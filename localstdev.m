function localStd = localstdev(traceIn, windowSize)
% LOCALSTDEV: Searches through trace to find the window with the smallest
% standard deviation to determine baseline standard deviation.
%   Inputs:
%       traceIn: an input trace to be searched for a region of stable stdev
%       windowSize: search sliding window size
%   
%   localStd = localstdev(traceIn, windowSize)


% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
traceLength = numel(traceIn);
localStd = realmax;

for leftFrame = 1:traceLength-windowSize
    window = leftFrame:leftFrame + windowSize;
    
    currStd = nanstd( traceIn( window ) );
    if currStd < localStd
        localStd = currStd;
    end

end




