function [bkgSubtracted_traces , ROI_traces] = getBkgSubtractedTraces(tiffStack, ROI_masks , Bkg_mask , bkg_decision)
% Inputs:
% tiffStack: input video after reading into a 3d matrix
% ROI_masks: a cell array of ROI binary masks
% Bkg_mask: a binary mask for the background region
% Output:
% bkgSubtracted_traces: a cell array containing background subtracted
% traces of ROIs
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
bkgSubtracted_traces = cell(size(ROI_masks));
ROI_traces = cell(size(ROI_masks));
bkg_trace = applyMask2TiffStack(tiffStack , Bkg_mask);
bkg_trace = nnzMeanTrace(bkg_trace , Bkg_mask);
bkg_median = nanmedian(bkg_trace);


for rr = 1:numel(ROI_masks)

    ROI_trace = applyMask2TiffStack(tiffStack , ROI_masks{rr});
    ROI_trace = nnzMeanTrace(ROI_trace , ROI_masks{rr});
    ROI_traces{rr} = ROI_trace;
    
    if  strcmp(bkg_decision , 'Raw')
        bkgSubtracted_traces{rr} = ROI_trace ;
    elseif strcmp(bkg_decision , 'Bkg correction')
        bkgSubtracted_traces{rr} = ROI_trace - bkg_median;
    elseif strcmp(bkg_decision , 'Bkg subtraction')
        bkgSubtracted_traces{rr} = ROI_trace - bkg_trace;
    end


end

    