function groupIndividualImages(directoryROIs)
    
    folderROIdir = dir(fullfile(directoryROIs,'**','ROI_*'));    
    
    parfor nROIFolders = 1:size(folderROIdir,1)
         try 
            if isfolder(fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name))
                dirROI = fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name);
                allROIdir = dir(fullfile(dirROI,'Image_*'));
                
                nameImages={allROIdir.name};
                onlyNames=cellfun(@(x) strsplit(x,'_'),nameImages,'UniformOutput',false);
                numImages=cellfun(@(x) str2num(x{2}),onlyNames);
                [~,indx]=sort(numImages);
                orderROIDir = allROIdir(indx,:);
                fileName = fullfile(orderROIDir(1).folder,[folderROIdir(nROIFolders).name '.tif']);
                if ~exist(fileName,'file')
                        zSize = size(orderROIDir,1);
                        initImage = imread(fullfile(orderROIDir(1).folder,orderROIDir(1).name));
                        maskTotal = uint8(zeros(size(initImage,1),size(initImage,2),zSize));
                        
                        for nTempImg = 1:zSize
                           maskTotal(:,:,nTempImg) = imread(fullfile(orderROIDir(nTempImg).folder,orderROIDir(nTempImg).name));
                           imwrite(maskTotal(:,:,nTempImg) ,fileName, 'WriteMode' , 'append') ;                       
                        end
                        for nTempImg = 1:zSize
                            delete(fullfile(orderROIDir(nTempImg).folder,orderROIDir(nTempImg).name));
                        end
                end
            end
            
        catch
            disp(['Error: ' fullfile(folderROIdir(nROIFolders).folder,folderROIdir(nROIFolders).name)])
        end

    end
end