function backGroundImage = detectBackground(fileName,ids)

    imageAccum=imread(fileName, ids(1));
    nAccum=2;
    for nImg =2:1:length(ids)
        imageAccum(:,:,nAccum) = imread(fileName, ids(nImg));
        nAccum=nAccum+1;
    end
    backGroundImage=mode(imageAccum,3);

end