% Plots the result of sampling a noisy sine function at different rates
% C. Hassall
% Oct. 28, 2011
% name changed and modified by O Krigolson Feb 2018

close all;
clear all;
clc;

num_points = 10000;
samplingRates = [10000 5000 500 100 10 5 2 1]; % The number of plots we'll need 
max_x = 5; % Set a bound on x
xs = 1:(max_x-1)/num_points:max_x; % The time values
ys = sin(xs); % The signal (no noise)
rs = zeros(1,length(ys)); % The noise

% Make some noise
r = 0;
for i = 1:length(xs)
    rs(i) = r + 0.01 * randn();
    r = rs(i);
end

% Add in the noise
ys = ys + rs;

% Find the ranges, for scaling the plots
minx = min(xs)-0.1; maxx = max(xs)+0.1; miny = min(ys)-0.1; maxy = max(ys)+0.1;

figure;
for n = 1:length(samplingRates)
    step_size = samplingRates(n);
    if step_size < 1 % Something went wrong
        break;
    end
    subset = 1:step_size:num_points;
    clf;
    subplot(1,2,1);
    plot(xs,ys,'r'); % Uncomment this to see the original data
    title('Original Signal');
    subplot(1,2,2);
    plot(xs(subset), ys(subset),'o');
    xlim([minx maxx]);
    ylim([miny maxy]);
    xlabel('Time');
    ylabel('Voltage');
    title(['Number of Samples: ' num2str(length(subset))]);
    drawnow;
    
    pause;
    
end