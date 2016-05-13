function worms = saveWorms(filename, video, vig, samples, varargin)
%SAVEWORMS Save worms from a video to a file.
%
%   angles = saveWorms(filename, video, vig, samples)
%   angles = saveWorms(filename, video, vig, samples, scale,
%                      startFrame, endFrame)
%
% Input:
%       filename   - the filename in which to save the worms:
%                    Note: pixels & angles are ordered from head to tail
%                    worm(frame).pixels = worm pixels (x,y)
%                    worm(frame).angles = worm angles
%                    worm(frame).length = worm length (in pixels)
%                    worm(frame).error  = the error number, if one occurred
%                                         (See also WORMFRAMEANNOTATION)
%       video      - the video from which to extract worms
%       vig        - the vignette correction
%       samples    - the number of samples for the worm data
%       scale      - a scale for resizing video images to speed up
%                    processing and clean up the segmentation
%       numErode   - the number of time to erode the binary worm image
%       numDilate  - the number of time to dilate the binary worm image
%       startFrame - the start frame
%       endFrame   - the end frame
%       
% Output:
%       worms - the worm per frame
%               Note: pixels & angles are ordered from head to tail
%               worm(frame).pixels = worm pixels (x,y)
%               worm(frame).angles = worm angles
%               worm(frame).length = worm length (in pixels)
%               worm(frame).error  = the error number, if one occurred
%                                    (See also WORMFRAMEANNOTATION)
%
% See also SAVEVIG
%
%
%
% © Eviatar Yemini and Columbia University 2013
% You will not remove any copyright or other notices from the Software;
% you must reproduce all copyright notices and other proprietary notices
% on any copies of the Software.

% Are we scaling the images for speed and to clean them up?
scale = [];
if ~isempty(varargin) 
    scale = varargin{1};
end
if isempty(scale) || scale <= 0 || scale > 1
    scale = 1;
end

% Are we eroding and/or dilating the worm?
numErode = [];
numDilate = [];
if length(varargin) > 1
    numErode = varargin{2};
end
if length(varargin) > 2
    numDilate = varargin{3};
end

% Determine the start and end frames.
startFrame = 1;
endFrame = [];
if length(varargin) > 3
    startFrame = varargin{4};
end
if length(varargin) > 4
    endFrame = varargin{5};
end

% Open the video.
vr = VideoReader(video);
if isempty(endFrame)
    endFrame = vr.NumberOfFrames;
end
fps = vr.FrameRate;
height = vr.height;
width = vr.width;

% Is their a vignette?
if isempty(vig)
    vig = zeros(height, width);
end
vig = imresize(vig, scale);

% Compute the pixel scale.
pixelScale = [height, width] ./ size(vig);

% Compute the number of frames.
numFrames = endFrame - startFrame + 1;

% Compute the video center ((x,y) not (r,c)) to determine the worm's head.
center = [(width + 1) / 2, (height + 1) / 2]';

% Initialize the orientation information.
orientTimeThreshold = 0.25;
orientationSamples = [1:5 7:11] / 12;

% Extract the worm from video.
worms = [];
wormsI = 1;
prevWorm = [];
orientI = 1;
for frame = startFrame:endFrame
    
    % Get the next frame.
    img = vr.read(frame);
    
    % Scale the image.
    if scale < 1
        img = imresize(img, scale);
    end
    
    % Correct the vignette.
    img = uint8(vig + double(img));
    
    % Update our progress.
    if mod(wormsI - 1, 10) == 0
        disp(['Segmenting frame ' num2str(wormsI) '/' num2str(numFrames) ' ...']);
        
    end    % No worm was found.
    [worm, errNum, ~] = segWorm(img, frame, true, false, ...
        numErode, numDilate);
    if isempty(worm)
        worms(wormsI).frame = frame;
        worms(wormsI).pixels = [];
        worms(wormsI).angles = [];
        worms(wormsI).length = [];
        worms(wormsI).error = errNum;

    % Extract the worm.
    else
        
        % Orient the worm.
        if ~isempty(prevWorm)
            
            % Use the previous frame to orient the worm.
            if (worm.video.frame - prevWorm.video.frame) / fps < ...
                    orientTimeThreshold
                [worm, ~, ~] = orientWormAtCentroid(prevWorm, worm, ...
                    orientationSamples);
                
            % Orient the previous chunk of worms.
            else
                worms = orientWorms(worms, center, orientI, wormsI - 1);
                orientI = wormsI;
            end
        end
        prevWorm = worm;
        
        % Downsample the worm and scale the pixels.
        [pixels, pixelI] = downSampleSkeleton(worm, samples);
        pixels(:,1) = pixels(:,1) * pixelScale(1);
        pixels(:,2) = pixels(:,2) * pixelScale(2);
        
        % Save the essentials.
        worms(wormsI).frame = frame;
        worms(wormsI).pixels = fliplr(pixels); % (r,c)->(x,y)
        worms(wormsI).angles = worm.skeleton.angles(pixelI);
        worms(wormsI).length = worm.skeleton.length;
        worms(wormsI).error = [];
        
        % Correct the worm orientation.
        if worm.orientation.head.isFlipped
            worms(wormsI).pixels = flipud(worms(wormsI).pixels);
            worms(wormsI).angles = -flipud(worms(wormsI).angles);
        end
    end
    
    % Advance.
    wormsI = wormsI + 1;
end

% Orient the last chunk of worms.
worms = orientWorms(worms, center, orientI, length(worms));

% Save the file.
save(filename, 'worms', 'scale', 'fps');
end



%% Orient a set of worms.
function worms = orientWorms(worms, center, startI, endI)

% Which end is closest to the center?
pixels = cat(3, worms(startI:endI).pixels);
if ndims(pixels) < 3
    headDist = pixels(1,:)' - center;
    headDist = sum(headDist .^ 2);
    tailDist = pixels(end,:)' - center;
    tailDist = sum(tailDist .^ 2);
else
    headDist = mean(squeeze(pixels(1,:,:)), 2) - center;
    headDist = sum(headDist .^ 2);
    tailDist = mean(squeeze(pixels(end,:,:)), 2) - center;
    tailDist = sum(tailDist .^ 2);
end

% Flip the head and tail.
if headDist > tailDist
    for i = startI:endI
        worms(i).pixels = flipud(worms(i).pixels);
        worms(i).angles = -flipud(worms(i).angles);
    end
end
end
