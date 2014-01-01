function [worms imgs oImgs] = segWormFrames(videoFile, frames, verbose, ...
    varargin)
%SEGWORMFRAMES Segment the worm in a set of video frames and organize
%   the information in a structure.
%
%   [WORMS IMGS OIMGS] = SEGWORMFRAMES(VIDEOFILE, FRAMES, VERBOSE)
%
%   [WORMS IMGS OIMGS] = SEGWORMFRAMES(VIDEOFILE, FRAMES, VERBOSE, SAMPLES)
%
%   [WORMS IMGS OIMGS] = SEGWORMFRAMES(VIDEOFILE, FRAMES, VERBOSE, SAMPLES,
%                                      ISINTERP)
%
%   Inputs:
%       videoFile - the name of the video to segment
%       frames    - the frames of the video to segment
%                   Note: video frame indexing begins at 0
%       verbose   - verbose mode shows the results in figures
%       samples   - the number of samples to use in verbose mode;
%                   if empty, all the worm is used.
%       isInterp  - when downsampling, should we interpolate the missing
%                   data or copy it from the original worm;
%                   if empty, we interpolate the missing data.
%
%   Output:
%       worms - the worms' information organized in a cell array of structures
%               This structure contains 8 sub-structures,
%               6 sub-sub-structures, and 4 sub-sub-sub-structures:
%
%               * Video *
%               video = {frame}
%
%               * Contour *
%               contour = {pixels, touchI, inI, outI, angles, headI, tailI}
%
%               * Skeleton *
%               skeleton = {pixels, touchI, inI, outI, inOutI, angles,
%                           length, chainCodeLengths, widths}
%
%               * Head *
%               head = {bounds, pixels, area,
%                       cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%               head.bounds{contour.left (indices for [start end]),
%                           contour.right (indices for [start end]),
%                           skeleton indices for [start end]}
%
%               * Tail *
%               tail = {bounds, pixels, area,
%                       cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%               tail.bounds{contour.left (indices for [start end]),
%                           contour.right (indices for [start end]),
%                           skeleton indices for [start end]}
%
%               * Left Side (Counter Clockwise from the Head) *
%               left = {bounds, pixels, area,
%                       cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%               left.bounds{contour (indices for [start end]),
%                           skeleton (indices for [start end])}
%
%               * Right Side (Clockwise from the Head) *
%               right = {bounds, pixels, area,
%                        cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%               right.bounds{contour (indices for [start end]),
%                            skeleton (indices for [start end])}
%
%               * Orientation *
%               orientation = {head, vulva}
%               orientation.head = {isFlipped,
%                                   confidence.head, confidence.tail}
%               orientation.vulva = {isClockwiseFromHead,
%                                   confidence.vulva, confidence.nonVulva}
%
%       imgs  - a cell array of the requested frames converted to grayscale
%               and corrected for vignetting
%       oImgs - a cell array of the requested frames
%
%   See also WORM2STRUCT, SEGWORM, and SEGWORMVIDEO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Open the video.
if ispc()
    vr = videoReader(videoFile, 'plugin', 'DirectShow');
else
    vr = videoReader(videoFile, 'plugin', 'ffmpegDirect');
end
fps = get(vr, 'fps');

% Get the vignette.
vImg = 0;
vignetteFile = strrep(videoFile, '.avi', '.info.xml.vignette.dat');
if exist(vignetteFile, 'file')
    height = get(vr, 'height');
    width = get(vr, 'width');
    fid = fopen(vignetteFile, 'r');
    vImg = fread(fid, [width height], 'int32=>int8', 0, 'b')';
    fclose(fid);
end

% Is the video grayscale?
% Note: if there's no difference between the red and green channel, we
% consider all 3 RGB channels identical grayscale images.
isGray = false;
if next(vr)
    img = getframe(vr);
    if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
        isGray = true;
    end
    
% The video is empty.
else
    close(vr);
    error('segWormFrames:EmptyVideo', 'The video is empty');
end

% Pre-allocate memory.
oImgs = cell(length(frames),1);
imgs = cell(length(frames),1);
worms = cell(length(frames),1);

% Segment the video frames.
orientSamples = [1:5 7:11] / 12;
timestamp = 0;
frame = 0;
nextWorm = [];
for i = 1:length(frames)
    
    % We are at the frame.
    isNewWorm = true;
    if frames(i) == frame
        
        % We segmented the worm.
        if ~isempty(nextWorm)
            
            % Store the worm information.
            oImgs{i} = nextOImg;
            imgs{i} = nextImg;
            worms{i} = nextWorm;
            isNewWorm = false;
            
        % We failed to segment the worm.
        elseif i > 1 && frames(i) - frames(i - 1) == 1 && ...
                ~isempty(worms{i - 1})
            isNewWorm = false;
        end
        
    % Step to the next video frame.
    elseif frames(i) - frame == 1
        next(vr);
        timestamp = get(vr, 'timeStamp');
        frame = round(timestamp * fps);
        
    % Seek the next video frame.
    elseif frames(i) > frame || (i > 1 && frames(i) < frames(i - 1))
        
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
    
    % Segment the worm and store its information.
    if isNewWorm
        
        % Did we find the requested frame?
        if frames(i) ~= frame
            warning('segWormFrames:NoFrame', ['Cannot find frame ' ...
                num2str(frames(i)) '. Perhaps it was dropped']);
            nextWorm = [];
            
        % Segment the worm and store the information.
        else
            
            % Store the original image.
            oImgs{i} = getframe(vr);
            
            % Get the video frame and convert it to grayscale.
            if isGray
                imgs{i} = getframe(vr);
                imgs{i} = imgs{i}(:,:,1);
            else
                imgs{i} = rgb2gray(getframe(vr));
            end
            
            % Correct the vignette.
            if ~isempty(vImg)
                imgs{i} = uint8(single(imgs{i}) - single(vImg));
            end
            
            % Segment the worm.
            worms{i} = segWorm(imgs{i}, frame, 1, verbose, varargin{:});
        end
    end
    
    % Show the frame information.
    if ~isempty(worms{i})
        hours = floor(timestamp / 3600);
        minutes = floor((timestamp - hours * 60) / 60);
        seconds = (timestamp - hours * 3600 - minutes * 60);
        disp(['Worm at approximate frame = ' ...
            num2str(get(vr, 'approxFrameNum')) ...
            ', real frame = '  num2str(frame) ...
            ', timestamp = ' num2str(hours) ':' ...
            num2str(minutes, '%02.0f') ':' num2str(seconds, '%02.3f')]);
        
        % Compute the proximity and head/tail movement confidence.
        if next(vr)
            
            % Did we find the requested frame?
            timestamp = get(vr, 'timeStamp');
            frame = round(timestamp * fps);
            if frames(i) + 1 ~= frame
                warning('segWormFrames:NoNextFrame', ['Frame ' ...
                    num2str(frames(i) + 1) ' cannot be found. ' ...
                    'Therefore, the orientation and head/tail' ...
                    'movement confidences cannot be computed for its ' ...
                    'previous frame ' num2str(frames(i))]);
                nextWorm = [];
                
            % Get the next video frame and convert it to grayscale.
            else
                nextOImg = getframe(vr);
                nextImg = rgb2gray(nextOImg);
                nextImg = uint8(single(nextImg) - single(vImg));
                
                % Can the worm in the next frame be segmented?
                nextWorm = segWorm(nextImg, frame, 1, verbose && ...
                    (i < length(frames) && frames(i + 1) == frame), ...
                    varargin{:});
                if isempty(nextWorm)
                    warning('segWormFrames:NoNextWorm', ['Frame ' ...
                        num2str(frames(i) + 1) ' cannot be segmented. ' ...
                        'Therefore, the orientation and head/tail' ...
                        'movement confidences cannot be computed for its ' ...
                        'previous frame ' num2str(frames(i))]);
                    
                % Orient the worm and compute the confidence.
                else
                    [nextWorm confidence flippedConfidence] = ...
                        orientWorm(worms{i}, nextWorm, orientSamples);
                    [hOrthoConfidence tOrthoConfidence ...
                        hParaConfidence tParaConfidence ...
                        hMagConfidence tMagConfidence] = ...
                        headTailMovementConfidence(worms{i}, nextWorm);
                    
                    % Show the proximity and movement confidence.
                    disp(['Proximal orientation confidence:   ' 10 ...
                        '   Confidence = ' ...
                        num2str(confidence) 10 ...
                        '   Flipped confidence = ' ...
                        num2str(flippedConfidence)]);
                    disp(['Head/tail movement confidence: ' 10 ...
                        '   Head ortho-movement confidence = ' ...
                        num2str(hOrthoConfidence) 10 ...
                        '   tail ortho-movement confidence = ' ...
                        num2str(tOrthoConfidence) 10 ...
                        '   Head para-movement confidence = ' ...
                        num2str(hParaConfidence) 10 ...
                        '   Tail para-movement confidence = ' ...
                        num2str(tParaConfidence) 10 ...
                        '   Head movement magnitude confidence = ' ...
                        num2str(hMagConfidence) 10 ...
                        '   Tail movement magnitude confidence = ' ...
                        num2str(tMagConfidence)]);
                end
            end
        end
    end
end

% Clean up.
close(vr);
end
