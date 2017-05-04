function [xcorrArr, lagArrMs] = plotxcorrtotal(fileGroup, maxLagMs)
xcorrArr = [];
for iFile = 1:numel(fileGroup)
    spikeFile = fileGroup{iFile};
    load(spikeFile,'spikeDataArray','frameRate');
    nFrame = numel(spikeDataArray{1}.dffs);
    xcorrMaxLagFrame = round(maxLagMs*frameRate/1000);
    for roi1 = 1:numel(spikeDataArray)
        for roi2 = (roi1+1):numel(spikeDataArray)
            spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
            spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);

            [currXcorrArr, lagArr] = xcorr(spikeVec1, spikeVec2,xcorrMaxLagFrame);
            xcorrArr = addarr(xcorrArr,currXcorrArr);
        end
    end
end
%convert from frames back to Ms
lagArrMs = lagArr ./ frameRate .* 1000;

dir = fileparts(fileGroup{1});
save([dir filesep 'xcorr.mat'],'lagArrMs','xcorrArr');
plotcorrelogram(xcorrArr, lagArrMs);


function plotcorrelogram(xcorrArr, lagArrMs)
figure;
bar(lagArrMs,xcorrArr)

ylimit = round(max(xcorrArr)*1.5);
set(gca,'XTick',lagArrMs);
if ylimit ~= 0
    axis([lagArrMs(1) lagArrMs(end) 0 ylimit]);
else
    axis([lagArrMs(1) lagArrMs(end) 0 1]);
end

title(sprintf('Sum crosscorrelogram of all ROI pairs in area'));
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