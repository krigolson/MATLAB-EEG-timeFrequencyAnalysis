function figures = plotWAVPermutationTest(STATS,varargin)
%plotWAVPermutationTest Plots the output of doWAVPermutationTest.
%
%   figures = plotWAVPermutationTest(STATS)
%
%   Makes two figures:
%     1. Uncorrected: t at every time-frequency point with the points that
%        pass the t-test outlined, and the same map with only those points.
%     2. Corrected: the t map with each cluster outlined and labelled with
%        its corrected p (thick outline if it survives), next to the
%        cluster scores compared with chance.
%
% NAME-VALUE PAIRS
%   'ConditionLabels' : names of conditionA and conditionB, in that order.
%                       Default {'A','B'}.
%   'Title'           : text added to the start of each figure title, for
%                       example the channel name. Default ''.
%   'ColorMap'        : colour map for the t maps. Default jet(256).
%   'TLimit'          : the colour scale runs from -TLimit to TLimit.
%                       Default is the largest |t| rounded up.
%   'LabelClusters'   : smallest cluster, in points, that gets a p label.
%                       Default is 1% of the tested points.
%   'SaveAs'          : file name without extension. If given, the figures
%                       are saved as <name>_uncorrected.png and
%                       <name>_clusters.png. Default '' (not saved).
%
% OUTPUT
%   figures : handles of the two figures
%
% See also doWAVPermutationTest

