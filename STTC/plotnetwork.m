function plotnetwork(fileGroup,xcorrLagMs, monoMinLagMs, monoMaxLagMs)
% PLOTNETWORK Work in progress.
ratioArr = calcratio(fileGroup, xcorrLagMs, monoMinLagMs, monoMaxLagMs);
connectionArr = classify(ratioArr);
plotnetworkgraph(connectionArr, size(ratioArr,1), 'Ratio based monosynaptic',fileGroup);
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


function plotnetworkgraph(directionalArr, nRoi, plotTitle, fileGroup)
if numel(directionalArr) == 0
    disp('There were 0 edges for this dataset.');
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

% Color each node according to the assignment, if it exists.
dir = fileparts(fileGroup{1});
roiFile = currentdir(dir, '^roi-.*.mat$');

if ~isempty(roiFile)
    % Throws warning if assignments haven't been made yet.
    load([dir filesep roiFile{1}],'assignments');
end

if exist('assignments','var')
    for i = 1:numel(assignments)
        switch assignments{i}
            case 'DGC'
                highlight(p,i,'NodeColor','g');
            case 'Inhib'
                highlight(p,i,'NodeColor','b');
            case 'CA1'
                highlight(p,i,'NodeColor','c');
            case 'CA3'
                highlight(p,i,'NodeColor','m');
        end
    end
    disp('Legend for node colors:');
    disp('Green - DGC, Blue - Inhib, Cyan - CA1, Magenta - CA3');
end
    

