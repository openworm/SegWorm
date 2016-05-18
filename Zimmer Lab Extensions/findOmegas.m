function omegas = findOmegas(worms, numWormPoints, varargin)
%FINDOMEGAS Find omega turns.
%
%   [omegaEvents omegaFrames] = findOmegas(worms)
%
%   Input:
%       worms          - an array of consecutive worm frames from video
%                        See also SAVEWORMS
%       numWormPoints  - the number of points (samples) for worm data
%       bendPoints     - the bend points; either a scalar, the number of
%                        segments to divide the worm into; or, a 2xN array
%                        of (start, end) points to divide the worm into
%                        bending segments for identifying omegas turns;
%                        if empty, the worm is divided in 3 even pieces
%                        Note: an omega bend is a traveling angular wave
%                        beyond a given angular threshold. The number of
%                        bend points used bins the measured angles across
%                        body segments trading off between detection
%                        accuracy and measurement noise.
%       angleScale     - the scale (edge size) to compute bend angles;
%                        if empty, the edge size is 1
%       angleThreshold - the angular threshold for omega bends;
%                        if empty, the threshold is a 45 degree angle
%
%   Output:
%       omegaEvents - the omega events if any were found:
%                     start = the start frame
%                     end   = the end frame
%                     sign  = the omega turn sign (side)
%                     dir   = the direction of the omega turn
%                              1 = forward (head first)
%                             -1 = backward (tail first)
%
%
%
%   Note: This function identifies a traveling wave of high curvature along
%   the worm body. The wave can propagate either head-to-tail or vice versa
%   and can occur on either the dorsal or ventral side. The worm's angular
%   bends are recomputed to an appropriate physiological scale for
%   identifying omega turns. The body is then divided into several segments
%   to identify traveling waves of high curvature. Each body segment's
%   curvature is defined by the maximal bend present within. All omega
%   turns must begin and end with a semi-independent bend, meaning not all
%   segments can have high curvature. This restriction eliminates simple
%   coiled shapes that are not reflective of an omega turn. Please note, an
%   omega turn can begin propagating at one end, even before the last one
%   has completed. Therefore, we take measures to exclude identifying the
%   same omega turn twice without ruling out 2 coincident omegas occuring
%   on either side of the body.
%
%
% © Eviatar Yemini and Columbia University 2013
% You will not remove any copyright or other notices from the Software;
% you must reproduce all copyright notices and other proprietary notices
% on any copies of the Software.
% How should we divide the worm?

bendPoints = [];
if ~isempty(varargin)
    bendPoints = varargin{1};
end
if isempty(bendPoints)
    bendPoints = 3;
end

% Compute the bending segments.
if size(bendPoints,1) < 2
    
    % We can't divide the worm any further.
    bendPoints = min(bendPoints, numWormPoints);
    
    % How are we dividing the worm?
    bendSize = round(numWormPoints / bendPoints);
    numBends = bendPoints;
    
    % Compute the bends.
    bendPoints = nan(numBends,2);
    for i = 1:(numBends - 1)
        startI = (i - 1) * bendSize + 1;
        bendPoints(i,:) = [startI, startI + bendSize - 1];
    end
    bendPoints(numBends,:) = [i * bendSize + 1, numWormPoints];
end

% Compute the bending angles.
angleScale = [];
if length(varargin) > 1
    angleScale = varargin{2};
end
oldWorms = worms;
if ~isempty(angleScale) && angleScale > 1
    
    % Recompute the bending angles.
    scaledAngles = nan(numWormPoints, 1);
    for i = 1:length(worms)
        if ~isempty(worms(i).pixels)
            
            % Compute the tangent angles.
            diffPixels = worms(i).pixels((1 + angleScale):end,:) - ...
                worms(i).pixels(1:(end - angleScale),:);
            newAngles = atan2(diffPixels(:,1), diffPixels(:,2));
            
            % Compute the bending angles.
            newAngles = newAngles(1:(end - angleScale)) - ...
                newAngles((1 + angleScale):end);
            newAngles = wrapToPi(newAngles) * 180 / pi;
            scaledAngles((1 + angleScale):(end - angleScale)) = newAngles;
            
            % Store the new bending angles.
            worms(i).angles = scaledAngles;
        end
    end
end

% What angular threshold should we use to identify omega bends?
angleThreshold = 45;
if length(varargin) > 2
    angleThreshold = varargin{3};
end

% Convert the worms to angles.
minAngles = nan(size(bendPoints,1), length(worms));
maxAngles = nan(size(bendPoints,1), length(worms));
for i = 1:length(worms)
    if ~isempty(worms(i).angles)
        for j = 1:size(bendPoints,1)
            minAngles(j,i) = ...
                min(worms(i).angles(bendPoints(j,1):bendPoints(j,2)));
            maxAngles(j,i) = ...
                max(worms(i).angles(bendPoints(j,1):bendPoints(j,2)));
        end
    end
end

% Find head-first omega turns.
omegas = [];
i = 1;
while i < size(minAngles,2)
    
    % Find negatively-sided omega turns,
    % the first bend must be semi independent (not a coil).
    if minAngles(1,i) <= -angleThreshold && ...
            ~all(minAngles(2:end,i) <= -angleThreshold)
        omega = followNegOmega(minAngles, i, i, 1, 1, -angleThreshold);
        if ~isempty(omega)
            omegas = [omegas, omega];
            i = omega.start;
            while minAngles(1,i) <= -angleThreshold || ...
                    isnan(minAngles(1,i))
                i = i + 1;
            end
        end
        
    % Find positively-sided omega turns,
    % the first bend must be semi independent (not a coil).
    elseif maxAngles(1,i) >= angleThreshold && ...
            ~all(maxAngles(2:end,i) >= angleThreshold)
        omega = followPosOmega(maxAngles, i, i, 1, 1, angleThreshold);
        if ~isempty(omega)
            omegas = [omegas, omega];
            i = omega.start;
            while maxAngles(1,i) >= angleThreshold  || ...
                    isnan(maxAngles(1,i))
                i = i + 1;
            end
        end
    end
    
    % Advance.
    i = i + 1;
