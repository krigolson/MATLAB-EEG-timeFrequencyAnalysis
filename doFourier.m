function [fftResults,frequencies] = doFourier(data,srate)
    
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
    
    % determine how many data points are in the analysis
    pnts = size(data,2);
    
    % run the fft
    fftOutput = fft(data,[],2);

    % determine frequency resolution
    frequencyResolution = srate / pnts;

    %We want to scale the output of the fft function to be divided by the length of the data submitted because The FFT computation involves a lot of summing over time points, and so dividing by N puts the data back to the scale of the original input.
    fftOutput = fftOutput/pnts;

    % we want to remove the negative half of the fft output because it is redundant
    fftOutput = fftOutput(:,1:pnts/2,:);

    % you take abs of the output of the fft because you want the resultant of the real and imaginary output
    fftOutput = abs(fftOutput);

    % square the amplitude to get power
    fftOutput = fftOutput.^2;

    % multiply by 2 to ensure that the positive aspect of the fft output has been corrected for the loss of the negative aspect
    fftOutput = 2 * fftOutput;

    % finally, remove the very first value as it is the power at 0 Hz (the DC power)
    fftOutput(:,1,:) = [];

    % Compute the average FFT output for this condition
    fftResults = squeeze(nanmean(fftOutput,3));

    % create a frequency bin
    frequencies = frequencyResolution:frequencyResolution:length(fftOutput)*frequencyResolution;

end