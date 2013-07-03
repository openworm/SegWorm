function worm = flipWormVulva(worm)
%FLIPWORMVULVA Flip the vulval orientation of the worm.
%
%   WORM = FLIPWORMVULVA(WORM)
%
%   Input:
%       worm - the worm to flip
%
%   Output:
%       worm - the flipped worm
%
%   See also FLIPWORMCELLVULVA, FLIPWORMHEAD, FLIPWORMDATA, WORM2STRUCT,
%   SEGWORM

% Flip the worm's vulval side.
worm.orientation.vulva.isClockwiseFromHead = ...
    ~worm.orientation.vulva.isClockwiseFromHead;
tmp = worm.orientation.vulva.confidence.vulva;
worm.orientation.vulva.confidence.vulva = ...
    worm.orientation.vulva.confidence.nonVulva;
worm.orientation.vulva.confidence.nonVulva = tmp;
end

