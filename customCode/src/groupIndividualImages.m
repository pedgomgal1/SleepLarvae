function groupIndividualImages(directoryROIs)

folderROIdir = dir(fullfile(directoryROIs,'**','ROI_*'));



parfor nROIFolders = 1:size(folderROIdir,1)
    if isfolder(fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name))
        dirROI = fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name);
        allROIdir = dir(fullfile(dirROI,'Image_*'));
    
        nameImages={allROIdir.name};
        onlyNames=cellfun(@(x) strsplit(x,'_'),nameImages,'UniformOutput',false);
        numImages=cellfun(@(x) str2num(x{2}),onlyNames);
        [~,indx]=sort(numImages);
        orderROIDir = allROIdir(indx,:);
    
        zSize = size(orderROIDir,1);
        initImage = imread(fullfile(orderROIDir(1).folder,orderROIDir(1).name));
        maskTotal = uint8(zeros(size(initImage,1),size(initImage,2),zSize));
        fileName = fullfile(orderROIDir(1).folder,[folderROIdir(nROIFolders).name '.tif']);
        for nTempImg = 1:zSize
           maskTotal(:,:,nTempImg) = imread(fullfile(orderROIDir(nTempImg).folder,orderROIDir(nTempImg).name));
           imwrite(maskTotal(:,:,nTempImg) ,fileName, 'WriteMode' , 'append') ;
           
           delete(fullfile(orderROIDir(nTempImg).folder,orderROIDir(nTempImg).name));
        end
    end
end
