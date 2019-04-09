function [immagini] = warpROIFound(all_transf, ROI)
% This function transform the ROI found in order to rectify it.
%   The transformation founded before was matching the features of the
%   template with the features of the image. Now the inverted
%   transformation is computed and then applied to the ROI, in order to
%   rectify it.

global template_RGB showWarpedBox ssize1 ssize2

immagini = zeros(ssize1,ssize2,3,length(all_transf));
immagini(:,:,:,1) = template_RGB;


for i = 1 :length(all_transf)
    
    % Every cycle we take the ROI found before
    img1 = ROI(:,:,:,i);
    
    % From the transformation that was matching the template to the ROI we
    % find the inverse transformation 
    tform1 = projective2d(all_transf(i).T);
    
    tInv = invert(tform1);
       
    % Process to cut the whole image and take just the ROI
    [row,col,~] = find(img1(:,:,1));
    row = sort(row);
    col = sort(col);
    croppedImage = [];
    croppedImage_R = img1(row(1):row(end), col(1):col(end),1);
    croppedImage_G = img1(row(1):row(end), col(1):col(end),2);
    croppedImage_B = img1(row(1):row(end), col(1):col(end),3);
    croppedImage(:,:,1) = croppedImage_R;
    croppedImage(:,:,2) = croppedImage_G;
    croppedImage(:,:,3) = croppedImage_B;
    
    % Set the reference system of the transformation
    Rin = imref2d(size(croppedImage));
    Rin.XWorldLimits = [col(1) col(end)];
    Rin.YWorldLimits = [row(1) row(end)];
    
    % Warp the image using the reference system 
    outputImage = imwarp(croppedImage,Rin, tInv);
    
    % Crop the black parts of the image
    [row1,col1,~] = find(outputImage(:,:,1));
    row1 = sort(row1);
    col1 = sort(col1);
    croppedImage_final = [];
    croppedImage_R_final = outputImage(row1(1):row1(end), col1(1):col1(end),1);
    croppedImage_G_final = outputImage(row1(1):row1(end), col1(1):col1(end),2);
    croppedImage_B_final = outputImage(row1(1):row1(end), col1(1):col1(end),3);
    croppedImage_final(:,:,1) = croppedImage_R_final;
    croppedImage_final(:,:,2) = croppedImage_G_final;
    croppedImage_final(:,:,3) = croppedImage_B_final;
    
    
    
    % Mostra dei singoli box
    if showWarpedBox
        figure(5)
        imshow(croppedImage_final);
        title('Affine trasformation of the ROI');
    end
    
    % Resize of the ROI found in order to make them equal to the template
    imgResized = imresize(croppedImage_final, [ssize1 ssize2]);
    
    % All the ROIs found are saved in one vector
    immagini(:,:,:,i+1) = imgResized;
    
end
end

