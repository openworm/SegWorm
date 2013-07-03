function filter = permissiveFeatureFilter()
%PERMISSIVEFEATUREFILTER Get a permissive filter for worm features:
% 250   < Length        < 2000
% 25    < Midbody Width < 200
% -1000 < Midbody Speed < 1000
%
%   FILTER = PERMISSIVEFEATUREFILTER()
%
%   Output:
%       filter - a permissive filter to identify usable worm experiments
%
% See also FILTERWORMHIST

% Construct a permissive filter for worm experiments.
filter = [];
filter.featuresI = [ ...
    1 ... % length
    3 ... % midbody width
    35]; % midbody speed
filter.minThrs = [ ...
    250 ... % length
    25 ... % midbody width
    -1000 ]; % midbody speed
filter.maxThrs = [ ...
    2000 ... % length
    200 ... % midbody width
    1000 ]; % midbody speed
end
