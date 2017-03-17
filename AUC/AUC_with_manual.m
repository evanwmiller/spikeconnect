%% initiate

% Uncomment this for selecting new file
clear all
[fname, fpath] = uigetfile('*.mat' , 'Select a .mat file containing the traces and spikes');
load([fpath fname])



clc
close all

fc = 50;
fs = 500;

traceIdx = 6;
traceLength = 5000;

[b,a] = butter(6,fc/(fs/2));

w  = gausswin(15);


trace = ROI_traces{traceIdx};

%% apply filter and plot
dataIn = trace';
dataOut = filter(b,a,dataIn);
dataOutGauss = filter(w, 1, dataIn);

avgDataIn = mean(dataIn);
avgDataOut = mean(dataOut);
% dataIn(1:30) = avgDataIn;
dataOut(1:30) = avgDataOut;
dataOutGauss(1:30) = mean(dataOutGauss);
t = rasterSpikeTimes{traceIdx};
% figure('units','normalized','outerposition',[0.1 0.3 0.8 0.6]);
% subplot(3,1,1)
% plot(dataIn)
% title('Raw ROI mean trace')
% 
% subplot(3,1,2)
% h1 =plot(dataOut);
% title('Low pass filtered ROI trace')
% 
% 
% subplot(3,1,3)
% plot(dataOutGauss)
% title('Gaussian')

% hold on
% 
% 
% for ll = 1:numel(t)
%     line([t(ll)  t(ll)] , get(get(h1,'parent'),'YLim') , 'Color' , 'R')
% end
% line([traceLength traceLength] , get(get(h1,'parent'),'YLim') , 'Color' , 'w');
% line([1 1] , get(get(h1,'parent'),'YLim') , 'Color' , 'w');
% 
% hold off

%% Get dff whole trace; iterate each PDS in dff trace, print the AUC

ROI_trace = traceFlattener(dataOut' , 1);
curr_clusters = clusters{traceIdx};

baseline = curr_clusters{baseline_cluster_idx{traceIdx}};
spikes = curr_clusters{spikes_cluster_idx{traceIdx}};


baseline_med = nanmedian(baseline);
baseline_med = baseline_med + 2*nanstd(baseline);
baseline_min = min(baseline);

dff_min = (ROI_trace - baseline_min)./baseline_min;
dff_med = (ROI_trace - baseline_med)./baseline_med;
dff_med(dff_med < 0) = 0;

disp([' AUC of the whole trace = '  num2str(trapz(dff_med))]);%  AUC of whole trace
disp('------------------------------------------');
disp('Automatic Boundary Detection:')
f = figure('units','normalized','outerposition',[0.1 0.3 0.8 0.6]);
subplot(2,1,1)
plot(ROI_trace)
title('Raw ROI mean trace');
n = numel(t);
t = [t 5000];
if n>1
    
    for ss = 1:numel(t)-1
%         figure(f)
        pause(0.02)
        subplot(2,1,2)
        h = plot(dff_med);
        title('dff trace')

        hold on


        for ll = 1:numel(t)
            line([t(ll)  t(ll)] , get(get(h,'parent'),'YLim')  , 'Color' , 'R')
        end
        line([traceLength traceLength] , get(get(h,'parent'),'YLim') , 'Color' , 'w');
        line([1 1] , get(get(h,'parent'),'YLim') , 'Color' , 'w');
        area(t(ss):t(ss+1) , dff_med(t(ss):t(ss+1)));
        disp(['Area Under Curve from ' num2str(t(ss)) ' to '...
            num2str(t(ss+1)) ' = ' num2str(trapz(t(ss):t(ss+1) ,...
            dff_med(t(ss):t(ss+1)))) ] )
        hold off
       
      
        
        subplot(2,1,1)
        set(gca,'Color',rand(1,3));
    end
end




% plot(baseline)
% hold on 
% line([1 traceLength] , [baseline_med baseline_med] , 'Color' , 'R')
% line([1 traceLength] , [baseline_min baseline_min] , 'Color' , 'G')
% hold off
% 
% subplot(3,1,3)
% plot(dff_min)
% % 

%% Manual AUC
disp('------------------------------------------');
disp('Manual Boundary Selection:');
figure('units','normalized','outerposition',[0.1 0.5 0.8 0.3]);
hax = plot(dff_med);
hold on
while 1
    title('Select the lower bound')
    [x1,~] = ginput(1);
    x1 = floor(x1);
    line([x1 x1],get(get(hax,'parent'),'YLim') , 'Color' , 'R')
    title('Select the upper bound')
    [x2,~] = ginput(1);
    x2= floor(x2);
    line([x2 x2],get(get(hax,'parent'),'YLim') , 'Color' , 'R')
    
    area(x1:x2 , dff_med(x1:x2))
    disp(['Area under curve from ' num2str(x1) ' to ' num2str(x2) ' = ' ...
        num2str(trapz(x1:x2 , dff_med(x1:x2)))]);
end


