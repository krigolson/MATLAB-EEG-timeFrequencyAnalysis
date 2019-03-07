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
[EEG] = doFilter(EEG,1,30,60,2,500);

% epoch the data
[EEG] = doEpochData(EEG,{'S202','S203'},[-200 800]);

% implement a baseline correction
[EEG] = doBaseline(EEG,[-200,0]);

% check for gradient artifacts
[EEG] = doArtifactRejection(EEG,'Gradient',30);

% check for difference artifacts
[EEG] = doArtifactRejection(EEG,'Difference',150);

% remove artifact trials
[EEG] = doRemoveEpochs(EEG,EEG.artifactPresent);

% run the FFT transform on each condition
[FFT] = doFFT(EEG,{'S202','S203'});

% plot the first 30 Hz of signal for channel Fz for each condition, NB,
% this is 60 data points given the sampling rate and size of data selected
dataToPlot = squeeze(FFT.data(52,1:30,:));
bar(dataToPlot);
title('FFT Analysis');
xticks([1:1:30]);
xticklabels(FFT.frequencies);
xlabel('Frequency (Hz)');
ylabel('Power (uV^2)');