function Outfiles=recursdir(baseDir,searchExpression)
% OUTFILES = RECURSDIR(BASEDIRECTORY,SEARCHEXPRESSION)
% A recursive search to find files that match the search expression
%

dstr = dir(baseDir);%search current directory and put results in structure
Outfiles = {};
for II = 1:length(dstr)
    if ~dstr(II).isdir && ~isempty(regexp(dstr(II).name,searchExpression,'match')) 
    %look for a match that isn't a directory
        Outfiles{length(Outfiles)+1} = fullfile(baseDir,dstr(II).name);
    elseif dstr(II).isdir && ~strcmp(dstr(II).name,'.') && ~strcmp(dstr(II).name,'..') 
    %if it is a directory(and not current or up a level), search in that
        pname = fullfile(baseDir,dstr(II).name);
        OutfilesTemp=recursdir(pname,searchExpression);
        if ~isempty(OutfilesTemp)
        %if recursive search is fruitful, add it to the current list
            Outfiles((length(Outfiles)+1):(length(Outfiles)+length(OutfilesTemp))) = OutfilesTemp;
        end
    end
end
