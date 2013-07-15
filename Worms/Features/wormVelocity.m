function [velocity events] = wormVelocity(x, y, fps, lengths, varargin)
%WORMVELOCITY Compute the worm velocity (speed & direction) at the
%head-tip/head/midbody/tail/tail-tip, forward/paused/backward events, and
%motion mode.
%
%   [VELOCITY EVENTS] = WORMVELOCITY(X, Y, FPS, LENGTHS)
%
%   [VELOCITY EVENTS] = WORMVELOCITY(X, Y, FPS, LENGTHS, VENTRALMODE)
%
%   Inputs:
%       x           - the worm skeleton's x-axis coordinates
%       y           - the worm skeleton's y-axis coordinates
%       fps         - the frames/seconds
%       lengths     - the worm length per frame
%       ventralMode - the ventral side mode:
%
%                     0 = the ventral side is unknown
%                     1 = the ventral side is clockwise
%                     2 = the ventral side is anticlockwise
%
%   Outputs:
%       velocity - the worm velocity; each field has subfields for the
%                  "speed" and "direction":
%
%                  headTip = the tip of the head (1/12 the worm at 0.25s)
%                  head    = the head (1/6 the worm at 0.5s)
%                  midbody = the midbody (2/6 the worm at 0.5s)
%                  tail    = the tail (1/6 the worm at 0.5s)
%                  tailTip = the tip of the tail (1/12 the worm at 0.25s)
%
%       events   - the locomotion events; a struct with event fields:
%
%                  forward  = forward locomotion
%                  paused   = no locomotion (the worm is paused)
%                  backward = backward locomotion
%                  mode     = the locomotion mode:
%
%                             -1 = backward locomotion
%                              0 = no locomotion (the worm is paused)
%                              1 = forward locomotion
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Where is the ventral side located?
ventralMode = 0;
if ~isempty(varargin)
    ventralMode = varargin{1};
end

%% Compute the lcocomotion velocity.

% Initialize the body parts.
samples = size(x, 1);
size12 = floor(samples / 12);
size6 = floor(samples / 6);
middleI = round((samples + 1) / 2);
headTipI = 1:size12;
headI = 1:size6;
midbodyI = (middleI - size12):(middleI + size12);
tailI = (samples - size6 + 1):samples;
tailTipI = (samples - size12 + 1):samples;

% Initialize the velocity derivative scale.
fps = double(fps);
tipDiff = 0.25;
bodyDiff = 0.5;

% Compute the tail-to-head direction.
bodyI = fliplr((headI(end) + 1):(tailI(1) - 1));
diffX = nanmean(diff(x(bodyI,:), 1, 1), 1);
diffY = nanmean(diff(y(bodyI,:), 1, 1), 1);
bodyAngle = atan2(diffY, diffX) * (180 / pi);

% Compute the velocity.
velocity.headTip = computeVelocity(x, y, bodyAngle, headTipI, fps, ...
    tipDiff, ventralMode);
velocity.head = computeVelocity(x, y, bodyAngle, headI, fps, ...
    bodyDiff, ventralMode);
velocity.midbody = computeVelocity(x, y, bodyAngle, midbodyI, fps, ...
    bodyDiff, ventralMode);
velocity.tail = computeVelocity(x, y, bodyAngle, tailI, fps, ...
    bodyDiff, ventralMode);
velocity.tailTip = computeVelocity(x, y, bodyAngle, tailTipI, fps, ...
    tipDiff, ventralMode);



%% Compute the locomotion events.
events = [];

% Initialize the worm speed and video frames.
speed = velocity.midbody.speed;
totalFrames = length(speed);

% Compute the distance.
distance = abs(speed / fps);

% Interpolate the missing lengths.
isNotData = isnan(lengths);
isData = ~isNotData;
dataI = find(isData);
interpI = find(isNotData);
if ~isempty(interpI) && length(dataI) > 1
    lengths(interpI) = interp1(dataI, lengths(dataI), interpI, 'linear');
end



%% Find the forward motion.
wormSpeedThr = lengths * 0.05; % 5 percent of its length
wormDistanceThr = lengths * 0.05; % 5 percent of its length
wormEventFramesThr = 0.5 * fps;
wormEventMinInterFramesThr = 0.25 * fps;
minForwardSpeed = wormSpeedThr;
minForwardDistance = wormDistanceThr;
forwardFrames = findEvent(speed, minForwardSpeed, [], true, ...
    wormEventFramesThr, [], false, ...
    minForwardDistance, [], true, distance, wormEventMinInterFramesThr);

% Compute the forward statistics.
[forwardEventStats forwardStats] = events2stats(forwardFrames, fps, ...
    distance, 'distance', 'interDistance');

% Organize the forward motion.
events.forward.frames = forwardEventStats;
events.forward.frequency = [];
events.forward.ratio = [];
if ~isempty(forwardStats)
    events.forward.frequency = forwardStats.frequency;
    events.forward.ratio = forwardStats.ratio;
end



%% Find the backward motion.
maxBackwardSpeed = -wormSpeedThr;
minBackwardDistance = wormDistanceThr;
backwardFrames = findEvent(speed, [], maxBackwardSpeed, true, ...
    wormEventFramesThr, [], false, ...
    minBackwardDistance, [], true, distance, wormEventMinInterFramesThr);

