function cropIndividualROIs(I,ROI,folder2save,imageName)
    for nRoi = 1:size(ROI,1)
        imgCropped = imcrop(I,[ROI(nRoi,[1,3]),ROI(nRoi,2)-ROI(nRoi,1),ROI(nRoi,4)-ROI(nRoi,3)]);
        folderRoi = fullfile(folder2save,['ROI_' num2str(nRoi)]);
        mkdir(folderRoi)
        imwrite (imgCropped, fullfile(folderRoi,imageName))
    end
end