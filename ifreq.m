function [ifreq , freq] = ifreq(rasterSpikeTime)
% Input: a vector of spike times (i.e. the times at which there are spikes)
% Outputs: ifreq: a vector containing the instantaneous frequencies of the
% input; freq: number of spikes in the input vector
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
ifreq = diff(rasterSpikeTime);
ifreq = ifreq .*2;
ifreq = 1000./ifreq;
freq = numel(rasterSpikeTime);
