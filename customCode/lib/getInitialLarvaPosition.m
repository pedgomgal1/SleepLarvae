function [centroid2Check, larvaFilt]=getInitialLarvaPosition(croppedBackGround,fileName,maskCircle,globalFeatures)

    centroid2Check=[];
    counter=0;
    lastFrame=globalFeatures.frameToStartLarvaSearching;
    while counter<lastFrame-1
        % Initialize variables for larva tracking (from init)
        larva1 = abs(croppedBackGround - imread(fileName, lastFrame-counter).*maskCircle) > globalFeatures.thresholdDiffPixelsValue;
        larva2 = abs(croppedBackGround - imread(fileName, lastFrame-1-counter).*maskCircle) > globalFeatures.thresholdDiffPixelsValue;
        % Use bwareafilt to keep objects within the specified area range
        larva1 = bwareafilt(larva1, [globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]);
        larva2 = bwareafilt(larva2, [globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]);
        %filter by maximum major axis length
        larva1 = bwpropfilt(larva1,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);
        larva2 = bwpropfilt(larva2,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);

        % Detect the larva position to do not consider noisy regions far
        % from larva position
        labelLarva = bwlabel(larva2);
        labels = labelLarva(abs(larva2 - larva1) > 0);
        if ~any(labels)
            larvaFilt = labelLarva == mode(labelLarva(larva2));
        else
            larvaFilt = labelLarva == mode(labels(labels > 0));
        end
         
        centroid2Check = regionprops(larvaFilt, 'Centroid');
        if isempty(centroid2Check), centroid2Check=[]; else, centroid2Check = centroid2Check.Centroid; end
        
        counter=counter+1;

    end

    if ~isempty(centroid2Check)
        for nTempImg = lastFrame:-1:2
            nTempImgPrevious = nTempImg - 1;
            % Read two consecutive frames
            imgEnd = imread(fileName, nTempImg).*maskCircle;
            imgPrevious = imread(fileName, nTempImgPrevious).*maskCircle;
    
            try
                [isMoving, difImage, nPixels, centroid2Check, larvaFilt] = isLarvaSleeping(imgEnd, imgPrevious, croppedBackGround, centroid2Check,globalFeatures);
            catch
            end
        end
    else
        disp('Larva not found - trying conventional mode')

        % Initialize variables for larva tracking (from init)
        larva1 = abs(croppedBackGround - imread(fileName, 1).*maskCircle) > globalFeatures.thresholdDiffPixelsValue;
        larva2 = abs(croppedBackGround - imread(fileName, 2).*maskCircle) > globalFeatures.thresholdDiffPixelsValue;
        % Use bwareafilt to keep objects within the specified area range
        larva1 = bwareafilt(larva1, [globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]);
        larva2 = bwareafilt(larva2, [globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]);
        %filter by maximum major axis length
        larva1 = bwpropfilt(larva1,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);
        larva2 = bwpropfilt(larva2,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);

        % Detect the larva position to do not consider noisy regions far
        % from larva position
        labelLarva = bwlabel(larva1);
        labels = labelLarva(abs(larva2 - larva1) > 0);
        if ~any(labels)
            larvaFilt = labelLarva == mode(labelLarva(larva2));
        else
            larvaFilt = labelLarva == mode(labels(labels > 0));
        end
        centroid2Check = regionprops(larvaFilt, 'Centroid');
        if isempty(centroid2Check), centroid2Check=[]; else, centroid2Check = centroid2Check.Centroid; end
    end
end
