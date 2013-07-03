function failedFrames = segWormVideo(videoFile, anglesVideoFile, ...
    touchVideoFile, debugVideoFile, varargin)
%SEGWORMVIDEO Segment a worm video.
%
%   - Segment the video:
%   FAILEDFRAMES = SEGWORMVIDEO(VIDEOFILE, ANGLESVIDEOFILE, TOUCHVIDEOFILE,
%                               DEBUGVIDEOFILE)
%
%   - Segment the video and normalize the worm:
%   FAILEDFRAMES = SEGWORMVIDEO(VIDEOFILE, ANGLESVIDEOFILE, TOUCHVIDEOFILE,
%                               DEBUGVIDEOFILE, SAMPLES)
%
%   - Segment the video, normalize the worm, then interpolate the worm:
%   FAILEDFRAMES = SEGWORMVIDEO(VIDEOFILE, ANGLESVIDEOFILE, TOUCHVIDEOFILE,
%                               DEBUGVIDEOFILE, SAMPLES, ISINTERP)
%
%   - Segment the video, normalize the worm, then interpolate the worm, and
%     exclude stage movements:
%   FAILEDFRAMES = SEGWORMVIDEO(VIDEOFILE, ANGLESVIDEOFILE, TOUCHVIDEOFILE,
%                               DEBUGVIDEOFILE, SAMPLES, ISINTERP,
%                               INFOFILE, LOGFILE, DIFFFILE)
%
%   Inputs:
%       videoFile       - the name of the video to segment
%       anglesVideoFile - the name for the video of the worm's angles;
%                         if empty, this video is not created
%       touchVideoFile  - the name for the video of the worm's touching
%                         segments; if empty, this video is not created
%       debugVideoFile  - the name for the video of debugging information;
%                         if empty, this video is not created
%       samples         - the number of samples to use;
%                         if empty, all the worm is used.
%       isInterp        - when downsampling, should we interpolate the
%                         missing data or copy it from the original worm;
%                         if empty, we interpolate the missing data.
%       infoFile        - the XML file with the experiment information
%                         Note: if infoFile, logFile, and diffFile are
%                         undefined, all video frames are segmented
%                         (including those containing stage movements)
%       logFile         - the CSV file with the stage locations
%       diffFile        - the MAT file with the video differentiation
%
%   Outputs:
%       failedFrames - the frame numbers at which segmentation failed
%
%   See also SEGWORMFRAMES, SEGWORM, OVERLAYWORMANGLES, OVERLAYWORMTOUCH

% Are we downsampling the worm?
if ~isempty(varargin)
    downSamples = varargin{1};
    
    % Setup the stage movements.
    moves = [0, 0];
    origins = [0,0];
    pixel2MicronScale = [-1, -1];
    rotation = 1;
else
    downSamples = [];
end

% When downsampling, are we interpolating the missing data or copying it
% from the original worm?
if length(varargin) > 1
    isInterp = varargin{2};
else
    isInterp = true;
end

% Are we excluding stage movement frames?
moveFrames = [];
if length(varargin) == 5
    
    % Assign the variable input arguments.
    infoFile = varargin{3};
    logFile = varargin{4};
    diffFile = varargin{5};
    
    % Read the info to convert onscreen pixels to real-world microns.
    [pixel2MicronScale rotation] = readPixels2Microns(infoFile);
    
    % Find the stage movements.
    [moveFrames, ~, ~] = findStageMovement(infoFile, logFile, diffFile, 0);
end

% Open the video and get its information.
if ispc()
    vr = videoReader(videoFile, 'plugin', 'DirectShow');
else
    vr = videoReader(videoFile, 'plugin', 'ffmpegDirect');
end
fps = get(vr, 'fps');
spf = 1 / fps;
frames = get(vr, 'numFrames') + get(vr, 'nHiddenFinalFrames');

% Get the vignette.
vImg = [];
vignetteFile = strrep(videoFile, '.avi', '.info.xml.vignette.dat');
if exist(vignetteFile, 'file')
    height = get(vr, 'height');
    width = get(vr, 'width');
    fid = fopen(vignetteFile, 'r');
    vImg = fread(fid, [width height], 'int32=>int8', 0, 'b')';
    fclose(fid);
end

