function [ifreq , freq, count] = ifreq(rasterSpikeTimes, frameRate, numFrames)
% Input: a vector of spike times (i.e. the times at which there are spikes)
% Input: frame rate and number of frames of the movie
% Outputs:  ifreq:  a vector containing interspike intervals in ms
%           freq:   number of spikes in the input vector

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
ifreq = diff(rasterSpikeTimes);
 % convert from frames between spikes to interspike interval in ms
ifreq = ifreq ./ frameRate * 1000;

count = numel(rasterSpikeTimes);
freq = count/(numFrames/frameRate);
