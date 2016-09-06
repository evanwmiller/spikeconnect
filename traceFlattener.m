function flattenedTrace = traceFlattener(trace , polynomial_order)
     %------ Configuration Variables------
%     polynomial_order = 10;
    
    %-----------------------------------

    % Flatten the trace using polynomial regression
    timeStamps = 1:numel(trace);
    p = polyfit(timeStamps , trace , polynomial_order);
    y = polyval(p, timeStamps);
    minY = min(y);
    flatY = y-minY;
    flattenedTrace = trace - flatY;


end