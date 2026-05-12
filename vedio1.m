%% STEP 1: Load Video and Extract Frames

videoFile = 'video1.avi';

% Check if file exists
if ~isfile(videoFile)
    error('Video file "%s" not found. Check the filename and current directory: %s', videoFile, pwd);
end

v       = VideoReader(videoFile);
frames  = {};
frameNo = 0;

while hasFrame(v)
    frameNo         = frameNo + 1;
    frames{frameNo} = readFrame(v);
end

totalFrames = length(frames);
fprintf('Total frames loaded: %d\n', totalFrames);

if totalFrames == 0
    error('No frames were extracted. The video may be corrupted or unreadable.');
end

%% STEP 2: Display all frames for best frame selection
figure;
cols = 4;
rows = ceil(totalFrames / cols);

for i = 1:totalFrames
    subplot(rows, cols, i);
    imshow(frames{i});
    title(['Frame ', num2str(i)]);
end
sgtitle('All Frames - Select Best Frame for Number Plate');

%% STEP 3: Select best frame manually
bestFrameNo = input('Enter the best frame number for number plate visibility: ');

% Validate input
if bestFrameNo < 1 || bestFrameNo > totalFrames
    error('Invalid frame number. Please enter a number between 1 and %d.', totalFrames);
end

bestFrame = frames{bestFrameNo};

figure;
imshow(bestFrame);
title(['Selected Best Frame from Video1 - Frame ', num2str(bestFrameNo)]);
fprintf('Frame %d selected successfully.\n', bestFrameNo);

%% STEP 4: Adjust selected frame in colour using imadjust only
adjustedFrame = imadjust(bestFrame, stretchlim(bestFrame, [0.01 0.99]), []);

figure;
subplot(1,2,1);
imshow(bestFrame);
title('Original Selected Frame');

subplot(1,2,2);
imshow(adjustedFrame);
title('Adjusted Colour Frame using imadjust');
sgtitle('Original vs Contrast Adjusted Frame');

%% STEP 5: Manually crop the number plate from adjusted frame
fprintf('Please select the number plate region on the adjusted frame.\n');
figure;
imshow(adjustedFrame);
title('Draw Rectangle Around Number Plate - Double Click to Confirm');

try
    roi         = drawrectangle;
    wait(roi);
    plateRegion = imcrop(adjustedFrame, roi.Position);
    close;

    if isempty(plateRegion)
        error('Cropping cancelled or resulted in an empty region.');
    end
catch ME_crop
    error('Could not crop image. Error: %s', ME_crop.message);
end

figure;
imshow(plateRegion);
title('Original Cropped Number Plate');

%% STEP 6: Upscale the Cropped Plate
scaleFactor   = 6;
plateUpscaled = imresize(plateRegion, scaleFactor, 'bicubic');

figure;
imshow(plateUpscaled);
title(['Upscaled Number Plate (', num2str(scaleFactor), 'x Bicubic)']);

%% STEP 7: Convert to Grayscale
if size(plateUpscaled, 3) == 3
    plateGray = rgb2gray(plateUpscaled);
else
    plateGray = plateUpscaled;
end

%% STEP 8: Enhance Contrast using imadjust
plateEnhanced = imadjust(plateGray, stretchlim(plateGray, [0.01 0.99]), []);

%% STEP 9: Final Comparison
figure;
subplot(1,2,1);
imshow(plateRegion);
title('1. Original Cropped Plate');

subplot(1,2,2);
imshow(plateEnhanced);
title(['2. Enhanced Upscaled Plate (', num2str(scaleFactor), 'x)']);
sgtitle('Number Plate - Original vs Enhanced');

fprintf('Processing complete.\n');
fprintf('If frame 19 is not visible, total frames in video = %d\n', totalFrames);