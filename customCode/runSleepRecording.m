%% Image acquisition logging to TIFF files
% This example uses PARFEVAL (Parallel Computing Toolbox) to save acquired 
% images to TIFF files.

rootFolder = 'C:\Users\TEM\Documents\Pedro\Sleep';
mkdir(rootFolder)

v = videoinput('ni', 1, 'NICFGen');

totalRecordingsHours = 6;%hours
totalRecordingsSeconds = totalRecordingsHours*60*60;
acquistionImageTime = 6;%seconds
hourToStartAcquisition = 17; %hour
minToStartAcquisition = 30; %min
initClock = clock;
finalClock = initClock;
counter=1;
folder2save=[date '_' num2str(hourToStartAcquisition) '_' num2str(minToStartAcquisition)];
mkdir(fullfile(rootFolder,folder2save));
currentClock=clock;

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


while currentClock(4)<hourToStartAcquisition || currentClock(5)< minToStartAcquisition
   currentClock=clock; 
end

clockToStartExp = currentClock;

while etime(clock,clockToStartExp) < totalRecordingsSeconds
    currentClock=clock; 
    frame = getsnapshot(v);
    if strcmp(splitOrSelectDir,'Yes')
        frameCropped = imcrop(frame,[ROI(1,[1,3]),ROI(1,2)-ROI(1,1),ROI(1,4)-ROI(1,3)]);
        imwrite(frameCropped,fullfile(rootFolder,folder2save,'StackSleep.tif'), 'WriteMode' , 'append') ;
    else
        imwrite(frame,fullfile(rootFolder,folder2save,'StackSleep.tif'), 'WriteMode' , 'append') ;
    end
    %% save image stack
    counter=counter+1;
    pause(acquistionImageTime-etime(clock,currentClock));
end

