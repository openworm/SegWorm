function [timeAxis frameAxis] = plotEvent(events, totalFrames, fps, ...
    titleName, yAxisName, eventNames, event2box, states, colors, varargin)
%PLOTEVENT Plot a time series of events.
%
%   PLOTEVENT(EVENTS, FRAMES, FPS, TITLENAME, YAXISNAME, EVENTNAMES,
%             EVENT2BOX, STATES, COLORS)
%
%   PLOTEVENT(EVENTS, FRAMES, FPS, TITLENAME, YAXISNAME, EVENTNAMES,
%             EVENT2BOX, STATES, COLORS, ISBOXEDGE)
%
%   Inputs:
%       events      - the events to plot
%       totalFrames - the total number of frames for the time series
%       fps         - the frames/second
%       titleName   - the title for the figure
%       yAxisName   - the name to label the y axis
%       eventNames  - the name(s) to label the events
%       event2box   - a function handle(s) for converting the events to
%                     boxes; the function must be of the form:
%                    
%                     [BOX STATE] =
%                        EVENT2BOX(STATE, PREVEVENT, EVENT, NEXTEVENT)
%
%       states      - the function state(s) for the event2box function(s);
%                     if there are more states than function handles, the
%                     last function is used for all unassigned states
%       colors      - the box colors, per event2box function
%       isBoxEdge   - do the boxes have a black edge?
%
%   Outputs:
%       timeAxis  - the plot's time axis
%       frameAxis - the plot's frame axis
%
% See also FINDEVENT, EVENT2BOX
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Do the boxes have a black edge?
isBoxEdge = false;
if ~isempty(varargin)
    isBoxEdge = varargin{1};
end

% Organize the event names.
if ~iscell(eventNames)
    eventNames = {eventNames};
end

% Organize the event-to-box functions.
if ~iscell(event2box)
    event2box = {event2box};
end
if length(event2box) < length(states)
    event2box((end + 1):length(states)) = event2box(end);
end

% Compute the event boxes
frames = zeros(1, totalFrames);
boxes = nan(length(events), length(event2box), 2, 4);
prevEvent = [];
nextEvent = [];
for i = 1:length(events)
    
    % Set the next event.
    if i < length(events)
        nextEvent = events(i + 1);
    end
    
    % Compute the event box.
    for j = 1:length(event2box)
         [boxes(i,j,:,:) states(j)] = event2box{j}(states(j), ...
             prevEvent, events(i), nextEvent);
         
         % Compute the event frames.
         startX = min(boxes(i,j,1,:));
         minX = boxes(i,j,1,:) == startX;
         startY = max(boxes(i,j,2,minX));
         endX = max(boxes(i,j,1,:));
         maxX = boxes(i,j,1,:) == endX;
         endY = max(boxes(i,j,2,maxX));
         newX = abs(endX - startX) + 1;
         rangeX = linspace(startX + 1, endX + 1, newX);
         if ~(isnan(rangeX(1)) || isnan(rangeX(end)))
             frames(rangeX) = linspace(startY, endY, newX);
         end
    end
    
    % Set the previous event.
    prevEvent = events(i);
end

% Compute the x axis.
frameX = 0:(totalFrames - 1);

% Plot both frame and time.
[ax, h1, h2] = plotyy(NaN, NaN, frameX, frames);
timeAxis = ax(1);
frameAxis = ax(2);
set(timeAxis, 'XAxisLocation', 'top');
set(h2, 'LineStyle', 'none');
hold on;

% Setup the events for the legend.
for i = fliplr(1:length(eventNames))
    h = plot(timeAxis, NaN, 'Color', colors(i,:));
    uistack(h, 'bottom');
end

% Plot the events.
patchHandle = nan(size(boxes, 2), 1);
if isBoxEdge
    for i = 1:size(boxes, 2)
        patchHandle(i) = patch(squeeze(boxes(:,i,1,:))', ...
            squeeze(boxes(:,i,2,:))', colors(i,:), 'Parent', frameAxis);
    end
else
    for i = 1:size(boxes, 2)
        patchHandle(i) = patch(squeeze(boxes(:,i,1,:))', ...
            squeeze(boxes(:,i,2,:))', colors(i,:), 'Parent', frameAxis, ...
            'EdgeColor', colors(i,:));
    end
end

% Compute the x & y axis limits.
minTimeX = frameX(1) / fps; %datenum(0, 0, 0, 0, 0, frameX(1) / fps);
maxTimeX = frameX(end) / fps; %datenum(0, 0, 0, 0, 0, frameX(end) / fps);
boxesY = boxes(:,:,2,:);
boxesY = boxesY(:);
minY = min(boxesY);
maxY = max(boxesY);

% Link the frame and time axes.
if ~isequalwithequalnans(minTimeX, maxTimeX)
    xlim(timeAxis, [minTimeX, maxTimeX]);
end
xlim(frameAxis, [frameX(1), frameX(end)]);
if ~isequalwithequalnans(minY, maxY)
    ylim(timeAxis, [minY, maxY]);
    ylim(frameAxis, [minY, maxY]);
end
linkaxes(ax, 'y');

% Fix the figure zoom.
set(zoom(get(h1, 'Parent')), 'Motion', 'horizontal', 'Enable', 'on');

% Fix the figure colors.
black = [0 0 0];
%magenta = [1 0 1];
set(h1, 'Color', black);
set(h2, 'Color', black);
%set(timeAxis, 'XColor', magenta);
set(timeAxis, 'XColor', black);
set(frameAxis, 'XColor', black);
set(timeAxis, 'YColor', black);
set(frameAxis, 'YColor', black);

% Label the figure.
xlabel(timeAxis, 'Event Time (seconds)', 'Color', black);
xlabel(frameAxis, 'Event Frame (number)', 'Color', black);
ylabel(timeAxis, titleName, 'Color', black);
ylabel(frameAxis, yAxisName, 'Color', black, 'Rotation', 270);
set(timeAxis, 'YTickMode', 'manual');
set(timeAxis, 'YTickLabel', []);
set(timeAxis, 'YTick', []);
if isempty(yAxisName)
    set(frameAxis, 'YTickMode', 'manual');
    set(frameAxis, 'YTickLabel', []);
    set(frameAxis, 'YTick', []);
else
    set(frameAxis, 'YTickMode', 'auto');
end
%datetick(frameAxis, 'x', 13, 'keeplimits');

% Fix the data crosshairs.
uistack(h2, 'top');

% Show the legend.
legend(eventNames);
end
