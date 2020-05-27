load('ms.mat');
% % % load('behav.mat');
v1 = 0;
v2 = 0;
try
    load('msTouchSync.mat');
    v1 = 1;
    v2 = 0;
end
try
    load('msTouchSync_new.mat');
    v1 = 0;
    v2 = 1;
end
try 
    ms = calcium;
end
% ms = calcium;
if v1    
    timediff = diff(msTouchSync.timeMap);
    timediffnew = timediff(find(timediff));
    fps = round(1/mode(timediffnew));
    events = msTouchSync.events;
elseif v2
    timediff = diff(synchronization.miniscopeMaster.cageTimes);
    timediffnew = timediff(find(timediff));
    fps = round(1/mode(timediffnew));
    events = synchronization.miniscopeMaster.events;
end
ticmultiplier = 2;


% -------------STEP 3) Reliability ---------------

% Step1: Align data to Anchor points
% Generate raster plots for all trials and all cells

[Calcium, TrialInds,rawSep,rawCalcium] = TouchRaster_V4(events,ms,fps,1,1,1,1,1,1);
save('TouchRasterResults.mat','Calcium','TrialInds')
save('UncutTraces.mat','rawSep','rawCalcium')
load('minmax.mat')
load('SepDelay.mat')
load('SepFront.mat')
load('SepBack.mat')

% Step2: Find Reliable Cell
% Cells that pass criteria
ShuffledCrit = TouchScreenShuffle(ms,events,TrialInds);
ShuffledCritSep = TouchScreenShuffleSeperation_V2(SepDelay,SepFront,SepBack,ms,TrialInds,events);
save('ShuffledCrit.mat','ShuffledCrit','ShuffledCritSep')

%Figure1: Seqence of population data
%Delay
[Dcorrectmean,rastsort] = sortpeaks(nanmean(ShuffledCrit.DcorrectPassed,3));
Dincorrectmean = nanmean(Calcium.Dincorrect(ShuffledCrit.DcorrectCells,:,:),3);
Dincorrectmean = Dincorrectmean(rastsort,:,:);
Dcorcorrectmean =nanmean(Calcium.DcorrectCor(ShuffledCrit.DcorrectCells,:,:),3);
Dcorcorrectmean = Dcorcorrectmean(rastsort,:,:);
Dcorincorrectmean =nanmean(Calcium.DincorrectCor(ShuffledCrit.DcorrectCells,:,:),3);
Dcorincorrectmean = Dcorincorrectmean(rastsort,:,:);

meanmaxvalc = max(max(Dcorrectmean));
meanmaxvali = max(max(Dincorrectmean));
meanmaxvalcc = max(max(Dcorcorrectmean));
meanmaxvalic = max(max(Dcorincorrectmean));

meanminvalc = min(min(Dcorrectmean));
meanminvali = min(min(Dincorrectmean));
meanminvalcc = min(min(Dcorcorrectmean));
meanminvalic = min(min(Dcorincorrectmean));

meanmaxval = max([meanmaxvalc,meanmaxvali,meanmaxvalic,meanmaxvalcc]);
meanminval = max([meanminvalc,meanminvali,meanminvalic,meanminvalcc]);

