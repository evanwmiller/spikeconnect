function cmArr = causalityanalysis(fileGroup, params)
%CALCXCIARR Calculates the causality metrics for the
%island represented by fileGroup. 
%

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


function [cmCorr, lagArrMs, seconds] = calccmcorr(fileGroup, roi1, roi2, params)
maxLagMs = params.monoMaxLagMs;
totals = 0;
totalFrames = 0;
cmCorr = [];
totalLagArr = [];
lag = [];
for iFile = 1:numel(fileGroup)
    spikeFile = fileGroup{iFile};
    load(spikeFile, 'spikeDataArray', 'frameRate');
    nFrame = numel(spikeDataArray{1}.dffs);
    totalFrames = (totalFrames + nFrame) * numel(fileGroup);
    cmCorrMaxLagFrame = round(maxLagMs*frameRate/1000);

    spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
    spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);
    
    [currcmcorrArrB, lagArr] = xcorr(spikeVec1, spikeVec2, cmCorrMaxLagFrame);
    totalLagArr = [totalLagArr lagArr];
    totals = [totals currcmcorrArrB];
end

for elem = 1:numel(totals)
    poissResults = poisscdf(totals(elem), 0); %need to change second paramter
    if poissResults > 1 - params.alphaThreshold
        cmCorr = [cmCorr poissResults];
        if elem <= numel(totalLagArr)
            lag = [lag totalLagArr(elem)];
        end
    end

end
    

%convert from frames back to Ms
lagArrMs = lag ./ frameRate .* 1000;
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
