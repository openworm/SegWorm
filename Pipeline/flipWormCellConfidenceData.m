function worm = flipWormCellConfidenceData(worm)
%FLIPWORMCELLCONFIDENCEDATA Flip the confidence values
%
%   WORM = FLIPWORMCELLCONFIDENCEDATA(WORM)
%
%   Input:
%       worm - the worm to flip confidence values
%
%   Output:
%       worm - the flipped worm
%
%   See also FLIPWORMCELLDATA, FLIPWORMHEAD, FLIPWORMVULVA, WORM2STRUCT,
%   SEGWORM
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Flip the orientation.

tmp = worm{8}{1}{2}{1};
worm{8}{1}{2}{1} = worm{8}{1}{2}{2};
worm{8}{1}{2}{2} = tmp;
end
