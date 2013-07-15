function video2Diff(videoFile, diffFile, varargin)
%VIDEO2DIFF Differentiate a video frame by frame. The difference is
%   defined as the variance of pixel differences between subsequent frames.
%   Note 1: video frame indexing begins at zero; therefore, video
%   differentiation indexing begins at 1.
%   Note 2: dropped frames are labelled as NaN. Frames separated by dropped
%   frames are differentiated as subsequent. Therefore, these frames can be
%   recognized as any value following a NaN.
%
%   VIDEO2DIFF(VIDEOFILE, DIFFFILE)
%
%   VIDEO2DIFF(VIDEOFILE, DIFFFILE, DIFFVIDEOFILE)
%
%   VIDEO2DIFF(VIDEOFILE, DIFFFILE, DIFFVIDEOFILE, PROGRESSFUNC,
%       PROGRESSSTATE)
%
%   VIDEO2DIFF(VIDEOFILE, DIFFFILE, DIFFVIDEOFILE, PROGRESSFUNC,
%       PROGRESSSTATE, REMMODE)
%
%   VIDEO2DIFF(VIDEOFILE, DIFFFILE, DIFFVIDEOFILE, PROGRESSFUNC,
%       PROGRESSSTATE, REMMODE, DILATEPIXELS)
%
%   Inputs:
%       videoFile     - the name of the video to differentiate
%       diffFile      - the name for the file containing the frames/second
%                       and the video differences per subsequent frames
%                       (the difference is defined as the variance of
%                       pixel differences between subsequent frames).
%       diffVideoFile - the name for the video of the frame differences;
%                       if empty, we don't output a video
%       progressFunc  - the function to call as an update on our progress.
%                       Video differentiation is slow. The progress
%                       function, if not empty, is called every frame. This
%                       function can keep a GUI updated on the progress of
%                       video differentiation. The progress function must
%                       have the following signature:
%                       
%                       progressFunc(state, frames, frame, image,
%                                    diffImage, variance)
%                       
%                       state     = persistent state data for the function
%                       frames    = the total number of frames
%                       frame     = the frame number
%                       image     = the video image
%                       diffImage = the frame-difference image
%                       variance  = the frame-difference variance
%       progressState - the persistent state data for the progressFunc
%       remMode       - the worm removal mode. Occasionally fast worm
%                       movements can be confused with stage movements.
%                       Removing the worm eliminates its contribution to
%                       frame differences (unfortunately, this computation
%                       is temporally expensive). The modes are:
%
%                       0 = don't remoe the worm; the default
%                       1 = remove everything darker than the Otsu threshold
%                       2 = remove the largest Otsu-thresholded connected component
%
%       dilatePixels  - the number of neighboring pixels to use for
%                       dilating the lagest connected component (used in
%                       conjunction with worm removal); if empty, the
%                       largest connected component isn't dilated
%
% See also FINDSTAGEMOVEMENT, SIMPLEPROGRESSUPDATE
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% % Get the vignette.
% vImg = [];
% vignetteFile = strrep(videoFile, '.avi', '.info.xml.vignette.dat');
% if exist(vignetteFile, 'file')
%     fid = fopen(vignetteFile, 'r');
%     vImg = fread(fid, [640 480],'int32=>int8', 0, 'b')';
%     fclose(fid);
% end

% Are we creating a video of the frame differences?
diffVideoFile = [];
if ~isempty(varargin)
    diffVideoFile = varargin{1};
end

% Is there a progress function?
progressFunc = [];
if length(varargin) > 1
    progressFunc = varargin{2};
end

% Is there a state for the progress function?
progressState = [];
if length(varargin) > 2
    progressState = varargin{3};
end

% Determine the thresholded-object removal mode.
remMode = 0;
if length(varargin) > 3
    remMode = varargin{4};
end

% Create the dilation disk.
dilateDisk = [];
if length(varargin) > 4 && varargin{5} > 0
    dilateDisk = strel('disk', varargin{5});
end

% Open the video and get the seconds / frame.
if ispc()
    vr = videoReader(videoFile, 'plugin', 'DirectShow');
else
    vr = videoReader(videoFile, 'plugin', 'ffmpegDirect');
end
fps = get(vr, 'fps');
spf = 1 / fps;
frames = get(vr, 'numFrames') + get(vr, 'nHiddenFinalFrames');

% Check the frame rate.
minFPS = .1;
maxFPS = 100;
if fps < minFPS || fps > maxFPS
    warning('video2Diff:WeirdFPS', [videoFile ' was recorded at ' ...
        num2str(fps) ' frames/second. An unusual frame rate']);
end

% Get the vignette.
vImg = [];
if remMode > 0
    
    % Pre-allocate memory.
    height = get(vr, 'height');
    width = get(vr, 'width');
    falseImg = false(height, width);
    
    
    % Get the vignette.
    vImg = [];
    vignetteFile = strrep(videoFile, '.avi', '.info.xml.vignette.dat');
    if exist(vignetteFile, 'file')
        fid = fopen(vignetteFile, 'r');
        vImg = fread(fid, [width height], 'int32=>int8', 0, 'b')';
        fclose(fid);
    end
end

% Is the video grayscale?
% Note: if there's no difference between the red and green channel, we
% consider all 3 RGB channels identical grayscale images.
isGray = false;
isVideoFrame = next(vr);
if isVideoFrame
    img = getframe(vr);
    
    % If the read and green channels are identical, the video is grayscale.
    if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
        isGray = true;
        img = img(:,:,1);
        
    % Convert the frame to grayscale.
    else
        img = rgb2gray(img);
    end
    
% The video is empty.
else
    error('video2Diff:NoFrames', [videoFile ' has no frames']);
end

