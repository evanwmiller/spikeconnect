function [adjustedTraces, rawTraces] = computetraces(tiffStack, roiMasks, bkgMask, bkgDecision)
% COMPUTETRACE For each ROI, compute trace from TIFF stack.
%   Inputs:
%       tiffStack: input video after reading into a 3d matrix
%       roiMasks: a cell array of ROI binary masks
%       bkgMask: a binary mask for the background region
%       bkgDecision: background method (selected in batchkmeans_gui)
%
%   Outputs:
%       adjustedTraces: a cell array containing adjusted ROI traces
%                        
%       rawTraces: a cell array contraining the raw traces (without
%                  background subtraction).

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi

% Calculate background 
bkgTrace = applymask(tiffStack , bkgMask, 'background', '');
bkgTrace = nnzmeantrace(bkgTrace , bkgMask);
bkgMedian = nanmedian(bkgTrace);

adjustedTraces = cell(size(roiMasks));
rawTraces = cell(size(roiMasks));
nRoi = numel(roiMasks);
for iRoi = 1:nRoi
    roiTrace = applymask(tiffStack, roiMasks{iRoi},...
        'ROI',[num2str(iRoi) ' of ' num2str(nRoi)]);
    roiTrace = nnzmeantrace(roiTrace, roiMasks{iRoi});
    rawTraces{iRoi} = roiTrace;
    
    switch bkgDecision
        case 'Raw'
            adjustedTraces{iRoi} = roiTrace;
        case 'Background Correction'
            adjustedTraces{iRoi} = roiTrace - bkgMedian;
        case 'Background Subtraction'
            adjustedTraces{iRoi} = roiTrace - bkgTrace;
        otherwise
            disp('Invalid background choice, using Raw instead.');
            adjustedTraces{iRoi} = roiTrace;
    end
end

    