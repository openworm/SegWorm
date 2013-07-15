function [velocities centroidVelocities] = ...
    wormVelocityTest(wormFile, indices, use, type, scales, isSparse, verbose)
%SEGWORMVIDEOFRAMES Segment the worm in a set of video frames and organize
%   the information in a structure.
%
%   [WORMS IMGS OIMGS] = SEGWORMVIDEOFRAMES(VIDEOFILE, FRAME, VERBOSE)
%
%   Inputs:
%       infoFile     - the XML file with the experiment information
%       logFile      - the CSV file with the stage locations
%       diffFile     - the MAT file with the video differentiation
%       videoFile    - the name of the video to segment
%       vignetteFile - an optional file with the video vignette correction
%       startFrameI  - the starting frame of the video sequence to segment
%       endFrameI    - the ending frame of the video sequence to segment
%       samples      - the number of samples to use in order to normalize
%                      the worms (see normWorms)
%       use          - if not empty, for each frame, is it usable?
%                      The 'use' vector allows one to test replacement
%                      algorithms (e.g., interpolation, nearest neighbor,
%                      etc.), in differentiation, by comparing the results
%                      from real data with tests where elements of this
%                      data have been removed by being declared unusable.
%                      Note: stage movements and failed segmentation are
%                      ALWAYS treated as unusable.
%       type         - the type of algorithm to use when replacing unusable
%                      data samples (e.g., due to stage movements or failed
%                      segmentation). Differentiation is expressed as:
%
%                      dX/dT = -(X1 - X2)/(T1 - T2)
%
%                      type is a 1 or 2 letter string indicating which
%                      method to use when replacing an unusable X1 and/or
%                      X2. If type is 2 characters long:
%
%                      type(1) = X1
%                      type(2) = X2
%
%                      Otherwise, type(1) is used for both X1 and X2. The
%                      methods are as follows:
%
%                      i = linearly interpolate unusable data
%                          (type(2) is ignored)
%                      e = exact match, if data is unusable, the result is NaN
%                      b = backwards nearest neighbor
%                      f = forwards nearest neighbor
%                      n = nearest neighbor
%
%                      Note: the nearest-neighbor type algorithms adjust
%                      the time accordingly. If there is no nearest
%                      neighbor, differentiation results in NaN.
%       scales       - a vector of the scales (in seconds) to use for
%                      spacing X1 from X2
%       isSparse     - is the differentiation sparse? for each scale,
%                      sparse differentiation only calculates the data
%                      differences at multiples of that scale
%       verbose      - verbose mode shows the results in figures
%
%   Output:
%       velocities         - a cell array of the velocities at each scale
%       centroidVelocities - a cell array of the centroid velocities at
%                            each scale. The centroid is calculated from
%                            the worm's contour.
%
%   See also MULTISCALEDIFF, NORMWORMS, SEGWORMVIDEOFRAMES
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Read the info to convert onscreen pixels to real-world microns.
[pixel2MicronScale rotation] = readPixels2Microns(infoFile);

% Find the stage movements.
[moveFrames moves origins] = findStageMovement(infoFile, logFile, ...
    diffFile, 0);

% Get the vignette.
vImg = 0;
if exist(vignetteFile, 'file')
    fid = fopen(vignetteFile, 'r');
    vImg = fread(fid, [640 480],'int32=>int8', 0, 'b')';
    fclose(fid);
end

% Open the video.
vr = videoReader(videoFile, 'plugin', 'DirectShow');

% Get the frames/second.
fps = get(vr, 'fps');

% Segment the video frames.
frames = startFrameI:endFrameI;
if isempty(use) % can we use every frame?
    use = true(length(frames), 1);
