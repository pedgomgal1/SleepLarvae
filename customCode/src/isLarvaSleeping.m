function [boolMovement,restImageFinal,nPixels,Centroid2Check,larvaFilt] = isLarvaSleeping(imageROI1, imageROI2,imageBackground,thresholdPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,CentroidPrevious,larvaFiltPrevious,minLarvaArea,maxLarvaArea)
    
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
    Centroid2Check=struct2array(regionprops(bwareafilt(larvaFilt,1),'Centroid'));
    [y,x]=find(restImageFinal);
    if ~isempty(x)
        Centroid2Check = [round(mean(x)),round(mean(y))];
        maskCentroid=false(size(imageROI1));
        maskCentroid(round(Centroid2Check(2)),round(Centroid2Check(1)))=1;
        dilatedCentroid=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));
        labelLarva = bwlabel(imageROI2minusBG>thresholdPixelsValue);
        labels=labelLarva(restImage21);
        selectedBlobLarva = (labelLarva == mode(labels(labels>0)));
        larvaFilt = bwareafilt(selectedBlobLarva & dilatedCentroid,[minLarvaArea,maxLarvaArea]);
        larvaFilt = bwareafilt(larvaFilt,1);
        if ~any(larvaFilt(:)>0)
            %Larva intersection
            larvaFilt = bwareafilt(bwareafilt(intersectLarv,[minLarvaArea,maxLarvaArea]),1);
        end
    else
        larvaFilt = bwareafilt(bwareafilt(intersectLarv,[minLarvaArea,maxLarvaArea]),1);
        if any(larvaFilt(:)>0)
            [y,x]=find(larvaFilt);
            Centroid2Check = [round(mean(x)),round(mean(y))];
        end
    end
    
    %update centroid 
    maskCentroid=false(size(imageROI1));
    maskCentroid(round(Centroid2Check(2)),round(Centroid2Check(1)))=1;
    dilatedCentroid=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));

    if  ~any(sum((dilatedCentroidPrevious & dilatedCentroid)>0))
        dilatedCentroid=dilatedCentroidPrevious;
        larvaFilt = bwareafilt(bwareafilt((imageROI2minusBG>thresholdPixelsValue)>0 & dilatedCentroid,[minLarvaArea,maxLarvaArea]),1);
        Centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));
        if isempty(Centroid2Check)
            Centroid2Check=CentroidPrevious;
        end
    end


    %check movement and amount of movement
    restImageFinal = (restCombined.*dilatedCentroid)>0;
    nPixels=sum(restImageFinal(:));
    boolMovement = nPixels>numberOfPixelsThreshold;
    
    %imshow([restImageFinal,imageROI2minusBG>10,restCombined,larvaFilt])

end