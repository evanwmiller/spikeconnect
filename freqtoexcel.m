function alliFreqs = freqtoexcel(ifreqs , freqs ,maxCount, xlsxFileName ,sheetn ,sourceFileName)
% ifreqs: a cell array containing a set of ROIs' instantaneous frequencies
% freqs: a cell array containing a set of ROIs' frequencies
% xlsxFileName: Excel filename to which data is saved (format should be
% [filename].xlsx)
% sheetn: a character vector containing the worksheet name or a positive 
% integer indicating the worksheet index
% Note: ifreqs and freqs should have similar sizes

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi

matsize = maxCount - 1; % size matrix to maximum number of ifreqs
numROIs = numel(ifreqs);
outMat = zeros(matsize , numROIs);
colTitles = cell(1,numROIs);
alliFreqs = [];
for ff = 1:numel(ifreqs)
   colTitles{ff} = ['ROI ' num2str(ff)];
   freqCol = ifreqs{ff};    
   freqCol = freqCol';
   alliFreqs = [alliFreqs ; freqCol];
   if numel(freqCol)>0
     outMat((1:numel(freqCol)) , ff) = freqCol;
   end
end
outMat(outMat == 0) = nan;

writetable(table({sourceFileName}) ,xlsxFileName ,'Sheet', sheetn, 'Range' , 'A1' , 'WriteVariableNames' , false);

writetable(table({'ROI'}) ,xlsxFileName,'Sheet', sheetn,  'Range' , ['A' num2str(matsize + 6)] , 'WriteVariableNames' , false);
writetable(table({'Freqs (Hz)'}) ,xlsxFileName,'Sheet', sheetn,  'Range' , ['B' num2str(matsize + 6)] , 'WriteVariableNames' , false);
%ROI Labels for frequencies
if ~isempty(cell2mat(freqs))
    writetable(table((1:numel(freqs))') ,xlsxFileName,'Sheet', sheetn, 'Range' , ['A' num2str(matsize + 7)] , 'WriteVariableNames' , false);
end

if ~isempty(cell2mat(freqs))
    writetable(table(cell2mat(freqs)') ,xlsxFileName,'Sheet', sheetn, 'Range' , ['B' num2str(matsize + 7)] , 'WriteVariableNames' , false);
end

writetable(table({'Inst. Freqs (ms) (all ROIs)'}) ,xlsxFileName,'Sheet', sheetn,  'Range' , ['E' num2str(matsize + 6)] , 'WriteVariableNames' , false);

if ~isempty(alliFreqs)
    writetable(table(alliFreqs) ,xlsxFileName,'Sheet', sheetn, 'Range' , ['E' num2str(matsize + 7)] , 'WriteVariableNames' , false);
end

writetable(table({'Inst. Freqs (ms)'}) ,xlsxFileName ,'Sheet', sheetn, 'Range' , 'A3' , 'WriteVariableNames' , false);

if ~isempty(colTitles)
    writetable(table(colTitles) ,xlsxFileName, 'Sheet', sheetn, 'Range' , 'A4' , 'WriteVariableNames' , false);
end
if ~isempty(outMat)
    writetable(table(outMat) , xlsxFileName ,'Sheet', sheetn,  'Range' , 'A5' , 'WriteVariableNames' , false);
end

