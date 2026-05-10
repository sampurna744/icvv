% Load the input image
inputImage = imread('Image3.bmp');

% Display original image with noise
figure;
imshow(inputImage);
title('image3 (Salt & Pepper Noise)');

% Convert to grayscale if input is RGB

if size(inputImage, 3) == 3
    grayScaleImg = rgb2gray(inputImage);
else
    grayScaleImg = inputImage;
end

% Apply median filtering with a 3x3 kernel to reduce salt & pepper noise

medianFilteredImg = medfilt2(grayScaleImg, [3 3]);

% Show median filtered image
figure;
imshow(medianFilteredImg);
title('Median Filter (3x3)');

% Create and apply an averaging filter (3x3 kernel) for noise smoothing

avgKernel = fspecial('average', [3 3]);
averageFilteredImg = imfilter(grayScaleImg, avgKernel, 'replicate');

% Display average filtered image
figure;
imshow(averageFilteredImg);
title('Average Filter (3x3)');

% Side-by-side comparison of original noisy, median filtered, and average filtered images

figure;
subplot(1,3,1), imshow(grayScaleImg), title('Original Noisy');
subplot(1,3,2), imshow(medianFilteredImg), title('Median Filtered');
subplot(1,3,3), imshow(averageFilteredImg), title('Average Filtered');
sgtitle('Noise Reduction Techniques Comparison');