function [images]=findROIofImage(all_polygons, images)
%This function return the ROIs of the image and store them inside a single
%array

global image_RGB showROIimage

z = 1;
for i =1: 2: length(all_polygons)-1
    % cut the region of the box
    %POI region of interest
    BW = roipoly(image_RGB, all_polygons(:,i), all_polygons(:,i+1));
    % Show only the region of the image contained in the polygon
    ROI = image_RGB;
    R = ROI(:,:,1);
    G = ROI(:,:,2);
    B = ROI(:,:,3);
    R(BW == 0) = 0;
    G(BW == 0) = 0;
    B(BW == 0) = 0;
    ROI(:,:,1) = R;
    ROI(:,:,2) = G;
    ROI(:,:,3) = B;
    
    if showROIimage
        figure(40)
        imshow(ROI);
    end
    
    images(:,:,:,z)=ROI;
    z = z + 1;
end


end

