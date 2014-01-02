function angles = unwrapAngles(angles, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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
