function [directoryROIs,allROIs] = splitImagesInROIs(filePath,genotypes)

    addpath(genpath('lib'))

    imgTemplate = imread(filePath);     
    [folderPath,~,~] = fileparts(filePath);

    if isempty(genotypes)
        chosenPhenotype = questdlg('Choose phenotype', '','all genotypes','individual genotype','all genotypes');
        if strcmp(chosenPhenotype,'all genotypes')
            genotypes = {'WT','G2019S','A53T'};
        else
            chosenPhenotype = questdlg('Choose phenotype', '','WT','G2019S','A53T','WT');
            genotypes = {chosenPhenotype};
        end
    end

    [centers,radii] = imfindcircles(imgTemplate,[75,90],'ObjectPolarity','dark','Sensitivity',0.975);
    [centers,indx]=sortrows(centers);
    radii=radii(indx);
    imshow(imgTemplate); hold on; viscircles(centers, radii,'EdgeColor','b');
    numROIs=length(radii);
    %Label the ROI with its number inside the circle
    for n=1:numROIs
       text(centers(n,1), centers(n,2), num2str(n), 'Color', 'black', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    end

% % Interactive selection using ginput
% padding=10; % # pixels as padding
% listROI=[];
% for n = 1:numROIs
%     title(['Selected ROIs for ' genotypes{nGen} ': ' num2str(listROI)])
%     [x, y] = ginput(1); % Wait for user input by clicking on a circle
%     idx = knnsearch(centers, [x, y]); % Find the nearest circle
%     %if the roi is in the list double to delete
%     listROI=[listROI, idx];
%     ROI(n,:)=[centers(idx,1)-radii(idx)-padding,centers(idx,1)+radii(idx)+padding,centers(idx,2)-radii(idx)-padding,centers(idx,2)+radii(idx)+padding];
%     ROILine(n) = plot([ROI(n,1) ROI(n,2) ROI(n,2) ROI(n,1) ROI(n,1)], ...
%                     [ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4) ROI(n,3)]);
%     title(['Selected ROIs for ' genotypes{nGen} ': ' num2str(listROI)])
% end

    for nGen = 1:length(genotypes)     
        
        path2save=fullfile(folderPath,'Processing',genotypes{nGen});

        if ~exist(fullfile(path2save,'roiDetails.mat'),'file')
            mkdir(path2save)        
            Ans = inputdlg({['Enter number of ROI for ' genotypes{nGen}]},'Manual Selection',1,{''});
            numROIs = str2num(Ans{1});
            ROI = zeros(numROIs,4);
            ROILine =zeros(1,numROIs);
            ROILabel =zeros(1,numROIs);
            fig1 = imshow(imgTemplate);
            hold on
            for n = 1:numROIs
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
            
            rightROI = questdlg('Right ROI selection?', '','Yes','No','Yes');
            close all
            if strcmp(rightROI,'Yes')
                save(fullfile(path2save,'roiDetails.mat'),'ROI','ROILine')
            else 
                return;
            end        
        else
            load(fullfile(path2save,'roiDetails.mat'),'ROI')
            disp(['remove the existing ROIs from ' genotypes{nGen} ' if you want to select new ones'])
        end
        directoryROIs{nGen,1} = path2save;
        allROIs{nGen,1} = ROI;
    end
end