function worm2pdf(wormFile, varargin)
%WORM2PDF Show the worm information in a PDF.
%
%   WORM2PDF(WORMFILE)
%
%   WORM2PDF(WORMFILE, PDFFILE)
%
%   Inputs:
%       wormFile - the name of the worm feature's Matlab file
%       pdfFile  - the name for the PDF file; if empty, the wormFile name
%                  is used and ammended to end in .pdf
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Determine the PDF file name.
if isempty(varargin)
    pdfFile = strrep(wormFile, '.mat', '.pdf');
else
    pdfFile = varargin{1};
end

% Load the worm information.
info = [];
worm = [];
load(wormFile, 'info', 'worm');
if isempty(info)
    error('worm2pdf:NoInfo', ['"' wormFile '" does not contain "info"']);
end
if isempty(worm)
    error('worm2pdf:NoWorm', ['"' wormFile '" does not contain a "worm"']);
end

% Determine the frames/second.
fps = info.video.resolution.fps;

% Do we know the worm's ventral side?
isVentralSide = ~isempty(info.experiment.worm.ventralSide);

% Show the worm's morphology.
%showMorphology(worm);

% Show the worm's posture.
time = info.video.length.time;
%showPosture(worm, time, isVentralSide);

% Show the worm's locomotion.
showLocomotion(worm, time, fps, isVentralSide);
end

%% Show the worm's morphology.
function showMorphology(worm)

% Create the figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm length.
data = worm.morphology.length;
titleName = 'WORM LENGTH ';
valueName = 'Length (microns)';
dataNames = 'Length';
resolutions = 1;
histColors = [.5 .5 .5];
lineColors = [.75 0 0];
subplot(2,3,1);
hold on;
plotHistogram(data, resolutions, titleName, valueName, dataNames, ...
    histColors, lineColors);

% Show the worm's midbody width.
data = { ...
    worm.morphology.width.midbody, ...
    worm.morphology.width.head, ...
    worm.morphology.width.tail};
titleName = 'WORM WIDTH ';
valueName = 'Width (microns)';
dataNames = { ...
    'Midbody Width', ...
    'Head Width', ...
    'Tail Width'};
resolutions = { ...
    1, ...
    1, ...
    1};
histColors = { ...
    [.5 .5 .5], ...
    [0 .5 0], ...
    [.5 0 0]};
lineColors = { ...
    [.25 .25 .25], ...
    [0 .75 0], ...
    [.75 0 0]};
subplot(2,3,2);
hold on;
plotHistogram(data, resolutions, titleName, valueName, dataNames, ...
    histColors, lineColors);

% Show the worm area.
data = worm.morphology.area;
titleName = 'WORM AREA ';
valueName = 'Area (microns^{2})';
dataNames = 'Area';
resolutions = 250;
histColors = [.5 .5 .5];
lineColors = [.75 0 0];
subplot(2,3,3);
hold on;
plotHistogram(data, resolutions, titleName, valueName, dataNames, ...
    histColors, lineColors);

% Show the worm midbody width/length.
data = worm.morphology.widthPerLength;
titleName = 'WORM MIDBODY WIDTH/LENGTH   ';
valueName = 'Midbody Width/Length (unitless measure)';
dataNames = 'Width/Length';
resolutions = 0.0001;
histColors = [.5 .5 .5];
lineColors = [.75 0 0];
subplot(2,3,4);
hold on;
plotHistogram(data, resolutions, titleName, valueName, dataNames, ...
    histColors, lineColors);

% Show the worm area/length.
data = worm.morphology.areaPerLength;
titleName = 'WORM AREA/LENGTH  ';
valueName = 'Area/Length (microns)';
dataNames = 'Area/Length';
resolutions = 0.1;
histColors = [.5 .5 .5];
lineColors = [.75 0 0];
subplot(2,3,5);
hold on;
plotHistogram(data, resolutions, titleName, valueName, dataNames, ...
    histColors, lineColors);
end



%% Show the worm's posture.
function showPosture(worm, time, isVentralSide)

end



%% Show the worm's locomotion.
function showLocomotion(worm, time, fps, isVentralSide)

