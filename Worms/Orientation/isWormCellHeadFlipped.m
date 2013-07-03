function isFlipped = isWormCellHeadFlipped(worm)
%ISWORMCELLHEADFLIPPED Summary of this function goes here
%
%   ISFLIPPED = ISWORMCELLHEADFLIPPED(WORM)
%
%   Input:
%       worm - the worm information organized in a cell array
%
%   Output:
%       isFlipped - are the worm's head and tail flipped?

isFlipped = worm{8}{1}{1};
end
