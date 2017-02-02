function meanTrace = nnzmeantrace(maskedTiffStack , binaryBgImg)
% COMPUTENNZMEAN Computes the mean of a trace by taking the average of the non-zero
% elements. 
%
% See Also: NNZ

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
meanTrace = sum(sum(maskedTiffStack,1),2);
meanTrace = meanTrace/nnz(binaryBgImg);
meanTrace = reshape(meanTrace , [1 numel(meanTrace)]);