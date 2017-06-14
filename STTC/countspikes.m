function spikeCountArr = countspikes(fileGroup)
% Returns an array with the # of spikes for each ROI across all movies in
% fileGroup.

load(fileGroup{1},'roiTraces');
nRoi = numel(roiTraces);

spikeCountArr = zeros(1,nRoi);
for iFile = 1:numel(fileGroup)
    load(fileGroup{iFile},'spikeDataArray');
    for iRoi = 1:nRoi
        spikeCountArr(iRoi) = spikeCountArr(iRoi) ...
                + numel(spikeDataArray{iRoi}.rasterSpikeTimes);
    end
end