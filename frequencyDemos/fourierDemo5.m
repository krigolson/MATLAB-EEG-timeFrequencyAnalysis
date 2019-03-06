clc;

t = (0:0.001:1)';

y1 = sin(2*pi*50*t);
y2 = sin(2*pi*25*t);
y3 = sin(2*pi*10*t);
y4 = sin(2*pi*75*t);
y5 = sin(2*pi*14*t);
y6 = sin(2*pi*21*t);
y7 = sin(2*pi*19*t);
y8 = sin(2*pi*79*t);

y9 = y1+y2+y3+y4+y5+y6+y7+y8;

subplot(1,2,1);
plot(t,y1);
ylim([-3 3]);

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y1,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(1,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));

pause;

subplot(1,2,1);
plot(t,y2);
ylim([-3 3]);


L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y2,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(1,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));

pause;

subplot(1,2,1);
plot(t,y3);
ylim([-3 3]);

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y3,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(1,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));

pause;