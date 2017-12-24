% ANALYZE_SPIKES_FILE Prompts user to select a spikes file. Then, computes
% and plots the coupling filters.

[filename, pathname] = uigetfile('*.mat', 'Pick a spikes- file');
if ~startsWith(filename, 'spikes-')
    error('Must select a spikes- file');
end

spikes = load([pathname filename]);

% extract spike times
numFrames = numel(spikes.bkgSubtractedTraces{1});
numCells = numel(spikes.spikeDataArray);

for i = 1:numCells
    binarySpike{i} = zeros(numFrames, 1);
    binarySpike{i}(spikes.spikeDataArray{i}.rasterSpikeTimes) = 1;
end

[t, couplingFilters] = compute_coupled_glm(binarySpike, spikes.frameRate);
plot_coupling_filters(t, couplingFilters);


