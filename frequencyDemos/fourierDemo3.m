% demo to show the perfect deconstruction and construction of a signal

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

figure(1);

subplot(2,2,1);
plot(t,y9);
ylim([-3 3]);
title('Original Signal');
L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y9,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,2);
plot(f,2*abs(Y(1:NFFT/2+1)));
title('FFT Decomposition');

pause;

yn = y9;

figure(2);

yn = yn - y1;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y1);
ylim([-3 3]);
title('Substracted Signal');
pause;

yn = yn - y2;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y2);
ylim([-3 3]);
title('Substracted Signal');
pause;

yn = yn - y3;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y3);
ylim([-3 3]);
title('Substracted Signal');
pause;

yn = yn - y4;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y4);
ylim([-3 3]);
title('Substracted Signal');
pause;

yn = yn - y5;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y5);
ylim([-3 3]);
title('Substracted Signal');
pause;

yn = yn - y6;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y6);
ylim([-3 3]);
title('Substracted Signal');
pause;

yn = yn - y7;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y7);
ylim([-3 3]);
title('Substracted Signal');
pause;

yn = yn - y8;
subplot(2,2,1);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,2);
plot(t,y8);
ylim([-3 3]);
title('Substracted Signal');
pause;


yn = yn + y1;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y1);
ylim([-3 3]);
title('Added Signal');
pause;

yn = yn + y2;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y2);
ylim([-3 3]);
title('Added Signal');
pause;

yn = yn + y3;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y3);
ylim([-3 3]);
title('Added Signal');
pause;

yn = yn + y4;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y4);
ylim([-3 3]);
title('Added Signal');
pause;

yn = yn + y5;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y5);
ylim([-3 3]);
title('Added Signal');
pause;

yn = yn + y6;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y6);
ylim([-3 3]);
title('Added Signal');
pause;

yn = yn + y7;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y7);
ylim([-3 3]);
title('Added Signal');
pause;

yn = yn + y8;
subplot(2,2,3);
plot(t,yn);
ylim([-3 3]);
title('Current Signal');

subplot(2,2,4);
plot(t,y8);
ylim([-3 3]);
title('Added Signal');
pause;

figure(1);
subplot(2,2,3);
plot(t,y9);
ylim([-3 3]);
title('Original Signal');
pause;

L = length(t);
Fs = 1000;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y9,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,2,4);
plot(f,2*abs(Y(1:NFFT/2+1)));
title('FFT Decomposition');