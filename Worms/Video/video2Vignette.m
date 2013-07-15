function vignette = video2Vignette(videoFile, frames, threshold, ...
    otsuStdDev, dilatePixels, erodePixels, smoothPixels, varargin)
%VIDEO2VIGNETTE Compute the vignette from a video. Exclude the largest
%   dark, connected component (i.e., exclude the worm). And, exlcude frames
%   where the largest dark, connected component touches an edge (i.e.,
%   exclude the vignette).
%
%   VIGNETTE = VIDEO2VIGNETTE(VIDEOFILE, FRAMES, THRESHOLD, OTSUSTDDEV, 
%                             DILATEPIXELS, ERODEPIXELS, SMOOTHPIXELS)
%
%   VIGNETTE = VIDEO2VIGNETTE(VIDEOFILE, FRAMES, THRESHOLD, OTSUSTDDEV, 
%                             DILATEPIXELS, ERODEPIXELS, SMOOTHPIXELS,
%                             VIGNETTEFILE)
%
%   VIGNETTE = VIDEO2VIGNETTE(VIDEOFILE, FRAMES, THRESHOLD, OTSUSTDDEV,
%                             DILATEPIXELS, ERODEPIXELS, SMOOTHPIXELS,
%                             VIGNETTEFILE, INFOFILE)
%
%   VIGNETTE = VIDEO2VIGNETTE(VIDEOFILE, FRAMES, THRESHOLD, OTSUSTDDEV, 
%                             DILATEPIXELS, ERODEPIXELS, SMOOTHPIXELS,
%                             VIGNETTEFILE, INFOFILE, LOGFILE, DIFFFILE)
%
%   VIGNETTE = VIDEO2VIGNETTE(VIDEOFILE, FRAMES, THRESHOLD, OTSUSTDDEV, 
%                             DILATEPIXELS, ERODEPIXELS, SMOOTHPIXELS,
%                             VIGNETTEFILE, INFOFILE, LOGFILE, DIFFFILE,
%                             IMPRINTSIZETHR, IMPRINTINTENSITYTHR,
%                             IMPRINTDILATEPIXELS, IMPRINTNEIGHBORAVG)
%
%   Inputs:
%       videoFile    - the name of the video for computing the vignette
%       frames       - the frames for computing the vignette;
%                      if empty, all frames are used
%                      Note 1: video frame indexing begins at 0
%                      Note 2: if the infoFile, logFile, and diffFile are
%                      defined, we use the stage movement frames instead
%       threshold    - the threshold for binarizing the image; this
%                      threshold is between 0-1.0 or 0-255 (black to
%                      white); if empty, we use the Otsu threshold instead
%                      Note: if the infoFile is defined, we use the
%                      user-defined threshold instead
%       otsuStdDev   - if we are thresholding using the Otsu method, this
%                      value is the standard deviations, from the Otsu
%                      threshold's foreground mean, at which to threshold;
%                      if empty, we threshold at the Otsu threshold
%                      Note: if the infoFile is defined, we use the
%                      user-defined threshold instead
%       dilatePixels - the number of neighboring pixels to use for
%                      dilating the lagest connected component; if empty,
%                      the largest connected component isn't dilated
%       erodePixels  - the number of neighboring pixels to use for
%                      eroding the lagest connected component; if empty,
%                      the largest connected component isn't eroded
%       smoothPixels - the number of neighboring pixels to use for
%                      gaussian smoothing the vignette; if empty, the
%                      vignette isn't smoothed
%       vignetteFile - the name of the file in which to store the vignette;
%                      if empty, the vignette isn't stored
%       infoFile     - the XML file with the experiment information
%       logFile      - the CSV file with the stage locations
%       diffFile     - the MAT file with the video differentiation
%       imprintSizeThr      - the size threshold for removing any worm
%                             imprints in the vignette
%       imprintIntensityThr - the intensity threshold for removing any worm
%                             imprints in the vignette; the default is 0
%                             (the intensity is centered near 0)
%       imprintDilatePixels - the number of neighboring pixels to use for
%                             dilating the worm imprint; if empty, the worm
%                             imprint isn't dilated
%       imprintNeighborAvg  - the number of neighboring pixels to use in
%                             determining the imprint's replacement value.
%                             The mean of the imprint's bordering pixels,
%                             at this width, determines the imprint's
%                             replacement value.
%
%   Output:
%       vignette - the video's vignette
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we saving the vignette to a file?
vignetteFile = [];
if ~isempty(varargin)
    vignetteFile = varargin{1};
