%% applyMask2TiffStack(tiff_stack , mask)
% Applies logical mask to all frames of an image stack.
% The mask and the image stack height and width should be the same.
% Returns a masked stack of the same height, width, and length .
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi

function masked_tiff_stack = applyMask2TiffStack(tiff_stack , mask)

  h = waitbar(0 , 'Applying mask...');
  masked_tiff_stack = tiff_stack;
  L = size(tiff_stack , 3);
  waitbar(0.1 , h)
  for i = 1:L
    masked_tiff_stack(:,:,i) = tiff_stack(:,:,i).*mask;
%     if(rem(i , 20)==0)
%         waitbar(i/L , h);
%     end
  end
 waitbar(1 , h) 
 close(h);
%     
    
    