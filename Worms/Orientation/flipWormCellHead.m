function worm = flipWormCellHead(worm)
%FLIPWORMHEAD Flip the head-to-tail orientation of the worm (organized in a
%cell array).
%
%Note: since the vulva is specified relative to the head, its location
%flips to preserve its orientation.
%
%   WORM = FLIPWORMCELLHEAD(WORM)
%
%   Input:
%       worm - the worm (organized in a cell array) to flip
%
%   Output:
%       worm - the flipped worm (organized in a cell array)
%
%   See also FLIPWORMCELLVULVA, FLIPWORMCELLDATA, CELL2WORM, WORM2CELL,
%   WORM2STRUCT, SEGWORM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Does the worm cell array have enough elements?
if size(worm, 1) ~= 8
    error('flipWormCellHead:BadWorm', ...
        'The worm cell array must have 6 elements');
end
if size(worm{8}, 1) ~= 2
    error('flipWormCellHead:BadOrientation', ...
        'The worm orientation cell array (worm{8}) must have 2 elements');
end
if size(worm{8}{1}, 1) ~= 2
    error('flipWormCellHead:BadOrientationHead', ...
        ['The worm orientation head cell array ' ...
         '(worm{8}{1}) must have 2 elements']);
end
if size(worm{8}{1}{2}, 1) ~= 2
    error('flipWormCellHead:BadOrientationHeadConfidence', ...
        ['The worm orientation head confidence cell array ' ...
         '(worm{8}{1}{2}) must have 2 elements']);
end
if size(worm{8}{2}, 1) ~= 2
    error('flipWormCellHead:BadOrientationVulva', ...
        ['The worm orientation vulva cell array ' ...
         '(worm{8}{2}) must have 2 elements']);
end

% Flip worm.orientation.head.isFlipped.
worm{8}{1}{1} = ~worm{8}{1}{1};

% Flip worm.orientation.head.confidence.head and
% worm.orientation.head.confidence.tail.
tmp = worm{8}{1}{2}{1};
worm{8}{1}{2}{1} = worm{8}{1}{2}{2};
worm{8}{1}{2}{2} = tmp;

% Flip worm.orientation.vulva.isClockwiseFromHead.
worm{8}{2}{1} = ~worm{8}{2}{1};
end