% Remove dark objects from the image.
if remMode > 0
    
    % Correct the vignette.
    if ~isempty(vImg)
        img = uint8(single(img) - single(vImg));
    end
    
    % Binarize the image.
    bImg = otsuImg(img, true);
    bImg = ~bImg;
    
    % Remove all thresholded pixels.
    if remMode < 2
        
        % Dilate the thresholded pixels.
        if ~isempty(dilateDisk)
            bImg = imdilate(bImg, dilateDisk);
        end
        
        % Remove the thresholded pixels.
        img = single(img);
        img(bImg) = NaN;
        
        % Remove the worm.
    else
        
        % Find the worm.
        cc = bwconncomp(bImg);
        if ~isempty(cc.PixelIdxList)
            lengths = cellfun(@numel, cc.PixelIdxList);
            [~, ccMaxI] = max(lengths, [], 2);
            
            % Use the largest connected component.
            wormPixels = cc.PixelIdxList{ccMaxI};
            
            % Create a mask of the worm.
            mask = falseImg;
            mask(wormPixels) = true;
            
            % Dilate the worm.
            if ~isempty(dilateDisk)
                mask = imdilate(mask, dilateDisk);
            end
            
            % Remove the worm.
            img = single(img);
            img(mask) = NaN;
        end
    end
end

% Check for dropped frames.
timestamp = get(vr, 'timeStamp');
droppedFrames = round(timestamp / spf);

% Are we making a video of the differences?
if ~isempty(diffVideoFile)
    
    % Construct the video file.
    diffVideoFile = strrep(videoFile, '.avi', '_diff.avi');
    vw = videoWriter(diffVideoFile, 'fps', fps, 'plugin', 'DirectShow');
    
    % Initialize the video information.
    colorOffset = 16;
    noImg = uint8(zeros(size(img)));
    
    % Construct an empty RGB image.
    noRGBImg(:,:,1) = noImg;
    noRGBImg(:,:,2) = noImg;
    noRGBImg(:,:,3) = noImg;
    prevDiffRGBImg = noRGBImg;
end

% Differentiate the video.
prevTimestamp = 0;
prevImg = img;
frameDiffs(1:frames) = NaN;
i = 1;
%j = 1;
while next(vr) %&& j <= 1000
    %j = j + 1;
    
%     % Get the frame's red channel.
%     img = getframe(vr);
%     img = img(:,:,1);
        
    % Get the video frame and convert it to grayscale.
    if isGray
        img = getframe(vr);
        img = img(:,:,1);
    else
        img = rgb2gray(getframe(vr));
    end
    
    % Remove dark objects from the image.
    if remMode > 0
        
        % Correct the vignette.
        if ~isempty(vImg)
            img = uint8(single(img) - single(vImg));
        end
        
        % Binarize the image.
        bImg = otsuImg(img, true);
        bImg = ~bImg;
        
        % Remove all thresholded pixels.
        if remMode < 2
            
            % Dilate the thresholded pixels.
            if ~isempty(dilateDisk)
                bImg = imdilate(bImg, dilateDisk);
            end
            
            % Remove the thresholded pixels.
            img = single(img);
            img(bImg) = NaN;
            
        % Remove the worm.
        else
            
            % Find the worm.
            cc = bwconncomp(bImg);
            if ~isempty(cc.PixelIdxList)
                lengths = cellfun(@numel, cc.PixelIdxList);
                [~, ccMaxI] = max(lengths, [], 2);
                
                % Use the largest connected component.
                wormPixels = cc.PixelIdxList{ccMaxI};
        
                % Create a mask of the worm.
                mask = falseImg;
                mask(wormPixels) = true;
                
                % Dilate the worm.
                if ~isempty(dilateDisk)
                    mask = imdilate(mask, dilateDisk);
                end
                
                % Remove the worm.
                img = single(img);
                img(mask) = NaN;
            end
        end
    end
    
    % Check for dropped frames.
    timestamp = get(vr, 'timeStamp');
    droppedFrames = round((timestamp - prevTimestamp) / spf - 1);
    i = i + droppedFrames;
    prevTimestamp = timestamp;
    
    % Differentiate subsequent frames and measure the variance.
    % Note: frames separated by dropped frames are treated as subsequent.
    diffImg = single(img) - single(prevImg);
    frameDiffs(i) = nanvar(single(diffImg(:)));
    if remMode > 0
        frameDiffs(i) = frameDiffs(i) .^ 2;
    end
    i = i + 1;
    prevImg = img;
    
    % Update the progress.
    if ~isempty(progressFunc)
        index = i - 1;
        progressFunc(progressState, frames, index, img, diffImg, ...
            frameDiffs(index));
    end
    
    % Are we making a video of the differences?
    if ~isempty(diffVideoFile)
        
        % Label the negative changes in red.
        rImg = noImg;
        rDiffs = diffImg < 0;
        rImg(rDiffs) = uint8(abs(diffImg(rDiffs)) + colorOffset);
        
        % Label the positive changes in green.
        gImg = noImg;
        gDiffs = diffImg > 0;
        gImg(gDiffs) = uint8(abs(diffImg(gDiffs)) + colorOffset);
        
        % Construct the RGB image.
        diffRGBImg(:,:,1) = rImg;
        diffRGBImg(:,:,2) = gImg;
        diffRGBImg(:,:,3) = noImg;
        
        % Add the difference frame(s).
        for k = 1:droppedFrames
            addframe(vw, prevDiffRGBImg);
        end
        addframe(vw, diffRGBImg);
        prevDiffRGBImg = diffRGBImg;
    end
end

% Clean up.
close(vr);
if ~isempty(diffVideoFile)
    close(vw);
end
frameDiffs(i:end) = [];

% Save the video differentiation.
save(diffFile, 'fps', 'frameDiffs');
end
