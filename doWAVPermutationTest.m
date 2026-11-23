function STATS = doWAVPermutationTest(conditionA,conditionB,times,frequencies,varargin)
%doWAVPermutationTest Paired t-test at every time-frequency point, with a
%   cluster-based permutation test to correct for multiple comparisons.
%
%   STATS = doWAVPermutationTest(conditionA,conditionB,times,frequencies)
%
%   The test is conditionA minus conditionB, so a positive t means more
%   power in conditionA. It works on any frequencies x time x participants
%   data (for example one channel, or the mean of several channels, taken
%   from the output of doWAV), and on any pair of conditions.
%
% INPUTS
%   conditionA  : frequencies x time x participants
%   conditionB  : the same size as conditionA, with participants in the
%                 same order. Use [] to test conditionA against zero (for
%                 example if conditionA is already a difference).
%   times       : time of each sample in ms, one per column of the data
%   frequencies : frequency of each row of the data in Hz
%
% NAME-VALUE PAIRS
%   'TestWindow'      : [start end] in ms. Only these times are tested.
%                       Default is the whole epoch. Leave out the baseline
%                       period: baseline correction forces every
%                       participant close to zero there, so tiny
%                       differences give large t values.
%   'FrequencyWindow' : [low high] in Hz. Only these frequencies are
%                       tested. Default is all of them.
%   'Alpha'           : two-sided alpha, used for the t-test at each point
%                       (which also forms the clusters) and for the
%                       clusters. Default 0.05.
%   'Permutations'    : number of random sign flips. Default 5000. If
%                       there are few enough participants that every
%                       possible sign flip is no more than this, every
%                       possible one is used and the test is exact.
%   'ClusterStatistic': 'mass' (sum of t in the cluster, default) or
%                       'size' (number of points in the cluster).
%   'Seed'            : seed for the random sign flips, so the result is
%                       the same each time. Default 1. Use [] to leave the
%                       random number generator alone.
%
% OUTPUT, a structure with
%   tMap, pMap             : t and uncorrected p at every point
%   tCritical              : the t value that corresponds to Alpha
%   tested                 : true for the points that were tested
%   significantUncorrected : tested points with p < Alpha
%   clusters               : one entry per cluster, largest first, with its
%                            points, size, mass, corrected p, direction and
%                            its range in time and frequency
%   significantCorrected   : points in clusters with corrected p < Alpha
%   nullDistribution       : largest cluster statistic in each permutation
%   plus the times, frequencies, settings and number of participants
%
% HOW THE CORRECTION WORKS
%   Points that pass the t-test are grouped into clusters of touching
%   points with the same sign. Each cluster is scored (by default with the
%   sum of its t values). If the conditions did not differ, the sign of
%   each participant's difference would be arbitrary, so the signs are
%   flipped at random many times and the largest cluster score is kept each
%   time. A cluster's corrected p is the proportion of those scores that
%   are at least as large as its own.
%
%   A significant cluster means the conditions differ somewhere. It does
%   not show that every point in the cluster differs, or exactly when or at
%   what frequency the difference starts and stops.
%
% Needs the Statistics and Machine Learning Toolbox (tcdf, tinv).
%
% See also plotWAVPermutationTest, doWAV

%% Inputs

parser = inputParser;
addParameter(parser,'TestWindow',[],@(x) isempty(x) || (isnumeric(x) && numel(x) == 2));
addParameter(parser,'FrequencyWindow',[],@(x) isempty(x) || (isnumeric(x) && numel(x) == 2));
addParameter(parser,'Alpha',0.05,@(x) isnumeric(x) && isscalar(x) && x > 0 && x < 1);
addParameter(parser,'Permutations',5000,@(x) isnumeric(x) && isscalar(x) && x >= 1);
addParameter(parser,'ClusterStatistic','mass',@(x) any(strcmpi(x,{'mass','size'})));
addParameter(parser,'Seed',1,@(x) isempty(x) || (isnumeric(x) && isscalar(x)));
parse(parser,varargin{:});
settings = parser.Results;

