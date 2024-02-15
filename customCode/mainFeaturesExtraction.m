clear all
close all
warning 'off'

%1. Split original images in individual wells per genotype
addpath(genpath('src'))
addpath(genpath('lib'))

rangeWellRadii = [75 85]; % [minRadius, maxRadius] of wells in pixels
wellPaddingROI = 3; % extra pixels circle radius
splitOrSelectDir = questdlg('Do you want to split original images into individual wells', '','Yes','No, select individual wells directory','Yes');

if strcmp(splitOrSelectDir,'Yes')
    [fileName, filePath] = uigetfile('*.tif', 'Select template file to CHOOSE or LOAD the ROIs per genotype');
    bigImagePath = fullfile(filePath,fileName);
    
    ROISelection=true;
    directoryROIs=selectIndividualROIs(bigImagePath,[],[],rangeWellRadii,wellPaddingROI,ROISelection);
    %1.1 Transform individual ROI images in image sequence
    %groupIndividualImages(directoryROIs)
else
    directoryROIs{1} = uigetdir('..','Choose directory of ROIs of a specific phenotype');
end

% groupIndividualImages(directoryROIs)

%2. Check bouts of individual larvae
countBouts = questdlg('Do you want to count the bouts per ROI?', '','Yes','No','Yes');

%% Parameters to count the larvae bouts
frameToStartLarvaSearching = 1000; %is challenging to detect the larvae in the initial frames. For this reason we developed and reverse tracking, from frame X until the initial one in order to ensure proper initial larva detection.
thresholdDiffPixelsValue = 15; % pixel value difference between substracted background and actual image to be considered different from background
maxLarvaArea = 200; %no larva area larger than 200 pixels
maxMajorAxisLength = 30; % no larvae longer than 30 pixels
minLarvaArea = 10; %do not consider blobs smaller than 10 pixels (could happen when larvae are near the border)
numberOfPixelsThreshold = 5; %Number of different pixels between segmented larva in frame n and n+1 to be considered a bout
pixels2CheckFromCentroid=45; %field of view from previous larva centroid for larva tracking. To avoid artifacts far from the larvae.
nImagesPerHour=600;
maxNan = 200; %number max of frames in which a larva cannot be tracked. If we overpass the threshold the experiment is discarded. 10 frames = 1 minute


if strcmp(countBouts, 'Yes')
    for nDir = 1:size(directoryROIs,1)
        countBoutsPerHour(directoryROIs{nDir},rangeWellRadii,wellPaddingROI,frameToStartLarvaSearching,thresholdDiffPixelsValue,maxLarvaArea,maxMajorAxisLength,...
            minLarvaArea,numberOfPixelsThreshold,pixels2CheckFromCentroid,nImagesPerHour,maxNan)
    end
end