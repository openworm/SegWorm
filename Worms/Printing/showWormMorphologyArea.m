function [saveFile pages] = showWormMorphologyArea(worm, varargin)
%SHOWWORMMORPHOLOGYAREA Show the worm area morphology.
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYAREA(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYAREA(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYAREA(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYAREA(WORM, FILEPREFIX, PAGE, ISCLOSE)
%
%   Inputs:
%       worm        - the worm to show
%       filePrefix  - the file prefix for saving the figure;
%                     if empty, the figure is not saved
%       page        - the page number;
%                     if empty, the page number is not shown
%       isClose     - shoud we close the figure after saving it?
%                     when saving the figure, the default is yes (true)
%                     otherwise, the default is no (false)
%
%   Output:
%       saveFile - the file containing the saved figure;
%                  if empty, the figure was not saved
%       pages    - the number of pages in the figure file
%
%   See WORMORGANIZATION, SHOWORMMORPHOLOGY
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Pad the title when saving the figure.
% Note: Matlab has a bug that cuts off the title when saving figures.
pages = 0;
titlePad = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    pages = 1;
    titlePad = '          ';
end

% Determine the locomotion modes.
motionMode = worm.locomotion.motion.mode;
motionModes = { ...
    1, ...
    0, ...
    -1};
motionNames = { ...
    'Forward', ...
    'Paused', ...
    'Backward'};



%% Show the area.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm area.
subplot(2, 3, 1);
hold on;
data = {worm.morphology.area};
titleName = ['WORM AREA' titlePad];
xAxisName = 'Area (microns^{2})';
dataNames = {'Area'};
resolutions = 250;
histColors = str2colors('k', 0, true);
statColors = str2colors('r', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm area.
subplot(2, 3, 4);
hold on;
dataAll = worm.morphology.area;
data = cell(length(motionModes),1);
for i = 1:length(motionModes)
    data{i} = dataAll(motionMode == motionModes{i});
end
samplesAll = sum(~isnan(dataAll));
meanAll = nanmean(dataAll);
stdDevAll = nanstd(dataAll);
titleName = ['WORM AREA (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Area (microns^{2})';
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Area'];
end
resolutions = 250;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);



%% Show the area/length.

% Show the worm area/length.
subplot(2, 3, 2);
hold on;
data = {worm.morphology.areaPerLength};
titleName = ['WORM AREA/LENGTH' titlePad];
xAxisName = 'Area/Length (microns)';
dataNames = {'Area/Length'};
resolutions = 0.1;
histColors = str2colors('k', 0, true);
statColors = str2colors('r', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm area/length.
subplot(2, 3, 5);
hold on;
dataAll = worm.morphology.areaPerLength;
data = cell(length(motionModes),1);
for i = 1:length(motionModes)
    data{i} = dataAll(motionMode == motionModes{i});
end
samplesAll = sum(~isnan(dataAll));
meanAll = nanmean(dataAll);
stdDevAll = nanstd(dataAll);
titleName = ['WORM AREA/LENGTH (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Area/Length (microns)';
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Area/Length'];
end
resolutions = 0.1;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

%% Show the width/length.

% Show the worm width/length.
subplot(2, 3, 3);
hold on;
data = {worm.morphology.widthPerLength};
titleName = ['WORM WDTH/LENGTH' titlePad];
xAxisName = 'Width/Length (microns)';
dataNames = {'Width/Length'};
resolutions = 0.0005;
histColors = str2colors('k', 0, true);
statColors = str2colors('r', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm width/length.
subplot(2, 3, 6);
hold on;
dataAll = worm.morphology.widthPerLength;
data = cell(length(motionModes),1);
for i = 1:length(motionModes)
    data{i} = dataAll(motionMode == motionModes{i});
end
samplesAll = sum(~isnan(dataAll));
meanAll = nanmean(dataAll);
stdDevAll = nanstd(dataAll);
titleName = ['WORM WIDTH/LENGTH (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Width/Length (unitless measure)';
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Width/Length'];
end
resolutions = 0.0005;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);



%% Save the figure to a file.
saveFile = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    
    % Construct the title.
    figureTitle = 'MORPHOLOGY: AREA';
    if length(varargin) > 1 && ~isempty(varargin{2})
        figureTitle = ['<html><b>Page ' num2str(varargin{2}) ' &rarr; ' ...
            figureTitle '</b></html>'];
    else
        figureTitle = ['<html><b>' figureTitle '</b></html>'];
    end
    
    % Add the title.
    titlePosition = [0, 0, length(figureTitle), 2];
    uicontrol('units', 'characters', 'String', figureTitle, ...
        'Position', titlePosition);

    % Save the figure.
    saveFile = [varargin{1} '_morphology_area.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if length(varargin) < 3 || isempty(varargin{3}) || varargin{3}
        close(h);
    end
end
end
