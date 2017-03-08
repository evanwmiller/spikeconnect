function v1tov2spikepatch()
%patch spikesData.mat files from V1 into spikes-*.mat files for V2.
baseDir = uigetdir('', 'Select a folder');
if baseDir == 0; return; end;

oldFilePaths = recursdir(baseDir , '^spikesData.*.mat$');
for i = 1:numel(oldFilePaths)
    oldFile = oldFilePaths{i};
    f = load(oldFile);
    bkgSubtractedTraces = f.bkg_subtracted_traces;
    diffFeatures = f.diffFeatures;
    frameRate = 500;
    roiMasks = f.ROI_masks;
    roiTraces = f.ROI_traces;
    snapPath = f.snappath;
    spikeDataArray = cell(size(f.bkg_subtracted_traces));
    for j = 1:numel(spikeDataArray)
        spikeDataArray{j} = struct();
        spikeDataArray{j}.clusters = f.clusters{j};
        spikeDataArray{j}.spikesClusterIndex = f.spikes_cluster_idx{j};
        spikeDataArray{j}.baselineClusterIndex = f.baseline_cluster_idx{j};
        spikeDataArray{j}.rasterSpikeTimes = f.rasterSpikeTimes{j};
        spikeDataArray{j}.dffs = f.dffs{j};
        spikeDataArray{j}.dffSnr = f.dff_snr{j};
    end
    textPos = f.textPos;
    [dirName,fileName,ext] = fileparts(oldFile);
    newName = ['spikes-' fileName(11:end) '.mat'];
    newPath = [dirName filesep newName];
    save(newPath, 'bkgSubtractedTraces','diffFeatures','frameRate', 'roiMasks',...
        'roiTraces','snapPath','spikeDataArray','textPos');
end

