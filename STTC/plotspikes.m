function plotspikes(spikeFile, roi1, roi2, handles)
% PLOTSPIKES Plots the spike times of roi1 and roi2 from spikeFile, and
% plots the cross correlation of roi1 and roi2.
load(spikeFile,'spikeDataArray','frameRate');
nFrame = numel(spikeDataArray{1}.dffs);

figure('units','inches');
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) pos(3) round(pos(4))])

% Plot roi1 spikes
subplot(3,1,1);
plotroispikes(spikeDataArray,roi1,frameRate, nFrame);

% Plot roi2 spikes
subplot(3,1,2);
plotroispikes(spikeDataArray,roi2,frameRate, nFrame);

% Plot cross correlation histogram
h = subplot(3,1,3);
[xcorrArr, lagArr] = plotxcorrhist(spikeDataArray,roi1,roi2,frameRate, handles);
set(h, 'ButtonDownFcn', {@expandPlot, xcorrArr, lagArr, roi1, roi2});

function plotroispikes(spikeDataArray, roi, frameRate, nFrame)
t = spikeDataArray{roi}.rasterSpikeTimes; 
nSpike = numel(t);
for iSpike = 1:nSpike
  % draw a black vertical line of length 1 at time t(x) for roi1
  line([t(iSpike) t(iSpike)],[0 1],'Color','k'); 
end

axis([0 nFrame 0 1]);
set(gca,'YColor','w')
xlabel('Time (s)');
frameTick = get(gca,'xtick');
set(gca,'xticklabel',frameTick/frameRate);
set(gca,'ytick',[])
set(gca,'yticklabel',[])
title(sprintf('Spikes for ROI %d',roi));


function [xcorrArr, lagArrMs] = plotxcorrhist(spikeDataArray,roi1,roi2, frameRate, handles)
nFrame = numel(spikeDataArray{1}.dffs);
xcorrMaxLagMs = handles.xcorrMaxLagMs;
xcorrMaxLagFrame = round(xcorrMaxLagMs*frameRate/1000);

spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);

[xcorrArr, lagArr] = xcorr(spikeVec1, spikeVec2,xcorrMaxLagFrame);
%convert from frames back to Ms
lagArrMs = lagArr ./ frameRate .* 1000;
plotcorrelogram(xcorrArr, lagArrMs, roi1, roi2);
    
function expandPlot(~,~, xcorrArr, lagArrMs, roi1, roi2)
figure;
plotcorrelogram(xcorrArr, lagArrMs, roi1, roi2);


function plotcorrelogram(xcorrArr, lagArrMs, roi1, roi2)
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

