% load fisheriris
% pred = meas(51:end,1:2);
% resp = (1:100)'>50;
% mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');
% scores = mdl.Fitted.Probability;
% [X,Y,T,AUC] = perfcurve(species(51:end,:),scores,'virginica');


clear;
close all;
load('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/infoVideo.mat');
load('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/roc.mat');
load ('ROC/Datos.mat')


Nv={'office             ','PETS2006    ','highway        ','pedestrians  ', 'sofa              ','canoe           ','fountain02    ','fall                '};
Auc=zeros(1,8);
colors = distinguishable_colors(8);
Methods={'MaddalenaSOBS','GrimsonGMM','WrenGA','ZivkovicGMM','MFBM'};

for NdxMethod=1:size(Methods,2) 
    figure
    hold on;
    for i=1:8; % i =NdxVideo
        Datos=Detecc{i};
        BW = shiftdim(roc(NdxMethod+1,i,:),1);

        [X,Y,T,Auc(i)]=perfcurve(Datos(1,:),BW(1+1:infoVideo(i,1)-1),1);
        plot(X,Y,'LineWidth',1,'Color',colors(i,:));hold on;
    end
    xlabel('False positive rate')
    ylabel('True positive rate')
    % title ('ROC for Classification')
    Leg=legend([Nv{1} 'AUC = ' num2str(Auc(1))],[Nv{2} 'AUC = ' num2str(Auc(2))],[Nv{3} 'AUC = ' num2str(Auc(3))],[Nv{4} 'AUC = ' num2str(Auc(4))],...
        [Nv{5} 'AUC = ' num2str(Auc(5))],[Nv{6} 'AUC = ' num2str(Auc(6))],[Nv{7} 'AUC = ' num2str(Auc(7))],[Nv{8} 'AUC = ' num2str(Auc(8))]);
    set(Leg,'Location','southeast');
    
    set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    
    saveas(gcf, ['FigROC_' Methods{NdxMethod} '.pdf'])
    %open(['FigROC_' Methods{NdxMethod} '.pdf'])
end

