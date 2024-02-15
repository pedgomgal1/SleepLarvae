function [boolMovement,restImageFinal,nPixels,centroid2Check,larvaFilt] = isLarvaSleeping(imageROI1, imageROI2,imageBackground,thresholdPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,CentroidPrevious,larvaFiltPrevious,minLarvaArea,maxLarvaArea,maxMajorAxisLength)
    
    % Create a disk mask seeding in the larvaFilt centroid
    maskCentroid=false(size(imageROI1));
    maskCentroid(round(CentroidPrevious(2)),round(CentroidPrevious(1)))=1;
    dilatedCentroidPrevious=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));

    % Get the XOR larvae pixels
    imageROI1minusBG = abs(imageBackground-imageROI1);
    imageROI2minusBG = abs(imageBackground-imageROI2);
    restImage12 = abs(imageROI1minusBG-imageROI2minusBG)>thresholdPixelsValue;
    restImage21 = abs(imageROI2minusBG-imageROI1minusBG)>thresholdPixelsValue;
    restCombined=(restImage12 | restImage21);
    restImageFinal = (restCombined.*dilatedCentroidPrevious)>0;

    intersectLarv = (abs(imageBackground-imageROI1)>thresholdPixelsValue) & (abs(imageBackground-imageROI2)>thresholdPixelsValue) | restImage21;

    % update centroid based on NOT pixels in Frame 2, else based on XOR
    % pixels of Frames 1-2. If not possible, then

    % filter larva body of frame 2, and keep the centroid if no other centroid can be captured from restImageFinal or restCombined
    larvaFilt = bwareafilt((imageROI2minusBG>thresholdPixelsValue)>0 & dilatedCentroidPrevious,[minLarvaArea,maxLarvaArea]);
    larvaFilt = bwpropfilt(larvaFilt,'MajorAxisLength',[0 maxMajorAxisLength]);

    centroid2Check=regionprops(bwareafilt(larvaFilt,1),'Centroid');
    if isempty(centroid2Check), centroid2Check=[]; else, centroid2Check = centroid2Check.Centroid; end
    
    [y,x]=find(restImageFinal);
    if ~isempty(x)
        centroid2Check = [round(mean(x)),round(mean(y))];
        maskCentroid=false(size(imageROI1));
        maskCentroid(round(centroid2Check(2)),round(centroid2Check(1)))=1;
        dilatedCentroid=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));
        labelLarva = bwlabel(imageROI2minusBG>thresholdPixelsValue);
        labels=labelLarva(restImage21);
        selectedBlobLarva = (labelLarva == mode(labels(labels>0)));
        larvaFilt = bwareafilt(selectedBlobLarva & dilatedCentroid,[minLarvaArea,maxLarvaArea]);
        larvaFilt = bwpropfilt(larvaFilt,'MajorAxisLength',[0 maxMajorAxisLength]);
        larvaFilt = bwareafilt(larvaFilt,1);
        if ~any(larvaFilt(:)>0)
            %Larva intersection
            larvaFilt = bwpropfilt(intersectLarv,'MajorAxisLength',[0 maxMajorAxisLength]);
            larvaFilt = bwareafilt(bwareafilt(larvaFilt,[minLarvaArea,maxLarvaArea]),1);
        end
    else
        larvaFilt = bwpropfilt(intersectLarv,'MajorAxisLength',[0 maxMajorAxisLength]);
        larvaFilt = bwareafilt(bwareafilt(larvaFilt,[minLarvaArea,maxLarvaArea]),1);
        if any(larvaFilt(:)>0)
            [y,x]=find(larvaFilt);
            centroid2Check = [round(mean(x)),round(mean(y))];
        end
    end
    
    %update centroid 
    maskCentroid=false(size(imageROI1));
    maskCentroid(round(centroid2Check(2)),round(centroid2Check(1)))=1;
    dilatedCentroid=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));

    if  ~any(sum((dilatedCentroidPrevious & dilatedCentroid)>0))
        dilatedCentroid=dilatedCentroidPrevious;
        larvaFilt = bwpropfilt((imageROI2minusBG>thresholdPixelsValue)>0 & dilatedCentroid,'MajorAxisLength',[0 maxMajorAxisLength]);
        larvaFilt = bwareafilt(bwareafilt(larvaFilt,[minLarvaArea,maxLarvaArea]),1);
        centroid2Check=regionprops(larvaFilt,'Centroid').Centroid;
        if isempty(centroid2Check)
            centroid2Check=CentroidPrevious;
        end
    end


    %check movement and amount of movement
    restImageFinal = (restCombined.*dilatedCentroid)>0;
    nPixels=sum(restImageFinal(:));
    boolMovement = nPixels>numberOfPixelsThreshold;
    
    %imshow([restImageFinal,imageROI2minusBG>10,restCombined,larvaFilt])

end