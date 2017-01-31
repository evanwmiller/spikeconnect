function maskedTiffStack = applymask(tiffStack, mask)
% Applies logical mask to all frames of an image stack (TIFF).
% The mask and the image stack height and width should be the same.
% Returns a masked stack of the same height, width, and length .
% maskedTiffStack = applymask(tiffStack, mask)

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
progressBar = waitbar(0, 'Applying mask...');
maskedTiffStack = zeros(size(tiffStack));
nFrame = size(tiffStack, 3);
waitbar(0.1, progressBar);
for iFrame = 1:nFrame
    maskedTiffStack(:,:,iFrame) = tiffStack(:,:,iFrame).*mask;
end
waitbar(1 , progressBar);
close(progressBar);
    