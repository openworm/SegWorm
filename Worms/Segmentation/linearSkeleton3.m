function [skeleton cWidths] = ...
    linearSkeleton3(headI, tailI, minP, minI, contour, wormSegSize)
%LINEARSKELETON3 Skeletonize a linear (non-looped) worm. The worm is
%skeletonized by splitting its contour, from head to tail, into short
%segments. These short segments are bounded by matching pairs of minimal
%angles (< -20 degrees) and their nearest points on the opposite side of
%the worm's contour. We then walk along the opposing sides of these short
%segments and mark the midline as our skeleton. The final step is cleaning
%up this skeleton to remove overlapping points and interpolate missing ones.
%
%   LINEARSKELETON3(HEADI, TAILI, MINP, MINI, MAXP, MAXI, CONTOUR)
%
%   Inputs:
%       headI       - the head's contour index
%       tailI       - the tail's contour index
%       minP        - the local minimal peaks
%       minI        - the local minimal peaks' contour indices
%       contour     - the worm's contour
%       wormSegSize - the size (in contour points) of a worm segment.
%                     Note: The worm's contour is roughly divided into 50
%                     segments of musculature (i.e., hinges that represent
%                     degrees of freedom).
%
%   Output:
%       skeleton - the worm's skeleton
%       cWidths  - the worm contour's width at each skeleton point
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Is the segment size too long?
% Note: the head and tail are not part of the sides.
cLength = size(contour, 1);
size1 = abs(headI - tailI) - 1;
size2 = cLength - size1 - 2;
if min(size1, size2) < wormSegSize;
    error('linearSkeleton:SegSizeTooBig', ...
        ['The segment size for skeletonization, to compute opposing ' ...
        'points for bends, is too long. Please contact the programmer.']);
end
    
% Find the large minimal bends (less than -30 degrees).
bendI = minI(minP < -30);

% Compute the bounding indices for the contour's sides.
preHeadI = headI - 1;
if preHeadI < 1
    preHeadI = preHeadI + cLength;
end
postHeadI = headI + 1;
if postHeadI > cLength
    postHeadI = postHeadI - cLength;
end
preTailI = tailI - 1;
if preTailI < 1
    preTailI = preTailI + cLength;
end
postTailI = tailI + 1;
if postTailI > cLength
    postTailI = postTailI - cLength;
end

% Compute opposing points for the bends.
% Side1 always goes from head to tail in positive, index increments.
% Side2 always goes from head to tail in negative, index increments.
segI = zeros(length(bendI), 2);
if headI <= tailI
    
    % Side 1.
    side1 = bendI > headI & bendI < tailI;
    sSize1 = sum(side1);
    sSize2 = length(bendI) - sSize1;
    segI(1:sSize1,1) = bendI(side1);
    minBendI1 = segI(1:sSize1,1) - wormSegSize;
    minBendI1(minBendI1 <= headI) = postHeadI;
    maxBendI1 = segI(1:sSize1,1) + wormSegSize;
    maxBendI1(maxBendI1 >= tailI) = preTailI;
    
    % Side 2.
    % Note: the head and tail have already been excluded as their bends are
    % much greater than -30 degrees.
    side2 = ~side1;
    segI((sSize1 + 1):end,2) = bendI(side2);
    minBendI2 = segI((sSize1 + 1):end,2) + wormSegSize;
    wrap = minBendI2 > cLength;
    minBendI2(wrap) = minBendI2(wrap) - cLength;
    minBendI2(minBendI2 >= headI & minBendI2 <= tailI) = preHeadI;
    maxBendI2 = segI((sSize1 + 1):end,2) - wormSegSize;
    wrap = maxBendI2 < 1;
    maxBendI2(wrap) = maxBendI2(wrap) + cLength;
    maxBendI2(maxBendI2 >= headI & maxBendI2 <= tailI) = postTailI;
