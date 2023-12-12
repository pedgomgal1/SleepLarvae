function [directoryROIs,allROIs] = splitImagesInROIs(filePath,genotypes,rangeWellRadii,wellPaddingROI,ROISelection)

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

    if ROISelection
        Ans = inputdlg({'Enter total number of wells'},'Manual Selection',1,{''});
        totalNumberWells =  str2num(Ans{1});
        
        [centerROIs,radiiWells,metrics] = imfindcircles(imgTemplate,rangeWellRadii,'Sensitivity',0.99);
        centerROIs=centerROIs(1:totalNumberWells,:);
        radiiWells=radiiWells(1:totalNumberWells);
        [centerROIs,indx]=sortrows(centerROIs);
        radiiWells=radiiWells(indx);
        imshow(imgTemplate); hold on; viscircles(centerROIs, radiiWells,'EdgeColor','b');
        numROIs=length(radiiWells);
        %Label the ROI with its number inside the circle
        for n=1:numROIs
           text(centerROIs(n,1), centerROIs(n,2), num2str(n), 'Color', 'black', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
        
        roiSelectionMode = questdlg('Selection of ROI mode', '','interactive','manual','interactive');
    end
    
    for nGen = 1:length(genotypes)     
        
        path2save=fullfile(folderPath,'Processing',genotypes{nGen});

        if ~exist(fullfile(path2save,'roiDetails.mat'),'file')
            mkdir(path2save)        
            Ans = inputdlg({['Enter number of ROI for ' genotypes{nGen}]},'Manual Selection',1,{''});
            numROIs = str2num(Ans{1});
            ROILine =zeros(1,numROIs);
            ROILabel =zeros(1,numROIs);
            
            if strcmp(roiSelectionMode,'interactive')
                padding=wellPaddingROI; % # pixels as padding
                listROI=[];
                ROI=[];
                close all
                imshow(imgTemplate); hold on; viscircles(centerROIs, radiiWells,'EdgeColor','b');
                while length(listROI)<numROIs
                    % Interactive selection using ginput
                    title(['Selected ROIs for ' genotypes{nGen}  ' -- Double selection to remove ROI'])
                    [x, y] = ginput(1); % Wait for user input by clicking on a circle
                    idx = knnsearch(centerROIs, [x, y]); % Find the nearest circle
                    newROI = [centerROIs(idx,1)-radiiWells(idx)-padding,centerROIs(idx,1)+radiiWells(idx)+padding,centerROIs(idx,2)-radiiWells(idx)-padding,centerROIs(idx,2)+radiiWells(idx)+padding];
                    %if the roi is in the list double to delete
                    if ismember(idx, listROI)
                        listROI(listROI==idx)=[];
                        ROI(ismember(ROI,newROI,'rows'),:)=[];
                        close all
                        imshow(imgTemplate); hold on; viscircles(centerROIs, radiiWells,'EdgeColor','b');
                    else
                        listROI=[listROI, idx];
                        ROI=[ROI;newROI];
                    end
                    for nROI=1:length(listROI)
                        ROILine(nROI) = plot([ROI(nROI,1) ROI(nROI,2) ROI(nROI,2) ROI(nROI,1) ROI(nROI,1)],[ROI(nROI,3) ROI(nROI,3) ROI(nROI,4) ROI(nROI,4) ROI(nROI,3)]);
                        text(centerROIs(listROI(nROI),1), centerROIs(listROI(nROI),2), num2str(nROI), 'Color', 'black', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
                    end
                    title(['Selected ROIs for ' genotypes{nGen}  ' -- Double selection to remove ROI'])
                end
            else
                close all;
                imshow(imgTemplate);hold on;
                ROI = zeros(numROIs,4);
                for n = 1:numROIs
                    %Manual selection
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
            end
            
            %adjust ROI to the image limits
            ROI = round(ROI);
            [maxRow,maxCol]=size(imgTemplate);
            ROI(ROI<1)=1;
            idxMaxCol = [ROI(:,[1,2])>maxCol,false(size(ROI(:,[3,4])))];
            ROI(idxMaxCol)=maxCol;
            idxMaxRow = [false(size(ROI(:,[1,2]))),ROI(:,[3,4])>maxRow];
            ROI(idxMaxRow)=maxRow;
%             close all;
%             imshow(imgTemplate); hold on;
%             for nROI=1:length(listROI)
%                 ROILine(nROI) = plot([ROI(nROI,1) ROI(nROI,2) ROI(nROI,2) ROI(nROI,1) ROI(nROI,1)],[ROI(nROI,3) ROI(nROI,3) ROI(nROI,4) ROI(nROI,4) ROI(nROI,3)]);
%                 text(centerROIs(listROI(nROI),1), centerROIs(listROI(nROI),2), num2str(nROI), 'Color', 'black', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
%             end

            rightROI = questdlg('Right ROI selection?', '','Yes','No','Yes');
            
            if strcmp(rightROI,'Yes')
                f = gcf;
                exportgraphics(f,fullfile(path2save,[genotypes{nGen} '_ROIs.png']),'Resolution',300)
                save(fullfile(path2save,'roiDetails.mat'),'ROI')
                close all
            else 
                close all
                return;
            end 
                     
        else
            load(fullfile(path2save,'roiDetails.mat'),'ROI')
            disp(['remove the existing ROIs from ' genotypes{nGen} ' to select new ones'])
        end
        directoryROIs{nGen,1} = path2save;
        allROIs{nGen,1} = ROI;
    end
end