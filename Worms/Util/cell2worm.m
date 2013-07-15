function worm = cell2worm(worm)
%CELL2WORM Convert a cell array to a worm struct.
%
%   WORM = CELL2WORM(WORM)
%
%   Input:
%       worm - the worm information organized in a cell array
%
%   Output:
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
%   See also WORM2CELL, WORM2STRUCT, SEGWORM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Does the worm cell array have enough elements?
if size(worm, 1) ~= 8
    error('cell2worm:BadWorm', ...
        'The worm cell array must have 6 elements');
end

% Convert the video information.
if size(worm{1}, 1) ~= 1
    error('cell2worm:BadVideoInfo', ...
        'The worm video information cell array (worm{1}) must have 1 element');
end
video = cell2struct(worm{1}, 'frame', 1);

% Convert the contour.
if size(worm{2}, 1) ~= 8
    error('cell2worm:BadContour', ...
        'The worm contour cell array (worm{2}) must have 8 elements');
end
contour = cell2struct(worm{2}, ...
    {'pixels', ...
     'touchI', ...
     'inI', ...
     'outI', ...
     'angles', ...
     'headI', ...
     'tailI', ...
     'chainCodeLengths'}, 1);

% Convert the skeleton.
if size(worm{3}, 1) ~= 9
    error('cell2worm:BadSkeleton', ...
        'The worm skeleton cell array (worm{3}) must have 9 elements');
end
skeleton = cell2struct(worm{3}, ...
    {'pixels', ...
     'touchI', ...
     'inI', ...
     'outI', ...
     'inOutI', ...
     'angles', ...
     'length', ...
     'chainCodeLengths', ...
     'widths'}, 1);

% Convert the head.
if size(worm{4}, 1) ~= 5
    error('cell2worm:BadHead', ...
        'The worm head cell array (worm{4}) must have 4 elements');
end
if size(worm{4}{1}, 1) ~= 2
    error('cell2worm:BadHeadBounds', ...
        'The worm head bounds cell array (worm{4}{1}) must have 2 elements');
end
if size(worm{4}{1}{1}, 1) ~= 2
    error('cell2worm:BadHeadContour', ...
        'The worm head contour cell array (worm{4}{1}{1}) must have 2 elements');
end
hContour = cell2struct(worm{4}{1}{1}, {'left', 'right'}, 1);
hBounds = struct('contour', hContour, 'skeleton', worm{4}{1}{2});
head = struct('bounds', hBounds, 'pixels', worm{4}{2}, ...
    'area', worm{4}{3}, 'cdf', worm{4}{4}, 'stdev', worm{4}{5});

% Convert the tail.
if size(worm{5}, 1) ~= 5
    error('cell2worm:BadTail', ...
        'The worm tail cell array (worm{5}) must have 4 elements');
end
if size(worm{5}{1}, 1) ~= 2
    error('cell2worm:BadTailBounds', ...
        'The worm tail bounds cell array (worm{5}{1}) must have 2 elements');
end
if size(worm{5}{1}{1}, 1) ~= 2
    error('cell2worm:BadTailContour', ...
        'The worm tail contour cell array (worm{5}{1}{1}) must have 2 elements');
end
tContour = cell2struct(worm{5}{1}{1}, {'left', 'right'}, 1);
tBounds = struct('contour', tContour, 'skeleton', worm{5}{1}{2});
tail = struct('bounds', tBounds, 'pixels', worm{5}{2}, ...
    'area', worm{5}{3}, 'cdf', worm{5}{4}, 'stdev', worm{5}{5});

% Convert the worm's left side.
if size(worm{6}, 1) ~= 5
    error('cell2worm:BadLeftSide', ...
        'The worm left-side cell array (worm{6}) must have 4 elements');
end
if size(worm{6}{1}, 1) ~= 2
    error('cell2worm:BadLeftSideBounds', ...
        'The worm left-side bounds cell array (worm{6}{1}) must have 2 elements');
end
lBounds = cell2struct(worm{6}{1}, {'contour', 'skeleton'}, 1);
left = struct('bounds', lBounds, 'pixels', worm{6}{2}, ...
    'area', worm{6}{3}, 'cdf', worm{6}{4}, 'stdev', worm{6}{5});

% Convert the worm's right side.
if size(worm{7}, 1) ~= 5
    error('cell2worm:BadRightSide', ...
        'The worm right-side cell array (worm{7}) must have 4 elements');
end
if size(worm{7}{1}, 1) ~= 2
    error('cell2worm:BadRightSideBounds', ...
        'The worm right-side bounds cell array (worm{7}{1}) must have 2 elements');
end
rBounds = cell2struct(worm{7}{1}, {'contour', 'skeleton'}, 1);
right = struct('bounds', rBounds, 'pixels', worm{7}{2}, ...
    'area', worm{7}{3}, 'cdf', worm{7}{4}, 'stdev', worm{7}{5});

% Convert the worm's orientation.
if size(worm{8}, 1) ~= 2
    error('cell2worm:BadOrientation', ...
        'The worm orientation cell array (worm{8}) must have 2 elements');
end
if size(worm{8}{1}, 1) ~= 2
    error('cell2worm:BadOrientationHead', ...
        ['The worm orientation head cell array ' ...
         '(worm{8}{1}) must have 2 elements']);
end
if size(worm{8}{1}{2}, 1) ~= 2
    error('cell2worm:BadOrientationHeadConfidence', ...
        ['The worm orientation head confidence cell array ' ...
         '(worm{8}{1}{2}) must have 2 elements']);
end
if size(worm{8}{2}, 1) ~= 2
    error('cell2worm:BadOrientationVulva', ...
        ['The worm orientation vulva cell array ' ...
         '(worm{8}{2}) must have 2 elements']);
end
if size(worm{8}{2}{2}, 1) ~= 2
    error('cell2worm:BadOrientationVulvaConfidence', ...
        ['The worm orientation vulva confidence cell array ' ...
         '(worm{8}{2}{2}) must have 2 elements']);
end
hConfidence = cell2struct(worm{8}{1}{2}, {'head', 'tail'}, 1);
hOrientation = struct('isFlipped', worm{8}{1}{1}, ...
    'confidence', hConfidence);
vConfidence = cell2struct(worm{8}{2}{2}, {'vulva', 'nonVulva'}, 1);
vOrientation = struct('isClockwiseFromHead', worm{8}{2}{1}, ...
    'confidence', vConfidence);
orientation = struct('head', hOrientation, 'vulva', vOrientation);

% Convert the worm.
worm = struct('video', video, 'contour', contour, 'skeleton', skeleton, ...
    'head', head, 'tail', tail, 'left', left, 'right', right, ...
    'orientation', orientation);
end

