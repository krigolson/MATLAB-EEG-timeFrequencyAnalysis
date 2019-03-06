clear all;
close all;
clc;

t = (0:0.001:1)';

y1 = sin(2*pi*20*t);

subplot(2,3,1);
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

pause;

figure;

subplot(2,3,1);
plot(t(1:200),y1(1:200));
axis([0 0.2 -3 3]);

subplot(2,3,3);
plot(t(1:200),y2(1:200));
axis([0 0.2 -3 3]);

pause;

hold on;
y3 = y1 + y2;

for counter = 1:200
    
    subplot(2,3,5);
    plot(t(counter),y3(counter),'o');
    axis([0 0.2 -3 3]);
    
    hold on;
    drawnow;
    
    WaitSecs(0.05);
    
end

pause;
    
figure;

subplot(1,2,1);
plot(t(1:200),y3(1:200));
axis([0 0.2 -3 3]);

pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y3,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(1,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));

pause;