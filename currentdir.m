function Outfiles=currentdir(baseDir,searchExpression, exclude)
% OUTFILES = RECURSDIR(BASEDIRECTORY,SEARCHEXPRESSION)
% Use this method to search the current folder for matches, but exclude one
% particular file.
% Usage: used in select_ROI_gui3 to automatically select all .tiff files
% in the given directory that aren't the excluded file.
% Copyright 2016 The Miller Lab, UC Berkeley

dstr = dir(baseDir);%search current directory and put results in structure
Outfiles = {};
for II = 1:length(dstr)
    %look for a match that isn't a directory
    if ~dstr(II).isdir && ~isempty(regexp(dstr(II).name,searchExpression,'match')) 
        if strcmp(exclude,dstr(II).name) == 0
            Outfiles{length(Outfiles)+1} = dstr(II).name;
        end
    end
end
