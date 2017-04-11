function [aucAvg,aucSum,aucArr,areas] = multispike(dff,spikeTimes)
%MULTISPIKE Calculates the integral of just the spikes from a spike train
%by calculating the integral on the flattened trace. Returns the integral
%value (auc) and the areas used to calculate the integral.
adjDff = slidingwindowflattener(dff,100);
areas = zeros(numel(spikeTimes),2);
aucArr = zeros(size(spikeTimes));
aucSum = 0;
nSpike = numel(spikeTimes);
for i = 1:nSpike
    t = spikeTimes(i);
    prev = findprevzero(adjDff,t);
    next = findnextzero(adjDff,t);
    areas(i,:) = [prev,next];
    aucArr(i) = wholetrace(dff,prev,next);
    aucSum = aucSum + aucArr(i);
end
if nSpike == 0
    aucAvg = 0;
else
    aucAvg = aucSum/nSpike;
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