else
    
    % Side 2.
    side2 = bendI > tailI & bendI < headI;
    sSize2 = sum(side2);
    sSize1 = length(bendI) - sSize2;
    segI((sSize1 + 1):end,2) = bendI(side2);
    minBendI2 = segI((sSize1 + 1):end,2) + wormSegSize;
    minBendI2(minBendI2 >= headI) = preHeadI;
    maxBendI2 = segI((sSize1 + 1):end,2) - wormSegSize;
    maxBendI2(maxBendI2 <= tailI) = postTailI;
    
    % Side 1.
    % Note: the head and tail have already been excluded as their bends are
    % much greater than -30 degrees.
    side1 = ~side2;
    segI(1:sSize1,1) = bendI(side1);
    minBendI1 = segI(1:sSize1,1) - wormSegSize;
    wrap = segI(1:sSize1,1) < 1;
    minBendI1(wrap) = minBendI1(wrap) + cLength;
    minBendI1(minBendI1 >= tailI & minBendI1 <= headI) = postHeadI;
    maxBendI1 = segI(1:sSize1,1) + wormSegSize;
    wrap = maxBendI1 > cLength;
    maxBendI1(wrap) = maxBendI1(wrap) - cLength;
    maxBendI1(maxBendI1 >= tailI & maxBendI1 <= headI) = preTailI;
end

% Find the opposing points for bends on side 1.
minOppI1 = circOpposingPoints(maxBendI1, headI, tailI, cLength);
maxOppI1 = circOpposingPoints(minBendI1, headI, tailI, cLength);
for i = 1:sSize1
    segI(i,2) = circNearestPoint(contour(segI(i,1),:), ...
        minOppI1(i), maxOppI1(i), contour);
end

% Find the opposing points for bends on side 2.
minOppI2 = circOpposingPoints(maxBendI2, headI, tailI, cLength);
maxOppI2 = circOpposingPoints(minBendI2, headI, tailI, cLength);
for i = (sSize1 + 1):size(segI, 1)
    j = i - sSize1;
    segI(i,1) = circNearestPoint(contour(segI(i,2),:), ...
        maxOppI2(j), minOppI2(j), contour);
end

% Order the points from head to tail.
% segI(:,1) always goes from head to tail in positive, index increments.
% segI(:,2) always goes from head to tail in negative, index increments.
segI = sortrows(segI);

% Skeletonize the segments and measure their widths by walking the midline
% between their opposing contour sides.
% Note: the maximal skeleton length occurs when one side of the contour
% contains all of the points (the head and tail are always shared by both
% sides).
skeleton = zeros(cLength, 2); % pre-allocate memory
cWidths = zeros(cLength, 1); % pre-allocate memory
prevSegI(1:2) = headI;
sLength = 1;
for i = 1:size(segI, 1)
    
    % Skeletonize the segment.
    [segment sWidths] = skeletonize(prevSegI(1), segI(i,1), 1, ...
        prevSegI(2), segI(i,2), -1, contour, contour, false);
    skeleton(sLength:(sLength + size(segment, 1) - 1),:) = segment;
    cWidths(sLength:(sLength + size(segment, 1) - 1),:) = sWidths;
    sLength = sLength + size(segment, 1);
    
    % Advance.
    prevSegI = segI(i,:);
end

% Skeletonize the last segment.
[segment sWidths] = skeletonize(prevSegI(1), tailI, 1, ...
    prevSegI(2), tailI, -1, contour, contour, false);
skeleton(sLength:(sLength + size(segment, 1) - 1),:) = segment;
cWidths(sLength:(sLength + size(segment, 1) - 1),:) = sWidths;
sLength = sLength + size(segment, 1);

% Collapse any extra memory.
skeleton(sLength:end,:) = [];
cWidths(sLength:end,:) = [];

% Clean up the rough skeleton.
skeleton = round(skeleton);
[skeleton cWidths] = cleanSkeleton(skeleton, cWidths, wormSegSize);

% Smooth the skeleton.
% halfWin = round(wormSegSize / 2);
% gWin = gausswin(2 * halfWin + 1);
% gWin = gWin / sum(gWin);
% preSkeleton(1:halfWin,1) = skeleton(1,1);
% preSkeleton(1:halfWin,2) = skeleton(1,2);
% postSkeleton(1:halfWin,1) = skeleton(end,1);
% postSkeleton(1:halfWin,2) = skeleton(end,2);
% skeleton(:,1) = ...
%     round(conv([preSkeleton(:,1); skeleton(:,1); postSkeleton(:,1)], gWin, 'valid'));
% skeleton(:,2) = ...
%     round(conv([preSkeleton(:,2); skeleton(:,2); postSkeleton(:,2)], gWin, 'valid'));
% 
% % Clean up the smoothed skeleton.
% skeleton = cleanSkeleton(skeleton);
end
