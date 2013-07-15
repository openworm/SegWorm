function [isUsed data] = filterWormInfo(info, filt)
%FILTERWORMINFO Filter worm information to meet specific criteria.
%
%   [ISUSED DATA] = FILTERWORMINFO(INFO, FILTER)
%
%   Inputs:
%       info - the worm information
%       filt - the filtering criteria; a structure with any of the fields:
%
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
%              days       = the days (of the week) to use (1-7, Mon-Sun)
%              hours      = the hours to use (0-23)
%              trackers   = the trackers to use (1-8)
%
%   Outputs:
%       isUsed - for each worm, did it meet the criteria?
%       data   - the worm data; a structure with any of the fields:
%
%                fps         = the video frame rate (frames/seconds)
%                videoTime   = the video time (seconds)
%                videoFrames = the total number of video frames
%                segFrames   = the number of segmented video frames
%                date        = the experiment date (see DATENUM)
%                year        = the experiment year
%                month       = the experiment month (1-12)
%                week        = the experiment week (1-52)
%                weekday     = the experiment weekday (1-7 = Mon-Sat)
%                day         = the experiment day (1-31)
%                hour        = the experiment hour (1-24)
%                minute      = the experiment minute (1-60)
%                second      = the experiment second (1-60)
%                tracker     = the tracker number (1-8)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Use all the worms.
isUsed = true(length(info), 1);

% Determine the filtering criteria.
minFPS = NaN;
minTime = NaN;
maxTime = NaN;
minSegTime = NaN;
minRatio = NaN;
minDate = NaN;
maxDate = NaN;
useHours = [];
useDays = [];
useWeeks = [];
useMonths = [];
useYears = [];
useTrackers = [];
if ~isempty(filt) && isstruct(filt)
    
    % Determine the minimum video frame rate.
    if isfield(filt, 'minFPS')
        minFPS = filt.minFPS;
    end
    
    % Determine the minimum video time.
    if isfield(filt, 'minTime')
        minTime = filt.minTime;
    end
    
    % Determine the maximum video time.
    if isfield(filt, 'maxTime')
        maxTime = filt.maxTime;
    end
    
    % Determine the minimum time for segmented video.
    if isfield(filt, 'minSegTime')
        minSegTime = filt.minSegTime;
    end
    
    % Determine the minimum ratio for segmented video frames.
    if isfield(filt, 'minRatio')
        minRatio = filt.minRatio;
    end
    
    % Determine the minimum date to use.
    if isfield(filt, 'minDate')
        minDate = filt.minDate;
    end
    
    % Determine the maximum date to use.
    if isfield(filt, 'maxDate')
        maxDate = filt.maxDate;
    end
    
    % Determine the years to use.
    if isfield(filt, 'years')
        useMonths = filt.months;
    end
    
    % Determine the months to use.
    if isfield(filt, 'months')
        useMonths = filt.months;
    end
    
    % Determine the weeks to use.
    if isfield(filt, 'weeks')
        useWeeks = filt.weeks;
    end
    
    % Determine the days to use.
    if isfield(filt, 'days')
        useDays = filt.days;
    end
    
    % Determine the hours to use.
    if isfield(filt, 'hours')
        useHours = filt.hours;
    end
    
    % Determine the trackers to use.
    if isfield(filt, 'trackers')
        useTrackers = filt.trackers;
    end
end

% Don't use low-resolution videos.
fps = arrayfun(@(x) x.video.resolution.fps, info);
if ~isnan(minFPS)
    isUsed(fps < minFPS) = false;
end

% Don't use videos that are too short or too long.
times = arrayfun(@(x) x.video.length.time, info);
if ~(isnan(minTime) && isnan(maxTime))
    isUsed(times < minTime) = false;
    isUsed(times > maxTime) = false;
end

% Don't use videos with insufficient frames segmented.
frames = arrayfun(@(x) x.video.length.frames, info);
segFrames = arrayfun(@(x) sum(x.video.annotations.frames == 1), info);
if ~(isnan(minSegTime) && isnan(minRatio))
    isUsed((segFrames .* fps) < minSegTime) = false;
    isUsed((segFrames ./ frames) < minRatio) = false;
