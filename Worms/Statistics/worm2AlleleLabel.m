function label = worm2AlleleLabel(wormInfo)
%WORM2ALLELELABEL Label the worm allele.
%
%   LABEL = WORM2ALLELELABEL(WORMINFO)
%
%   Input:
%       wormInfo - the worm information
%
%   Output:
%       label - the worm label
%
% See also WORMSTATS2MATRIX

label = wormInfo(1).experiment.worm.allele;
end
