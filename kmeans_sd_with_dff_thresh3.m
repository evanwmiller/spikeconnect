function [clusters , spikes_cluster_idx , baseline_cluster_idx , rasterSpikeTime , dff1 , dff_snr] = kmeans_sd_with_dff_thresh2(trace_features , ROI_tracein , K , dff_thresh)
    % use polynomial regression to flatten the trace and calc df/f
    ROI_trace = traceFlattener(ROI_tracein , 1);
%     baseline = median(ROI_trace);

    idx = kmeans(trace_features , K);
    
    for i = 1:K
        kdx(i,:) = idx == i;
    end
    
    [~ ,spikes_cluster_idx] = min(sum(kdx , 2));
     [~ ,baseline_cluster_idx] = max(sum(kdx , 2));
    
    clusters = cell(1,K);
    for i = 1:K
        spiko = ROI_trace;
        spiko(~kdx(i,:)) = NaN;
        clusters{i} = spiko;
    end
    baseline = ROI_trace(~isnan(clusters{baseline_cluster_idx}));
    baseline = nanmedian(baseline);
    
    spikes = clusters{spikes_cluster_idx};
    dff1 = (spikes - baseline)/baseline;
    dff = dff1;
    dff(dff < dff_thresh) = NaN;
    rasterSpikeTime = find(~isnan(dff));
        
    baseline_cluster = clusters{baseline_cluster_idx};
    
    baseline_dff = (baseline_cluster - baseline)/baseline;
    baseline_dff_mean = nanmean(baseline_dff);
    
    std_baseline_dff = getLocalSTD(baseline_dff , 100);
    
    dff_snr = (dff1) / std_baseline_dff ;
    
%     figure;
%     plot(dff_snr)
    
    
end

