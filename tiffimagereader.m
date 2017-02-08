function firstImage = tiffimagereader(filePath, file)
% TIFFIMAGEREADER Reads the first frame from a tiff stack.

% Copyright 2016 The Miller Lab, UC Berkeley
warning('off','all');
filename = [filePath file];
fileInfo=imfinfo(filename);
tiffObj = Tiff(filename, 'r');
tiffObj.setDirectory(1);
firstImage = tiffObj.read();  
warning('on','all');
end