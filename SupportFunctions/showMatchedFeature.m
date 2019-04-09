function [] = showMatchedFeature(feature_image, feature_template,indexFirstMatch, indexSecondMatch, showMatchedFeaturesFigure)
%Shows all the features that have passed the ratio test.

global image_BW template_BW

if showMatchedFeaturesFigure
    figure
    ax=axes;
    showMatchedFeatures(image_BW,template_BW,feature_image(indexFirstMatch(:,1))...
        .Location,feature_template(indexFirstMatch(:,2)).Location,'Montage','Parent',ax);
    title('First nearest feature');
    
    figure
    showMatchedFeatures(image_BW,template_BW,feature_image(indexSecondMatch(:,1))...
        .Location,feature_template(indexSecondMatch(:,2)).Location,'Montage', 'PlotOptions',...
        {'bo','g+','r-'});
    title('Second nearest feature');
    
end