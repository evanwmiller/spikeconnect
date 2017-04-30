function featureVectorArr = extractfeatures(traces, spikeData, frameRate)
%EXTRACTFEATURES Determines feature vectors for each spike of a spike train.
%   The features calculated are (in order of return arr):
%       1. peak dff - highest dff within spike window
%       2. auc - area of spike within spike window
%       3. width - width of spike as determined by sliding window flattener
%       4. starting height - difference between dff when spike begins/ends
%       (whichever is smaller) and the baseline dff
%   Returns the feature vectors as a cell array of arrays.

spikeTimes = spikeData.rasterSpikeTimes;
[~,~,aucArr,windowArr] = multispike(traces,spikeTimes,frameRate);
featureVectorArr = cell(size(spikeTimes));
for i = 1:numel(spikeTimes)
    window = windowArr(i,:);
    peakdff = max(traces(window(1):window(2)));
    auc = frame2ms(aucArr(i),frameRate);
    width = frame2ms(window(2) - window(1),frameRate);
    height = min(traces(window));
    featureVectorArr{i} = [peakdff, auc, width, height];
end

function ms = frame2ms(frame, frameRate)
ms = frame / frameRate * 1000;