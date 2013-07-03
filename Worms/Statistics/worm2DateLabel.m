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

label = wormInfo(1).experiment.environment.timestamp;
end
