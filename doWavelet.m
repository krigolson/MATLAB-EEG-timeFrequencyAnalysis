function [waveletData,waveletDataPercent,frex] = doWavelet(data,timePoints,baselineWindow,minimumFrequency,maximumFrequency,frequencySteps,mortletParameter,samplingRate)
%doWavelet Does a wavelet
%   O. Krigolson
%   October, 2017
% data is channels x time x trials
% samplingRate is the sampling rate of the data
% timePoints is the time vector for each sample
% baselineWindow are the start and end points of the baseline
% mortletParameter = 6 is normal, the range is from abour 3 to 8, the lower
% the value is the more temporal precision there is, the higher the number
% more frequency precision there is
% minimumFrequency is the lower bound of frequencies to examine
% maximumFrequency is the upper bound of frequencies to examine
% frequencySteps is the number of steps between the min and max frequencies

% get the data points for the baseline times (i.e., 1 50)
baseidx = baselineWindow;

% setup wavelet parameters

% frequency parameters
% the y-vector for plots showing the frequency range
frex = linspace(minimumFrequency,maximumFrequency,frequencySteps); % Linear scale
%frex = logspace(log10(min_freq),log10(max_freq),num_frex); % Log scale

% used in creating the actual wavelet
s = logspace(log10(mortletParameter(1)),log10(mortletParameter(end)),frequencySteps) ./ (2*pi*frex);

% length of the wavelet kernel, why -2 to 2??? WHY? MAYBE length of wavelet = 2 x
% sampling rate
wavtime = -2:1/samplingRate:2;

% middle of the wavelet - but also the length of the zero padding
half_wave = (length(wavtime)-1)/2;

% FFT parameters
% length of the wavelet
nWave = length(wavtime);

% length of data in the analysis when it is concatenated
nData = size(data,2) * size(data,3);

% this is the length of the convolution, data plus size of wavelet
nConv = nWave + nData - 1;

% cycle through the channels
for channelCounter = 1:size(data,1)
    % concatenate all the trials to help with edge artifacts (maybe?) and improve
    % processing speed (how much?)
    alldata = [];
    alldata = reshape(data(channelCounter,:,:) ,1,[]);
    
    % run the FFT on the EEG data, use nConv, adds in zero padding as
    dataX   = fft(alldata,nConv);
    
    % initialize output time-frequency data
    tf = zeros(length(frex),size(data,2));
    
    % now perform convolution
    
    % loop over frequencies
    for fi=1:length(frex)
        
        % create wavelet and get its FFT - the wavelets is a combination of
        % Eulers waveform (first half) and the Gaussian (second half)
        wavelet  = exp(2*1i*pi*frex(fi).*wavtime) .* exp(-wavtime.^2./(2*s(fi)^2));
        
        % take the fft of the wavelet
        waveletX = fft(wavelet,nConv);
        
        % this standardizes the wavelet between 0 and 1
        waveletX = waveletX ./ max(waveletX);
        
        % now run convolution in one step - what is put into the fft is not the
        % dot the product of the EEG data and the wavelet, it is the dot
        % product of the fft of the EEG data and the wavelet - it is an inverse
        % fft as the two things going in are ffts already
        as = ifft(waveletX .* dataX);
        
        % cuts off half the wavlet from the start, and half from the end, the
        % bits that were zero padded in the first place
        as = as(half_wave+1:end-half_wave);
        
        % and reshape back to time X trials
        as = reshape( as, size(data,2), size(data,3) );
        
        % compute power and average over trials
        tf(fi,:) = mean( abs(as).^2 ,2);
    end
    
    % create new matrix for percent change
    tfpct = zeros(size(tf));
    
    % if a baseline was specified, apply it, and also compute percent
    % change
    if ~isempty(baseidx)
        
        activity = tf(:,:);
        
        % create a baseline
        baseline = mean(tf(:,baseidx(1):baseidx(2)),2);
        
        % decibel
        % somehow this converts it to decibels, remove activity that was
        % constant over time, WHY?
        tf(:,:) = 10*log10( bsxfun(@rdivide, activity, baseline) );
        
        % percent change
        tfpct(:,:) = 100 * bsxfun(@rdivide, bsxfun(@minus,activity,baseline), baseline);
    end

    % assign output variables
    waveletData(channelCounter,:,:) = tf;
    waveletDataPercent(channelCounter,:,:) = tfpct;
    
end

end