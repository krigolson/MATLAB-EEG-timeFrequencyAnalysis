[y, Fs] = audioread('heart.wav');
sound(y, Fs);

pause;

subplot(1,2,1);
plot(y);

L = length(y);

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
subplot(1,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));
xlim([0 500]); 