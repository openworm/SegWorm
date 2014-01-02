function [angleArray, meanAngles] = makeAngleArray(x, y)
%MAKEANGLEARRAY Get tangent angles for each frame of normBlocks and rotate
%               to have zero mean angle
%
%   [ANGLEARRAY, MEANANGLES] = MAKEANGLEARRAY(X, Y)
%
%   Input:
%       x - the x coordinates of the worm skeleton (equivalent to 
%           dataBlock{4}(:,1,:)
%       y - the y coordinates of the worm skeleton (equivalent to 
%           dataBlock{4}(:,2,:)
%
%   Output:
%       angleArray - a numFrames by numSkelPoints - 1 array of tangent
%                    angles rotated to have mean angle of zero.
%       meanAngles - the average angle that was subtracted for each frame
%                    of the video.
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%convert block data to more intuitive form
x = permute(x, [3, 1, 2]);
y = permute(y, [3, 1, 2]);

[numFrames, lengthX] = size(x);

% initialize arrays
angleArray = zeros(numFrames, lengthX-1);
meanAngles = zeros(numFrames, 1);

% for each video frame
for i = 1:numFrames
    
    % calculate the x and y differences
    dX = diff(x(i,:));
    dY = diff(y(i,:));
    
    % calculate tangent angles.  atan2 uses angles from -pi to pi instead...
    % of atan which uses the range -pi/2 to pi/2.
    angles = atan2(dY, dX);
    
    % need to deal with cases where angle changes discontinuously from -pi
    % to pi and pi to -pi.  In these cases, subtract 2pi and add 2pi
    % respectively to all remaining points.  This effectively extends the
    % range outside the -pi to pi range.  Everything is re-centred later
    % when we subtract off the mean.
    
    % find discontinuities larger than pi (skeleton cannot change direction
    % more than pi from one segment to the next)
    positiveJumps = find(diff(angles) > pi) + 1; %+1 to cancel shift of diff
    negativeJumps = find(diff(angles) < -pi) + 1;
    
    % subtract 2pi from remainging data after positive jumps
    for j = 1:length(positiveJumps)
        angles(positiveJumps(j):end) = angles(positiveJumps(j):end) - 2*pi;
    end
    
    % add 2pi to remaining data after negative jumps
    for j = 1:length(negativeJumps)
        angles(negativeJumps(j):end) = angles(negativeJumps(j):end) + 2*pi;
    end
    
    % rotate skeleton angles so that mean orientation is zero
    meanAngle = mean(angles(:));
    meanAngles(i) = meanAngle;
    angles = angles - meanAngle;
    
    % append to angle array
    angleArray(i,:) = angles;
end