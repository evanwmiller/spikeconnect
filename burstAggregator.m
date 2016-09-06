function fireTimes = burstAggregator(spike_times , fireGap)
    
    spikesDiff = diff([0 , spike_times]);
    spikeIndxes = find(spikesDiff>=fireGap);
    fireTimes = spike_times(spikeIndxes);

end