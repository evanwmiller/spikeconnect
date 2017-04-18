function [groupSttc, fileSttcs] = calcsttc(groupA, groupB, dt, nFrameArr)
% CALCSTTC Calculates the spike time tiling coefficient between spike
% trains groups a and b. 
% See http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4205553/.
%   Input:
%       groupA: group of spike trains (array of frame numbers with spikes)
%       groupB: group of other spike train
%       dt: window size (delta t) from STTC paper
%       nFrameArr: total number of frames in each movie
%   Output:
%       groupSttc: spike time tiling coefficient for group
%       fileSttcs: STTCs for each individual file
%   [groupSttc, fileSttcs] = calcsttc(groupA, groupB, dt, nFrameArr)
[Pb , Ta , PbArr , TaArr] = calcparams(groupA , groupB , dt , nFrameArr);
[Pa , Tb , PaArr , TbArr] = calcparams(groupB , groupA , dt , nFrameArr);

groupSttc = 0.5 * ((Pa - Tb)/(1 - Pa*Tb) + (Pb - Ta)/(1 - Pb*Ta));

fileSttcs = zeros(size(PbArr));
for iFile = 1:numel(fileSttcs)
    Pa = PaArr(iFile);
    Ta = TaArr(iFile);
    Pb = PbArr(iFile);
    Tb = TbArr(iFile);
    fileSttcs(iFile) = 0.5 * ((Pa - Tb)/(1 - Pa*Tb) + (Pb - Ta)/(1 - Pb*Ta));
end
end

function [Pb,Ta,PbArr,TaArr] = calcparams(groupA, groupB, dt, nFrameArr)
% CALCPARAMS Calculates Pb, the proportion of spikes of B within window of
% A, and Ta, the proportion of frames covered by windows of A spikes, for
% both the group and each individual file in the group.
nFile = numel(groupA);
PbArr = zeros(1,nFile);
TaArr = zeros(1,nFile);
frameInA = 0;
totalFrame = 0;
bInA = 0;
totalB = 0;
for iFile = 1:nFile
    nFrame = nFrameArr{iFile};
    a = groupA{iFile}; 
    b = groupB{iFile};
    [iFrameInA, iBInA, iTotalB] = calccounts(a, b, dt, nFrame);
    PbArr(iFile) = iBInA/iTotalB;
    TaArr(iFile) = iFrameInA/nFrame;
    
    % update group counts
    frameInA = frameInA + iFrameInA;
    totalFrame = totalFrame + nFrame;
    bInA = bInA + iBInA;
    totalB = totalB + iTotalB;
end
Pb = bInA/totalB;
Ta = frameInA/totalFrame;
end

function [frameInA, bInA, totalB] = calccounts(a, b, dt, nFrame)
% CALCCOUNTS Returns the following for spike train A and B:
%   frameInA: number of frames +-dt from a spike in A
%   bInA: number of spikes in B +- dt from a spike in A
%   totalB: total number of spikes in B;

%cell array of 1x2 of [leftFrame, rightFrame]
aFramesWithinLag = cell(1,numel(a));

%use map to record b's spikes within a to avoid double counting
bSpikesWithinA = containers.Map('KeyType' , 'int32' , 'ValueType' , 'int32');

for i = 1:numel(a)
    aSpike = a(i);
    
    leftBound = aSpike - dt;
    if leftBound < 0; leftBound = 0; end
    
    rightBound = aSpike + dt;
    if rightBound > nFrame; rightBound = nFrame; end
    
    bSpikesInRange = b(b >= leftBound & b <= rightBound);
    aFramesWithinLag{i} = [leftBound, rightBound];
    
    for j = 1:numel(bSpikesInRange)
        bSpikesWithinA(bSpikesInRange(j)) = 1;
    end
end
frameInA = calcnumframes(aFramesWithinLag);
bInA = double(bSpikesWithinA.Count);
totalB = numel(b);
end

function numFramesWithinA = calcnumframes(aFramesWithinLag)
% CALCNUMFRAMES Calculates the number of frames contained within the set of
% ranges specified by aFramesWithinLag. Assumes that both the left and
% right frame numbers are monotonically increasing throughout the sequence.
    prevRightBound = 0;
    numFramesWithinA = 0;
    for i = 1:numel(aFramesWithinLag)
        window = aFramesWithinLag{i};
        if window(1) <= prevRightBound
            window(1) = prevRightBound+1;
        end
        numFramesWithinA = numFramesWithinA+window(2)-window(1)+1;
        prevRightBound = window(2);
    end
end
