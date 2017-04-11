function  auctoexcel(filePaths, excelPath, aucValues)
%AUCTOEXCEL Exports area under curve values to the Excel spreasheet
%specified by the user.
spikeFileStruct = findgroups(filePaths);
groups = sort(fieldnames(spikeFileStruct));
warning off;
aggregateMean = [];
for iGroup = 1:numel(groups)
    groupName = groups{iGroup};
    indices = spikeFileStruct.(groupName);
    groupMean = writeGroup(excelPath, groupName, aucValues, filePaths, indices);
    aggregateMean = cellcat(aggregateMean,groupMean);
end
writeAggregate(excelPath, aggregateMean);
if ispc
    RemoveSheet123(excelPath);
end
warning on;

function groupMean = writeGroup(excelPath, groupName, aucValues, filePaths, indices)
%WRITEGROUP Writes a group to the Excel sheet named groupName.
offset = 1;
groupSum = [];
for i = 1:numel(indices)
    index = indices(i);
    filePath = filePaths{index};
    fileAuc = aucValues{index};
    nRoi = numel(fileAuc);
    wt({filePath},excelPath,groupName,1,offset);
    wt({'ROI'},excelPath,groupName,2,offset);
    wt({'Multi-spike Avg (ms)'}, excelPath, groupName,2,offset+1);
    wt({'Multi-spike Sum (ms)'}, excelPath, groupName, 2, offset + 2);
    wt({'Whole Trace (ms)'}, excelPath, groupName,2,offset+3);
    wt((1:nRoi)', excelPath, groupName, 3,offset);
    wt(fileAuc', excelPath, groupName, 3, offset+1);
    groupSum = cellsum(groupSum,fileAuc');
    offset = offset + 6;
end
groupMean = celldivide(groupSum,numel(indices));
wt({'Group Means'},excelPath,groupName,1,offset);
wt({'ROI'},excelPath,groupName,2,offset);
wt({'Multi-spike Avg (ms)'}, excelPath, groupName,2,offset+1);
wt({'Multi-spike Sum (ms)'}, excelPath, groupName, 2, offset + 2);
wt({'Whole Trace (ms)'}, excelPath, groupName,2,offset+3);
wt((1:nRoi)', excelPath, groupName, 3,offset);
wt(groupMean, excelPath, groupName, 3, offset+1);

function writeAggregate(excelPath, aggregateMean)
% WRITEAGGREGATE Writes aggregateMean to a sheet named 'Aggregate'.
wt({'Multi-spike Avg (ms)'}, excelPath, 'Aggregate',1,1);
wt({'Multi-spike Sum (ms)'}, excelPath, 'Aggregate', 1,2);
wt({'Whole Trace (ms)'}, excelPath, 'Aggregate',1,3);
wt(aggregateMean, excelPath, 'Aggregate',2,1);

function fileStruct = findgroups(fileArr)
% FINDGROUPS Groups the files in fileArr by the parent directory. Returns
% as a structure where the field names are the parent directory and each
% field consists of the corresponding indices.

fileStruct = struct;
% Group spike files by their parent directory
for iFile = 1:numel(fileArr)
    [dir,~,~] = fileparts(fileArr{iFile});
    dirSplit = strsplit(dir,filesep);
    folderName = dirSplit{end};
    folderName = strrep(folderName,' ','_');
    if isfield(fileStruct,folderName)
        currentGroup = fileStruct.(folderName);
        currentGroup(end+1) = iFile;
        fileStruct.(folderName) = currentGroup;
    else
        fileStruct.(folderName) = iFile;
    end
end

function sum = cellsum(arr1, arr2)
if numel(arr1) == 0
    sum = arr2;
else
    sum = cell(size(arr1));
    for i = 1:numel(arr1)
        sum{i} = arr1{i}+arr2{i};
    end
end

function cat = cellcat(arr1, arr2)
if numel(arr1) == 0
    cat = arr2;
else
    cat = vertcat(arr1,arr2);
end

function div = celldivide(arr,d)
div = cell(size(arr));
for i = 1:numel(arr)
    div{i} = arr{i} / d;
end

function wt(content,file,sheet,row, col)
% WT Shortcut for WRITETABLE. Input row and col in numbers.
range = nn2an(row,col);
writetable(table(content), file, 'Sheet',sheet,'Range',range,'WriteVariableNames', false);


function cr = nn2an(row, col)
% convert number, number format to alpha, number format
t = [floor((col - 1)/26) + 64 rem(col - 1, 26) + 65];
if(t(1)<65), t(1) = []; end
cr = [char(t) num2str(row)];

