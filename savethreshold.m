function savethreshold(spikeFilePaths, threshold, rearmFactor)
%SAVETHRESHOLD Save spike times based on a dff snr threshold and a re-arm
%factor (minimum frames of baseline before considering another spike).
for iSpikeFile = 1:numel(spikeFilePaths)
    load(spikeFilePaths{iSpikeFile}, 'spikeDataArray', ...
        'roiTraces', 'frameRate');
    %instantaneous frequency
    ifreqs = {};
    %interspike interval
    isiMs = {};
    freqs = {};
    
    % get number of frames per video
    nFrame = numel(spikeDataArray{1}.dffSnr);
    
    for i = 1:numel(spikeDataArray)
        %replace subtreshold events with NaN
        tmp = spikeDataArray{i}.dffSnr;
        tmp(tmp < threshold) = NaN;
        
        spikeDataArray{i}.rasterSpikeTimes = find(~isnan(tmp));
        spikeDataArray{i}.rasterSpikeTimes = ...
            burstaggregator(spikeDataArray{i}.rasterSpikeTimes, ...
                roiTraces{i}, ...
                rearmFactor);
        
        [ifreqs{i}, isiMs{i}, freqs{i}] = ...
            ifreq(spikeDataArray{i}.rasterSpikeTimes,frameRate, nFrame); 
    end
    
    save(spikeFilePaths{iSpikeFile} ,'spikeDataArray' ,'-append');
    save(spikeFilePaths{iSpikeFile}, 'rearmFactor','threshold','-append');
    
    [pathstr,movieName,~] = fileparts(spikeFilePaths{iSpikeFile});
    % 8 is length of 'spikes-' tag
    nameWithoutPrefix = movieName(8:end);
    filename = ['ifreqs-' nameWithoutPrefix '.mat'];
    if exist([pathstr filesep filename], 'file')
      save([pathstr filesep filename] , 'ifreqs', 'isiMs', 'freqs' , '-append')
    else
      save([pathstr filesep filename], 'ifreqs' , 'isiMs', 'freqs')
    end
end
end

