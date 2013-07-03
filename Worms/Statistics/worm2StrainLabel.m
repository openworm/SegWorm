function label = worm2StrainLabel(wormInfo)
%WORM2STRAINLABEL Label the worm strain.
%
%   LABEL = WORM2STRAINLABEL(WORMINFO)
%
%   Input:
%       wormInfo - the worm information
%
%   Output:
%       label - the worm label
%
% See also WORMSTATS2MATRIX

label = wormInfo(1).experiment.worm.strain;
end
