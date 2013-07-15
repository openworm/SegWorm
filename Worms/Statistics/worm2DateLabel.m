function label = worm2DateLabel(wormInfo)
%WORM2DATELABEL Label the worm date.
%
%   LABEL = WORM2DATELABEL(WORMINFO)
%
%   Input:
%       wormInfo - the worm information
%
%   Output:
%       label - the worm label
%
% See also WORMSTATS2MATRIX
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

label = wormInfo(1).experiment.environment.timestamp;
end
