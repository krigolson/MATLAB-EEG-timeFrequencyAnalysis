function FFT = doFFT(inputData,markers,flag)

    % written as a shell by Olav Krigolson
    % runs FFT analysis byu conditions on EEG data structure
    
    numberOfConditions = size(markers,2);
    numberOfEpochs = size(inputData.data,3);

    if flag == 0
    
        for conditionCounter = 1:numberOfConditions
            
            tempData = [];
            tempDataCounter = 1;
            
            for epochCounter = 1:numberOfEpochs
        
                if strcmp(markers(conditionCounter),inputData.epoch(epochCounter).eventtype)
                
                    tempData(:,:,tempDataCounter) = inputData.data(:,:,epochCounter);
                    tempDataCounter = tempDataCounter + 1;
                    
                end
                
            end
            
            if isempty(tempData)
                ERP.data(:,:,conditionCounter) = NaN(size(inputData.data,1),size(inputData.data,2));
                FFT.data(:,:,conditionCounter) = NaN(size(inputData.data,1),(size(inputData.data,2)/2)-1);
                FFTFrequencies = 1:(size(inputData.data,2)/2)-1;
            else
                [FFTResults, trialPower, FFTPower,  trialPhase, FFTFrequencies] = doFourier(tempData,inputData.srate);
                FFT.data(:,:,conditionCounter) = FFTResults;
                FFT.phase(:,:,conditionCounter) = FFTPower;
                if numberOfConditions == 1
                    FFT.trialPower(:,:,:,conditionCounter) = trialPower;
                    FFT.trialPhase(:,:,:,conditionCounter) = trialPhase;
                end
            end
    
            FFT.epochCount(conditionCounter) = tempDataCounter - 1;
            
        end

    end
    if flag == 1
    
        for conditionCounter = 1:numberOfConditions
            
            tempData = [];
            tempDataCounter = 1;
            
            for epochCounter = 1:numberOfEpochs
        
                tempData(:,:,tempDataCounter) = inputData.data(:,:,epochCounter);
                tempDataCounter = tempDataCounter + 1;
                
            end
            
            if isempty(tempData)
                ERP.data(:,:,conditionCounter) = NaN(size(inputData.data,1),size(inputData.data,2));
                FFT.data(:,:,conditionCounter) = NaN(size(inputData.data,1),(size(inputData.data,2)/2)-1);
                FFTFrequencies = 1:(size(inputData.data,2)/2)-1;
            else
                [FFTResults, trialPower, FFTPower,  trialPhase, FFTFrequencies] = doFourier(tempData,inputData.srate);
                FFT.data(:,:,conditionCounter) = FFTResults;
                FFT.phase(:,:,conditionCounter) = FFTPower;
                if numberOfConditions == 1
                    FFT.trialPower(:,:,:,conditionCounter) = trialPower;
                    FFT.trialPhase(:,:,:,conditionCounter) = trialPhase;
                end
            end
    
            FFT.epochCount(conditionCounter) = tempDataCounter - 1;
            
        end

    end

    
    FFT.frequencies = FFTFrequencies;
    FFT.totalEpochs = numberOfEpochs;
    FFT.chanlocs = inputData.chanlocs;
    FFT.srate = inputData.srate;
    FFT.epochTime(1) = inputData.xmin;
    FFT.epochTime(2) = inputData.xmax;
    FFT.times = inputData.times;
    
    disp('FFTs have now been created...');
    
end