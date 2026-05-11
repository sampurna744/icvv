%% STEP 1: Setup Parameters
folderPath  = 'FrameSeq1';
outputVideo = 'video.avi';
frameRate   = 30;

%% STEP 2: Load Image Files

imageFiles = dir(fullfile(folderPath, '*.png'));
imageFiles = [imageFiles; dir(fullfile(folderPath, '*.jpg'))];

[~, idx]   = sort({imageFiles.name});
imageFiles = imageFiles(idx);

if isempty(imageFiles)
    disp('No images found in the specified folder.');
    return;
end

%% STEP 3: Create Video from Image Sequence
img               = imread(fullfile(folderPath, imageFiles(1).name));
[height, width, ~] = size(img);

videoWriter           = VideoWriter(outputVideo, 'Uncompressed AVI');
videoWriter.FrameRate = frameRate;
open(videoWriter);

for i = 1:length(imageFiles)
    img = imread(fullfile(folderPath, imageFiles(i).name));
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    end
    writeVideo(videoWriter, img);
end

close(videoWriter);

%% STEP 4: Load Frame
img = imread('FrameSeq1/vespa042.jpg');

if size(img, 3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

%% STEP 5: Apply Non-Local Means Filter
nlm_img = imnlmfilt(img_gray);

%% STEP 6: Moving Object Mask
% Load two consecutive frames for motion detection
frame1 = imread(fullfile(folderPath, imageFiles(1).name));
frame2 = imread(fullfile(folderPath, imageFiles(2).name));

% Convert to grayscale
if size(frame1, 3) == 3
    frame1_gray = rgb2gray(frame1);
else
    frame1_gray = frame1;
end

if size(frame2, 3) == 3
    frame2_gray = rgb2gray(frame2);
else
    frame2_gray = frame2;
end

% Compute frame difference for motion mask
diffFrame  = abs(double(frame1_gray) - double(frame2_gray));
motionMask = diffFrame > 25;
motionMask = bwareaopen(motionMask, 50);

% Display Moving Object Mask side by side with original
figure;
subplot(1,2,1);
imshow(frame1);
title('Original Frame');

subplot(1,2,2);
imshow(motionMask);
title('Moving Object Mask');

%% STEP 7: Motion Vectors using Optical Flow

% Enhance frames first for better flow detection
f1 = im2double(imadjust(frame1_gray, stretchlim(frame1_gray, [0.01 0.99]), []));
f2 = im2double(imadjust(frame2_gray, stretchlim(frame2_gray, [0.01 0.99]), []));

% Compute optical flow using Lucas-Kanade method
opticFlow = opticalFlowLK('NoiseThreshold', 0.0039);
estimateFlow(opticFlow, f1);
flow      = estimateFlow(opticFlow, f2);

% Display Motion Vectors
figure;
imshow(frame1);
hold on;
title('Motion Vectors');

step = 8;
[rows, cols] = size(f1);
[X, Y]       = meshgrid(1:step:cols, 1:step:rows);

Vx = flow.Vx(1:step:rows, 1:step:cols);
Vy = flow.Vy(1:step:rows, 1:step:cols);

quiver(X, Y, Vx, Vy, 2, 'r', ...
       'LineWidth',   1.2, ...
       'MaxHeadSize', 0.8);
hold off;

%% STEP 8: Crop Number Plate
figure;
imshow(nlm_img);
title('Select ONLY the white plate area - crop tightly');
[plate, rect] = imcrop(nlm_img);

figure;
imshow(plate);
title('Original Crop');

%% STEP 9: Upscale
scaleFactor    = 10;
plate_upscaled = imresize(plate, scaleFactor, 'bicubic');

%% STEP 10: First Sharpen Pass
plate_sharp1 = imsharpen(plate_upscaled, ...
               'Amount',    3,   ...
               'Radius',    2,   ...
               'Threshold', 0.02);

%% STEP 11: Second Sharpen Pass
plate_sharp2 = imsharpen(plate_sharp1, ...
               'Amount',    2,   ...
               'Radius',    1,   ...
               'Threshold', 0.02);

%% STEP 12: Histogram Equalisation
plate_histeq = histeq(plate_sharp2);

%% STEP 13: Final Contrast Adjustment
plate_final = imadjust(plate_histeq, ...
              stretchlim(plate_histeq, [0.05 0.95]), []);

%% STEP 14: Median Filter
plate_clean = medfilt2(plate_final, [2 2]);

%% STEP 15: Final Display
figure;
imshow(plate_clean);
title('Number Plate');

%% STEP 16: Three Panel Comparison
figure;
subplot(1,3,1);
imshow(plate);
title('1. Original Crop');

subplot(1,3,2);
imshow(plate_upscaled);
title(['2. Upscaled (', num2str(scaleFactor), 'x)']);

subplot(1,3,3);
imshow(plate_clean);
title('3. Final Enhanced');
sgtitle('Number Plate Enhancement');

%% STEP 17: Original Crop vs Histogram Equalised Comparison
figure('Name', 'Number Plate Comparison', 'NumberTitle', 'off');
subplot(1,2,1);
imshow(plate);
title('Original Crop');

subplot(1,2,2);
imshow(plate_histeq);
title('Histogram Equalised Plate');
sgtitle('Original Crop vs Histogram Equalised');

disp('Video creation complete!');