function [directoryROIs,allROIs] = splitImagesInROIs(filePath)

    addpath(genpath('lib'))

    imgTemplate = imread(filePath);        
    chosenPhenotype = questdlg('Choose phenotype', '','all genotypes','individual genotype','all genotypes');
    [folderPath,~,~] = fileparts(filePath);
    if strcmp(chosenPhenotype,'all genotypes')
        genotypes = {'WT','G2019S','A53T'};
    else
        chosenPhenotype = questdlg('Choose phenotype', '','WT','G2019S','A53T','WT');
        genotypes = {chosenPhenotype};
    end
    for nGen = 1:length(genotypes)     
        
        path2save=fullfile(folderPath,'Processing',genotypes{nGen});

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
        else
            load(fullfile(path2save,'roiDetails.mat'),'ROI')
            disp('remove the existing ROIs if you want to select new ones')
        end
        directoryROIs{nGen,1} = path2save;
        allROIs{nGen,1} = ROI;
    end
end