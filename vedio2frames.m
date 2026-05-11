% --- Load the Specific Frame ---
imageFile = 'Extracted_Frames_Video2/frame_0029.png';
try
    originalImage = imread(imageFile);
    disp(['Successfully loaded image: ' imageFile]);
catch ME
    error('Cannot load image file: %s\n%s', imageFile, ME.message);
end

% --- 1. Interactively Crop the Number Plate Region ---
%    Allows the user to select the plate area precisely.
figure; 
imshow(originalImage);
title('Select the Number Plate Area, then Double-Click');
try
    roi         = drawrectangle;
    wait(roi);  % Wait for user to position and double-click
    plateRegion = imcrop(originalImage, roi.Position);
    close;      % Close the temporary cropping figure

    if isempty(plateRegion)
        error('Cropping cancelled or resulted in an empty image.');
    end
catch ME_crop
    error('Could not crop image. Error: %s', ME_crop.message);
end

% --- 2. Upscale the Cropped Region ---
scaleFactor   = 3;
%    'bicubic' interpolation is often suitable for enlargement.
plateUpscaled = imresize(plateRegion, scaleFactor, 'bicubic');

% --- 3. Process the Upscaled Region ---

% a) Convert Upscaled Region to Grayscale
%    Simplifies subsequent processing by removing color.
if size(plateUpscaled, 3) == 3
    plateGray = rgb2gray(plateUpscaled);
else
    plateGray = plateUpscaled; % Already grayscale
end

% b) Enhance Contrast (Applied to the upscaled grayscale image)
%    Uses Adaptive Histogram Equalization (adapthisteq) to boost local contrast.
%    <<< TUNABLE PARAMETER 2 >>> Adjust ClipLimit (e.g., 0.01, 0.015, 0.02, 0.025)
clipLimitValue = 0.02; % Using the previously increased value, adjust as needed
plateEnhanced  = adapthisteq(plateGray, 'ClipLimit', clipLimitValue, 'Distribution', 'uniform');

% --- 4. Display Final Comparison ---
%    Shows the original cropped region and the enhanced upscaled region side-by-side.
figure; % New figure for the final comparison display
subplot(1,2,1); % First position in a 1x2 grid
imshow(plateRegion);
title('1. Original Cropped Plate');

subplot(1,2,2); % Second position in a 1x2 grid
imshow(plateEnhanced);
title('2. Enhanced Upscaled');

disp('Processing complete. Check the final figure for comparison.');