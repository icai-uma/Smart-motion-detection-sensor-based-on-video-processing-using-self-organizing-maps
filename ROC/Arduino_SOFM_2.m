clc;
clear;

Detecc=cell(1,8);

for NumVid=1:8

if NumVid == 1
    NameVideo='office';
    IniFrame=570;  
    NumFrames = 2050;
    NumDif=50;
elseif NumVid == 2
    NameVideo='PETS2006';
    IniFrame=300;
    NumFrames = 1200;
    NumDif=300;
elseif NumVid == 3
    NameVideo = 'highway';
    IniFrame=470;  
    NumFrames = 1700;
    NumDif=50;
elseif NumVid == 4
    NameVideo = 'pedestrians';
    IniFrame=300;
    NumFrames = 1099;
    NumDif=50;
elseif NumVid == 5 
    NameVideo = 'sofa';
    IniFrame=500;
    NumFrames = 2750;
    NumDif=50;
elseif NumVid == 6
    NameVideo = 'canoe';
    IniFrame=800;
    NumFrames = 1189;
    NumDif=50;
elseif NumVid == 7
    NameVideo = 'fountain02';
    IniFrame=500;
    NumFrames = 1499;
    NumDif=50;
elseif NumVid == 8
    NameVideo = 'fall';
    IniFrame=1000;
    NumFrames = 4000;
    NumDif=50;
end
    LimitA=1*10^-3;
    LimitB=1*10^-6;
    

disp(['Video: ' NameVideo]);  

Frame=NumFrames;

NdxVideo=1;
Videos = {NameVideo};
NumVideos = length(Videos);
DeltaFrames = 0;
MyVideoName=Videos{NdxVideo};
NumSteps=NumFrames(NdxVideo);
PathOrdenador   = 'C:/Users/Fortega/Dropbox/Trabajo/Ezequiel/Sensores/videos/';
PathVideo       = '%s/input/in%06d.jpg';
PathGround      = '%s/groundtruth/gt%06d.png';

PathG=sprintf([PathOrdenador PathGround],MyVideoName,IniFrame);
AntGround=double( imread(PathG)>1);
Paso=1;

Data=load( ['Modelo_A_' NameVideo '_' num2str(IniFrame) '.mat'],'SOFM1DModels');
SOFM1DModels=Data.SOFM1DModels;

DataB=load( ['Modelo_B_' NameVideo '_' num2str(IniFrame) '.mat'],'SOFM1DModels');
SOFM1DModelsB=DataB.SOFM1DModels;

Parameters.NumRowsMap=3;
Parameters.NumColsMap=4;
Parameters.InitialLearningRate=0.4;
Parameters.MaxRadius=sqrt(Parameters.NumRowsMap*Parameters.NumColsMap)/8;
Parameters.ConvergenceLearningRate=0.01;
Parameters.ConvergenceRadius=1;
Parameters.InitialSigma=0.01;
Parameters.NumStepsOrdering=5000;

NumRowsMaps=12;
NumColsMaps=16;

Minimum   =zeros(NumRowsMaps,NumColsMaps);
NdxWinner =zeros(NumRowsMaps,NumColsMaps);
MaxHisMin =zeros(1,Frame-IniFrame+1); 

Indices=IniFrame+1:Paso:Frame-1;
Deteccion =zeros(3,length(Indices));

i=0;
for NdxStep=Indices
    i=i+1;

    Path=sprintf([PathOrdenador PathVideo],MyVideoName,NdxStep);
    MyFrame = double(imread(Path))/255;
    MyMiniFrame=imresize(MyFrame,[NumRowsMaps NumColsMaps]);
    MyMiniFrame(MyMiniFrame>1)=1;
    
    PathG=sprintf([PathOrdenador PathGround],MyVideoName,NdxStep);
    Ground=double( imread(sprintf(PathG)));
    Ground=double(Ground>1);
    %Ground(:,:,2)=double( imread(sprintf(PathGround,MyVideoName,NdxStep),'png'));
    %Ground(:,:,3)=double( imread(sprintf(PathGround,MyVideoName,NdxStep),'png'));
    
    if NdxStep<Parameters.NumStepsOrdering
        LearningRate=Parameters.InitialLearningRate*(1-NdxStep/Parameters.NumStepsOrdering);
        MyRadius=Parameters.MaxRadius*(1-(NdxStep-1)/Parameters.NumStepsOrdering);
    else
        LearningRate=Parameters.ConvergenceLearningRate;
        MyRadius=Parameters.ConvergenceRadius;
    end
     
GrafMin=zeros(NumRowsMaps,NumColsMaps,3);
GrafPre=zeros(NumRowsMaps,NumColsMaps,3);

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
            
%             GrafPre(NdxRowMap,NdxColMap,:)=[1 1 1].*(Minimum(NdxRowMap,NdxColMap)>LimitA);
        end
    end
    
    DecisionA=max(max(Minimum));
    
    MyMiniFrameB=imresize(MyFrame,[1 1]);
    MyMiniFrameB(MyMiniFrameB>1)=1;
    ModelB=SOFM1DModelsB{1,1};
    SquaredDistancesB=sum((squeeze(MyMiniFrameB)-ModelB.Prototypes).^2);
    MinimumB=SquaredDistancesB; 
    CoefB=LearningRate*exp(-1)/(MyRadius^2);
    ModelB.Prototypes=CoefB.*squeeze(MyMiniFrameB)+(1-CoefB).*ModelB.Prototypes;
    SOFM1DModelsB{1,1}=ModelB;
    %GrafPreB=MinimumB>LimitB;
    
    DifGround=abs(AntGround-Ground);
      
    %DecisionA=fix(sum(sum(sum(GrafPre)))/3)>=2;
    %DecisionB=GrafPreB>=1;
    NumDifGround=sum(sum(DifGround));
    DecisionR=NumDifGround>NumDif;
    
    Deteccion(2,i)=DecisionA;
    Deteccion(3,i)=MinimumB;
    Deteccion(1,i)=DecisionR;
    

    if mod(NdxStep,25)==0
        disp(['Nº Frame=' num2str(NdxStep)]);
     end   
    AntGround=Ground;
end

Detecc{NumVid}=Deteccion;
end

save Datos.mat Detecc