% Compute the video frames.
frames = 1:size(worm.posture.skeleton.x, 1);

% Construct the skeleton.
skeleton = cat(3, worm.posture.skeleton.x, worm.posture.skeleton.y);
skeleton = permute(skeleton, [2 3 1]);

% Compute the worm indices.
headI = 1;
tailI = size(worm.posture.skeleton.x, 2);
midI = round((tailI + 1) / 2);

% Compute the worm segments.
wormSegSize = round(tailI / 12);
halfWormSegSize = round(wormSegSize / 2);
headIs = headI:(headI + wormSegSize - 1);
neckIs = (headI + wormSegSize):(headI + wormSegSize * 2 - 1);
midIs = (midI - halfWormSegSize):(midI + halfWormSegSize);
hipIs = (tailI - wormSegSize * 2 + 1):(tailI - wormSegSize);
tailIs = (tailI - wormSegSize + 1):tailI;
%allMidIs = (neckIs(end) + 1):(hipIs(1) - 1);

% Find the starting worm shape.
startWorm = [];
i = 1;
while i < size(worm.posture.skeleton.x, 1) && ...
        isnan(worm.posture.skeleton.x(i,1))
    i = i + 1;
end
if i < size(worm.posture.skeleton.x, 1)
    startWorm = squeeze(skeleton(:,:,i));
end

% Find the ending worm shape.
endWorm = [];
i = size(worm.posture.skeleton.x, 1);
while i > 0  && isnan(worm.posture.skeleton.x(i,1))
    i = i - 1;
end
if i > 0
    endWorm = squeeze(skeleton(:,:,i));
end

% Create the figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Plot the worm's integrated path.
headWidth = nanmean(worm.morphology.width.head);
midWidth = nanmean(worm.morphology.width.midbody);
tailWidth = nanmean(worm.morphology.width.tail);
meanWidth = (headWidth + midWidth + tailWidth) / 3;
scale = sqrt(2) / meanWidth;
points = { ...
    headI:tailI, ...
    headIs, ...
    tailIs, ...
    midIs, ...
    neckIs, ...
    hipIs};
titleNames = { ...
    'Worm Path Integral', ...
    'Head Path Integral', ...
    'Tail Path Integral', ...
    'Midbody Path Integral', ...
    'Neck Path Integral', ...
    'Hips Path Integral'};
paths = integratePath(skeleton, scale, points);
for i = 1:length(paths)
    
    % Plot the integrated path.
    data = paths{i} / fps;
    subplot(2, ceil(length(paths) / 2), i);
    imagesc(data);
    axis image;
    
    % Label the figure.
    title(titleNames{i});
    xlabel('X Location (microns)');
    ylabel('Y Location (microns)');
    
    % Label the figure values.
    colorbarHandle = colorbar;
    caxis([min(data(:)) max(data(:))]);
    set(get(colorbarHandle, 'YLabel'), 'String', 'Time (seconds)');
end
return;

% Create the figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Plot the worm's midbody speed.
data = worm.locomotion.velocity.midbody.speed;
data = frames;
wormPath = squeeze(skeleton(midI,:,:));
wormColors = { ...
    [0 0 0], ...
    [.5 .5 .5]};
titleName = 'WORM MIDBODY SPEED';
valueName = 'Locaton (microns)';
dataName = 'Speed (microns/second)';
%subplot(2,3,1);
%hold on;
plotPathData(data, wormPath, startWorm, endWorm, wormColors, time, ...
    nanmean(worm.morphology.widthPerLength), titleName, valueName, ...
    dataName, data);
%saveFigure(h, speedFile);

return;

% Create the figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Plot the worm's head, midbody, and tail path.
wormPaths = { ...
    squeeze(nanmean(skeleton(headIs,:,:), 1)), ...
    squeeze(nanmean(skeleton(neckIs,:,:), 1)), ...
    squeeze(nanmean(skeleton(tailIs,:,:), 1)), ...
    squeeze(nanmean(skeleton(hipIs,:,:), 1)), ...
    squeeze(nanmean(skeleton(midIs,:,:), 1))};
