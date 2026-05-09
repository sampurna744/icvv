%% Step 1 - Read and Display Original Image
img = imread('Imag2.JPG');
figure('Name','Step 1: Original Imag2.JPG - Out of Focus Blur');
imshow(img);
title('Step 1: Original Imag2.JPG - Out of Focus Blur');

%% Step 2 - Grayscale Conversion and Histogram
gray = rgb2gray(img);
figure('Name','Step 2: Grayscale and Histogram');
subplot(1,2,1); imshow(gray); title('Step 2a: Grayscale');
subplot(1,2,2); imhist(gray); title('Step 2b: Histogram');
xlabel('Intensity Value'); ylabel('Pixel Count');


%% Step 3 - Sharpening with imsharpen (Radius=3, Amount=2)
sharpened = imsharpen(img, 'Radius', 3, 'Amount', 2);
figure('Name','Step 3: Original vs Sharpened');
subplot(1,2,1); imshow(img);       title('Original');
subplot(1,2,2); imshow(sharpened); title('Sharpened (Radius=3, Amount=2)');
sgtitle('Step 3: Original (Left) vs Sharpened (Right)');

%% Step 4 - Wiener Deconvolution with Gaussian PSF
% PSF: Gaussian 15x15, sigma=5
psf = fspecial('gaussian', [15 15], 5);
gray_double = im2double(gray);
wiener_restored = deconvwnr(gray_double, psf, 0.01);
wiener_restored = im2uint8(wiener_restored);

figure('Name','Step 4: Grayscale vs Wiener Deconvolution');
subplot(1,2,1); imshow(gray);             title('Step 4a: Grayscale Original');
subplot(1,2,2); imshow(wiener_restored);  title('Step 4b: Wiener Deconvolution Restored');
sgtitle('Step 4: Grayscale original (left) vs Wiener Deconvolution restored (right)');

%% Step 5 - Motion Wiener Deconvolution (for comparison)
psf_motion = fspecial('motion', 21, 11);
wiener_motion = deconvwnr(gray_double, psf_motion, 0.01);
wiener_motion = im2uint8(wiener_motion);

figure('Name','Step 5: Grayscale vs Motion Wiener Restored');
subplot(1,2,1); imshow(gray);          title('Step 5a: Grayscale (Left)');
subplot(1,2,2); imshow(wiener_motion); title('Step 5b: Motion Wiener Restored (Right)');
sgtitle('Step 5: Grayscale (Left) vs Motion Wiener Restored (Right)');

%% Step 6 - Edge Detection Comparison (before vs after sharpening)
gray_sharp = rgb2gray(sharpened);
edges_before = edge(gray, 'Sobel');
edges_after  = edge(gray_sharp, 'Sobel');

figure('Name','Step 6: Edge Detection Before vs After Sharpening');
subplot(1,2,1); imshow(edges_before); title('Step 6a: Edges Before - Weak due to Blur');
subplot(1,2,2); imshow(edges_after);  title('Step 6b: Edges After Sharpening');
sgtitle('Step 6: Edge detection before (left) vs after sharpening (right)');

disp('Imag2.JPG processing complete.');