% Are we making a video showing the worm's angles (curvature)?
isVideo = false;
if ~isempty(anglesVideoFile)
    isVideo = true;
    
    % Construct a pattern to identify the head.
    ahImg = [1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1];
    [ahPattern(:,1) ahPattern(:,2)] = find(ahImg == 1);
    ahPattern(:,1) = ahPattern(:,1) - ceil(size(ahImg, 1) / 2);
    ahPattern(:,2) = ahPattern(:,2) - ceil(size(ahImg, 2) / 2);
    
    % Construct a pattern to identify the vulva.
    avImg = [1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1];
    [avPattern(:,1) avPattern(:,2)] = find(avImg == 1);
    avPattern(:,1) = avPattern(:,1) - ceil(size(avImg, 1) / 2);
    avPattern(:,2) = avPattern(:,2) - ceil(size(avImg, 2) / 2);
    
    % Choose the color scheme.
    blue = zeros(360, 3);
    blue(:,3) = 255;
    red = zeros(360, 3);
    red(:,1) = 255;
    acRGB = [blue(1:90,:); jet(181) * 255; red(1:90,:)]; % thermal
    asRGB = acRGB;
    %asRGB = [blue(1:90,:); jet(181) * 255; red(1:90,:)]; % thermal
    asRGBNaN = [255 0 0]; % red
    ahRGB = [0 255 0]; % green
    isAHOpaque = 1;
    avRGB = [255 0 0]; % red
    isAVOpaque = 1;
    
    % Construct the video file.
    if ispc()
        avw = videoWriter(anglesVideoFile, 'fps', fps, 'plugin', ...
            'DirectShow');
    else
        avw = videoWriter(anglesVideoFile, 'fps', fps, 'plugin', ...
            'ffmpegDirect');
    end
end

% Are we making a video showing the worm's touching segments?
if ~isempty(touchVideoFile)
    isVideo = true;

    % Choose the color scheme.
    thRGB = [150 150 64];
    isTHOpaque = 1;
    ttRGB = [64 64 0];
    isTTOpaque = 1;
    tvRGB = [96 96 255];
    isTVOpaque = 1;
    tnvRGB = [0 0 224];
    isTNVOpaque = 1;
    tcTouchRGB = [255 255 255];
    isTCTOpaque = 1;
    tcInRGB = [255 0 0];
    isTCIOpaque = 1;
    tcOutRGB = [0 255 0];
    isTCOOpaque = 1;
    tsTouchRGB = [255 255 255];
    isTSTOpaque = 1;
    tsInRGB = [0 255 0];
    isTSIOpaque = 1;
    tsOutRGB = [255 0 0];
    isTSOOpaque = 1;
    tsInOutRGB = [255 150 255];
    isTSIOOpaque = 1;
    
    % Construct the video file.
    if ispc()
        tvw = videoWriter(touchVideoFile, 'fps', fps, 'plugin', ...
            'DirectShow');
    else
        tvw = videoWriter(touchVideoFile, 'fps', fps, 'plugin', ...
            'ffmpegDirect');
    end
end

% Are we making a video to debug worm segmentation?
if ~isempty(debugVideoFile)
    isVideo = true;
    
    % Construct the video file.
    if ispc()
        dvw = videoWriter(debugVideoFile, 'plugin', 'DirectShow', ...
            'fps', fps, 'fourcc', 'FFDS');
    else
        dvw = videoWriter(debugVideoFile, 'plugin', 'ffmpegDirect', ...
            'fps', fps, 'fourcc', 'FFDS');
    end
end

% Is the video grayscale?
% Note: if there's no difference between the red and green channel, we
% consider all 3 RGB channels identical grayscale images.
isGray = false;
isVideoFrame = next(vr);
if isVideoFrame
    img = getframe(vr);
    if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
        isGray = true;
    end
end

% Pre-compute the values for orienting successive worm frames.
prevOrientWorm = [];
orientSamples = [1:5 7:11] / 12;

% Compute the time boundaries for small head movements.
% Note: at around, 1/30 of a second, worm movements are dwarfed by camera
% noise. On the other hand, small worm head movements can complete in just
% under 1/6 of a second. Therefore, when evaluating the head and tail
% movement confidences, we attempt to differentiate at 1/6 of a second.
% Unfortunately, due to dropped frames, stage movement, and failed
% segmentation, the requisite frame for differentiation may be missing.
% Therefore, we set an upper bound of 1/4 of a second (1.5 * 1/6) so as at
% to catch any small head movements without the possibility that the head
% returned to its initial location.
htMoveMinDiff = round(fps / 6) - 1;
htMoveMaxDiff = round(fps / 4) - 1;
prevWorms = cell(htMoveMaxDiff,1);

