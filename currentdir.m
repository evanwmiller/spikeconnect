function outfiles=currentdir(baseDir,searchExpression, exclude)
% OUTFILES = RECURSDIR(BASEDIRECTORY,SEARCHEXPRESSION)
% Use this method to search the current folder for matches, but exclude one
% particular file.
% Usage: used in select_ROI_gui3 to automatically select all .tiff files
% in the given directory that aren't the excluded file.
% Copyright 2016 The Miller Lab, UC Berkeley

dirContents = dir(baseDir);
outfiles = {};
for i = 1:length(dirContents)
    %look for a match that isn't a directory
    if ~dirContents(i).isdir && ~isempty(regexp(dirContents(i).name,searchExpression,'match')) 
        if strcmp(exclude,dirContents(i).name) == 0
            outfiles{length(outfiles)+1} = dirContents(i).name;
        end
    end
end
