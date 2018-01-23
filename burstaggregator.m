function fireTimes = burstaggregator(spikeTimes, trace, fireGap)
% BURSTAGGREGATOR: Rearming function that bins the spikeTimes with less than
% fireGap delay in between. For each bin, select the spikeTime that
% corresponds to the max value in the trace.
%
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
if nargin < 3 
    error('Not enough input arguments');
end

groupedTimes = group(spikeTimes, fireGap);
fireTimes = getpeaks(groupedTimes, trace);
end

function groupedTimes = group(spikeTimes, fireGap)
% GROUP Combine times that are less than fireGap apart. For example, if the
% input is group([1 5 10 13 14 20], 5), output {[1 5], [10 13 14], 20}.
groupedTimes = {};
if numel(spikeTimes) == 0
    return
end

currentGroup = spikeTimes(1);
for i = 2:numel(spikeTimes)
    if spikeTimes(i) - currentGroup(end) < fireGap
        currentGroup(end+1) = spikeTimes(i);
    else
        groupedTimes{end+1} = currentGroup;
        currentGroup = spikeTimes(i);
    end
end
groupedTimes{end+1} = currentGroup;
end


function peaks = getpeaks(groupedTimes, trace)
% GETPEAKS Given grouped times, for each group, find the time that
% corresponds to the max value in the given trace. For example, if the
% input is getpeaks({[1],[4,5]}, [1 2 3 10 15]), return [1, 5].
peaks = [];
for i = 1:numel(groupedTimes)
    group = groupedTimes{i};
    [~, maxIndex] = max(trace(group));
    peaks(end+1) = group(maxIndex);
end
end