% Compute the backward statistics.
[backwardEventStats backwardStats] = events2stats(backwardFrames, fps, ...
    distance, 'distance', 'interDistance');

% Organize the backward motion.
events.backward.frames = backwardEventStats;
events.backward.frequency = [];
events.backward.ratio = [];
if ~isempty(backwardStats)
    events.backward.frequency = backwardStats.frequency;
    events.backward.ratio = backwardStats.ratio;
end



%% Find the paused motion.
wormPauseThr = lengths * 0.025; % 2.5 percent of its length
minPausedSpeed = -wormPauseThr;
maxPausedSpeed = wormPauseThr;
pausedFrames = findEvent(speed, minPausedSpeed, maxPausedSpeed, true, ...
    wormEventFramesThr, [], false, ...
    [], [], true, distance, wormEventMinInterFramesThr);

% Compute the paused statistics.
[pausedEventStats pausedStats] = events2stats(pausedFrames, fps, ...
    distance, 'distance', 'interDistance');

% Organize the paused motion.
events.paused.frames = pausedEventStats;
events.paused.frequency = [];
events.paused.ratio = [];
if ~isempty(pausedStats)
    events.paused.frequency = pausedStats.frequency;
    events.paused.ratio = pausedStats.ratio;
end



%% Compute the motion mode.

% Translate the events to logical arrays.
isForwardFrame = events2array(forwardFrames, totalFrames);
isBackwardFrame = events2array(backwardFrames, totalFrames);
isPausedFrame = events2array(pausedFrames, totalFrames);

% Set forward = 1, backward = -1, paused = 0, and unknown = NaN.
events.mode = nan(1,totalFrames);
events.mode(isForwardFrame) = 1;
events.mode(isBackwardFrame) = -1;
events.mode(isPausedFrame) = 0;
end



%% Compute the velocity.
function velocity = computeVelocity(x, y, bodyAngle, pointsI, fps, ...
    scale, ventralMode)

% The scale must be odd.
scale = scale * fps;
if rem(floor(scale), 2)
    scale = floor(scale);
elseif rem(ceil(scale), 2)
    scale = ceil(scale);
else
    scale = round(scale + 1);
end

% Do we have enough coordinates?
speed = nan(1, size(x, 2));
direction = nan(1, length(speed));
if scale > size(x, 2)
    velocity.speed = speed;
    velocity.direction = direction;
    return;
end

% Compute the body part direction.
diffX = nanmean(diff(x(pointsI,:), 1, 1), 1);
diffY = nanmean(diff(y(pointsI,:), 1, 1), 1);
pointAngle = atan2(diffY, diffX) * (180 / pi);

% Compute the coordinates.
x = mean(x(pointsI,:), 1);
y = mean(y(pointsI,:), 1);

% Compute the speed using back/front nearest neighbors bounded at twice
% the scale.
scaleMinus1 = scale - 1;
halfScale = scaleMinus1 / 2;
diff1 = 1;
diff2 = scale;
for i = (1 + halfScale):(length(speed) - halfScale)
    
    % Advance the indices for the derivative.
    newDiff1 = i - halfScale;
    if ~isnan(x(newDiff1))
        diff1 = newDiff1;
    elseif i - diff1 >= scale
        diff1 = i - scale + 1;
    end
    newDiff2 = i + halfScale;
    if ~isnan(x(newDiff2)) || newDiff2 > diff2
        diff2 = newDiff2;
    end
    
    % Find usable indices for the derivative.
    while isnan(x(diff1)) && diff1 > 1 && i - diff1 < scaleMinus1
        diff1 = diff1 - 1;
    end
    while isnan(x(diff2)) && diff2 < length(speed) && ...
            diff2 - i < scaleMinus1
        diff2 = diff2 + 1;
    end
    
    % Compute the speed.
    if ~isnan(x(diff1)) && ~isnan(x(diff2))
        diffX = x(diff2) - x(diff1);
        diffY = y(diff2) - y(diff1);
        distance = sqrt(diffX ^ 2 + diffY ^ 2);
        time = (diff2 - diff1) / fps;
        speed(i) = distance / time;
        
        % Compute the direction.
        direction(i) = pointAngle(diff2) - pointAngle(diff1);
        if direction(i) < -180
            direction(i) = direction(i) + 360;
        elseif direction(i) > 180
            direction(i) = direction(i) - 360;
        end
        direction(i) = direction(i) / fps;
        
        % Sign the speed.
        motionDirection = atan2(diffY, diffX) * (180 / pi);
        bodyDirection = motionDirection - bodyAngle(diff1);
        if bodyDirection < -180
            bodyDirection = bodyDirection + 360;
        elseif bodyDirection > 180
            bodyDirection = bodyDirection - 360;
        end
        if abs(bodyDirection) > 90
            speed(i) = -speed(i);
        end
    end
end

% Sign the direction for dorsal/ventral locomtoion.
if ventralMode < 2 % + = dorsal direction
    direction = -direction;
end

% Organize the velocity.
velocity.speed = speed;
velocity.direction = direction;
end
