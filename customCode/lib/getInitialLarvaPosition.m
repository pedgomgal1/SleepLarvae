function [centroid2Check, larvaFilt]=getInitialLarvaPosition(croppedBackGround,fileName,lastFrame,maskCircle,thresholdDiffPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,minLarvaArea,maxLarvaArea,maxMajorAxisLength)

    centroid2Check=[];
    counter=0;
    while isempty(centroid2Check) && counter<lastFrame-1
        % Initialize variables for larva tracking (from init)
        larva1 = abs(croppedBackGround - imread(fileName, lastFrame-counter).*maskCircle) > thresholdDiffPixelsValue;
        larva2 = abs(croppedBackGround - imread(fileName, lastFrame-1-counter).*maskCircle) > thresholdDiffPixelsValue;
        % Use bwareafilt to keep objects within the specified area range
        larva1 = bwareafilt(larva1, [minLarvaArea,maxLarvaArea]);
        larva2 = bwareafilt(larva2, [minLarvaArea,maxLarvaArea]);
        %filter by maximum major axis length
        larva1 = bwpropfilt(larva1,'MajorAxisLength',[0 maxMajorAxisLength]);
        larva2 = bwpropfilt(larva2,'MajorAxisLength',[0 maxMajorAxisLength]);

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
        
        counter=counter+1;

    end

    if ~isempty(centroid2Check)
        for nTempImg = lastFrame:-1:2
            nTempImgPrevious = nTempImg - 1;
            % Read two consecutive frames
            imgEnd = imread(fileName, nTempImg).*maskCircle;
            imgPrevious = imread(fileName, nTempImgPrevious).*maskCircle;
    
            % Initialize variables for larva tracking (from init)
            larva2 = abs(croppedBackGround - imgEnd) > thresholdDiffPixelsValue;
            larva1 = abs(croppedBackGround - imgPrevious) > thresholdDiffPixelsValue;
            larva2 = bwareafilt(larva2, [minLarvaArea,maxLarvaArea]);
            larva1 = bwareafilt(larva1, [minLarvaArea,maxLarvaArea]);
            %filter by maximum major axis length
            larva1 = bwpropfilt(larva1,'MajorAxisLength',[0 maxMajorAxisLength]);
            larva2 = bwpropfilt(larva2,'MajorAxisLength',[0 maxMajorAxisLength]);
    
            try
                [isMoving, difImage, nPixels, centroid2Check, larvaFilt] = isLarvaSleeping(imgEnd, imgPrevious, croppedBackGround, thresholdDiffPixelsValue, numberOfPixelsThreshold, pixels2CheckFromCentroid, centroid2Check, larvaFilt,minLarvaArea,maxLarvaArea);
            catch
                
            end
        end
    else
        disp('Larva not found - trying conventional mode')

        % Initialize variables for larva tracking (from init)
        larva1 = abs(croppedBackGround - imread(fileName, 1).*maskCircle) > thresholdDiffPixelsValue;
        larva2 = abs(croppedBackGround - imread(fileName, 2).*maskCircle) > thresholdDiffPixelsValue;
        % Use bwareafilt to keep objects within the specified area range
        larva1 = bwareafilt(larva1, [minLarvaArea,maxLarvaArea]);
        larva2 = bwareafilt(larva2, [minLarvaArea,maxLarvaArea]);
        %filter by maximum major axis length
        larva1 = bwpropfilt(larva1,'MajorAxisLength',[0 maxMajorAxisLength]);
        larva2 = bwpropfilt(larva2,'MajorAxisLength',[0 maxMajorAxisLength]);

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
    end
end
