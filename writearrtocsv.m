function writearrtocsv(arr, csvPath, rowNames, columnNames, title)
% WRITEARRTOCSV Appends arr to the .csv at csvPath with given rowNames and
% columnNames. rowNames and columnNames should be cell array of strings.
% If either are empty, they will just be numbered instead.
% arr should either be a 2d array or a cell array of arrays.
fid = fopen(csvPath, 'a');
fprintf(fid, '%s\n', title);
fprintf(fid, ',');
if numel(columnNames) == 0
    fprintf(fid, '%d,', 1:size(arr, 2));
else 
    fprintf(fid, '%s,', columnNames{1:end});
end
fprintf(fid, '\n');
for i = 1:size(arr,1)
    if numel(rowNames) == 0
        fprintf(fid, '%d,', i);
    else
        fprintf(fid, '%s,', rowNames{i});
    end
    if iscell(arr)
        fprintf(fid, '%d,', arr{i});
    else 
        fprintf(fid, '%d,', arr(i,:));
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n\n');
fclose(fid);
end