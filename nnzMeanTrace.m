function meanTrace = nnzMeanTrace(maskedTiffStack , binarybgimg)

    meanTrace = sum(sum(maskedTiffStack,1),2);
    meanTrace = meanTrace/nnz(binarybgimg);
    meanTrace = reshape(meanTrace , [1 numel(meanTrace)]);