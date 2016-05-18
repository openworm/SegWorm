function saveWormVideoOverlay(filename, video, vig, worms, wormScale, ...
    varargin)
%SAVEWORMVIDEOOVERLAY Annotate the worm video.
%
%   saveWormVideoOverlay(filename, video, vig, worms, wormScale)
%   saveWormVideoOverlay(filename, video, vig, worms, wormScale,
%                        videoScale, startFrame, endFrame)
%
% Input:
%       filename   - the filename in which to save the worms:
%                    Note: pixels & angles are ordered from head to tail
%                    worm(frame).pixels = worm pixels (x,y)
%                    worm(frame).angles = worm angles
%       video      - the video from which to extract worms
%       vig        - the vignette correction
%       samples    - the number of samples for the worm data
%       wormScale  - the scale used for extracting the worms
%       videoScale - the scale for resizing the video
%                    (to conserve disk space and processing time)
%       startFrame - the start frame
%       endFrame   - the end frame
%
%
%
% © Eviatar Yemini and Columbia University 2013
% You will not remove any copyright or other notices from the Software;
% you must reproduce all copyright notices and other proprietary notices
% on any copies of the Software.

% Are we scaling the images for speed and to clean them up?
videoScale = [];
if ~isempty(varargin) 
    videoScale = varargin{1};
end
if isempty(videoScale) || videoScale <= 0 || videoScale > 1
    videoScale = 1;
end
videoScale = min(videoScale, wormScale);

% Determine the start and end frames.
startFrame = worms(1).frame;
endFrame = worms(end).frame;
if length(varargin) > 1
    startFrame = max(startFrame, varargin{2});
end
if length(varargin) > 2
    endFrame = min(endFrame, varargin{3});
end

% Initialize the skeleton dot pattern.
dot = [0 1 1 0;
       1 1 1 1;
       1 1 1 1;
       0 1 1 0];
% dot = [0 1 1 1 0;
%        1 1 1 1 1;
%        1 1 1 1 1;
%        1 1 1 1 1;
%        0 1 1 1 0];
[dotX, dotY] = find(dot);
dotXOff = -(size(dot,2) + 1) / 2;
dotYOff = -(size(dot,1) + 1) / 2;
dotX = dotX + dotXOff;
dotY = dotY + dotYOff;

% Open the video for reading.
vr = VideoReader(video);
fps = vr.FrameRate;

% Open the video for writing.
%vw = VideoWriter(filename);
vw = VideoWriter(filename, 'MPEG-4');
vw.FrameRate = fps;
vw.open();

% Is their a vignette?
if isempty(vig)
    vig = zeros(height, width);
end
vig = imresize(vig, videoScale);

% Compute the number of frames and the offset from the worms to the video.
numFrames = endFrame - startFrame + 1;
wormsOff = startFrame - worms(1).frame;

% Compute the worm-to-video scale.
worm2videoScale = videoScale;

% Initialize the color indices.
red(1:round(numel(vig) * worm2videoScale),1) = 1;
green(1:round(numel(vig) * worm2videoScale),1) = 2;
blue(1:round(numel(vig) * worm2videoScale),1) = 3;

% Initialize the head and tail colors.
headColor(1,1:3) = 255;
tailColor(1,1:3) = 0;

% Initialize the heatmap.
blueColor = zeros(360, 3);
blueColor(:,3) = 255;
redColor = zeros(360, 3);
redColor(:,1) = 255;
angleRGB = round([blueColor(1:90,:); jet(181) * 255; redColor(1:90,:)]);

% Annotate the video.
writeI = 1;
for readI = startFrame:endFrame
    
    % Offset the worms index.
    wormsI = readI + wormsOff;
    
    % Get the next frame.
    img = vr.read(readI);

    % Scale the image.
    if videoScale < 1
        img = imresize(img, videoScale);
    end
    
    % Correct the vignette.
    img = uint8(vig + double(img));
    
    % The worm failed to segment.
    if isempty(worms(writeI).pixels)
        img = overlayBadWorm(img, 'f');
        
    % Annotate the worm.
    else
        
        % Convert the image to RGB.
        img = cat(3, img, img, img);
        
        % Scale the pixels.
        x = worms(wormsI).pixels(:,2) * worm2videoScale;
        y = worms(wormsI).pixels(:,1) * worm2videoScale;
        
        % Dot the head.
        colorX = round(x(1) + dotX);
        colorY = round(y(1) + dotY);
        badX = colorX < 1 | colorX > size(img,2);
        colorX(badX) = [];
        colorY(badX) = [];
        badY = colorY < 1 | colorY > size(img,1);
        colorX(badY) = [];
        colorY(badY) = [];
        img(sub2ind(size(img), colorX, colorY, red(1:length(colorX)))) = ...
            headColor(1);
        img(sub2ind(size(img), colorX, colorY, green(1:length(colorX)))) = ...
            headColor(2);
        img(sub2ind(size(img), colorX, colorY, blue(1:length(colorX)))) = ...
            headColor(3);
        
        % Dot the body.
        for j = 2:(length(x) - 1)
            colorX = round(x(j) + dotX);
            colorY = round(y(j) + dotY);
            badX = colorX < 1 | colorX > size(img,2);
            colorX(badX) = [];
            colorY(badX) = [];
            badY = colorY < 1 | colorY > size(img,1);
            colorX(badY) = [];
            colorY(badY) = [];
            color = angleRGB(round(worms(wormsI).angles(j) + 181),:);
            img(sub2ind(size(img), colorX, colorY, ...
                red(1:length(colorX)))) = color(1);
            img(sub2ind(size(img), colorX, colorY, ...
                green(1:length(colorX)))) = color(2);
            img(sub2ind(size(img), colorX, colorY, ...
                blue(1:length(colorX)))) = color(3);
        end
        
        % Dot the tail.
        colorX = round(x(end) + dotX);
        colorY = round(y(end) + dotY);
        badX = colorX < 1 | colorX > size(img,2);
        colorX(badX) = [];
        colorY(badX) = [];
        badY = colorY < 1 | colorY > size(img,1);
        colorX(badY) = [];
        colorY(badY) = [];
        img(sub2ind(size(img), colorX, colorY, red(1:length(colorX)))) = ...
            tailColor(1);
        img(sub2ind(size(img), colorX, colorY, green(1:length(colorX)))) = ...
            tailColor(2);
        img(sub2ind(size(img), colorX, colorY, blue(1:length(colorX)))) = ...
            tailColor(3);
    end
    
    % Record the image.
    if mod(writeI - 1, 10) == 0
        disp(['Writing frame ' num2str(writeI) '/' num2str(numFrames) ' ...']);
    end
    vw.writeVideo(img);
        
    % Advance.
    writeI = writeI + 1;
end

% Clean up.
vw.close();
end