wormColors = { ...
    [0 0 0], ...
    [.5 .5 .5]};
titleName = 'WORM PATH';
valueName = 'Locaton (microns)';
pathNames = { ...
    'Head Path', ...
    'Neck Path', ...
    'Tail Path', ...
    'Hips Path', ...
    'Midbody Path'};
pathColors = { ...
    [1 0 0], ...
    [1 .8 .9], ...
    [0 0 1], ...
    [.8 .9 1], ...
    [0 1 0]};
%subplot(2,3,1);
%hold on;
plotPath(wormPaths, startWorm, endWorm, wormColors, time, ...
    nanmean(worm.morphology.widthPerLength), titleName, valueName, ...
    pathNames, pathColors);
end



%% Plot a histogram of data.
function plotHistogram(data, resolutions, titleName, valueName, ...
    dataNames, histColors, lineColors)

% Organize the data.
if ~iscell(data)
    data = {data};
    resolutions = {resolutions};
    dataNames = {dataNames};
    histColors = {histColors};
    lineColors = {lineColors};
end

% Compute the statistics.
counts = cell(length(data),1);
bins = cell(length(data),1);
probability = cell(length(data),1);
maxProbability = nan(length(data),1);
means = nan(length(data),1);
stdDevs = nan(length(data),1);
minBin = NaN;
maxBin = NaN;
for i = 1:length(data)
    
    % Compute the histogram.
    [counts{i} bins{i}] = histogram(data{i}, resolutions{i});
    probability{i} = counts{i} ./ sum(counts{i});
    maxProbability(i) = max(probability{i});
    
    % Compute the summary statistics.
    means(i) = nanmean(data{i});
    stdDevs(i) = nanstd(data{i});
    
    % Compute the minimum and maximum bins.
    minBin = min(minBin, min(bins{i}));
    maxBin = max(maxBin, max(bins{i}));
end

% Compute the summary statistics.
lineScale = 1.1;
meanLineX = nan(length(data), 2);
negStdLineX = nan(length(data), 2);
posStdLineX = nan(length(data), 2);
lineY = nan(length(data), 2);
for i = 1:length(data)
    
    % Compute the line.
    meanLineX(i,1:2) = means(i);
    negStdLineX(i,:) = meanLineX(i,:) - stdDevs(i);
    posStdLineX(i,:) = meanLineX(i,:) + stdDevs(i);
    lineY(i,1:2) = [0, maxProbability(i) * lineScale];
end

% Plot the data.
% Note: this is done twice to display the legend and layers correctly.
transparency = 0.5;
meanLineStyle = '-';
stdLineStyle = '--';
plotHandle = [];
for i = 1:length(data)
    
    % Plot the histograms.
    histHandle = fill(bins{i}, probability{i}, histColors{i});
    set(histHandle, 'FaceAlpha', transparency);
    plotHandle = get(histHandle, 'Parent');
    
    % Plot the summary statisitics.
    line(meanLineX(i,:), lineY(i,:), 'LineStyle', meanLineStyle, ...
        'Color', lineColors{i});
    line(negStdLineX(i,:), lineY(i,:), 'LineStyle', stdLineStyle, ...
        'Color', lineColors{i});
end

% Re-plot the summary statistics.
% Note: this is done twice to display the legend and layers correctly.
for i = 1:length(data)
    line(meanLineX(i,:), lineY(i,:), 'LineStyle', meanLineStyle, ...
        'Color', lineColors{i});
    line(negStdLineX(i,:), lineY(i,:), 'LineStyle', stdLineStyle, ...
        'Color', lineColors{i});
    line(posStdLineX(i,:), lineY(i,:), 'LineStyle', stdLineStyle, ...
        'Color', lineColors{i});
end

% Construct the legend.
legends = cell(3 * length(data), 1);
for i = 1:length(data)
    legends{3 * i - 2} = [dataNames{i} ' Histogram (N = ' ...
        num2str(sum(~isnan(data{i}))) ')'];
    legends{3 * i - 1} = ['Mean ' dataNames{i} ' = ' num2str(means(i))];
    legends{3 * i} = ['Standard Deviation ' dataNames{i} ' = ' ...
        num2str(stdDevs(i))];
