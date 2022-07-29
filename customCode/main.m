clear all
close all
warning 'off'
%1. Split original images in individual wells per genotype
addpath(genpath('src'))

splitOrSelectDir = questdlg('Do you want to split original images into individual wells', '','Yes','No, select individual wells directory','Yes');

if strcmp(splitOrSelectDir,'Yes')
    directoryROIs=splitImagesInROIs;
else
    directoryROIs = uigetdir('..','Choose directory of ROIs of a specific phenotype');
end

%2. Check bouts of individual 
countBoutsPerHour(directoryROIs)