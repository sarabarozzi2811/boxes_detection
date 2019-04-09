function [all_polygons,all_transf] = locateObjectsImage(final_feature_template,...
    final_feature_image,boxPolygon, all_polygons, all_transf)
% With this function we locate the matching features in the image. When we
% find a match, we project the shape of the template on the image in order
% to see the ROI that is found by the algorithm. We have 3 cases:
% 1) The box is inside the image and is not degenerate: in this case we
% store the part of the image, the box and the transformation. We also
% remove all the inlier from inside the box to make the next cycle more
% precise
% 2) The box is outside the image: in this case we
% don't save anything, but we remove all the inlier from inside the box, so
% in the next cycles the feature will not interfere and will not be counted
% anymore
% 3) The box is degenerate (either inside or outside the image): in this
% case we do nothing, and we go to the next cycle
% This function return all the boxes found and the transformations
% associated with them.


global showExternalBoxImage showDegenerateBoxImage MAX_NUM_BOX MIN_NUM_INLIER MAX_NUM_TRIAL image_BW
contatore = 0;

while true
  
    % Using a MSAC algorithm, the best match between the features of the
    % template and the features of the image is found. This function
    % extracts a transformation, the inlier of the selected points and the
    % outliers. 
    [tform, inlierTemplatePoints, inlierImagePoints] = estimateGeometricTransform...
        (final_feature_template, final_feature_image, 'affine','MaxNumTrials', MAX_NUM_TRIAL, 'MaxDistance', 20);
    
    % Check the number of inliers and break the cycle if they are less than
    % a specified value
    if length(inlierImagePoints) < MIN_NUM_INLIER
        sprintf('Number of inliers smaller than the fixed treshold.')
        break;
    end
    
    % Fit the obtained homography with a least square adjustment
    H_est_fit = fitgeotrans(inlierTemplatePoints.Location,inlierImagePoints.Location,...
        'projective');
        
    % Transform the box of the template with the transformation 
    newBoxPolygon = transformPointsForward(H_est_fit, boxPolygon);
    
    % Create a matrix with the vertices of the box on the image
    vertices = [newBoxPolygon(1,1) newBoxPolygon(1,2);
        newBoxPolygon(3,1) newBoxPolygon(3,2);
        newBoxPolygon(2,1) newBoxPolygon(2,2);
        newBoxPolygon(4,1) newBoxPolygon(4,2)];
    
    % Find the center of the box by computing the intersection between the
    % line passing through the vertices of the box on the image
    intersection = linlinintersect(vertices);
    
    % Check if the intersection of the lines is inside the obtained polygon
    % n.b. the coordinates of the image are in the form of y-x
    centre_inside = inpolygon(intersection(1), intersection(2),newBoxPolygon(:,1),...
        newBoxPolygon(:,2));
    
    % Check if the box is inside the image
    box_inside = (newBoxPolygon(1,1) > 0 && newBoxPolygon(1,1) < size(image_BW,2) && ...
        newBoxPolygon(1,2) > 0 && newBoxPolygon(1,2) < size(image_BW,1)&& ...
        newBoxPolygon(2,1) > 0 && newBoxPolygon(2,1) < size(image_BW,2) && ...
        newBoxPolygon(2,2) > 0 && newBoxPolygon(2,2) < size(image_BW,1)&&...
        newBoxPolygon(3,1) > 0 && newBoxPolygon(3,1) < size(image_BW,2) && ...
        newBoxPolygon(3,2) > 0 && newBoxPolygon(3,2) < size(image_BW,1)&&...
        newBoxPolygon(4,1) > 0 && newBoxPolygon(4,1) < size(image_BW,2) && ...
        newBoxPolygon(4,2) > 0 && newBoxPolygon(4,2) < size(image_BW,1));
    
    % First case: the box found is not degenerate and inside the image
    if centre_inside && box_inside
        
        all_polygons = [all_polygons newBoxPolygon];
        all_transf = [all_transf H_est_fit];
        
        showBox(inlierImagePoints, inlierTemplatePoints, newBoxPolygon)
        
        
        % Remove all the features that are inside the polygon, so they
        % don't interfere with the next cycles.
        
        % Find index of features inside the box polygon
        in = inpolygon(final_feature_image.Location(:,1),final_feature_image.Location(:,2),...
            newBoxPolygon(:,1),newBoxPolygon(:,2));
        
        feature_inside = find(in);
        
        % Remove from all the matching features the ones inside the box
        final_feature_image = removerows(final_feature_image, 'ind', feature_inside);
        final_feature_template = removerows(final_feature_template, 'ind', feature_inside);
        
    else
        % Second case: the box is outside the image
        if   not(box_inside)
            in = inpolygon(final_feature_image.Location(:,1),final_feature_image.Location(:,2),...
                newBoxPolygon(:,1),newBoxPolygon(:,2));
            
            feature_inside = find(in);
            
            % Remove from all the matching features the ones inside the
            % box, so they don't interfere with next cycles
            final_feature_image = removerows(final_feature_image, 'ind', feature_inside);
            final_feature_template = removerows(final_feature_template, 'ind', feature_inside);
            sprintf('Bounding box external to the picture!')
            
            if showExternalBoxImage
                % show the box that is external to the image
                showBox(inlierImagePoints, inlierTemplatePoints, newBoxPolygon)
            end
            
        else 
            % Third case: the polygon is degenerate
            
            contatore = contatore +1;
            sprintf('Degenerate polygon #%d found!', contatore)
            if contatore > 10
                break
            end
            
            if showDegenerateBoxImage
                % show the box that is degenerate
                showBox(inlierImagePoints, inlierTemplatePoints, newBoxPolygon)
            end
            

        end
    end
    
    % Limit the number of matches found (if there are too many everything
    % will block due to the dimensions of the arrays)
    if length(all_polygons)/2 > MAX_NUM_BOX
        break
    end
end




