function results = xcianalysis(spikeFileStruct, params)
%XCIANALYSIS Calculates XCI for each of the islands in spikeFileStruct and
%calculated connectivity factors, which is a value associated with the
%observed likelihood of a connection between cell types. See XCI_GUI.
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
%   1. islandResults: cell array of result structs for each island in
%   spikeFileStruct. Each struct in islandResults has the following fields:
%       a. name: name of the island.
%       b. assignments: assignment{roi} is the cell type of the roi.
%       c. xciArr: xciArr(a,b) is the xci between roi A and B. If xciArr is
%       nan, then the cell did not meet the minimum frequency requirement.
%       If the value is positive, then a->b is assumed. Otherwise, b->a is
%       assumed.
%       d. edgeCount: edgeCount(cell type number, roi) is the number of
%       edges (connections with xci over xciThreshold) from roi to that
%       cell type.
%       e. typeCount: typeCount(cell type number) is the number of cells of
%       that type.
%       f. normalizedEdgeCount: edgeCount, but with the counts normalized
%       by the number of the receiving cell.
%       g. sumNormalizedEdgeCountByType: group roi's with the same cell
%       type in normalizedEdgeCount.
%       h. connectivityFactor: average normalized edge count by type.
%       i. xciArrGroupedByType: xciArr, but organized into cell type ->
%       cell type. 5x5 cell array, where xciArrGroupedByType(x,y) is the
%       xci's for x->y.
%   2. Aggregate: combined statistics about all islands that meet the
%   filter criteria. Has the following fields:
%       a. params: input parameters
%       b. typeCount: combined type count
%       c. connectivityFactor: combined connectivity factor
%   -----------------------------------------------------------------------

disp('XCI analysis in progress...');
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
disp('XCI analysis completed.');


function match = matchesFilter(islandResults, filter)
% MATCHESFILTER Returns whether or not the island has the required cell
% types. See XCIANALYSIS for what fields filter should have.
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
% ISLANDANALYSIS Returns xci results for the island represented by
% fileGroup. See XCIANALYSIS.
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
    if numOfReceivingCellType ~= 0
        normalizedEdgeCount(i,:) = edgeCount(i,:) / numOfReceivingCellType;
    end
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
xciArrGroupedByType = cell(5, 5);
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
            xciArrGroupedByType{trigger, receiver}(end+1) = abs(xciArr(row,col));
        end
    end
end

islandResults.assignments = assignments;
islandResults.xciArr = xciArr;
islandResults.edgeCount = edgeCount;
islandResults.typeCount = typeCount;
islandResults.normalizedEdgeCount = normalizedEdgeCount;
islandResults.sumNormalizedEdgeCountByType = sumNormalizedEdgeCountByType;
islandResults.connectivityFactor = connectivityFactor;
islandResults.xciArrGroupedByType = xciArrGroupedByType;