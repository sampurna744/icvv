videoFile    = 'video2.avi';                % video file name
outputFolder = 'Extracted_Frames_Video2';   % Name of the folder to save frames
outputFormat = 'png';                       % Format to save frames

try
    video = VideoReader(videoFile);
    disp(['Successfully opened video: ' videoFile]);
    disp(['Video duration: ' num2str(video.Duration) ' seconds']);
    disp(['Frame rate: ' num2str(video.FrameRate) ' fps']);
    disp(['Total frames (estimated): ' num2str(video.NumFrames)]);
catch ME
    error('Cannot open video file: %s\n%s', videoFile, ME.message);
end

% --- Frame Extraction Loop ---
frameNumber = 0;
disp('Starting frame extraction...');

% Loops through all frames in the video
while hasFrame(video)
    frameNumber  = frameNumber + 1;
    currentFrame = readFrame(video);

    % Creates the filename for the current frame (e.g., frame_0001.png)
    % Using %04d ensures 4 digits with leading zeros (adjust if needed for very long videos)
    filename = fullfile(outputFolder, sprintf('frame_%04d.%s', frameNumber, outputFormat));

    % Saves the current frame as an image file
    try
        imwrite(currentFrame, filename);
    catch ME_write
        warning('Could not write frame %d. Error: %s', frameNumber, ME_write.message);
        % Consider adding a break here if one failure means you should stop
    end

    % Displays progress periodically
    if mod(frameNumber, 50) == 0  % Display progress every 50 frames
        fprintf('Saved frame: %d\n', frameNumber);
    end
end

disp(['Finished extracting frames. Total frames saved: ' num2str(frameNumber)]);
disp(['Frames saved in folder: ' outputFolder]);