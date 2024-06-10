function [boolMovement,restImageFinal,nPixels,centroid2Check,larvaFilt] = isLarvaSleeping(imageROI1, imageROI2,imageBackground,CentroidPrevious,globalFeatures)
    
    % Create a disk mask seeding in the larvaFilt centroid
    maskCentroid=false(size(imageROI1));
    maskCentroid(round(CentroidPrevious(2)),round(CentroidPrevious(1)))=1;
    dilatedCentroidPrevious=imdilate(maskCentroid,strel('disk',globalFeatures.pixels2CheckFromCentroid));

    zerosFrame=imageROI1==0;
    imageBackground(zerosFrame)=0;
    % Get the XOR larvae pixels
    imageROI1minusBG = abs(imageBackground-imageROI1);
    imageROI2minusBG = abs(imageBackground-imageROI2);
    restImage12 = abs(imageROI1minusBG-imageROI2minusBG)>globalFeatures.thresholdDiffPixelsValue;
    restImage21 = abs(imageROI2minusBG-imageROI1minusBG)>globalFeatures.thresholdDiffPixelsValue;
    restCombined=(restImage12 | restImage21);
    restImageFinal = (restCombined.*dilatedCentroidPrevious)>0;

    intersectLarv = (imageROI1minusBG>globalFeatures.thresholdDiffPixelsValue) & (imageROI2minusBG>globalFeatures.thresholdDiffPixelsValue) | restImage21;

    % update centroid based on NOT pixels in Frame 2, else based on XOR
    % pixels of Frames 1-2. If not possible, then

    % filter larva body of frame 2, and keep the centroid if no other centroid can be captured from restImageFinal or restCombined
    larvaFilt = bwareafilt((imageROI2minusBG>globalFeatures.thresholdDiffPixelsValue)>0 & dilatedCentroidPrevious,[globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]);
    larvaFilt = bwpropfilt(larvaFilt,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);

    centroid2Check=regionprops(bwareafilt(larvaFilt,1),'Centroid');
    if isempty(centroid2Check), centroid2Check=[]; else, centroid2Check = centroid2Check.Centroid; end
    
    [y,x]=find(restImageFinal);
    if ~isempty(x)
        centroid2Check = [round(mean(x)),round(mean(y))];
        maskCentroid=false(size(imageROI1));
        maskCentroid(round(centroid2Check(2)),round(centroid2Check(1)))=1;
        dilatedCentroid=imdilate(maskCentroid,strel('disk',globalFeatures.pixels2CheckFromCentroid));
        labelLarva = bwlabel(imageROI2minusBG>globalFeatures.thresholdDiffPixelsValue);
        labels=labelLarva(restImage21);
        selectedBlobLarva = (labelLarva == mode(labels(labels>0)));
        larvaFilt = bwareafilt(selectedBlobLarva & dilatedCentroid,[globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]);
        larvaFilt = bwpropfilt(larvaFilt,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);
        larvaFilt = bwareafilt(larvaFilt,1);
        if ~any(larvaFilt(:)>0)
            %Larva intersection
            larvaFilt = bwpropfilt(intersectLarv,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);
            larvaFilt = bwareafilt(bwareafilt(larvaFilt,[globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]),1);
        end
    else
        larvaFilt = bwpropfilt(intersectLarv,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);
        larvaFilt = bwareafilt(bwareafilt(larvaFilt,[globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]),1);
        if any(larvaFilt(:)>0)
            [y,x]=find(larvaFilt);
            centroid2Check = [round(mean(x)),round(mean(y))];
        end
    end
    
    %update centroid 
    maskCentroid=false(size(imageROI1));
    maskCentroid(round(centroid2Check(2)),round(centroid2Check(1)))=1;
    dilatedCentroid=imdilate(maskCentroid,strel('disk',globalFeatures.pixels2CheckFromCentroid));

    if  ~any(sum((dilatedCentroidPrevious & dilatedCentroid)>0))
        dilatedCentroid=dilatedCentroidPrevious;
        larvaFilt = bwpropfilt((imageROI2minusBG>globalFeatures.thresholdDiffPixelsValue)>0 & dilatedCentroid,'MajorAxisLength',[0 globalFeatures.maxMajorAxisLength]);
        larvaFilt = bwareafilt(bwareafilt(larvaFilt,[globalFeatures.minLarvaArea,globalFeatures.maxLarvaArea]),1);
        centroid2Check=regionprops(larvaFilt,'Centroid').Centroid;
        if isempty(centroid2Check)
            centroid2Check=CentroidPrevious;
        end
    end


    %check movement and amount of movement
    restImageFinal = (restCombined.*dilatedCentroid)>0;
    nPixels=sum(restImageFinal(:));
    boolMovement = nPixels>globalFeatures.numberOfPixelsThreshold;
    
    %imshow([restImageFinal,imageROI2minusBG>5,imageROI2minusBG>10,imageROI2minusBG>15,imageROI2minusBG>20,imageROI2minusBG>25,restCombined,larvaFilt])

end