end

% Find tail-first omega turns.
i = size(minAngles,2);
while i > 1
    
    % Find negatively-sided omega turns,
    % the first bend must be semi independent (not a coil).
    if minAngles(1,i) <= -angleThreshold && ...
            ~all(minAngles(2:end,i) <= -angleThreshold)
        omega = followNegOmega(minAngles, i, i, 1, -1, -angleThreshold);
        if ~isempty(omega)
            omegas = [omegas, omega];
            i = omega.end;
            while minAngles(1,i) <= -angleThreshold || ...
                    isnan(minAngles(1,i))
                i = i - 1;
            end
        end
        
    % Find positively-sided omega turns,
    % the first bend must be semi independent (not a coil).
    elseif maxAngles(1,i) >= angleThreshold && ...
            ~all(maxAngles(2:end,i) >= angleThreshold)
        omega = followPosOmega(maxAngles, i, i, 1, -1, angleThreshold);
        if ~isempty(omega)
            omegas = [omegas, omega];
            i = omega.end;
            while maxAngles(1,i) >= angleThreshold || ...
                    isnan(maxAngles(1,i))
                i = i - 1;
            end
        end
    end
        
    % Advance.
    i = i - 1;
end

% Sort the omega turns.
if length(omegas) > 1
    [~, sortI] = sort([omegas.start]);
    omegas = omegas(sortI);
end
end



%% Follow a potential negatively-sided omega turn.
function omega = followNegOmega(angles, startI, frameI, bendI, ...
    increment, threshold)

% Follow the bend till the next one begins.
omega = [];
if bendI < size(angles,1)
    
    % Do we have at least one bend within threshold?
    if ~((frameI >= 1 && frameI <= size(angles,2)) && ...
            (isnan(angles(bendI, frameI)) || ...
            (angles(bendI, frameI) <= threshold)))
        return;
    end
    
    % Follow the bend till the next one begins.
    while (frameI >= 1 && frameI <= size(angles,2)) && ...
            (isnan(angles(bendI, frameI)) || ...
            (angles(bendI, frameI) <= threshold && ...
            angles(bendI + 1, frameI) > threshold))
        frameI = frameI + increment;
    end

    % Follow the omega along the bending segments.
    omega = followNegOmega(angles, startI, frameI, bendI + 1, ...
        increment, threshold);

% Follow the last bend till it ends.
else
    
    % Follow potential bends till they end.
    while (frameI >= 1 && frameI <= size(angles,2)) && ...
            isnan(angles(bendI, frameI))
        frameI = frameI + increment;
    end
    
    % Follow the last bend till it ends.
    while (frameI >= 1 && frameI <= size(angles,2)) && ...
            angles(bendI, frameI) <= threshold
        frameI = frameI + increment;
    end
    
    % The last bend must be semi independent (not a coil).
    frameI = frameI - increment;
    if angles(bendI, frameI) <= threshold && ...
            ~all(angles(1:(end - 1), frameI) <= threshold)
        
        % Record the omega turn.
        omega.start = min(startI, frameI);
        omega.end = max(startI, frameI);
        omega.sign = -1;
        omega.dir = increment;
    end
end
end



%% Follow a potential positively-sided omega turn.
function omega = followPosOmega(angles, startI, frameI, bendI, ...
    increment, threshold)

% Follow the bend till the next one begins.
omega = [];
if bendI < size(angles,1)
    
    % Do we have at least one bend within threshold?
    if ~((frameI >= 1 && frameI <= size(angles,2)) && ...
            (isnan(angles(bendI, frameI)) || ...
            (angles(bendI, frameI) >= threshold)))
        return;
    end
    
    % Follow the bend till the next one begins.
    while (frameI >= 1 && frameI <= size(angles,2)) && ...
            (isnan(angles(bendI, frameI)) || ...
            (angles(bendI, frameI) >= threshold && ...
            angles(bendI + 1, frameI) < threshold))
        frameI = frameI + increment;
    end

    % Follow the omega along the bending segments.
    omega = followPosOmega(angles, startI, frameI, bendI + 1, ...
        increment, threshold);

% Follow the last bend till it ends.
else
    
    % Follow potential bends till they end.
    while (frameI >= 1 && frameI <= size(angles,2)) && ...
            isnan(angles(bendI, frameI))
        frameI = frameI + increment;
    end
    
    % Follow the last bend till it ends.
    while (frameI >= 1 && frameI <= size(angles,2)) && ...
            angles(bendI, frameI) >= threshold
        frameI = frameI + increment;
    end
    
    % The last bend must be semi independent (not a coil).
    frameI = frameI - increment;
    if angles(bendI, frameI) >= threshold && ...
            ~all(angles(1:(end - 1), frameI) >= threshold)
        
        % Record the omega turn.
        omega.start = min(startI, frameI);
        omega.end = max(startI, frameI);
        omega.sign = -1;
        omega.dir = increment;
    end
end
end



%% Wrap the angles.
function angles = wrapToPi(angles)
anglesI = angles > pi;
angles(anglesI) = angles(anglesI) - 2 * pi;
anglesI = angles < -pi;
angles(anglesI) = angles(anglesI) + 2 * pi;
end
