function plotnetwork(spikeFile,xcorrLagMs, monoMinLagMs, monoMaxLagMs)
% PLOTNETWORK Plots a network graph of the ROIs where the direction and
% weight of the line indicates the delay between spike times.

% Steps:
% 1) For each pair of ROIs, find the delay (within the xcorr window) for 
%    which it has the maximum crosscorrelation value.
% 2) Then, based on the delay, it classifies it as synchronous, 
%     monosynaptic, then disynaptic depending on whether or not 
%     it?s in the specified monosynaptic lag range.
% 3) Then, plots a network graph (in no particular order) or the nodes. 
%    The weight on the line indicates the delay.

load(spikeFile,'spikeDataArray','frameRate');

xcorrMaxLag = ms2frame(xcorrLagMs, frameRate);
[delayArr, xcorrArr] = calcdelay(spikeDataArray,xcorrMaxLag);
monoMinLag = ms2frame(monoMinLagMs, frameRate);
monoMaxLag = ms2frame(monoMaxLagMs, frameRate);
[mono, di, sync, nRoi] = classifylag(delayArr, monoMinLag, monoMaxLag);
plotnetworkgraph(mono,nRoi, 'Monosynaptic');
plotnetworkgraph(di, nRoi, 'Disynaptic');
plotnetworkgraph(sync, nRoi, 'Synchronous');


function [delayArr, xcorrArr] = calcdelay(spikeDataArray,xcorrMaxLag)
nFrame = numel(spikeDataArray{1}.dffs);
nRoi = length(spikeDataArray);
xcorrArr = cell(nRoi, nRoi);
delayArr = zeros(nRoi, nRoi);

for iRoi = 1:nRoi
    r1 = times2vector(spikeDataArray{iRoi}.rasterSpikeTimes, nFrame);
    for jRoi = iRoi:nRoi
        r2 = times2vector(spikeDataArray{jRoi}.rasterSpikeTimes, nFrame);
        [xcorrArr{iRoi,jRoi},lags] = xcorr(r1, r2 , xcorrMaxLag);
        [~, maxIndex] = max(xcorrArr{iRoi,jRoi});
        delayArr(iRoi,jRoi) = lags(maxIndex);
    end
end


function [mono, di, sync, nRoi] = classifylag(delayArr, minDelay, maxDelay)
nRoi = size(delayArr,1);
mono = cell(0);
di = cell(0);
sync = cell(0);
for iRoi = 1:nRoi
    for jRoi = iRoi+1:nRoi
        absDelay = abs(delayArr(iRoi,jRoi));
        if absDelay < minDelay
            sync{end+1} = directional(iRoi, jRoi, delayArr(iRoi, jRoi));
        elseif absDelay > maxDelay
            di{end+1} = directional(iRoi, jRoi, delayArr(iRoi, jRoi));
        else
            mono{end+1} = directional(iRoi, jRoi, delayArr(iRoi, jRoi));
        end
    end
end

function directionalLine = directional(x,y,delay)
if delay > 0
    directionalLine = [x,y,delay];
else
    directionalLine = [y,x,-delay];
end


function plotnetworkgraph(directionalArr, nRoi, plotTitle)
if numel(directionalArr) == 0
    return;
end

s = zeros(size(directionalArr));
t = zeros(size(directionalArr));
weights = zeros(size(directionalArr));
for i = 1:numel(weights)
    s(i) = directionalArr{i}(1);
    t(i) = directionalArr{i}(2);
    weights(i) = directionalArr{i}(3);
end

figure;
G = digraph(s,t, weights, nRoi);
p = plot(G,'Layout','force','EdgeLabel',G.Edges.Weight);
p.MarkerSize = 10;
p.EdgeColor = 'r';
title(plotTitle);


function spikeVector = times2vector(spikeTimes, nFrame)
spikeVector = zeros(1,nFrame);
spikeVector(spikeTimes) = 1;


function frames = ms2frame(timeMs,frameRate)
frames = round(timeMs/1000*frameRate,0);
