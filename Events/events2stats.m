function [eventStats summaryStats] = events2stats(frames, fps, data, ...
    name, interName)
%EVENTS2STATS Compute the event statistics.
%
%   [EVENTSTATS SUMMARYSTATS] = EVENTS2STATS(FRAMES, FPS, DATA)
%
%   Inputs:
%       frames    - the event frames (see findEvent)
%       fps       - the video's frames/second
%       data      - the data values
%       name      - the struct field name for the event's data sum;
%                   if empty, this value is neither computed nor included
%       interName - the struct field name for the data sum till the next
%                   event;
%                   if empty, this value is neither computed nor included
%
%   Outputs:
%       eventStats   - the event statistics; a structure array with fields:
%
%                      start       = the start frame
%                      end         = the end frame
%                      time        = the event time
%                      <name>      = the sum of the event data
%                      interTime   = the time till the next event
%                      inter<name> = the sum of the data till the next event
%
%       summaryStats - the summary statistics for the events;
%                      a structure with fields:
%
%                      frequency = the event frequency (excluding partial
%                                  events at the start and end)
%                      ratio     = a structure with fields:
%                      
%                                  time   = the ratio of time
%                                           (event time / total time)
%                                  <name> = the ratio of data
%                                           (event data / total data)
%
% See also FINDEVENT
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we computing/including the event's data sum.
isName = true;
if isempty(name)
    isName = false;
    name = 'tmpName';
end

% Are there any event frames?
eventStats = [];
if isempty(frames)
    
    % There are no events.
    frequency = 0;
    if isName
        ratios = struct('time', 0, name, 0);
    else
        ratios = struct('time', 0);
    end
    
    % Create the summary statistics.
    summaryStats = struct( ...
        'frequency', frequency, ...
        'ratio', ratios);
    return;
end

% Fix the data.
data = data(:);

% Are we computing/including the data sum till the next event?
isInterName = true;
if isempty(interName)
    isName = false;
    interName = 'tmpInterName';
end

% Organize the event information.
eventStats = struct( ...
    'start', [], ...
    'end', [], ...
    'time', [], ...
    name, [], ...
    'interTime', [], ...
    interName, []);
if ~isName
    eventStats = rmfield(eventStats, name);
end
if ~isInterName
    eventStats = rmfield(eventStats, interName);
end

% Compute the event information.
for i = 1:length(frames)

    % Compute the event information.
    eventTime = (frames(i).end - frames(i).start + 1) / fps;
    eventSum = [];
    if isName
        eventSum = nansum(data((frames(i).start + 1):(frames(i).end + 1)));
    end
    
    % The last inter- time and sum are unknown.
    interTime = NaN;
    interSum = NaN;
    if i < length(frames)
        interTime = (frames(i + 1).start - frames(i).end - 1) / fps;
        if isInterName
            interSum = ...
                nansum(data((frames(i).end + 2):(frames(i + 1).start)));
        end
    end
    
    % Organize the event information.
    eventStats(i).start = frames(i).start;
    eventStats(i).end = frames(i).end;
    eventStats(i).time = eventTime;
    if isName
        eventStats(i).(name) = eventSum;
    end
    eventStats(i).interTime = interTime;
    if isInterName
        eventStats(i).(interName) = interSum;
    end
end

% Compute the number of events, excluding the partially recorded ones.
numEvents = length(frames);
if numEvents > 1 && frames(1).start == 0
    numEvents = numEvents - 1;
end
if numEvents > 1 && frames(end).end == length(data) - 1
    numEvents = numEvents - 1;
end

% Compute the event statistics.
totalTime = length(data) / fps;
frequency = numEvents / totalTime;
timeRatio = nansum([eventStats.time]) / totalTime;
if isName
    dataRatio = nansum([eventStats.(name)]) / nansum(data);
    ratios = struct( ...
        'time', timeRatio, ...
        name, dataRatio);
else
    ratios = struct('time', timeRatio);
end
summaryStats = struct( ...
    'frequency', frequency, ...
    'ratio', ratios);
end

