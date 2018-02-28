function  xcitoexcel(xciResults, excelPath)
%XCITOEXCEL Outputs results from XCI analysis to excel. See XCIANALYSIS.
tabName = 'Summary';

nr = 1; % next row

params = xciResults.params;
nr=wt({'Analysis parameters'}, excelPath, tabName, nr, 1);

wt({'Monosynaptic lag range (ms)'}, excelPath, tabName, nr, 1);
nr=wt([params.monoMinLagMs params.monoMaxLagMs], excelPath, tabName, nr, 2);

wt({'Minimum frequency (Hz)'}, excelPath, tabName, nr, 1);
nr=wt(params.minFreq, excelPath, tabName, nr, 2);

wt({'XCI Threshold'}, excelPath, tabName, nr, 1);
nr=wt(params.xciThreshold, excelPath, tabName, nr, 2);

filter = params.filter;
nr=wt({'Cell type filters'}, excelPath, tabName, nr+1, 1);
wt(getcelltypenames()', excelPath, tabName, nr, 1);
nr=wt({filter.dgc; filter.inhib; filter.ca1; filter.ca3}, ...
        excelPath, tabName, nr, 2);


aggregate = xciResults.aggregate;
nr=wt({'Note that aggregate results below only include islands that match filter.'}, ...
        excelPath, tabName, nr+2, 1);
nr=wt({'Total number of each type of cell.'}, excelPath, tabName, nr+2, 1);
wt(getcelltypenames()', excelPath, tabName, nr, 1);
nr=wt(aggregate.typeCount(1:4), excelPath, tabName, nr, 2);

nr=wt({'Connectivity factors. This is the average normalized edge count grouped by trigger cell type. Column labels are trigger cell type. Row labels are receiving cell type.'}, ...
    excelPath, tabName, nr+1, 1);
nr=wt(getcelltypenames(), excelPath, tabName, nr, 2);
wt(getcelltypenames()', excelPath, tabName, nr, 1);
nr=wt(aggregate.connectivityFactor(1:4,1:4), excelPath, tabName, nr, 2);

for i = 1:numel(xciResults.islandResults)
    writeislandresults(xciResults.islandResults{i}, excelPath);
end


function writeislandresults(islandResults, excelPath)
tabName = islandResults.name;
nRoi = size(islandResults.edgeCount,2);
nr = 1; % next row

nr=wt({['Number of edges to each type of cell. '...
    'Column labels are the number of the triggering cell. '...
    'Row labels are type of receiving cell.']}, excelPath, tabName, nr, 1);
nr=wt(1:nRoi, excelPath, tabName, nr, 2);
wt(getcelltypenames()', excelPath, tabName, 3, 1);
nr=wt(islandResults.edgeCount(1:4,:), excelPath, tabName, nr, 2);

nr=wt({'Number of each type of cell.'}, excelPath, tabName, nr+1, 1);
wt(getcelltypenames()', excelPath, tabName, nr, 1);
nr=wt(islandResults.typeCount(1:4), excelPath, tabName, nr,2);

nr=wt({'Normalized edge count. This is the number of edges divided by the total number of the receiving cell.'}, ...
    excelPath, tabName, nr+1, 1);
nr=wt(1:nRoi, excelPath, tabName, nr, 2);
wt(getcelltypenames()', excelPath, tabName, nr, 1);
nr=wt(islandResults.normalizedEdgeCount(1:4,:), excelPath, tabName, nr, 2);

nr=wt({'Connectivity factors. This is the average normalized edge count grouped by trigger cell type. Column labels are trigger cell type. Row labels are receiving cell type.'}, ...
    excelPath, tabName, nr+1, 1);
nr=wt(getcelltypenames(), excelPath, tabName, nr, 2);
wt(getcelltypenames()', excelPath, tabName, nr, 1);
nr=wt(islandResults.connectivityFactor(1:4,1:4), excelPath, tabName, nr, 2);

nr=wt({'Connectivity factors organized by connection type.'}, excelPath, tabName, nr+1,1);
nr=wt(getcelltocellconnections(), excelPath, tabName, nr, 1);
nr=wt(reshape(islandResults.connectivityFactor(1:4,1:4)', 1, 16), excelPath, tabName, nr, 1);

nr=wt({'XCI. Column labels are trigger cell and row labels are receiving cell. If the value is negative, it goes the other way. If the value is missing in upper right triangle, then the cell is either nonfiring or did not meet minimum frequency.'}, ...
    excelPath, tabName, nr+1, 1);
nr=wt(1:nRoi, excelPath, tabName, nr, 2);
wt((1:nRoi)', excelPath, tabName, nr, 1);
% report negative so that trigger is column label.
% xciArr has format of (trigger, receiving).
nr=wt(-islandResults.xciArr, excelPath, tabName, nr, 2);

nr=wt({'XCI grouped by trigger and receiving cell type.'}, excelPath, tabName, nr+1, 1);
nr=wt(getcelltocellconnections(), excelPath, tabName, nr, 1);
nr=wt(islandResults.xciArrGroupedByType', excelPath, tabName, nr, 2);


function header = getcelltypenames()
header = {'DGC','Inhib', 'CA1','CA3'};


function header = getcelltocellconnections()
header = {};
celltypes = getcelltypenames();
for trigger = 1:numel(celltypes)
    for receiver = 1:numel(celltypes)
        header{end+1} = sprintf('%s -> %s', celltypes{trigger}, celltypes{receiver});
    end
end


function nextRow = wt(content,file,sheet,row, col)
% WT Shortcut for WRITETABLE. Input row and col in numbers.
% Returns the next empty row.
range = nn2an(row,col);
writetable(table(content), file, 'Sheet',sheet,'Range',range,'WriteVariableNames', false);
nextRow = row + size(content, 1);

function cr = nn2an(row, col)
% convert number, number format to alpha, number format
t = [floor((col - 1)/26) + 64 rem(col - 1, 26) + 65];
if(t(1)<65), t(1) = []; end
cr = [char(t) num2str(row)];
