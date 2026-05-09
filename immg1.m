%% Step 1 - Read and Display Original Image

img = imread('Image1.jpg');
figure('Name','Step 1: Original Image1 - Poor Lighting and Green Colour Cast');
imshow(img);
title('Step 1: Original Image1 - Poor Lighting and Green Colour Cast');

%% Step 2 - Grayscale Histogram

gray = rgb2gray(img);
figure('Name','Step 2: Histogram - Pixels Concentrated in Dark Region');
imhist(gray);
title('Step 2: Histogram - Pixels Concentrated in Dark Region');
xlabel('Intensity Value'); ylabel('Pixel Count');

%% Step 3 - Brightness Adjustment using imadjust (gamma = 0.5)

brightened = imadjust(img, [], [], 0.5);
figure('Name','Step 3: Original vs Brightness Adjusted');
subplot(1,2,1); imshow(img);    title('Original');
subplot(1,2,2); imshow(brightened); title('Brightness Adjusted (gamma=0.5)');
sgtitle('Step 3: Original (Left) vs Brightness Adjusted (Right)');

%% Step 4 - Histogram Equalisation

gray_eq = histeq(gray);
figure('Name','Step 4: Grayscale vs Histogram Equalised');
subplot(1,2,1); imshow(gray);     title('Step 4a: Original Grayscale');
subplot(1,2,2); imshow(gray_eq);  title('Step 4b: Histogram Equalised');
sgtitle('Step 4: Grayscale original (left) vs Histogram Equalised (right)');

%% Step 5 - Colour Correction (reduce green cast)
% Adjust RGB channels: Red x1.5, Green x0.7, Blue x1.2
img_double = double(img);
corrected = img_double;
corrected(:,:,1) = img_double(:,:,1) * 1.5;  % Red boost
corrected(:,:,2) = img_double(:,:,2) * 0.7;  % Green reduce
corrected(:,:,3) = img_double(:,:,3) * 1.2;  % Blue boost
corrected = uint8(min(corrected, 255));        % Clip to valid range

figure('Name','Step 5: Original vs Colour Corrected');
subplot(1,2,1); imshow(img);       title('Original');
subplot(1,2,2); imshow(corrected); title('Colour Corrected (R×1.5, G×0.7, B×1.2)');
sgtitle('Step 5: Original (Left) vs Colour Corrected (Right)');

disp('Image1.jpg processing complete.');
