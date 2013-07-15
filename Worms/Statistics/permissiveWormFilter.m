function filter = permissiveWormFilter()
%PERMISSIVEWORMFILTER Get a permissive filter for worm experiments (roughly
%15 minute-long videos with 20 or more frames/seconds, 1/5 or more of the
%frames segmented, and performed from Monday to Saturday 8am to 6pm).
%
%   FILTER = PERMISSIVEWORMFILTER()
%
%   Output:
%       filter - a permissive filter to identify usable worm experiments
%
% See also FILTERWORMINFO, STANDARDWORMFILTER
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Construct a permissive filter for worm experiments.
filter = [];
filter.minFPS = 20;    % >= 20 frames/seconds
filter.minTime = 840;  % >= 14 minutes
filter.maxTime = 960;  % <= 16 minutes
filter.minRatio = 1/5; % >= 1/5 of the video frames segmented
filter.days = 1:6;     % performed Monday to Saturday
filter.hours = 8:17;   % performed 8am to 6pm
end
