function saveavgs(baseDir)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

rois = {}; %instantiate cell array containing cell type assignments
roiFilePaths = recursdir(baseDir , '^roi-.*.mat$'); %find all roi-*.mat files
for iRoiFile = 1:numel(roiFilePaths)
    load(roiFilePaths{iRoiFile} , 'assignments');
    for i = 1:numel(assignments)
        rois{i} = assignments{i}; %for every roi assignment, set new index in the cell array to the string
    end
end

spikeFilePaths = recursdir(baseDir , '^spikes-.*.mat$');
for iSpikeFile = 1:numel(spikeFilePaths) %for every spike file in the path specified
    load(spikeFilePaths{iSpikeFile} , 'spikeDataArray'); %load the file
    means = []; %instantiate means array (to be saved in a mat file)
    dffVals = {}; %cell array in which each array of spike dff values will be stored
    
    
    
    for i = 1:numel(spikeDataArray) %for every cell in spikeDataArray in the file
        spikeTimes = spikeDataArray{i}.rasterSpikeTimes; %assign spiketimes to the values found in rasterSpikeTimes
        spikeVals = []; %array of spike dff values for current cell
        for index = 1:numel(spikeTimes)
            spikeVals = [spikeVals spikeDataArray{i}.dffTrace(spikeTimes(index))]; %add dff value to array for each spiketime
        end
        means = [means mean(spikeVals)]; %add mean of spikeVals array to means array
        dffVals{i} = spikeVals; %add spikeVals array to vals cell array
    end
    groups = containers.Map(rois,means); %create cell type - dff mean hashmap
    saveDir = [baseDir '\avgs.mat']; %find directory
    save(saveDir, 'means', 'vals', 'groups'); %save as avgs.mat in current folder
end


end

