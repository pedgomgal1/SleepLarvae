function directoryROIs = splitImagesInROIs

    [fileName,filePath] = uigetfile('*.tif','select template file to choose the ROIs per genotype');
    
    addpath(genpath('lib'))
    
    imgTemplate = imread(fullfile(filePath,fileName));
    chosenPhenotype = questdlg('Choose phenotype', '','WT','G2019S','A53T','WT');
    
    path2save=fullfile(filePath,'Processing',chosenPhenotype);
    
    if ~exist(fullfile(path2save,'roiDetails.mat'),'file')
    
        mkdir(path2save)
        
        Ans = inputdlg({'Enter number of ROI'},'Manual Selection',1,{''});
        NumROI = str2num(Ans{1});
        ROI = zeros(NumROI,4);
        ROILine =zeros(1,NumROI);
        ROILabel =zeros(1,NumROI);
        fig1 = imshow(imgTemplate);
        hold on
        for n = 1:NumROI
            title(['Select ROI#' ...
                num2str(n) ': Click at UPPER-LEFT corner, then at LOWER-RIGHT corner.'])
            [ROI(n,1), ROI(n,3)] = ginput(1);
            p(1) = plot([ROI(n,1) ROI(n,1)], [1 size(imgTemplate,1)], '-r');
            p(2) = plot([1 size(imgTemplate,2)], [ROI(n,3) ROI(n,3)], '-r');
            [ROI(n,2), ROI(n,4)] = ginput(1);
            set(p(:),'Visible','off');
            ROILine(n) = plot([ROI(n,1) ROI(n,2) ROI(n,2) ROI(n,1) ROI(n,1)], ...
                [ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4) ROI(n,3)]);
            ROILabel(n) = text(ROI(n,1)+10,ROI(n,3)+20,num2str(n),'Color','white','FontSize',10);
        end
        ROI = round(ROI);
        
        rightROI = questdlg('Right ROI selection', '','Yes','No','Yes');
        close all
        if strcmp(rightROI,'Yes')
            save(fullfile(path2save,'roiDetails.mat'),'ROI','ROILine')
        else 
            return;
        end
    
        filePattern = fullfile(filePath, '*.tif');
        tifFiles = dir(filePattern);
        
        parfor nTiffImages = 1:size(tifFiles,1)
            imgTif = imread(fullfile(filePath,tifFiles(nTiffImages).name));
            cropIndividualROIs(imgTif,ROI,path2save,tifFiles(nTiffImages).name)
        end
    else
        disp('remove the existing ROIs if you want to select new ones')
    end
    directoryROIs = path2save;
end