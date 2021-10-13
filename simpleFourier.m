function [power,phase,frequencies] = simpleFourier(data,srate)
    
    %   doFFT run a fft on data
    
    % run a FFT on a vector
    
    % determine how many data points are in the analysis
    pnts = size(data,2);
    
    if pnts == 1
        data = data';
    end
    
    % run the fft
    fftOutput = fft(data);
    
    % keep a copy of the output for phase
    power = fftOutput;
    phase = angle(fftOutput);

    %We want to scale the output of the fft function to be divided by the length of the data submitted because The FFT computation involves a lot of summing over time points, and so dividing by N puts the data back to the scale of the original input.
    power = power/pnts;

    % we want to remove the negative half of the fft output because it is redundant
    power = power(:,1:round(pnts/2)); % if 2D data is passed

    % you take abs of the output of the fft because you want the resultant of the real and imaginary output
    power = abs(power);

    % square the amplitude to get power
    power = power.^2;

    % multiply by 2 to ensure that the positive aspect of the fft output
    % has been corrected for the loss of the negative aspect, NB, Mathewson
    % does not do this
    power = 2 * power;

    % finally, remove the very first value as it is the power at 0 Hz (the DC power)
    power(:,1) = [];

    % remove phase negative half and DC offset
    phase = phase(:,1:round(pnts/2)); % if 2D data is passed
    phase(:,1) = [];

    % determine frequency resolution
    frequencyResolution = srate / pnts;
    
    % create a frequency bin
    frequencies = frequencyResolution:frequencyResolution:size(power,2)*frequencyResolution;
        
end