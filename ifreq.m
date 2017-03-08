function [ifreqs, isiMs, freq] = ifreq(rasterSpikeTimes, frameRate, numFrames)
% Input: a vector of spike times (i.e. the times at which there are spikes)
% Input: frame rate and number of frames of the movie
% Outputs:  ifreq:  instantaneous frequency vector in Hz
%           isi: interspike interval vector in milliseconds
%           freq:   number of spikes in the input vector

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
isiFrame = diff(rasterSpikeTimes);
 % convert from frames between spikes to interspike interval in ms
isiSec = isiFrame ./ frameRate;
isiMs = isiSec*1000;
ifreqs = 1./isiSec;

count = numel(rasterSpikeTimes);
freq = count/(numFrames/frameRate);
