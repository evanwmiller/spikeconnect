function fireTimes = burstAggregator(spike_times , fireGap)
% Rearming function. Bins the spike_times with less than 
% fireGap delay inbetween
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
    spikesDiff = diff([0 , spike_times]);
    spikeIndxes = find(spikesDiff>=fireGap);
    fireTimes = spike_times(spikeIndxes);

end