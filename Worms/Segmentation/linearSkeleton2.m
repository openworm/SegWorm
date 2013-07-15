function skeleton = ...
    linearSkeleton2(headI, tailI, minP, minI, maxP, maxI, contour, wormSegSize)
%LINEARSKELETON2 Skeletonize a linear (non-looped) worm. The worm is
%skeletonized by splitting its contour, from head to tail, into short
%segments. These short segments are bounded by matching pairs of maximal
%and minimal angles (with magnitude > 20 degrees) on opposite sides of the
%worm's contour. We then walk along the opposing sides of these short
%segments and mark the midline as our skeleton. The final step is cleaning
%up this skeleton to remove overlapping points and interpolate missing ones.
%
%   LINEARSKELETON2(HEADI, TAILI, MINP, MINI, MAXP, MAXI, CONTOUR)
%
%   Inputs:
%       headI       - the head's contour index
%       tailI       - the tail's contour index
%       minP        - the local minimal peaks
%       minI        - the local minimal peaks' contour indices
%       maxP        - the local maximal peaks
%       maxI        - the local maximal peaks' contour indices
%       contour     - the worm's contour
%       wormSegSize - the size (in contour points) of a worm segment.
%                     Note: The worm's contour is roughly divided into 50
%                     segments of musculature (i.e., hinges that represent
%                     degrees of freedom).
%
%   Output:
%       skeleton - the worm's skeleton
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
        
% Find and order the large bends (greater than +-20 degrees) on each side.
% Side1 always goes from head to tail in positive, index increments.
% Side2 always goes from head to tail in negative, index increments.
bendMinI = minI(minP < -20);
bendMaxI = maxI(maxP > 20);
if headI > tailI
    minSide1 = [bendMinI(bendMinI > headI) bendMinI(bendMinI < tailI)];
    maxSide1 = [bendMaxI(bendMaxI > headI) bendMaxI(bendMaxI < tailI)];
    minSide2 = fliplr(bendMinI(bendMinI > tailI & bendMinI < headI));
    maxSide2 = fliplr(bendMaxI(bendMaxI > tailI & bendMaxI < headI));
else
    minSide1 = bendMinI(bendMinI > headI & bendMinI < tailI);
    maxSide1 = bendMaxI(bendMaxI > headI & bendMaxI < tailI);
    minSide2 = fliplr([bendMinI(bendMinI > tailI) bendMinI(bendMinI < headI)]);
    maxSide2 = fliplr([bendMaxI(bendMaxI > tailI) bendMaxI(bendMaxI < headI)]);
end

% Find the length of each side.
cLength = size(contour, 1);
if headI > tailI
    size1 = headI - tailI + 1;
    size2 = cLength - headI + 1 + tailI;
else
    size1 = tailI - headI + 1;
    size2 = cLength - tailI + 1 + headI;
end

% Find the scale of side2 to side1.
scale1to2 = size2 / size1;

% Try to match large bends on either side.
mb1 = matchBends(minSide1, maxSide2, scale1to2, headI, cLength, wormSegSize);
mb2 = matchBends(maxSide1, minSide2, scale1to2, headI, cLength, wormSegSize);

% Skeletonize the bend segments by walking the midline between their
% opposing contour sides.
% Note: the maximal skeleton length occurs when one side of the contour
% contains all of the points (the head and tail are always shared by both
% sides).
skeleton = zeros(cLength, 2); % pre-allocate memory
prevBend(1:2) = headI;
sLength = 1;
i = 1;
j = 1;
while i <= size(mb1, 1) || j <= size(mb2, 1)
    
    % Which bend comes first?
    if j > size(mb2, 1) || (i <= size(mb1, 1) && mb1(i,1) < mb2(j,1))
        bend = mb1(i,:);
        i = i + 1;
    else
        bend = mb2(j,:);
        j = j + 1;
    end
    
    % Skeletonize the segment between the previous bend and this one.
    segment = round(skeletonize(prevBend(1), bend(1), 1, ...
        prevBend(2), bend(2), -1, contour));
    skeleton(sLength:(sLength + size(segment, 1) - 1),:) = segment;
    sLength = sLength + size(segment, 1);
    
    % Advance.
    prevBend = bend;
end

% Skeletonize the last segment between the previous bend and the tail.
segment = round(skeletonize(prevBend(1), tailI, 1, ...
    prevBend(2), tailI, -1, contour));
skeleton(sLength:(sLength + size(segment, 1) - 1),:) = segment;
sLength = sLength + size(segment, 1);

% Collapse any extra memory.
skeleton(sLength:end,:) = [];

% Clean up the skeleton
skeleton = cleanSkeleton(skeleton);
end

% Try to match bends on either side. Do this by choosing points on
% side 1, then searching for a match, within an interval, on side 2. 
function matchedBends = matchBends(side1, side2, scale, head, cLength, edgeSize)

% Convert the lower bounds for search intervals on side 1 to upper bounds
% for search intervals on side 2.
minPoints1 = side1 - edgeSize;
wrap = minPoints1 < 1; % correct any wrapped points
minPoints1(wrap) = minPoints1(wrap) + cLength;
maxPoints2 = matchPoints1to2(minPoints1, scale, head, cLength);

% Convert the upper bounds for search intervals on side 1 to lower bounds
% for search intervals on side 2.
maxPoints1 = side1 + edgeSize;
wrap = maxPoints1 < 1; % correct any wrapped points
maxPoints1(wrap) = maxPoints1(wrap) + cLength;
minPoints2 = matchPoints1to2(maxPoints1, scale, head, cLength);

% Try to match the bends on side 1 to those on side 2.
matchedBends = zeros(length(side1), 2); % pre-allocate memory
mbLength = 1;
for i = 1:length(side1)
    
    % Match the bend on side 1 to those within an interval on side 2.
    minI2 = minPoints2(i);
    maxI2 = maxPoints2(i);
    if minI2 <= maxI2
        side2Matches = find(side2 >= minI2 & side2 <= maxI2);
    else % the interval wraps
        side2Matches = find(side2 >= minI2 | side2 <= maxI2);
    end
    
    % We found matching bends on side 2.
    if ~isempty(side2Matches)
        
        % Match the bend on side 1 to the earliest choice on side 2.
        matchedBends(mbLength,:) = [side1(i) side2(side2Matches(1))];
        mbLength = mbLength + 1;
        
        % Remove everything from side 2 up to, and including, the matching bend.
        side2(1:side2Matches(1)) = [];
    end
end

% Collapse any extra memory.
matchedBends(mbLength:end,:) = [];
end

% Match points on side 1 to their equivalent points on side 2.
function points = matchPoints1to2(points, scale, head, cLength)

% Find the distance of the points from the head, scale it for the opposite
% side, then find the equivalent point, at the scaled distance from the
% head, on the opposite side.
minPoints = points < head;
points(minPoints) = head - (points(minPoints) + cLength - head + 1) * scale + 1;
maxPoints = points >= head;
points(maxPoints) = head - (points(maxPoints) - head + 1) * scale + 1;

% Round the points off to be proper inidices.
points = round(points);

% Correct any wrapped points.
minPoints = points < 1;
points(minPoints) = points(minPoints) + cLength;
maxPoints = points > cLength;
points(maxPoints) = points(maxPoints) - cLength;
end
