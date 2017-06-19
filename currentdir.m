function outfiles=currentdir(baseDir,searchExpression, exclude)
% CURRENTDIR searches Searches specified folder for matches, excluding the
% file specified by exclude.
% Example: currentdir(h.baseDir , '^spikes-.*.mat$');
% Copyright 2016 The Miller Lab, UC Berkeley

if nargin < 3
    exclude = '';
end

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
