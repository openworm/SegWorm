function [saveFile pages] = showWormPostureOrientation(worm, varargin)
%SHOWWORMPOSTUREORIENTATION Show the worm posture direction.
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREORIENTATION(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREORIENTATION(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREORIENTATION(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREORIENTATION(WORM, FILEPREFIX, PAGE,
%                                                 ISCLOSE)
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



%% Show the direction.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm direction.
subplot(2, 2, 1);
hold on;
segNames = {
    'head', ...
    'tail2head', ...
    'tail'};
data = cell(length(segNames), 1);
for i = 1:length(segNames)
    data{i} = worm.posture.directions.(segNames{i});
end
dataNames = { ...
    'Head Orientation', ...
    'Tail-to-Head Orientation', ...
    'Tail Orientation'};
samples = sum(~isnan(data{1}));
titleName = ['WORM ORIENTATION (N = ' num2str(samples) ')' titlePad];
xAxisName = 'Orientation (degrees)';
resolutions = .5;
histColors = str2colors('mkc', 0, true);
statColors = str2colors('mkc', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors, 1, 0);

% Show the forward/paused/backward worm width.
dataAll = data;
dataAllNames = dataNames;
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Orientation'];
end
resolutions = .5;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
for i = 1:length(dataAll)
    subplot(2, 2, i + 1);
    hold on;
    data = cell(length(motionModes),1);
    for j = 1:length(motionModes)
        data{j} = dataAll{i}(motionMode == motionModes{j});
    end
    samplesAll = sum(~isnan(dataAll{i}));
    meanAll = nanmean(dataAll{i});
    stdDevAll = nanstd(dataAll{i});
    titleName = ['WORM ' upper(dataAllNames{i}) ...
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
    figureTitle = 'POSTURE: ORIENTATION';
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
    saveFile = [varargin{1} '_posture_orientation.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if length(varargin) < 3 || isempty(varargin{3}) || varargin{3}
        close(h);
    end
end
end
