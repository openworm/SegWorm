function filter = standardWormFilter()
%STANDARDWORMFILTER Get a filter for standard worm experiments (roughly 15
%minute-long videos with 20 or more frames/seconds, 2/3  or more of the
%frames segmented, and performed from Monday to Friday 8am to 5pm).
%
%   FILTER = STANDARDWORMFILTER()
%
%   Output:
%       filter - a filter to identify standard worm experiments
%
% See also FILTERWORMINFO, PERMISSIVEWORMFILTER

% Construct a filter for standard worm experiments.
filter = [];
filter.minFPS = 20;    % >= 20 frames/seconds
filter.minTime = 840;  % >= 14 minutes
filter.maxTime = 960;  % <= 16 minutes
filter.minRatio = 2/3; % >= 2/3 of the video frames segmented
filter.days = 1:5;     % performed Monday to Friday
filter.hours = 8:16;   % performed 8am to 5pm
end
