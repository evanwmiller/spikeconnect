function [ifreq , freq, count] = ifreq(rasterSpikeTime, frameRate, numFrames)
% Input: a vector of spike times (i.e. the times at which there are spikes)
% Input: frame rate of movie
% Outputs: ifreq: a vector containing the instantaneous frequencies of the
% input; freq: number of spikes in the input vector
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
ifreq = diff(rasterSpikeTime);
ifreq = ifreq ./ frameRate * 1000 % convert from frames to ms
count = numel(rasterSpikeTime)
freq = count/(numFrames/frameRate)
