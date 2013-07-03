function label = worm2GeneLabel(wormInfo)
%WORM2GENELABEL Label the worm gene.
%
%   LABEL = WORM2GENELABEL(WORMINFO)
%
%   Input:
%       wormInfo - the worm information
%
%   Output:
%       label - the worm label
%
% See also WORMSTATS2MATRIX

label = wormInfo(1).experiment.worm.gene;
end
