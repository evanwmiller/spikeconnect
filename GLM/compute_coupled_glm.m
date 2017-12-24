function [t, couplingFilters] = compute_coupled_glm(binarySpike, frameRate)
% COMPUTE_COUPLED_GLM Uses GLMspiketools to find the coupling filters
% between neurons. Sets the Stim to 0 since there is no stimulus.
%   
% Input: spikeTimes is cell array with spikeTimes{i} is the frame numbers
% of spikes from neuron i.
%
% Returns a cell array where filter{i,j} is the coupling filter from neuron
% i to neuron j.

numCells = numel(binarySpike);
numFrames = numel(binarySpike{1});
dtStim = 1/frameRate;
dtSp = dtStim;
nkt = 20;
Stim = zeros(numFrames, 1);

% Use makeSimStruct_GLM to get default parameters.
ggsim = makeSimStruct_GLM(nkt, dtStim, dtSp);
[ktbas, ktbasis] = makeBasis_StimKernel(ggsim.ktbasprs, nkt);
[iht, ihbas, ihbasis] = makeBasis_PostSpike(ggsim.ihbasprs, dtSp);

% Initial fitting parameters
gg0 = makeFittingStruct_GLM(dtStim, dtSp);
gg0.ktbas = ktbas;
gg0.ihbas = ihbas;
gg0.ihbas2 = ihbas;
nktbasis = size(ktbas,2);
nhbasis = size(ihbas, 2);
gg0.kt = zeros(10,1);
gg0.k = gg0.ktbas*gg0.kt;
gg0.ihw = zeros(nhbasis, 1);
gg0.iht = iht;
gg0.dc = 0;

opts = {'display', 'iter', 'maxiter', 100};

% For each cell, copy the initial gg0, then set coupled nums and the
% sps/sps2.
couplingFilters = cell(numCells, numCells);

for i = 1:numCells
    gg = gg0;
    gg.couplednums = [1:i-1 i+1:numCells];
    gg.ihw2 = zeros(nhbasis, numCells-1);
    gg.ih = [gg.ihbas*gg.ihw gg.ihbas2*gg.ihw2];
    gg.sps = binarySpike{i};
    gg.sps2 = [binarySpike{gg.couplednums}];
    [gg1, neglogli1] = MLfit_GLM(gg, Stim, opts);
    
    couplingFilters{i,i} = gg1.ih(:,1);
    for j = 1:numel(gg.couplednums)
        couplingFilters{gg.couplednums(j), i} = gg1.ih(:, j+1);
    end
    gg1.dc
end

t = gg1.iht;
end

