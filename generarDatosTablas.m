function generarDatosTablas()


%videos={'baseline/highway','baseline/pedestrians','baseline/office',...
%    'baseline/PETS2006','dynamicBackground/canoe','dynamicBackground/fountain02',...
%    'dynamicBackground/fall','intermittentObjectMotion/sofa'};
methods={'MFBM','GrimsonGMM','AdaptiveSOM','WrenGA','ZivkovicGMM'};
segmentedImageName = {'','GrimsonGMM','AdaptiveSOM','WrenGA','ZivkovicGMM'};
segmentedImagePostname = {'in','_Gaus_0.00_','_Gaus_0.00_','_Gaus_0.00_','_Gaus_0.00_'};
segmentedImageExtension = {'jpg','.png','.png','.png','.png'};

videos={'baseline/office','baseline/PETS2006','baseline/highway',...
    'baseline/pedestrians','intermittentObjectMotion/sofa',...
    'dynamicBackground/canoe','dynamicBackground/fountain02',...
    'dynamicBackground/fall'};

NumDif=[50 300 50 50 50 50 50 50];
% %
% methods={'AdaptiveSOM'};
% segmentedImageName = {'AdaptiveSOM'};
% segmentedImagePostname = {'_Gaus_0.00_'};
% segmentedImageExtension = {'.png'};
% videos={'baseline/pedestrians'};
% NumDif=[50];
%
% methods={'AdaptiveSOM','GrimsonGMM'};
% segmentedImageName = {'AdaptiveSOM','GrimsonGMM'};
% segmentedImagePostname = {'_Gaus_0.00_','_Gaus_0.00_'};
% segmentedImageExtension = {'.png','.png'};
% videos={'baseline/highway','baseline/pedestrians'};

% methods={'MFBM'};
% segmentedImageName = {''};
% segmentedImagePostname = {'in'};
% segmentedImageExtension = {'jpg'};
% videos={'baseline/highway','baseline/pedestrians'};

stats=[];

load ('ROC/Datos.mat')

for k=1:length(videos)
    for n=1:length(methods)
        
        
        medias = [0 0 0 0 0 0 0 0];
        cont = 1;
        path_GT = ['../../../../proyectos_matlab/Videos/' videos{k} '/groundtruth' '/'];
        path_BW = ['../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/' methods{n} '/' videos{k} '/'];
        infoFiles = dir(path_GT);
        disp(sprintf('%d-%d',n,k));
        Datos=Detecc{k};
        %Datos=Detecc{4}; %%%%%%%%%%%%%%%%%%%%%quitar
        numel(Datos(1,:))
        numFramesWithRelevantPixels = -1;
        numFrames = 0;
        numNoRelevantFrames = 0;
        
        AntBW = [];
        
        for i=1:length(infoFiles)
            if (infoFiles(i).isdir == 0)
                % Se trata de un fichero
                filename = infoFiles(i).name;
                [pathstr, name, ext] = fileparts(filename);
                % Nos quedamos con aquellos que sean .bmp o .jpg o .png
                if (strcmpi(ext,'.bmp') == 1) || (strcmpi(ext,'.jpg') == 1) || (strcmpi(ext,'.png') == 1)
                    path_img_GT = strcat(path_GT,filename);
                    
                    GT = imread(path_img_GT);
                    
                    numPixelsFrame = numel (GT);
                    numWhitePixelsGT = size(find(GT==255),1);
                    numBlackPixelsGT = size(find(GT==0),1);
                    
                    if strcmpi(methods{n},'MFBM') == 1
                        filename_bw = [segmentedImageName{n} segmentedImagePostname{n} filename(3:end-3) segmentedImageExtension{n}];
                    else
                        filename_bw = [segmentedImageName{n} segmentedImagePostname{n} int2str(str2num(filename(3:end-3))) segmentedImageExtension{n}];
                    end
                    
                    path_img_BW = strcat(path_BW,filename_bw);
                    
                    
                    numFrames = numFrames + 1;
                    
                    if (numWhitePixelsGT > 0 || numBlackPixelsGT > 0) && exist(path_img_BW) % si hay algun pixel del groundtruth con valor 255 o 0,
                        % ademas de que exista su imagen segmentada, entonces analizamos el frame
                        BW = imread(path_img_BW);
                        numWhitePixelsBW = size(find(BW==255),1);
                        numFramesWithRelevantPixels = numFramesWithRelevantPixels + 1;
                        
                        if ~isempty(AntBW)
                            DifBW=abs(AntBW-BW);
                            NumDifBW=sum(sum(DifBW));
                        end
                        
                        %%stats(metodo, video, frame, [tp fn fp tn])
                        if numFramesWithRelevantPixels > 0 && numFramesWithRelevantPixels <= size(Datos(1,:),2)
                            if Datos(1,numFramesWithRelevantPixels) == 1 %detected movement
                                if numWhitePixelsBW/numPixelsFrame >= 2/192 %hit
                                %if NumDifBW>NumDif(k) %hit
                                    stats(n,k,numFramesWithRelevantPixels,1) = 1; %tp = 1;
                                else % miss
                                    stats(n,k,numFramesWithRelevantPixels,2) = 1; %fn = 1;
                                end
                            else %no movement
                                if numWhitePixelsBW/numPixelsFrame >= 2/192 % false alarm
                                %if NumDifBW>NumDif(k) % false alarm
                                    stats(n,k,numFramesWithRelevantPixels,3) = 1; %fp = 1;
                                else % correct rejection
                                    stats(n,k,numFramesWithRelevantPixels,4) = 1; %tn = 1;
                                end
                            end
%                             if numWhitePixelsGT>NumDif(k) %detected movement
%                                 %if numWhitePixelsBW/numPixelsFrame >= 2/192 %hit
%                                 if numWhitePixelsBW>NumDif(k) %hit
%                                     stats(n,k,numFramesWithRelevantPixels,1) = 1; %tp = 1;
%                                 else % miss
%                                     stats(n,k,numFramesWithRelevantPixels,2) = 1; %fn = 1;
%                                 end
%                             else %no movement
%                                 %if numWhitePixelsBW/numPixelsFrame >= 2/192 % false alarm
%                                 if numWhitePixelsBW>NumDif(k) % false alarm
%                                     stats(n,k,numFramesWithRelevantPixels,3) = 1; %fp = 1;
%                                 else % correct rejection
%                                     stats(n,k,numFramesWithRelevantPixels,4) = 1; %tn = 1;
%                                 end
%                             end
%                             if k==2
%                                 disp(sprintf('      %d:%d-%d',numFrames,numWhitePixelsGT,numWhitePixelsBW));
%                             end
                        end
                        AntBW = BW;
                        
                    else
                        numNoRelevantFrames = numNoRelevantFrames + 1;
                    end
                end
            end
        end
        numFramesWithRelevantPixels
        infoVideo(k,1) = numFramesWithRelevantPixels;
        infoVideo(k,2) = numNoRelevantFrames;
        infoVideo(k,3) = numFrames;
    end
end

save('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/stats.mat','stats','-v7.3');
save('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/infoVideo.mat','infoVideo');



