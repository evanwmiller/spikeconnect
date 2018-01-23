function [groupSttcArr, fileSttcArrs] = calcsttcarr(spikeFileGroup, sttcMaxLagMs)
%CALCSTTCARR Given a spikeFileGroup, calculates the pairwise spike time
%tiling coefficient (sttc) using CALCSTTC. Returns the sttc array for the
%group as well as for each individual file in the group.
%   The bottom left triangle is set to be NaN.
%   STTCs with non-firing cells are also NaN.
%
%   Inputs:
%       spikeFileGroup: cell array of spike files w/ same ROI and framerate
%       sttcMaxLagMs: range to use for window when calculating sttc (in ms)
%   Outputs:
%       groupSttcArr: STTC array for group, combining counts in calcsttc.m
%       fileSttcArrs: STTC array for each individual file in group
%   [groupSttcArr, fileSttcArrs] = calcsttcarr(spikeFileGroup, sttcMaxLagMs)

% Copyright 2017, The Miller Lab, UC Berkeley
% Author: Patrick Zhang

[timesArr, nFrameArr, maxLagFrame] = combine(spikeFileGroup, sttcMaxLagMs);
nRoi = numel(timesArr);
%initialize each sttc array to nRoi x nRoi array of NaN
groupSttcArr = nan(nRoi, nRoi);
fileSttcArrs = cell(1,numel(spikeFileGroup));
for i = 1:numel(spikeFileGroup)
    fileSttcArrs{i} = groupSttcArr;
end

for iRoi = 1:nRoi
    r1 = timesArr{iRoi};
    for jRoi = iRoi:nRoi
        r2 = timesArr{jRoi};
        [groupSttc, fileSttcs] = calcsttc(r1, r2 , maxLagFrame, nFrameArr);
        %Set negative values to 0.
        if groupSttc < 0; groupSttc = 0; end;
        fileSttcs(fileSttcs < 0) = 0;
        %Set sttc in appropriate sttcArr
        groupSttcArr(iRoi, jRoi) = groupSttc; 
        for iSttc = 1:numel(fileSttcs)
            fileSttcArrs{iSttc}(iRoi, jRoi) = fileSttcs(iSttc);
        end
    end
end

function [timesArr, nFrameArr, maxLagFrame] = combine(spikeFileGroup, sttcMaxLagMs)
% COMBINE Groups the rasterSpikeTimes from each of the files in
% spikeFileGroup. Returns the following:
%   times: 1 x nRoi cell array, each cell contains another
%       cell array with the raster spike times of each spikeFile
%   numFrames: 1 x nRoi array, each entry is the number of frames for that
%       spikeFile.
for iSpikeFile = 1:numel(spikeFileGroup)
    spikeFile = spikeFileGroup{iSpikeFile};
    load(spikeFile,'spikeDataArray','frameRate');

    nFrameArr{iSpikeFile} = numel(spikeDataArray{1}.dffs);
    maxLagFrame = round(sttcMaxLagMs / 1000 * frameRate,0);
    nRoi = length(spikeDataArray);
    for iRoi = 1:nRoi
        timesArr{iRoi}{iSpikeFile} = spikeDataArray{iRoi}.rasterSpikeTimes;
    end
end
    

