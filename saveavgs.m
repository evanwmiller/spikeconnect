function saveavgs(baseDir)
%SAVES SPIKE RELATED DATA TO MATLAB FILE
%   Takes in a directory with spikes-*.mat and roi-*.mat files and returns
%   a cell array of dff values for each cell, an array of mean dff values
%   for each cell, and a hashmap pairing a mean dff value with its roi
%   type. Saves under the file avgs.mat

rois = {}; 
roiFilePaths = recursdir(baseDir , '^roi-.*.mat$'); 
for iRoiFile = 1:numel(roiFilePaths)
    load(roiFilePaths{iRoiFile} , 'assignments');
    for i = 1:numel(assignments)
        rois{i} = assignments{i}; 
    end
end

spikeFilePaths = recursdir(baseDir , '^spikes-.*.mat$');
for iSpikeFile = 1:numel(spikeFilePaths) 
    load(spikeFilePaths{iSpikeFile} , 'spikeDataArray'); 
    means = []; 
    dffVals = {}; 
    
    
    
    for i = 1:numel(spikeDataArray) 
        spikeTimes = spikeDataArray{i}.rasterSpikeTimes; 
        spikeVals = []; 
        for index = 1:numel(spikeTimes)
            spikeVals = [spikeVals spikeDataArray{i}.dffTrace(spikeTimes(index))]; 
        end
        means = [means mean(spikeVals)]; 
        dffVals{i} = spikeVals; 
    end
    groups = containers.Map(rois,means); 
    saveDir = [baseDir '\avgs.mat']; 
    save(saveDir, 'means', 'dffVals', 'groups'); 
end


end