end

% Don't use videos outside our date range.
dates = arrayfun(@(x) ...
    datenumEmpty2Zero(x.experiment.environment.timestamp), info);
if ~(isnan(minDate) && isnan(maxDate))
    isUsed(dates < minDate) = false;
    isUsed(dates > maxDate) = false;
end

% Only use videos from the requested years.
[years, months, days, hours, minutes, seconds] = datevec(dates);
if ~isempty(useYears)
    unusedYears = setdiff(unique(years), useYears);
    unusedWorms = arrayfun(@(x) any(x == unusedYears), years);
    isUsed(unusedWorms) = false;
end

% Only use videos from the requested months.
if ~isempty(useMonths)
    unusedMonths = setdiff(unique(months), useMonths);
    unusedWorms = arrayfun(@(x) any(x == unusedMonths), months);
    isUsed(unusedWorms) = false;
end

% Compute the experiment days and weeks.
dayStrs = {
    'Mon'
    'Tue'
    'Wed'
    'Thu'
    'Fri'
    'Sat'
    'Sun'};
[minDate minDateI] = min(dates);
minDayStr = datestr(minDate, 'ddd');
dayI = 1;
while dayI <= size(dayStrs,1) && ~strcmp(minDayStr, dayStrs{dayI})
    dayI = dayI + 1;
end
shortDates = datenum(years, months, days);
diffDates =  shortDates - shortDates(minDateI);
diffDays = diffDates + dayI - 1;
weekdays = mod(diffDays, 7) + 1;
diffWeeks = shortDates - datenum(years(minDateI), 0, 0) + dayI - 1;
weeks = mod(floor(diffWeeks / 7), 52) + 1;

% Only use videos from the requested weeks.
if ~isempty(useWeeks)
    unusedWeeks = setdiff(unique(weeks), useWeeks);
    unusedWorms = arrayfun(@(x) any(x == unusedWeeks), weeks);
    isUsed(unusedWorms) = false;
end

% Only use videos from the requested weekdays.
if ~isempty(useDays)
    unusedDays = setdiff(unique(weekdays), useDays);
    unusedWorms = arrayfun(@(x) any(x == unusedDays), weekdays);
    isUsed(unusedWorms) = false;
end

% Only use videos from the requested hours.
if ~isempty(useHours)
    unusedHours = setdiff(unique(hours), useHours);
    unusedWorms = arrayfun(@(x) any(x == unusedHours), hours);
    isUsed(unusedWorms) = false;
end

% Only use videos from the requested trackers.
trackers = arrayfun(@(x) ...
    uint8(str2double(x.experiment.environment.tracker)), info);
if ~isempty(useTrackers)
    unusedTrackers = setdiff(unique(trackers), useTrackers);
    unusedWorms = arrayfun(@(x) any(x == unusedTrackers), trackers);
    isUsed(unusedWorms) = false;
end

% Organize the data.
data(length(info),1).fps = [];
data(length(info),1).videoTime = [];
data(length(info),1).videoFrames = [];
data(length(info),1).videoSegFrames = [];
data(length(info),1).date = [];
data(length(info),1).year = [];
data(length(info),1).month = [];
data(length(info),1).week = [];
data(length(info),1).day = [];
data(length(info),1).weekday = [];
data(length(info),1).hour = [];
data(length(info),1).minute = [];
data(length(info),1).second = [];
data(length(info),1).tracker = [];
for i = 1:length(data)
    data(i).fps = fps(i);
    data(i).videoTime = times(i);
    data(i).videoFrames = frames(i);
    data(i).videoSegFrames = segFrames(i);
    data(i).date = dates(i);
    data(i).year = years(i);
    data(i).month = months(i);
    data(i).week = weeks(i);
    data(i).day = days(i);
    data(i).weekday = weekdays(i);
    data(i).hour = hours(i);
    data(i).minute = minutes(i);
    data(i).second = seconds(i);
    data(i).tracker = trackers(i);
end
end
