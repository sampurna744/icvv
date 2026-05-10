foggyPic = imread('Image6.jpg');
figure;
imshow(foggyPic);
title('Original Image6.jpg');

% Dehaze using approx dark channel prior with contrast enhancement
clearedPic = imreducehaze(foggyPic, 'Method', 'approxdcp', 'ContrastEnhancement', 'boost');
figure;
imshow(clearedPic);
title('Dehazed Result (imreducehaze)');
figure;
imshowpair(foggyPic, clearedPic, 'montage');
title('Before vs. After Dehazing');

% Perform luminance balancing
inputRGB       = clearedPic;
luminanceGray  = rgb2gray(inputRGB);  % Convert to grayscale to get luminance reference

% Separate the RGB layers
layerRed   = inputRGB(:,:,1);
layerGreen = inputRGB(:,:,2);
layerBlue  = inputRGB(:,:,3);

% Compute mean brightness values
meanRed   = mean2(layerRed);
meanGreen = mean2(layerGreen);
meanBlue  = mean2(layerBlue);
meanLuma  = mean2(luminanceGray);

% Normalize each channel based on grayscale luminance
layerRed   = uint8(double(layerRed)   * meanLuma / meanRed);
layerGreen = uint8(double(layerGreen) * meanLuma / meanGreen);
layerBlue  = uint8(double(layerBlue)  * meanLuma / meanBlue);

% Merge adjusted channels back into one RGB image
balancedOutput = cat(3, layerRed, layerGreen, layerBlue);

% Display the final color-balanced image
figure;
imshow(balancedOutput);
title('Luminance-Balanced Dehazed Image');

% ---- NEW: Comparison of original vs luminance image ----

figure;
imshowpair(inputRGB, balancedOutput, 'montage');
title('Orginal vs Processed Image');