function countBoutsPerHour(directoryROIs)
    
    thresholdDiffPixelsValue = 10;
    maxLarvaArea = 200; %no larva area larger than 200 pixels
    minLarvaArea = 10; %do not consider blobs smaller than 10 pixels (could happen when larvae are near the border)
    numberOfPixelsThreshold = 5; %only pixel value difference larger than XXX considered for larvae detection
    pixels2CheckFromCentroid=45; %look for in a radius of XXX for the larvae, to avoid some external artifacts
    nImagesPerHour=600;

    folderROIdir = dir(fullfile(directoryROIs,'**','ROI_*.tif'));

    parfor nROIFolders = 1:size(folderROIdir,1)
        pathROI_tif = fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name);
        warning('off')   
        disp(['Running analysis: ' pathROI_tif])
        %if ~exist(fullfile(dirROI,'boutsData','boutsPerHour.mat'),'file')
          saveLarvaMovement(pathROI_tif,thresholdDiffPixelsValue,numberOfPixelsThreshold,minLarvaArea,maxLarvaArea,pixels2CheckFromCentroid,nImagesPerHour);
        %end
    end
end