% Pre-allocate memory for the color, movement, and proximity confidences.
failedFrames(1:frames) = NaN; 
hOrthoConfidence = zeros(frames, 1); % head orthogonal movement confidences
tOrthoConfidence = zeros(frames, 1); % tail orthogonal movement confidences
hParaConfidence = zeros(frames, 1); % head parallel movement confidences
tParaConfidence = zeros(frames, 1); % tail parallel movement confidences
hMagConfidence = zeros(frames, 1); % head movement magnitude confidences
tMagConfidence = zeros(frames, 1); % tail movement magnitude confidences
hColorConfidence = zeros(frames, 1); % head color confidences
tColorConfidence = zeros(frames, 1); % tail color confidences
vColorConfidence = zeros(frames, 1); % vulva-side color confidences
nvColorConfidence = zeros(frames, 1); % non-vulval-side color confidences
proximityConfidence = zeros(frames, 1); % proximity confidences
flippedConfidence = zeros(frames, 1); % flipped confidences

% Measure the video frame statistics.
totalSegmentedFrames = 0;
totalUnsegmentedFrames = 0;
totalDroppedFrames = 0;

% Segment the video.
prevTimestamp = -spf;
%j = 1; % frame index
k = 1; % proximity confidences index
l = 1; % head and tail movement confidences index
m = 1; % color and movement confidences index
while isVideoFrame %&& j <= 1000
    %j = j + 1;
    
    % Get the video frame and convert it to grayscale.
    if isGray
        img = getframe(vr);
        img = img(:,:,1);
    else
        img = rgb2gray(getframe(vr));
    end
    
    % Correct the vignette.
    if ~isempty(vImg)
        img = uint8(single(img) - single(vImg));
    end
    
    % Check for dropped frames.
    timestamp = get(vr, 'timeStamp');
    frame = round(timestamp * fps);
    droppedFrames = round((timestamp - prevTimestamp) * fps - 1);
    totalDroppedFrames = totalDroppedFrames + droppedFrames;
    prevTimestamp = timestamp;
    
    % Fill in the dropped frames.
    if droppedFrames >= 1
    
        % Update the previous worms
        if droppedFrames < length(prevWorms)
            for i = (frame - droppedFrames):(frame - 1)
                prevWorms{mod(i, length(prevWorms)) + 1} = [];
            end
        else
            for i = 1:length(prevWorms)
                prevWorms{i} = [];
            end
        end
        
        % Fill in the video.
        if isVideo
            if ~isempty(anglesVideoFile) || ~isempty(touchVideoFile)
                dropImg = overlayBadWorm(img, 'd');
            end
            if ~isempty(anglesVideoFile)
                for i = 1:droppedFrames
                    addframe(avw, dropImg);
                end
            end
            if ~isempty(touchVideoFile)
                for i = 1:droppedFrames
                    addframe(tvw, dropImg);
                end
            end
            if ~isempty(debugVideoFile)
                for i = 1:droppedFrames
                    addframe(dvw, debugImg);
                end
            end
        end
    end
    
