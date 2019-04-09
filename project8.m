clear all
close all
clc
warning('off')
scrsz = get(groot,'ScreenSize');
addpath('./Images','./SupportFunctions','./Templates')


%% Define parameter, global variables and chosen example
global MIN_NUM_INLIER MAX_NUM_BOX image_BW image_RGB template_BW template_RGB...
    showExternalBoxImage showDegenerateBoxImage showROIimage showWarpedBox...
    isize1 isize2 ssize1 ssize2 showHistograms MAX_NUM_TRIAL

% Operational parameter
MIN_NUM_INLIER = 10;
MAX_NUM_BOX = Inf;

MAX_NUM_TRIAL = 100000;

MAX_DISTEUC = 0.25;
percent_eu = 30;

MAX_DISTHIST = 0.1;
perc_dist_hist= 200;

MIN_SSIMVAL = 0.4;
percent_ssim = 25;

% Choose the type of distance measurement. This can be either set to
% 'euclidean' or 'ssim' 
imageChooser = 'euclidean';


% Choice of the boolean values. This can be changed in order to show/hide
% images
showFeaturesImages = false;
showMatchedFeaturesFigure = false;
showExternalBoxImage = false;
showDegenerateBoxImage = false;
showROIimage = true;
showWarpedBox = true;
showHistograms = true;
ShowBoxesEqualizzati = true;

% Button form to le the user decide the example he wants to run
inputOptions={'1) Image 1 with blue coffe', '2) Image 1 with red coffee',...
    '3) Image 2 with blue coffee', '4) Image 3 with blue coffee','5) Image 4 with Choco Barchette',...
    '6) Image 4 with Choco numberz'}; 
iSel=bttnChoiseDialog(inputOptions, 'Example Chooser', ...
    'Which example would you like to run?', [6 1]); 
fprintf( 'User selection "%s"\n', inputOptions{iSel});
inputImages = int2str(iSel);


%% Load the images and turn into grayscale

switch inputImages
    % Normal example
    case '1'
        image_RGB = im2double(imread('Images/caffe_tagliato.jpg'));
        template_RGB =im2double(imread('Templates/caffe_blu.jpg'));
        image_BW = rgb2gray(image_RGB);
        template_BW = rgb2gray(template_RGB);
        
    case '2'
        % Algorithm detects differences in color
        image_RGB = im2double(imread('Images/caffe_tagliato.jpg'));
        template_RGB =im2double(imread('Templates/caffe_rosso_2.jpg'));
        image_BW = rgb2gray(image_RGB);
        template_BW = rgb2gray(template_RGB);
        
        
    case '3'
        % Algorithm detects a high number of boxes and correctly selects the
        % right ones. The image is frontal
        image_RGB = im2double(imread('Images/img_caffe2.jpg'));
        template_RGB =im2double(imread('Templates/caffe_blu.jpg'));
        image_BW = rgb2gray(image_RGB);
        template_BW = rgb2gray(template_RGB);
        
        
    case '4'
        % Starting from a perspective image, the algorithm detects a high 
        % number of boxes and correctly selects the right ones; 
        image_RGB = im2double(imread('Images/img_caffe1.jpg'));
        template_RGB =im2double(imread('Templates/caffe_blu.jpg'));
        image_BW = rgb2gray(image_RGB);
        template_BW = rgb2gray(template_RGB);
         
    case '5'
        % Cereal boxes found also if there are some shades
        image_RGB = im2double(imread('Images/image.jpg'));
        template_RGB =im2double(imread('Templates/choco.png'));
        image_BW = rgb2gray(image_RGB);
        template_BW = rgb2gray(template_RGB);
        
   case '6' 
        % Cereal boxes in perspective, perfect detection of the boxes
        image_RGB = im2double(imread('Images/image.jpg'));
        template_RGB =im2double(imread('Templates/template1.png'));
        image_BW = rgb2gray(image_RGB);
        template_BW = rgb2gray(template_RGB);
                      
end

% Compute the extreme limit of the image
img_borders = [0,0; size(image_BW,2), 0; size(image_BW,2), size(image_BW,1);...
    0, size(image_BW,1)];
isize1 = size(image_RGB,1); % height of the RGB image
isize2 = size(image_RGB,2); % width of the RGB image
ssize1 = size(template_RGB,1); % height of the RGB template
ssize2 = size(template_RGB,2); % width of the RGB template

%% Detect and Extract features for both images

% Extract feature and points of template
feature_template = detectSURFFeatures(template_BW,'MetricThreshold',2000);
%feature_template = detectSURFFeatures(template_BW);

