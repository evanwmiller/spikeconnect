
clc
fc = 50; % cut off frequency for the low pass filter
fs = 500; % smpling frequency


traceLength = 5000;

[b,a] = butter(6,fc/(fs/2)); % create the butterworth filter

baseDir = 'F:\MillerLabData\Integral\Tau neurons\C1_1';
dirToProcess = uigetdir(baseDir);
spikeFileNames = recursdir([dirToProcess ''] , '^spikes-.*.mat$');

f = figure('units','normalized','outerposition',[0.1 0.3 0.8 0.6]);

for ff = 1:numel(spikeFileNames)
    load(spikeFileNames{ff})
    [pathstr,name,ext] = fileparts(spikeFileNames{ff}); 
    Areas = [];
    for rr = 1:numel(spikeDataArray)
        trace = roiTraces{rr}; 
        dataIn = trace';
        dataOut = filter(b,a,dataIn);

        avgDataIn = mean(dataIn);
        avgDataOut = mean(dataOut);
        % dataIn(1:30) = avgDataIn;
        dataOut(1:30) = avgDataOut;
        t = spikeDataArray{rr}.rasterSpikeTimes;

%         ROI_trace = traceFlattener(dataOut' , 1);
        ROI_trace = dataOut';
        curr_clusters = spikeDataArray{rr}.clusters;

        % get the baseline for calculating the deltaF/F
        baseline = curr_clusters{spikeDataArray{rr}.baselineClusterIndex}; 
        spikes = curr_clusters{spikeDataArray{rr}.spikesClusterIndex};


        baseline_med = nanmedian(baseline);
        baseline_min = min(baseline);

        dff_min = (ROI_trace - baseline_min)./baseline_min;
        dff_med = (ROI_trace - baseline_med)./baseline_med;

%         dff_med(dff_med < 0) = 0;

          hold off 
          subplot(2,1,1) 
          trace_med = trace - min(trace);
          plot(trace_med); 
          subplot(2,1,2) 
          dff_med(dff_med<0.007) = 0;

          h = plot(dff_med); hold on
          title([spikeFileNames{ff} '_ROI' num2str(rr)]);
          disp([spikeFileNames{ff} '....ROI(' num2str(rr) '):'])


          AUC  = trapz(1:traceLength , dff_med(1:traceLength));
          Areas = [Areas AUC];


          area(1:traceLength , dff_med(1:traceLength));

        pause(0.5);        


    end
    save([pathstr filesep 'AUC_MS_' name '.mat'] , 'Areas');
    disp(['Saving to ' pathstr filesep  'AUC_MS_' name '.mat']);
    hold off   
%   waitforbuttonpress;
end


