function spikeData = spikekmeansdff(traceFeatures, dffTrace, K)
% SPIKEKMEANSDFF Computes the spike times from a trace using k-means
% clustering. 
%   traceFeatures is the sliding window flattened version of dff.
%   dff is the relative fluorescence trace. 
%   K is the parameter used for k-means clustering, typically 3 (baseline, 
%       subthreshold, and spikes). 
% If the trace is not df/f and is instead the raw background subtracted 
% trace, use SPIKEKMEANS instead.

% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
    
    % Use k-means clustering to assign each point in the trace vector to
    % either cluster 1 (baseline), cluster 2, or cluster 3 (spikes).
    clusterIndices = kmeans(traceFeatures, K);
    
    for i = 1:K
        kdx(i,:) = clusterIndices == i;
    end
    
    [~ ,spikesClusterIndex] = min(sum(kdx , 2));
    [~ ,baselineClusterIndex] = max(sum(kdx , 2));
    
    clusters = cell(1,K);
    for i = 1:K
        spiko = dffTrace;
        spiko(~kdx(i,:)) = NaN;
        clusters{i} = spiko;
    end
    
    % dff is just the dff of the spikes (NaN for non spikes)
    dff = clusters{spikesClusterIndex};
    rasterSpikeTimes = find(~isnan(dff));
        
    baselineDff = clusters{baselineClusterIndex};
    stdBaselineDff = localstdev(baselineDff , 100);
    dffSnr = (dff) / stdBaselineDff ;
    
    spikeData = struct('clusters', {clusters}, ...
                   'spikesClusterIndex', spikesClusterIndex, ...
                   'baselineClusterIndex', baselineClusterIndex, ...
                   'rasterSpikeTimes', rasterSpikeTimes, ...
                   'dffs',  dff , ...
                   'dffSnr',   dffSnr , ...
                   'dffTrace', dffTrace);
end

