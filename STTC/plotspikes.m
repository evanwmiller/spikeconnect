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
subplot(3,1,3);
plotxcorrhist(spikeDataArray,roi1,roi2, frameRate, handles);

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


function plotxcorrhist(spikeDataArray,roi1,roi2, frameRate, handles)
nFrame = numel(spikeDataArray{1}.dffs);
xcorrMaxLagMs = handles.xcorrMaxLagMs;
xcorrMaxLagFrame = round(handles.xcorrMaxLagMs*frameRate/1000);

spikeVec1 = times2vector(spikeDataArray{roi1}.rasterSpikeTimes, nFrame);
spikeVec2 = times2vector(spikeDataArray{roi2}.rasterSpikeTimes, nFrame);

[xcorrArr, lagArr] = xcorr(spikeVec1, spikeVec2,xcorrMaxLagFrame);
%convert from frames back to Ms
lagArrMs = lagArr ./ frameRate .* 1000;
bar(lagArrMs,xcorrArr)
hold on;
ylimit = round(max(xcorrArr)*1.5);
set(gca,'XMinorTick','on','XTick',lagArrMs);
if ylimit ~= 0
    axis([-xcorrMaxLagMs xcorrMaxLagMs 0 ylimit]);
else
    axis([-xcorrMaxLagMs xcorrMaxLagMs 0 1]);
end

%plot 4 dotted lines indicating mono lag range limits
mlr1 = [handles.monoMinLagMs, handles.monoMinLagMs];
mlr2 = [handles.monoMaxLagMs, handles.monoMaxLagMs];
yline = [0,ylimit];
offset = 0.8;
plot(mlr1 - offset ,yline,'k--');
plot(-mlr1 + offset,yline,'k--');
plot(mlr2 + offset,yline,'k--');
plot(-mlr2 - offset,yline,'k--');

title(sprintf('Crosscorrelogram of ROI %d and %d',roi1,roi2));
xlabel('Time(ms)');
ylabel('Count');
    

function spikeVector = times2vector(spikeTimes, nFrame)
spikeVector = zeros(1,nFrame);
spikeVector(spikeTimes) = 1;

