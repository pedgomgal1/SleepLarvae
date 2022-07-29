function countBoutsPerHour(directoryROIs)
    
    thresholdDiffPixelsValue = 10;
    numberOfPixelsThreshold = 5;
    pixels2CheckFromCentroid=45;
    nImagesPerHour=600;

    folderROIdir = dir(fullfile(directoryROIs,'ROI_*'));

   parfor nROIFolders = 1:size(folderROIdir,1)

        dirROI = fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name);
        allROIdir = dir(fullfile(dirROI,'Image_*'));

        disp(['Running analysis: ' folderROIdir(nROIFolders).name])
        if ~exist(fullfile(allROIdir(1).folder,'boutsData','boutsPerHour.mat'),'file')
            saveLarvaMovement(allROIdir,thresholdDiffPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,nImagesPerHour)
        end
    end

end