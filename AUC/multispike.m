function [auc,adjDff,areas] = multispike(dff,spikeTimes)
%MULTISPIKE Calculates the integral of just the spikes from a spike train
%by calculating the integral on the flattened trace. Returns the integral
%value (auc) and the adjusted trace used to calculate the integral. Also
%returns the area boundaries for plotting purposes.
adjDff = slidingwindowflattener(dff,100);
areas = zeros(numel(spikeTimes),2);
auc = 0;
for i = 1:numel(spikeTimes)
    t = spikeTimes(i);
    prev = findprevzero(adjDff,t);
    next = findnextzero(adjDff,t);
    areas(i,:) = [prev,next];
    auc = auc + trapz(adjDff(prev:next));
end

function nextIndex = findnextzero(arr,index)
nextIndex = index;
%if it hits the end, no need to check since that will be the default.
while nextIndex < numel(arr) - 1 && arr(nextIndex) ~= 0
    nextIndex = nextIndex + 1;
end

function prevIndex = findprevzero(arr,index)
prevIndex = index;
while prevIndex > 1 && arr(prevIndex) ~= 0 
    prevIndex = prevIndex - 1;
end

