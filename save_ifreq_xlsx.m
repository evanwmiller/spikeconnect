function save_ifreq_xlsx(ifreqs , freqs , xlsxFileName)
% ifreqs: a cell array containing a set of ROIs' instantaneous frequencies
% freqs: a cell array containgin a set of ROIs' frequencies
% xlsxFileName: Excel filename to which data is saved (format should be
% [filename].xlsx)
% Note: ifreqs and freqs should have similar sizes
% Author: Kaveh Karbasi

maxFreq = max(cell2mat(freqs)) - 1;
numROIs = numel(ifreqs);
outMat = zeros(maxFreq , numROIs);
colTitles = cell(1,numROIs);
for ff = 1:numel(ifreqs)
        colTitles{ff} = ['ROI ' num2str(ff)];
       freqCol = ifreqs{ff};    
       freqCol = freqCol';
       outMat((1:numel(freqCol)) , ff) = freqCol;
end
outMat(outMat == 0) = nan;

writetable(table({'Inst. Freqs'}) ,xlsxFileName, 'Range' , 'A1' , 'WriteVariableNames' , false);

writetable(table(colTitles) ,xlsxFileName, 'Range' , 'A2' , 'WriteVariableNames' , false);

writetable(table(outMat) , xlsxFileName , 'Range' , 'A3' , 'WriteVariableNames' , false);

writetable(table({'Freqs'}) ,xlsxFileName, 'Range' , ['A' num2str(maxFreq + 5)] , 'WriteVariableNames' , false);

writetable(table(cell2mat(freqs)') ,xlsxFileName, 'Range' , ['B' num2str(maxFreq + 6)] , 'WriteVariableNames' , false);
