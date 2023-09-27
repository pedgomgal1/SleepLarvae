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
    percBoutsPerHour = zeros(6,size(dirBouts,1));
    allBoutsPerGenotype = cell(size(dirBouts));
    for nFil = 1:size(dirBouts,1)
        load(fullfile(dirBouts(nFil).folder,dirBouts(nFil).name),'cellBouts');
        percBoutsPerHour(:,nFil) = cellfun(@(x) sum(x==1)/(sum(x==0)+sum(x==1)),cellBouts.bouts);     
        allBoutsPerGenotype{nFil} = cellBouts;
    end

%     figure
%     binranges = 0:0.05:2;
%     [bincounts] = histc(percBoutsPerHour(1,:)+percBoutsPerHour(2,:),binranges);
%     bar(binranges,bincounts,'histc');


    averBouts = mean(percBoutsPerHour,2);

    allPercBouts{nGen} = percBoutsPerHour(:);
    arrayNames = arrayfun(@(x) [allGenotypes{nGen} '_' num2str(x) 'h'],1:12,'UniformOutput',false);
    namesRep = repmat(arrayNames',size(percBoutsPerHour,2),1);
    allNames{nGen} = namesRep;

    allAverageBouts(:,nGen)=averBouts;

    varBouts = var(percBoutsPerHour,[],2);
    allVarBouts(:,nGen)=varBouts;

end

% %Histogram bouts per hour
% b=bar(allAverageBouts);
% b(1).FaceColor = [0 0 1];
% b(2).FaceColor = [1 0.5 0];
% b(3).FaceColor = [0 1 0];
% 
% 
% ylim([0 1])
% xticks(1:12)
% yticks(0:0.1:1)
% ylabel('activity / resting proportion')
% xlabel('hour')
% hold on
% errorbar([cellBouts.hour-0.225,cellBouts.hour,cellBouts.hour+0.225],allAverageBouts,allVarBouts,'Color',[0 0 0],'LineStyle','none')
% set(gca,'FontSize', 18,'FontName','Arial');
% set(gca,'innerposition');
% legend('Control','G2019S','A53T','','','')
% 
% path2save = '../data/12h';
% print(h,fullfile(path2save,['sleep_bouts_' date '.png']),'-dpng','-r300')
% savefig(h,fullfile(path2save,['sleep_bouts_' date '.fig']))

%ANOVA with Tukey's test
[p,t,stats] = anova1(vertcat(allPercBouts{:}),vertcat(allNames{:}));
[c,m,h,gnames] = multcompare(stats);


