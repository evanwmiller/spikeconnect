function flattenedTrace = traceflattener(trace, polynomial_order)
% TRACEFLATTERNER Flatten the trace using polynomial regression.

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
    
    timeStamps = 1:numel(trace);
    p = polyfit(timeStamps , trace , polynomial_order);
    y = polyval(p, timeStamps);
    minY = min(y);
    flatY = y-minY;
    flattenedTrace = trace - flatY;
end