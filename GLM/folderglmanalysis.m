function couplingFile = folderglmanalysis(baseDir)
%FOLDERGLMANALYSIS Concatenates all spikes-*.m files found in the given
%directory, computes coupling filters, and saves to a coupling-*.m file.

spikeFilePaths = currentdir(baseDir , '^spikes-.*\.mat$');
if numel(spikeFilePaths) == 0
    couplingFile = '';
    return
end

for iFile = 1:numel(spikeFilePaths)
    spikeFilePath = [baseDir filesep spikeFilePaths{iFile}];
    spikes = load(spikeFilePath);
    
    % extract spike times
    numFrames = numel(spikes.bkgSubtractedTraces{1});
    numCells = numel(spikes.spikeDataArray);
    
    if iFile == 1
        for i = 1:numCells
            binarySpike{i} = [];
        end
    end
    
    for i = 1:numCells
        curr = zeros(numFrames, 1);
        curr(spikes.spikeDataArray{i}.rasterSpikeTimes) = 1;
        binarySpike{i} = vertcat(binarySpike{i}, curr);
    end
end

[t, couplingFilters] = computecoupledglm(binarySpike, spikes.frameRate);
% Names it with the same convention as the first spikes file found.
[~, spikeFileName, ~] = fileparts(spikeFilePaths{1});
tag = spikeFileName(8:end);
couplingFile = ['couplings-' tag '.mat'];
savePath = [baseDir filesep couplingFile];
save(savePath, 't', 'couplingFilters');

end

