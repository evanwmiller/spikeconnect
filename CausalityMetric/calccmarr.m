function cmArr = calccmarr(fileGroup, params)
%CALCXCIARR Calculates the causality metrics for the
%island represented by fileGroup. 
%

spikeCountArr = countspikes(fileGroup);
nRoi = numel(spikeCountArr);
cmCorr = [];
lag = [];
cmArr = nan(nRoi);
for roi1 = 1:nRoi
    for roi2 = (roi1+1):nRoi
        [cmCorrArr, lagArrMs, seconds, K0] = calccmcorr(fileGroup, roi1, roi2, params);
        K0 = mean(K0);
        for elem = 1:numel(cmCorrArr)
            poissResults = poisscdf(cmCorrArr(elem), K0); %need to change second paramter
            if poissResults > 1 - params.alphaThreshold
                cmCorr = [cmCorr poissResults];
                if elem <= numel(lagArrMs)
                    lag = [lag lagArrMs(elem)];
                end
            end
        end
        counts = bucket(cmCorr, lag, params);
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


function [totals, lagArrMs, seconds, totals0] = calccmcorr(fileGroup, roi1, roi2, params)
maxLagMs = params.monoMaxLagMs;
zeroLagMs = params.monoZeroLagMs;
totals = 0;
totals0 = 0;
totalFrames = 0;
totalLagArr = [];
for iFile = 1:numel(fileGroup)
    spikeFile = fileGroup{iFile};
    load(spikeFile, 'spikeDataArray', 'frameRate');
    nFrame = numel(spikeDataArray{1}.dffs);
    totalFrames = (totalFrames + nFrame) * numel(fileGroup);
    cmCorrMaxLagFrame = round(maxLagMs*frameRate/1000);
    cmCorr0LagFrame = round(zeroLagMs*frameRate/1000);

    spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
    spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);
    
    [currcmcorrArrB, lagArr] = xcorr(spikeVec1, spikeVec2, cmCorrMaxLagFrame);
    [K0Arr, lagArr0] = xcorr(spikeVec1, spikeVec2, cmCorr0LagFrame);
    totalLagArr = [totalLagArr lagArr];
    totals = [totals currcmcorrArrB];
    totals0 = [totals0 K0Arr];
end

%convert from frames back to Ms
lagArrMs = totalLagArr ./ frameRate .* 1000;
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
