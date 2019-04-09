function [indexFirstMatch, indexSecondMatch] = findGoodMatches(matches, D)
%This function takes the matches between the features of the template and 
%the features of the image and their distance, then applies a ratio test 
%based on the distance in order to discard the ambiguous matches and the 
%false matches arising from the background clutter.


goodMatches = zeros(size(matches));

% Create matrix that satisfy ratio test
for i = 1 : length(matches)
    
    % Ratio test
    if (D(i,1) / D(i,2) < 0.8)
        goodMatches(i,:) = matches(i,:);
    end
end

% Create two matrices with the indexes of the first and second good
% features of goodMatches (when it is different from 0)
indexFirstMatch = [];
indexSecondMatch = [];
for i = 1 : length(goodMatches)
    if (goodMatches(i,1) ~= 0)
        indexFirstMatch = [indexFirstMatch; i, goodMatches(i,1)];
        indexSecondMatch = [indexSecondMatch; i, goodMatches(i,2)];
    end
end

end