[features_t, t_valid_points] = extractFeatures(template_BW, feature_template);

% Extract feature and points of image
feature_image = detectSURFFeatures(image_BW);
[features_i, i_valid_points] = extractFeatures(image_BW, feature_image);

showFeatures(template_BW, image_BW, t_valid_points, i_valid_points, showFeaturesImages)

% Create a KDTree
MdlKDT = KDTreeSearcher(features_t);

% Find the two nearest neighbour and their distance from feature
[matches,D] = knnsearch(MdlKDT,features_i,'k',2);

% Apply a ratio test
[indexFirstMatch, indexSecondMatch] = findGoodMatches(matches,D);

% Display of the first and second nearest feature that satisfy ratio test
showMatchedFeature(feature_image, feature_template, ...
    indexFirstMatch, indexSecondMatch, showMatchedFeaturesFigure);

%% Find and extract the ROI where there is a feature match

% Extract matched features of image and template
final_features_image = feature_image(indexFirstMatch(:,1));
final_features_template = feature_template(indexFirstMatch(:,2));
all_polygons = [];
all_transf = [];

% Create a polygon of the size of the template
boxPolygon = [1, 1;...                              % top-left
    size(template_BW, 2), 1;...                     % top-right
    size(template_BW, 2), size(template_BW, 1);...  % bottom-right
    1, size(template_BW, 1);...                     % bottom-left
    1, 1];                                          % top-left again to close the polygon


% Find all the ROI in the image
[all_polygons, all_transf] = locateObjectsImage(final_features_template, final_features_image,...
    boxPolygon, all_polygons, all_transf);

% Show all the Region of interest found in the image
figure
imshow(image_BW)
for i = 1 : 2 :length(all_polygons)-1
    line(all_polygons(:, i), all_polygons(:, i+1), 'Color', 'r', 'LineWidth', 2);
    title('Detected Box','FontSize',15);
    xlabel('Click any button to go on with the execution','FontSize',15)
end
waitforbuttonpress


%% Find the regions of interest in the image and rectify them

images=zeros(isize1,isize2,3,length(all_polygons));

% Extract and warp the ROI found before, in order to be comparable with the
% template
[images]=findROIofImage(all_polygons, images);
[immagini] = warpROIFound(all_transf, images);


% Show all the rectified region of interest. The firs box is the template
figure
montage(immagini);
title('Rectified boxes','FontSize',15);
xlabel('The first box contains the template and it can be comapred with the ROI found in the image.',...
    'FontSize',10);

%% BW equalization of template and objects
% Images in B/W are equalized to make them more similar and easier to
% compare. If the images are in BW is easier to detect differences between
% them

immagini_BW=zeros(size(template_BW,1),size(template_BW,2),1,size(immagini,4));
immagini_BW(:,:,:,1)= template_BW;
for i=2:size(immagini,4)
    immagini_BW(:,:,:,i) = rgb2gray(immagini(:,:,:,i));
end

boxes_equalizzati_BW = zeros(size(template_BW,1),size(template_BW,2),1,size(immagini,4));
boxes_equalizzati_BW(:,:,:,1) = template_BW;

%eqaulize pictures
for i = 2 : size(immagini,4)
    boxes_equalizzati_BW(:,:,1,i) = imhistmatch(immagini(:,:,1,i), template_BW,256);    
end

if ShowBoxesEqualizzati
    figure
    montage(boxes_equalizzati_BW, 'size', [1 size(boxes_equalizzati_BW,4)]);
    title('Boxes B/W equalized','FontSize',15)
end

%% Choice of the right region of interest

% Swithc between 2 cases:
% 1) select minimum eculidean distance between template e object,that gives
% as a result the most simila ROI. If this value is higher that a certain
% treshold then it means that there are no occurences of the template in
% the image. If the value is lower than the treshold MAX_DISTEUC we select
% that distance value, we calculate a percentage variation of this value
% (using percent_eu parameter)
% and we select only the objects that have a distance lower than the limit
% value we found.
% 2) the switch allows to do the same with the SSIM distance. This passage
%has been used a test to chek if our computation with the euclidea distance
%were correct. 

