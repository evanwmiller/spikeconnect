function previewthreshold(spikeFilePaths, threshold, rearmFactor)
%PREVIEWTHRESHOLD Shows spike times compared to raw plots for the given set
%of files, dff snr threshold, and rearm factor.

roiCounts = 0;
axhandles = createpreviewfigure;
for iSpikeFile = 1:numel(spikeFilePaths)
    roiLabel = 1;
    load(spikeFilePaths{iSpikeFile} ,'spikeDataArray' ,'roiTraces' )
    fprintf('Movie %d: %s \n', iSpikeFile,spikeFilePaths{iSpikeFile});
    for i = 1:numel(spikeDataArray)
        roiCounts = roiCounts + 1;
        tmp = spikeDataArray{i}.dffSnr;
        tmp(tmp < threshold) = NaN;
        spikeDataArray{i}.rasterSpikeTimes = find(~isnan(tmp));
        spikeDataArray{i}.rasterSpikeTimes = ...
            burstaggregator(spikeDataArray{i}.rasterSpikeTimes, rearmFactor);
        
        %plot in groups of 3 by 3
        if mod(roiCounts , 9) ~= 0
            axes(axhandles{mod(roiCounts , 9)}('trace'))
            plot(roiTraces{i})
            traceLength = numel(roiTraces{i});
            
            axes(axhandles{mod(roiCounts , 9)}('spikes'))
            t = spikeDataArray{i}.rasterSpikeTimes;
            for ll = 1:numel(t)
                line([t(ll)  t(ll)] , [0.0  1.0] , 'Color' , 'k')
            end
            line([traceLength traceLength] , [0.0 1.0] , 'Color' , 'w');
            line([1 1] , [0.0 1.0] , 'Color' , 'w');
            title(sprintf('Movie %d ROI %d', iSpikeFile, roiLabel));
            roiLabel = roiLabel + 1;
            
        else
            axes(axhandles{9}('trace'));
            plot(roiTraces{i})
            
            axes(axhandles{9}('spikes'));
            t = spikeDataArray{i}.rasterSpikeTimes;
            for ll = 1:numel(t)
                line([t(ll)  t(ll)] , [0.0  1.0] , 'Color' , 'k')
            end
            line([traceLength traceLength] , [0.0 1.0] , 'Color' , 'w');
            line([1 1] , [0.0 1.0] , 'Color' , 'w');
            title(sprintf('Movie %d ROI %d', iSpikeFile, roiLabel));
            roiLabel = roiLabel + 1;
            axhandles = createpreviewfigure;
        end
    end    

end
end

