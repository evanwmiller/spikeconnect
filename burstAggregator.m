function fireTimes = burstaggregator(spikeTimes, fireGap)
% BURSTAGGREGATOR: Rearming function that bins the spikeTimes with less than
% fireGap delay in between.
%
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
spikesDiff = diff([0, spikeTimes]);
spikeIndex = find(spikesDiff>=fireGap);
fireTimes = spikeTimes(spikeIndex);

end