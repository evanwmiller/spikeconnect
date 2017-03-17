close all
clc

% Get the directory path
baseDir = '';
dirToProcess = uigetdir(baseDir);
stdFileNames = recursdir([dirToProcess ''] , '^spikes-.*.mat$');

%-----------------------Filter Parameters--------------------------
fc = 50; % Cutoff frequency
fs = 500; % Sampling frequency
%------------------------------------------------------------------

traceLength = 5000; % Sampling length

f1 = figure('units','normalized','outerposition',[0.1 0.6 0.8 0.3]);
f2 = figure('units','normalized','outerposition',[0.1 0.3 0.8 0.3]);

areas_of = containers.Map;
avg_of = containers.Map;

K = 1;

for ff = 1:numel(stdFileNames)
    disp(stdFileNames{ff});
    load(stdFileNames{ff});
    areas_all = {};
    areas_avg = {};
    [pathstr,name,ext] = fileparts(stdFileNames{ff}); 
    for rr = 1:numel(spikeDataArray)
        areas_ROI = [];
        t = spikeDataArray{rr}.rasterSpikeTimes;
        t = burstaggregator(t, 2); % rearming if needed
        [b,a] = butter(6,fc/(fs/2)); % Create a Butterworth low pass filter (gets rid of any frequency higher than fc)
        trace = roiTraces{rr}; 
        dataIn = trace';
        dataOut = filter(b,a,dataIn); % Apply the filter to the trace
        avgDataOut = mean(dataOut); % mean of the filtered trace
        
        figure(f1);
        plot(trace);
        dataOut(1:30) = avgDataOut; % The low-pass filter messes up the first few frames. Set the first 30 frames to the average.
        figure(f2);
        plot(dataOut-avgDataOut);
        
         SWFtrace = slidingwindowflattener(dataOut , 100); %Use sliding window filter to level the low-pass-filtered trace
         hold on
        
         h = plot(SWFtrace , 'r');
         pause(1)

         for i = 1:numel(t)
             line([t(i)-2  t(i)-2] , get(get(h,'parent'),'YLim')  , 'Color' , 'G')


             toNxt = find_next_ptn_idx_zero(SWFtrace(t(i)+5:end)) + t(i) + 5; %Find the next point that touches zero
             
             if isempty(toNxt)
                 toNxt = t(i);
             end
             if toNxt + 2 <= 5000
                line([toNxt+2  toNxt+2] , get(get(h,'parent'),'YLim')  , 'Color' , 'K')
                 area(t(i)-2:toNxt+2 , SWFtrace(t(i)-2:toNxt+2)); %Color the area under curve
                 areas_ROI = [areas_ROI trapz(t(i)-2:toNxt+2 , SWFtrace(t(i)-2:toNxt+2))]; %Calculate the area under curve
%              saveas(f2 , ['.\image3\' num2str(K) '.jpg']); % to save the plots   
             K = K+1;
             end
             
             pause(0.03)
         end
         areas_all{rr} = areas_ROI';
         areas_avg{rr} = mean(areas_ROI);
         hold off
%           waitforbuttonpress %uncomment if you want to wait on each ROI


         
    end
    save([pathstr filesep 'AUC_SS_' name '.mat'] , 'areas_all', 'areas_avg');
    disp(['Saving to ' pathstr filesep  'AUC_SS_' name '.mat']);
    areas_of(stdFileNames{ff}) = areas_all;
    avg_of(stdFileNames{ff}) = areas_avg;
end


% -------------------Export to Excel-------------------------------

Alphab = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

[xlsxFilename, xlsxPath] = uiputfile({'*.xlsx' ; '*.xls'} , 'Save as' , 'export.xlsx');

for i = 1:numel(stdFileNames)
    curr_f = areas_of(stdFileNames{i});
    curr_avg = avg_of(stdFileNames{i});
    disp(['saving data from ' stdFileNames{i}]);
    writetable(table({stdFileNames{i}}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , 'A1' , 'WriteVariableNames' , false);
    writetable(table({'Average:'}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , 'A3' , 'WriteVariableNames' , false);
    for j = 1:numel(curr_f)
        
        writetable(table({['ROI' num2str(j)]}) ,[xlsxPath xlsxFilename] ,'Sheet', i, 'Range' , [Alphab(j+1) '2'] , 'WriteVariableNames' , false);
        if numel(curr_f{j}) >0
            writetable(table(curr_avg{j}) , [xlsxPath xlsxFilename] , 'Sheet' , i , 'Range' ,  [Alphab(j+1) '3'], 'WriteVariableNames' , false);
            writetable(table(curr_f{j}) , [xlsxPath xlsxFilename] , 'Sheet' , i , 'Range' ,  [Alphab(j+1) '5'], 'WriteVariableNames' , false);
        end
    end
end

disp('Done!')





 
 