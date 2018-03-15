function results = groupcausality(spikeFileStruct, params)

%   -----------------------------------------------------------------------

disp('CM analysis in progress...');
spikeFileDirs = fieldnames(spikeFileStruct);

sumNormalizedEdgeCountByType = zeros(5,5);
typeCount = [0 0 0 0 0]';
results.islandResults = {};
results.aggregate.cm = [];
for iDir = 1:numel(spikeFileDirs)
    fileGroup = spikeFileStruct.(spikeFileDirs{iDir});
    islandResults = islandanalysis(fileGroup, params);
    islandResults.name = spikeFileDirs{iDir};
    
    % only include in aggregate analysis if it meets filter criteria
    if matchesFilter(islandResults, params.filter)
        typeCount = typeCount + islandResults.typeCount;
        sumNormalizedEdgeCountByType = sumNormalizedEdgeCountByType + islandResults.sumNormalizedEdgeCountByType;
        results.islandResults{end+1} = islandResults;

        % extract abs value of non-nan cm values
        cmValues = reshape(islandResults.cmArr, 1, []);
        cmValues = abs(cmValues(~isnan(cmValues)));
        results.aggregate.cm = [results.aggregate.cm cmValues];
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
disp('CM analysis completed.');


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

cmArr = causalityanalysis(fileGroup, params); 

% count edges from each ROI to each type.
% there is an edge if |xci| >= xciThreshold
edgeCount = zeros(5, numel(assignments));
for row = 1 : size(cmArr, 1)
    for col = row+1 : size(cmArr, 2)
        if abs(cmArr(row, col)) >= params.alphaThreshold
            if cmArr(row,col) > 0
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
cmArrGroupedByType = cell(5, 5);
for row = 1:size(cmArr,1)
    for col = (row+1):size(cmArr,2)
        if cmArr(row,col) > 0
            trigger = getvalueofassignment(assignments{row});
            receiver = getvalueofassignment(assignments{col});
        else
            trigger = getvalueofassignment(assignments{col});
            receiver = getvalueofassignment(assignments{row});
        end
        
        if ~isnan(cmArr(row,col))
            cmArrGroupedByType{trigger, receiver}(end+1) = abs(cmArr(row,col));
        end
    end
end

islandResults.assignments = assignments;
islandResults.cmArr = cmArr;
islandResults.edgeCount = edgeCount;
islandResults.typeCount = typeCount;
islandResults.normalizedEdgeCount = normalizedEdgeCount;
islandResults.sumNormalizedEdgeCountByType = sumNormalizedEdgeCountByType;
islandResults.connectivityFactor = connectivityFactor;
islandResults.cmArrGroupedByType = cmArrGroupedByType;


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