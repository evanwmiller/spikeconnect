function xciArr = calcxciarr(fileGroup, params)
%CALCXCIARR Calculates the XCI (cross-correlation connection index) for the
%island represented by fileGroup. 
%
% XCI between cell A and cell B is the fraction of spikes of cell A that has 
% a corresponding spike in cell B in the monosynaptic lag range.

spikeCountArr = countspikes(fileGroup);
nRoi = numel(spikeCountArr);

xciArr = nan(nRoi);
for roi1 = 1:nRoi
    for roi2 = (roi1+1):nRoi
        [xcorrArr, lagArrMs, seconds] = calcxcorr(fileGroup, roi1, roi2, params);
        counts = bucket(xcorrArr, lagArrMs, params);
        if spikeCountArr(roi1)/seconds < params.minFreq ...
                || spikeCountArr(roi2)/seconds < params.minFreq
            xciArr(roi1, roi2) = nan;
        elseif counts.atob >= counts.btoa
            xciArr(roi1, roi2) = counts.atob/spikeCountArr(roi1);
        else
            xciArr(roi1, roi2) = -counts.btoa/spikeCountArr(roi2);  
        end
    end
end


function [xcorrArr, lagArrMs, seconds] = calcxcorr(fileGroup, roi1, roi2, params)
% CALCXCORR Adaptation of xcorr to work with multiple files and values
% reported in frames/milliseconds. Returns lag is ms and corresponding
% xcorr value. Also reports the total length of the movie in seconds.
maxLagMs = params.monoMaxLagMs;
xcorrArr = [];
totalFrames = 0;
for iFile = 1:numel(fileGroup)
    spikeFile = fileGroup{iFile};
    load(spikeFile, 'spikeDataArray', 'frameRate');
    nFrame = numel(spikeDataArray{1}.dffs);
    totalFrames = totalFrames + nFrame;
    xcorrMaxLagFrame = round(maxLagMs*frameRate/1000);

    spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
    spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);

    [currXcorrArr, lagArr] = xcorr(spikeVec1, spikeVec2,xcorrMaxLagFrame);
    xcorrArr = addarr(xcorrArr,currXcorrArr);
end

%convert from frames back to Ms
lagArrMs = lagArr ./ frameRate .* 1000;
seconds = totalFrames / frameRate;


function counts = bucket(xcorrArr, lagArrMs, params)
minLag = params.monoMinLagMs;
maxLag = params.monoMaxLagMs;
counts.atob = sum(xcorrArr(find(lagArrMs >= -maxLag & lagArrMs <= -minLag)));
counts.btoa = sum(xcorrArr(find(lagArrMs >= minLag & lagArrMs <= maxLag)));


function sumArr = addarr(arr1,arr2)
if isempty(arr1)
    sumArr = arr2;
else
    sumArr = arr1+arr2;
end


function spikeVector = times2vector(spikeTimes, nFrame)
spikeVector = zeros(1,nFrame);
spikeVector(spikeTimes) = 1;
