function updatefilepaths(baseDir)
% UPDATEFILEPATHS Recursively searches through baseDir for spikenet
% associated files and updates any file paths in order to accomodate moving
% folders. Spikenet associated files with saved file paths are roi-*.mat
% and spikes-*.mat, and both store snapPath.

roiFiles = recursdir(baseDir,'^roi-.*\.mat');
% for each roi file, access the original snap path, and swap the directory
% with the current directory.
for iFile = 1:numel(roiFiles)
    roiFile = roiFiles{iFile};
    load(roiFile,'snapPath');
    [~,name,ext] = fileparts(snapPath);
    [dir,~,~] = fileparts(roiFile);
    snapPath = [dir filesep name ext];
    save(roiFile,'snapPath','-append');
    
    %find spikes- files in the same directory and update those as well
    spikesFiles = currentdir(dir,'^spikes-.*\.mat','');
    for iSpike = 1:numel(spikesFiles)
        spikeFileName = spikesFiles{iSpike};
        spikeFile = [dir filesep spikeFileName];
        save(spikeFile, 'snapPath', '-append');
    end
end

fprintf('Updated %d data sets.\n',numel(roiFiles));
end