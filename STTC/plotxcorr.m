function [xcorrArr, lagArrMs] = plotxcorr(fileGroup,roi1,roi2, maxLagMs, toPlot)

if nargin == 4
    toPlot = true;
end
xcorrArr = [];
for iFile = 1:numel(fileGroup)
    spikeFile = fileGroup{iFile};
    load(spikeFile,'spikeDataArray','frameRate');
    nFrame = numel(spikeDataArray{1}.dffs);
    xcorrMaxLagFrame = round(maxLagMs*frameRate/1000);

    spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
    spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);

    [currXcorrArr, lagArr] = xcorr(spikeVec1, spikeVec2,xcorrMaxLagFrame);
    xcorrArr = addarr(xcorrArr,currXcorrArr);
end
%convert from frames back to Ms
lagArrMs = lagArr ./ frameRate .* 1000;

if toPlot == true
    plotcorrelogram(xcorrArr, lagArrMs, roi1, roi2);
end

function plotcorrelogram(xcorrArr, lagArrMs, roi1, roi2)
figure;
bar(lagArrMs,xcorrArr)

ylimit = round(max(xcorrArr)*1.5);
set(gca,'XTick',lagArrMs);
if ylimit ~= 0
    axis([lagArrMs(1) lagArrMs(end) 0 ylimit]);
else
    axis([lagArrMs(1) lagArrMs(end) 0 1]);
end

title(sprintf('Crosscorrelogram of ROI %d and %d',roi1,roi2));
xlabel('Time(ms)');
ylabel('Count');

function spikeVector = times2vector(spikeTimes, nFrame)
spikeVector = zeros(1,nFrame);
spikeVector(spikeTimes) = 1;

function sumArr = addarr(arr1,arr2)
if isempty(arr1)
    sumArr = arr2;
else
    sumArr = arr1+arr2;
end