end

% Are we using the user-defined threshold?
if length(varargin) > 1
    
    % Read the threshold configuration.
    infoFile = varargin{2};
    xml = xmlread(infoFile);
    boundary = lower(strtrim(xmlReadTag(xml, ...
        'configuration.info.tracker.boundary.type')));
    isAuto = lower(strtrim(xmlReadTag(xml, ...
        'configuration.info.tracker.algorithm.threshold.auto.on')));
    
    % Read the threshold.
    threshold = [];
    otsuStdDev = [];
    if (isequal(boundary, 'centroid') || isequal(boundary, 'both'))
        if isequal(isAuto, 'false')
            threshold = str2double(xmlReadTag(xml, ...
                'configuration.info.tracker.algorithm.threshold.manual'));
        else
            otsuStdDev = -str2double(xmlReadTag(xml, ['configuration.' ...
                'info.tracker.algorithm.threshold.auto.deviation']));
        end
    end
end

% Are we using the stage movement frames?
if isempty(frames) && length(varargin) > 3
    
    % Find the stage movements.
    logFile = varargin{3};
    diffFile = varargin{4};
    [moveFrames, ~, ~] = findStageMovement(infoFile, logFile, diffFile, 0);
    frames = find(moveFrames) - 1;
end

% Are we removing the worm imprint from the vignette?
imprintSizeThr = [];
if length(varargin) > 4
    
    % Determine the worm imprint size threshold.
    imprintSizeThr = varargin{5};
    
    % Determine the worm imprint intensity threshold.
    imprintIntensityThr = 0;
    if length(varargin) > 5
        imprintIntensityThr = varargin{6};
    end
    
    % Determine the worm imprint dilation.
    imprintDilatePixels = 5;
    if length(varargin) > 6
        imprintDilatePixels = varargin{7};
    end
    
    % Determine the width of the imprint's neighboring border to use
    % in computing imprint's the replacement value.
    imprintNeighborAvg = 5;
    if length(varargin) > 7
        imprintNeighborAvg = varargin{8};
    end
end

% Open the video and get its information.
if ispc()
    vr = videoReader(videoFile, 'plugin', 'DirectShow');
else
    vr = videoReader(videoFile, 'plugin', 'ffmpegDirect');
end
fps = get(vr, 'fps');
height = get(vr, 'height');
width = get(vr, 'width');
imgSize = height * width;
imgNWCorner = imgSize - height + 1;

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

% Check the frames.
if isempty(frames)
    frames = 0:(get(vr, 'numFrames') - 1);
end

% Check the threshold.
if threshold > 1
    threshold = double(threshold) / 255.0;
end

% Create the dilation disk.
dilateDisk = [];
if dilatePixels > 0
    dilateDisk = strel('disk', dilatePixels);
end

% Create the erosion disk.
erodeDisk = [];
if erodePixels > 0
    erodeDisk = strel('disk', erodePixels);
end

% Pre-allocate memory.
trueImg = true(height, width);
vignette = double(zeros(height, width));
numVignetteFrames = 0;

