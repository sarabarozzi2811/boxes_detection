function showFeatures(template_BW, image_BW, t_valid_points, i_valid_points, showFeaturesImages)
%This function simply shows the features of the template and the features 
%of image.

if showFeaturesImages
    figure
    imshow(template_BW);
    hold on; plot(t_valid_points,'ShowOrientation', true);
    title('Template features');
    
    
    figure
    imshow(image_BW);
    hold on; plot(i_valid_points,'ShowOrientation', true);
    title('Image features');
end

end