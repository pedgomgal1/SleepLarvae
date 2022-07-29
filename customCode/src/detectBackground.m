function backGroundImage = detectBackground(dirImages)

    imageAccum = imread(fullfile(dirImages(1).folder,dirImages(1).name));
    nAccum=2;
    for nImg =2:1:size(dirImages,1)
        imageAccum(:,:,nAccum) = imread(fullfile(dirImages(nImg).folder,dirImages(nImg).name));
        nAccum=nAccum+1;
    end

    backGroundImage=mode(imageAccum,3);

end