function [power,phase,frequencies] = doFourier(data,srate,varargin)
    
    %   doFFT run a fft on EEG data
    %   based on code by Michael X. Cohen
    %   modified by C. Hassall and O. Krigolson
    %   May 23, 2018 last update
    %   The input data is channels x time x epochs (3 D matrix)
    %   The output data is in power (amplitude squared)
    
    %   create a Hanning Window to reduce edge artifacts - divide by two to get
    %   half a cosine cycle - the discontinuity from edge artifacts is
    %   because the start and end voltages of the segment are different
    %   Mike Cohen says to turn off the Hanning Window
    %   hanning_window = [];
    %   hanning_window = 0.5 - cos(2*pi*linspace(0,1,length_of_data))/2;
    %   convolute the data with the hanning window
    %   tapered_data = trimmedEEG.data .* hanning_window;
    
    % note, we are do not demean the data as in principle this is captured
    % at 0Hz which measures the DC offset. Further, if the data has been
    % filtered before FFT then the mean has already been removed.
    
    % added some varargin to allow for hamming, hanning, demean, and
    % upperbound, set the first varargin to 0 for no tapered window, to 1
    % for a hanning window, and to 2 for a hamming window. Set the second
    % varargin to 1 to demean the data or 0 to not do this. Finally, the
    % last varargin specifies the frequecy to chop the data at for cleanup
    % purposes.
    
    % determine how many data points are in the analysis
    pnts = size(data,2);
    
    % check for optional parameters
    doIng = 0;
    doDeMean = 0;
    uBound = 0;
    if ~isempty(varargin)
        doIng = varargin{1};
        doDeMean = varargin{2};
        uBound = varargin{3};
    end
    
    % demean the data if flagged
    if doDeMean == 1
        data = data - mean(data,2);
    end
            
    % apply a hanning or hamming window if flagged
    if doIng == 1
        hWindow = hanning(size(data,2))';
        data = data .* hWindow;
    end
    if doIng == 2
        hWindow = hamming(size(data,2))';
        data = data .* hWindow;
    end

    % run the fft
    fftOutput = fft(data,[],2);
    
    % keep a copy of the output for phase
    power = fftOutput;
    phase = angle(fftOutput);

    %We want to scale the output of the fft function to be divided by the length of the data submitted because The FFT computation involves a lot of summing over time points, and so dividing by N puts the data back to the scale of the original input.
    power = power/pnts;

    % we want to remove the negative half of the fft output because it is redundant
    if ndims(power) == 3
        power = power(:,1:round(pnts/2),:);
    else
        power = power(:,1:round(pnts/2)); % if 2D data is passed
    end

    % you take abs of the output of the fft because you want the resultant of the real and imaginary output
    power = abs(power);

    % square the amplitude to get power
    power = power.^2;

    % multiply by 2 to ensure that the positive aspect of the fft output
    % has been corrected for the loss of the negative aspect, NB, Mathewson
    % does not do this
    power = 2 * power;

    % finally, remove the very first value as it is the power at 0 Hz (the DC power)
    if ndims(power) == 3
        power(:,1,:) = [];
    else
        power(:,1) = [];
    end
    
    % remove phase negative half and DC offset
    if ndims(phase) == 3
        phase = phase(:,1:round(pnts/2),:);
        phase(:,1,:) = []; % remove phase for DC offset
    else
        phase = phase(:,1:round(pnts/2)); % if 2D data is passed
        phase(:,1) = [];
    end

    % Compute the average FFT output if passes three dimenionsal data
    if ndims(data) == 3
        power = squeeze(nanmean(power,3));
        phase = squeeze(nanmean(phase,3));
    end

    % determine frequency resolution
    frequencyResolution = srate / pnts;
    
    % create a frequency bin
    frequencies = frequencyResolution:frequencyResolution:size(power,2)*frequencyResolution;
    
    if uBound > 0
        if uBound < max(frequencies)
            uBoundF = find(frequencies >= uBound,1);
        else
            [~, uBoundF] = max(frequencies);
        end
        uBoundF = round(uBoundF);
        power = power(:,1:uBoundF);
        phase = phase(:,1:uBoundF);
        frequencies = frequencies(1:uBoundF);
    end
        
end