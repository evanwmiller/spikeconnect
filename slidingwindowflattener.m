function lbtrace = slidingwindowflattener ( trace , window_size)
% Inputs: A trace and window size 
% At each frame, the baseline is calculated as the mean of +/-widnow_size 
% excluding the current frame, and is subtracted from the current frame
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
    vidLength = numel(trace);
    lbtrace = zeros(vidLength,1); 
    
    for ii = 1 : vidLength
        tmp = ii - window_size : ii + window_size;
        baseIdx = tmp( tmp > 0 & tmp < vidLength+1 & tmp~=ii);
        local_baseline = mean( trace( baseIdx ) );
        lbtrace(ii) = trace(ii) - local_baseline;

    end

    lbtrace(lbtrace < 0) = 0;

    


end