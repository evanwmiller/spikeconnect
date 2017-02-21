function plotrois(spikeFile)
%PLOTROIS Creates a figure with the snap picture and ROI numbering.
figure;
load(spikeFile,'snapPath','textPos');

% try to find the labeled version if it exists
% if not, write the text to the picture (without circles for ROI)
[dir,snapName,ext] = fileparts(snapPath);
labeledSnapPath = [dir filesep 'label-' snapName '.png'];
if exist(labeledSnapPath, 'file')
    labeledImage = imread(labeledSnapPath,'png');
    imshow(labeledImage);
else
    snap = imread(snapPath);
    imshow(imadjust(snap));
    for i = 1:numel(textPos)
        text('position',textPos{i},...
            'fontsize',20 , ...
            'Color' , 'w' ,...
            'string', num2str(i));
    end
end
title(snapName);
