clear all
close all
warning 'off'

addpath(genpath('src'))
addpath(genpath(fullfile('..','..','Chemotaxis','Code','lib','plotGraphs')))

colors = [0 0 1; 1 0.5 0;0 1 0];% Blue for control, orange for G2019S, green for A53T
fontSizeFigure = 12;
fontNameFigure = 'Arial';


rootDirectory = uigetdir('..','Choose root directory');

[ ~ , nameExp , ~ ] = fileparts( rootDirectory );
switch nameExp
    case 'Control'
      phenotypes_name = {'TH-Gal4 ; +', '+ ; UAS-hLRRK2-G2019S', '+ ; UAS-aSyn-A53T'};
    case 'R58E02G@UPD'
      phenotypes_name = {'R58E02-Gal4 ; +', 'R58E02-Gal4 ; UAS-hLRRK2-G2019S', 'R58E02-Gal4 ; UAS-aSyn-A53T'};
    case 'thG@UPD'
      phenotypes_name = {'TH-Gal4 ; +', 'TH-Gal4 ; UAS-hLRRK2-G2019S', 'TH-Gal4 ; UAS-aSyn-A53T'};
    case 'tshG80thG@UPD'
      phenotypes_name = {'TH-Gal4, tsh-Gal80 ; +', 'TH-Gal4, tsh-Gal80 ; UAS-hLRRK2-G2019S', 'TH-Gal4, tsh-Gal80 ; UAS-aSyn-A53T'};
end
abbrNames={'WT','G2019S','A53T'};


alldirs=cell(size(phenotypes_name));
numberOfHours = 6;
allAverageBouts = zeros(numberOfHours,length(phenotypes_name));
allVarBouts = zeros(numberOfHours,length(phenotypes_name));


allPercBouts = cell(length(phenotypes_name),1);
allNames = cell(length(phenotypes_name),1);
bincounts=cell(size(phenotypes_name));

h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
hold on;

%%load a dir to get the number of file to initialize the variables
dirBouts=dir(fullfile(rootDirectory,'*','Processing',abbrNames{1},'ROI_*','boutsData','boutsPerHour.mat'));

nBoutsHour1=zeros(size(dirBouts,1),length(phenotypes_name));
meanLengthBout_h1=zeros(size(dirBouts,1),length(phenotypes_name));
nBouts_fullExp_perHour=zeros(size(dirBouts,1),length(phenotypes_name));
meanLengthBout_fullExp=zeros(size(dirBouts,1),length(phenotypes_name));
nRestEpisodesHour1=zeros(size(dirBouts,1),length(phenotypes_name));
meanLengthRest_h1=zeros(size(dirBouts,1),length(phenotypes_name));
nRestEpisodes_fullExp=zeros(size(dirBouts,1),length(phenotypes_name));
meanLengthRest_fullExp=zeros(size(dirBouts,1),length(phenotypes_name));

