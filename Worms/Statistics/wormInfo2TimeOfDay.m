function [isUsed wormX tickX nameX labelX] = wormInfo2TimeOfDay(info, filt)
%WORMINFO2TIMEOFDAY Convert worm information to the time the experiment was
%performed.
%
%   [ISUSED WORMX TICKX NAMEX LABELX] = WORMINFO2TIMEOFDAY(INFO, FILT)
%
%   Inputs:
%       info - the worm information
%       filt - the filtering criteria; a structure with any of the fields:
%              minFPS     = the minimum video frame rate (frames/seconds)
%              minTime    = the minimum video time (seconds)
%              maxTime    = the maximum video time (seconds)
%              minSegTime = the minimum time for segmented video (seconds)
%              minRatio   = the minimum ratio for segmented video frames
%              minDate    = the minimum date to use (DATENUM)
%              maxDate    = the maximum date to use (DATENUM)
%              years      = the years to use
%              months     = the months to use (1-12)
%              weeks      = the weeks to use (1-52)
%              days       = the days (of the week) to use (1-7)
%              hours      = the hours to use (1-24)
%              trackers   = the trackers to use (1-8)
%              ticks      = the number of ticks to use
%
%   Outputs:
%       isUsed - for each worm, are we using the data?
%       wormX  - the x-axis values
%       tickX  - the x-axis ticks
%       nameX  - the x-axis tick names
%       labelX - the x-axis tick labels
%
% See also PLOTWORMSTATS, FILTERWORMINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Filter the worms.
[isUsed data] = filterWormInfo(info, filt);

% Compute the x-axis values.
usedData = data(isUsed);
wormX(1,:) = datenum(2000, 1, 1, [usedData.hour], [usedData.minute], ...
    [usedData.second]);

% Compute the x-axis ticks.
tickX = sort(unique(wormX));
if ~isempty(filt) && isstruct(filt)
    if isfield(filt, 'ticks')
        if ~isempty(filt.ticks) && filt.ticks < length(tickX)
            tickX = linspace(tickX(1), tickX(end), filt.ticks);
        end
    end
end

% Compute the x-axis tick names.
nameX(1,:) = arrayfun(@(x) datestr(x, 'HH:MM PM'), tickX, ...
    'UniformOutput', false);

% Construct the x-axis label.
labelX = [];
end
