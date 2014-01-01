function plotAxes = plotWormPathData(titleLabel, skeleton, ...
    coils, omegas, bodyI, data, varargin)
%PLOTWORMPATHDATA Plot the worm path data.
%
%   PLOTAXES = PLOTWORMPATHDATA(SKELETON, COILS, OMEGAS, BODYI, DATA)
%
%   PLOTAXES = PLOTWORMPATHDATA(SKELETON, COILS, OMEGAS, BODYI, DATA,
%                               DLIM, ALPHA, XLIMS, YLIMS,
%                               CENTERMODE, ROTATEMODE, SHAPEMODE, SORTMODE
%                               PLOTAXES)
%
%   Inputs:
%       skeleton   - the worm(s) skeleton (worm.posture.skeleton)
%       coils      - the worm(s) coils (worm.posture.coils)
%       omegas     - the worm(s) omegas (worm.locomotion.turns.omegas)
%       bodyI      - the body indices to use for the plot
%       data       - the data to plot
%       dLims      - the data limits to use for coloring;
%                    if empty, the colors are scaled to the full data set;
%                    the default is scaled (empty)
%       alpha      - the alpha transparency to use;
%                    the default is opaque (1)
%       xLims      - the x-axis limits;
%                    if empty, the limits are scaled to the data set;
%                    the default is scaled (empty)
%       yLims      - the y-axis limits;
%                    if empty, the limits are scaled to the data set;
%                    the default is scaled (empty)
%       centerMode - how are we centering the path(s)?
%                    the default is not to center the paths (0)
%
%                    0 = don't center the path(s)
%                    1 = center the path(s) by boundary 
%                    2 = center the path(s) by centroid
%
%       rotateMode - are we rotating the path(s) to a standard orientation?
%                    the negative sign (-) rotates by image orientation
%                    the default is not to rotate the paths (0)
%
%                    0 = don't rotate the path(s)
%                    1 = rotate the path by axial orientation
%                    2 = rotate the path and center the path(s) by boundary 
%                    3 = rotate the path and center the path(s) by centroid
%
%       shapeMode  - are we plotting the path(s) on a shape?
%                    the default mode is no shape (0)
%
%                    0     = don't plot the path(s) on a shape
%                    1     = plot the path(s) on a circle
%                    2     = plot the path(s) on a square
%                    [r,c] = plot the path(s) on a rectangle
%                            r = rows; c = columns
%
%       sortMode   - how are we sorting the path(s) on the shape?
%                    use the negative sign (-) to sort in descending order
%                    the default mode is not to sort the paths (0)
%
%                    0 = don't sort the path(s)
%                    1 = sort the paths by maximum axis
%                    2 = sort the paths by minimum axis
%                    3 = sort the paths by area (x-axis size * y-axis size)
%                    4 = sort the paths by x-axis size
%                    5 = sort the paths by y-axis size
%
%       isBigFonts - are we using big fonts for the labels?
%                    the default is no (false)
%       plotAxes   - the plot axes; if empty, create new axes
%
%   Outputs:
%       plotAxes - the plot axes
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Get the data limits to use for coloring.
dLims = [];
if ~isempty(varargin)
    dLims = varargin{1};
end
if isempty(dLims)
    dLims = [min(data), max(data)];
end

% Get the alpha transparency to use.
alpha = 0.99;
if length(varargin) > 1
    alpha = varargin{2};
end

% Get the x-axis limits.
xLims = [];
if length(varargin) > 2
    xLims = varargin{3};
end

% Get the y-axis limits.
yLims = [];
if length(varargin) > 3
    yLims = varargin{4};
end

% Are we centering the path(s)?
centerMode = 0;
if length(varargin) > 4
    centerMode = varargin{5};
end

% Are we rotating the path(s) to a standard orientation?
rotateMode = 0;
if length(varargin) > 5
    rotateMode = varargin{6};
end

% Are we plotting the path(s) on a shape?
shapeMode = 0;
if length(varargin) > 6
    shapeMode = varargin{7};
