function alliFreqs = save_ifreq_xlsx(ifreqs , freqs , xlsxFileName ,sheetn ,sourceFileName)
% ifreqs: a cell array containing a set of ROIs' instantaneous frequencies
% freqs: a cell array containgin a set of ROIs' frequencies
% xlsxFileName: Excel filename to which data is saved (format should be
% [filename].xlsx)
% sheetn: a character vector containing the worksheet name or a positive 
% integer indicating the worksheet index
% Note: ifreqs and freqs should have similar sizes
% Author: Kaveh Karbasi

maxFreq = max(cell2mat(freqs)) - 1;
numROIs = numel(ifreqs);
outMat = zeros(maxFreq , numROIs);
colTitles = cell(1,numROIs);
alliFreqs = [];
for ff = 1:numel(ifreqs)
       colTitles{ff} = ['ROI ' num2str(ff)];
       freqCol = ifreqs{ff};    
       freqCol = freqCol';
       alliFreqs = [alliFreqs ; freqCol];
       outMat((1:numel(freqCol)) , ff) = freqCol;
end
outMat(outMat == 0) = nan;

writetable(table({sourceFileName}) ,xlsxFileName ,'Sheet', sheetn, 'Range' , 'A1' , 'WriteVariableNames' , false);

writetable(table({'Freqs'}) ,xlsxFileName,'Sheet', sheetn,  'Range' , ['A' num2str(maxFreq + 6)] , 'WriteVariableNames' , false);

writetable(table(cell2mat(freqs)') ,xlsxFileName,'Sheet', sheetn, 'Range' , ['B' num2str(maxFreq + 7)] , 'WriteVariableNames' , false);

writetable(table({'Inst. Freqs (all ROIs)'}) ,xlsxFileName,'Sheet', sheetn,  'Range' , ['E' num2str(maxFreq + 6)] , 'WriteVariableNames' , false);

writetable(table(alliFreqs) ,xlsxFileName,'Sheet', sheetn, 'Range' , ['E' num2str(maxFreq + 7)] , 'WriteVariableNames' , false);

writetable(table({'Inst. Freqs'}) ,xlsxFileName ,'Sheet', sheetn, 'Range' , 'A3' , 'WriteVariableNames' , false);

writetable(table(colTitles) ,xlsxFileName, 'Sheet', sheetn, 'Range' , 'A4' , 'WriteVariableNames' , false);

writetable(table(outMat) , xlsxFileName ,'Sheet', sheetn,  'Range' , 'A5' , 'WriteVariableNames' , false);


