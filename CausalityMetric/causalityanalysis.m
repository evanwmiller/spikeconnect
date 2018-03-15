function cmArr = causalityanalysis(fileGroup, params)
%CALCXCIARR Calculates the XCI (cross-correlation connection index) for the
%island represented by fileGroup. 
%
% XCI between cell A and cell B is the fraction of spikes of cell A that has 
% a corresponding spike in cell B in the monosynaptic lag range.

spikeCountArr = countspikes(fileGroup);
nRoi = numel(spikeCountArr);

cmArr = nan(nRoi);
for roi1 = 1:nRoi
    for roi2 = (roi1+1):nRoi
        [cmCorrArr, lagArrMs, seconds] = calccmcorr(fileGroup, roi1, roi2, params);
        counts = bucket(cmCorrArr, lagArrMs, params);
        if spikeCountArr(roi1)/seconds < params.minFreq ...
                || spikeCountArr(roi2)/seconds < params.minFreq
            cmArr(roi1, roi2) = nan;
        elseif counts.atob >= counts.btoa
            cmArr(roi1, roi2) = counts.atob/spikeCountArr(roi1);
        else
            cmArr(roi1, roi2) = -counts.btoa/spikeCountArr(roi2);  
        end
    end
end


function [cmCorrArr, lagArrMs, seconds] = calccmcorr(fileGroup, roi1, roi2, params)
% CALCXCORR Adaptation of xcorr to work with multiple files and values
% reported in frames/milliseconds. Returns lag is ms and corresponding
% xcorr value. Also reports the total length of the movie in seconds.
maxLagMs = params.monoMaxLagMs;
cmCorrArr = [];
totalFrames = 0;
for iFile = 1:numel(fileGroup)
    spikeFile = fileGroup{iFile};
    load(spikeFile, 'spikeDataArray', 'frameRate');
    nFrame = numel(spikeDataArray{1}.dffs);
    totalFrames = totalFrames + nFrame;
    cmCorrMaxLagFrame = round(maxLagMs*frameRate/1000);

    spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
    spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);

    currcmcorrArr = poisspdf(spikeVec1, spikeVec2);
    [x, lagArr] = xcorr(spikeVec1, spikeVec2,cmCorrMaxLagFrame);
    cmCorrArr = addarr(cmCorrArr,currcmcorrArr);
end

%convert from frames back to Ms
lagArrMs = lagArr ./ frameRate .* 1000;
seconds = totalFrames / frameRate;


function counts = bucket(cmcorrArr, lagArrMs, params)
minLag = params.monoMinLagMs;
maxLag = params.monoMaxLagMs;
counts.atob = sum(cmcorrArr(find(lagArrMs >= -maxLag & lagArrMs <= -minLag)));
counts.btoa = sum(cmcorrArr(find(lagArrMs >= minLag & lagArrMs <= maxLag)));


function sumArr = addarr(arr1,arr2)
if isempty(arr1)
    sumArr = arr2;
else
    sumArr = arr1+arr2;
end


function spikeVector = times2vector(spikeTimes, nFrame)
spikeVector = zeros(1,nFrame);
spikeVector(spikeTimes) = 1;
