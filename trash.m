close all
clear all

baseDir = uigetdir('' , 'Select a folder');
matFileNames = recursdir(baseDir , 'std.*\.mat');
figTitles = strrep(matFileNames , baseDir , '');
matFileNames = strrep(matFileNames , '\' , '\\');
figTitles = strrep(figTitles , '\' , '\\');