switch imageChooser
    
    case 'euclidean'
         %compute the distances between template and all the ROI
         for i = 1 : size(boxes_equalizzati_BW,4)
            for j = 1 : size(boxes_equalizzati_BW,4)
                Dist_euc_boxes_BW(i,j) = euclidean_distance2(boxes_equalizzati_BW(:,:,:,i), ...
                    boxes_equalizzati_BW(:,:,:,j));
            end
            
         end
        %removing the first column to avoid indexes problems
        Dist_euc_boxes_BW_notemp = Dist_euc_boxes_BW(1, 2:end);
        %compare the distances
        %no match is found if any image has a distance from the template
        %lower than a certain treshold
        if min(Dist_euc_boxes_BW) > MAX_DISTEUC
            
            figure('Position',[scrsz(3)/10 scrsz(4)/10 scrsz(3)/1.25 scrsz(4)/1.25]);
            text(0.5, 0.5, "The template selected can't be found in the image",...
                'FontSize',40, 'Color','k','HorizontalAlignment',...
                'Center', 'VerticalAlignment','Middle')
            axis off
            
        else
            % look for the distances
            % work on black and white pictures for an easier detection of
            % the differences
            
            %find the index of the minimal distance and the related
            %distance
            index_reference_value = find(Dist_euc_boxes_BW_notemp == min(Dist_euc_boxes_BW_notemp));
            distanza_ref_temp = Dist_euc_boxes_BW_notemp(1, index_reference_value);
            %find the percentage variation that fix the intarval of
            %distances that can be taken
            value = (distanza_ref_temp * percent_eu) / 100;
            interval = distanza_ref_temp + value;
            
            % select only the picture with distance lower than the treshold
            object_buoni = (Dist_euc_boxes_BW_notemp < interval);
            
            immagini_BW_buone_notemp =  immagini_BW(:,:,:,2:end);
            immagini_BW_buone = immagini_BW_buone_notemp(:,:,:,object_buoni);
            figure
            montage(immagini_BW_buone, 'size', [1 size(immagini_BW_buone,4)]);
            title('Picture with Euclidean distance lower than the treshold','FontSize',15)
        end
        
    case 'ssim'
        %compute the distances with ssim method
        ssimval = zeros(1,size(boxes_equalizzati_BW,4));
        ssimmap = zeros(size(boxes_equalizzati_BW,1),size(boxes_equalizzati_BW,2),...
            size(boxes_equalizzati_BW,4));
        
        for i = 1 : size(boxes_equalizzati_BW,4)
           [ssimval(i), ssimmap(:,:,i)] = ssim(boxes_equalizzati_BW(:,:,:,i),template_BW);
        end
         
        ssimvalues = ssimval(2:end);
        
        %compare the distances
        %no match is found if any image has a distance from the template
        %lower than a certain treshold
        if max(ssimvalues) < MIN_SSIMVAL
            
            figure('Position',[scrsz(3)/10 scrsz(4)/10 scrsz(3)/1.25 scrsz(4)/1.25]);
            text(0.5, 0.5, "The template selected can't be found in the image",...
                'FontSize',40, 'Color','k','HorizontalAlignment',...
                'Center', 'VerticalAlignment','Middle')
            axis off
            
        else
            
            % look for the distances
            % work on black and white pictures for an easier detection of
            % the differences
            
            %find the index of the minimal distance and the related
            %distance
            index_reference_value = find(ssimvalues == max(ssimvalues));
            distanza_ref_temp = ssimvalues(1, index_reference_value);
            %find the percentage variation that fix the intarval of
            %distances that can be take
            value = (distanza_ref_temp * percent_ssim) / 100;
            interval = distanza_ref_temp + value;
            
            % select only the picture with distance lower than the treshold
            object_buoni = ssimvalues< interval;
            
            immagini_BW_buone_notemp =  immagini_BW(:,:,:,2:end);
            immagini_BW_buone = immagini_BW_buone_notemp(:,:,:,object_buoni);
            figure
            montage(immagini_BW_buone, 'size', [1 size(immagini_BW_buone,4)]);
            title('Picture with SSIM lower than the treshold','FontSize',15)
        end
end

%% Color comparison roi/template
%after the finding of the objects with a distance lower than the
%treshold,it is necessary a further check on the histogram of the RGB
%images with a chi square test to see if the retrieved ROI have the same
%colour or not
%the value oh the hsitogram distances is compared with the maximum distance
%value MAX_DISTHIST. Then the lower distance value is selected. This value
%is increased of a selected percentage variation (perc_dist_hist).Pictures 
%with a distance lower that this percentage value are selected.
%The check is done with the equalized pictures, because the non equalized
%one can show very high differences in color because of shades 

boxes_equalizzati = zeros(size(template_RGB,1),size(template_RGB,2),3,size(immagini,4));
boxes_equalizzati(:,:,:,1) = template_RGB;

