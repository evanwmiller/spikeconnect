function plotspikes(spikeFile, roi1, roi2)
% PLOTSPIKES Plots the spike times of roi1 and roi2 from spikeFile, and
% plots the cross correlation of roi1 and roi2.
load(spikeFile,'spikeDataArray','frameRate');
nFrame = numel(spikeDataArray{1}.dffs);

figure('units','inches');
pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) pos(3) round(pos(4)/1.5)])

% Plot roi1 spikes
subplot(2,1,1);
plotroispikes(spikeDataArray,roi1,frameRate, nFrame);

% Plot roi2 spikes
subplot(2,1,2);
plotroispikes(spikeDataArray,roi2,frameRate, nFrame);


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

