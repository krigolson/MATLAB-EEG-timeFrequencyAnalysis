function statMap = doWAVStats(data,alpha)

% alpha is the corrected p value to use

nFreqs = size(data,1);
nTime = size(data,2);

for i = 1:nFreqs

    for o = 1:nTime

        tempData = squeeze(data(i,o,:));

        [h p ci stats] = ttest(tempData);

        if p <= alpha

            statMap(i,o) = stats.tstat;

        else

            statMap(i,o) = 0;

        end

    end

end