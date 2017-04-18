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