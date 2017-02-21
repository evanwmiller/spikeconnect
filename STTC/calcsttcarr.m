function sttcArr = calcsttcarr(spikeFile, sttcMaxLagMs)
%CALCSTTCARR Given a spikeDataArray, calculates the pairwise spike time
%tiling coefficient (sttc) using CALCSTTC. Returns as 2D array. 
%   The bottom left triangle is set to be 1.05 so that it will show up 
%   white in the heatmap.
%
%   Inputs:
%       spikeFile: string of spike data file (after thresholding)
%       sttcMaxLagMs: range to use for window when calculating sttc (in ms)
%   Outputs:
%       sttcArr: pairwise sttc for each of the rois in the movie
%   sttcArr = calcsttcarr(spikeDataArray, sttcMaxLagMs, nFrame)

% Copyright 2017, The Miller Lab, UC Berkeley
% Author: Patrick Zhang

load(spikeFile,'spikeDataArray','frameRate');

nRoi = length(spikeDataArray);
nFrame = numel(spikeDataArray{1}.dffs);
maxLagFrame = round(sttcMaxLagMs / 1000 * frameRate,0);
sttcArr = ones(nRoi, nRoi);
sttcArr = sttcArr * 1.05;
for iRoi = 1:nRoi
    r1 = spikeDataArray{iRoi}.rasterSpikeTimes;
    for jRoi = iRoi:nRoi
        r2 = spikeDataArray{jRoi}.rasterSpikeTimes;
        sttc = calcsttc(r1, r2 , maxLagFrame, nFrame);
        %Sets negative values to be 0.
        if sttc < 0; sttc = 0; end;
        sttcArr(iRoi, jRoi) = sttc;          
    end
end

