% demo of FFT decomposition

clear all;
close all;
clc;

t = (0:0.001:1)';

y1 = sin(2*pi*20*t);

subplot(2,2,1);
plot(t(1:200),y1(1:200));
axis([0 0.2 -3 3]);

pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y1,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));
ylim([0 1]);

pause;

y2 = 2 * sin(2 *pi*20*t);

subplot(2,2,3);
plot(t(1:200),y2(1:200));
axis([0 0.2 -3 3]);

pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y2,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,4);
plot(f,2*abs(Y(1:NFFT/2+1)));
ylim([0 1]);

pause;

figure;

t = (0:0.001:1)';

y1 = sin(2*pi*20*t);

subplot(2,2,1);
plot(t(1:200),y1(1:200));
axis([0 0.2 -3 3]);

pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y1,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));
ylim([0 1]);

pause;

y2 = sin(2*pi*100*t);

subplot(2,2,3);
plot(t(1:200),y2(1:200));
axis([0 0.2 -3 3]);

pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y2,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,4);
plot(f,2*abs(Y(1:NFFT/2+1)));
ylim([0 1]);

figure;

t = (0:0.001:1)';

y1 = sin(2*pi*20*t);

subplot(2,2,1);
plot(t(1:200),y1(1:200));
axis([0 0.2 -3 3]);

pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y1,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));
ylim([0 1]);

pause;

y3 = sin(2*pi*100*t);
y4 = 1.5*sin(2*pi*20*t);
y5 = sin(2*pi*30*t);
y6 = 0.5*sin(2*pi*300*t);
y7 = sin(2*pi*100*t);
y8 = sin(4*pi*50*t);
y9 = sin(3.2*pi*40*t);
y2 = y3 + y4 + y5 + y6 +y7 +y8 + y9;

subplot(2,2,3);
plot(t(1:200),y2(1:200));
axis([0 0.2 -3 3]);

pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y2,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,4);
plot(f,2*abs(Y(1:NFFT/2+1)));
ylim([0 1]);