if isempty(conditionB)
    differences = double(conditionA);
else
    if ~isequal(size(conditionA),size(conditionB))
        error('conditionA and conditionB must be the same size (frequencies x time x participants).');
    end
    differences = double(conditionA) - double(conditionB);
end

if ndims(differences) ~= 3
    error('The data must be frequencies x time x participants.');
end

[numberOfFrequencies,numberOfTimes,numberOfParticipants] = size(differences);
times = times(:)';
frequencies = frequencies(:)';

if numel(times) ~= numberOfTimes
    error('times has %d values but the data have %d time points.',numel(times),numberOfTimes);
end
if numel(frequencies) ~= numberOfFrequencies
    error('frequencies has %d values but the data have %d frequencies.',numel(frequencies),numberOfFrequencies);
end
if numberOfParticipants < 2
    error('At least two participants are needed.');
end
if any(~isfinite(differences(:)))
    error('The data contain NaN or Inf. Remove participants with missing conditions first.');
end

if isempty(settings.TestWindow)
    settings.TestWindow = [times(1) times(end)];
end
if isempty(settings.FrequencyWindow)
    settings.FrequencyWindow = [frequencies(1) frequencies(end)];
end

timeTested = times >= settings.TestWindow(1) & times <= settings.TestWindow(2);
frequencyTested = frequencies >= min(settings.FrequencyWindow) & frequencies <= max(settings.FrequencyWindow);
tested = frequencyTested' & timeTested;   % frequencies x time

if ~any(tested(:))
    error('TestWindow and FrequencyWindow leave no points to test.');
end

useSize = strcmpi(settings.ClusterStatistic,'size');

%% t-test at every point

tMap = tValues(differences);
pMap = 2 * tcdf(-abs(tMap),numberOfParticipants-1);
tCritical = tinv(1-settings.Alpha/2,numberOfParticipants-1);
significantUncorrected = pMap < settings.Alpha & tested;

%% Clusters in the real data

[clusterPoints,clusterScore] = findClusters(tMap,tCritical,tested,useSize);

%% Chance distribution of the largest cluster

if ~isempty(settings.Seed)
    rng(settings.Seed);
end

% every sign flip is used if there are few enough, otherwise a random sample
if 2^numberOfParticipants <= settings.Permutations
    numberOfPermutations = 2^numberOfParticipants;
    allSigns = 1 - 2*(dec2bin(0:numberOfPermutations-1,numberOfParticipants) == '1');   % permutations x participants
    exactTest = true;
else
    numberOfPermutations = round(settings.Permutations);
    allSigns = [];
    exactTest = false;
end

nullDistribution = zeros(numberOfPermutations,1);

for permutationCounter = 1:numberOfPermutations
    if exactTest
        signs = allSigns(permutationCounter,:);
    else
        signs = 2*(rand(1,numberOfParticipants) > 0.5) - 1;
    end
    tPermuted = tValues(differences .* reshape(signs,1,1,[]));
    [~,permutedScore] = findClusters(tPermuted,tCritical,tested,useSize);
    if ~isempty(permutedScore)
        nullDistribution(permutationCounter) = max(abs(permutedScore));
    end
end

%% Corrected p for each cluster

clusters = struct('points',{},'size',{},'mass',{},'statistic',{},'p',{},'direction',{},'timeRange',{},'frequencyRange',{});
significantCorrected = false(size(tMap));

[~,order] = sort(abs(clusterScore),'descend');

for clusterCounter = order(:)'
    points = clusterPoints{clusterCounter};
    [frequencyIndex,timeIndex] = ind2sub(size(tMap),points);
    newCluster.points = points;
    newCluster.size = numel(points);
    newCluster.mass = sum(tMap(points));
    newCluster.statistic = abs(clusterScore(clusterCounter));
    if exactTest
        % the real data are one of the sign flips, so they are already counted
        newCluster.p = sum(nullDistribution >= newCluster.statistic - 1e-10) / numberOfPermutations;
    else
        newCluster.p = (sum(nullDistribution >= newCluster.statistic) + 1) / (numberOfPermutations + 1);
    end
    newCluster.direction = sign(newCluster.mass);   % 1 = A greater than B, -1 = B greater than A
    newCluster.timeRange = [min(times(timeIndex)) max(times(timeIndex))];
    newCluster.frequencyRange = [min(frequencies(frequencyIndex)) max(frequencies(frequencyIndex))];
    clusters(end+1) = newCluster; %#ok<AGROW>
    if newCluster.p < settings.Alpha
        significantCorrected(points) = true;
    end
