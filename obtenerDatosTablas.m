clear all
close all

%previamente se ha ejecutado generarDatosTablas

load('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/stats.mat');
load('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/infoVideo.mat');

ListDatasets={'Office','PETS2006','Highway','Pedestrians','Sofa','Canoe','Fountain02','Fall'};
Methods={'MaddalenaSOBS','GrimsonGMM','WrenGA','ZivkovicGMM','MFBM'};

%load data and generate stats
for NdxMethod=1:size(stats,1) %method
    for NdxVideo=1:size(stats,2) %video
        numFramesWithRelevantPixels = infoVideo(NdxVideo,1) - 1
        %numNoRelevantFrames = infoVideo(NdxVideo,2);
        %numFrames = infoVideo(NdxVideo,3);
        %disp(sprintf('%d-%d-%d-%d-%d',NdxMethod,NdxVideo,numFramesWithRelevantPixels,numNoRelevantFrames,numFrames));
        disp(sprintf('%d-%d-%d',NdxMethod,NdxVideo,numFramesWithRelevantPixels));
        %el ultimo frame no se tiene en cuenta para el calculo
        %el primer frame se elimino al ejecutar generarDatosTablas
        tp(NdxVideo,NdxMethod) = sum(stats(NdxMethod,NdxVideo,1:end-1,1))/numFramesWithRelevantPixels;
        fn(NdxVideo,NdxMethod) = sum(stats(NdxMethod,NdxVideo,1:end-1,2))/numFramesWithRelevantPixels;
        fp(NdxVideo,NdxMethod) = sum(stats(NdxMethod,NdxVideo,1:end-1,3))/numFramesWithRelevantPixels;
        tn(NdxVideo,NdxMethod) = sum(stats(NdxMethod,NdxVideo,1:end-1,4))/numFramesWithRelevantPixels;
        
        disp(sprintf('tp: %f',tp(NdxVideo,NdxMethod)));
        disp(sprintf('fn: %f',fn(NdxVideo,NdxMethod)));
        disp(sprintf('fp: %f',fp(NdxVideo,NdxMethod)));
        disp(sprintf('tn: %f',tn(NdxVideo,NdxMethod)));
        
        recall(NdxVideo,NdxMethod) = tp(NdxVideo,NdxMethod) / (tp(NdxVideo,NdxMethod) + fn(NdxVideo,NdxMethod)); %tpr
        specificity(NdxVideo,NdxMethod) = tn(NdxVideo,NdxMethod) / (tn(NdxVideo,NdxMethod) + fp(NdxVideo,NdxMethod)); %tnr
        fpr(NdxVideo,NdxMethod) = fp(NdxVideo,NdxMethod) / (fp(NdxVideo,NdxMethod) + tn(NdxVideo,NdxMethod));
        fnr(NdxVideo,NdxMethod) = fn(NdxVideo,NdxMethod) / (tp(NdxVideo,NdxMethod) + fn(NdxVideo,NdxMethod));
        pbc(NdxVideo,NdxMethod) = 100*(fn(NdxVideo,NdxMethod)+fp(NdxVideo,NdxMethod))/(tp(NdxVideo,NdxMethod)+fn(NdxVideo,NdxMethod)+fp(NdxVideo,NdxMethod)+tn(NdxVideo,NdxMethod));
        precision(NdxVideo,NdxMethod) = tp(NdxVideo,NdxMethod)/(tp(NdxVideo,NdxMethod)+fp(NdxVideo,NdxMethod));
        fmeasure(NdxVideo,NdxMethod) = 2*recall(NdxVideo,NdxMethod)*precision(NdxVideo,NdxMethod)/(recall(NdxVideo,NdxMethod)+precision(NdxVideo,NdxMethod));
        
    end
end

xlswrite('stats_recall.xlsx',recall);
xlswrite('stats_specificity.xlsx',specificity);
xlswrite('stats_fpr.xlsx',fpr);
xlswrite('stats_fnr.xlsx',fnr);
xlswrite('stats_pbc.xlsx',pbc);
xlswrite('stats_precision.xlsx',precision);
xlswrite('stats_fmeasure.xlsx',fmeasure);






