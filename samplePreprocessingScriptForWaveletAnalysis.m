clear all;
close all;
clc;

% load a data set for analysis into EEGLAB format
[EEG] = doLoadBVData('Cognitive_Assessment_01.vhdr');

% not needed but here for demonstration purposes
%[EEG] = doRemoveChannels(EEG,{},EEG.chanlocs);

% not needed but here for demonstration purposes
%[EEG] = doInterpolate(EEG,EEG.chanlocs,'spherical');

% rereference the data
[EEG] = doRereference(EEG,{'TP9','TP10'},EEG.chanlocs);

% filter the data, note the higher top end to get at high gamma range
[EEG] = doFilter(EEG,0.1,100,60,2,500);

% epoch the data
[EEG] = doEpochData(EEG,{'S202','S203'},[-500 1502]);

% implement a baseline correction
[EEG] = doBaseline(EEG,[-200,0]);

% check for gradient artifacts
[EEG] = doArtifactRejection(EEG,'Gradient',30);

% check for difference artifacts
[EEG] = doArtifactRejection(EEG,'Difference',150);

% remove artifact trials
[EEG] = doRemoveEpochs(EEG,EEG.artifactPresent);

% run the FFT transform on each condition
[WAV] = doWAV(EEG,{'S202','S203'},[-500 -300],1,30,60,6);

% plot the Wavelets for both conditions side by size for channel 52
condition1WaveletData = squeeze(WAV.data(52,:,:,1));
condition2WaveletData = squeeze(WAV.data(52,:,:,2));
condition1PercentData = squeeze(WAV.percent(52,:,:,1));
condition2PercentData = squeeze(WAV.percent(52,:,:,2));

subplot(2,2,1);
imagesc(condition1WaveletData);
title('Channel Pz: Condition One');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
set(gca,'YDir','normal');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(condition1WaveletData,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);
subplot(2,2,2);
imagesc(condition2WaveletData);
title('Channel Pz: Condition Two');
xlabel('Time (ms)');
set(gca,'YDir','normal');
ylabel('Frequency (Hz)');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(condition2WaveletData,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);

subplot(2,2,3);
imagesc(condition1PercentData);
title('Channel Pz: Condition One');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
set(gca,'YDir','normal');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(condition1WaveletData,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);
subplot(2,2,4);
imagesc(condition2PercentData);
title('Channel Pz: Condition Two');
xlabel('Time (ms)');
set(gca,'YDir','normal');
ylabel('Frequency (Hz)');
xticklabels = EEG.times(1):100:EEG.times(end);
xticks = linspace(1,size(condition2WaveletData,2),numel(xticklabels));
set(gca,'XTick',xticks,'XTickLabel',xticklabels);