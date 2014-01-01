function plotWormPathData(titleLabel, skeleton, coils, omegas, bodyI, ...
    data, varargin)
%PLOTWORMPATHDATA Plot the worm path data.
%
%   PLOTWORMPATHDATA(SKELETON, COILS, OMEGAS, BODYI, DATA)
%
%   PLOTWORMPATHDATA(SKELETON, COILS, OMEGAS, BODYI, DATA, DLIM, ALPHA,
%                    XLIMS, YLIMS)
%
%   Inputs:
%       skeleton - the worm skeleton (worm.posture.skeleton)
%       coils    - the worm coils (worm.posture.coils)
%       omegas   - the worm omegas (worm.locomotion.turns.omegas)
%       bodyI    - the body indices to use for the plot
%       data     - the data to plot
%       dLims    - the data limits to use for coloring;
%                  if empty, the colors are scaled to the full data set;
%                  the default is scaled (empty)
%       alpha    - the alpha transparency to use;
%                  the default is opaque (1)
%       xLims    - the x-axis limits;
%                  if empty, the limits are scaled to the data set;
%                  the default is scaled (empty)
%       yLims    - the y-axis limits;
%                  if empty, the limits are scaled to the data set;
%                  the default is scaled (empty)
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
alpha = 1;
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

% Initialize special ascii symbols.
sepStr = '   ¤   ';

% Initialize the label information.
titleFont = '\fontsize{16}';
axisFont = '\fontsize{14}';
tickFontSize = 12;

% Initialize the worm plot information.
firstWormColor = str2colors('k', 0.5);
lastWormColor = str2colors('k')';

% Initialize the path plot information.
pathWidth = 2;
wormWidth = 2;

% Initialize the event plot information.
coilMarker = '\bf+';
coilColor = str2colors('n');
omegaMarker = '\bfx';
omegaColor = str2colors('n');
eventFontSize = 48;

% Initialize the skeleton information.
x = skeleton.x;
y = skeleton.y;
isNaNFrame = isnan(x(1,:));

% Zero the skeleton.
x = (x - min(x(:))) / 1000;
y = (y - min(y(:))) / 1000;

% Compute the points.
bodyX = [mean(x(bodyI,:), 1), nan];
bodyY = [mean(y(bodyI,:), 1), nan];
z = [data, nan];

% Find the first and last worm.
firstI = findForeFrame(1, isNaNFrame);
lastI = findBackFrame(length(isNaNFrame), isNaNFrame);

% Find the coils and omega turns. 
[coils omegas] = touch2frames(coils, omegas, isNaNFrame);
coilsX = (bodyX(coils(:,1)) + bodyX(coils(:,2))) / 2;
coilsY = (bodyY(coils(:,1)) + bodyY(coils(:,2))) / 2;
omegasX = (bodyX(omegas(:,1)) + bodyX(omegas(:,2))) / 2;
omegasY = (bodyY(omegas(:,1)) + bodyY(omegas(:,2))) / 2;

% Plot the first and last worm.
% zWorm = [zeros(1, skelSize) nan];
% patch([x(:,firstI)', nan], [y(:,firstI)', nan], zWorm, ...
%     'EdgeColor', firstWormColor, 'LineWidth', wormWidth, 'EdgeAlpha', 1);
% patch([x(:,lastI)', nan], [y(:,lastI)', nan], zWorm, ...
%     'EdgeColor', lastWormColor, 'LineWidth', wormWidth, 'EdgeAlpha', 1);
hold on;
plot(x(:,firstI), y(:,firstI), 'o', 'Color', firstWormColor, ...
    'MarkerFaceColor', firstWormColor, ...
    'MarkerEdgeColor', firstWormColor, ...
    'LineWidth', wormWidth);
plot(x(:,lastI), y(:,lastI), 'o', 'Color', lastWormColor, ...
    'MarkerFaceColor', lastWormColor, ...
    'MarkerEdgeColor', lastWormColor, ...
    'LineWidth', wormWidth);

% Plot the coils and omegas.
text(coilsX, coilsY, coilMarker, 'FontSize', eventFontSize, ...
    'Color', coilColor, ...
    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle');
text(omegasX, omegasY, omegaMarker, 'FontSize', eventFontSize, ...
    'Color', omegaColor, ...
    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle');

% Plot the path.
colormap(jet);
set(gca, 'CLim', dLims);
patch(bodyX, bodyY, z, 'CDataMapping','scaled', ...
    'EdgeColor', 'flat', 'LineWidth', pathWidth, 'EdgeAlpha', alpha);

% Label the coils and omegas.
blackStr = '\color{black}';
coilColorStr = color2TeX(coilColor);
omegaColorStr = color2TeX(omegaColor);
coilStr = ['\bfCoils(' coilColorStr coilMarker blackStr ') = ' ...
    num2str(length(coilsX))];
omegaStr = ['\bfOmegas(' omegaColorStr omegaMarker blackStr ') = ' ...
    num2str(length(omegasX))];

% Label the image.
set(gca, 'FontSize', tickFontSize);
title([titleFont titleLabel]);
xlabel([axisFont 'X Location (mm)' sepStr omegaStr]);
ylabel([axisFont 'Y Location (mm)' sepStr coilStr]);

% Clean up the image.
axis equal;
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
