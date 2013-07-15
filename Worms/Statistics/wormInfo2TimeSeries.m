function [isUsed wormX tickX nameX labelX] = wormInfo2TimeSeries(info, filt)
%WORMINFO2TIMESERIES Convert worm information to time series information.
%
%   [ISUSED WORMX TICKX LABELX] = WORMINFO2TIMESERIES(INFO, FILT)
%
%   Inputs:
%       info - the worm information
%       filt - the filtering criteria; a structure with any of the fields:
%              unitScale  = the unit scale;
%                           the default is 60 seconds
%              unitName   = the unit name;
%                           the default is minutes
%              unitTick   = the unit tick spacing;
%                           the default is 1
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

% Determine the unit scale, label, and tick spacing.
scale = 60;
label = 'minutes';
tickX = [];
if ~isempty(filt) && isstruct(filt)
    
    % Determine the unit scale.
    if isfield(filt, 'unitScale')
        scale = filt.unitScale;
    end
    
    % Determine the unit label.
    if isfield(filt, 'unitLabel')
        label = filt.unitLabel;
    end
    
    % Determine the unit tick.
    if isfield(filt, 'unitTick')
        tickX = filt.unitTick;
    end
end

% Compute the x-axis time scale.
wormX(:,1) = arrayfun(@(x) 1 ./ ([x.fps] .* scale), data(isUsed));

% Construct the x-axis label.
nameX  = [];
labelX = ['Time (' label ')'];
end
