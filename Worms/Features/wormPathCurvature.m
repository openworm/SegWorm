function curvature = wormPathCurvature(x, y, fps, varargin)
%WORMPATHCUR?VATURE Compute the worm path curvature (angle/distance).
%
%   CURVATURE = WORMPATHCURVATURE(X, Y, FPS)
%
%   CURVATURE = WORMPATHCURVATURE(X, Y, FPS, VENTRALMODE)
%
%   Inputs:
%       x           - the worm skeleton's x-axis coordinates
%       y           - the worm skeleton's y-axis coordinates
%       fps         - the frames/seconds
%       ventralMode - the ventral side mode:
%
%                     0 = the ventral side is unknown
%                     1 = the ventral side is clockwise
%                     2 = the ventral side is anticlockwise
%
%   Outputs:
%       curvature - the worm path curvature (the angle between every 3 
%                   subsequent locations at the given scale, divided by the
%                   distance traveled between these 3 subsequent locations)
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

%% Compute the path curvature.

% Initialize the body parts.
samples = size(x, 1);
size12 = floor(samples / 12);
bodyI = fliplr((1 + size12):(samples - size12));

% Initialize the velocity derivative scale.
fps = double(fps);
bodyDiff = 0.5;

% Compute the tail-to-head direction.
diffX = nanmean(diff(x(bodyI,:), 1, 1), 1);
diffY = nanmean(diff(y(bodyI,:), 1, 1), 1);
bodyAngle = atan2(diffY, diffX) * (180 / pi);

% Compute the velocity.
velocity = computeVelocity(x, y, bodyAngle, bodyI, fps, ...
    bodyDiff, ventralMode);

% Compute the path curvature.
curvature = computeCurvature(velocity.speed, velocity.direction, ...
    bodyDiff, fps);
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
        direction(i) = atan2(diffY, diffX) * (180 / pi);
        
        % Sign the direction.
        bodyDirection = direction(i) - bodyAngle(diff1);
        if bodyDirection < -180
            bodyDirection = bodyDirection + 360;
        elseif bodyDirection > 180
            bodyDirection = bodyDirection - 360;
        end
        if bodyDirection < 0
            direction(i) = -direction(i);
        end
    end
end

% Sign the direction for dorsal/ventral locomtoion.
if ventralMode > 1 % + = dorsal direction
    direction = -direction;
end

% Organize the velocity.
velocity.speed = speed;
velocity.direction = direction;
end



%% Compute the worm path curvature.
function curvature = computeCurvature(speed, direction, scale, fps)

% The frame scale must be odd.
frameScale = scale * fps;
if rem(floor(frameScale), 2)
    frameScale = floor(frameScale);
elseif rem(ceil(frameScale), 2)
    frameScale = ceil(frameScale);
else
    frameScale = round(frameScale + 1);
end
halfFrameScale = (frameScale - 1) / 2;

% Compute the angle differentials and distances.
speed = abs(speed);
diffDirection = nan(size(speed));
distance = nan(size(diffDirection));
diffDirection(1:(end - frameScale + 1)) = ...
    direction(frameScale:end) - direction(1:(end - frameScale + 1));
distanceI = (halfFrameScale + 1):(length(speed) - frameScale);
distance(distanceI) = ((speed(distanceI) + ...
    speed(distanceI + frameScale)) * scale) / 2;

% Wrap the direction.
wrap = diffDirection >= 180;
diffDirection(wrap) = diffDirection(wrap) - 360;
wrap = diffDirection <= -180;
diffDirection(wrap) = diffDirection(wrap) + 360;

% Compute the worm path curvature.
distance(distance < 1) = NaN;
curvature = (diffDirection ./ distance) * (pi / 180);
end
