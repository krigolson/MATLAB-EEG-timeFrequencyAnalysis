function WAV = doWAV(EEG,markers,baselineWindow,minimumFrequency,maximumFrequency,frequencySteps,mortletParameter)

    % written as a shell by Olav Krigolson
    % runs FFT analysis byu conditions on EEG data structure
    
    disp('Starting Wavelet analysis...');
    
    if ~isempty(baselineWindow)
        x = find(EEG.times >= baselineWindow(1));
        y = find(EEG.times >= baselineWindow(2));
        baselinePoints(1) = x(1);
        baselinePoints(2) = y(1);
    end
    
    numberOfConditions = size(markers,2);
    numberOfEpochs = size(EEG.data,3);
    
    for conditionCounter = 1:numberOfConditions
        
        tempData = [];
        tempDataCounter = 1;
        
        for epochCounter = 1:numberOfEpochs
    
            if strcmp(markers(conditionCounter),EEG.epoch(epochCounter).eventtype)
            
                tempData(:,:,tempDataCounter) = EEG.data(:,:,epochCounter);
                tempDataCounter = tempDataCounter + 1;
                
            end
            
        end
        
        if ~isempty(baselineWindow)
            [waveletData,waveletDataPercent,WAVFrequencies] = doWavelet(tempData,EEG.times,baselinePoints,minimumFrequency,maximumFrequency,frequencySteps,mortletParameter,EEG.srate);
        else
            [waveletData,waveletDataPercent,WAVFrequencies] = doWavelet(tempData,EEG.times,[],minimumFrequency,maximumFrequency,frequencySteps,mortletParameter,EEG.srate);
        end
        WAV.data(:,:,:,conditionCounter) = waveletData;
        WAV.percent(:,:,:,conditionCounter) = waveletDataPercent;
        WAV.epochCount(conditionCounter) = tempDataCounter - 1;
        
    end
    
    WAV.frequencies = WAVFrequencies;
    WAV.totalEpochs = numberOfEpochs;
    WAV.chanlocs = EEG.chanlocs;
    WAV.srate = EEG.srate;
    WAV.epochTime(1) = EEG.xmin;
    WAV.epochTime(2) = EEG.xmax;
    WAV.times = EEG.times;
    if ~isempty(baselineWindow)
        WAV.baseline = baselineWindow;
    else
        WAV.baseline = [];
    end
    WAV.frequencyRange = [minimumFrequency maximumFrequency];
    WAV.frequencySteps = frequencySteps;
    WAV.mortletParameter = mortletParameter;
    
    disp('Wavelets have now been created...');
    
end