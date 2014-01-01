function angles = unwrapAngles(angles, varargin)
%UNWRAPANGLES Unwrap a sequence of angles to replace discrete jumps with
%continuity.
%
%   ANGLES = UNWRAPANGLES(ANGLES)
%   ANGLES = UNWRAPANGLES(ANGLES, ISRAD)
%
%   Input:
%       angles - the angles to unwrap
%       isRad  - are the angles in radians? by default the angles are
%                assumed to be in degrees
%
%   Output:
%       angles - the unwrapped (continuous) angles
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we using radians?
isRad = false;
if ~isempty(varargin)
    isRad = varargin{1};
end

% What is the differential threshold for wrapping?
if isRad
    diffThr = pi;
else
    diffThr = 180;
end
if length(varargin) > 1
    diffThr = varargin{2};
end

% Unwrap the angles.
off = 0;
for i = 1:(length(angles) - 1)
    
    % Did the angle wrap?
    dAngle = angles(i + 1) - angles(i);
    
    % Offset the angle.
    angles(i) = angles(i) + off;
    
    % If the angle wrapped adjust the offset.
    if abs(dAngle) >= diffThr
        if dAngle < 0
            off = off + 360;
        else
            off = off - 360;
        end
    end
end

% Wrap the last angle.
angles(end) = angles(end) + off;
end
