%% Image acquisition logging to TIFF files
% This example uses PARFEVAL (Parallel Computing Toolbox) to save acquired 
% images to TIFF files.

rootFolder = 'data';
mkdir(rootFolder)

v = videoinput('ni', 1, 'NICFGen');

totalRecordingsHours = 12;%hours
totalRecordingsSeconds = totalRecordingsHours*60*60;
acquistionImageTime = 6;%seconds
hourToStartAcquisition = 18;
initClock = clock;
finalClock = initClock;
counter=1;
folder2save=date;
mkdir(fullfile(rootFolder,folder2save));
currentClock=clock;
while currentClock(4)<hourToStartAcquisition
   currentClock=clock; 
end

while etime(clock,initClock) < totalRecordingsSeconds
    currentClock=clock; 
    frame = getsnapshot(v);
    %% imwrite(frame,fullfile(rootFolder,folder2save,['Image_' num2str(counter) '_' num2str(currentClock(4)) 'h' num2str(currentClock(5)) 'm' num2str(floor(currentClock(6))) 's.tif']));
    imwrite(frame,fullfile(rootFolder,folder2save,'StackSleep.tif'), 'WriteMode' , 'append') ;
    counter=counter+1;
    pause(acquistionImageTime-etime(clock,currentClock));
end

