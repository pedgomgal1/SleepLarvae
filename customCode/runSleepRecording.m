%% Image acquisition logging to TIFF files
% This example uses PARFEVAL (Parallel Computing Toolbox) to save acquired 
% images to TIFF files.

rootFolder = 'C:\Users\TEM\Documents\Pedro\Sleep';
mkdir(rootFolder)
addpath(genpath('src'))
addpath(genpath('lib'))

v = videoinput('ni', 1, 'NICFGen');

totalRecordingsHours = 6;%hours
totalRecordingsSeconds = totalRecordingsHours*60*60;
acquistionImageTime = 6;%seconds
hourToStartAcquisition = 17; %hour
minToStartAcquisition = 30; %min
initClock = clock;
finalClock = initClock;
folder2save=[date '_' num2str(hourToStartAcquisition) '_' num2str(minToStartAcquisition)];
mkdir(fullfile(rootFolder,folder2save));
currentClock=clock;

rangeWellRadii = [70 90]; % [minRadius, maxRadius] in pixels
wellPaddingROI = 10; % ROI side = 2*(radius + padding) in pixels

%% Cropping the init frame
splitOrSelectDir = questdlg('Do you want to crop the frame?','Selection','Yes','No','Yes');

if strcmp(splitOrSelectDir,'Yes')
    happyDecision = 0;
    while happyDecision==0
        %select initial ROI
        frame = getsnapshot(v);
        fig1 = imshow(frame);
        hold on
        title('Select ROI - Click at UPPER-LEFT corner, then at LOWER-RIGHT corner')
        [ROI(1,1), ROI(1,3)] = ginput(1);
        p(1) = plot([ROI(1,1) ROI(1,1)], [1 size(frame,1)], '-r');
        p(2) = plot([1 size(frame,2)], [ROI(1,3) ROI(1,3)], '-r');
        [ROI(1,2), ROI(1,4)] = ginput(1);
        plot([ROI(1,1) ROI(1,2) ROI(1,2) ROI(1,1) ROI(1,1)], ...
                [ROI(1,3) ROI(1,3) ROI(1,4) ROI(1,4) ROI(1,3)],'LineWidth',2);
        rightROI = questdlg('Right ROI selection?','Selection','Yes','No','Yes');
        if strcmp(rightROI,'Yes')
            happyDecision=1; 
            close all
        end
    end
end

%% Create ROIs of individual wells
selectWells = questdlg('Do you want to select all the individual ROIs?','Selection','Yes','No','Yes');
if strcmp(selectWells,'Yes')
    bigImgPath = fullfile(rootFolder,folder2save,'templateImage.tif');
    if strcmp(splitOrSelectDir,'Yes')
        frameCropped = imcrop(frame,[ROI(1,[1,3]),ROI(1,2)-ROI(1,1),ROI(1,4)-ROI(1,3)]);
        imwrite(frameCropped,bigImgPath) ;
    else
        imwrite(frame,bigImgPath);
    end
    directoryROIs = selectIndividualROIs(bigImgPath,{'WT','G2019S','A53T'},[],rangeWellRadii,wellPaddingROI);
    delete(bigImgPath)
end

%% Loop to wait for the exact time to start the recording
while currentClock(4)<hourToStartAcquisition || currentClock(5)< minToStartAcquisition
   currentClock=clock; 
end
clockToStartExp = currentClock;

%% Append frame every X seconds
tiffCounter=0;
while etime(clock,clockToStartExp) < totalRecordingsSeconds
    currentClock=clock; 
    frame = getsnapshot(v);
    if strcmp(splitOrSelectDir,'Yes')
        frame2save = imcrop(frame,[ROI(1,[1,3]),ROI(1,2)-ROI(1,1),ROI(1,4)-ROI(1,3)]);
    else
        frame2save=frame;
    end

    try
        imwrite(frame2save,fullfile(rootFolder,folder2save,['StackSleep' num2str(tiffCounter) '.tif']), 'WriteMode' , 'append') ;
    catch
        tiffCounter = tiffCounter+1;
        imwrite(frame2save,fullfile(rootFolder,folder2save,['StackSleep' num2str(tiffCounter) '.tif']), 'WriteMode' , 'append') ;
    end
    pause(acquistionImageTime-etime(clock,currentClock));
end

%% Split ROIs
directoryROIs = selectIndividualROIs(fullfile(rootFolder,folder2save,'StackSleep0.tif'),{'WT','G2019S','A53T'},'Yes, crop selected ROIs',rangeWellRadii,wellPaddingROI);

%% Run bout extraction
for nDir = 1:size(directoryROIs,1)
    countBoutsPerHour(directoryROIs{nDir},rangeWellRadii)
end