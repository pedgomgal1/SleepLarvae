function saveLarvaMovement(fileName,globalFeatures)

        % Extract the folder path from the input file name
        [folderPath, ~, ~] = fileparts(fileName);
        
        % Get information about the input images (e.g size)
        infoImage = imfinfo(fileName);

        % Detect initial background to be subtracted
        imageBackground = detectBackground(fileName, 1:globalFeatures.nImagesPerHour);
        
        [centerROIs,radiiWells,metric] = imfindcircles(imageBackground,globalFeatures.rangeWellRadii,'Sensitivity',0.99);
        figure('Visible','off')
        imshow(imageBackground); hold on; viscircles(centerROIs(1,:), radiiWells(1),'EdgeColor','b');
        circ = drawcircle('Center',centerROIs(1,:),'Radius',radiiWells(1)+globalFeatures.wellPaddingROI);
        maskCircle = uint8(createMask(circ));
        close all;
        croppedBackGround = imageBackground.*maskCircle;


        %%Identify larva in the first frame after tracking larva movement
        %%From the end to the beggining of the experiment
        [centroid2Check, larvaFilt]=getInitialLarvaPosition(croppedBackGround,fileName,maskCircle,globalFeatures);

%         imshow([croppedBackGround,uint8(larvaFilt)*255,imread(fileName, 1).*maskCircle])
        % Initialize arrays to store tracking data
        arrayBouts = [];
        arrayPixels = [];
        
        % Create directories for storing results
        if exist(fullfile(folderPath,'binaryLarva'),'dir')
            rmdir(fullfile(folderPath,'binaryLarva'),'s');
            rmdir(fullfile(folderPath,'boutsData'),'s');
        end
        mkdir(fullfile(folderPath, 'binaryLarva'));
        mkdir(fullfile(folderPath, 'boutsData'));

        % Save the initial larva filter as an image
        imwrite(larvaFilt, fullfile(folderPath, 'binaryLarva', [num2str(1) '.jpg']));
        
        % Initialize a cell array to store tracking data per hour
        cellBouts = cell(round(size(infoImage, 1) / globalFeatures.nImagesPerHour), 4);
        counterNan = 0;

        %create binary stack
        binaryLarvaStack=zeros(size(larvaFilt,1),size(larvaFilt,2),size(infoImage,1));
        binaryMovTrackStack=binaryLarvaStack;
        
        binaryLarvaStack(:,:,1)=larvaFilt;
        if ~isempty(centroid2Check)
            binaryMovTrackStack(round(centroid2Check(2)),round(centroid2Check(1)),1)=1;
        end
        %%mark movement on binary image
        movBinaryMark=zeros(size(larvaFilt));
        movBinaryMark(end,end)=1;
        movBinaryMark=imdilate(movBinaryMark,strel('square',30));

        %% Detect larva position across the whole experiment
        while counterNan<globalFeatures.maxNan
            for nTempImg = 1:size(infoImage,1)-1
                % Read two consecutive frames
                img1 = imread(fileName, nTempImg).*maskCircle;
                img2 = imread(fileName, nTempImg + 1).*maskCircle;
                
                % Update the background and centroid every hour
                if mod(nTempImg, globalFeatures.nImagesPerHour) == 0 && (nTempImg + globalFeatures.nImagesPerHour) < size(infoImage, 1)
                    imageBackground = detectBackground(fileName, nTempImg:nTempImg + globalFeatures.nImagesPerHour).*maskCircle;
                    larva1 = abs(imageBackground - img1) > globalFeatures.thresholdDiffPixelsValue;
                    larvaFilt = bwareafilt(larva1, [globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]);
                    larvaFilt = bwpropfilt(larvaFilt,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);
                    centroid2Check = regionprops(bwareafilt(larvaFilt,1), 'Centroid');
                    if isempty(centroid2Check), centroid2Check=[]; else, centroid2Check = centroid2Check.Centroid; end
                end
    
                try
                     % Check if larva is moving
                    [isMoving, difImage, nPixels, centroid2Check, larvaFilt] = isLarvaSleeping(img1, img2, imageBackground, centroid2Check,globalFeatures);
                    
                    % Save the filtered larva image with additional information
                    imwrite(larvaFilt, fullfile(folderPath, 'binaryLarva', [num2str(nTempImg + 1) '_' num2str(nPixels) 'px.jpg']))
                    binaryImage=zeros(size(larvaFilt));
                    if isMoving
                        binaryImage=movBinaryMark;
                    end
                    binaryLarvaStack(:,:,nTempImg+1)=larvaFilt+binaryImage;
                    centroidLarvFilt = regionprops(bwareafilt(larvaFilt,1), 'Centroid').Centroid;
                    if ~isempty(centroidLarvFilt)
                        binaryImage(round(centroidLarvFilt(2)),round(centroidLarvFilt(1)))=1;
                    end
                    binaryMovTrackStack(:,:,nTempImg+1)=binaryImage;

                catch
                    try
                        %if fails, try to recalculate background, just in
                        %case background modified along the time.
                        if nTempImg > globalFeatures.nImagesPerHour / 2
                            imageBackground = detectBackground(fileName, (nTempImg - round(globalFeatures.nImagesPerHour / 2)):(nTempImg + round(globalFeatures.nImagesPerHour / 2))).*maskCircle;
                        else
                            imageBackground = detectBackground(fileName, 1:nTempImg + round(globalFeatures.nImagesPerHour / 2)).*maskCircle;
                        end
                        larva1 = abs(imageBackground - img1) > globalFeatures.thresholdDiffPixelsValue;
                        larvaFilt = bwareafilt(larva1, 1);
                        if sum(centroid2Check) == 0
                            centroid2Check = regionprops(larvaFilt, 'Centroid');
                            if isempty(centroid2Check), centroid2Check=[]; else, centroid2Check = centroid2Check.Centroid; end
                        end
                        [isMoving, difImage, nPixels, centroid2Check, larvaFilt] = isLarvaSleeping(img1, img2, imageBackground, centroid2Check,globalFeatures);
                        
                        % Save the filtered larva image with additional information
                        imwrite(larvaFilt, fullfile(folderPath, 'binaryLarva', [num2str(nTempImg + 1) '_' num2str(nPixels) 'px.jpg']))
                        binaryImage=zeros(size(larvaFilt));
                        if isMoving
                            binaryImage=movBinaryMark;
                        end
                        binaryLarvaStack(:,:,nTempImg+1)=larvaFilt+binaryImage;
                        centroidLarvFilt = regionprops(bwareafilt(larvaFilt,1), 'Centroid').Centroid;
                        if ~isempty(centroidLarvFilt)
                            binaryImage(round(centroidLarvFilt(2)),round(centroidLarvFilt(1)))=1;
                        end
                        binaryMovTrackStack(:,:,nTempImg+1)=binaryImage;
                    catch
                        % Handle exceptions when larva tracking fails
                        isMoving = NaN;
                        nPixels = NaN;
                        counterNan = counterNan + 1;
                        imwrite(ones(size(larvaFilt)), fullfile(folderPath, 'binaryLarva', [num2str(nTempImg + 1) '_NaN.jpg']));
                        binaryMovTrackStack(:,:,nTempImg+1)=ones(size(larvaFilt));
                        binaryLarvaStack(:,:,nTempImg+1)=ones(size(larvaFilt));
                        % Exit loop if too many exceptions occur
                        if counterNan == globalFeatures.maxNan
                            disp(['Too many NaN in: ' folderPath])
                            try 
                                rmdir(fullfile(folderPath,'binaryLarva'),'s');
                                rmdir(fullfile(folderPath,'boutsData'),'s');
                            catch

                            end
                            break;
                        end
                    end
                end
                          
                %Save bouts data per hour
                arrayBouts(end+1)=isMoving;
                arrayPixels(end+1)=nPixels;

                if nTempImg==size(infoImage,1)-1
                    nHour=ceil(nTempImg/globalFeatures.nImagesPerHour);
                    cellBouts(nHour,1:4)={nHour,arrayBouts,arrayPixels,sum(isnan(arrayBouts))};
                    cellBouts=cell2table(cellBouts,VariableNames={'hour','bouts','pixelsMove','numNaNs'});
                    
                    save(fullfile(folderPath,'boutsData','boutsPerHour.mat'),'cellBouts','globalFeatures')
                    writeStackTif(binaryMovTrackStack,fullfile(folderPath,'binaryTrackMovStack.tif'))
                    writeStackTif(binaryLarvaStack,fullfile(folderPath,'binaryLarvaStack.tif'))
                    disp([folderPath ' number of NaNs images: ' num2str(sum(cellBouts.numNaNs))])
                    counterNan=globalFeatures.maxNan;
                end

                
                if mod(nTempImg,globalFeatures.nImagesPerHour)==0 && nTempImg < size(infoImage,1)-1
                    nHour=ceil(nTempImg/globalFeatures.nImagesPerHour);
                    cellBouts(nHour,1:4)={nHour,arrayBouts,arrayPixels,sum(isnan(arrayBouts))};
                    arrayBouts=[];
                    arrayPixels=[];
                    save(fullfile(folderPath,'boutsData','boutsPerHour.mat'),'cellBouts')
                end
    
            end
        end

end
