function events2video_native(eventFrames, videoFile, eventVideoFile, varargin)
%EVENTS2VIDEO Create a video of events.
%
%   EVENTS2VIDEO(EVENTFRAMES, VIDEOFILE, EVENTVIDEOFILE)
%
%   EVENTS2VIDEO(EVENTFRAMES, VIDEOFILE, EVENTVIDEOFILE, CONVERT2GRAY)
%
%   EVENTS2VIDEO(EVENTFRAMES, VIDEOFILE, EVENTVIDEOFILE, CONVERT2GRAY
%                ISHOWFRAME)
%
%   EVENTS2VIDEO(EVENTFRAMES, VIDEOFILE, EVENTVIDEOFILE, CONVERT2GRAY
%                ISHOWFRAME, ISSHOWTIME)
%
%   EVENTS2VIDEO(EVENTFRAMES, VIDEOFILE, EVENTVIDEOFILE, CONVERT2GRAY
%                ISHOWFRAME, ISSHOWTIME, EVENTSEPARATORTIME)
%
%   Inputs:
%       eventFrames        - the event frames (see findEvent)
%       videoFile          - the name of the video file
%       eventVideoFile     - the name for the event video file to create
%       isConvert2Gray     - should we convert the video to grayscale?
%                            The default is false.
%       isShowFrame        - are we showing the frame numbers in the video?
%                            The default is true.
%       isShowTime         - are we showing the timestamp in the video?
%                            The default is true.
%       eventSeparatorTime - how much time separates each event?
%                            The default is 2 seconds.
%
% See also FINDEVENT
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are there any events?
if isempty(eventFrames)
    warning('events2video:NoEvents', 'There are no events');
    return;
end

% Are we converting the video to grayscale?
isConvert2Gray = false;
if ~isempty(varargin)
    isConvert2Gray = varargin{1};
end

% Are we showing the frame number?
isShowFrame = true;
if length(varargin) > 1
    isShowFrame = varargin{2};
end

% Are we showing the timestamp?
isShowTime = true;
if length(varargin) > 2
    isShowTime = varargin{3};
end

% How many seconds interlude is there between showing events?
eventSeparatorTime = 2;
if length(varargin) > 3
    eventSeparatorTime = varargin{4};
end

% Open the video.
vr = VideoReader(videoFile);
fps = vr.FrameRate;

% Is the video grayscale?
% Note: if there's no difference between the red and green channel, we
% consider all 3 RGB channels identical grayscale images.
isGray = false;
img = vr.read(1);
if ~isempty(img)
    imgSize = size(img);
    if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
        isGray = true;
    end
    
% The video is empty.
else
    error('events2video:EmptyVideo', 'The video is empty');
end

% Construct the video file of events.
%vw = VideoWriter(eventVideoFile, 'Motion JPEG AVI');
vw = VideoWriter(eventVideoFile, 'MPEG-4');
vw.FrameRate = 3*fps;
vw.open();

% Create a video of the events.
eventSeperatorFrames = round(eventSeparatorTime * fps);
for i = 1:length(eventFrames)
    
    % Record the event seperator.
    if eventSeperatorFrames > 0
        
        % Construct an image with the event information.
        if isConvert2Gray
            infoImg = uint8(zeros(imgSize(1:2)));
        else
            infoImg = uint8(zeros(imgSize));
        end
        
        % Show the event's starting frame number.
        startImg = ...
            text2im(['Start Frame: ' num2str(eventFrames(i).start)]);
        infoImg(1:size(startImg,1),1:size(startImg,2),1) = ...
            startImg * 255;
        if ndims(infoImg) > 2
            infoImg(1:size(startImg,1),1:size(startImg,2),2) = ...
                startImg * 255;
            infoImg(1:size(startImg,1),1:size(startImg,2),3) = ...
                startImg * 255;
        end

        % Show the event's ending frame number.
        endImg = text2im(['End Frame: ' num2str(eventFrames(i).end)]);
        infoImg((end - size(endImg,1) + 1):end, ...
            (end - size(endImg,2) + 1):end,1) = endImg * 255;
        if ndims(infoImg) > 2
            infoImg((end - size(endImg,1) + 1):end, ...
                (end - size(endImg,2) + 1):end,2) = endImg * 255;
            infoImg((end - size(endImg,1) + 1):end, ...
                (end - size(endImg,2) + 1):end,3) = endImg * 255;
        end

        % Record the event information image.
        disp(['Writing separator ' num2str(i) ' ...']);
        for j = 1:eventSeperatorFrames
            vw.writeVideo(infoImg);
        end
    end
    
    % Save the event frames.
    disp(['Writing event ' num2str(i) ' ...']);
    for j = eventFrames(i).start:eventFrames(i).end
        
        % Get the video frame.
        img = vr.read(j);
        
        % Convert the frame to grayscale.
        if isConvert2Gray
            if isGray
                img = img(:,:,1);
            else
                img = rgb2gray(getframe(vr));
            end
        end
        
        % Show the frame number.
        if isShowFrame
            frameImg = text2im(['Frame: ' num2str(j )]);
            img(1:size(frameImg,1),1:size(frameImg,2),1) = ...
                frameImg * 255;
            if ndims(img) > 2
                img(1:size(frameImg,1),1:size(frameImg,2),2) = ...
                    frameImg * 255;
                img(1:size(frameImg,1),1:size(frameImg,2),3) = ...
                    frameImg * 255;
            end
        end
        
        % Show the timestamp.
        if isShowTime
            timeImg = text2im(['Time: ' num2str(j / fps, '%.3f')]);
            img((end - size(timeImg,1) + 1):end, ...
                (end - size(timeImg,2) + 1):end,1) = timeImg * 255;
            if ndims(img) > 2
                img((end - size(timeImg,1) + 1):end, ...
                    (end - size(timeImg,2) + 1):end,2) = timeImg * 255;
                img((end - size(timeImg,1) + 1):end, ...
                    (end - size(timeImg,2) + 1):end,3) = timeImg * 255;
            end
        end
        
        % Record the image.
        disp(['Writing frame ' num2str(j) ' ...']);
        vw.writeVideo(img);
    end
end

% Clean up.
vw.close();
end