end

% How are we sorting the path(s) on the shape?
sortMode = 0;
if length(varargin) > 7
    sortMode = varargin{8};
end

% Are we using big fonts?
isBigFonts = false;
if length(varargin) > 8
    isBigFonts = varargin{9};
end

% Get the plot axes.
plotAxes = [];
if length(varargin) > 9
    plotAxes = varargin{10};
end

% Fix the data.
if ~iscell(skeleton)
    skeleton = {skeleton};
end
if ~iscell(coils)
    coils = {coils};
end
if ~iscell(omegas)
    omegas = {omegas};
end
if ~iscell(data)
    data = {data};
end

% Initialize special ascii symbols.
sepStr = '   ¤   ';

% Initialize the label information.
if isBigFonts
    titleFont = '\fontsize{24}';
    axisFont = '\fontsize{20}';
    tickFontSize = 16;
else
    titleFont = '\fontsize{16}';
    axisFont = '\fontsize{14}';
    tickFontSize = 12;
end

% Initialize the worm plot information.
firstWormColor = str2colors('k', 0.5);
lastWormColor = str2colors('k')';

% Initialize the path plot information.
pathScale = 1 / 1000;
pathWidth = 2;
wormWidth = 2;

% Initialize the event plot information.
coilMarker = '\bf+';
coilColor = str2colors('n');
omegaMarker = '\bfx';
omegaColor = str2colors('n');
eventFontSize = 48;

