function raster_plot( rasterSpikeTimes , vidLength , plot_title)
% rasterSpikeTime: a cell array. each cell contains the spike times of one ROI/neuron
% vidLength: length of the experiment video
% plot_title: raster plot title
% Copyright 2016 The Miller Lab, UC Berkeley
% Author: Kaveh Karbasi
    figure;
   
    ntrials = numel(rasterSpikeTimes); % number of trials
    for jj = 1:ntrials
        t       = rasterSpikeTimes{jj}; % Spike timings in the jjth trial
        nspikes   = numel(t); % number of elemebts / spikes
        for ii = 1:nspikes % for every spike
          line([t(ii) t(ii)],[jj-0.5 jj+0.5],'Color','k'); 
          % draw a black vertical line of length 1 at time t (x) and at trial jj (y)
        end
    end
    line([vidLength vidLength],[jj-0.5 jj+0.5],'Color','w');  
    xlabel('Time');
    ylabel('ROI number');
    set(gca,'ytick', 1:ntrials); 
    title(plot_title)

end
