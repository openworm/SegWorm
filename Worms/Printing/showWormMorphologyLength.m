function [saveFile pages] = showWormMorphologyLength(worm, varargin)
%SHOWWORMMORPHOLOGYLENGTHWIDTH Show the worm length morphology.
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTH(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTH(WORM, WORMNAME)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTH(WORM, WORMNAME, CONTROL)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTH(WORM, WORMNAME, CONTROL,
%                                               CONTROLNAME)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTH(WORM, WORMNAME, CONTROL,
%                                               CONTROLNAME, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTH(WORM, WORMNAME, CONTROL,
%                                               CONTROLNAME, FILEPREFIX,
%                                               PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTH(WORM, WORMNAME, CONTROL,
%                                               CONTROLNAME, FILEPREFIX,
%                                               PAGE, ISCLOSE)
%
%   Inputs:
%       worm        - the worm(s) to show
%       wormName    - the name for the worm;
%                     if empty, the worm figures are named "worm"
%       control     - the control worm(s);
%                     if empty, no control is shown
%       controlName - the name for the control;
%                     if empty, the control figures are named "control"
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

% Organize the worm data.
if iscell(worm)
    wormData = cellfun(@(x) x.morphology.length, worm, ...
        'UniformOutput', false);
else
    wormData = worm.morphology.length;
    worm = {worm};
end

% Determine the worm name.
wormName = 'WORM';
if ~isempty(varargin) && ~isempty(varargin{1})
    wormName = upper(varargin{1});
end

% Are we showing a control?
control = [];
controlData = [];
if length(varargin) > 1 && ~isempty(varargin{2})
    
    % Organize the control data.
    control = varargin{2};
    if iscell(control)
        controlData = cellfun(@(x) x.morphology.length, varargin{2}, ...
            'UniformOutput', false);
    else
        controlData = control.morphology.length;
        control = {control};
    end
    
    % Determine the control name.
    controlName = 'CONTROL';
    if length(varargin) > 2
        controlName = upper(varargin{3});
    end
end

% Pad the title when saving the figure.
% Note: Matlab has a bug that cuts off the title when saving figures.
filePrefix = [];
pages = 0;
titlePad = [];
if length(varargin) > 3 && ~isempty(varargin{4})
    filePrefix = varargin{4};
    pages = 1;
    titlePad = '          ';
    
    % Determine the page number.
    page = [];
    if length(varargin) > 4
        page = varargin{5};
    end
    
    % Are we closing the figure after saving it?
    isClose = true;
    if length(varargin) > 5
        isClose = varargin{6};
    end
end

% Determine the locomotion modes.
motionModes = { ...
    1, ...
    0, ...
    -1};
motionNames = { ...
    'Forward', ...
    'Paused', ...
    'Backward'};



%% Show the worm length.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm length.
if isempty(controlData)
    subplot(1, 2, 1);
else
    subplot(2, 2, 1);
end
hold on;
resolutions = 2;
histData = histogram(wormData, resolutions);
titleName = [wormName ' LENGTH' titlePad];
xAxisName = 'Length (microns)';
dataNames = {'Length'};
histColors = str2colors('k', 0);
statColors = str2colors('r', -0.1);
plotHistogram(histData, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm length.
if isempty(controlData)
    subplot(1, 2, 2);
else
    subplot(2, 2, 2);
end
hold on;
samplesAll = histData.allData.samples;
meanAll = histData.allData.mean;
stdDevAll = histData.allData.stdDev;
histData(1:end) = [];
for i = 1:length(motionModes)
    motionData = cell(length(worm), 1);
    for j = 1:length(worm)
        dataAll = wormData{j};
        motionData{j} = ...
            dataAll(worm{j}.locomotion.motion.mode == motionModes{i});
    end
    histData(i) = histogram(motionData, resolutions);
end
titleName = [wormName ' LENGTH (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Length (microns)';
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Length'];
end
histColors = str2colors('rkb', 0);
statColors = str2colors('rkb', -0.1);
plotHistogram(histData, titleName, xAxisName, dataNames, ...
    histColors, statColors);



%% Show the control length.
if ~isempty(controlData)

% Show the control length.
subplot(2, 2, 3);
hold on;
resolutions = 2;
histData = histogram(controlData, resolutions);
titleName = [controlName ' LENGTH' titlePad];
xAxisName = 'Length (microns)';
dataNames = {'Length'};
histColors = str2colors('k', 0);
statColors = str2colors('r', -0.1);
plotHistogram(histData, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward control length.
subplot(2, 2, 4);
hold on;
samplesAll = histData.allData.samples;
meanAll = histData.allData.mean;
stdDevAll = histData.allData.stdDev;
histData(1:end) = [];
for i = 1:length(motionModes)
    motionData = cell(length(control), 1);
    for j = 1:length(control)
        dataAll = controlData{j};
        motionData{j} = ...
            dataAll(control{j}.locomotion.motion.mode == motionModes{i});
    end
    histData(i) = histogram(motionData, resolutions);
end
titleName = [controlName ' LENGTH (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Length (microns)';
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Length'];
end
histColors = str2colors('rkb', 0);
statColors = str2colors('rkb', -0.1);
plotHistogram(histData, titleName, xAxisName, dataNames, ...
    histColors, statColors);
end



%% Save the figure to a file.
saveFile = [];
if ~isempty(filePrefix)
    
    % Construct the title.
    figureTitle = 'MORPHOLOGY: LENGTH';
    if ~isempty(page)
        figureTitle = ['<html><b>Page ' num2str(page) ' &rarr; ' ...
            figureTitle '</b></html>'];
    else
        figureTitle = ['<html><b>' figureTitle '</b></html>'];
    end
    
    % Add the title.
    titlePosition = [0, 0, length(figureTitle), 2];
    uicontrol('units', 'characters', 'String', figureTitle, ...
        'Position', titlePosition);

    % Save the figure.
    saveFile = [filePrefix '_morphology_length_width.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if isClose
        close(h);
    end
end
end
