function eventStats = removePartialEvents(eventStats, totalFrames)
%REMOVEPARTIALEVENTS Remove partial events at the start and end of the data.
%
%   EVENTSTATS = REMOVEPARTIALEVENTS(EVENTSTATS, TOTALFRAMES)
%
%   Inputs:
%       eventStats  - the event statistics (see events2stats)
%       totalFrames - the total number of frames in the video
%
%   Output:
%       eventStats - the event statistics (see events2stats) with partial
%                    events, at the start and end of the data, removed
%
%   See also EVENTS2STATS
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Remove partially recorded events.
if ~isempty(eventStats)
    if eventStats(1).start == 0
        eventStats(1) = [];
    end
end
if ~isempty(eventStats)
    if eventStats(end).end == totalFrames
        eventStats(end) = [];
    end
end
end

