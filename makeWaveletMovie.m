clear all
close all
clc

load('sampleData');

vidObj = VideoWriter('TED');
open(vidObj);

theChannel = 5;
sRate = 500;

x1 = 1;
x2 = 500;

figure

EEG = doFilter(EEG,0.1,30,2,60);

for i = 1:200
    
    currentData = squeeze(EEG.data(5,x1:x2));
    
    [waveletData, waveletPercent, frex] = doWavelet(currentData,[1:1:500],[],1,50,500,6,500);

    imagesc(squeeze(waveletData(1,:,:)));
    set(gca,'YDir','normal');
    title('TP10');
    set(gca,'Color','k');
    set(gca,'visible','off');
    set(gcf,'Color','k');
    drawnow
    
    currentFrame = getframe;
    % write the frame to the video file
    writeVideo(vidObj,currentFrame);
    
    x1 = x2 + 1;
    x2 = x2 + 500;
    
end

close(vidObj);

    
    