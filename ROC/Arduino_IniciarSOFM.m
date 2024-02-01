function [Result]=Arduino_IniciarSOFM(Model,TrainingSample,NdxStep,Parameters)
% Train a Kohonen's SOFM model, standard version, online learning
Esc=255;

Dimension=size(TrainingSample,1);
% if isempty(Model)
    

    % Inicializacion
    NumNeuro=Parameters.NumRowsMap*Parameters.NumColsMap;
    Model.NumColsMap=Parameters.NumColsMap;
    Model.NumRowsMap=Parameters.NumRowsMap;
    Model.Dimension=Dimension;
    Model.NumNeuro=NumNeuro;
    %Model.Prototypes=zeros(Dimension,Model.NumRowsMap,Model.NumColsMap);

    % Random initialization around the training sample
%     Model.Prototypes=repmat(TrainingSample,[1 Model.NumRowsMap Model.NumColsMap])+...
%         Parameters.InitialSigma*randn(Dimension,Model.NumRowsMap,Model.NumColsMap);
    Model.Prototypes=(fix(Esc.*(repmat(TrainingSample,[1 Model.NumRowsMap Model.NumColsMap])+...
        Parameters.InitialSigma*randn(Dimension,Model.NumRowsMap,Model.NumColsMap))))./Esc;    
    

    [AllXCoords, AllYCoords]=ind2sub([Model.NumRowsMap Model.NumColsMap],1:NumNeuro);
    AllCoords(1,:)=AllXCoords;
    AllCoords(2,:)=AllYCoords;
    DistTopol=cell(1,NumNeuro);
    for NdxNeuro=1:NumNeuro    
        DistTopol{NdxNeuro}=sum((repmat(AllCoords(:,NdxNeuro),1,NumNeuro)-AllCoords).^2,1);
    end
    Model.DistTopol=DistTopol;
% %     
% %     Model.TiedRank=cell(Model.NumRowsMap,Model.NumColsMap);
% %     for NdxNeuron=1:NumNeuro
% %         Model.TiedRank{NdxNeuron}=reshape(tiedrank(DistTopol{NdxNeuron}(:))-1,...
% %             [Model.NumRowsMap Model.NumColsMap]);
% %     end
% else
%     % Training
%     if NdxStep<Parameters.NumStepsOrdering
%         % Ordering phase: linear decay
%         LearningRate=Parameters.InitialLearningRate*(1-NdxStep/Parameters.NumStepsOrdering);
%         MyRadius=Parameters.MaxRadius*(1-(NdxStep-1)/Parameters.NumStepsOrdering);
%     else
%         % Convergence phase: constant
%         LearningRate=Parameters.ConvergenceLearningRate;
%         MyRadius=Parameters.ConvergenceRadius;
%     end
%     
%     SquaredDistances=sum((repmat(TrainingSample,1,Model.NumNeuro)-Model.Prototypes(:,:)).^2,1);
%     [Minimum, NdxWinner]=min(SquaredDistances);
%     Coef=repmat(LearningRate*exp(-Model.DistTopol{NdxWinner}/(MyRadius^2)),Dimension,1);
%     
%     % Update the neurons
%     Model.Prototypes(:,:)=Coef.*repmat(TrainingSample,1,Model.NumNeuro)+(1-Coef).*Model.Prototypes(:,:);
% end

Result=Model;

    
    
        