end

%% Output

STATS.tMap = tMap;
STATS.pMap = pMap;
STATS.tCritical = tCritical;
STATS.tested = tested;
STATS.significantUncorrected = significantUncorrected;
STATS.clusters = clusters;
STATS.significantCorrected = significantCorrected;
STATS.nullDistribution = nullDistribution;
STATS.times = times;
STATS.frequencies = frequencies;
STATS.numberOfParticipants = numberOfParticipants;
STATS.alpha = settings.Alpha;
STATS.testWindow = settings.TestWindow;
STATS.frequencyWindow = settings.FrequencyWindow;
STATS.clusterStatistic = lower(settings.ClusterStatistic);
STATS.numberOfPermutations = numberOfPermutations;
STATS.exactTest = exactTest;

end

%% Local functions

function tMap = tValues(differences)
% one-sample t at every point; a point where nobody differs gets t = 0
n = size(differences,3);
standardError = std(differences,0,3) / sqrt(n);
tMap = mean(differences,3) ./ standardError;
tMap(standardError == 0) = 0;
end

function [clusterPoints,clusterScore] = findClusters(tMap,tCritical,tested,useSize)
% Clusters of touching points (including diagonally) beyond the threshold.
% Positive and negative t values are clustered separately.
clusterPoints = {};
clusterScore = [];
for direction = [1 -1]
    found = connectedPoints(direction*tMap > tCritical & tested);
    for counter = 1:numel(found)
        clusterPoints{end+1} = found{counter}; %#ok<AGROW>
        if useSize
            clusterScore(end+1) = numel(found{counter}); %#ok<AGROW>
        else
            clusterScore(end+1) = sum(tMap(found{counter})); %#ok<AGROW>
        end
    end
end
end

function groups = connectedPoints(mask)
% Groups of touching true points in a 2D mask, as lists of linear indices.
% Uses the Image Processing Toolbox if it is installed and a slower search
% if it is not, so the function does not depend on that toolbox.
persistent haveToolbox
if isempty(haveToolbox)
    haveToolbox = exist('bwconncomp','file') == 2;
end

if haveToolbox
    found = bwconncomp(mask,8);
    groups = found.PixelIdxList;
    return
end

groups = {};
[numberOfRows,numberOfColumns] = size(mask);
remaining = mask;
stack = zeros(nnz(mask),1);

for start = find(mask)'
    if ~remaining(start)
        continue
    end
    members = zeros(nnz(remaining),1);
    memberCount = 0;
    stackCount = 1;
    stack(1) = start;
    remaining(start) = false;
    while stackCount > 0
        current = stack(stackCount);
        stackCount = stackCount - 1;
        memberCount = memberCount + 1;
        members(memberCount) = current;
        row = rem(current-1,numberOfRows) + 1;
        column = (current - row)/numberOfRows + 1;
        for rowStep = -1:1
            for columnStep = -1:1
                neighbourRow = row + rowStep;
                neighbourColumn = column + columnStep;
                if neighbourRow >= 1 && neighbourRow <= numberOfRows && neighbourColumn >= 1 && neighbourColumn <= numberOfColumns
                    neighbour = (neighbourColumn-1)*numberOfRows + neighbourRow;
                    if remaining(neighbour)
                        remaining(neighbour) = false;
                        stackCount = stackCount + 1;
                        stack(stackCount) = neighbour;
                    end
                end
            end
        end
    end
    groups{end+1} = sort(members(1:memberCount)); %#ok<AGROW>
end
end
