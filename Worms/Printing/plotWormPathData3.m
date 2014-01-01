%PLOTWORMPATHDATA Plot data along the worm path.
%
%   PLOTWORMPATHDATA(DATA, WORMPATH, STARTWORM, ENDWORM, WORMCOLORS,
%                    FPS, WIDTHPERLENGTH, TITLENAME, AXISNAME, DATANAME)
%
%   PLOTWORMPATHDATA(DATA, WORMPATH, STARTWORM, ENDWORM, WORMCOLORS,
%                    FPS, WIDTHPERLENGTH, TITLENAME, AXISNAME, DATANAME,
%                    DATACOLORS)
%
%   PLOTWORMPATHDATA(DATA, WORMPATH, STARTWORM, ENDWORM, WORMCOLORS, FPS,
%                    WIDTHPERLENGTH, TITLENAME, AXISNAME, DATANAME,
%                    DATACOLORS, EVENTS, EVENTNAMES, EVENTMARKERS,
%                    EVENTCOLORS)
%
%   Inputs:
%       data           - the data vector to plot
%       wormPath       - the worm path coordinates
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
%       dataName       - the name to label the data values
%       dataColors     - the indices/values or colors for coloring the data;
%                        if empty, the data values are used with the "jet"
%                        colormap
%       events         - the event(s) coordinates (XY coordinates x event
%                        number) -- see events2coordinates
%       eventNames     - the name(s) to label the event(s)
%       eventMarkers   - the marker(s) to label the event(s)
%       eventColors    - the color(s) to label the event(s) marker(s)
%
% See PLOTWORMPATH, EVENTS2COORDINATES
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function plotWormPathData(data, wormPath, startWorm, endWorm, ...
    wormColors, fps, widthPerLength, titleName, axisName, dataName, ...
    varargin)

% Determine the data colors.
dataColors = data;
if ~isempty(varargin)
    dataColors = varargin{1};
end

% Are we plotting any events?
events = [];
if length(varargin) >= 5
    
    % Determine the events.
    events = varargin{2};
    
    % Determine the event names.
    eventNames = varargin{3};
    
    % Determine the event markers.
    eventMarkers = varargin{4};
    
    % Determine the event colors.
    eventColors = varargin{5};
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
% Note: this is done twice to display the legend and layers correctly.
hold on;
lineSize = 3;
if ~isempty(startWorm)
    plot(startWorm(1,1), startWorm(1,2), 'Color', wormColors{1}, ...
        'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
    plot(endWorm(1,1), endWorm(1,2), 'Color', wormColors{2}, ...
        'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});
end

% Plot the events.
% Note: this is done twice to display the legend and layers correctly.
for i = 1:length(events)
    plot(events(1,1), events(2,1), 'LineStyle', '.', 'Color', ...
        eventColors{i}, 'Marker', eventMarkers{i});
end

% Plot the worm path data.
colormap(jet);
circleSize = 3;
pathHandle = scatter(wormPath(1,:), wormPath(2,:), circleSize, ...
    dataColors, 'filled');
plotHandle = get(pathHandle, 'Parent');

% Show the color legend.
colorbarHandle = colorbar;
caxis([min(data) max(data)]);
set(get(colorbarHandle, 'YLabel'), 'String', dataName);

% Plot the start and end worms.
% Note: this is done twice to display the legend and layers correctly.
if ~isempty(startWorm)
    plot(startWorm(:,1), startWorm(:,2), 'Color', wormColors{1}, ...
        'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
    plot(endWorm(:,1), endWorm(:,2), 'Color', wormColors{2}, ...
        'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});
end

% Plot the events.
% Note: this is done twice to display the legend and layers correctly.
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
    time = length(wormPath) / fps;
    legends{end + 1} = ['End (Time = ' num2str(time) ' seconds)'];
end

% Construct the events legend.
for i = 1:length(events)
    legends{end + 1} = [eventNames '(N = ' num2str(length(events{i})) ')'];
end

% Label the figure.
title(titleName);
xlabel(['X ' axisName]);
ylabel(['Y ' axisName]);
if ~isempty(startWorm)
    legendHandle = legend(legends, 'Location', 'North');
    set(legendHandle, 'LineWidth', 1.5);
end

% Compute the minimum and maximum path coordinates.
minXPath = min(wormPath(1,:));
maxXPath = max(wormPath(1,:));
minYPath = min(wormPath(2,:));
maxYPath = max(wormPath(2,:));

% Resize the plots to fit the legend.
pathScale = 1;
if ~isempty(startWorm)
    plotPosition = get(plotHandle, 'Position');
    legendPosition = get(legendHandle, 'Position');
    pathScale = (legendPosition(2) - plotPosition(2)) / plotPosition(4);
end
axis equal;
pad = 0.01 * min(maxXPath - minXPath, maxYPath - minYPath);
xlim([minXPath - pad, maxXPath + pad]);
ylim([minYPath - pad, (maxYPath - minYPath) / pathScale + minYPath + pad]);
end