end
worms = cell(length(frames),1);
prevFrame = NaN;
for i = 1:length(frames)
    
    % Skip over stage movement.
    if moveFrames(frames(i) + 1)
        if frames(i) - prevFrame == 1
            
            % Is the next frame not a stage movement?
            if i < length(frames) && ~moveFrames(frames(i + 1) + 1) && ...
                    (frames(i + 1) - frames(i)) == 1 && next(vr)
                
                % Segment the next frame's worm.
                img2 = rgb2gray(getframe(vr));
                img2 = uint8(single(img2) - single(vImg));
                worm2 = segWorm(img2, frames(i) + 1, 1, false);
            end
            
            % Advance.
            prevFrame = frames(i);
        end
        
        % Skip to the next frame.
        continue;
    end
    
    % Use the next video frame.
    if frames(i) - prevFrame == 1
        worms{i} = worm2;

    % Get the new video frame.
    else
        seek(vr, frames(i));
        
        % Convert the frame to grayscale.
        img = rgb2gray(getframe(vr));

        % Correct the vignette.
        if ~isempty(vImg)
            img = uint8(single(img) - single(vImg));
        end
        
        % Segment the worm.
        worms{i} = segWorm(img, frames(i), 1, false);
        
        % The worm is unusable.
        if isempty(worms{i})
            use(i) = false;
        end
        
        % Show the frame information.
        timestamp = get(vr, 'timeStamp');
        hours = floor(timestamp / 3600);
        minutes = floor((timestamp - hours * 60) / 60);
        seconds = (timestamp - hours * 3600 - minutes * 60);
        disp(['Worm ' num2str(frames(i)) 'at approximate frame = ' ...
            num2str(get(vr, 'approxFrameNum')) ', real frame = '  ...
            num2str(timestamp * get(vr, 'fps')) ', timestamp = ' ...
            num2str(hours) ':' num2str(minutes, '%02.0f') ':' ...
            num2str(seconds, '%02.3f')]);
    end
    
    % Advance.
    prevFrame = frames(i);
    
    % Compute the proximity and head/tail movement confidence.
    if next(vr)
        
        % Get the next video frame and convert it to grayscale.
        img2 = rgb2gray(getframe(vr));
        img2 = uint8(single(img2) - single(vImg));
        
        % Did the worm in the next frame segment?
        worm2 = segWorm(img2, frames(i) + 1, 1, 0);
        if ~isempty(worm2)
            
            % Orient the worm and compute the confidence.
            samples = [1:3 5:7] / 8;
            [worm2 confidence flippedConfidence] = ...
                orientWorm(worms{i}, worm2, samples);
            [hConfidence tConfidence] = ...
                headTailMovementConfidence(worms{i}, worm2);
            
            % Show the proximity and movement confidence.
            if verbose
                disp(['Proximal orientation confidence:   ' ...
                    ' confidence = ' num2str(confidence) ...
                    ' flipped confidence = ' num2str(flippedConfidence)]);
                disp(['Head/tail movement confidence: ' ...
                    ' head confidence = ' num2str(hConfidence) ...
                    ' tail confidence = ' num2str(tConfidence)]);
            end
        end
    end
end

% Clean up.
close(vr);

% Normalize the worms.
[vulvaContours nonVulvaContours skeletons angles inOutTouches ...
    lengths widths headAreas tailAreas vulvaAreas nonVulvaAreas] = ...
    normWorms(worms, samples, moves, origins, framesStart - 1, ...
    pixel2MicronScale, rotation, false);

% Organize the normalized worm data.
data{1} = squeeze(skeletons(:,1,:));
data{2} = squeeze(skeletons(:,2,:));
data{3} = mean([squeeze(vulvaContours(:,1,:)); ...
    squeeze(nonVulvaContours(:,1,:))], 1);
data{4} = mean([squeeze(vulvaContours(:,1,:)); ...
    squeeze(nonVulvaContours(:,1,:))], 1);
if verbose
    data{5} = angles;
    data{6} = lengths;
    data{7} = widths;
    data{8} = headAreas;
    data{9} = tailAreas;
    data{10} = vulvaAreas;
    data{11} = nonVulvaAreas;
end

% Pre-allocate memory.
velocities = cell(length(scales), 1);
centroidVelocities = cell(length(scales), 1);

% Differentiate the normalized worm data.
diffData = multiScaleDiff(data, use, 1 / fps, type, ...
    round(scales / fps), isSparse);
for i = 1:length(scales)
    velocities{i} = sqrt(diffData{1}{i} .^ 2 + diffData{2}{i} .^ 2);
    centroidVelocities{i} = sqrt(diffData{3}{i} .^ 2 + diffData{4}{i} .^ 2);
end

% Show the results in a figure.
if verbose
end
end
