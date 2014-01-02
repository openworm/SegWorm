function worm = flipWormConfidenceData(worm)
%FLIPWORMDATA Flip the confidence values
%
%   WORM = FLIPWORMDATA(WORM)
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

tmp = worm.orientation.head.confidence.head;
worm.orientation.head.confidence.head = worm.orientation.head.confidence.tail;
worm.orientation.head.confidence.tail = tmp;
end
