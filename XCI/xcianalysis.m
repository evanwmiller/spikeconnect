function results = xcianalysis(spikeFileStruct, params)
%XCIANALYSIS Summary of this function goes here
%   
%   -----------------------------------------------------------------------
%   Inputs:
%   1. spikeFileStruct: path to spike-*.m files grouped by directory. See
%   FINDGROUPS.
%   
%   The following fields must be present in params.
%   2. monoMinLagMs: minimum delay for a monosynaptic connection in ms.
%   3. monoMaxLagMs: maximum delay for a monosynaptic connection in ms.
%   4. minFreq: minimum frequency for a cell to be included in analysis.
%   All cells that have a lower frequency will be treated as if they were
%   non firing.
%   5. xciThreshold: threshold xci value to be considered a connection.
%   6. filter: struct with cell type as field name (dgc, inhib, ca1, ca3)
%   and either 'include', 'require', or 'exclude'.
%   -----------------------------------------------------------------------
%   Output struct fields:
%   1. For each fieldname in spikeFileStruct, there's a corresponding field
%   in results for the xci calculations for that island, consisting of the
%   folloi
%   2. Aggregate:
%   -----------------------------------------------------------------------

spikeFileDirs = fieldnames(spikeFileStruct);

sumNormalizedEdgeCountByType = zeros(5,5);
typeCount = [0 0 0 0 0]';
results.islandResults = {};
results.aggregate.xci = [];
for iDir = 1:numel(spikeFileDirs)
    fileGroup = spikeFileStruct.(spikeFileDirs{iDir});
    islandResults = islandanalysis(fileGroup, params);
    islandResults.name = spikeFileDirs{iDir};
    
    % only include in aggregate analysis if it meets filter criteria
    if matchesFilter(islandResults, params.filter)
        typeCount = typeCount + islandResults.typeCount;
        sumNormalizedEdgeCountByType = sumNormalizedEdgeCountByType + islandResults.sumNormalizedEdgeCountByType;
        results.islandResults{end+1} = islandResults;

        % extract abs value of non-nan xci values
        xciValues = reshape(islandResults.xciArr, 1, []);
        xciValues = abs(xciValues(~isnan(xciValues)));
        results.aggregate.xci = [results.aggregate.xci xciValues];
    end
end

% average by trigger cell type count.
connectivityFactor = zeros(5, 5);
for col = 1 : 5
    connectivityFactor(:, col) = sumNormalizedEdgeCountByType(:, col) ./ typeCount(col);
end

results.aggregate.typeCount = typeCount;
results.aggregate.connectivityFactor = connectivityFactor;
results.params = params;


function match = matchesFilter(islandResults, filter)
typeCount = islandResults.typeCount;
filterArr = nan(1, 5);

names = fieldnames(filter);
for i = 1:numel(names)
    if strcmp(filter.(names{i}), 'require')
        filterArr(getvalueofassignment(names{i})) = 1;
    elseif strcmp(filter.(names{i}), 'exclude')
        filterArr(getvalueofassignment(names{i})) = -1;
    end
end

match = all(typeCount(filterArr == 1) > 0) ...
        && all(typeCount(filterArr == -1) == 0);

    

function islandResults = islandanalysis(fileGroup, params)
dir = fileparts(fileGroup{1});
roiFile = currentdir(dir, '^roi-.*.mat$');
load([dir filesep roiFile{1}],'assignments');
if ~exist('assignments', 'var')
    error('Assignments are missing for %s', dir);
end

xciArr = calcxciarr(fileGroup, params);

% count edges from each ROI to each type.
% there is an edge if |xci| >= xciThreshold
edgeCount = zeros(5, numel(assignments));
for row = 1 : size(xciArr, 1)
    for col = row+1 : size(xciArr, 2)
        if abs(xciArr(row, col)) >= params.xciThreshold
            if xciArr(row,col) > 0
                triggerRoi = row;
                receiverType = getvalueofassignment(assignments{col});
            else
                triggerRoi = col;
                receiverType = getvalueofassignment(assignments{row});
            end
            
            edgeCount(receiverType, triggerRoi) = ...
                edgeCount(receiverType, triggerRoi) + 1;
        end
    end
end

% count how many of each cell type there are
typeCount = [0 0 0 0 0]';
for i = 1 : numel(assignments)
    row = getvalueofassignment(assignments{i});
    typeCount(row) = typeCount(row) + 1;
end

% normalize each edgeCount by the number of the receiving cell type
normalizedEdgeCount = zeros(size(edgeCount));
for i = 1 : numel(typeCount) % 5 rows
    numOfReceivingCellType = typeCount(i);
    normalizedEdgeCount(i,:) = edgeCount(i,:) / numOfReceivingCellType;
end

% combine normalized counts based on trigger cell type
sumNormalizedEdgeCountByType = zeros(5, 5);
for i = 1 : numel(assignments)
    col = getvalueofassignment(assignments{i});
    sumNormalizedEdgeCountByType(:, col) ...
        = sumNormalizedEdgeCountByType(:, col) + normalizedEdgeCount(:, i);
end

% average by trigger cell type count.
connectivityFactor = zeros(5, 5);
for col = 1 : 5
    connectivityFactor(:, col) = sumNormalizedEdgeCountByType(:, col) ./ typeCount(col);
end

% group  xciArr by trigger and receiving cell type.
% xciArr (as is) is (trigger, receiving). If negative, the connection goes 
% the opposite direction.
xciArrGroupedByType = cell(25, 1);
for row = 1:size(xciArr,1)
    for col = (row+1):size(xciArr,2)
        if xciArr(row,col) > 0
            trigger = getvalueofassignment(assignments{row});
            receiver = getvalueofassignment(assignments{col});
        else
            trigger = getvalueofassignment(assignments{col});
            receiver = getvalueofassignment(assignments{row});
        end
        
        if ~isnan(xciArr(row,col))
            xciArrGroupedByType{(trigger-1)*5+receiver}(end+1) = abs(xciArr(row,col));
        end
    end
end

islandResults.xciArr = xciArr;
islandResults.edgeCount = edgeCount;
islandResults.typeCount = typeCount;
islandResults.normalizedEdgeCount = normalizedEdgeCount;
islandResults.sumNormalizedEdgeCountByType = sumNormalizedEdgeCountByType;
islandResults.connectivityFactor = connectivityFactor;
islandResults.xciArrGroupedByType = xciArrGroupedByType;


function value = getvalueofassignment(assignment)
switch lower(assignment)
    case 'dgc'
        value = 1;
    case 'inhib'
        value = 2;
    case 'ca1'
        value = 3;
    case 'ca3'
        value = 4;
    otherwise
        value = 5;
end