function worm = flipWormData(worm)
%FLIPWORMDATA Flip the orientation of the worm data (re-orient the entire
%   worm data structure and every one of its substructures).
%
%   WORM = FLIPWORMDATA(WORM)
%
%   Input:
%       worm - the worm to flip
%
%   Output:
%       worm - the flipped worm
%
%   See also FLIPWORMCELLDATA, FLIPWORMHEAD, FLIPWORMVULVA, WORM2STRUCT,
%   SEGWORM

% Flip the contour.
tmp = worm.contour.headI;
worm.contour.headI = worm.contour.tailI;
worm.contour.tailI = tmp;

% Flip the skeleton.
worm.skeleton.pixels = flipud(worm.skeleton.pixels);
worm.skeleton.touchI = ...
    fliplr(length(worm.skeleton.angles) - worm.skeleton.touchI + 1);
worm.skeleton.inI = ...
    fliplr(length(worm.skeleton.angles) - worm.skeleton.inI + 1);
worm.skeleton.outI = ...
    fliplr(length(worm.skeleton.angles) - worm.skeleton.outI + 1);
worm.skeleton.inOutI = ...
    fliplr(length(worm.skeleton.angles) - worm.skeleton.inOutI + 1);
worm.skeleton.angles = -flipud(worm.skeleton.angles);
worm.skeleton.chainCodeLengths = ...
    flipud(worm.skeleton.length - worm.skeleton.chainCodeLengths);
worm.skeleton.widths = flipud(worm.skeleton.widths);

% Flip the head and tail.
tmp = worm.head;
worm.head = worm.tail;
worm.tail = tmp;
tmp = worm.head.bounds.contour.left;
worm.head.bounds.contour.left = worm.head.bounds.contour.right;
worm.head.bounds.contour.right = tmp;
worm.head.bounds.skeleton = ...
    flipud(length(worm.skeleton.angles) - worm.head.bounds.skeleton + 1);
tmp = worm.tail.bounds.contour.left;
worm.tail.bounds.contour.left = worm.tail.bounds.contour.right;
worm.tail.bounds.contour.right = tmp;
worm.tail.bounds.skeleton = ...
    flipud(length(worm.skeleton.angles) - worm.tail.bounds.skeleton + 1);

% Flip the left and right side.
tmp = worm.left;
worm.left = worm.right;
worm.right = tmp;
worm.left.bounds.skeleton = ...
    flipud(length(worm.skeleton.angles) - worm.left.bounds.skeleton + 1);
worm.right.bounds.skeleton = ...
    flipud(length(worm.skeleton.angles) - worm.right.bounds.skeleton + 1);

% Flip the orientation.
worm.orientation.head.isFlipped = ~worm.orientation.head.isFlipped;
worm.orientation.vulva.isClockwiseFromHead = ...
    ~worm.orientation.vulva.isClockwiseFromHead;
tmp = worm.orientation.vulva.confidence.vulva;
worm.orientation.vulva.confidence.vulva = ...
    worm.orientation.vulva.confidence.nonVulva;
worm.orientation.vulva.confidence.nonVulva = tmp;
end
