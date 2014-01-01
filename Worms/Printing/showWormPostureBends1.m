function [saveFile pages] = showWormPostureBends1(worm, varargin)
%SHOWWORMPOSTUREBENDS1 Show the worm bends mean posture.
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREBENDS1(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREBENDS1(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREBENDS1(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREBENDS1(WORM, FILEPREFIX, PAGE,
%                                            ISCLOSE)
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
%   See WORMORGANIZATION, SHOWORMPOSTURE
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



%% Show the mean bends.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm mean bends.
subplot(2, 3, 1);
hold on;
segNames = {
    'head', ...
    'neck', ...
    'midbody', ...
    'hips', ...
    'tail'};
data = cell(length(segNames), 1);
dataNames = cell(length(segNames), 1);
for i = 1:length(segNames)
    data{i} = worm.posture.bends.(segNames{i}).mean;
    dataNames{i} = [upper(segNames{i}(1)) segNames{i}(2:end) ' Mean Bends'];
end
samples = sum(~isnan(data{1}));
titleName = ['WORM MEAN BENDS (N = ' num2str(samples) ')' titlePad];
xAxisName = 'Mean Bends (degrees)';
resolutions = 1;
histColors = str2colors('rrgbb', [-0.1, 2/3, -0.1, 2/3, -0.1], true);
statColors = [];
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors, 2, 1);

% Show the forward/paused/backward worm mean bends.
dataAll = data;
dataAllNames = dataNames;
dataNames = cell(length(motionModes), 1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Mean Bends'];
end
locations = {
    2, ...
    5, ...
    4, ...
    6, ...
    3};
resolutions = 1;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
for i = 1:length(dataAll)
    subplot(2, 3, locations{i});
    hold on;
    data = cell(length(motionModes), 1);
    for j = 1:length(motionModes)
        data{j} = dataAll{i}(motionMode == motionModes{j});
    end
    samplesAll = sum(~isnan(dataAll{i}));
    meanAll = nanmean(dataAll{i});
    stdDevAll = nanstd(dataAll{i});
    titleName = ['WORM ' upper(dataAllNames{i}) ....
        ' (N = ' num2str(samplesAll) ...
        ', MEAN = ' num2str(meanAll) ...
        ', S.D. = ' num2str(stdDevAll) ')' titlePad];
    xAxisName = [dataAllNames{i} ' (degrees)'];
    plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
        histColors, statColors);
end



%% Save the figure to a file.
saveFile = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    
    % Construct the title.
    figureTitle = 'POSTURE: MEAN BENDS';
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

    saveFile = [varargin{1} '_posture_bends1.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if length(varargin) < 3 || isempty(varargin{3}) || varargin{3}
        close(h);
    end
end
end