% Organize the skeleton, body, and events.
isNaNFrame = cell(length(skeleton), 1);
firstX = cell(length(skeleton), 1);
firstY = cell(length(skeleton), 1);
lastX = cell(length(skeleton), 1);
lastY = cell(length(skeleton), 1);
bodyX = cell(length(skeleton), 1);
bodyY = cell(length(skeleton), 1);
coilsX = cell(length(skeleton), 1);
coilsY = cell(length(skeleton), 1);
omegasX = cell(length(skeleton), 1);
omegasY = cell(length(skeleton), 1);
for i = 1:length(skeleton)
    
    % Determine the skeleton.
    x = skeleton{i}.x;
    y = skeleton{i}.y;
    isNaNFrame{i} = isnan(x(1,:));
    bodyX{i} = mean(x(bodyI,:), 1) * pathScale;
    bodyY{i} = mean(y(bodyI,:), 1) * pathScale;
    
    % Compute the path centroid.
    if centerMode > 0 || rotateMode ~= 0
        meanX = nanmean(bodyX{i});
        meanY = nanmean(bodyY{i});
    end
    
    % Center the path to its boundary.
    xOff = 0;
    yOff = 0;
    if centerMode == 1
        xOff = -(max(bodyX{i}) + min(bodyX{i})) ./ 2;
        yOff = -(max(bodyY{i}) + min(bodyY{i})) ./ 2;
        bodyX{i} = bodyX{i} + xOff;
        bodyY{i} = bodyY{i} + yOff;
        
    % Center the path to its centroid.
    elseif centerMode == 2
        xOff = -meanX;
        yOff = -meanY;
        bodyX{i} = bodyX{i} + xOff;
        bodyY{i} = bodyY{i} + yOff;
    end
    
    % Find the first and last worm.
    firstI = findForeFrame(1, isNaNFrame{i});
    firstX{i} = x(:,firstI) * pathScale + xOff;
    firstY{i} = y(:,firstI) * pathScale + yOff;
    lastI = findBackFrame(length(isNaNFrame{i}), isNaNFrame{i});
    lastX{i} = x(:,lastI) * pathScale + xOff;
    lastY{i} = y(:,lastI) * pathScale + yOff;
    
    % Rotate the path.
    if rotateMode ~= 0
        
        % Compute the axial orientation.
        if rotateMode > 0
            
            % Find the path bounds.
            [minX, minXI] = min(bodyX{i});
            [minY, minYI] = min(bodyY{i});
            [maxX, maxXI] = max(bodyX{i});
            [maxY, maxYI] = max(bodyY{i});
            
            % Find the axial sizes.
            sizeX = maxX - minX;
            sizeY = maxY - minY;
            
            % Align to the largest axis.
            if sizeX > sizeY
                sizeY = bodyY{i}(maxXI) - bodyY{i}(minXI);
            else
                sizeX = bodyX{i}(maxYI) - bodyX{i}(minYI);
            end
            theta = atan2(sizeY, sizeX);
            
        % Compute the image orientation.
        % Note: see http://en.wikipedia.org/wiki/Image_moment#Examples_2
        else
            M00 = length(bodyX{i});
            M11 = nansum(bodyX{i} .* bodyY{i});
            M20 = nansum(bodyX{i}.^2);
            M02 = nansum(bodyY{i}.^2);
            up11 = M11 / M00 - meanX * meanY;
            up20 = M20 / M00 - meanX.^2;
            up02 = M02 / M00 - meanY.^2;
            theta = atan(2 * up11 / (up20 - up02)) / 2;
        end
        
        % Compute the rotation.
        theta = theta - pi / 2;
        rot = [cos(theta) sin(-theta); sin(theta) cos(theta)];
        
        % Rotate the path.
        bodyXY = ([bodyX{i}; bodyY{i}]' * rot)';
        bodyX{i} = bodyXY(1,:);
        bodyY{i} = bodyXY(2,:);
        
        % Rotate the first and last worms.
        firstXY = [firstX{i}, firstY{i}] * rot;
        firstX{i} = firstXY(:,1);
        firstY{i} = firstXY(:,2);
        lastXY = [lastX{i}, lastY{i}] * rot;
        lastX{i} = lastXY(:,1);
        lastY{i} = lastXY(:,2);

        % Re-center the path.
        if abs(rotateMode) > 1
            
            % Center the path to its boundary.
            if abs(rotateMode) == 2
                minX = min(bodyX{i});
                minY = min(bodyY{i});
                maxX = max(bodyX{i});
                maxY = max(bodyY{i});
                xOff = -(minX + maxX) / 2;
                yOff = -(minY + maxY) / 2;
                
            % Center the path to its centroid.
            else % abs(rotateMode) == 3
                xOff = -nanmean(bodyX{i});
                yOff = -nanmean(bodyY{i});
            end
            
            % Translate the path.
            bodyX{i} = bodyX{i} + xOff;
            bodyY{i} = bodyY{i} + yOff;
            
            % Translate the first and last worms.
            firstX{i} = firstX{i} + xOff;
            firstY{i} = firstY{i} + yOff;
            lastX{i} = lastX{i} + xOff;
            lastY{i} = lastY{i} + yOff;
        end
    end
    
    % Find the coils and omega turns.
    [coil omega] = touch2frames(coils{i}, omegas{i}, isNaNFrame{i});
    coilsX{i} = (bodyX{i}(coil(:,1)) + bodyX{i}(coil(:,2))) / 2;
    coilsY{i} = (bodyY{i}(coil(:,1)) + bodyY{i}(coil(:,2))) / 2;
    omegasX{i} = (bodyX{i}(omega(:,1)) + bodyX{i}(omega(:,2))) / 2;
    omegasY{i} = (bodyY{i}(omega(:,1)) + bodyY{i}(omega(:,2))) / 2;
end

% Translate the paths to a shape.
if shapeMode > 0
    
    % Find the path bounds.
    minX = min([cellfun(@min, bodyX), ...
        cellfun(@min, firstX), cellfun(@min, lastX)], [], 2);
    minY = min([cellfun(@min, bodyY), ...
        cellfun(@min, firstY), cellfun(@min, lastY)], [], 2);
    maxX = max([cellfun(@max, bodyX), ...
        cellfun(@max, firstX), cellfun(@max, lastX)], [], 2);
    maxY = max([cellfun(@max, bodyY), ...
        cellfun(@max, firstY), cellfun(@max, lastY)], [], 2);
    sizeX = maxX - minX;
    sizeY = maxY - minY;
    
    % Center the paths.
    for i = 1:length(bodyX)
        
        % Compute the center.
        xOff = -(minX(i) + maxX(i)) / 2;
        yOff = -(minY(i) + maxY(i)) / 2;
        
        % Translate the path.
        bodyX{i} = bodyX{i} + xOff;
        bodyY{i} = bodyY{i} + yOff;
        
        % Translate the first and last worms.
        firstX{i} = firstX{i} + xOff;
        firstY{i} = firstY{i} + yOff;
        lastX{i} = lastX{i} + xOff;
        lastY{i} = lastY{i} + yOff;
    end
    
    % Sort the paths.
    if sortMode ~= 0
        
        % Determine the sorting order.
        mode = 'ascend';
        if sortMode < 0
            mode = 'descend';
            sortMode = -sortMode;
        end
        
        % Sort the paths by maximum axis.
        sortI = 1:length(bodyX);
        if sortMode == 1
            [~, sortI] = sort(max(sizeX, sizeY), 1, mode);
            
        % Sort the paths by minimum axis.
        elseif sortMode == 2
            [~, sortI] = sort(min(sizeX, sizeY), 1, mode);
            
        % Sort the paths by area.
        elseif sortMode == 3
            [~, sortI] = sort(sizeX .* sizeY, 1, mode);
            
        % Sort the paths by x-axis size.
        elseif sortMode == 4
            [~, sortI] = sort(sizeX, 1, mode);
            
        % Sort the paths by y-axis size.
        elseif sortMode == 5
            [~, sortI] = sort(sizeY, 1, mode);
        end
        
        % Sort the data.
        sizeX = sizeX(sortI);
        sizeY = sizeY(sortI);
        firstX = firstX(sortI);
        firstY = firstY(sortI);
        lastX = lastX(sortI);
        lastY = lastY(sortI);
        bodyX = bodyX(sortI);
        bodyY = bodyY(sortI);
        coilsX = coilsX(sortI);
        coilsY = coilsY(sortI);
        omegasX = omegasX(sortI);
        omegasY = omegasY(sortI);
        data = data(sortI);
    end

    % Translate the paths to a circle.
    if length(shapeMode) == 1 && shapeMode == 1
        circumference = sum(sizeX);
        radius = (circumference / pi) / 2;
        theta = 0;
        for i = 1:length(firstX)
            
            % Translate the path upward.
            yOff = radius + sizeY(i) / 2;
            firstY{i} = firstY{i} + yOff;
            lastY{i} = lastY{i} + yOff;
            bodyY{i} = bodyY{i} + yOff;
            coilsY{i} = coilsY{i} + yOff;
            omegasY{i} = omegasY{i} + yOff;
            
            % Compute the rotation.
            rot = [cos(theta) sin(-theta); sin(theta) cos(theta)];
            
            % Rotate the path.
            bodyXY = ([bodyX{i}; bodyY{i}]' * rot)';
            bodyX{i} = bodyXY(1,:);
            bodyY{i} = bodyXY(2,:);
            
            % Rotate the first and last worms.
            firstXY = [firstX{i}, firstY{i}] * rot;
            firstX{i} = firstXY(:,1);
            firstY{i} = firstXY(:,2);
            lastXY = [lastX{i}, lastY{i}] * rot;
            lastX{i} = lastXY(:,1);
            lastY{i} = lastXY(:,2);
            
            % Rotate the coils and omegas.
            %coilsXY = ([coilsX{i}; coilsY{i}]' * rot)';
            %coilsX{i} = coilsXY(1,:);
            %coilsY{i} = coilsXY(2,:);
            %omegasXY = ([omegasX{i}; omegasY{i}]' * rot)';
            %omegasX{i} = omegasXY(1,:);
            %omegasY{i} = omegasXY(2,:);
            
            % Remove the coils and omegas.
            coilsX{i} = [];
            coilsY{i} = [];
            omegasX{i} = [];
            omegasY{i} = [];
            
            % Advance.
            if i < length(firstX)
                pathOff = (sizeX(i) + sizeX(i + 1)) / 2;
                theta = theta + 2 * pi * (pathOff / circumference);
            end
        end
        
    % Translate the paths to a square.
    else
        
        % Determine the rows and columns.
        if length(shapeMode) > 1
            rows = shapeMode(1);
            cols = shapeMode(2);
            
        % Compute the rows and columns.
        else
            rows = round(sqrt(length(sizeX)));
            cols = ceil(length(sizeX) / rows);
        end
        
        % Compute the sizes.
        padSizeX = zeros(rows * cols, 1);
        padSizeY = zeros(rows * cols, 1);
        padSizeX(1:length(sizeX)) = sizeX;
        padSizeY(1:length(sizeY)) = sizeY;
        sizeX = reshape(padSizeX, cols, rows)';
        sizeY = reshape(padSizeY, cols, rows)';
        
        % Plot the paths.
        padScale = 0.05;
        xMax = max(sizeX);
        xOffs = xMax ./ 2;
        xCumOff =  cumsum([0, xMax(1:(end - 1))] + xMax .* padScale);
        xOffs = xOffs + xCumOff;
        yMax = flipud(max(sizeY, [], 2));
        yOffs = yMax ./ 2;
        yCumOff =  cumsum([0; yMax(1:(end - 1))] + yMax .* padScale);
        yOffs = flipud(yOffs + yCumOff);
        for i = 1:length(bodyX)
            
            % Compute the row and column.
            row = floor((i - 1) / cols) + 1;
            col = floor(i - (row - 1) * cols);
            
            % Compute the offsets.
            xOff = xOffs(col);
            yOff = yOffs(row);
            
            % Translate the path.
            bodyX{i} = bodyX{i} + xOff;
            bodyY{i} = bodyY{i} + yOff;
            
            % Translate the first and last worms.
            firstX{i} = firstX{i} + xOff;
            firstY{i} = firstY{i} + yOff;
            lastX{i} = lastX{i} + xOff;
            lastY{i} = lastY{i} + yOff;
            
            % Translate the coils and omegas.
            %coilsX{i} = coilsX{i} + xOff;
            %coilsY{i} = coilsY{i} + yOff;
            %omegasX{i} = omegasX{i} + xOff;
            %omegasY{i} = omegasY{i} + yOff;
            
            % Remove the coils and omegas.
            coilsX{i} = [];
            coilsY{i} = [];
            omegasX{i} = [];
            omegasY{i} = [];
        end
    end
end

% Compute the patch points.
z = cell(length(bodyX), 1);
for i = 1:length(bodyX)
    bodyX{i} = [bodyX{i}, nan];
    bodyY{i} = [bodyY{i}, nan];
    z{i} = [data{i}, nan];
end

% Plot the paths.
if isempty(plotAxes)
    plotAxes = axes;
end
colormap(plotAxes, jet);
set(plotAxes, 'CLim', dLims);
hold(plotAxes, 'on');
for i = 1:length(bodyX)
    
    % Plot the first and last worm.
    plot(plotAxes, firstX{i}, firstY{i}, 'o', ...
        'Color', firstWormColor, ...
        'MarkerFaceColor', firstWormColor, ...
        'MarkerEdgeColor', firstWormColor, ...
        'LineWidth', wormWidth);
    plot(plotAxes, lastX{i}, lastY{i}, 'o', ...
        'Color', lastWormColor, ...
        'MarkerFaceColor', lastWormColor, ...
        'MarkerEdgeColor', lastWormColor, ...
        'LineWidth', wormWidth);
    
    % Plot the coils and omegas.
    text(coilsX{i}, coilsY{i}, coilMarker, ...
        'FontSize', eventFontSize, ...
        'Color', coilColor, ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', ...
        'Parent', plotAxes);
    text(omegasX{i}, omegasY{i}, omegaMarker, ...
        'FontSize', eventFontSize, ...
        'Color', omegaColor, ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', ...
        'Parent', plotAxes);
    
    % Plot the path.
    patch(bodyX{i}, bodyY{i}, z{i}, 'CDataMapping','scaled', ...
        'EdgeColor', 'flat', 'LineWidth', pathWidth, 'EdgeAlpha', alpha);
end

% Label the coils and omegas.
coilStr = '';
omegaStr = '';
if shapeMode == 0
    blackStr = '\color{black}';
    coilColorStr = color2TeX(coilColor);
    omegaColorStr = color2TeX(omegaColor);
    coilStr = [sepStr '\bfCoils(' coilColorStr coilMarker blackStr ...
        ') = ' num2str(sum(cellfun('length', coilsX)))];
    omegaStr = [sepStr '\bfOmegas(' omegaColorStr omegaMarker blackStr ...
        ') = ' num2str(sum(cellfun('length', omegasX)))];
end

% Label the image.
set(plotAxes, 'FontSize', tickFontSize);
title(plotAxes, [titleFont titleLabel]);
xlabel(plotAxes, [axisFont 'X Location (mm)' omegaStr]);
ylabel(plotAxes, [axisFont 'Y Location (mm)' coilStr]);

% Clean up the image.
axis image;
if ~isempty(xLims)
    xlim(xLims);
end
if ~isempty(yLims)
    ylim(yLims);
end
end



%% Find the first usable frame forwards.
function i = findForeFrame(i, isNaNFrame)
while isNaNFrame(i) && i < length(isNaNFrame)
    i = i + 1;
end
end



%% Find the first usable frame backwards.
function i = findBackFrame(i, isNaNFrame)
while isNaNFrame(i) && i > 1
    i = i - 1;
end
end



%% Find the coils and omega turns. 
function [coilFrames omegaFrames] = touch2frames(coils, omegas, isNaNFrame)

% Get the frames.
coils = coils.frames;
omegas = omegas.frames;

% Remove coils that are omega turns.
if ~isempty(coils)
    keepI = true(length(coils), 1);
    for i = 1:length(coils)
        for j = 1:length(omegas)
            
            % Do the coil and omega intersect?
            c1 = coils(i).start;
            c2 = coils(i).end;
            o1 = omegas(j).start;
            o2 = omegas(j).end;
            if (c1 >= o1 && c1 <= o2) || (c2 >= o1 && c2 <= o2) || ...
                    (c1 <= o1 && c2 >= o2)
                keepI(i) = false;
            end
        end
    end
    coils = coils(keepI);
end

% Find the first and last usable frame for each coil.
coilFrames = nan(length(coils), 2);
for i = 1:length(coils)
    
    % Find the first and last usable frame.
    coilFrames(i,1) = findBackFrame(coils(i).start + 1, isNaNFrame);
    coilFrames(i,2) = findForeFrame(coils(i).end + 1, isNaNFrame);
    
    % Are either of the frames missing?
    if isNaNFrame(coilFrames(i,1))
        coilFrames(i,1) = coilFrames(i,2);
    elseif isNaNFrame(coilFrames(i,2))
        coilFrames(i,2) = coilFrames(i,1);
    end
end

% Find the first and last usable frame for each omega.
omegaFrames = nan(length(omegas), 2);
for i = 1:length(omegas)
    
    % Find the first and last usable frame.
    omegaFrames(i,1) = findBackFrame(omegas(i).start + 1, isNaNFrame);
    omegaFrames(i,2) = findForeFrame(omegas(i).end + 1, isNaNFrame);
    
    % Are either of the frames missing?
    if isNaNFrame(omegaFrames(i,1))
        omegaFrames(i,1) = omegaFrames(i,2);
    elseif isNaNFrame(omegaFrames(i,2))
        omegaFrames(i,2) = omegaFrames(i,1);
    end
end
end
