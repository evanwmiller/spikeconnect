function cmArr = calccmarr(fileGroup, params)
%CALCCMARR Calculates the causality metrics for the
%island represented by fileGroup. 
%  Returns an n x n matrix of ones and zeros where ones
%  denote positive causality between the two spikes.

spikeCountArr = countspikes(fileGroup); 
nRoi = numel(spikeCountArr); 
cmArr = nan(nRoi);
for roi1 = 1:nRoi
    for roi2 = (roi1+1):nRoi
        [ktArr, k0Arr] = calccmcorr(fileGroup, roi1, roi2, params);
        kt = ktArr;
        k0 = k0Arr;
        poissResults = poisscdf(kt, k0);
        if poissResults > 1 - params.alphaThreshold
            cmArr(roi1,roi2) = 1;
        else
            cmArr(roi1,roi2) = 0;
        end
    end
end


function [ktArr, k0Arr] = calccmcorr(fileGroup, roi1, roi2, params)
maxLagMs = params.monoMaxLagMs;
minLagMs = params.monoMinLagMs;
zeroLagMs = params.monoZeroLagMs;
ktArr = 0;
k0Arr = 0;
totalFrames = 0;
for iFile = 1:numel(fileGroup)
    spikeFile = fileGroup{iFile};
    load(spikeFile, 'spikeDataArray', 'frameRate');
    nFrame = numel(spikeDataArray{1}.dffs);
    totalFrames = (totalFrames + nFrame) * numel(fileGroup);
    cmCorrMaxLagFrame = round(maxLagMs*frameRate/1000);
    cmCorr0LagFrame = round(zeroLagMs*frameRate/1000);
    cmCorrMinLagFrame = round(minLagMs*frameRate/1000);

    spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
    spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);
    
    [xcorrKt, lagArr] = xcorr(spikeVec1, spikeVec2, cmCorrMaxLagFrame);
    
    for x = 1:numel(xcorrKt)
        if lagArr(x) >= cmCorrMinLagFrame || lagArr(x) <= -cmCorrMinLagFrame
            ktArr = ktArr + xcorrKt(x);
        end
    end
    xcorrK0 = xcorr(spikeVec1, spikeVec2, cmCorr0LagFrame);
    k0Arr = k0Arr + sum(xcorrK0);
end

function spikeVector = times2vector(spikeTimes, nFrame)
spikeVector = zeros(1,nFrame);
spikeVector(spikeTimes) = 1;
