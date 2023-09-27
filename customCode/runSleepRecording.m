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
while currentClock(4)<hourToStartAcquisition || currentClock(5)< minToStartAcquisition
   currentClock=clock; 
end

clockToStartExp = currentClock;

while etime(clock,clockToStartExp) < totalRecordingsSeconds
    currentClock=clock; 
    frame = getsnapshot(v);
    %% imwrite(frame,fullfile(rootFolder,folder2save,['Image_' num2str(counter) '_' num2str(currentClock(4)) 'h' num2str(currentClock(5)) 'm' num2str(floor(currentClock(6))) 's.tif']));
    imwrite(frame,fullfile(rootFolder,folder2save,'StackSleep.tif'), 'WriteMode' , 'append') ;
    counter=counter+1;
    pause(acquistionImageTime-etime(clock,currentClock));
end

