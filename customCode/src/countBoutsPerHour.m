function countBoutsPerHour(directoryROIs)
    
    thresholdDiffPixelsValue = 10;
    maxLarvaArea = 200; %no larva area larger than 200 pixels
    minLarvaArea = 15;
    numberOfPixelsThreshold = 5;
    pixels2CheckFromCentroid=45;
    nImagesPerHour=600;

    folderROIdir = dir(fullfile(directoryROIs,'**','ROI_*.tif'));

    parfor nROIFolders = 1:size(folderROIdir,1)
        pathROI_tif = fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name);
           
        disp(['Running analysis: ' pathROI_tif])
        %if ~exist(fullfile(dirROI,'boutsData','boutsPerHour.mat'),'file')
          saveLarvaMovement(pathROI_tif,thresholdDiffPixelsValue,numberOfPixelsThreshold,minLarvaArea,maxLarvaArea,pixels2CheckFromCentroid,nImagesPerHour);
        %end
    end
end