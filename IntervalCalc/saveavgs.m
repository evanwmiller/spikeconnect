function saveavgs(baseDir)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

ROIs = {};
roiFilePaths = recursdir(baseDir , '^roi-.*.mat$');
for iRoiFile = 1:numel(roiFilePaths)
    load(roiFilePaths{iRoiFile} , 'assignments');
    for i = 1:numel(assignments)
        ROIs{i} = assignments{i};
    end
end

spikeFilePaths = recursdir(baseDir , '^spikes-.*.mat$');
for iSpikeFile = 1:numel(spikeFilePaths) %for every spike file in the path specified
    load(spikeFilePaths{iSpikeFile} , 'spikeDataArray'); %load the file
    means = [];
    vals = {};
    
    
    
    for i = 1:numel(spikeDataArray) %for every cell in spikeDataArray in the file
        spiketimes = spikeDataArray{i}.rasterSpikeTimes; %assign spiketimes to the values found in rasterSpikeTimes
        spikevals = [];
        for index = 1:numel(spiketimes)
            spikevals = [spikevals spikeDataArray{i}.dffTrace(spiketimes(index))];
        end
        means = [means mean(spikevals)];
        vals{i} = spikevals;
    end
    groups = containers.Map(ROIs,means);
    saveDir = [baseDir '\avgs.mat'];
    save(saveDir, 'means', 'vals', 'groups');
end


end

