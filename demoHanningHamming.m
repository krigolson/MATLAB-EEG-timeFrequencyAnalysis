% sample script showing the difference between Hanning and Hamming Windows
% on FFT output.
% by Olav Krigolson

clear all;
close all;
clc;

load('sampleData');

EEG = doFilter(EEG,0.1,30,2,60,500);

SEEG = doSegmentData(EEG,{'S202','S203'},[-200 798]);

[SEEG] = doArtifactRejection(SEEG,'Difference',150);

[SEEG] = doRemoveEpochs(SEEG,SEEG.artifact.badSegments,0);

[power,phase,freqs] = doFourier(SEEG.data,500,0,0,30);

[hnpower,hnphase,hnfreqs] = doFourier(SEEG.data,500,1,0,30);

[hmpower,hmphase,hmfreqs] = doFourier(SEEG.data,500,2,0,30);

theChannel = 6;
sampleTrial = SEEG.data(theChannel,:,1);
subplot(4,3,1);
plot(sampleTrial,'LineWidth',3);
title('No Taper');
subplot(4,3,2);
plot(sampleTrial,'LineWidth',3);
title('Hanning Taper');
subplot(4,3,3);
plot(sampleTrial,'LineWidth',3);
title('HammingTaper');

subplot(4,3,4);
noTaper = ones(1,500);
plot([1:1:500],noTaper,'LineWidth',3);
subplot(4,3,5);
hn = hanning(500);
plot(hn,'LineWidth',3);
subplot(4,3,6);
hm = hamming(500);
plot(hm,'LineWidth',3);

subplot(4,3,7);
plot(noTaper.*sampleTrial,'LineWidth',3);
subplot(4,3,8);
plot(hn'.*sampleTrial,'LineWidth',3);
subplot(4,3,9);
plot(hm'.*sampleTrial,'LineWidth',3);

subplot(4,3,10);
bar(power(theChannel,:));
subplot(4,3,11);
bar(hnpower(theChannel,:));
subplot(4,3,12);
bar(hmpower(theChannel,:));

figure;
subplot(2,1,1);
plot(power(theChannel,:),'LineWidth',3);
hold on;
plot(hnpower(theChannel,:),'LineWidth',3);
plot(hmpower(theChannel,:),'LineWidth',3);

subplot(2,1,2);
barData = [hnpower(theChannel,:); hmpower(theChannel,:)];
bar(barData');