parser = inputParser;
addParameter(parser,'ConditionLabels',{'A','B'},@(x) iscell(x) && numel(x) == 2);
addParameter(parser,'Title','',@(x) ischar(x) || isstring(x));
addParameter(parser,'ColorMap',jet(256),@(x) isnumeric(x) && size(x,2) == 3);
addParameter(parser,'TLimit',[],@(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
addParameter(parser,'LabelClusters',[],@(x) isempty(x) || (isnumeric(x) && isscalar(x)));
addParameter(parser,'SaveAs','',@(x) ischar(x) || isstring(x));
parse(parser,varargin{:});
settings = parser.Results;

labelA = settings.ConditionLabels{1};
labelB = settings.ConditionLabels{2};
contrast = sprintf('%s minus %s',labelA,labelB);
prefix = char(settings.Title);
if ~isempty(prefix)
    prefix = [prefix ': '];
end

if isempty(settings.TLimit)
    settings.TLimit = max(1,ceil(max(abs(STATS.tMap(:)))));
end
if isempty(settings.LabelClusters)
    settings.LabelClusters = 0.01 * nnz(STATS.tested);
end

ink = [11 11 11]/255; softInk = [82 81 78]/255; surface = [252 252 251]/255; accent = [235 104 52]/255;
style = struct('ink',ink,'softInk',softInk,'surface',surface,'colourMap',settings.ColorMap, ...
    'limits',[-settings.TLimit settings.TLimit],'colourLabel',sprintf('t (%s)',contrast));

numberTested = nnz(STATS.tested);
numberPassed = nnz(STATS.significantUncorrected);
testedText = sprintf('%g to %g ms, %g to %g Hz',STATS.testWindow(1),STATS.testWindow(2),STATS.frequencyWindow(1),STATS.frequencyWindow(2));
directionText = sprintf('Positive t = more power for %s, negative = more for %s',labelA,labelB);

%% Figure 1: uncorrected

figures(1) = figure('Color',surface,'Position',[50 50 1300 480]);
layout = tiledlayout(figures(1),1,2,'TileSpacing','compact','Padding','compact');

ax = nexttile(layout);
drawMap(ax,STATS,STATS.tMap,style);
outline(ax,STATS,STATS.significantUncorrected,ink,1.2);
title(ax,sprintf('t at every point; outline is p < %g',STATS.alpha),'Color',ink,'FontSize',13);
ylabel(ax,'Frequency (Hz)','Color',softInk);

ax = nexttile(layout);
maskedMap = STATS.tMap;
maskedMap(~STATS.significantUncorrected) = 0;
drawMap(ax,STATS,maskedMap,style);
title(ax,sprintf('Only points with p < %g (|t| > %.2f)',STATS.alpha,STATS.tCritical),'Color',ink,'FontSize',13);

title(layout,sprintf('%s%s, paired t-test at every time-frequency point, uncorrected (n = %d)',prefix,contrast,STATS.numberOfParticipants), ...
    'Color',ink,'FontWeight','bold','FontSize',15);
subtitle(layout,sprintf('%d tests (%s) with no correction, so about %d would pass by chance alone; %d passed. %s', ...
    numberTested,testedText,round(STATS.alpha*numberTested),numberPassed,directionText),'Color',softInk,'FontSize',11);

%% Figure 2: cluster-based permutation test

figures(2) = figure('Color',surface,'Position',[50 50 1300 480]);
layout = tiledlayout(figures(2),1,2,'TileSpacing','compact','Padding','compact');

clusterP = [STATS.clusters.p];
labelled = [STATS.clusters.size] >= settings.LabelClusters | clusterP < STATS.alpha;

ax = nexttile(layout);
drawMap(ax,STATS,STATS.tMap,style);
outline(ax,STATS,STATS.significantUncorrected,ink,0.8);
outline(ax,STATS,STATS.significantCorrected,ink,3);
for clusterCounter = find(labelled)
    [frequencyIndex,timeIndex] = ind2sub(size(STATS.tMap),STATS.clusters(clusterCounter).points);
    text(ax,mean(STATS.times(timeIndex)),mean(STATS.frequencies(frequencyIndex)),sprintf('p = %.3f',clusterP(clusterCounter)), ...
        'Color',ink,'FontSize',10,'HorizontalAlignment','center','BackgroundColor',surface,'Margin',1);
end
title(ax,sprintf('Corrected p for each cluster; %d of %d below %g',sum(clusterP < STATS.alpha),numel(clusterP),STATS.alpha), ...
    'Color',ink,'FontSize',13);
ylabel(ax,'Frequency (Hz)','Color',softInk);

ax = nexttile(layout); hold(ax,'on');
histogram(ax,STATS.nullDistribution,60,'FaceColor',softInk,'EdgeColor','none','FaceAlpha',0.5);
xline(ax,prctile(STATS.nullDistribution,100*(1-STATS.alpha)),'--','Color',ink,'LineWidth',1.2);
for clusterCounter = find(labelled)
    xline(ax,STATS.clusters(clusterCounter).statistic,'-','Color',accent,'LineWidth',2);
end
if strcmp(STATS.clusterStatistic,'size')
    scoreText = 'cluster size (points)';
else
    scoreText = 'cluster mass (|sum of t|)';
end
title(ax,'Observed clusters (orange) against chance','Color',ink,'FontSize',13);
xlabel(ax,['Largest ' scoreText ' in each permutation'],'Color',softInk);
ylabel(ax,'Permutations','Color',softInk);
set(ax,'Color',surface,'XColor',softInk,'YColor',softInk,'FontSize',12,'TickDir','out','Box','off');

if STATS.exactTest
    permutationText = sprintf('all %d possible sign flips',STATS.numberOfPermutations);
else
    permutationText = sprintf('%d random sign flips',STATS.numberOfPermutations);
end
title(layout,sprintf('%s%s, cluster-based permutation test (n = %d)',prefix,contrast,STATS.numberOfParticipants), ...
    'Color',ink,'FontWeight','bold','FontSize',15);
subtitle(layout,sprintf('Clusters formed at p < %g, scored by %s, %s, %s; thick outline = survives, dashed line = %g%% point of chance', ...
    STATS.alpha,STATS.clusterStatistic,permutationText,testedText,100*(1-STATS.alpha)),'Color',softInk,'FontSize',11);

%% Save

if strlength(string(settings.SaveAs)) > 0
    exportgraphics(figures(1),[char(settings.SaveAs) '_uncorrected.png'],'Resolution',130,'BackgroundColor',surface);
    exportgraphics(figures(2),[char(settings.SaveAs) '_clusters.png'],'Resolution',130,'BackgroundColor',surface);
end

end

%% Local functions

function drawMap(ax,STATS,map,style)
% One time-frequency panel, with the untested part faded.
imagesc(ax,STATS.times,STATS.frequencies,map);
axis(ax,'xy');
colormap(ax,style.colourMap);
clim(ax,style.limits);
hold(ax,'on');

% fade everything that was not tested
fade = ones([size(map) 3]) .* reshape(style.surface,1,1,3);
faded = image(ax,STATS.times,STATS.frequencies,fade);
faded.AlphaData = 0.6 * ~STATS.tested;

if STATS.times(1) < 0 && STATS.times(end) > 0
    xline(ax,0,'-','Color',style.softInk);
end
set(ax,'Color',style.surface,'XColor',style.softInk,'YColor',style.softInk,'FontSize',12,'TickDir','out','Box','off');
xlabel(ax,'Time (ms)','Color',style.softInk);
bar = colorbar(ax);
bar.Label.String = style.colourLabel;
bar.Color = style.softInk;
bar.Label.Color = style.softInk;
bar.FontSize = 11;
end

function outline(ax,STATS,mask,colour,width)
% Outline of the true points in a mask.
if any(mask(:)) && all(size(mask) > 1)
    contour(ax,STATS.times,STATS.frequencies,double(mask),[0.5 0.5],'Color',colour,'LineWidth',width);
end
end
