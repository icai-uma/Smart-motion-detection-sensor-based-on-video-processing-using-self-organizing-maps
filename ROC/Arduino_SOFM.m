% SOM demo, pixel color data, online version
clear;
clc;

% NameVideo='office';
% NameVideo='PETS2006';
%NameVideo='highway';
%NameVideo='pedestrians';
%NameVideo='sofa';
%NameVideo='canoe';
%NameVideo='fountain02';
NameVideo='fall';

TxT='A';
%TxT='B';

if TxT=='A'
    NumRowsMaps=12;
    NumColsMaps=16;
    Parameters.NumRowsMap=3;
    Parameters.NumColsMap=4;
else
    NumRowsMaps=1;
    NumColsMaps=1;
    Parameters.NumRowsMap=1;
    Parameters.NumColsMap=1;
end

if strcmp(NameVideo,'PETS2006')
    Frames=300;
    NumFrames = 1200;
elseif strcmp(NameVideo,'office')
    Frames=570;
    NumFrames = 2050;
elseif strcmp(NameVideo,'highway')
    Frames=470;
    NumFrames = 1700;
elseif strcmp(NameVideo,'pedestrians')
    Frames=300;
    NumFrames = 1099;
elseif strcmp(NameVideo,'sofa')
    Frames=500;
    NumFrames = 2750;
elseif strcmp(NameVideo,'canoe')
    Frames=800;
    NumFrames = 1189;
elseif strcmp(NameVideo,'fountain02')
    Frames=500;
    NumFrames = 1499;
elseif strcmp(NameVideo,'fall')
    Frames=1000;
    NumFrames = 4000;
end




NdxVideo=1;
Videos = {NameVideo};
NumVideos = length(Videos);
PathVideo = '%s/input/in%06d.jpg';
DeltaFrames = 0;
MyVideoName=Videos{NdxVideo};
NumSteps=NumFrames(NdxVideo);

% Parameters.NumRowsMap=3;
% Parameters.NumColsMap=4;
Parameters.InitialLearningRate=0.4;
Parameters.MaxRadius=sqrt(Parameters.NumRowsMap*Parameters.NumColsMap)/8;
Parameters.ConvergenceLearningRate=0.01;
Parameters.ConvergenceRadius=1;
Parameters.InitialSigma=0.001;
Parameters.NumStepsOrdering=5000;


% Original SOFM, 1D
tic
MyFrame = double(imread(sprintf(PathVideo,MyVideoName,DeltaFrames(NdxVideo)+1)))/255;
MyMiniFrame=imresize(MyFrame,[NumRowsMaps NumColsMaps]);
SOFM1DModels=cell(NumRowsMaps,NumColsMaps);
for NdxRowMap=1:NumRowsMaps
    for NdxColMap=1:NumColsMaps
        SOFM1DModels{NdxRowMap,NdxColMap}=Arduino_IniciarSOFM([],squeeze(MyMiniFrame(NdxRowMap,NdxColMap,:)),0,Parameters);
    end
end

SampleLog=zeros(3,NumRowsMaps,NumColsMaps,NumSteps);

for NdxStep=1:Frames
    if mod(NdxStep,10)==0
        disp(NdxStep);
    end
    MyFrame = double(imread(sprintf(PathVideo,MyVideoName,DeltaFrames(NdxVideo)+NdxStep+1)))/255;
    MyMiniFrame=imresize(MyFrame,[NumRowsMaps NumColsMaps]);
    MyMiniFrame(MyMiniFrame>1)=1;
    
    if NdxStep<Parameters.NumStepsOrdering
        LearningRate=Parameters.InitialLearningRate*(1-NdxStep/Parameters.NumStepsOrdering);
        MyRadius=Parameters.MaxRadius*(1-(NdxStep-1)/Parameters.NumStepsOrdering);
    else
        LearningRate=Parameters.ConvergenceLearningRate;
        MyRadius=Parameters.ConvergenceRadius;
    end
    
    Minimum   =zeros(NumRowsMaps,NumColsMaps);
    NdxWinner =zeros(NumRowsMaps,NumColsMaps);
    for NdxRowMap=1:NumRowsMaps
        for NdxColMap=1:NumColsMaps
            MyTrainingSample=squeeze(MyMiniFrame(NdxRowMap,NdxColMap,:));
            
            Dimension=size(MyTrainingSample,1);
            Model=SOFM1DModels{NdxRowMap,NdxColMap};
            SquaredDistances=sum((repmat(MyTrainingSample,1,Model.NumNeuro)-Model.Prototypes(:,:)).^2,1);
            [Minimum(NdxRowMap,NdxColMap), NdxWinner(NdxRowMap,NdxColMap)]=min(SquaredDistances);
            Coef=repmat(LearningRate*exp(-Model.DistTopol{NdxWinner(NdxRowMap,NdxColMap)}/(MyRadius^2)),Dimension,1);
            % Update the neurons
            Model.Prototypes(:,:)=Coef.*repmat(MyTrainingSample,1,Model.NumNeuro)+(1-Coef).*Model.Prototypes(:,:);         
            SOFM1DModels{NdxRowMap,NdxColMap}=Model;
            
            SampleLog(:,NdxRowMap,NdxColMap,NdxStep)=MyTrainingSample;
        end
    end
end

save (['Modelo_' TxT '_' NameVideo '_' num2str(Frames) '.mat'], 'SOFM1DModels')


% figure(1);imagesc(MyFrame);
% figure(2);imagesc(MyMiniFrame);
% 
% GrafNeu=zeros(Parameters.NumRowsMap*(NumRowsMaps-1)+Parameters.NumRowsMap,Parameters.NumColsMap*(NumColsMaps-1)+Parameters.NumColsMap,3);
% 
% for PixA=1:NumRowsMaps
%     for PixB=1:NumColsMaps
%         
%         for A=1:Parameters.NumRowsMap
%              for B=1:Parameters.NumColsMap
%                 GA=Parameters.NumRowsMap*(PixA-1)+A;
%                 GB=Parameters.NumColsMap*(PixB-1)+B;
%                 GrafNeu(GA,GB,:)=SOFM1DModels{PixA,PixB}.Prototypes(:,A,B);
%              end
%         end
%     end
% end
% 
% GrafNeu(GrafNeu>1)=1;
% figure(3);imagesc(GrafNeu);
% 
% toc




