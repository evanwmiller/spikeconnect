function sttc = calcsttc(a, b, dt, nFrame)
% CALCSTTC Calculates the spike time tiling coefficient between spike
% trains a and b. See http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4205553/.
%   Input:
%       a: spike train (cell array of frame numbers with spikes)
%       b: other spike train (cell array of frame numbers with spikes)
%       dt: window size (delta t) from STTC paper
%       nFrame: total number of frames in the movie
%   Output:
%       sttc: spike time tiling coefficient
%   sttc = calcsttc(a, b, dt, nFrame)
[~ , ~ , Pb , Ta] = calcparams(a , b , dt , nFrame);
[~ , ~ , Pa , Tb] = calcparams(b , a , dt , nFrame);

sttc = 0.5 * ((Pa - Tb)/(1 - Pa*Tb) + (Pb - Ta)/(1 - Pb*Ta));
end

function [hist, lags, Pb, Ta] = calcparams(a, b, dt, nFrame)
% CALCPARAMS Used by CALCSTTC to calculate Ta,Tb,Pa, and Pb.
% Outputs:
%   Ta: Proportion of frames within +-dt of spike of A
%   Pb: Proportion of spikes of B within +-dt of spike from A
%   hist/lags: count of spikes at a particular lag/dt

lags = -dt : dt; 
hist = zeros(1 , 2*dt + 1);

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
    
    bSpikesInRange = b( b >= leftBound & b <= rightBound);
    aFramesWithinLag{i} = [leftBound, rightBound];
    
    for j = 1:numel(bSpikesInRange)
        bSpikesWithinA(bSpikesInRange(j)) = 1;
        lag = bSpikesInRange(j) - aSpike;
        hist(lag2idx(lag , dt)) = hist(lag2idx(lag , dt)) + 1;
    end
end
numFramesWithinA = calcnumframes(aFramesWithinLag);
Ta = double(numFramesWithinA/nFrame);
Pb = double(bSpikesWithinA.Count)/numel(b);
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

function idx = lag2idx(lag , maxLag)
% LAG2IDX right shifts value to be from range (-maxLag, maxLag) to range of
% (1, 2*maxLag + 1). 
    % e.g. for a maxlag of 3, lag of -3 is index 1, -2 is index 2, and 
    % lag of +3 is index 7.
    idx = maxLag + 1 + lag;
end
