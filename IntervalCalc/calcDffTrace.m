function trace = calcDffTrace(bkgSubtractedTraces)
%CALCDFFTRACE
%   Calculates dff if not in spikeDataArray file when using intervalcalc

    nTrace = numel(bkgSubtractedTraces);
    diffFeatures = cell(1, nTrace);
    trace = {};
    for iTrace = 1:nTrace
        diffFeatures{iTrace} = slidingwindowflattener(...
                bkgSubtractedTraces{iTrace} , 50);
        results = dffCalc(diffFeatures{iTrace}, bkgSubtractedTraces{iTrace}, 3);
        trace{iTrace} = results;
    end

