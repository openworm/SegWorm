%PLOTWORMPATH Plot the worm path(s).
%
%   PLOTWORMPATH(WORMPATH, STARTWORM, ENDWORM, WORMCOLORS, FPS,
%                WIDTHPERLENGTH, TITLENAME, AXISNAME, PATHNAMES, PATHCOLORS)
%
%   PLOTWORMPATH(WORMPATH, STARTWORM, ENDWORM, WORMCOLORS, FPS,
%                WIDTHPERLENGTH, TITLENAME, AXISNAME, PATHNAMES, PATHCOLORS,
%                EVENTS, EVENTNAMES, EVENTMARKERS, EVENTCOLORS)
%
%   Inputs:
%       wormPaths      - the worm path(s) coordinates
%       startWorm      - the starting worm coordinates;
%                        if empty, the worm is not plotted
%       endWorm        - the ending worm coordinates;
%                        if empty, the worm is not plotted
%       wormColors     - the colors for the starting and ending worms
%                        if empty, the worm is not plotted
%       fps            - the frames/second;
%                        if empty, the path time is not shown
%       widthPerLength - the worm's mean width/length
%                        (for plotting the starting and ending worm);
%                        if empty, the worm width defaults to 3 points
%       titleName      - the title for the figure
%       axisName       - the name to label the path axes
%       pathNames      - the name(s) to label the path(s)
%       pathColors     - the path(s) colors
%       events         - the event(s) coordinates (XY coordinates x event
%                        number) -- see events2coordinates
%       eventNames     - the name(s) to label the event(s)
%       eventMarkers   - the marker(s) to label the event(s)
%       eventColors    - the color(s) to label the event(s) marker(s)
%
% See PLOTWORMPATHDATA, EVENTS2COORDINATES
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function plotWormPath(wormPaths, startWorm, endWorm, wormColors, fps, ...
    widthPerLength, titleName, axisName, pathNames, pathColors, varargin)

% Are we plotting any events?
events = [];
if length(varargin) >= 4
    
    % Determine the events.
    events = varargin{1};
    
    % Determine the event names.
    eventNames = varargin{2};
    
    % Determine the event markers.
    eventMarkers = varargin{3};
    
    % Determine the event colors.
    eventColors = varargin{4};
end

% Organize the paths.
if ~iscell(wormPaths)
    wormPaths = {wormPaths};
    pathNames = {pathNames};
    pathColors = {pathColors};
end

% Organize the events.
if ~isempty(events) && ~iscell(events)
    events = {events};
    eventNames = {eventNames};
    eventMarkers = {eventMarkers};
    eventColors = {eventColors};
end

% Should we plot the start and end worms?
if isempty(startWorm) || isempty(endWorm)
    startWorm = [];
    endWorm = [];
end

% Plot the start and end worms.
% Note: this is repeated to display the legend and layers correctly.
hold on;
lineSize = 3;
if ~isempty(startWorm)
    plot(startWorm(1,1), startWorm(1,2), 'Color', wormColors{1}, ...
        'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
        'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
end
if ~isempty(endWorm)
    plot(endWorm(1,1), endWorm(1,2), 'Color', wormColors{2}, ...
        'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
        'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});
end

% Plot the start worm for each path in the respective path color.
% Note: this is repeated to display the legend and layers correctly.
if ~isempty(startWorm)
    for i = 1:length(pathColors)
        plot(startWorm(1,1), startWorm(1,2), 'Color', pathColors{i}, ...
            'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', ...
            lineSize, 'MarkerFaceColor', pathColors{i}, ...
            'MarkerEdgeColor', pathColors{i});
    end
end

% Plot the events.
% Note: this is repeated to display the legend and layers correctly.
for i = 1:length(events)
    plot(events(1,1), events(2,1), 'LineStyle', '.', 'Color', ...
        eventColors{i}, 'Marker', eventMarkers{i});
end

% Plot the worm paths.
minXPath = NaN;
maxXPath = NaN;
minYPath = NaN;
maxYPath = NaN;
plotHandle = [];
for i = 1:length(wormPaths)
    
    % Plot the path.
    pathHandle = plot(wormPaths{i}(1,:), wormPaths{i}(2,:), ...
        'LineStyle', '.', 'Marker', '.', 'MarkerSize', 1, ...
        'Color', pathColors{i});
    plotHandle = get(pathHandle, 'Parent');
    
    % Compute the minimum and maximum path coordinates.
    minXPath = min(minXPath, min(wormPaths{i}(1,:)));
    maxXPath = max(maxXPath, max(wormPaths{i}(1,:)));
    minYPath = min(minYPath, min(wormPaths{i}(2,:)));
    maxYPath = max(maxYPath, max(wormPaths{i}(2,:)));
end

% Plot the start and end worms.
% Note: this is repeated to display the legend and layers correctly.
if ~isempty(startWorm)
    plot(startWorm(:,1), startWorm(:,2), 'Color', wormColors{1}, ...
        'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
        'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
    plot(endWorm(:,1), endWorm(:,2), 'Color', wormColors{2}, ...
        'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
        'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});
end

% Plot the events.
for i = 1:length(events)
    plot(events(1,:), events(2,:), 'LineStyle', '.', 'Color', ...
        eventColors{i}, 'Marker', eventMarkers{i});
end

% Construct the starting and ending worm legend.
legends = [];
if ~isempty(startWorm)
    legends{end + 1} = 'Start';
end
if ~isempty(endWorm)
    time = length(wormPaths{1}) / fps;
    legends{end + 1} = ['End (Time = ' num2str(time) ' seconds)'];
end

% Construct the path legend.
for i = 1:length(wormPaths)
    legends{end + 1} = [pathNames{i} ' Path'];
end

% Construct the events legend.
for i = 1:length(events)
    legends{end + 1} = [eventNames '(N = ' num2str(length(events{i})) ')'];
end

% Label the figure.
axis equal;
title(titleName);
xlabel(['X ' axisName]);
ylabel(['Y ' axisName]);
%legendHandle = legend(legends, 'Location', 'North');
%set(legendHandle, 'LineWidth', 1.5);

% Resize the plots to fit the legend.
%plotPosition = get(plotHandle, 'Position');
%legendPosition = get(legendHandle, 'Position');
%pathScale = (legendPosition(2) - plotPosition(2)) / plotPosition(4);
%axis equal;
%pad = 0.01 * min(maxXPath - minXPath, maxYPath - minYPath);
%xlim([minXPath - pad, maxXPath + pad]);
%ylim([minYPath - pad, (maxYPath - minYPath) / pathScale + minYPath + pad]);
end
