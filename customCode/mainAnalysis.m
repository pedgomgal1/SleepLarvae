clear all
close all
warning 'off'

addpath(genpath('src'))

allGenotypes={'WT','G2019S','A53T'};
rootDirectory = uigetdir('..','Choose root directory');

alldirs=cell(size(allGenotypes));

allAverageBouts = zeros(12,length(allGenotypes));
allVarBouts = zeros(12,length(allGenotypes));
h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
hold on;

allPercBouts = cell(length(allGenotypes),1);
allNames = cell(length(allGenotypes),1);

for nGen = 1:length(allGenotypes)
    dirBouts=dir(fullfile(rootDirectory,'*','Processing',allGenotypes{nGen},'ROI_*','boutsData','boutsPerHour.mat'));
    percBoutsPerHour = zeros(12,size(dirBouts,1));
    for nFil = 1:size(dirBouts,1)
        load(fullfile(dirBouts(nFil).folder,dirBouts(nFil).name),'cellBouts');
        percBoutsPerHour(:,nFil) = cellfun(@(x) sum(x==1)/(sum(x==0)+sum(x==1)),cellBouts.bouts);        
    end


    averBouts = mean(percBoutsPerHour,2);

    allPercBouts{nGen} = percBoutsPerHour(:);
    arrayNames = arrayfun(@(x) [allGenotypes{nGen} '_' num2str(x) 'h'],1:12,'UniformOutput',false);
    namesRep = repmat(arrayNames',size(percBoutsPerHour,2),1);
    allNames{nGen} = namesRep;

    allAverageBouts(:,nGen)=averBouts;

    varBouts = var(percBoutsPerHour,[],2);
    allVarBouts(:,nGen)=varBouts;

end

%Histogram bouts per hour

bar(allAverageBouts)
ylim([0 1])
xticks(1:12)
yticks(0:0.1:1)
ylabel('activity / resting proportion')
xlabel('hour')
legend(allGenotypes)
hold on
errorbar([cellBouts.hour-0.225,cellBouts.hour,cellBouts.hour+0.225],allAverageBouts,allVarBouts,'Color',[0 0 0],'LineStyle','none')
set(gca,'FontSize', 24,'FontName','Helvetica');
set(gca,'innerposition');

% exportgraphics(ax,fullfile(path2save,['heatMap_varianceVolume_Gland_' date '.png']),'Resolution',600)


%ANOVA with Tukey's test
[p,t,stats] = anova1(vertcat(allPercBouts{:}),vertcat(allNames{:}));
[c,m,h,gnames] = multcompare(stats);


