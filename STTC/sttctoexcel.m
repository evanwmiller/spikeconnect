function sttctoexcel(baseDir, excelPath, sttcMaxLagMs)
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
% Output: Writes 

% Copyright 2017, The Miller Lab, UC Berkeley
% Author: Patrick Zhang

spikeFileStruct = findgroups(baseDir);
groups = sort(fieldnames(spikeFileStruct));
means = [];
for iGroup = 1:numel(groups)
    groupName = groups{iGroup};
    fileNames = spikeFileStruct.(groupName);
    groupMean = writegrouptoexcel(excelPath, groupName, fileNames, sttcMaxLagMs);
    means = vertcat(means,groupMean);
end
writemeanstoexcel(excelPath, means);
if ispc
    RemoveSheet123(excelPath);
end


function fileStruct = findgroups(baseDir)
% FINDGROUPS Uses recursive search starting from baseDir to find 
% spikes-*.mat files and then groups them by the parent directory so that 
% movies of the same area will be in the same field of fileStruct. The 
% field names in fileStruct are the parent directories, with spaces
% replaced by underscores.

fileStruct = struct;
% Find all spike files in this directory.
fileArr = recursdir(baseDir , '^spikes-.*.mat$');

% Group spike files by their parent directory
for iFile = 1:numel(fileArr)
    [dir,~,~] = fileparts(fileArr{iFile});
    dirSplit = strsplit(dir,filesep);
    folderName = dirSplit{end};
    folderName = strrep(folderName,' ','_');
    if isfield(fileStruct,folderName)
        currentGroup = fileStruct.(folderName);
        currentGroup{end+1} = fileArr{iFile};
        fileStruct.(folderName) = currentGroup;
    else
        fileStruct.(folderName) = {fileArr{iFile}};
    end
end


function sttcMeanCol = writegrouptoexcel(excelPath, groupName, fileNames, lag)
% WRITEGROUPTOEXCEL Calculates the STTC array for a set of movies given by
% fileNames and writes it to a tab specified by groupName in the Excel file
% specified by excelPath. It writes the STTC array for each movie as a
% grid, then as a column underneath it. In addition to the files, it will
% calculates the groupMean, which is outputted.
currCol = 1;

for iFile = 1:numel(fileNames)
    filePath = fileNames{iFile};
    %label movie
    [~,label,~] = fileparts(filePath);
    wt({label}, excelPath, groupName, 1, currCol);
    
    sttcArr = calcsttcarr(filePath, lag);
    if iFile == 1
        sttcSum = sttcArr;
    else
        sttcSum = sttcSum + sttcArr;
    end
    
    %label ROI row/columns for heatmap
    wt({'ROI'}, excelPath, groupName, 2, currCol);
    wt(1:size(sttcArr,2), excelPath, groupName, 2, currCol+1);
    wt((1:size(sttcArr,2))', excelPath, groupName, 3, currCol);
    
    %write sttcArr
    for iCol = 1:size(sttcArr,2)
        wt(sttcArr(1:iCol,iCol), excelPath, groupName, 3, currCol+iCol);
    end
    
    currRow = 5+size(sttcArr,1);
    %write sttcArr as column
    wt(arr2column(sttcArr), excelPath, groupName, currRow, currCol);
    
    %move over to right
    currCol = currCol + 3 + size(sttcArr,2);
end

%write mean if more than one movie
if numel(fileNames) > 1
    sttcMean = sttcSum / numel(fileNames);
    wt({'Mean'}, excelPath, groupName, 1, currCol);
    %label ROI row/columns for heatmap
    wt({'ROI'}, excelPath, groupName, 2, currCol);
    wt(1:size(sttcMean,2), excelPath, groupName, 2, currCol+1);
    wt((1:size(sttcMean,2))', excelPath, groupName, 3, currCol);
    
    %write sttcMean
    for iCol = 1:size(sttcMean,2)
        wt(sttcMean(1:iCol,iCol), excelPath, groupName, 3, currCol+iCol);
    end
    
    currRow = 5+size(sttcMean,1);
    %write sttcArr as column
    sttcMeanCol = arr2column(sttcMean);
    wt(sttcMeanCol, excelPath, groupName, currRow, currCol);
end


function writemeanstoexcel(excelPath, means)
% WRITEMEANSTOEXCEL Given an array of means, writes it as a column in a new
% Excel tab in the file specified by excelPath. 
wt(means, excelPath,'Aggregate',1,1);


function wt(content,file,sheet,row, col)
% WT Shortcut for WRITETABLE. Input row and col in numbers.
range = nn2an(row,col);
writetable(table(content), file, 'Sheet',sheet,'Range',range,'WriteVariableNames', false);


function column = arr2column(arr)
% ARR2COLUMN Converts a nxn matrix into a n*(n+1)/2 x 1 column vector using
% the upper triangular portion of the array. 
column = [];
for col = 1:size(arr,2)
    column = vertcat(column,arr(1:col,col));
end


function cr = nn2an(row, col)
% convert number, number format to alpha, number format
t = [floor((col - 1)/26) + 64 rem(col - 1, 26) + 65];
if(t(1)<65), t(1) = []; end
cr = [char(t) num2str(row)];

        
    