%     % Code for debugging.
%     disp(['Frame = ' num2str(get(vr, 'approxFrameNum')) ...
%         ', real frame = '  num2str(timestamp / spf) ...
%         ', timestamp = ' num2str(timestamp)]);
    
    % The stage is moving.
    if ~isempty(moveFrames) && moveFrames(frame + 1)
        prevWorms{mod(frame, length(prevWorms)) + 1} = [];
    
    % Segment the video frame.
    else
        worm = segWorm(img, frame, true, ~isempty(debugVideoFile));
        
        % Segmentation failed.
        if isempty(worm)
            totalUnsegmentedFrames = totalUnsegmentedFrames + 1;
            failedFrames(totalUnsegmentedFrames) = frame;
            prevWorms{mod(frame, length(prevWorms)) + 1} = [];

        % Orient and downsample the worm.
        else
            
            % Determine the worm orientation.
            if isempty(prevOrientWorm)
                
                % The frame segmented.
                totalSegmentedFrames = totalSegmentedFrames + 1;

                % Are the head and tail flipped?
                hColorConfidence(m) = ...
                    worm.orientation.head.confidence.head;
                tColorConfidence(m) = ...
                    worm.orientation.head.confidence.tail;
                if hColorConfidence(m) < tColorConfidence(m)
                    worm = flipWormHead(worm);
                    hColorConfidence(m) = ...
                        worm.orientation.head.confidence.head;
                    tColorConfidence(m) = ...
                        worm.orientation.head.confidence.tail;
                end
                
                % Where is the vulva?
                vColorConfidence(m) = ...
                    worm.orientation.vulva.confidence.vulva;
                nvColorConfidence(m) = ...
                    worm.orientation.vulva.confidence.nonVulva;
                if vColorConfidence(m) < nvColorConfidence(m)
                    worm = flipWormVulva(worm);
                    vColorConfidence(m) = ...
                        worm.orientation.vulva.confidence.vulva;
                    nvColorConfidence(m) = ...
                        worm.orientation.vulva.confidence.nonVulva;
                end
                m = m + 1;
                
                % Advance.
                prevOrientWorm = worm;
                prevWorms{mod(frame, length(prevWorms)) + 1} = worm;
                
            % Orient the worm relative to the nearest segmented frame.
            else
                
                % The frame segmented.
                totalSegmentedFrames = totalSegmentedFrames + 1;
                
                % Orient the worm and record its orientation confidences.
                if ~isempty(moveFrames) && moveFrames(frame)
                    [worm, proximityConfidence(k), flippedConfidence(k)] = ...
                        orientWormAtCentroid(prevOrientWorm, worm, ...
                        orientSamples);
                else % the previous frame was not a stage movement
                    [worm, proximityConfidence(k), flippedConfidence(k)] = ...
                        orientWorm(prevOrientWorm, worm, orientSamples);
                end
                k = k + 1;
                
                % Record the head and tail movement confidences.
                if htMoveMinDiff <= frame
                    
                    % Find the nearest previous differentiable worm.
                    i = htMoveMinDiff;
                    prevWormsI = mod(frame - i, length(prevWorms)) + 1;
                    prevFrame = frame - 1;
                    while i < prevFrame && i < htMoveMaxDiff && ...
                            isempty(prevWorms{prevWormsI})
                        i = i + 1;
                        prevWormsI = mod(frame - i, length(prevWorms)) + 1;
                    end
                    
                    % Record the head and tail movement confidences.
                    if ~isempty(prevWorms{prevWormsI})
                        [hOrthoConfidence(l) tOrthoConfidence(l) ...
                            hParaConfidence(l) tParaConfidence(l) ...
                            hMagConfidence(l) tMagConfidence(l)] = ...
                            headTailMovementConfidence( ...
                            prevWorms{prevWormsI}, worm);
%                         if hOrthoConfidence(l) < tOrthoConfidence(l)
%                             worm = flipWormHead(worm);
%                         end
%                         if hParaConfidence(l) < tParaConfidence(l)
%                             worm = flipWormHead(worm);
%                         end
%                         if hMagConfidence(l) < tMagConfidence(l)
%                             worm = flipWormHead(worm);
%                         end
                        l = l + 1;
                    end
                end
                
                % Record the coloration confidences.
                hColorConfidence(m) = ...
                    worm.orientation.head.confidence.head;
                tColorConfidence(m) = ...
                    worm.orientation.head.confidence.tail;
                vColorConfidence(m) = ...
                    worm.orientation.vulva.confidence.vulva;
                nvColorConfidence(m) = ...
                    worm.orientation.vulva.confidence.nonVulva;
                m = m + 1;
                
                % Advance.
                prevOrientWorm = worm;
                prevWorms{mod(frame, length(prevWorms)) + 1} = worm;
            end
            
            % Downsample the worm.
            if ~isempty(downSamples)
                
                % Normalize the worm.
                [vulvaContour nonVulvaContour skeleton skeletonAngles ...
                    inOutTouch skeletonLength widths headArea tailArea ...
                    vulvaArea nonVulvaArea] = normWorms({worm}, ...
                    downSamples, origins, moves, pixel2MicronScale, ...
                    rotation, false);
                if isInterp
                    worm = [];
                end
                
                % Reconstruct the normalized worm.
                worm = norm2Worm(frame, vulvaContour, nonVulvaContour, ...
                    skeleton, skeletonAngles, inOutTouch, ...
                    skeletonLength, widths, ...
                    headArea, tailArea, vulvaArea, nonVulvaArea, ...
                    origins, pixel2MicronScale, rotation, worm);
            end
        end
    end
    
    % Are we making a video?
    if isVideo

        % Convert the image to 8-bit grayscale.
        if isfloat(img)
            img = uint8(round(img * 255));
        end
        
        % Are we showing the worm's angles or touching segments?
        isSeg = true;
        if  ~isempty(anglesVideoFile) || ~isempty(touchVideoFile)
            
            % Overlay the stage movement.
            if ~isempty(moveFrames) && moveFrames(frame + 1)
                segImg = overlayBadWorm(img, 'm');
                isSeg = false;
                
            % Overlay the bad worm.
            elseif isempty(worm)
                segImg = overlayBadWorm(img, 'f');
                isSeg = false;
            end
        end
        
        % Show the worm's angles.
        if ~isempty(anglesVideoFile)
            if isSeg
                segImg = overlayWormAngles(img, worm, acRGB, ...
                    asRGB, asRGBNaN, ahPattern, ahRGB, isAHOpaque, ...
                    avPattern, avRGB, isAVOpaque);
            end
            addframe(avw, segImg);
        end
        
        % Show the worm's touching segments.
        if ~isempty(touchVideoFile)
            if isSeg
                segImg = overlayWormTouch(img, worm, thRGB, isTHOpaque, ...
                    ttRGB, isTTOpaque, tvRGB, isTVOpaque, ...
                    tnvRGB, isTNVOpaque, tcTouchRGB, isTCTOpaque, ...
                    tcInRGB, isTCIOpaque, tcOutRGB, isTCOOpaque, ...
                    tsTouchRGB, isTSTOpaque, tsInRGB, isTSIOpaque, ...
                    tsOutRGB, isTSOOpaque, tsInOutRGB, isTSIOOpaque);
            end
            addframe(tvw, segImg);
        end
        
        % Show the debugging information.
        if ~isempty(debugVideoFile)
            debugImg = frame2im(getframe(gcf));
            close(gcf);
            addframe(dvw, debugImg);
        end
    end
    
    % Advance to the next video frame.
    isVideoFrame = next(vr);
