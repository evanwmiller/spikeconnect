function  xcitoexcel(xciResults, excelPath)
%XCITOEXCEL Outputs results from XCI analysis to excel. See XCIANALYSIS.
tabName = 'Summary';

params = xciResults.params;
wt({'Analysis parameters'}, excelPath, tabName, 1, 1);

wt({'Monosynaptic lag range (ms)'}, excelPath, tabName, 3, 1);
wt([params.monoMinLagMs params.monoMaxLagMs], excelPath, tabName, 3, 2);

wt({'Minimum frequency (Hz)'}, excelPath, tabName, 4, 1);
wt(params.minFreq, excelPath, tabName, 4, 2);

wt({'XCI Threshold'}, excelPath, tabName, 5, 1);
wt(params.xciThreshold, excelPath, tabName, 5, 2);

filter = params.filter;
wt({'Cell type filters'}, excelPath, tabName, 7, 1);
wt(getcelltypenames()', excelPath, tabName, 8, 1);
wt({filter.dgc; filter.inhib; filter.ca1; filter.ca3}, ...
        excelPath, tabName, 8, 2);


aggregate = xciResults.aggregate;
startRow = 13;
wt({'Note that aggregate results below only include islands that match filter.'}, ...
        excelPath, tabName, startRow, 1)
wt({'Total number of each type of cell.'}, excelPath, tabName, startRow+2, 1);
wt(getcelltypenames()', excelPath, tabName, startRow+4, 1);
wt(aggregate.typeCount, excelPath, tabName, startRow+4, 2);

wt({'Connectivity factors. This is the average normalized edge count grouped by trigger cell type. Column labels are trigger cell type. Row labels are receiving cell type.'}, ...
    excelPath, tabName, startRow+10, 1);
wt(getcelltypenames(), excelPath, tabName, startRow+11, 2);
wt(getcelltypenames()', excelPath, tabName, startRow+12, 1);
wt(aggregate.connectivityFactor, excelPath, tabName, startRow+12, 2);

for i = 1:numel(xciResults.islandResults)
    writeislandresults(xciResults.islandResults{i}, excelPath);
end


function writeislandresults(islandResults, excelPath)
tabName = islandResults.name;
nRoi = size(islandResults.edgeCount,2);

wt({['Number of edges to each type of cell. '...
    'Column labels are the number of the triggering cell. '...
    'Row labels are type of receiving cell.']}, excelPath, tabName, 1, 1);
wt(1:nRoi, excelPath, tabName, 2, 2);
wt(getcelltypenames()', excelPath, tabName, 3, 1);
wt(islandResults.edgeCount, excelPath, tabName, 3, 2);

wt({'Number of each type of cell.'}, excelPath, tabName, 9, 1);
wt(getcelltypenames()', excelPath, tabName, 11, 1);
wt(islandResults.typeCount, excelPath, tabName, 11,2);

wt({'Normalized edge count. This is the number of edges divided by the total number of the receiving cell.'}, ...
    excelPath, tabName, 17, 1);
wt(1:nRoi, excelPath, tabName, 18, 2);
wt(getcelltypenames()', excelPath, tabName, 19, 1);
wt(islandResults.normalizedEdgeCount, excelPath, tabName, 19, 2);

wt({'Connectivity factors. This is the average normalized edge count grouped by trigger cell type. Column labels are trigger cell type. Row labels are receiving cell type.'}, ...
    excelPath, tabName, 25, 1);
wt(getcelltypenames(), excelPath, tabName, 26, 2);
wt(getcelltypenames()', excelPath, tabName, 27, 1);
wt(islandResults.connectivityFactor, excelPath, tabName, 27, 2);

wt({'XCI. Column labels are trigger cell and row labels are receiving cell. If the value is negative, it goes the other way. If the value is nan in upper righ triangle, then the cell is either nonfiring or did not meet minimum frequency.'}, ...
    excelPath, tabName, 33, 1);
wt(1:nRoi, excelPath, tabName, 34, 2);
wt((1:nRoi)', excelPath, tabName, 35, 1);
% report negative so that trigger is column label.
% xciArr has format of (trigger, receiving).
wt(-islandResults.xciArr, excelPath, tabName, 35, 2);

wt({'XCI grouped by trigger and receiving cell type.'}, excelPath, tabName, 41, 1);
wt(getcelltocellconnections()', excelPath, tabName, 43, 1);
wt(islandResults.xciArrGroupedByType, excelPath, tabName, 43, 2);


function header = getcelltypenames()
header = {'DGC','Inhib', 'CA1','CA3', 'Unknown'};


function header = getcelltocellconnections()
header = {};
celltypes = getcelltypenames();
for trigger = 1:numel(celltypes)
    for receiver = 1:numel(celltypes)
        header{end+1} = sprintf('%s -> %s', celltypes{trigger}, celltypes{receiver});
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
