function plot_coupling_filters(t, couplingFilters)
%PLOT_COUPLING_FILTERS Plots coupling filters.
numCells = min(4,size(couplingFilters,1));
for drivingCell = 1:numCells
    for receivingCell = 1:numCells
        plotNum = (drivingCell-1) * numCells + receivingCell;
        subplot(numCells, numCells, plotNum);
        plot(t, couplingFilters{drivingCell, receivingCell});
    end
end
end