end

% Clean up the videos and failed frames.
close(vr);
if ~isempty(anglesVideoFile)
    close(avw);
end
if ~isempty(touchVideoFile)
    close(tvw);
end
if ~isempty(debugVideoFile)
    close(dvw);
end
failedFrames((totalUnsegmentedFrames + 1):end) = [];

% Clean up the color, movement, and proximity confidences.
proximityConfidence(k:end) = [];
flippedConfidence(k:end) = [];
hOrthoConfidence(l:end) = [];
tOrthoConfidence(l:end) = [];
hParaConfidence(l:end) = [];
tParaConfidence(l:end) = [];
hMagConfidence(l:end) = [];
tMagConfidence(l:end) = [];
hColorConfidence(m:end) = [];
tColorConfidence(m:end) = [];
vColorConfidence(m:end) = [];
nvColorConfidence(m:end) = [];

% Report the color, movement, and proximity confidences.
disp('Mean confidence:');
disp(['Head ortho-movement     = ' num2str(mean(hOrthoConfidence))]);
disp(['Tail ortho-movement     = ' num2str(mean(tOrthoConfidence))]);
disp(['Head para-movement      = ' num2str(mean(hParaConfidence))]);
disp(['Tail para-movement      = ' num2str(mean(tParaConfidence))]);
disp(['Head movement magnitude = ' num2str(mean(hMagConfidence))]);
disp(['Tail movement magnitude = ' num2str(mean(tMagConfidence))]);
disp(['Head color      = ' num2str(mean(hColorConfidence))]);
disp(['Tail color      = ' num2str(mean(tColorConfidence))]);
disp(['Vulva color     = ' num2str(mean(vColorConfidence))]);
disp(['Non-vulva color = ' num2str(mean(nvColorConfidence))]);
disp(['Proximity confidence = ' num2str(mean(proximityConfidence))]);
disp(['Flipped confidence   = ' num2str(mean(flippedConfidence))]);
[~, minI] = min(proximityConfidence ./ flippedConfidence);
disp(['Minimum confidence   = ' num2str(proximityConfidence(minI)) ...
    ' proximal vs. ' num2str(flippedConfidence(minI)) ' flipped']);

% Report the video frame statistics.
if isempty(moveFrames)
    totalMoveFrames = 0;
else
    totalMoveFrames = sum(moveFrames);
end
disp([10 '***' 10 10 'Video frame statistics:']);
disp(['Segmented frames      = ' num2str(totalSegmentedFrames)]);
disp(['Unsegmented frames    = ' num2str(totalUnsegmentedFrames)]);
disp(['Stage movement frames = ' num2str(totalMoveFrames)]);
disp(['Dropped frames        = ' num2str(totalDroppedFrames)]);
disp(['Total frames          = ' num2str(totalSegmentedFrames + ...
    totalUnsegmentedFrames + totalDroppedFrames + totalMoveFrames)]);
end
