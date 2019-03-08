clear all;
close all;
clc;

% load a data set for analysis into EEGLAB format
[EEG] = doLoadNBackData('File1.bdf','File2.bdf','File3.bdf');

% not needed but here for demonstration purposes
%[EEG] = doRemoveChannels(EEG,{'AF7'},EEG.chanlocs);

% not needed but here for demonstration purposes
%[EEG] = doInterpolate(EEG,EEG.chanlocs,'spherical');

% rereference the data
[EEG] = doRereference(EEG,{'TP9','TP10'},EEG.chanlocs);

% filter the data, note the higher top end to get at high gamma range
[EEG] = doFilter(EEG,1,30,60,2,500);

% epoch the data
[EEG] = doEpochData(EEG,{'S1','S2','S3'},[-1000 1000]);

% check for gradient artifacts
[EEG] = doArtifactRejection(EEG,'Gradient',30);

% check for difference artifacts
[EEG] = doArtifactRejection(EEG,'Difference',150);

% remove artifact trials
[EEG] = doRemoveEpochs(EEG,EEG.artifactPresent);

% run the FFT transform on each condition
[FFT] = doFFT(EEG,{'S1','S2''S3'});

bar(EEG.channelArtifactPercentages);
ylim([0 100]);

save('Subject1','FFT');