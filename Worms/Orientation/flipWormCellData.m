function worm = flipWormCellData(worm)
%FLIPWORMCELLDATA Flip the orientation of the worm (organized in a cell
%   array)data (re-orient the entire worm data structure and every one of
%   its substructures).
%
%   WORM = FLIPWORMCELLDATA(WORM)
%
%   Input:
%       worm - the worm (organized in a cell array) to flip
%
%   Output:
%       worm - the flipped worm (organized in a cell array)
%
%   See also FLIPWORMDATA, FLIPWORMCELLHEAD, FLIPWORMCELLVULVA,  CELL2WORM,
%   WORM2CELL, WORM2STRUCT, SEGWORM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Does the worm cell array have enough elements?
if size(worm, 1) ~= 8
    error('flipWormCellData:BadWorm', ...
        'The worm cell array must have 6 elements');
end

% Does the contour cell array have enough elements?
if size(worm{2}, 1) ~= 8
    error('flipWormCellData:BadContour', ...
        'The worm contour cell array (worm{2}) must have 8 elements');
end

% Flip worm.contour.headI and worm.contour.tailI.
tmp = worm{2}{6};
worm{2}{6} = worm{2}{7};
worm{2}{7} = tmp;

% Does the skeleton cell array have enough elements?
if size(worm{3}, 1) ~= 9
    error('flipWormCellData:BadSkeleton', ...
        'The worm skeleton cell array (worm{3}) must have 9 elements');
end

% Flip worm.skeleton.pixels.
worm{3}{1} = flipud(worm{3}{1});

% Flip worm.skeleton.touchI.
worm{3}{2} = fliplr(length(worm{3}{6}) - worm{3}{2} + 1);

% Flip worm.skeleton.inI.
worm{3}{3} = fliplr(length(worm{3}{6}) - worm{3}{3} + 1);

% Flip worm.skeleton.outI.
worm{3}{4} = fliplr(length(worm{3}{6}) - worm{3}{4} + 1);

% Flip worm.skeleton.inOutI.
worm{3}{5} = fliplr(length(worm{3}{6}) - worm{3}{5} + 1);

% Flip worm.skeleton.angles.
worm{3}{6} = -flipud(worm{3}{6});

% Flip worm.skeleton.chainCodeLengths.
worm{3}{8} = flipud(worm{3}{7} - worm{3}{8});

% Flip worm.skeleton.widths.
worm{3}{9} = flipud(worm{3}{9});

% Does the head cell array have enough elements?
if size(worm{4}, 1) ~= 5
    error('flipWormCellData:BadHead', ...
        'The worm head cell array (worm{4}) must have 4 elements');
end
if size(worm{4}{1}, 1) ~= 2
    error('flipWormCellData:BadHeadBounds', ...
        'The worm head bounds cell array (worm{4}{1}) must have 2 elements');
end
if size(worm{4}{1}{1}, 1) ~= 2
    error('flipWormCellData:BadHeadContour', ...
        'The worm head contour cell array (worm{4}{1}{1}) must have 2 elements');
end

% Flip worm.head.bounds.contour.left and worm.head.bounds.contour.right.
tmp = worm{4}{1}{1}{1};
worm{4}{1}{1}{1} = worm{4}{1}{1}{2};
worm{4}{1}{1}{2} = tmp;

% Flip worm.head.bounds.skeleton.
worm{4}{1}{2} = flipud(length(worm{3}{6}) - worm{4}{1}{2} + 1);

% Does the tail cell array have enough elements?
if size(worm{5}, 1) ~= 5
    error('flipWormCellData:BadTail', ...
        'The worm tail cell array (worm{5}) must have 4 elements');
end
if size(worm{5}{1}, 1) ~= 2
    error('flipWormCellData:BadTailBounds', ...
        'The worm tail bounds cell array (worm{5}{1}) must have 2 elements');
end
if size(worm{5}{1}{1}, 1) ~= 2
    error('flipWormCellData:BadTailContour', ...
        'The worm tail contour cell array (worm{5}{1}{1}) must have 2 elements');
end

% Flip worm.tail.bounds.contour.left and worm.tail.bounds.contour.right.
tmp = worm{5}{1}{1}{1};
worm{5}{1}{1}{1} = worm{5}{1}{1}{2};
worm{5}{1}{1}{2} = tmp;

% Flip worm.tail.bounds.skeleton.
worm{5}{1}{2} = flipud(length(worm{3}{6}) - worm{5}{1}{2} + 1);

% Flip worm.head and worm.tail.
tmp = worm{4};
worm{4} = worm{5};
worm{5} = tmp;

% Does the left-side cell array have enough elements?
if size(worm{6}, 1) ~= 5
    error('flipWormCellData:BadLeftSide', ...
        'The worm left-side cell array (worm{6}) must have 4 elements');
end
if size(worm{6}{1}, 1) ~= 2
    error('flipWormCellData:BadLeftSideBounds', ...
        'The worm left-side bounds cell array (worm{6}{1}) must have 2 elements');
end

% Flip worm.left.bounds.skeleton.
worm{6}{1}{2} = flipud(length(worm{3}{6}) - worm{6}{1}{2} + 1);

% Does the right-side cell array have enough elements?
if size(worm{7}, 1) ~= 5
    error('flipWormCellData:BadRightSide', ...
        'The worm right-side cell array (worm{7}) must have 4 elements');
end
if size(worm{7}{1}, 1) ~= 2
    error('flipWormCellData:BadRightSideBounds', ...
        'The worm right-side bounds cell array (worm{7}{1}) must have 2 elements');
end

% Flip worm.right.bounds.skeleton.
worm{7}{1}{2} = flipud(length(worm{3}{6}) - worm{7}{1}{2} + 1);

% Flip worm.left and worm.right.
tmp = worm{6};
worm{6} = worm{7};
worm{7} = tmp;

% Does the orientation cell array have enough elements?
if size(worm{8}, 1) ~= 2
    error('flipWormCellData:BadOrientation', ...
        'The worm orientation cell array (worm{8}) must have 2 elements');
end
if size(worm{8}{1}, 1) ~= 2
    error('flipWormCellData:BadOrientationHead', ...
        ['The worm orientation head cell array ' ...
         '(worm{8}{1}) must have 2 elements']);
end
if size(worm{8}{1}{2}, 1) ~= 2
    error('flipWormCellData:BadOrientationHeadConfidence', ...
        ['The worm orientation head confidence cell array ' ...
         '(worm{8}{1}{2}) must have 2 elements']);
end
if size(worm{8}{2}, 1) ~= 2
    error('flipWormCellData:BadOrientationVulva', ...
        ['The worm orientation vulva cell array ' ...
         '(worm{8}{2}) must have 2 elements']);
end

% Flip worm.orientation.head.isFlipped.
worm{8}{1}{1} = ~worm{8}{1}{1};

% Flip worm.orientation.vulva.isClockwiseFromHead.
worm{8}{2}{1} = ~worm{8}{2}{1};

% Flip worm.orientation.vulva.confidence.vulva and
% worm.orientation.vulva.confidence.nonVulva.
tmp = worm{8}{2}{2}{1};
worm{8}{2}{2}{1} = worm{8}{2}{2}{2};
worm{8}{2}{2}{2} = tmp;
end
