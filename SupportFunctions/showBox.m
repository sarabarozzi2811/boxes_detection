function showBox(inlierImagePoints, inlierTemplatePoints, newBoxPolygon)
%SHOWBOX Show the ROI found on the image with a red box around it and the
%features that are connected with the template.

global image_RGB template_RGB

            figure(50);
            showMatchedFeatures(image_RGB, template_RGB, inlierImagePoints,...
                inlierTemplatePoints, 'montage');
            hold on;
            line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'r', 'LineWidth', 2);
            title('Box found with matched features');
            pause(0.01)


end

