function localSTD = getLocalSTD(intrace , windowSize)
% intrace: an input trace to be searched for a region of stable std
% windowSize: search sliding window size
% This function searches for the most stable part of the trace to represent
% as the baseline standard deviation
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
traceLength = numel(intrace);
localSTD = realmax;

for ii = 1 : traceLength-windowSize
    baseIdx = ii : ii + windowSize;
    
    curr_std = nanstd( intrace( baseIdx ) );
    if curr_std < localSTD
        localSTD = curr_std;
    end

end




