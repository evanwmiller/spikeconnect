function plotnetwork(fileGroup,xcorrLagMs, monoMinLagMs, monoMaxLagMs)
% PLOTNETWORK Work in progress.
ratioArr = calcratio(fileGroup, xcorrLagMs, monoMinLagMs, monoMaxLagMs);
connectionArr = classify(ratioArr);
plotnetworkgraph(connectionArr, size(ratioArr,1), 'Ratio based monosynaptic');
save('ratio.mat','ratioArr');


function ratioArr = calcratio(fileGroup, xcorrLagMs, monoMinLagMs, monoMaxLagMs)
load(fileGroup{1},'roiTraces');
nRoi = numel(roiTraces);

spikeCountArr = countspikes(fileGroup);

ratioArr = nan(nRoi);
for roi1 = 1:nRoi
    for roi2 = (roi1+1):nRoi
        [xcorrArr, lagArrMs] = plotxcorr(fileGroup, roi1,roi2,xcorrLagMs,false);
        counts = bucket(xcorrArr, lagArrMs, monoMinLagMs, monoMaxLagMs);
        if counts.forward >= counts.backward && spikeCountArr(roi1) > 0
            ratioArr(roi1,roi2) = counts.forward/spikeCountArr(roi1);
        elseif counts.backward >= counts.forward && spikeCountArr(roi2) > 0
            ratioArr(roi1,roi2) = counts.backward/spikeCountArr(roi2);  
        end
    end
end
dir = fileparts(fileGroup{1});
save([dir filesep 'ratio.mat'], 'ratioArr');

function counts = bucket(xcorrArr, lagArrMs, monoMinLagMs, monoMaxLagMs)
counts.backward = sum(xcorrArr(find(lagArrMs >= -monoMaxLagMs & lagArrMs <= -monoMinLagMs)));
counts.forward = sum(xcorrArr(find(lagArrMs >= monoMinLagMs & lagArrMs <= monoMaxLagMs)));
counts.synch = sum(xcorrArr(find(lagArrMs > -monoMinLagMs & lagArrMs < monoMinLagMs)));

function connectionArr = classify(ratioArr)
connectionArr = {};
ratioThreshold = 0.25;
nRoi = size(ratioArr,1);
for roi1 = 1:nRoi
    for roi2 = (roi1+1):nRoi
        ratio = ratioArr(roi1,roi2);
        if ratio >= ratioThreshold
            connectionArr{end+1} = [roi1,roi2, ratio];
        elseif ratio <= -ratioThreshold
            connectionArr{end+1} = [roi2, roi1, -ratio];
        end
    end
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
