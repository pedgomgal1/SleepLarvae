function directoryROIs = selectIndividualROIs(bigImgPath,genotypes,cropNow,rangeWellRadii,wellPaddingROI,ROISelection)
    ROItoSelect = 'Yes';
    while strcmp(ROItoSelect,'Yes')
        [directoryROIs,allROIs]=splitImagesInROIs(bigImgPath,genotypes,rangeWellRadii,wellPaddingROI,ROISelection);
        if isempty(cropNow)
            cropNow = questdlg('Is the video fully acquired?','','Yes, crop selected ROIs','No, I will do it later','Yes, crop selected ROIs');
        end
        if strcmp(cropNow,'Yes, crop selected ROIs')

            dirBigStacks = dir([bigImgPath(1:end-5) '*']);
            for nGen = 1:size(allROIs,1) 
                folder2save = directoryROIs{nGen};
                ROIsGen = allROIs{nGen};
                for nStack = 1:size(dirBigStacks,1)
                    stackFilepath = fullfile(dirBigStacks(nStack).folder,dirBigStacks(nStack).name);
                    infoImage = imfinfo(stackFilepath);
                    for nZ = 1:size(infoImage,1)
                        loadedImage = imread(stackFilepath,nZ);
                        
                        if nStack==1 && nZ==1
                            folderRoi =cell(size(ROIsGen,1),1);
                            idROIsExist = false(size(ROIsGen,1),1);
                            for nRoi = 1:size(ROIsGen,1)
                                folderRoi{nRoi} = fullfile(folder2save,['ROI_' num2str(nRoi)]);
                                idROIsExist(nRoi) = exist(folderRoi{nRoi},'dir');
                            end
                            folderRoi(idROIsExist)=[];
                            ROIsGen(idROIsExist,:)=[];
                        end
                        if ~isempty(folderRoi)
                            parfor nRoi = 1:size(folderRoi,1)
                                if nZ ==1
                                    if ~exist(folderRoi{nRoi},'dir')
                                        mkdir(folderRoi{nRoi})
                                    end
                                end
                                ROI = ROIsGen(nRoi,:);
                                imgCropped = imcrop(loadedImage,[ROI(1),ROI(3),ROI(2)-ROI(1),ROI(4)-ROI(3)]);
                                [~,ROIname,~] = fileparts(folderRoi{nRoi}); 
                                imwrite(imgCropped ,fullfile(folderRoi{nRoi},[ROIname '.tif']), 'WriteMode' , 'append') ;
                            end
                        else 
                            break
                        end

                    end
                end
            end


            if length(genotypes) == 3
                
               break;
            else
                ROItoSelect = questdlg('Do you want to select more ROIs?', '','Yes','No, exit selection','Yes');   
            end

        else
            ROItoSelect = questdlg('Do you want to select more ROIs?', '','Yes','No, exit selection','Yes');    
        end
    end
end