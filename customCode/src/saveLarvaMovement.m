function saveLarvaMovement(allROIdir,thresholdDiffPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,nImagesPerHour)
%            try
                nameImages={allROIdir.name};
                onlyNames=cellfun(@(x) strsplit(x,'_'),nameImages,'UniformOutput',false);
                numImages=cellfun(@(x) str2num(x{2}),onlyNames);
                [~,indx]=sort(numImages);
                orderROIDir = allROIdir(indx,:);
                
                imageBackground=detectBackground(orderROIDir(1:nImagesPerHour,:));
                
                larva1 = abs(imageBackground-imread(fullfile(orderROIDir(1).folder,orderROIDir(1).name)))>thresholdDiffPixelsValue;
                larva2 = abs(imageBackground-imread(fullfile(orderROIDir(2).folder,orderROIDir(2).name)))>thresholdDiffPixelsValue;
                labelLarva = bwlabel(larva1);
                labels=labelLarva(abs(larva2-larva1)>0);
                larvaFilt = (labelLarva == mode(labels(labels>0)));
                centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));
        
                arrayBouts=[];
                arrayPixels=[];
                
                mkdir(fullfile(orderROIDir(1).folder,'binaryLarva'));
                mkdir(fullfile(orderROIDir(1).folder,'boutsData'));
                imwrite(larvaFilt,fullfile(orderROIDir(1).folder,'binaryLarva',[num2str(1) '.jpg']));
        
                cellBouts=cell(round(size(orderROIDir,1)/nImagesPerHour),4);
                counterNan=0;
                while counterNan<100
                    for nTempImg = 1:size(orderROIDir,1)-1
                        
                        img1=imread(fullfile(orderROIDir(nTempImg).folder,orderROIDir(nTempImg).name));
                        img2=imread(fullfile(orderROIDir(nTempImg+1).folder,orderROIDir(nTempImg+1).name));
            
            
                        %%update background just in case some changes appear
                        if mod(nTempImg,nImagesPerHour)==0 && (nTempImg+nImagesPerHour)<size(orderROIDir,1)
                                imageBackground=detectBackground(orderROIDir(nTempImg:nTempImg+nImagesPerHour,:));
                                larva1 = abs(imageBackground-img1)>thresholdDiffPixelsValue;
                                larvaFilt=bwareafilt(larva1,1);
                                centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));
                        end
            
                        try
                            if sum(centroid2Check)==0
                                centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));
                            end
                            [isMoving,difImage,nPixels,centroid2Check,larvaFilt] = isLarvaSleeping(img1,img2,imageBackground,thresholdDiffPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,centroid2Check,larvaFilt);
            
                            imwrite(larvaFilt,fullfile(orderROIDir(nTempImg).folder,'binaryLarva',[num2str(nTempImg+1) '_' num2str(nPixels) 'px.jpg']))
                        catch
                            try
                                if nTempImg>nImagesPerHour/2
                                    imageBackground=detectBackground(orderROIDir(nTempImg-round(nImagesPerHour/2):nTempImg+round(nImagesPerHour/2),:));
                                else
                                    imageBackground=detectBackground(orderROIDir(1:nTempImg+round(nImagesPerHour/2),:));
                                end
                                larva1 = abs(imageBackground-img1)>thresholdDiffPixelsValue;
                                larvaFilt=bwareafilt(larva1,1);
                                if sum(centroid2Check)==0
                                    centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));
                                end                                
                                [isMoving,difImage,nPixels,centroid2Check,larvaFilt] = isLarvaSleeping(img1,img2,imageBackground,thresholdDiffPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,centroid2Check,larvaFilt);
                                imwrite(larvaFilt,fullfile(orderROIDir(nTempImg).folder,'binaryLarva',[num2str(nTempImg+1) '_' num2str(nPixels) 'px.jpg']))
                            catch
                                isMoving=NaN;
                                nPixels=NaN;
                                counterNan=counterNan+1;
                                imwrite(ones(size(larvaFilt)),fullfile(orderROIDir(nTempImg).folder,'binaryLarva',[num2str(nTempImg+1) '_NaN.jpg']))
                                if counterNan==100
                                    disp(['Too many NaN in: ' allROIdir(1).folder])
                                    break;
                                end
                            end
                        end
%                         imgChange = img2;
%                         imgChange(difImage)=255;
%                         
%                         imshow([img1,img2,imageBackground,imgChange,uint8(larvaFilt).*255])
%                         title([strrep(orderROIDir(nTempImg+1).name,'_',' ') ' is moving? ' num2str(isMoving) ' , ' num2str(nPixels) ' pixels'])
%                         hold on
                        % close all
            
                        %Save bouts data per hour
                        arrayBouts(end+1)=isMoving;
                        arrayPixels(end+1)=nPixels;
                        if mod(nTempImg,nImagesPerHour)==0
                            nHour=round(nTempImg/nImagesPerHour);
                            cellBouts(nHour,1:4)={nHour,arrayBouts,arrayPixels,sum(isnan(arrayBouts))};
                            arrayBouts=[];
                            arrayPixels=[];
                            save(fullfile(orderROIDir(1).folder,'boutsData','boutsPerHour.mat'),'cellBouts')
                        end

                        if nTempImg==size(orderROIDir,1)-1
                            nHour=round(nTempImg/nImagesPerHour);
                            cellBouts(nHour,1:4)={nHour,arrayBouts,arrayPixels,sum(isnan(arrayBouts))};
                            cellBouts=cell2table(cellBouts,VariableNames={'hour','bouts','pixelsMove','numNaNs'});
                            
                            save(fullfile(orderROIDir(1).folder,'boutsData','boutsPerHour.mat'),'cellBouts')
                            disp([allROIdir(1).folder ' number of NaNs images: ' num2str(sum(cellBouts.numNaNs))])
                            counterNan=100;
                        end
            
                    end
                end
%             catch
%                     disp(['Error in: ' allROIdir(1).folder])
%             end
end