figure(1)
colormap parula
subplot(2,2,1)
if ~isempty(Dcorrectmean)
    imagesc(Dcorrectmean)
    xticks(1:fps:length(Dcorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Dcorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Dcorrectmean(:,1))/10):length(Dcorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Delay: Correct Mean Fluorescence')
colorbar
caxis([meanminval meanmaxval])
subplot(2,2,2)
if ~isempty(Dincorrectmean)
    imagesc(Dincorrectmean)
    xticks(1:fps:length(Dincorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Dincorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Dincorrectmean(:,1))/10):length(Dincorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Delay: Incorrect Mean Fluorescence')
colorbar
caxis([meanminval meanmaxval])
subplot(2,2,3)
if ~isempty(Dcorcorrectmean)
    imagesc(Dcorcorrectmean)
    xticks(1:fps:length(Dcorcorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Dcorcorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Dcorcorrectmean(:,1))/10):length(Dcorcorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Delay: Correct Correction Mean Fluorescence')
colorbar
caxis([meanminval meanmaxval])
subplot(2,2,4)
if ~isempty(Dcorincorrectmean)
    imagesc(Dcorincorrectmean)
    xticks(1:fps:length(Dcorincorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Dcorincorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Dcorincorrectmean(:,1))/10):length(Dcorincorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Delay: Incorrect Correction Mean Fluorescence')
colorbar
caxis([meanminval meanmaxval])
saveas(figure(1),'Delay/Delay_PassedCriteria.fig')

if isempty(Dcorincorrectmean) || (nansum(nansum(Dcorincorrectmean))) == 0
    IncCor = false;
else
    IncCor = true;
end
%Front Anchored

[Fcorrectmean,rastsort] = sortpeaks(nanmean(ShuffledCrit.FcorrectPassed,3));
Fincorrectmean = nanmean(Calcium.Fincorrect(ShuffledCrit.FcorrectCells,:,:),3);
Fincorrectmean = Fincorrectmean(rastsort,:,:);
Fcorcorrectmean =nanmean(Calcium.FcorrectCor(ShuffledCrit.FcorrectCells,:,:),3);
Fcorcorrectmean = Fcorcorrectmean(rastsort,:,:);
if ~isempty(Calcium.FincorrectCor)
Fcorincorrectmean =nanmean(Calcium.FincorrectCor(ShuffledCrit.FcorrectCells,:,:),3);
Fcorincorrectmean = Fcorincorrectmean(rastsort,:,:);
else
    Fcorincorrectmean = [];
end

figure(1)
colormap parula
subplot(2,2,1)
if ~isempty(Fcorrectmean)
    imagesc(Fcorrectmean)
    xticks(1:fps:length(Fcorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Fcorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Fcorrectmean(:,1))/10):length(Fcorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Front Anchored: Correct Mean Fluorescence')
colorbar
subplot(2,2,2)
if ~isempty(Fincorrectmean)
    imagesc(Fincorrectmean)
    xticks(1:fps:length(Fincorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Fincorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Fincorrectmean(:,1))/10):length(Fincorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Front Anchored: Incorrect Mean Fluorescence')
colorbar
subplot(2,2,3)
if ~isempty(Fcorcorrectmean)
    imagesc(Fcorcorrectmean)
    xticks(1:fps:length(Fcorcorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Fcorcorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Fcorcorrectmean(:,1))/10):length(Fcorcorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Front Anchored: Correct Correction Mean Fluorescence')
colorbar
subplot(2,2,4)
if ~isempty(Fcorincorrectmean)
    imagesc(Fcorincorrectmean)
    xticks(1:fps:length(Fcorincorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Fcorincorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Fcorincorrectmean(:,1))/10):length(Fcorincorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Front Anchored: Incorrect Correction Mean Fluorescence')
colorbar
saveas(figure(1),'FrontAnchored/Front_PassedCriteria.fig')

%Back Anchored
%sort cells by firing order for the correct trials and keep same cell order
%across all trial types
[Bcorrectmean,rastsort] = sortpeaks(nanmean(ShuffledCrit.BcorrectPassed,3));
Bincorrectmean = nanmean(Calcium.Bincorrect(ShuffledCrit.BcorrectCells,:,:),3);
Bincorrectmean = Bincorrectmean(rastsort,:,:);
Bcorcorrectmean =nanmean(Calcium.BcorrectCor(ShuffledCrit.BcorrectCells,:,:),3);
Bcorcorrectmean = Bcorcorrectmean(rastsort,:,:);
if ~isempty(Calcium.BincorrectCor)
Bcorincorrectmean =nanmean(Calcium.BincorrectCor(ShuffledCrit.BcorrectCells,:,:),3);
Bcorincorrectmean = Bcorincorrectmean(rastsort,:,:);
else    
    Bcorincorrectmean = [];   
end

figure(1)
colormap parula
subplot(2,2,1)
if ~isempty(Bcorrectmean)
    imagesc(Bcorrectmean)
    vline(length(Bcorrectmean(1,:)) - 450,'g')
    xticks(1:fps:length(Bcorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Bcorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Bcorrectmean(:,1))/10):length(Bcorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Back Anchored: Correct Mean Fluorescence')
colorbar
subplot(2,2,2)
if ~isempty(Bincorrectmean)
    imagesc(Bincorrectmean)
    vline(length(Bincorrectmean(1,:)) - 450,'r')
    xticks(1:fps:length(Bincorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Bincorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Bincorrectmean(:,1))/10):length(Bincorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Back Anchored: Incorrect Mean Fluorescence')
colorbar
subplot(2,2,3)
if ~isempty(Bcorcorrectmean)
    imagesc(Bcorcorrectmean)
    vline(length(Bcorcorrectmean(1,:)) - 450,'g')
    xticks(1:fps:length(Bcorcorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Bcorcorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Bcorcorrectmean(:,1))/10):length(Bcorcorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Back Anchored: Correct Correction Mean Fluorescence')
colorbar
subplot(2,2,4)
if ~isempty(Bcorincorrectmean)
    imagesc(Bcorincorrectmean)
    xticks(1:fps:length(Bcorincorrectmean(1,:)));
    xticklabels(Frame2SecLabels(length(Bcorincorrectmean(1,:)),fps,ticmultiplier));
    yticks(1:round(length(Bcorincorrectmean(:,1))/10):length(Bcorincorrectmean(:,1)));
end
ylabel('Cell')
xlabel('Time (Seconds)')
title('Back Anchored: Incorrect Correction Mean Fluorescence')
colorbar
saveas(figure(1),'BackAnchored/Back_PassedCriteria.fig')

%Figure2: Population Representation of task contingencies
figure(1)
%Delay
Dcorrectpop = avgfluo(minmax(ShuffledCrit.DcorrectCells,:),ShuffledCrit.DcorrectPassed);
Dincorrectpop = avgfluo(minmax(ShuffledCrit.DcorrectCells,:),Calcium.Dincorrect(ShuffledCrit.DcorrectCells,:,:));
Dcorcorrectpop = avgfluo(minmax(ShuffledCrit.DcorrectCells,:),Calcium.DcorrectCor(ShuffledCrit.DcorrectCells,:,:));
if IncCor
Dcorincorrectpop = avgfluo(minmax(ShuffledCrit.DcorrectCells,:),Calcium.DincorrectCor(ShuffledCrit.DcorrectCells,:,:));
else
    Dcorincorrectpop = 0;
end
figure(1)
colormap parula
subplot(2,2,1)
if ~isempty(Dcorrectpop)
    plot(Dcorrectpop)
    xticks(1:fps:length(Dcorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Dcorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Dcorrectpop(:,1))/3):length(Dcorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Delay: Correct Population Level Fluorescence')
subplot(2,2,2)
if ~isempty(Dincorrectpop)
    plot(Dincorrectpop)
    xticks(1:fps:length(Dincorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Dincorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Dincorrectpop(:,1))/3):length(Dincorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Delay: Incorrect Population Level Fluorescence')
subplot(2,2,3)
if ~isempty(Dcorcorrectpop)
    plot(Dcorcorrectpop)
    xticks(1:fps:length(Dcorcorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Dcorcorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Dcorcorrectpop(:,1))/3):length(Dcorcorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Delay: Correct Correction Population Level Fluorescence')
subplot(2,2,4)
if ~isempty(Dcorincorrectpop)
    plot(Dcorincorrectpop)
    xticks(1:fps:length(Dcorincorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Dcorincorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Dcorincorrectpop(:,1))/3):length(Dcorincorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Delay: Incorrect Correction Population Level Fluorescence')
saveas(figure(1),'Delay/Delay_PassedCriteriaPOPULATION.fig')
%Front Anchored
Fcorrectpop = avgfluo(minmax(ShuffledCrit.FcorrectCells,:),ShuffledCrit.FcorrectPassed);
Fincorrectpop = avgfluo(minmax(ShuffledCrit.FcorrectCells,:),Calcium.Fincorrect(ShuffledCrit.FcorrectCells,:,:));
Fcorcorrectpop = avgfluo(minmax(ShuffledCrit.FcorrectCells,:),Calcium.FcorrectCor(ShuffledCrit.FcorrectCells,:,:));
if IncCor
Fcorincorrectpop = avgfluo(minmax(ShuffledCrit.FcorrectCells,:),Calcium.Fincorrect(ShuffledCrit.FcorrectCells,:,:));
else
    Fcorincorrectpop = 0;
end

figure(1)
colormap parula
subplot(2,2,1)
if ~isempty(Fcorrectpop)
    plot(Fcorrectpop)
    xticks(1:fps:length(Fcorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Fcorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Fcorrectpop(:,1))/3):length(Fcorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Front Anchored: Correct Population Level Fluorescence')
subplot(2,2,2)
if ~isempty(Fincorrectpop)
    plot(Fincorrectpop)
    xticks(1:fps:length(Fincorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Fincorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Fincorrectpop(:,1))/3):length(Fincorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Front Anchored: Incorrect Population Level Fluorescence')
subplot(2,2,3)
if ~isempty(Fcorcorrectpop)
    plot(Fcorcorrectpop)
    xticks(1:fps:length(Fcorcorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Fcorcorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Fcorcorrectpop(:,1))/3):length(Fcorcorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Front Anchored: Correct Correction Population Level Fluorescence')
subplot(2,2,4)
if ~isempty(Fcorincorrectpop)
    plot(Fcorincorrectpop)
    xticks(1:fps:length(Fcorincorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Fcorincorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Fcorincorrectpop(:,1))/3):length(Fcorincorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Front Anchored: Incorrect Correction Population Level Fluorescence')
saveas(figure(1),'FrontAnchored/Front_PassedCriteriaPOPULATION.fig')

% Back Anchored
Bcorrectpop = avgfluo(minmax(ShuffledCrit.BcorrectCells,:),ShuffledCrit.BcorrectPassed);
Bincorrectpop = avgfluo(minmax(ShuffledCrit.BcorrectCells,:),Calcium.Bincorrect(ShuffledCrit.BcorrectCells,:,:));
Bcorcorrectpop = avgfluo(minmax(ShuffledCrit.BcorrectCells,:),Calcium.BcorrectCor(ShuffledCrit.BcorrectCells,:,:));
if IncCor
    Bcorincorrectpop = avgfluo(minmax(ShuffledCrit.BcorrectCells,:),Calcium.Bincorrect(ShuffledCrit.BcorrectCells,:,:));
else
    Bcorincorrectpop = 0;
end

figure(1)
colormap parula
subplot(2,2,1)
if ~isempty(Bcorrectpop)
    plot(Bcorrectpop)
    vline(length(Bcorrectpop) - 450,'g')
    xticks(1:fps:length(Bcorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Bcorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Bcorrectpop(:,1))/3):length(Bcorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Back Anchored: Correct Population Level Fluorescence')
subplot(2,2,2)
if ~isempty(Bincorrectpop)
    plot(Bincorrectpop)
    xticks(1:fps:length(Bincorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Bincorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Bincorrectpop(:,1))/3):length(Bincorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Back Anchored: Incorrect Population Level Fluorescence')
subplot(2,2,3)
if ~isempty(Bcorcorrectpop)
    plot(Bcorcorrectpop)
    vline(length(Bcorcorrectpop) - 450,'g')
    xticks(1:fps:length(Bcorcorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Bcorcorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Bcorcorrectpop(:,1))/3):length(Bcorcorrectpop(:,1)));
end
ylabel('Mean Fluerescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Back Anchored: Correct Correction Population Level Fluorescence')
subplot(2,2,4)
if ~isempty(Bcorincorrectpop)
    plot(Bcorincorrectpop)
    xticks(1:fps:length(Bcorincorrectpop(1,:)));
    xticklabels(Frame2SecLabels(length(Bcorincorrectpop(1,:)),fps,ticmultiplier));
    yticks(0:round(length(Bcorincorrectpop(:,1))/3):length(Bcorincorrectpop(:,1)));
end
ylabel('Mean Fluorescence Activity')
ylim([0 1])
xlabel('Time (Seconds)')
title('Back Anchored: Incorrect Correction Population Level Fluorescence')
saveas(figure(1),'BackAnchored/Back_PassedCriteriaPOPULATION.fig')
clf

%% -----------STEP 4): Memeory related firing ---------------

%Step1: Which cell passed criteria based on choice location
%Figure1: Sample selected activity of individual cells
n = 4;
m = 4;

%Delay
%find all choices
choices = PokeFind(SepDelay);
count = 1;
for i = 1 : length(choices)
    %Correct
    if ~isempty(SepDelay.CorrectTrial{choices(i)})
        passedcorrectD = SepDelay.CorrectTrial{choices(i)}(:,:,ShuffledCritSep.DcorrectCells{choices(i)});
        for j = 1 : ShuffledCritSep.DcorrectNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.DcorrectCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedcorrectD(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.DcorrectCells{choices(i)}(j),1) minmax(ShuffledCritSep.DcorrectCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedcorrectD(1,:)));
            xticklabels(Frame2SecLabels(length(passedcorrectD(1,:)),fps,ticmultiplier));
            yticks(1:3:length(passedcorrectD(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Correct: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.DcorrectNumberPassed{choices(i)}
                pause(0.01)
                count = 1;                
                saveas(gcf,[pwd,'/Delay/ChoiceSeperation/CorrectTrials/',num2str(choices(i)),'/', num2str(cellNum),'CorrectTrials.jpg']);
                clf
            end
        end
    else
        passedcorrectD = [];
    end
    %Incorrect
    if ~isempty(SepDelay.IncorrectTrial{choices(i)})
        passedincorrectD = SepDelay.IncorrectTrial{choices(i)}(:,:,ShuffledCritSep.DincorrectCells{choices(i)});
        for j = 1 : ShuffledCritSep.DincorrectNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.DincorrectCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedincorrectD(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.DincorrectCells{choices(i)}(j),1) minmax(ShuffledCritSep.DincorrectCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedincorrectD(1,:)));
            xticklabels(Frame2SecLabels(length(passedincorrectD(1,:)),fps,ticmultiplier));
            yticks(1:length(passedincorrectD(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Incorrect: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.DincorrectNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/Delay/ChoiceSeperation/IncorrectTrials/',num2str(choices(i)),'/', num2str(cellNum),'IncorrectTrials.jpg']);
                clf
            end
        end
    else
        passedincorrectD = [];
    end
    %Correct Correction
    if ~isempty(SepDelay.CorrectCorrectionTrial{choices(i)})
        passedcorrectcorrectionD = SepDelay.CorrectCorrectionTrial{choices(i)}(:,:,ShuffledCritSep.DccorCells{choices(i)});
        for j = 1 : ShuffledCritSep.DccorNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.DccorCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedcorrectcorrectionD(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.DccorCells{choices(i)}(j),1) minmax(ShuffledCritSep.DccorCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedcorrectcorrectionD(1,:)));
            xticklabels(Frame2SecLabels(length(passedcorrectcorrectionD(1,:)),fps,ticmultiplier));
            yticks(1:length(passedcorrectcorrectionD(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Correct Correction: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.DccorNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/Delay/ChoiceSeperation/CorrectCorrectionTrials/',num2str(choices(i)),'/', num2str(cellNum),'CorrectCorrectionTrials.jpg']);
                clf
            end
        end
    else
        passedcorrectcorrectionD = [];
    end
    %Incorrect Correction
    if IncCor && ~isempty(SepDelay.IncorrectCorrectionTrial{choices(i)})
        passedincorrectcorrectionD = SepDelay.IncorrectCorrectionTrial{choices(i)}(:,:,ShuffledCritSep.DicorCells{choices(i)});
        for j = 1 : ShuffledCritSep.DicorNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.DicorCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedincorrectcorrectionD(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.DicorCells{choices(i)}(j),1) minmax(ShuffledCritSep.DicorCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedincorrectcorrectionD(1,:)));
            xticklabels(Frame2SecLabels(length(passedincorrectcorrectionD(1,:)),fps,ticmultiplier));
            yticks(1:length(passedincorrectcorrectionD(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Incorrect Correction: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.DicorNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/Delay/ChoiceSeperation/IncorrectCorrectionTrials/',num2str(choices(i)),'/', num2str(cellNum),'IncorrectCorrectionTrials.jpg']);
                clf
            end
        end
    else
        passedincorrectcorrectionD =[];
    end
    meancDpop = sortpeaks(permute(mean(passedcorrectD,1),[3 2 1]));
    meaniDpop = sortpeaks(permute(mean(passedincorrectD,1),[3 2 1]));
    meanccorDpop = sortpeaks(permute(mean(passedcorrectcorrectionD,1),[3 2 1]));
    if IncCor
    meanicorDpop = sortpeaks(permute(mean(passedincorrectcorrectionD,1),[3 2 1]));
    else
        meanicorDpop = [];
    end
    maxvalc = max(max(meancDpop));
    maxvali = max(max(meaniDpop));
    maxvalcc = max(max(meanccorDpop));
    maxvalic = max(max(meanicorDpop));
    
    minvalc = min(min(meancDpop));
    minvali = min(min(meaniDpop));
    minvalcc = min(min(meanccorDpop));
    minvalic = min(min(meanicorDpop));
    
    maxval = max([maxvalc,maxvali,maxvalic,maxvalcc]);
    minval = min([minvalc,minvali,minvalic,minvalcc]);
    
    figure(1)
    subplot(2,2,1)
    if ~isempty(meancDpop)
        imagesc(meancDpop)
        xticks(1:fps:length(meancDpop(1,:)));
        xticklabels(Frame2SecLabels(length(meancDpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meancDpop(:,1))/10):length(meancDpop(:,1)));
        xlabel('Time(Seconds)')
        ylabel('Cell ID')
        title('Delay: Correct Mean Fluorescence')
        colorbar
        caxis([minval maxval])
    end
    
    subplot(2,2,2)
    if ~isempty(meaniDpop)
        imagesc(meaniDpop)
        xticks(1:fps:length(meaniDpop(1,:)));
        xticklabels(Frame2SecLabels(length(meaniDpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meaniDpop(:,1))/10):length(meaniDpop(:,1)));
        xlabel('Time(Seconds)')
        ylabel('Cell ID')
        title('Delay: Incorrect Mean Fluorescence')
    end
    
    subplot(2,2,3)
    if ~isempty(meanccorDpop)
        imagesc(meanccorDpop)
        colorbar
        caxis([minval maxval])
        xticks(1:fps:length(meanccorDpop(1,:)));
        xticklabels(Frame2SecLabels(length(meanccorDpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meanccorDpop(:,1))/10):length(meanccorDpop(:,1)));
        xlabel('Time(Seconds)')
        ylabel('Cell ID')
        title('Delay: Correct Correction Mean Fluorescence')
    end
    
    subplot(2,2,4)
    
    if ~isempty(meanicorDpop)
        imagesc(meanicorDpop)
        colorbar
        caxis([minval maxval])
        xticks(1:fps:length(meanicorDpop(1,:)));
        xticklabels(Frame2SecLabels(length(meanicorDpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meanicorDpop(:,1))/10):length(meanicorDpop(:,1)));
        xlabel('Time(Seconds)')
        ylabel('Cell ID')
        title('Delay: Incorrect Correction Mean Fluorescence')
    end
    
    saveas(gcf,[pwd,'/Delay/ChoiceSeperation_',num2str(choices(i)),'_PopulationRasterPlot.fig']);
    clf    
end

%Front Anchored
choices = PokeFind(SepFront);
count = 1;
for i = 1 : length(choices)
    %Correct
    if ~isempty(SepFront.CorrectTrial{choices(i)})
        passedcorrectF = SepFront.CorrectTrial{choices(i)}(:,:,ShuffledCritSep.FcorrectCells{choices(i)});
        for j = 1 : ShuffledCritSep.FcorrectNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.FcorrectCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedcorrectF(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.FcorrectCells{choices(i)}(j),1) minmax(ShuffledCritSep.FcorrectCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedcorrectF(1,:)));
            xticklabels(Frame2SecLabels(length(passedcorrectF(1,:)),fps,ticmultiplier));
            yticks(1:3:length(passedcorrectF(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Correct: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.FcorrectNumberPassed{choices(i)}
                pause(0.01)
                count = 1;                
                saveas(gcf,[pwd,'/FrontAnchored/ChoiceSeperation/CorrectTrials/',num2str(choices(i)),'/', num2str(cellNum),'CorrectTrials.jpg']);
                clf
            end
        end
    else
        passedcorrectF = [];        
    end
    %Incorrect
    if ~isempty(SepFront.IncorrectTrial{choices(i)})
        passedincorrectF = SepFront.IncorrectTrial{choices(i)}(:,:,ShuffledCritSep.FincorrectCells{choices(i)});
        for j = 1 : ShuffledCritSep.FincorrectNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.FincorrectCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedincorrectF(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.FincorrectCells{choices(i)}(j),1) minmax(ShuffledCritSep.FincorrectCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedincorrectF(1,:)));
            xticklabels(Frame2SecLabels(length(passedincorrectF(1,:)),fps,ticmultiplier));
            yticks(1:length(passedincorrectF(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Incorrect: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.FincorrectNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/FrontAnchored/ChoiceSeperation/IncorrectTrials/',num2str(choices(i)),'/', num2str(cellNum),'IncorrectTrials.jpg']);
                clf
            end
        end
    else
        passedincorrectF = [];
    end
    %Correct Correction
    if ~isempty(SepFront.CorrectCorrectionTrial{choices(i)})
        passedcorrectcorrectionF = SepFront.CorrectCorrectionTrial{choices(i)}(:,:,ShuffledCritSep.FccorCells{choices(i)});
        for j = 1 : ShuffledCritSep.FccorNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.FccorCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedcorrectcorrectionF(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.FccorCells{choices(i)}(j),1) minmax(ShuffledCritSep.FccorCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedcorrectcorrectionF(1,:)));
            xticklabels(Frame2SecLabels(length(passedcorrectcorrectionF(1,:)),fps,ticmultiplier));
            yticks(1:length(passedcorrectcorrectionF(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Correct Correction: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.FccorNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/FrontAnchored/ChoiceSeperation/CorrectCorrectionTrials/',num2str(choices(i)),'/', num2str(cellNum),'CorrectCorrectionTrials.jpg']);
                clf
            end
        end
    else
        passedcorrectcorrectionF = [];
    end
    %Incorrect Correction
    if IncCor && ~isempty(SepFront.IncorrectCorrectionTrial{choices(i)})
        passedincorrectcorrectionF = SepFront.IncorrectCorrectionTrial{choices(i)}(:,:,ShuffledCritSep.FicorCells{choices(i)});
        for j = 1 : ShuffledCritSep.FicorNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.FicorCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedincorrectcorrectionF(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.FicorCells{choices(i)}(j),1) minmax(ShuffledCritSep.FicorCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedincorrectcorrectionF(1,:)));
            xticklabels(Frame2SecLabels(length(passedincorrectcorrectionF(1,:)),fps,ticmultiplier));
            yticks(1:3:length(passedincorrectcorrectionF(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Incorrect Correction: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.FicorNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/FrontAnchored/ChoiceSeperation/IncorrectCorrectionTrials/',num2str(choices(i)),'/', num2str(cellNum),'IncorrectCorrectionTrials.jpg']);
                clf
            end
        end
    else
        passedincorrectcorrectionF = [];
    end
    meancFpop = sortpeaks(permute(mean(passedcorrectF,1),[3 2 1]));
    meaniFpop = sortpeaks(permute(mean(passedincorrectF,1),[3 2 1]));
    meanccorFpop = sortpeaks(permute(mean(passedcorrectcorrectionF,1),[3 2 1]));
    if IncCor
        meanicorFpop = sortpeaks(permute(mean(passedincorrectcorrectionF,1),[3 2 1]));
    else
        meanicorFpop = [];
    end
    figure(1)
    subplot(2,2,1)
    imagesc(meancFpop)
    if ~isempty(meancFpop)
        xticks(1:fps:length(meancFpop(1,:)));
        xticklabels(Frame2SecLabels(length(meancFpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meancFpop(:,1))/10):length(meancFpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Front Anchored: Correct Mean Fluorescence')
    subplot(2,2,2)
    imagesc(meaniFpop)
    if ~isempty(meaniFpop)
        xticks(1:fps:length(meaniFpop(1,:)));
        xticklabels(Frame2SecLabels(length(meaniFpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meaniFpop(:,1))/10):length(meaniFpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Front Anchored: Incorrect Mean Fluorescence')
    subplot(2,2,3)
    imagesc(meanccorFpop)
    if ~isempty(meanccorFpop)
        xticks(1:fps:length(meanccorFpop(1,:)));
        xticklabels(Frame2SecLabels(length(meanccorFpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meanccorFpop(:,1))/10):length(meanccorFpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Front Anchored: Correct Correction Mean Fluorescence')
    subplot(2,2,4)
    imagesc(meanicorFpop)
    if ~isempty(meanicorFpop)
        xticks(1:fps:length(meanicorFpop(1,:)));
        xticklabels(Frame2SecLabels(length(meanicorFpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meanicorFpop(:,1))/10):length(meanicorFpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Front Anchored: Incorrect Correction Mean Fluorescence')
    saveas(gcf,[pwd,'/FrontAnchored/ChoiceSeperation_',num2str(choices(i)),'_PopulationRasterPlot.fig']);
    clf  
end

%Back Anchored
choices = PokeFind(SepBack);
count = 1;
for i = 1 : length(choices)
    %Correct
    if ~isempty(SepBack.CorrectTrial{choices(i)})
        passedcorrectB = SepBack.CorrectTrial{choices(i)}(:,:,ShuffledCritSep.BcorrectCells{choices(i)});
        for j = 1 : ShuffledCritSep.BcorrectNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.BcorrectCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedcorrectB(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.BcorrectCells{choices(i)}(j),1) minmax(ShuffledCritSep.BcorrectCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedcorrectB(1,:)));
            xticklabels(Frame2SecLabels(length(passedcorrectB(1,:)),fps,ticmultiplier));
            yticks(1:3:length(passedcorrectB(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Correct: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.BcorrectNumberPassed{choices(i)}
                pause(0.01)
                count = 1;                
                saveas(gcf,[pwd,'/BackAnchored/ChoiceSeperation/CorrectTrials/',num2str(choices(i)),'/', num2str(cellNum),'CorrectTrials.jpg']);
                clf
            end
        end
    else
        passedcorrectB = [];
    end
    %Incorrect
    if ~isempty(SepBack.IncorrectTrial{choices(i)})
        passedincorrectB = SepBack.IncorrectTrial{choices(i)}(:,:,ShuffledCritSep.BincorrectCells{choices(i)});
        for j = 1 : ShuffledCritSep.BincorrectNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.BincorrectCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedincorrectB(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.BincorrectCells{choices(i)}(j),1) minmax(ShuffledCritSep.BincorrectCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedincorrectB(1,:)));
            xticklabels(Frame2SecLabels(length(passedincorrectB(1,:)),fps,ticmultiplier));
            yticks(1:length(passedincorrectB(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Incorrect: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.BincorrectNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/BackAnchored/ChoiceSeperation/IncorrectTrials/',num2str(choices(i)),'/', num2str(cellNum),'IncorrectTrials.jpg']);
                clf
            end
        end
    else
        passedincorrectB = [];
    end
    %Correct Correction
    if ~isempty(SepBack.CorrectCorrectionTrial{choices(i)})
        passedcorrectcorrectionB = SepBack.CorrectCorrectionTrial{choices(i)}(:,:,ShuffledCritSep.BccorCells{choices(i)});
        for j = 1 : ShuffledCritSep.BccorNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.BccorCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedcorrectcorrectionB(:,:,j));
            axis('tight')
            colormap('parula')
            colorbar
            caxis([minmax(ShuffledCritSep.BccorCells{choices(i)}(j),1) minmax(ShuffledCritSep.BccorCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedcorrectcorrectionB(1,:)));
            xticklabels(Frame2SecLabels(length(passedcorrectcorrectionB(1,:)),fps,ticmultiplier));
            yticks(1:length(passedcorrectcorrectionB(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Correct Correction: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.BccorNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/BackAnchored/ChoiceSeperation/CorrectCorrectionTrials/',num2str(choices(i)),'/', num2str(cellNum),'CorrectCorrectionTrials.jpg']);
                clf
            end
        end
    else
        passedcorrectcorrectionB = [];
    end
    %Incorrect Correction
    if IncCor && ~isempty(SepBack.IncorrectCorrectionTrial{choices(i)})
        passedincorrectcorrectionB = SepBack.IncorrectCorrectionTrial{choices(i)}(:,:,ShuffledCritSep.BicorCells{choices(i)});
        for j = 1 : ShuffledCritSep.BicorNumberPassed{choices(i)}
            cellNum = ShuffledCritSep.BicorCells{choices(i)}(j);
            figure(1)
            subplot(n,m,count)
            count = count +1;
            h = imagesc(passedincorrectcorrectionB(:,:,j));
            axis('tight')
            colormap('parula') 
            colorbar
            caxis([minmax(ShuffledCritSep.BicorCells{choices(i)}(j),1) minmax(ShuffledCritSep.BicorCells{choices(i)}(j),2)])
            view(2)
            xticks(1:fps:length(passedincorrectcorrectionB(1,:)));
            xticklabels(Frame2SecLabels(length(passedincorrectcorrectionB(1,:)),fps,ticmultiplier));
            yticks(1:length(passedincorrectcorrectionB(:,1)));
            xlabel('Time(Seconds)')
            ylabel('Trial')
            title(['Passed Criteria Incorrect Correction: Cell ',num2str(cellNum)])
            if mod(j,n*m) == 0 || j == ShuffledCritSep.BicorNumberPassed{choices(i)}
                pause(0.01)
                count = 1;
                saveas(gcf,[pwd,'/BackAnchored/ChoiceSeperation/IncorrectCorrectionTrials/',num2str(choices(i)),'/', num2str(cellNum),'IncorrectCorrectionTrials.jpg']);
                clf
            end
        end
    else
        passedincorrectcorrectionB = [];
    end
    %Figure2: Sample selective activity in the population
    meancBpop = sortpeaks(permute(mean(passedcorrectB,1),[3 2 1]));
    meaniBpop = sortpeaks(permute(mean(passedincorrectB,1),[3 2 1]));
    meanccorBpop = sortpeaks(permute(mean(passedcorrectcorrectionB,1),[3 2 1]));
    if IncCor
        meanicorBpop = sortpeaks(permute(mean(passedincorrectcorrectionB,1),[3 2 1]));
    else
        meanicorBpop = [];
    end
    
    figure(1)
    subplot(2,2,1)
    imagesc(meancBpop)
    if ~isempty(meancBpop)
        xticks(1:fps:length(meancBpop(1,:)));
        xticklabels(Frame2SecLabels(length(meancBpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meancBpop(:,1))/10):length(meancBpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Back Anchored: Correct Mean Fluorescence')
    subplot(2,2,2)
    imagesc(meaniBpop)
    if ~isempty(meaniBpop)
        xticks(1:fps:length(meaniBpop(1,:)));
        xticklabels(Frame2SecLabels(length(meaniBpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meaniBpop(:,1))/10):length(meaniBpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Back Anchored: Incorrect Mean Fluorescence')
    subplot(2,2,3)
    imagesc(meanccorBpop)
    if ~isempty(meanccorBpop)
        xticks(1:fps:length(meanccorBpop(1,:)));
        xticklabels(Frame2SecLabels(length(meanccorBpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meanccorBpop(:,1))/10):length(meanccorBpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Back Anchored: Correct Correction Mean Fluorescence')
    subplot(2,2,4)
    imagesc(meanicorBpop)
    if ~isempty(meanicorBpop)
        xticks(1:fps:length(meanicorBpop(1,:)));
        xticklabels(Frame2SecLabels(length(meanicorBpop(1,:)),fps,ticmultiplier));
        yticks(1:round(length(meanicorBpop(:,1))/10):length(meanicorBpop(:,1)));
    end
    xlabel('Time(Seconds)')
    ylabel('Cell ID')
    title('Back Anchored: Incorrect Correction Mean Fluorescence')
    saveas(gcf,[pwd,'/BackAnchored/ChoiceSeperation_',num2str(choices(i)),'_PopulationRasterPlot.fig']);
    clf  
end

%Step2: Correct vs Incorrect Trial comparison
%Figure1: Visual Comparison of correct vs all other Trials at the
%individual cell level
%Figure2: Visal comparison of correct vs all other tirals at the population
%level

%Delay
DisplayComp(SepDelay,minmax,'Delay',ShuffledCrit.DcorrectCells);
%Front Anchored
DisplayComp(SepFront,minmax,'FrontAnchored',ShuffledCrit.FcorrectCells);
%Back Anchored
DisplayComp(SepBack,minmax,'BackAnchored',ShuffledCrit.BcorrectCells);
%}
clf
%Figure4: Locating the source of the error signal
%Delay
confInterD = ErrorSource(SepDelay,1,pwd,ShuffledCrit.DcorrectCells);
%Front Anchored
confInterF = ErrorSource(SepFront,2,pwd,ShuffledCrit.FcorrectCells);
%Back Anchored
confInterB = ErrorSource(SepBack,3,pwd,ShuffledCrit.BcorrectCells);

%Figure3: Comparison of correlation values between correct and incorrect
%trials

%Delay
metric1D = tMetric1(SepDelay,1);
metric2D = tMetric2(SepDelay);
count = 1;
for i = 1 : length(metric1D)
    for j = 1 : length(metric1D)
        if i == j && ~isempty(metric1D{i,j})
            figure(1)
            cdfplot(metric2D(:,count))
            hold on
            if ~isempty(metric1D{i,j}.Incorrect)
                cdfplot(metric1D{i,j}.Incorrect)
            end
            title('Delay CDF plot')
            legend('Metric2: Control Correct subset comparison','Metric1: correlation between incorrect and correct')
            count = count+1;
            saveas(gcf, [pwd,'/Delay/ConfidenceIntervals/CDFplot_Choice_',num2str(i),'.jpg'])
            pause(0.01);
            clf
        end
    end
end
%FrontAnchored
metric1F = tMetric1(SepFront,2);
metric2F = tMetric2(SepFront);
count = 1;
for i = 1 : length(metric1F)
    for j = 1 : length(metric1F)
        if i == j && ~isempty(metric1F{i,j})
            figure(1)
            cdfplot(metric2F(:,count))
            hold on
            if ~isempty(metric1F{i,j}.Incorrect)
                cdfplot(metric1F{i,j}.Incorrect)
            end
            
            title('Front Anchored CDF plot')
            legend('Metric2: Control Correct subset comparison','Metric1: correlation between incorrect and correct')
            count = count+1;
            saveas(gcf, [pwd,'/FrontAnchored/ConfidenceIntervals/CDFplot_Choice_',num2str(i),'.jpg'])
            pause(0.01);
            clf
        end
    end
end
%BackAnchored
metric1B = tMetric1(SepBack,3);
metric2B = tMetric2(SepBack);
count = 1;
for i = 1 : length(metric1B)
    for j = 1 : length(metric1B)
        if i == j && ~isempty(metric1B{i,j})
            figure(1)
            cdfplot(metric2B(:,count))
            hold on
            if ~isempty(metric1B{i,j}.Incorrect)
                cdfplot(metric1B{i,j}.Incorrect)
            end
            title('Back Anchored CDF plot')
            legend('Metric2: Control Correct subset comparison','Metric1: correlation between incorrect and correct')
            count = count+1;
            saveas(gcf, [pwd,'/BackAnchored/ConfidenceIntervals/CDFplot_Choice_',num2str(i),'.jpg'])
            pause(0.01);
            clf
        end
    end
end


%-------------------STEP 5------------------------

% % % out = step_5(ms,behav,msTouchSync.events,groupID,item_name,eventTime,eventInd); 

