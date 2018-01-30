function sttctoexcel(baseDir, excelPath, sttcMaxLagMs, includeNonFiring)
%STTCTOEXCEL Exports STTC data for a cover slip directory given a STTC lag
%window.
% Input:
%   baseDir: the parent directory of the data, which should look like
%       \baseDir
%           \Area 1
%               \snap.tiff
%               \movie1.tiff
%               \movie*.tiff
%           \Area *, etc.
%   excelPath: path to save Excel file
%   sttcMaxLagMs: lag window to use to calculate STTC (in ms)
%   includeNonFiring: if true, non firing cells will be outputted as 0.
% Output: Writes file STTC (sttc for each file), composite STTC (sttc for
%   concatenated files), and mean STTC (mean file STTC).

% Copyright 2017, The Miller Lab, UC Berkeley
% Author: Patrick Zhang

if nargin < 4
    includeNonFiring = true;
end

spikeFileStruct = findgroups(baseDir);
groups = sort(fieldnames(spikeFileStruct));
composites = [];
means = [];
for iGroup = 1:numel(groups)
    groupName = groups{iGroup};
    fileNames = spikeFileStruct.(groupName);
    [composite, mean] = writegrouptoexcel(excelPath, ...
            groupName, ...
            fileNames, ...
            sttcMaxLagMs, ...
            includeNonFiring);
    composites = vertcat(composites, composite);
    means = vertcat(means, mean);
end
wt({'Composite Aggregate'}, excelPath, 'Aggregate', 1, 1);
wt(composites, excelPath, 'Aggregate', 2, 1);
wt({'Mean Aggregate'}, excelPath, 'Aggregate', 1, 2);
wt(means, excelPath, 'Aggregate', 2, 2);

if ispc
    RemoveSheet123(excelPath);
end


function [compositeCol, meanCol] = writegrouptoexcel(excelPath, groupName, fileNames, lag, includeNonFiring)
% WRITEGROUPTOEXCEL Calculates the STTC array for a set of movies given by
% fileNames and writes it to a tab specified by groupName in the Excel file
% specified by excelPath. It writes the STTC array for each movie as a
% grid, then as a column underneath it. In addition to the files, it will
% calculates the groupMean, which is outputted.
currCol = 1;
[groupSttcArr, fileSttcArrs] = calcsttcarr(fileNames,lag);
if includeNonFiring
    groupSttcArr(isnan(groupSttcArr)) = 0;
    for i = 1:numel(fileSttcArrs)
        fileSttcArrs{i}(isnan(fileSttcArrs{i})) = 0;
    end
end

for iFile = 1:numel(fileNames)
    filePath = fileNames{iFile};
    
    %label movie
    [~,label,~] = fileparts(filePath);
    wt({label}, excelPath, groupName, 1, currCol);
    
    sttcArr = fileSttcArrs{iFile};
    countArr = ~isnan(sttcArr);
    sttcArrNoNan = sttcArr;
    sttcArrNoNan(isnan(sttcArr)) = 0;
    if iFile == 1
        sttcSum = sttcArrNoNan;
        countSum = countArr;
    else
        sttcSum = sttcSum + sttcArrNoNan;
        countSum = countSum + countArr;
    end
    
    %label ROI row/columns for heatmap
    wt({'ROI'}, excelPath, groupName, 2, currCol);
    wt(1:size(sttcArr,2), excelPath, groupName, 2, currCol+1);
    wt((1:size(sttcArr,2))', excelPath, groupName, 3, currCol);
    
    %write sttcArr excluding diagonal
    for iCol = 1:size(sttcArr,2)
        wt(sttcArr(1:iCol-1,iCol), excelPath, groupName, 3, currCol+iCol);
    end
    
    currRow = 5+size(sttcArr,1);
    %write sttcArr as column
    wt(arr2column(sttcArr), excelPath, groupName, currRow, currCol);
    
    %move over to right
    currCol = currCol + 3 + size(sttcArr,2);
end

wt({[groupName 'composite']}, excelPath, groupName, 1, currCol);
%label ROI row/columns
wt({'ROI'}, excelPath, groupName, 2, currCol);
wt(1:size(groupSttcArr,2), excelPath, groupName, 2, currCol+1);
wt((1:size(groupSttcArr,2))', excelPath, groupName, 3, currCol);

%write composite STTC excluding diagonal
for iCol = 1:size(groupSttcArr,2)
    wt(groupSttcArr(1:iCol-1,iCol), excelPath, groupName, 3, currCol+iCol);
end

currRow = 5+size(groupSttcArr,1);

%write sttc as column
compositeCol = arr2column(groupSttcArr);
wt(compositeCol, excelPath, groupName, currRow, currCol);

%move over to right
currCol = currCol + 3 + size(sttcArr,2);
sttcMean = sttcSum ./ countSum;
sttcMean(isinf(sttcMean)) = NaN;

wt({'Mean'}, excelPath, groupName, 1, currCol);
%label ROI row/columns
wt({'ROI'}, excelPath, groupName, 2, currCol);
wt(1:size(sttcMean,2), excelPath, groupName, 2, currCol+1);
wt((1:size(sttcMean,2))', excelPath, groupName, 3, currCol);

%write sttcMean excluding diagonal
for iCol = 1:size(sttcMean,2)
    wt(sttcMean(1:iCol-1,iCol), excelPath, groupName, 3, currCol+iCol);
end

currRow = 5+size(sttcMean,1);

%write sttcArr as column
meanCol = arr2column(sttcMean);
wt(meanCol, excelPath, groupName, currRow, currCol);


function wt(content,file,sheet,row, col)
% WT Shortcut for WRITETABLE. Input row and col in numbers.
range = nn2an(row,col);
writetable(table(content), file, 'Sheet',sheet,'Range',range,'WriteVariableNames', false);


function column = arr2column(arr)
% ARR2COLUMN Converts a nxn matrix into a n*(n+1)/2 x 1 column vector using
% the upper triangular portion of the array excluding the diagonal. Removes
% any NaN.
column = [];
for col = 1:size(arr,2)
    column = vertcat(column,arr(1:col-1,col));
end
column(isnan(column)) = [];


function cr = nn2an(row, col)
% convert number, number format to alpha, number format
t = [floor((col - 1)/26) + 64 rem(col - 1, 26) + 65];
if(t(1)<65), t(1) = []; end
cr = [char(t) num2str(row)];

        
    

