% original code from Michael X Cohen, the GURU
% modified by O. Krigolson

% create a few sine waves and sum

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
    sine_waves(fi,:) = amplit(fi) * sin(2*pi*time*frex(fi) + phases(fi));
end

%% Compute discrete-time Fourier transform

signal  = sum(sine_waves,1); % sum to simplify
N       = length(signal);    % length of sequence
fourierTime = ((1:N)-1)/N;   % "time" used for sine waves
nyquist = srate/2;           % Nyquist frequency -- the highest frequency you can measure in the data

% initialize Fourier output matrix
fourierCoefs = zeros(size(signal)); 

% These are the actual frequencies in Hz that will be returned by the
% Fourier transform. The number of unique frequencies we can measure is
% exactly 1/2 of the number of data points in the time series (plus DC). 
frequencies = linspace(0,nyquist,floor(N/2)+1);


% loop over frequencies
for fi=1:N
    
    % create sine wave for this frequency
    fourierSine = exp( -1i*2*pi*(fi-1).*fourierTime );
    
    % compute dot product as sum of point-wise elements
    fourierCoefs(fi) = sum(fourierSine.*sum(sine_waves));
    
    % note: this can also be expressed as a vector-vector product
    % fourier(fi) = fourierSine*signal';
end

% scale Fourier coefficients to original scale
fourierCoefs = fourierCoefs / N;


figure(1), clf
subplot(2,1,1)
plot(real(exp(-2*pi*1i*(10).*fourierTime )))
xlabel('time (a.u.)'), ylabel('Amplitude')
title('Sine wave')

hold on;
plot(signal)
title('Data')
hold off;

subplot(2,1,2)
plot(frequencies,abs(fourierCoefs(1:length(frequencies))).^2,'*-')
xlabel('Frequency (Hz)')
ylabel('Power (\muV)')
title('Power spectrum derived from discrete Fourier transform')