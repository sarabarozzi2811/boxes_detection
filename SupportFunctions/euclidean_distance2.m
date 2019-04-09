
function  t=euclidean_distance2(A,B)
%this function find compute the euclidean distance pixel by pixel between
%the template and the rectified ROI; the function is implemented both for
%the case of BW and RGB images

A=double(A);
B=double(B);
pixel= zeros(size(A,1),size(A,2),size(A,3));

%compute the difference between pixel
if (size(A,3)==1) && (size(B,3)==1)
    for i=1:size(A,1)
        for j=1:size(A,2)
            pixel(i,j)=sqrt((A(i,j)-B(i,j)).^2);
        end
    end
    
    %output of the function: mean of all the differences between pixel of
    %the template and of the ROI
    t=mean2(pixel);
    
elseif (size(A,3)==3) && (size(B,3)==3)
    
    for k=1:size(A,3)
        pixel(:,:,k)=((A(:,:,k)-B(:,:,k)).^2);
    end
    
    %output of the function: mean of all the difference between pixel of
    %the template and of the ROI done on the mean of the three RGB channel
    sum_3channels = sum(pixel,3);
    t = mean2(sqrt(sum_3channels));
    
end


end