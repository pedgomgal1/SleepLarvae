function countBoutsPerHour(directoryROIs,globalFeatures)

    folderROIdir = dir(fullfile(directoryROIs,'**','ROI_*.tif'));

    parfor nROIFolders = 1:size(folderROIdir,1)
        pathROI_tif = fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name);
        warning('off')   
        disp(['Running analysis: ' pathROI_tif])
        try
            if ~exist(fullfile(folderROIdir(nROIFolders).folder,'boutsData','boutsPerHour.mat'),'file')
                saveLarvaMovement(pathROI_tif,globalFeatures);
            end
        catch
            disp(['ERROR.check individually ->' pathROI_tif])
        end
    end
end