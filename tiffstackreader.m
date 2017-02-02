function tiffStack = tiffstackreader(fileName)
% TIFFSTACKREADER Converts a .tiff image to a matrix.
%   fileName should be the full path to a .tiff file.

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi    
    warning('off', 'all');
    fileInfo=imfinfo(fileName);
    frameW=fileInfo(1).Width;
    frameH=fileInfo(1).Height;
    nframes=length(fileInfo);
    tiffStack=zeros(frameH,frameW,nframes);

    tiffObj = Tiff(fileName , 'r');
    h = waitbar(0 , ['Reading ', fileName, '...']);
    for i = 1:nframes
        tiffObj.setDirectory(i);
        tiffStack(:,:,i) = tiffObj.read();   
        if (rem(i,100)==0)
            waitbar(i/nframes , h);
        end
    end
    close(h);
 
    warning('on' , 'all');
    
end