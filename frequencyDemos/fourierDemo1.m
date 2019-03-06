% code from Michael X Cohen, the TF Guru
% modified by O. Krigolson

% define a sampling rate
srate = 1000;

% list some frequencies
frex = [ 3   10   5   15   35 ];

% list some random amplitudes... make sure there are the same number of
% amplitudes as there are frequencies!
amplit = [ 5   15   10   5   7 ];

% phases... list some random numbers between -pi and pi
phases = [  pi/7  pi/8  pi  pi/2  -pi/4 ];

% define time...
time = -1:1/srate:1;

% now we loop through frequencies and create sine waves
sine_waves = zeros(length(frex),length(time));
for fi=1:length(frex)
    % Fix this next line!
    sine_waves(fi,:) = amplit(fi) * sin(2*pi*time*frex(fi) + phases(fi));
end

% now plot the result
subplot(3,5,3)
plot(time,sum(sine_waves))
title('sum of sine waves')
xlabel('Time (s)'), ylabel('Amplitude (arb. units)');

pause;

% now plot each wave separately
for fi=1:length(frex)
    subplot(3,5,5+fi)
    % Fix this next line!
    plot(time,sine_waves(fi,:))
    axis([ time([1 end]) -max(amplit) max(amplit) ])
end

% Now compute Fourier representation of summed sine waves

% take Fourier transform (via fast-Fourier transform)
sineX = fft( sum(sine_waves) )/length(time);

% define vector of frequencies in Hz
hz = linspace(0,srate/2,floor(length(time)/2)+1);

subplot(3,5,13);
plot(hz,2*abs(sineX(1:length(hz))),'ro-','markeredgecolor','m','markerfacecolor','k')

% make the plot look a bit nicer
set(gca,'xlim',[0 max(frex)*1.2])
xlabel('Frequency (Hz)'), ylabel('Amplitude')
