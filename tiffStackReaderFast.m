function tiffStack = tiffStackReaderFast(filename)
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi    
    warning('off', 'all');
    fileInfo=imfinfo(filename);
    frameW=fileInfo(1).Width;
    frameH=fileInfo(1).Height;
    nframes=length(fileInfo);
    tiffStack=zeros(frameH,frameW,nframes);

    tiffObj = Tiff(filename , 'r');
    h = waitbar(0 , ['Reading ', filename, '...']);
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