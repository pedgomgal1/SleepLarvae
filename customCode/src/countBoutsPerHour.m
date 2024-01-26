function countBoutsPerHour(directoryROIs,rangeWellRadii,frameToStartLarvaSearching,thresholdDiffPixelsValue,maxLarvaArea,maxMajorAxisLength,...
            minLarvaArea,numberOfPixelsThreshold,pixels2CheckFromCentroid,nImagesPerHour)

    folderROIdir = dir(fullfile(directoryROIs,'**','ROI_*.tif'));

    parfor nROIFolders = 1:size(folderROIdir,1)
        pathROI_tif = fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name);
        warning('off')   
        disp(['Running analysis: ' pathROI_tif])
        if ~exist(fullfile(folderROIdir(nROIFolders).folder,'boutsData','boutsPerHour.mat'),'file')
            saveLarvaMovement(pathROI_tif,thresholdDiffPixelsValue,numberOfPixelsThreshold,minLarvaArea,maxLarvaArea,maxMajorAxisLength,pixels2CheckFromCentroid,nImagesPerHour,rangeWellRadii,frameToStartLarvaSearching);
        end
    end
end