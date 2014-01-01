function worm = worm2cell(worm)
%WORM2CELL Convert a worm struct to a cell array.
%
%   WORM = WORM2CELL(WORM)
%
%   Input:
%       worm - the worm information organized in a structure
%              This structure contains 8 sub-structures,
%              6 sub-sub-structures, and 4 sub-sub-sub-structures:
%
%              * Video *
%              video = {frame}
%
%              * Contour *
%              contour = {pixels, touchI, inI, outI, angles, headI, tailI,
%                         chainCodeLengths}
%
%              * Skeleton *
%              skeleton = {pixels, touchI, inI, outI, inOutI, angles,
%                          length, chainCodeLengths, widths}
%
%              Note: positive skeleton angles bulge towards the side
%              clockwise from the worm's head (unless the worm is flipped).
%
%              * Head *
%              head = {bounds, pixels, area,
%                      cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              head.bounds{contour.left (indices for [start end]),
%                          contour.right (indices for [start end]),
%                          skeleton indices for [start end]}
%
%              * Tail *
%              tail = {bounds, pixels, area,
%                      cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              tail.bounds{contour.left (indices for [start end]),
%                          contour.right (indices for [start end]),
%                          skeleton indices for [start end]}
%
%              * Left Side (Counter Clockwise from the Head) *
%              left = {bounds, pixels, area,
%                      cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              left.bounds{contour (indices for [start end]),
%                          skeleton (indices for [start end])}
%
%              * Right Side (Clockwise from the Head) *
%              right = {bounds, pixels, area,
%                       cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              right.bounds{contour (indices for [start end]),
%                           skeleton (indices for [start end])}
%
%              * Orientation *
%              orientation = {head, vulva}
%              orientation.head = {isFlipped,
%                                  confidence.head, confidence.tail}
%              orientation.vulva = {isClockwiseFromHead,
%                                  confidence.vulva, confidence.nonVulva}
%
%   Output:
%       worm - the worm information organized in a cell array
%
%   See also CELL2WORM, WORM2STRUCT, SEGWORM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Convert the video information.
worm.video = struct2cell(worm.video);

% Convert the contour.
worm.contour = struct2cell(worm.contour);

% Convert the skeleton.
worm.skeleton = struct2cell(worm.skeleton);

% Convert the head.
worm.head.bounds.contour = struct2cell(worm.head.bounds.contour);
worm.head.bounds = struct2cell(worm.head.bounds);
worm.head = struct2cell(worm.head);

% Convert the tail.
worm.tail.bounds.contour = struct2cell(worm.tail.bounds.contour);
worm.tail.bounds = struct2cell(worm.tail.bounds);
worm.tail = struct2cell(worm.tail);

% Convert the worm's left side.
worm.left.bounds = struct2cell(worm.left.bounds);
worm.left = struct2cell(worm.left);

% Convert the worm's right side.
worm.right.bounds = struct2cell(worm.right.bounds);
worm.right = struct2cell(worm.right);

% Convert the worm's orientation.
worm.orientation.head.confidence = ...
    struct2cell(worm.orientation.head.confidence);
worm.orientation.head = struct2cell(worm.orientation.head);
worm.orientation.vulva.confidence = ...
    struct2cell(worm.orientation.vulva.confidence);
worm.orientation.vulva = struct2cell(worm.orientation.vulva);
worm.orientation = struct2cell(worm.orientation);

% Convert the worm.
worm = struct2cell(worm);
end

