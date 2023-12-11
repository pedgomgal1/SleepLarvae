function saveLarvaMovement(fileName,thresholdDiffPixelsValue,numberOfPixelsThreshold,minLarvaArea,maxLarvaArea,pixels2CheckFromCentroid,nImagesPerHour,rangeWellRadii)

        % Extract the folder path from the input file name
        [folderPath, ~, ~] = fileparts(fileName);
        
        % Get information about the input images (e.g size)
        infoImage = imfinfo(fileName);

        % Detect initial background to be subtracted
        imageBackground = detectBackground(fileName, 1:nImagesPerHour);
        
        [centerROIs,radiiWells,metric] = imfindcircles(imageBackground,rangeWellRadii,'ObjectPolarity','dark','Sensitivity',0.99);
        imshow(imageBackground); hold on; viscircles(centerROIs(1,:), radiiWells(1),'EdgeColor','b');

        %Crop just circle:
        imageSize = size(imageBackground);
        paddingCircle=2; %extra radius
        ci = [centerROIs(1,:), radiiWells(1)+paddingCircle];     % center and radius of circle ([c_row, c_col, r])
        [xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
        maskCircle = uint8((xx.^2 + yy.^2)<ci(3)^2);
        croppedBackGround = uint8(zeros(size(imageBackground)));
        croppedBackGround = imageBackground.*maskCircle;


        %%Identify larva in the first frame after tracking larva movement
        %%from the end to the beggining of the experiment

        % Initialize variables for larva tracking
        larva1 = abs(croppedBackGround - imread(fileName, 1).*maskCircle) > thresholdDiffPixelsValue;
        larva2 = abs(croppedBackGround - imread(fileName, 2).*maskCircle) > thresholdDiffPixelsValue;
        % Use bwareafilt to keep objects within the specified area range
        larva1 = bwareafilt(larva1, [minLarvaArea,maxLarvaArea]);
        larva2 = bwareafilt(larva2, [minLarvaArea,maxLarvaArea]);

        % Detect the larva position to do not consider noisy regions far
        % from larva position
        labelLarva = bwlabel(larva1);
        labels = labelLarva(abs(larva2 - larva1) > 0);
        if ~any(labels)
            larvaFilt = labelLarva == mode(labelLarva(larva2));
        else
            larvaFilt = labelLarva == mode(labels(labels > 0));
        end
        centroid2Check = struct2array(regionprops(larvaFilt, 'Centroid'));

         % Initialize arrays to store tracking data
        arrayBouts = [];
        arrayPixels = [];
        
        % Create directories for storing results
        mkdir(fullfile(folderPath, 'binaryLarva'));
        mkdir(fullfile(folderPath, 'boutsData'));

        % Save the initial larva filter as an image
        imwrite(larvaFilt, fullfile(folderPath, 'binaryLarva', [num2str(1) '.jpg']));
        
        % Initialize a cell array to store tracking data per hour
        cellBouts = cell(round(size(infoImage, 1) / nImagesPerHour), 4);
        counterNan = 0;
                

        %% Detect larva position across the whole experiment
        while counterNan<100
            for nTempImg = 1:size(infoImage,1)-1
                
                % Read two consecutive frames
                img1 = imread(fileName, nTempImg).*maskCircle;
                img2 = imread(fileName, nTempImg + 1).*maskCircle;
                
                % Update the background and centroid every hour
                if mod(nTempImg, nImagesPerHour) == 0 && (nTempImg + nImagesPerHour) < size(infoImage, 1)
                    imageBackground = detectBackground(fileName, nTempImg:nTempImg + nImagesPerHour).*maskCircle;
                    larva1 = abs(imageBackground - img1) > thresholdDiffPixelsValue;
                    larvaFilt = bwareafilt(larva1, [minLarvaArea,maxLarvaArea]);
                    centroid2Check = struct2array(regionprops(bwareafilt(larvaFilt,1), 'Centroid'));
                end
    
                try
                     % Check if larva is moving
                    [isMoving, difImage, nPixels, centroid2Check, larvaFilt] = isLarvaSleeping(img1, img2, imageBackground, thresholdDiffPixelsValue, numberOfPixelsThreshold, pixels2CheckFromCentroid, centroid2Check, larvaFilt,minLarvaArea,maxLarvaArea);
                    
                    % Save the filtered larva image with additional information
                    imwrite(larvaFilt, fullfile(folderPath, 'binaryLarva', [num2str(nTempImg + 1) '_' num2str(nPixels) 'px.jpg']))
                catch
                    try
                        if nTempImg > nImagesPerHour / 2
                            imageBackground = detectBackground(fileName, (nTempImg - round(nImagesPerHour / 2)):(nTempImg + round(nImagesPerHour / 2))).*maskCircle;
                        else
                            imageBackground = detectBackground(fileName, 1:nTempImg + round(nImagesPerHour / 2)).*maskCircle;
                        end
                        larva1 = abs(imageBackground - img1) > thresholdDiffPixelsValue;
                        larvaFilt = bwareafilt(larva1, 1);
                        if sum(centroid2Check) == 0
                            centroid2Check = struct2array(regionprops(larvaFilt, 'Centroid'));
                        end
                        [isMoving, difImage, nPixels, centroid2Check, larvaFilt] = isLarvaSleeping(img1, img2, imageBackground, thresholdDiffPixelsValue, numberOfPixelsThreshold, pixels2CheckFromCentroid, centroid2Check, larvaFilt,minLarvaArea,maxLarvaArea);
                        
                        % Save the filtered larva image with additional information
                        imwrite(larvaFilt, fullfile(folderPath, 'binaryLarva', [num2str(nTempImg + 1) '_' num2str(nPixels) 'px.jpg']))

                    catch
                        % Handle exceptions when larva tracking fails
                        isMoving = NaN;
                        nPixels = NaN;
                        counterNan = counterNan + 1;
                        imwrite(ones(size(larvaFilt)), fullfile(folderPath, 'binaryLarva', [num2str(nTempImg + 1) '_NaN.jpg']));
                        
                        % Exit loop if too many exceptions occur
                        if counterNan == 100
                            disp(['Too many NaN in: ' folderPath])
                            try 
                                rmdir(folderPath,'s');
                            catch

                            end
                            break;
                        end
                    end
                end
                          
                %Save bouts data per hour
                arrayBouts(end+1)=isMoving;
                arrayPixels(end+1)=nPixels;
                if mod(nTempImg,nImagesPerHour)==0
                    nHour=round(nTempImg/nImagesPerHour);
                    cellBouts(nHour,1:4)={nHour,arrayBouts,arrayPixels,sum(isnan(arrayBouts))};
                    arrayBouts=[];
                    arrayPixels=[];
                    save(fullfile(folderPath,'boutsData','boutsPerHour.mat'),'cellBouts')
                end

                if nTempImg==size(infoImage,1)-1
                    nHour=round(nTempImg/nImagesPerHour);
                    cellBouts(nHour,1:4)={nHour,arrayBouts,arrayPixels,sum(isnan(arrayBouts))};
                    cellBouts=cell2table(cellBouts,VariableNames={'hour','bouts','pixelsMove','numNaNs'});
                    
                    save(fullfile(folderPath,'boutsData','boutsPerHour.mat'),'cellBouts')
                    disp([folderPath ' number of NaNs images: ' num2str(sum(cellBouts.numNaNs))])
                    counterNan=100;
                end
    
            end
        end

end
