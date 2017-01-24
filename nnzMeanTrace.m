function meanTrace = nnzMeanTrace(maskedTiffStack , binarybgimg)
% Get the mean trace of an ROI
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
    meanTrace = sum(sum(maskedTiffStack,1),2);
    meanTrace = meanTrace/nnz(binarybgimg);
    meanTrace = reshape(meanTrace , [1 numel(meanTrace)]);