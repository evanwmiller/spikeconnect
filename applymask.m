function maskedTiffStack = applymask(tiffStack, mask, prefix, suffix)
% APPLYMASK Applies logical mask to all frames of an image stack (TIFF).
%   The mask and the image stack height and width should be the same.
%   Returns a masked stack of the same height, width, and length .
%   Prefix and suffix are optional arguments that go before and after mask.
%   If suffix is specified, prefix must be specified.
%   maskedTiffStack = applymask(tiffStack, mask, prefix, suffix)

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
if ~exist('prefix','var')
    prefix = '';
end
if ~exist('suffix','var')
    suffix='';
end

progressBar = waitbar(0, ['Applying ' prefix ' mask ' suffix '...']);
maskedTiffStack = zeros(size(tiffStack));
nFrame = size(tiffStack, 3);
waitbar(0.1, progressBar);
for iFrame = 1:nFrame
    maskedTiffStack(:,:,iFrame) = tiffStack(:,:,iFrame).*mask;
    waitbar(iFrame/nFrame, progressBar);
end
close(progressBar);
    