function freqtoexcel(ifreqFilePaths, excelPath)
% FREQTOEXCEL Outputs ifreq-* files to specified Excel path and aggregates
% data for the same area/ROIs.

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Patrick Zhang
ifreqFileStruct = findgroupsfromfiles(ifreqFilePaths);
groups = sort(fieldnames(ifreqFileStruct));
ifreqArr = [];
isiArr = [];
avgFreqArr = [];
for iGroup = 1:numel(groups)
    groupName = groups{iGroup};
    [ifreq, isi, avgFreq] = grouptoexcel(groupName, ifreqFileStruct.(groupName), excelPath);
    ifreqArr = horzcat(ifreqArr,ifreq);
    isiArr = horzcat(isiArr,isi);
    avgFreqArr = horzcat(avgFreqArr, avgFreq);
end

sheet = 'Overall';
wt({'Overall Aggregate'}, excelPath, sheet, 1,1);
wt({'Inst. Freq. (Hz)'}, excelPath, sheet, 2, 1);
wt({'Interspike Interval (ms)'}, excelPath, sheet, 2, 2);
wt({'Avg. Freq. (Hz)'}, excelPath, sheet, 2, 3);
wt(ifreqArr', excelPath,sheet,3, 1);
wt(isiArr', excelPath, sheet, 3, 2);
wt(avgFreqArr', excelPath, sheet, 3, 3);
if ispc
    RemoveSheet123(excelPath);
end

function [ifreqArr, isiArr, avgFreq] = grouptoexcel(groupName, ifreqFiles, excelPath)
% outputs a group (ifreqFiles in the same parent directory) to a sheet in
% excelPath with name groupName. This function returns a list of all
% instantaneous frequencies, interspike intervals, and average frequencies
% found in this group.
ifreqCell = {};
isiCell = {};
freqSum = [];
startColumn = 1;
for iFile = 1:numel(ifreqFiles)
    file = ifreqFiles{iFile};
    [ifreq, isi, freq, offset] = freqfiletoexcel(groupName, file, excelPath, startColumn);
    ifreqCell = combinecell(ifreqCell,ifreq);
    isiCell = combinecell(isiCell,isi);
    freqSum = addcell(freqSum, freq);
    startColumn = startColumn + offset + 3;
end
%aggregate lists together for output
ifreqArr = mergecell(ifreqCell);
isiArr = mergecell(isiCell);
avgFreq = divcell(freqSum, numel(ifreqFiles));

offset = 0;
sheet = groupName;
wt({'Group Aggregate'},excelPath,sheet,1,startColumn + offset);
%write freqs for group
nRoi = numel(ifreqCell);
wt({'Frequency (Hz)'},excelPath,sheet,2,startColumn+offset);
wt({'ROI'},excelPath,sheet,3,startColumn+offset);
wt((1:nRoi)',excelPath,sheet,4,startColumn+offset);
offset = offset+1;
wt({'Freq (Hz)'}, excelPath, sheet, 3, startColumn+offset);
wt(avgFreq',excelPath,sheet,4,startColumn+offset);
offset = offset+2;

%write ifreqs for group
wt({'Inst. Freq. (Hz)'},excelPath,sheet,2,startColumn+offset);
for i = 1:numel(ifreqCell)
    roiFreq = ifreqCell{i};
    label = sprintf('ROI %d',i);
    wt({label},excelPath,sheet,3,startColumn+offset);
    wt(roiFreq',excelPath,sheet,4,startColumn+offset);
    offset = offset+1;
end

%write isi for group
wt({'Interspike Intervals (ms)'},excelPath,sheet,2,startColumn+offset);
for i = 1:numel(ifreqCell)
    roiIsi = isiCell{i};
    label = sprintf('ROI %d',i);
    wt({label},excelPath,sheet,3,startColumn+offset);
    wt(roiIsi',excelPath,sheet,4,startColumn+offset);
    offset = offset+1;
end


function [ifreqs, isiMs, freqs, offset] = freqfiletoexcel(groupName, file, excelPath, startColumn)
% outputs a individual ispike file to a sheet groupName in excelPath given
% a starting column to output to. Returns the cell array of instantaneous
% frequencies, interspike intervals, and frequencies for this movie. offset
% is the number of columns taken up by this particular movie.
f = load(file);
%CODE FOR COMPATABILITY. Converts isi to frequency and patches file.
freqs = f.freqs;
if ~isfield(f,'isiMs')
    ifreqs = patchisitoifreq(f.ifreqs);
    isiMs = f.ifreqs;
    save(file,'ifreqs','freqs','isiMs','-append');
else
    ifreqs = f.ifreqs;
    isiMs = f.isiMs;
end
offset = 0;
sheet = groupName;
wt({file},excelPath,sheet,1,startColumn);

%write freqs for this movie
nRoi = numel(freqs);
wt({'Frequency (Hz)'},excelPath,sheet,2,startColumn+offset);
wt({'ROI'},excelPath,sheet,3,startColumn+offset);
wt((1:nRoi)',excelPath,sheet,4,startColumn+offset);
offset = offset+1;
wt({'Freq (Hz)'}, excelPath, sheet, 3, startColumn+offset);
wt(freqs',excelPath,sheet,4,startColumn+offset);
offset = offset+2;

%write ifreqs for each ROI
wt({'Inst. Freq. (Hz)'},excelPath,sheet,2,startColumn+offset);
for i = 1:numel(ifreqs)
    roiFreq = ifreqs{i};
    label = sprintf('ROI %d',i);
    wt({label},excelPath,sheet,3,startColumn+offset);
    wt(roiFreq',excelPath,sheet,4,startColumn+offset);
    offset = offset+1;
end

%write isi for each ROI
wt({'Interspike Intervals (ms)'},excelPath,sheet,2,startColumn+offset);
for i = 1:numel(ifreqs)
    roiIsi = isiMs{i};
    label = sprintf('ROI %d',i);
    wt({label},excelPath,sheet,3,startColumn+offset);
    wt(roiIsi',excelPath,sheet,4,startColumn+offset);
    offset = offset+1;
end

function fileStruct = findgroupsfromfiles(ifreqFilePaths)
% FINDGROUPSFROMFILES Groups file paths by parent directory.
fileStruct = struct;

% Group spike files by their parent directory
for iFile = 1:numel(ifreqFilePaths)
    [dir,~,~] = fileparts(ifreqFilePaths{iFile});
    dirSplit = strsplit(dir,filesep);
    folderName = dirSplit{end};
    folderName = strrep(folderName,' ','_');
    if isfield(fileStruct,folderName)
        currentGroup = fileStruct.(folderName);
        currentGroup{end+1} = ifreqFilePaths{iFile};
        fileStruct.(folderName) = currentGroup;
    else
        fileStruct.(folderName) = {ifreqFilePaths{iFile}};
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

function combinedCell = combinecell(c1,c2)
% for a cell array of arrays, concats each cell together
if numel(c1) == 0
    combinedCell = c2;
else
    combinedCell = cell(size(c1));
    for i = 1:numel(c1)
        combinedCell{i} = horzcat(c1{i},c2{i});
    end
end

function addedCell = addcell(c1,c2)
% for a cell array of arrays, adds each cell together
if numel(c1) == 0
    addedCell = c2;
else
    addedCell = cell(size(c1));
    for i=1:numel(c1)
        addedCell{i} = c1{i} + c2{i};
    end
end

function mergedArr = mergecell(c)
% merges the arrays from a cell array into a single array
mergedArr = [];
for i=1:numel(c)
    mergedArr = horzcat(mergedArr,c{i});
end


function ifreqs = patchisitoifreq(isi)
% temporary for patching purposes
% converts isi to frequency in a cell array
ifreqs = cell(size(isi));
for i = 1:numel(isi)
    ifreqs{i} = 1000 ./ isi{i};
end

function dividedCell = divcell(c,d)
% divide cell array c by number d
dividedCell = cell(size(c));
for i = 1:numel(c)
    dividedCell{i} = c{i}/d;
end
