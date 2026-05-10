% Load input color image

sourceImage = imread('Image4.jpg');

% Show the original image
figure;

imshow(sourceImage);
title('Original Image4.jpg');

% Method 1: Apply local brightness enhancement using imlocalbrighten

brightnessAmount = 0.35; % adjustable parameter
localBrightImage = imlocalbrighten(sourceImage, brightnessAmount);
figure;
imshow(localBrightImage);
title('Locally Brightened Image (imlocalbrighten)');

% Method 2: Gamma correction via imadjust on double precision image

imgDoublePrecision = im2double(sourceImage);
gammaValue = 0.5; % gamma < 1 brightens the image
gammaCorrectedImage = imadjust(imgDoublePrecision, [], [], gammaValue);
figure;
imshow(gammaCorrectedImage);
title(['Gamma Corrected Image (gamma = ', num2str(gammaValue), ')']);

% Method 3: Convert to grayscale and apply adaptive histogram equalization (adapthisteq)

if size(sourceImage, 3) == 3
    grayImage = rgb2gray(sourceImage);
else
    grayImage = sourceImage;
end
adapthistImage = adapthisteq(grayImage, 'ClipLimit', 0.01, 'Distribution', 'rayleigh');
figure;
imshow(adapthistImage);
title('Grayscale Adaptive Histogram Equalization');

% Compare original image and locally brightened image side by side

figure;
imshowpair(sourceImage, localBrightImage, 'montage');
title('Original Image vs. Locally Brightened Image');