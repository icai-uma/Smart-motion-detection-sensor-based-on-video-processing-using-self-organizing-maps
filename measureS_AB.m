function res = measureS_AB(path_result, path_groundTruth)

BW = imread(path_result);
GT = imread(path_groundTruth);
GT = GT(:,:,1);
BW = BW(:,:,1);

%if (max(max(GT)) > 40)
    GT_without_outline = GT > 180; % foreground = 1 ; outline (contorno), shadow and background = 0
    %GT = GT > 60; %40; %outline (contorno) and foreground = 1; shadow and background = 0
    GT = GT > 90; %40; %outline (contorno) and foreground = 1; shadow and background = 0
%end
BW = BW > 180; %40;

% class(GT)
% class(GT_without_outline)
%class(BW)



%%% Metrics include outlines in the stats
%AyB = GT.*BW;
%AoB = double((GT+BW) > 0);

%noA_y_noB = (1-GT).*(1-BW);
%noAyB = (1-GT).*BW;
%Ay_noB = GT.*(1-BW);
%%%


%%% Metrics dont include outlines in the stats
% Uncomment the code before and comment this if you want the stats with
% outlines
AyB = GT_without_outline.*BW;
AoB = double((GT_without_outline+BW) > 0);

noA_y_noB = (1-GT).*(1-BW);
noAyB = (1-GT).*BW;
Ay_noB = GT_without_outline.*(1-BW);

outline = (1-GT_without_outline).*GT;
n_outline = numel(nonzeros(outline));
n_foreground = numel(nonzeros(GT_without_outline));
n_shadowBackground = numel(nonzeros(GT-1));
%%%

n_AyB = numel(nonzeros(AyB));
n_noA_y_noB = numel(nonzeros(noA_y_noB));
n_AoB = numel(nonzeros(AoB));
n_noAyB = numel(nonzeros(noAyB));
n_Ay_noB = numel(nonzeros(Ay_noB));


%%% Test the number of pixels, they must be the same
%n_AyB + n_noA_y_noB + n_noAyB + n_Ay_noB + n_outline
%n_outline + n_foreground + n_shadowBackground
%%%

S = n_AyB / (n_AoB + eps);
FP = n_noAyB / (n_AoB + eps);
FN = n_Ay_noB / (n_AoB + eps);

precision = n_AyB / (n_AyB + n_noAyB + eps);
recall = n_AyB / (n_AyB + n_Ay_noB + eps);
accuracy = (n_AyB + n_noA_y_noB) / (n_AyB + n_noA_y_noB + n_noAyB + n_Ay_noB + eps);
fmeasure = 2*((precision*recall)/(precision+recall+eps));

res = [S FP FN precision recall accuracy fmeasure];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
