function frame = read_tiffStack_frame(filename , frameNumber)
% This function reads and returns the nth frame of an input tiff stack
% video
% Copyright 2016 The Miller Lab, UC Berkeley

    fileInfo=imfinfo(filename);
    nframes=length(fileInfo);
    
    if(nframes < frameNumber)
        error('Error. \nFrame number must be smaller than the video length')
    end
        
    tiffObj = Tiff(filename , 'r');
    tiffObj.setDirectory(frameNumber);
    frame = tiffObj.read();   
end