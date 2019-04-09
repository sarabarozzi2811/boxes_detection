## --- FEATURE DETECTION ---

Important! : some of the cases are quite slow and require high computational power and memory. If some errors occur with the dimension
             of some arrays, change the value of the parameter 'MAX_NUM_BOX' to 15 or less.

All the templates used for the feature detection are saved in the folder 'Template';
All the pictures used for the feature detection are saved in the folder 'Images';

The input parameter present in the first part of the code can be changed to see what happens during the selection of pictures.

- showFeaturesImages = if true shows the features detected in the image and in the template;
- showMatchedFeaturesFigure = if true shows the matches between image and template;
- showExternalBoxImage = if true, it shows the bounding box of the region of interest in the case in which it goes externally from the image;
- showDegenerateBoxImage = if true, it shows  the bounding box of the region of interest in the case in which the box it is a degenerate polygon;
- showROIimage = if true, it shows one after the other all the founded ROI;
- showWarpedBox = if true, it shows one by one the warped ROI;
- showHistograms = if true, it shows the histograms of the not equalized images;
- ShowBoxesEqualizzati = if true, it shows the histograms of the equalized images;

InputImages : a panel allows to select the example to be run. Different cases are possible:

1) Simple Example that shows how the algorithm works, with a frontal perspective and coffee box of 2 different colours.
2) Example with the same input picture as case 1, but with a different template. This example will show that a template with
   a wrong color is not recognised
3) Example working with a picture with an high number of detected boxes;
4) Example with an picture taken in perspective and with a high number of detected boxes;
5) Example with cereal boxes detection; the algorithm works well also with shaded boxes;
6) Example with cereal boxes; it finds the bounding boxes in a very precise way;

If a user wants to try the algorithm with additional images or templates, it is sufficient to look for them in the afore mentioned folders,
change the names of the input images and template in one of the cases of the switch and run the whole process.

imageChooser : a switch that allows to select the the method used to calculate the distances between images; By default is selected
               'euclidean'; Change it to 'ssim' to see that the algorithm works also with this different kind of measurements.
