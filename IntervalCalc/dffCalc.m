function dffTrace = dffCalc(traceFeatures, roiTraceIn, K)
%DFFCALC
%   Edited version of spikekmeans function

    % use polynomial regression to flatten the trace and calc df/f
    roiTrace = traceflattener(roiTraceIn, 1);
    
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
        spiko = roiTrace;
        spiko(~kdx(i,:)) = NaN;
        clusters{i} = spiko;
    end
    baseline = roiTrace(~isnan(clusters{baselineClusterIndex}));
    baseline = nanmedian(baseline);
    
    spikes = clusters{spikesClusterIndex};
    dff = (spikes - baseline)/baseline;
    rasterSpikeTimes = find(~isnan(dff));
    
    dffTrace = (roiTrace-baseline)/baseline;
        
    baseline_cluster = clusters{baselineClusterIndex};
    baselineDff = (baseline_cluster - baseline)/baseline;
    stdBaselineDff = localstdev(baselineDff , 100);
    dffSnr = (dff) / stdBaselineDff ;
end

