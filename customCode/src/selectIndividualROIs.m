function directoryROIs = selectIndividualROIs(bigImgPath)
    ROItoSelect = 'Yes';
    while strcmp(ROItoSelect,'Yes')
        [directoryROIs,ROI]=splitImagesInROIs(bigImgPath);
        cropNow = questdlg('Is big raw image fully acquired?','','Yes, crop selected ROIs','No, I will do it later','Yes, crop selected ROIs');
        if strcmp(cropNow,'Yes, crop selected ROIs')
            parfor nROI = 1:size(ROI,1)
                cropAndSaveStackTif(bigImgPath,ROI(nROI,:),directoryROIs,nROI);
            end
        end
        ROItoSelect = questdlg('Do you want to select more ROIs', '','Yes','No, exit selection','Yes');    
    end
end