% Average the video frames.
frames = unique(sort(frames));
frame = 0;
for i = 1:length(frames)
    
    % Step to the next video frame.
    if frames(i) - frame == 1
        next(vr);
        timestamp = get(vr, 'timeStamp');
        frame = round(timestamp * fps);
        
    % Seek the next video frame.
    elseif frames(i) > frame
        
        % Find the requested frame.
        % Note: seek is inaccurate.
        seek(vr, frames(i));
        timestamp = get(vr, 'timeStamp');
        
        % We overshot the requested frame.
        j = frames(i);
        while j > 0 && round(timestamp * fps) > frames(i)
            j = j - 1;
            seek(vr, j);
            timestamp = get(vr, 'timeStamp');
        end
        
        % We undershot the requested frame.
        isNextFrame = true;
        while isNextFrame && round(timestamp * fps) < frames(i)
            isNextFrame = next(vr);
            timestamp = get(vr, 'timeStamp');
        end
        frame = round(timestamp * fps);
    end
    
    % The frame is missing.
    if frames(i) ~= frame
        continue;
    end
    
    % Get the video frame and convert it to grayscale.
    if isGray
        img = getframe(vr);
        img = img(:,:,1);
    else
        img = rgb2gray(getframe(vr));
    end
    
    % Binarize the image.
    if isempty(threshold)
        bImg = otsuImg(img, true, otsuStdDev);
    else
        bImg = im2bw(img, threshold);
    end
    
    % Find the worm.
    bImg = ~bImg;
    cc = bwconncomp(bImg);
    if ~isempty(cc.PixelIdxList)
        lengths = cellfun(@numel, cc.PixelIdxList);
        [~, ccMaxI] = max(lengths, [], 2);
        
        % Use the largest connected component.
        wormPixels = cc.PixelIdxList{ccMaxI};
        
        % The largest connected component must not any of the edges.
        if ~any(wormPixels <= height) && ... % east
                ~any(wormPixels >= imgNWCorner) && ... % west
                ~any(mod(wormPixels, height) == 0) && ... % south
                ~any(mod(wormPixels - 1, height) == 0) % north
            
            % Create a mask of the worm.
            if isempty(dilateDisk) && isempty(erodeDisk)
                mask = trueImg;
                mask(wormPixels) = false;
                
            % Create a mask of the worm and dilate then erode it.
            else
                
                % Create a mask of the worm.
                % Note: the mask is reversed, the worm is the background.
                mask = trueImg;
                mask(wormPixels) = false;
                
                % Dilate the worm.
                % Note: we erode the foreground to dilate the worm.
                if ~isempty(dilateDisk)
                    mask = imerode(mask, dilateDisk);
                end
                
                % Erode the worm.
                % Note: we dilate the background to erode the worm.
                if ~isempty(erodeDisk)
                    mask = imdilate(mask, erodeDisk);
                end
            end
            
            % Add the masked vignette.
            vignette(mask) = vignette(mask) + double(img(mask)) - ...
                mean(img(mask));
            numVignetteFrames = numVignetteFrames + 1;
        end
    end
end

% Clean up.
close(vr);

% Do we have enough frames?
if numVignetteFrames < 2
    warning('video2Vignette:frames', ...
        'The vignette was computed using %d frames', numVignetteFrames);
end

% Average the vignette.
if numVignetteFrames > 0
    vignette = vignette / numVignetteFrames;
else
    vignette(:) = NaN;
end

% Remove any final worm imprint.
if imprintSizeThr > 0
    
    % Threshold the vignette.
    bVigImg = vignette < imprintIntensityThr;
    
    % Find any worm imprint.
    cc = bwconncomp(bVigImg);
    if ~isempty(cc.PixelIdxList)
        lengths = cellfun(@numel, cc.PixelIdxList);
        [~, orderI] = sort(lengths, 'descend');
        
        % The largest connected component must not any of the edges.
        i = 1;
        wormPixels = cc.PixelIdxList{orderI(i)};
        while i < length(orderI) && ...
                lengths(orderI(i)) > imprintSizeThr && ... % size threshold
                (any(wormPixels <= height) || ... % east
                any(wormPixels >= imgNWCorner) || ... % west
                any(mod(wormPixels, height) == 0) || ... % south
                any(mod(wormPixels - 1, height) == 0)) % north
            i = i + 1;
            wormPixels = cc.PixelIdxList{orderI(i)};
        end
        
        % We found a worm imprint.
        if i < length(orderI) && lengths(orderI(i)) > imprintSizeThr
            
            % Create a mask of the worm imprint.
            imprintMask = false(height, width);
            imprintMask(wormPixels) = true;
            
            % Dilate the worm imprint.
            if imprintDilatePixels > 0
                imprintDilateDisk = strel('disk', imprintDilatePixels);
                imprintMask = imdilate(imprintMask, imprintDilateDisk);
            end
            
            % Measure the non-imprint neighbors.
            neighborDilateDisk = strel('disk', imprintNeighborAvg);
            neighborMask = imprintMask;
            neighborMask = imdilate(neighborMask, neighborDilateDisk);
            neighborMask(imprintMask) = false;
            neighborValue = nanmean(vignette(neighborMask));
            
            % Remove the imprint.
            vignette(imprintMask) = neighborValue;
        end
    end
end

% Smooth the vignette.
if smoothPixels > 1
    blurWin = gausswin(smoothPixels);
    blurWin = blurWin * blurWin';
    blurWin = blurWin / sum(blurWin(:));
    vignette = conv2(vignette, blurWin, 'same');
end

% Write the vignette.
if ~isempty(vignetteFile)
    fid = fopen(vignetteFile, 'w');
    fwrite(fid, vignette', 'int32', 0, 'b');
    fclose(fid);
end
end
