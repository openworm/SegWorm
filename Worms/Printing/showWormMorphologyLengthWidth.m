function [saveFile pages] = showWormMorphologyLengthWidth(worm, varargin)
%SHOWWORMMORPHOLOGYLENGTHWIDTH Show the worm length and width morphology.
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTHWIDTH(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTHWIDTH(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTHWIDTH(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGYLENGTHWIDTH(WORM, FILEPREFIX, PAGE,
%                                                    ISCLOSE)
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



%% Show the length.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm length.
subplot(2, 3, 1);
hold on;
resolutions = 2;
histData = histogram(worm.morphology.length, resolutions);
titleName = ['WORM LENGTH' titlePad];
xAxisName = 'Length (microns)';
dataNames = {'Length'};
histColors = str2colors('k', 0);
statColors = str2colors('r', -0.1);
plotHistogram(histData, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm length.
subplot(2, 3, 4);
hold on;
samplesAll = histData.allData.samples;
meanAll = histData.allData.mean;
stdDevAll = histData.allData.stdDev;
dataAll = worm.morphology.length;
histData(1:end) = [];
for i = 1:length(motionModes)
    histData(i) = histogram(dataAll(motionMode == motionModes{i}), ...
        resolutions);
end
titleName = ['WORM LENGTH (N = ' num2str(samplesAll) ...
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



%% Show the width.

% Show the worm width.
subplot(2, 3, 2);
hold on;
segNames = {
    'head', ...
    'midbody', ...
    'tail'};
resolutions = .5;
histData(1:end) = [];
dataNames = cell(length(segNames), 1);
for i = 1:length(segNames)
    histData(i) = histogram(worm.morphology.width.(segNames{i}), ...
        resolutions);
    dataNames{i} = [upper(segNames{i}(1)) segNames{i}(2:end) ' Width'];
end
samples = histData(1).allData.samples;
titleName = ['WORM WIDTH (N = ' num2str(samples) ')' titlePad];
xAxisName = 'Width (microns)';
histColors = str2colors('mkc', 0);
statColors = str2colors('mkc', -0.1);
plotHistogram(histData, titleName, xAxisName, dataNames, ...
    histColors, statColors, 1, 0);

% Show the forward/paused/backward worm width.
histDataAll = histData;
dataAllNames = dataNames;
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Width'];
end
locations = {
    3, ...
    5, ...
    6};
resolutions = .5;
histColors = str2colors('rkb', 0);
statColors = str2colors('rkb', -0.1);
for i = 1:length(segNames)
    subplot(2, 3, locations{i});
    hold on;
    histData(1:end) = [];
    for j = 1:length(motionModes)
        data = worm.morphology.width.(segNames{i});
        histData(j) = histogram(data(motionMode == motionModes{j}), ...
            resolutions);
    end
    samplesAll = histDataAll(i).allData.samples;
    meanAll = histDataAll(i).allData.mean;
    stdDevAll = histDataAll(i).allData.stdDev;
    titleName = ['WORM ' upper(dataAllNames{i}) ....
        ' (N = ' num2str(samplesAll) ...
        ', MEAN = ' num2str(meanAll) ...
        ', S.D. = ' num2str(stdDevAll) ')' titlePad];
    xAxisName = [dataAllNames{i} ' (microns)'];
    plotHistogram(histData, titleName, xAxisName, dataNames, ...
        histColors, statColors);
end



%% Save the figure to a file.
saveFile = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    
    % Construct the title.
    figureTitle = 'MORPHOLOGY: LENGTH AND WIDTH';
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
    saveFile = [varargin{1} '_morphology_length_width.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if length(varargin) < 3 || isempty(varargin{3}) || varargin{3}
        close(h);
    end
end
end
