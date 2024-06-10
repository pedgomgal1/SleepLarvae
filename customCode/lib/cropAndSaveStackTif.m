function cropAndSaveStackTif(fileName,ROI,folder2save,nRoi)

    dirBigStacks = dir([fileName(1:end-5) '*']);
    for nStack = 1:size(dirBigStacks,1)
        stackFilepath = fullfile(dirBigStacks(nStack).folder,dirBigStacks(nStack).name);
        infoImage = imfinfo(stackFilepath);
        folderRoi = fullfile(folder2save,['ROI_' num2str(nRoi)]);
        mkdir(folderRoi)
        for nZ = 1:size(infoImage,1)
            loadedImage = imread(stackFilepath,nZ);
            imgCropped = imcrop(loadedImage,[ROI(1),ROI(3),ROI(2)-ROI(1),ROI(4)-ROI(3)]);
            imwrite(imgCropped ,fullfile(folderRoi,['ROI_' num2str(nRoi) '.tif']), 'WriteMode' , 'append') ;
        end
    end
end