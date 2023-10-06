function CropAndSaveStackTif(fileName,ROI,folderRoi,imageName)

    infoImage = imfinfo(fileName);
    folderRoi = fullfile(folder2save,['ROI_' num2str(nRoi)]);
    mkdir(folderRoi)
    for nZ = 1:size(infoImage,1)
        loadedImage = imread(fileName,nZ);
        imgCropped = imcrop(loadedImage,[ROI(1,3),ROI(2)-ROI(1),ROI(4)-ROI(3)]);
        imwrite(imgCropped ,fullfille(), 'WriteMode' , 'append') ;
    end
end