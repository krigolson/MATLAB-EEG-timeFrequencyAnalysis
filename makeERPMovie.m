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

f = figure

EEG = doFilter(EEG,0.1,100,2,60);

yLimit = 40;


for i = 1:2000
    
    set(gcf,'color','k');
    
    currentData1 = squeeze(EEG.data(1,x1:x2));
    currentData2 = squeeze(EEG.data(11,x1:x2));
    currentData3 = squeeze(EEG.data(43,x1:x2));
    currentData4 = squeeze(EEG.data(52,x1:x2));
    
    subplot(3,1,1);
    xValues1 = 1:1:500; 
    p1 = plot(xValues1,currentData1,'LineWidth',3,'Color','r');
    ylim([-1*yLimit yLimit]);
    xlim([1 500]);
    ylabel('AF7');
    set(gca,'visible','off');
    set(gca,'Color','k');
    
    subplot(3,1,2);
    xValues2 = 1:1:500; 
    p2 = plot(xValues2,currentData2,'LineWidth',3,'Color','g');
    ylim([-1*yLimit yLimit]);
    xlim([1 500]);
    ylabel('AF8');
    set(gca,'visible','off');
    set(gca,'Color','k');
    
    subplot(3,1,3);
    xValues3 = 1:1:500;  
    p3 = plot(xValues3,currentData3,'LineWidth',3,'Color','b');
    ylim([-1*yLimit yLimit]);
    xlim([1 500]);
    ylabel('TP9');
    set(gca,'visible','off');
    set(gca,'Color','k');
    
    drawnow;
    
    currentFrame = getframe(f);
    % write the frame to the video file
    writeVideo(vidObj,currentFrame);
    
    x1 = x1 + 5;
    x2 = x2 + 5;
    
end

close(vidObj);

    
    