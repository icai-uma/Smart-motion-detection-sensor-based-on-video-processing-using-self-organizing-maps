function EvaluarROC()


methods={'MFBM','GrimsonGMM','AdaptiveSOM','WrenGA','ZivkovicGMM'};
segmentedImageName = {'','GrimsonGMM','AdaptiveSOM','WrenGA','ZivkovicGMM'};
segmentedImagePostname = {'in','_Gaus_0.00_','_Gaus_0.00_','_Gaus_0.00_','_Gaus_0.00_'};
segmentedImageExtension = {'jpg','.png','.png','.png','.png'};

videos={'baseline/office','baseline/PETS2006','baseline/highway',...
        'baseline/pedestrians','intermittentObjectMotion/sofa',...
        'dynamicBackground/canoe','dynamicBackground/fountain02',...
        'dynamicBackground/fall'};
    

% methods={'AdaptiveSOM'};
% segmentedImageName = {'AdaptiveSOM'};
% segmentedImagePostname = {'_Gaus_0.00_'};
% segmentedImageExtension = {'.png'};
% videos={'baseline/highway','baseline/pedestrians'};

% methods={'MFBM'};
% segmentedImageName = {''};
% segmentedImagePostname = {'in'};
% segmentedImageExtension = {'jpg'};
% videos={'baseline/highway','baseline/pedestrians'};

roc=[];

for n=1:length(methods)
    for k=1:length(videos)
        medias = [0 0 0 0 0 0 0 0];
        cont = 1;
        path_GT = ['../../../../proyectos_matlab/Videos/' videos{k} '/groundtruth' '/'];
        path_BW = ['../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/' methods{n} '/' videos{k} '/'];
        infoFiles = dir(path_GT);
        disp(sprintf('%d-%d',n,k));
        numFramesWithRelevantPixels = 0;
        numFrames = 0;
        numNoRelevantFrames = 0;
        
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
                        roc(n+1,k,numFramesWithRelevantPixels) = numWhitePixelsBW/numPixelsFrame;
                    else
                        numNoRelevantFrames = numNoRelevantFrames + 1;
                    end
                end
            end
        end
        infoVideo(k,1) = numFramesWithRelevantPixels;
        infoVideo(k,2) = numNoRelevantFrames;
        infoVideo(k,3) = numFrames;
    end    
end
save('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/roc.mat','roc','-v7.3');
save('../../../../proyectos_matlab/Videos/imagenesSegmentadas/arduinoCuadrados/infoVideo.mat','infoVideo');



