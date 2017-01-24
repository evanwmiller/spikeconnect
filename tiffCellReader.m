function backgroundStack = tiffCellReader(filepath, filenames)
% Copyright 2016 The Miller Lab, UC Berkeley
    backgroundStack = cell(size(filenames));
    for index = 1:numel(filenames)
        filename = [filepath filenames{index}];
        fileInfo=imfinfo(filename);
        frameW=fileInfo(1).Width;
        frameH=fileInfo(1).Height;
        backgroundStack{index}=zeros(frameH,frameW);

        tiffObj = Tiff(filename, 'r');
        tiffObj.setDirectory(1);
        backgroundStack{index} = tiffObj.read();   
    end
end