clear all
close all
warning 'off'

%1. Split original images in individual wells per genotype
addpath(genpath('src'))

allGenotypes={'WT','G2019S','A53T'};
rootDirectory = uigetdir('..','Choose root directory');

alldirs=cell(size(allGenotypes));

allAverageBouts = zeros(12,length(allGenotypes));
allVarBouts = zeros(12,length(allGenotypes));

figure;hold on;
for nGen = 1:length(allGenotypes)
    dirBouts=dir(fullfile(rootDirectory,'*','Processing',allGenotypes{nGen},'ROI_*','boutsData','boutsPerHour.mat'));
    percBoutsPerHour = zeros(12,size(dirBouts,1));
    for nFil = 1:size(dirBouts,1)
        load(fullfile(dirBouts(nFil).folder,dirBouts(nFil).name),'cellBouts');
        percBoutsPerHour(:,nFil) = cellfun(@(x) sum(x==1)/(sum(x==0)+sum(x==1)),cellBouts.bouts);        
    end

    averBouts = mean(percBoutsPerHour,2);
    allAverageBouts(:,nGen)=averBouts;

    varBouts = var(percBoutsPerHour,[],2);
    allVarBouts(:,nGen)=varBouts;

end

bar(allAverageBouts)
ylim([0 1])
ylabel('activity / sleep bouts proportion')
xlabel('hour')
legend(allGenotypes)
hold on
errorbar([cellBouts.hour-0.225,cellBouts.hour,cellBouts.hour+0.225],allAverageBouts,allVarBouts,'Color',[0 0 0],'LineStyle','none')

%Histogram bouts per hour

