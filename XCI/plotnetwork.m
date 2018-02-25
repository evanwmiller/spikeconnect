function plotnetwork(fileGroup,xcorrLagMs, monoMinLagMs, monoMaxLagMs)
% PLOTNETWORK Work in progress.
disp('Calculating network ratios, please wait...');
ratioArr = calcratio(fileGroup, xcorrLagMs, monoMinLagMs, monoMaxLagMs);
connectionArr = classify(ratioArr);
plotnetworkgraph(connectionArr, ratioArr, 'Ratio based monosynaptic',fileGroup);


function ratioArr = calcratio(fileGroup, xcorrLagMs, monoMinLagMs, monoMaxLagMs)
load(fileGroup{1},'roiTraces');
nRoi = numel(roiTraces);

spikeCountArr = countspikes(fileGroup);

ratioArr = nan(nRoi);
for roi1 = 1:nRoi
    for roi2 = (roi1+1):nRoi
        [xcorrArr, lagArrMs] = plotxcorr(fileGroup, roi1,roi2,xcorrLagMs,false);
        counts = bucket(xcorrArr, lagArrMs, monoMinLagMs, monoMaxLagMs);
        % When more on forward than back, the roi2 is trigger cell.
        % Negative value in ratioArr indicates reverse arrow.
        if counts.forward >= counts.backward && spikeCountArr(roi1) > 0
            ratioArr(roi1,roi2) = -counts.forward/spikeCountArr(roi2);
        % If more on left than right, then roi1 is triggering.
        elseif counts.backward >= counts.forward && spikeCountArr(roi2) > 0
            ratioArr(roi1,roi2) = counts.backward/spikeCountArr(roi1);  
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


function plotnetworkgraph(directionalArr, ratioArr, plotTitle, fileGroup)
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

nRoi = size(ratioArr, 1);

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
    connectivityfactor(s, t, weights, assignments, ratioArr);
end

% EXPERIMENTAL
% s is triggering cell, t is receiving
function connectivityfactor(s,t ,weights, assignments, ratioArr)
% count edges from each ROI to each type.
edgeCount = zeros(4, numel(assignments));
for i = 1 : numel(weights)
    col = s(i);
    row = getvalueofassignment(assignments{t(i)});
    edgeCount(row, col) = edgeCount(row, col) + 1;
end

% count how many of each cell type there are
typesCount = [0 0 0 0]';
for i = 1 : numel(assignments)
    row = getvalueofassignment(assignments{i});
    typesCount(row) = typesCount(row) + 1;
end

% normalize each row by the number of the receiving cell type
normalizedEdgeCount = zeros(size(edgeCount));
for i = 1 : numel(typesCount) % 4 rows
    numOfReceivingCellType = typesCount(i);
    normalizedEdgeCount(i,:) = edgeCount(i,:) / numOfReceivingCellType;
end

% combine normalized counts based on trigger cell type.
combinedBasedOnCellType = zeros(4,4);
for i = 1 : numel(assignments)
    col = getvalueofassignment(assignments{i});
    combinedBasedOnCellType(:, col) = combinedBasedOnCellType(:, col) + normalizedEdgeCount(:, i);
end

% average by trigger cell type count.
for col = 1 : 4
    combinedBasedOnCellType(:, col) = combinedBasedOnCellType(:, col) ./ typesCount(col);
end

% group ratio arr by trigger and receiving cell type.
% ratioArr (as is) is receiving cell number on y axis and trigger cell
% number on x axis. If the ratio is negative, the connection goes the
% opposite direction.
groupRatioArrByType = cell(16,1);
for row = 1:size(ratioArr,1)
    for col = (row+1):size(ratioArr,2)
        if ratioArr(row,col) > 0
            trigger = getvalueofassignment(assignments{row});
            receiver = getvalueofassignment(assignments{col});
        else
            trigger = getvalueofassignment(assignments{col});
            receiver = getvalueofassignment(assignments{row});
        end
        
        if ~isnan(ratioArr(row,col))
            groupRatioArrByType{(trigger-1)*4+receiver}(end+1) = abs(ratioArr(row,col));
        end
    end
end


disp('Select file for .csv output');
[file,path] = uiputfile('*.csv','Save Results As');
if (file == 0); return; end;
csvPath = [path file];

writearrtocsv(edgeCount, csvPath, getcelltypenames(), {}, 'Number of edges to each type of cell. Column labels are the number of the triggering cell. Row labels are type of receiving cell.'); 
writearrtocsv(typesCount, csvPath, getcelltypenames(), {' '}, 'Number of each type of cell.');
writearrtocsv(normalizedEdgeCount, csvPath, getcelltypenames(), {}, 'Normalized edge count. This is the number of edges divided by the total number of the receiving cell.');
writearrtocsv(combinedBasedOnCellType, csvPath, getcelltypenames(), getcelltypenames(), 'Average normalized edge count by trigger type. Column labels are trigger cell type. Row labels are receiving cell type.')
writearrtocsv(-ratioArr, csvPath, {},{}, 'Ratio data. Column labels are trigger cell and row labels are receiving cell. If the value is negative: it goes the other way.'); 
writearrtocsv(groupRatioArrByType, csvPath, getcelltocellconnections(), {' '}, 'Ratios grouped by trigger cell type and receiving cell type.');

fprintf('Writing to %s successful.', csvPath);

% EXPERIMENTAL
% Ratio based. Takes the sum of trigger ratios of A->B connections, then
% divides by the total number of A->B connections.
function countedgesratiobased(s,t,weights,assignments) 
counts = zeros(4,4);
ratioSum = zeros(4,4);
for i = 1 : numel(weights) 
    row = getvalueofassignment(assignments{t(i)});
    col = getvalueofassignment(assignments{s(i)});
    counts(row,col) = counts(row,col) + 1;
    ratioSum(row, col) = ratioSum(row, col) + weights(i);
end

ratioAverage = ratioSum ./ counts;
ratioAverage(isinf(ratioAverage)) = NaN;

rowHeaders = {'DGC','Inhib','CA1','CA3'};
DGC = counts(:,1);
Inhib = counts(:,2);
CA1 = counts(:,3);
CA3 = counts(:,4);

triggerCount = table(DGC,Inhib,CA1,CA3,'RowNames',rowHeaders);
disp(triggerCount);

DGC = ratioAverage(:,1);
Inhib = ratioAverage(:,2);
CA1 = ratioAverage(:,3);
CA3 = ratioAverage(:,4);

ratioAverage = table(DGC,Inhib,CA1,CA3,'RowNames',rowHeaders);
disp(ratioAverage);

function value = getvalueofassignment(assignment)
switch assignment
    case 'DGC'
        value = 1;
    case 'Inhib'
        value = 2;
    case 'CA1'
        value = 3;
    case 'CA3'
        value = 4;
end

function header = getcelltypenames()
header = {'DGC','Inhib', 'CA1','CA3'};

function header = getcelltocellconnections()
header = {};
celltypes = getcelltypenames();
for trigger = 1:4
    for receiver = 1:4
        header{end+1} = sprintf('%s -> %s', celltypes{trigger}, celltypes{receiver});
    end
end


    

