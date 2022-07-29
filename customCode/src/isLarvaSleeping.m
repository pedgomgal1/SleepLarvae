function [boolMovement,restImageFinal,nPixels,Centroid2Check,larvaFilt] = isLarvaSleeping(imageROI1, imageROI2,imageBackground,thresholdPixelsValue,numberOfPixelsThreshold,pixels2CheckFromCentroid,CentroidPrevious,larvaFiltPrevious)
    
    maskCentroid=false(size(imageROI1));
    maskCentroid(round(CentroidPrevious(2)),round(CentroidPrevious(1)))=1;
    dilatedCentroidPrevious=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));
    dilatedCentroid = dilatedCentroidPrevious;

    imageROI1minusBG = abs(imageBackground-imageROI1);
    imageROI2minusBG = abs(imageBackground-imageROI2);
    restImage12 = abs(imageROI1minusBG-imageROI2minusBG)>thresholdPixelsValue;
    restImage21 = abs(imageROI2minusBG-imageROI1minusBG)>thresholdPixelsValue;
    restCombined=(restImage12 | restImage21);
    restImageFinal = (restCombined.*dilatedCentroidPrevious)>0;

    larvaFilt = bwareafilt((imageROI2minusBG>thresholdPixelsValue)>0 & dilatedCentroidPrevious,1);
    Centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));

    [y,x]=find(restImageFinal);
    if ~isempty(x)
        Centroid2Check = [round(mean(x)),round(mean(y))];
        maskCentroid=false(size(imageROI1));
        maskCentroid(round(Centroid2Check(2)),round(Centroid2Check(1)))=1;
        dilatedCentroid=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));
        labelLarva = bwlabel(imageROI2minusBG>thresholdPixelsValue);
        labels=labelLarva(restImage21);
        selectedBlobLarva = (labelLarva == mode(labels(labels>0)));
        larvaFilt = bwareafilt(selectedBlobLarva & dilatedCentroid,1);
    else
        if any(restCombined(:)>0) && ~any(restCombined(:) & larvaFilt(:)) && ~any(larvaFiltPrevious(:) & larvaFilt(:))
            [y,x]=find(restCombined);
            Centroid2Check = [round(mean(x)),round(mean(y))];
            maskCentroid=false(size(imageROI1));
            maskCentroid(round(Centroid2Check(2)),round(Centroid2Check(1)))=1;
            dilatedCentroid=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));
            labelLarva = bwlabel(imageROI2minusBG>thresholdPixelsValue);
            labels=labelLarva(restImage21);
            selectedBlobLarva = (labelLarva == mode(labels(labels>0)));
            larvaFilt = bwareafilt(selectedBlobLarva & dilatedCentroid,1);
            Centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));
        end
    end

    if sum(larvaFilt(:))==0
        larvaFilt = bwareafilt(((imageROI2minusBG>thresholdPixelsValue).*dilatedCentroid)>0,1);
        if sum(larvaFilt(:))==0
            larvaFilt = bwareafilt((imageROI2minusBG>thresholdPixelsValue)>0,1);
        end
        Centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));

        if isempty(Centroid2Check) && ~isempty(x)
            Centroid2Check = [round(mean(x)),round(mean(y))];
        end
    end
    maskCentroid=false(size(imageROI1));
    maskCentroid(round(Centroid2Check(2)),round(Centroid2Check(1)))=1;
    dilatedCentroid=imdilate(maskCentroid,strel('disk',pixels2CheckFromCentroid));

    if  ~any(sum((dilatedCentroidPrevious & dilatedCentroid)>0))
        dilatedCentroid=dilatedCentroidPrevious;
        larvaFilt = bwareafilt(((imageROI2minusBG>thresholdPixelsValue).*dilatedCentroid)>0,1);
        Centroid2Check=struct2array(regionprops(larvaFilt,'Centroid'));
        if isempty(Centroid2Check)
            Centroid2Check=CentroidPrevious;
        end
    end

    restImageFinal = (restCombined.*dilatedCentroid)>0;
    nPixels=sum(restImageFinal(:));
    boolMovement = nPixels>numberOfPixelsThreshold;
    
%     imshow([restImageFinal,imageROI2minusBG>10,restCombined,larvaFilt])

end