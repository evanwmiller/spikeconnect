function aucwholetrace(dirToProcess)
%AUCWHOLETRACE Calculates the area under the dF/F trace for each of the
%ROIs in dirToProcess with the following filtering steps.
%   1. Subtract the background median from entire trace.
%   2. Calculate area under filtered curve using trapezoidal method.

if nargin < 1; dirToProcess = uigetdir(); end;
if dirToProcess == 0; return; end;
spikeFileNames = recursdir(dirToProcess, '^spikes-.*.mat$');

for iFile = 1:numel(spikeFileNames)
    % spikeFile handle
    sf = load(spikeFileNames{iFile});
    cutOffFreq = 50/(sf.frameRate/2);
    traceLength = numel(sf.roiTraces{1});
    
    for iRoi = 1:numel(sf.spikeDataArray)
        figure;
        % filter trace and set first 30 frames to average (filter makes the
        % values very high)
        trace = sf.roiTraces{iRoi};
%         filterTrace = filter(b,a,trace);
%         filterTrace(1:30) = mean(filterTrace(30:end));
        filterTrace = trace;
       
        %calculate dF/F and remove negative values
        clusters = sf.spikeDataArray{iRoi}.clusters;
        baseline = clusters{sf.spikeDataArray{iRoi}.baselineClusterIndex};
        baselineMedian = nanmedian(baseline);
        dff = (trace-baselineMedian)/baselineMedian;
        dff(dff<0.007) = 0;
        
        %plot trace
        subplot(2,1,1);
        plot(trace);
        
        %plot dff with area filled in
        subplot(2,1,2);
        area(1:traceLength, dff,'FaceColor','b');
        
        %calculate integral
        auc = trapz(1:traceLength, dff(1:traceLength));
        disp([spikeFileNames{iFile} 'ROI ' num2str(iRoi) num2str(auc)]);
    end
end


