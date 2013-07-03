function label = worm2GenotypeLabel(wormInfo)
%WORM2GENOTYPELABEL Label the worm genotype.
%
%   LABEL = WORM2GENOTYPELABEL(WORMINFO)
%
%   Input:
%       wormInfo - the worm information
%
%   Output:
%       label - the worm label
%
% See also WORMSTATS2MATRIX

% label = [wormInfo(1).experiment.worm.strain ': ' ...
%     wormInfo(1).experiment.worm.genotype];
label = wormInfo(1).experiment.worm.genotype;
end
