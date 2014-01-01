function [saveFile pages] = showWormPostureEigens2(worm, varargin)
%SHOWWORMPOSTUREEIGENS2 Show the eigenworms 4-6 posture projections.
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREEIGENS2(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREEIGENS2(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREEIGENS2(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREEIGENS2(WORM, FILEPREFIX, PAGE, ISCLOSE)
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



%% Show the eigenworm projections.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the eigenworm projections.
for i = 4:6
    
    % Show the eigenworm projections.
    subplot(2, 3, i - 3);
    hold on;
    data = worm.posture.eigenProjection(i,:);
    dataNames = 'Eigenworm Projection';
    samples = sum(~isnan(data));
    titleName = [upper(dataNames) ' ' num2str(i) ...
        ' (N = ' num2str(samples) ')' titlePad];
    xAxisName = [dataNames ' ' num2str(i) ' (unitless measure)'];
    resolutions = 0.1;
    histColors = str2colors('k', 0, true);
    statColors = str2colors('r', -0.1, true);
    plotHistogram({data}, resolutions, titleName, xAxisName, ...
        {dataNames}, histColors, statColors);
    
    % Show the forward/paused/backward eigenworm projections.
    dataAll = data;
    dataAllNames = dataNames;
    dataNames = cell(length(motionModes), 1);
    for j = 1:length(motionModes)
        dataNames{j} = [motionNames{j} ' Projection'];
    end
    resolutions = 0.1;
    histColors = str2colors('rkb', 0, true);
    statColors = str2colors('rkb', -0.1, true);
    subplot(2, 3, i);
    hold on;
    data = cell(length(motionModes), 1);
    for j = 1:length(motionModes)
        data{j} = dataAll(motionMode == motionModes{j});
    end
    samplesAll = sum(~isnan(dataAll));
    meanAll = nanmean(dataAll);
    stdDevAll = nanstd(dataAll);
    titleName = [upper(dataAllNames) ' ' num2str(i) ...
        ' (N = ' num2str(samplesAll) ...
        ', MEAN = ' num2str(meanAll) ...
        ', S.D. = ' num2str(stdDevAll) ')' titlePad];
    plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
        histColors, statColors);
end



%% Save the figure to a file.
saveFile = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    
    % Construct the title.
    figureTitle = 'POSTURE: EIGENWORM PROJECTIONS 4-6';
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

    saveFile = [varargin{1} '_posture_eigens2.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if length(varargin) < 3 || isempty(varargin{3}) || varargin{3}
        close(h);
    end
end
end