end

% Label the figure.
title(titleName);
xlabel(valueName);
ylabel('Probability');
set(zoom(gcf), 'Motion', 'horizontal', 'Enable', 'on');
legendHandle = legend(legends, 'Location', 'North');
set(legendHandle, 'LineWidth', 1.5);

% Resize the plots to fit the legend.
plotPosition = get(plotHandle, 'Position');
legendPosition = get(legendHandle, 'Position');
histScale = (legendPosition(2) - plotPosition(2)) / plotPosition(4);
if minBin ~= maxBin
    xlim([minBin, maxBin]);
end
ylim([0, max(maxProbability) * lineScale / histScale]);
end



%% Plot the worm's path.
function plotPath(wormPaths, startWorm, endWorm, wormColors, time, ...
    widthPerLength, titleName, valueName, pathNames, pathColors)

% Organize the paths.
if ~iscell(wormPaths)
    wormPaths = {wormPaths};
    pathNames = {pathNames};
    pathColors = {pathColors};
end

% Plot the start worm for each path in the respective path color.
% Note: this is repeated to display the legend and layers correctly.
widthScale = 50;
lineSize = widthPerLength * widthScale;
for i = 1:length(pathColors)
    plot(startWorm(:,1), startWorm(:,2), 'Color', pathColors{i}, ...
        'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
        'MarkerFaceColor', pathColors{i}, 'MarkerEdgeColor', pathColors{i});
end

