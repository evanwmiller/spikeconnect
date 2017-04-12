function [auc,adjDff] = wholetrace(dff)
%WHOLETRACE Calculates the integral of the dff by zeroing all values
%below the treshold and taking the integral of the curve. Returns the 
%integral value (auc) and the adjusted dff used to calculate the integral.
THRESHOLD = 0.01;

adjDff = dff;
adjDff(adjDff<THRESHOLD) = 0;
length = numel(adjDff);

auc = trapz(adjDff(1:length));
end