for nGen = 1:length(phenotypes_name)
    dirBouts=dir(fullfile(rootDirectory,'*','Processing',abbrNames{nGen},'ROI_*','boutsData','boutsPerHour.mat'));
    percBoutsPerHour = zeros(numberOfHours,size(dirBouts,1));
    allBoutsPerGenotype = cell(size(dirBouts));
    for nFil = 1:size(dirBouts,1)
        load(fullfile(dirBouts(nFil).folder,dirBouts(nFil).name),'cellBouts');
        cellBouts=cellBouts(1:numberOfHours,:);
        try
            percBoutsPerHour(:,nFil) = cellfun(@(x) sum(x==1)/(sum(x==0)+sum(x==1)),cellBouts.bouts);     

            boutsHour1=cellBouts.bouts{1};
            lengthBouts_h1 = [regionprops(bwlabel(boutsHour1),'Area').Area];
            lengthRest_h1 = [regionprops(bwlabel(boutsHour1==0),'Area').Area];
            nBoutsHour1(nFil,nGen) = numel(lengthBouts_h1)/sum(~isnan(boutsHour1))*600;
            nRestEpisodesHour1(nFil,nGen) = numel(lengthRest_h1)/sum(~isnan(boutsHour1))*600;
            meanLengthBout_h1(nFil,nGen)=mean(lengthBouts_h1);% in seconds
            meanLengthRest_h1(nFil,nGen)=mean(lengthRest_h1);% in seconds

            boutsAllHours = bwlabel(horzcat(cellBouts.bouts{:}));
            lengthBouts_fullExp = [regionprops(bwlabel(boutsAllHours),'Area').Area];
            lengthRest_fullExp = [regionprops(bwlabel(boutsAllHours==0),'Area').Area];
            nBouts_fullExp_perHour(nFil,nGen) = numel(lengthBouts_fullExp)/sum(~isnan(boutsAllHours))*600;
            nRestEpisodes_fullExp(nFil,nGen) = numel(lengthRest_fullExp)/sum(~isnan(boutsAllHours))*600;
            meanLengthBout_fullExp(nFil,nGen)=mean(lengthBouts_fullExp); % in seconds
            meanLengthRest_fullExp(nFil,nGen)=mean(lengthRest_fullExp);% in seconds

        catch
            percBoutsPerHour(:,nFil) = sum(cellBouts.bouts==1,2)./(sum(cellBouts.bouts==0,2)+sum(cellBouts.bouts==1,2));
            
            boutsHour1=cellBouts.bouts(1,:);
            lengthBouts_h1 = [regionprops(bwlabel(boutsHour1),'Area').Area];
            lengthRest_h1 = [regionprops(bwlabel(boutsHour1==0),'Area').Area];
            nBoutsHour1(nFil,nGen) = numel(lengthBouts_h1)/sum(~isnan(boutsHour1))*600;
            nRestEpisodesHour1(nFil,nGen) = numel(lengthRest_h1)/sum(~isnan(boutsHour1))*600;
            meanLengthBout_h1(nFil,nGen)=mean(lengthBouts_h1);% in seconds
            meanLengthRest_h1(nFil,nGen)=mean(lengthRest_h1);% in seconds

            allBouts=cellBouts.bouts(:,:)';
            boutsAllHours = allBouts(:);
            lengthBouts_fullExp = [regionprops(bwlabel(boutsAllHours),'Area').Area];
            lengthRest_fullExp = [regionprops(bwlabel(boutsAllHours==0),'Area').Area];
            nBouts_fullExp_perHour(nFil,nGen) = numel(lengthBouts_fullExp)/sum(~isnan(boutsAllHours))*600;
            nRestEpisodes_fullExp(nFil,nGen) = numel(lengthRest_fullExp)/sum(~isnan(boutsAllHours))*600;
            meanLengthBout_fullExp(nFil,nGen)=mean(lengthBouts_fullExp); % in seconds
            meanLengthRest_fullExp(nFil,nGen)=mean(lengthRest_fullExp);% in seconds

        end
        allBoutsPerGenotype{nFil} = cellBouts;
    end


    
    subplot(2,3,nGen+3)

    binranges = 0:0.2:1;
    % [bincounts{nGen}] = histc(percBoutsPerHour(1,:)+percBoutsPerHour(2,:),binranges);
    [bincounts{nGen}] = histc(percBoutsPerHour(1,:),binranges);

    b=bar(binranges,bincounts{nGen},'histc');
    b(1).FaceColor = colors(nGen,:);
    b(1).FaceAlpha =  0.5;
    ylim([0, 50])
    xlim([0 1])
    xticks(binranges)
    ylabel('# larvae')
    xlabel([{'% time moving'},{'(hour 1)'}])
    set(gca,'FontSize', fontSizeFigure,'FontName',fontNameFigure);
   
    
    
    averBouts = mean(percBoutsPerHour,2);

    allPercBouts{nGen} = percBoutsPerHour(:);
    arrayNames = arrayfun(@(x) [phenotypes_name{nGen} '- h' num2str(x)],1:numberOfHours,'UniformOutput',false);
    namesRep = repmat(arrayNames',size(percBoutsPerHour,2),1);
    allNames{nGen} = namesRep;

    allAverageBouts(:,nGen)=averBouts;

    varBouts = var(percBoutsPerHour,[],2);
    allVarBouts(:,nGen)=varBouts;

    allPerBoutsPerHour{nGen} = percBoutsPerHour';

end




% allDataConcat = horzcat([allPerBoutsPerHour{:}]);
% initIds=[1,7,13];
% indicesReordered = [initIds,initIds+1,initIds+2,initIds+3,initIds+4,initIds+5];
% allDataReorder=mat2cell(allDataConcat(:,indicesReordered), size(allDataConcat, 1), ones(1,size(allDataConcat, 2)));
% 
% yLabel='% bouts';
% minMax_Y_val=[0 1.3];
% tickInterval=0.1;
% category='';
% xTickLabels={'','1h','','','2h','','','3h','','','4h','','','5h','','6h',''};
% 
% h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
% 
% stats_tab=plotBoxChart(allDataReorder,[], colors, category,fontSizeFigure,fontNameFigure,yLabel,minMax_Y_val,tickInterval,xTickLabels);
% legend(phenotypes_name{1},phenotypes_name{2},phenotypes_name{3})


subplot(2,3,1:3)
%Histogram bouts per hour
b=bar(allAverageBouts);
b(1).FaceColor = colors(1,:);
b(1).FaceAlpha =  0.5;
b(2).FaceColor = colors(2,:);
b(2).FaceAlpha =  0.5;
b(3).FaceColor = colors(3,:);
b(3).FaceAlpha =  0.5;

ylim([0 1])
xticks(1:12)
yticks(0:0.1:1)
ylabel('% time [larvae moving]')
xlabel('time - discrete hours')
hold on
errorbar([cellBouts.hour-0.225,cellBouts.hour,cellBouts.hour+0.225],allAverageBouts,allVarBouts,'Color',[0 0 0],'LineStyle','none')
set(gca,'FontSize', fontSizeFigure,'FontName',fontNameFigure);
legend(phenotypes_name{1},phenotypes_name{2},phenotypes_name{3},'','','','Location','northeast')



%ANOVA with Tukey's test
[p,t,stats] = anova1(vertcat(allPercBouts{:}),vertcat(allNames{:}));
[c,m,h,gnames] = multcompare(stats);


%% Bout number
h2 = figure; subplot(2,2,1)
yLabel='# bout episodes / hour';
minMax_Y_val=[0 150];
tickInterval=15;
xTickLabels={'hour 1','full experiment'};
cell_nBoutsHour1=mat2cell(nBoutsHour1, size(nBoutsHour1, 1), ones(1,size(nBoutsHour1, 2)));
cell_nBouts_fullExp_perHour=mat2cell(nBouts_fullExp_perHour, size(nBouts_fullExp_perHour, 1), ones(1,size(nBouts_fullExp_perHour, 2)));
stats_boutEpisodes_tab=plotBoxChart(cell_nBoutsHour1,cell_nBouts_fullExp_perHour, colors,'',fontSizeFigure,fontNameFigure,yLabel,minMax_Y_val,tickInterval,xTickLabels);

%% Bout length
subplot(2,2,2)
yLabel='duration bout (# timepoints)';
minMax_Y_val=[0 160];
tickInterval=10;
xTickLabels={'hour 1','full experiment'};
cell_meanLengthBout_h1=mat2cell(meanLengthBout_h1, size(meanLengthBout_h1, 1), ones(1,size(meanLengthBout_h1, 2)));
cell_meanLengthBout_fullExp=mat2cell(meanLengthBout_fullExp, size(meanLengthBout_fullExp, 1), ones(1,size(meanLengthBout_fullExp, 2)));
stats_boutLength_tab=plotBoxChart(cell_meanLengthBout_h1,cell_meanLengthBout_fullExp, colors,'',fontSizeFigure,fontNameFigure,yLabel,minMax_Y_val,tickInterval,xTickLabels);

%% Rest episodes number
subplot(2,2,3)
yLabel='# rest episodes / hour';
minMax_Y_val=[0 130];
tickInterval=10;
xTickLabels={'hour 1','full experiment'};
cell_nRestHour1=mat2cell(nRestEpisodesHour1, size(nRestEpisodesHour1, 1), ones(1,size(nRestEpisodesHour1, 2)));
cell_nRest_fullExp_perHour=mat2cell(nRestEpisodes_fullExp, size(nRestEpisodes_fullExp, 1), ones(1,size(nRestEpisodes_fullExp, 2)));
stats_restEpisodes_tab=plotBoxChart(cell_nRestHour1,cell_nRest_fullExp_perHour, colors,'',fontSizeFigure,fontNameFigure,yLabel,minMax_Y_val,tickInterval,xTickLabels);

%% Bout length
subplot(2,2,4)
yLabel='duration rest (# timepoints)';
minMax_Y_val=[0 30];
tickInterval=2;
xTickLabels={'hour 1','full experiment'};
cell_meanLengthRest_h1=mat2cell(meanLengthRest_h1, size(meanLengthRest_h1, 1), ones(1,size(meanLengthRest_h1, 2)));
cell_meanLengthRest_fullExp=mat2cell(meanLengthRest_fullExp, size(meanLengthRest_fullExp, 1), ones(1,size(meanLengthRest_fullExp, 2)));
stats_restLength_tab=plotBoxChart(cell_meanLengthRest_h1,cell_meanLengthRest_fullExp, colors,'',fontSizeFigure,fontNameFigure,yLabel,minMax_Y_val,tickInterval,xTickLabels);


% %save figures
% 
% path2save = fullfile('..','results',nameExp);
% if ~exist(path2save,'dir')
%     mkdir(path2save)    
% end
% print(h,fullfile(path2save,['percentage_sleep_bouts_' date '.png']),'-dpng','-r300')
% savefig(h,fullfile(path2save,['percentage_sleep_bouts_' date '.fig']))
% 
% print(h2,fullfile(path2save,['patterns_sleep_bouts_' date '.png']),'-dpng','-r300')
% savefig(h2,fullfile(path2save,['patterns_sleep_bouts_' date '.fig']))