% Plot the start and end worms.
% Note: this is repeated to display the legend and layers correctly.
plot(startWorm(:,1), startWorm(:,2), 'Color', wormColors{1}, ...
    'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
    'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
plot(endWorm(:,1), endWorm(:,2), 'Color', wormColors{2}, ...
    'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
    'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});

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
plot(startWorm(:,1), startWorm(:,2), 'Color', wormColors{1}, ...
    'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
    'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
plot(endWorm(:,1), endWorm(:,2), 'Color', wormColors{2}, ...
    'LineWidth', lineSize, 'Marker', 'o', 'MarkerSize', lineSize, ...
    'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});

% Construct the legend.
legends = cell(length(wormPaths) + 2, 1);
for i = 1:length(wormPaths)
    legends{i} = [pathNames{i} ' Path (N = ' ...
        num2str(sum(~isnan(wormPaths{i}(:,1)))) ')'];
end
legends{i + 1} = 'Start';
legends{i + 2} = ['End (Time = ' num2str(time) ' seconds)'];

% Label the figure.
title(titleName);
xlabel(['X ' valueName]);
ylabel(['Y ' valueName]);
legendHandle = legend(legends, 'Location', 'North');
set(legendHandle, 'LineWidth', 1.5);

% Resize the plots to fit the legend.
plotPosition = get(plotHandle, 'Position');
legendPosition = get(legendHandle, 'Position');
pathScale = (legendPosition(2) - plotPosition(2)) / plotPosition(4);
axis equal;
pad = 0.01 * min(maxXPath - minXPath, maxYPath - minYPath);
xlim([minXPath - pad, maxXPath + pad]);
ylim([minYPath - pad, (maxYPath - minYPath) / pathScale + minYPath + pad]);
end



%% Plot the worm's path data.
function plotPathData(data, wormPath, startWorm, endWorm, wormColors, ...
    time, widthPerLength, titleName, valueName, dataName, dataColors)

% Plot the start and end worms.
% Note: this is done twice to display the legend and layers correctly.
widthScale = 150;
lineSize = widthPerLength * widthScale;
plot(startWorm(:,1), startWorm(:,2), 'Color', wormColors{1}, ...
    'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
plot(endWorm(:,1), endWorm(:,2), 'Color', wormColors{2}, ...
    'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});

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

% Compute the minimum and maximum path coordinates.
minXPath = min(wormPath(1,:));
maxXPath = max(wormPath(1,:));
minYPath = min(wormPath(2,:));
maxYPath = max(wormPath(2,:));

% Plot the start and end worms.
% Note: this is done twice to display the legend and layers correctly.
plot(startWorm(:,1), startWorm(:,2), 'Color', wormColors{1}, ...
    'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{1}, 'MarkerEdgeColor', wormColors{1});
plot(endWorm(:,1), endWorm(:,2), 'Color', wormColors{2}, ...
    'LineWidth', lineSize); %, 'Marker', 'o', 'MarkerSize', lineSize, ...
    %'MarkerFaceColor', wormColors{2}, 'MarkerEdgeColor', wormColors{2});

% Construct the legend.
legends = { ...
    'Start', ...
    ['End (Time = ' num2str(time) ' seconds)']};

% Label the figure.
title(titleName);
xlabel(['X ' valueName]);
ylabel(['Y ' valueName]);
legendHandle = legend(legends, 'Location', 'North');
set(legendHandle, 'LineWidth', 1.5);

% Resize the plots to fit the legend.
plotPosition = get(plotHandle, 'Position');
legendPosition = get(legendHandle, 'Position');
pathScale = (legendPosition(2) - plotPosition(2)) / plotPosition(4);
axis equal;
pad = 0.01 * min(maxXPath - minXPath, maxYPath - minYPath);
xlim([minXPath - pad, maxXPath + pad]);
ylim([minYPath - pad, (maxYPath - minYPath) / pathScale + minYPath + pad]);
end



%% Integrate the worm path.
function paths = integratePath(skeleton, scale, points)

% Scale the skeleton.
skeleton = round(skeleton * scale);
skeletonX = skeleton(:,1,:);
skeletonY = skeleton(:,2,:);

% Compute the path space.
xMin = min(skeletonX(:));
xMax = max(skeletonX(:));
yMin = min(skeletonY(:));
yMax = max(skeletonY(:));

% Translate the skeleton to a zero origin.
skeleton(:,1,:) = skeleton(:,1,:) - xMin + 1;
skeleton(:,2,:) = skeleton(:,2,:) - yMin + 1;

% Construct the empty paths.
pathSize = [yMax - yMin + 1, xMax - xMin + 1];
zeroPath = zeros(pathSize);
paths = cell(length(points),1);
for i = 1:length(points)
    paths{i} = zeroPath;
end

% Integrate the paths.
for i = 1:size(skeleton, 3)

    % Is there a skeleton for this frame?
    worm = squeeze(skeleton(:,:,i));
    if isnan(worm(1))
        continue;
    end

    % Compute the worm.
    wormI = sub2ind(pathSize, worm(:,2), worm(:,1));
    
    % Integrate the path.
    for j = 1:length(paths)
        
        % Compute the unique worm points.
        wormPointsI = unique(wormI(points{j}));
        
        % Integrate the path.
        paths{j}(wormPointsI) = paths{j}(wormPointsI) + 1;
    end
end

% Correct the y-axis (from image space).
for i = 1:length(paths)
    paths{i} = flipud(paths{i});
end
end



%% Convert data to colors.
function dataColors = data2colors(data, colors)

% Normalize the data.
minData = min(data);
data = data - minData;
data = data / max(data);

% Convert the data to colors.
colorIndex = round((size(colors ,1) - 1) * data) + 1;
dataColors = colors(colorIndex,:);
end



%% Save a figure to a file.
function saveFigure(figureHandle, pdfFile)
drawnow;
set(figureHandle, 'PaperPosition', [0.25 0.25 22.9036 16.048]);
set(figureHandle, 'PaperOrientation', 'landscape');
set(figureHandle, 'PaperType', 'A2');
saveas(figureHandle, pdfFile, 'pdf');
end



%% Merge 2 PDF files.
function mergePDFs(file1, file2, mergeFile)

% Use Ghostscript to merge.
gsPath = '/usr/local/bin/gs';
command = [gsPath ' -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite ' ...
    '-sOutputFile=' mergeFile ' ' file1 ' ' file2 ];

% Merge the PDFs.
[status, result] = system(command);
if status ~= 0
    error('worm2pdf:MergePDF', ['"' file1 '" and "' file2 ...
        '" cannot be merged into "' mergeFile '": ' result]);
end
end

% function plotEvent(eventFrames, eventField, titleName, valueName, color)
% end
