clear all
close all
warning 'off'

%1. Split original images in individual wells per genotype
addpath(genpath('src'))

splitOrSelectDir = questdlg('Do you want to split original images into individual wells', '','Yes','No, select individual wells directory','Yes');

if strcmp(splitOrSelectDir,'Yes')
    [fileName, filePath] = uigetfile('*.tif', 'Select template file to CHOOSE or LOAD the ROIs per genotype');
    bigImagePath = fullfile(filePath,fileName);
    
    directoryROIs=selectIndividualROIs(bigImagePath);
    %1.1 Transform individual ROI images in image sequence
    %groupIndividualImages(directoryROIs)
else
    directoryROIs{1} = uigetdir('..','Choose directory of ROIs of a specific phenotype');
end

% groupIndividualImages(directoryROIs)

%2. Check bouts of individual larvae
countBouts = questdlg('Do you want to count the bouts per ROI?', '','Yes','No','Yes');

if strcmp(countBouts, 'Yes')
    for nDir = 1:size(directoryROIs,1)
        countBoutsPerHour(directoryROIs{nDir})
    end
end