function worm = flipWormCellVulva(worm)
%FLIPWORMCELLVULVA Flip the vulval orientation of the worm (organized in a
%   cell array).
%
%   WORM = FLIPWORMCELLVULVA(WORM)
%
%   Input:
%       worm - the worm (organized in a cell array) to flip
%
%   Output:
%       worm - the flipped worm (organized in a cell array)
%
%   See also FLIPWORMCELLHEAD, FLIPWORMCELLDATA, CELL2WORM, WORM2CELL,
%   WORM2STRUCT, SEGWORM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Does the worm cell array have enough elements?
if size(worm, 1) ~= 8
    error('flipWormCellVulva:BadWorm', ...
        'The worm cell array must have 6 elements');
end
if size(worm{8}, 1) ~= 2
    error('flipWormCellVulva:BadOrientation', ...
        'The worm orientation cell array (worm{8}) must have 2 elements');
end
if size(worm{8}{2}, 1) ~= 2
    error('flipWormCellVulva:BadOrientationVulva', ...
        ['The worm orientation vulva cell array ' ...
         '(worm{8}{2}) must have 2 elements']);
end
if size(worm{8}{2}{2}, 1) ~= 2
    error('flipWormCellVulva:BadOrientationVulvaConfidence', ...
        ['The worm orientation vulva confidence cell array ' ...
         '(worm{8}{2}{2}) must have 2 elements']);
end

% Flip worm.orientation.vulva.isClockwiseFromHead.
worm{8}{2}{1} = ~worm{8}{2}{1};

% Flip worm.orientation.vulva.confidence.vulva and
% worm.orientation.vulva.confidence.nonVulva.
tmp = worm{8}{2}{2}{1};
worm{8}{2}{2}{1} = worm{8}{2}{2}{2};
worm{8}{2}{2}{2} = tmp;
end
