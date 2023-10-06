function directoryROIs = selectIndividualROIs(bigImgPath)
    ROItoSelect = 'Yes';
    while strcmp(ROItoSelect,'Yes')
        [directoryROIs,ROI]=splitImagesInROIs(bigImgPath);
        cropNow = questdlg('Do you to crop the big image now?', '','Yes','No, I will do it later','Yes');
        if strcmp(cropNow,'Yes')
            parfor nROI = 1:size(ROI,1)
                cropAndSaveStackTif(bigImgPath,ROI(nROI,:),directoryROIs,nROI);
            end
        end
        ROItoSelect = questdlg('Do you want to select more ROIs', '','Yes','No, exit selection','Yes');    
    end
end