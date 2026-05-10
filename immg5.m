%% --- Step 1: Load and Normalize Image ---
inputImage = im2double(imread('Image5.jpg'));  % Convert to double precision [0,1]
imshow(inputImage)
title('orginal Image5.jpg')

%% --- Step 2: Setup Motion Blur PSF & Lucy-Richardson Deconvolution ---
blurLength    = 34;
blurAngle     = 8;
psfMotion     = fspecial('motion', blurLength, blurAngle);

iterationCount = 10;
dampFactor     = 0.001;
deblurredImg   = deconvlucy(inputImage, psfMotion, iterationCount, dampFactor);

figure;
imshow(deblurredImg);
title('Image Restored with Lucy-Richardson Deconvolution');

%% --- Step 3: Sharpen Image with Edge Preservation ---
sharpenAmt    = 0.5;
sharpenRad    = 1;
sharpenThresh = 0.3;
sharpenedImg2 = imsharpen(deblurredImg, ...
                    'Amount', sharpenAmt, ...
                    'Radius', sharpenRad, ...
                    'Threshold', sharpenThresh);

figure;
imshow(sharpenedImg2);
title('Sharpened Image with Edge Protection');

%% --- Step 4: Detect and Correct Artifacts ---
grayImg        = rgb2gray(sharpenedImg2);
cannyThreshold = [0.01 0.05];
edgesDetected  = edge(grayImg, 'Canny', cannyThreshold);

artifactRegion = imdilate(edgesDetected, strel('disk', 1));
figure;
imshow(artifactRegion);
title('Detected Artifact Mask');

% Revert artifact areas to original input pixels
mask3Channels = repmat(artifactRegion, [1,1,3]);
correctedImg  = sharpenedImg2;
correctedImg(mask3Channels) = inputImage(mask3Channels);

%% --- Step 5: Final Smoothening using Bilateral Filter ---
smoothDegree = 0.01;
finalImage   = imbilatfilt(correctedImg, 'DegreeOfSmoothing', smoothDegree);

%% --- Step 6: Show Input vs. Processed Image ---
figure('Position', [100 100 1200 600]);
subplot(1,2,1);
imshow(inputImage);
title('Original Input Image');

subplot(1,2,2);
imshow(finalImage);
title({'Final Output Image', 'Deblurred, Artifact-Reduced & Smoothed'});