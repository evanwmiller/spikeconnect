function result = causalityanalysis(spikeCellA, spikeCellB, minL, maxL, minOL, maxOL)
%CAUSALITY ANALYSIS
%   Detailed explanation goes here

ATimes = spikeCellA.rasterSpikeTimes;
BTimes = spikeCellB.rasterSpikeTimes;
k0 = 0;
kT = 0;

for k = 1:numel(ATimes)
    for i = 1:numel(BTimes)
        if i - k >= minOL && i - k <= maxOL
            k0 = k0 + 1;
        end
    end
end

for k = 1:numel(ATimes)
    for i = 1:numel(BTimes)
        if i - k >= minL && i - k <= maxL
            kT = kT + 1;
        end
    end
end

total = 0;

for i = kT
    result = k0^i / factorial(i);
    total = total + result;
end

result = e^(-k0) * total;

end