%equalization of the pictures on the RGB images
for i = 2 : size(immagini,4)
    boxes_equalizzati(:,:,:,i) = imhistmatch(immagini(:,:,:,i), template_RGB,256);
end

if ShowBoxesEqualizzati
    figure
    montage(boxes_equalizzati, 'size', [1 size(boxes_equalizzati,4)]);
    title('Boxes B/W equalized','FontSize',15)
end

object_buoni_temp=[true object_buoni];

%normal distances for the correct non equalized histogram 
normal_distances_noneq = findHistogramsDistance(immagini(:,:,:,object_buoni_temp));
%normal distances for all non equalized histogram 
normal_distances_noneq_tutte = findHistogramsDistance(immagini);

%normal ditances for the correct equalized histograms 
normal_distances = findHistogramsDistance(boxes_equalizzati(:,:,:,object_buoni_temp));
%normal ditances for all the equalized histograms 
normal_distance_eq_all=findHistogramsDistance(boxes_equalizzati);

% Discard the images that have a distance value higher than a certain threshold

%select the distances removing the template
normal_dist_notemp=normal_distances(1,2:end);

%no match is found if any image has a distance from the template
%lower than a certain treshold
if min(normal_dist_notemp) > MAX_DISTHIST        
    figure('Position',[scrsz(3)/10 scrsz(4)/10 scrsz(3)/1.25 scrsz(4)/1.25]);
    text(0.5, 0.5, "The template selected can't be found in the image",...
        'FontSize',40, 'Color','k','HorizontalAlignment',...
        'Center', 'VerticalAlignment','Middle')
    axis off
            
else
    %find the index of the minimal distance and the related
    %distance
    index_reference_value_hist = find(normal_dist_notemp == min(normal_dist_notemp));
    distanza_ref_temp_hist = normal_dist_notemp(1, index_reference_value_hist);
    %find the percentage variation that fix the intarval of
    %distances that can be take
    value_hist = (distanza_ref_temp_hist * perc_dist_hist) / 100;
    interval_hist = distanza_ref_temp_hist + value_hist;

    %Select only the picture with a value lower than the selected treshold
    object_buoni_hist = (normal_dist_notemp< interval_hist);

    immagini_hist_notemp =  boxes_equalizzati(:,:,:,2:end);
    immagini_BW_buone_hist = immagini_hist_notemp(:,:,:,object_buoni_hist);
    figure
    montage(immagini_BW_buone_hist, 'size', [1 size(immagini_BW_buone_hist,4)]);
    title('Final objects retrieved in the scene','FontSize',15);
end

%show the final result: the template and its occurences in the image.
%Found boxes are highlighted with a green border
polygon_buoni_bool = repelem(object_buoni,2);
poligoni_buoni_euc = all_polygons(:,polygon_buoni_bool);
polygon_buoni_hist_bool = repelem(object_buoni_hist,2);
poligoni_buoni_finali = poligoni_buoni_euc(:,polygon_buoni_hist_bool);
for i= 1 : 2 : size(poligoni_buoni_finali,2)
    vertici =[poligoni_buoni_finali(1,i) poligoni_buoni_finali(1,i+1);
        poligoni_buoni_finali(3,i) poligoni_buoni_finali(3,i+1);
        poligoni_buoni_finali(2,i) poligoni_buoni_finali(2,i+1);
        poligoni_buoni_finali(4,i) poligoni_buoni_finali(4,i+1)];
    
    centro_box(i,:) = linlinintersect(vertici);
end

centro_box( ~any(centro_box,2), : ) = [];

boxPolygon_2 = [boxPolygon(1,1) boxPolygon(1,2);
    boxPolygon(3,1) boxPolygon(3,2);
    boxPolygon(2,1) boxPolygon(2,2);
    boxPolygon(4,1) boxPolygon(4,2)];
centro_template = linlinintersect(boxPolygon_2);

for i = 1 : size(centro_box,1)
    centri_template(i,:) = centro_template;
end

figure('Position',[scrsz(3)/10 scrsz(4)/10 scrsz(3)/1.25 scrsz(4)/1.25])
ax=axes;
showMatchedFeatures(image_RGB,template_RGB,centro_box,centri_template,'Montage','PlotOptions',...
    {'go','go','w-'});
title('First nearest feature');
hold on
for i = 1 : 2 :length(poligoni_buoni_finali)-1
    line(poligoni_buoni_finali(:, i), poligoni_buoni_finali(:, i+1), 'Color', 'g', 'LineWidth', 3);
    title('Final objects detected in the scene','FontSize',15);
end