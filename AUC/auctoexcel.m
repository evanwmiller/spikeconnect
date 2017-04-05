function  auctoexcel(filePaths, excelPath, aucValues)
%AUCTOEXCEL Exports area under curve values to the Excel spreasheet
%specified by the user.
spikeFileStruct = findgroups(filePaths);
groups = sort(fieldnames(spikeFileStruct));
for iGroup = 1:numel(groups)
    groupName = groups{iGroup};
    indices = spikeFileStruct.(groupName);
    writeGroup(excelPath, groupName, aucValues, filePaths, indices);
end

if ispc
    RemoveSheet123(excelPath);
end

function writeGroup(excelPath, groupName, aucValues, filePaths, indices)
%WRITEGROUP Writes a group to the Excel sheet named groupName.
offset = 1;
for i = 1:numel(indices)
    index = indices(i);
    filePath = filePaths{index};
    fileAuc = aucValues{index};
    nRoi = numel(fileAuc);
    wt({filePath},excelPath,groupName,1,offset);
    wt({'ROI'},excelPath,groupName,2,offset);
    wt({'Multi-spike (ms)'}, excelPath, groupName,2,offset+1);
    wt({'Whole Trace (ms)'}, excelPath, groupName,2,offset+2);
    wt((1:nRoi)', excelPath, groupName, 3,offset);
    wt(fileAuc', excelPath, groupName, 3, offset+1);
    offset = offset + 5;
end

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

function wt(content,file,sheet,row, col)
% WT Shortcut for WRITETABLE. Input row and col in numbers.
range = nn2an(row,col);
writetable(table(content), file, 'Sheet',sheet,'Range',range,'WriteVariableNames', false);


function cr = nn2an(row, col)
% convert number, number format to alpha, number format
t = [floor((col - 1)/26) + 64 rem(col - 1, 26) + 65];
if(t(1)<65), t(1) = []; end
cr = [char(t) num2str(row)];

