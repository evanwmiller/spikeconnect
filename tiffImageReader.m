function backgroundStack = tiffImageReader(filepath, file)
% Copyright 2016 The Miller Lab, UC Berkeley
        filename = [filepath file];
        fileInfo=imfinfo(filename);
        frameW=fileInfo(1).Width;
        frameH=fileInfo(1).Height;

        tiffObj = Tiff(filename, 'r');
        tiffObj.setDirectory(1);
        backgroundStack = tiffObj.read();   
end