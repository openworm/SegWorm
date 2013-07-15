function [saveFile pages] = showWormPostureWave1(worm, varargin)
%SHOWWORMPOSTUREWAVE1 Show the worm amplitude and wavelength posture.
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREWAVE1(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREWAVE1(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREWAVE1(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTUREWAVE1(WORM, FILEPREFIX, PAGE, ISCLOSE)
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



%% Show the coils.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm coiled times.
subplot(2, 3, 1);
hold on;
data = {[worm.posture.coils.frames.time]};
dataNames = 'Coiled Time';
titleName = {['WORM ' upper(dataNames) titlePad], ...
    ['Frequency = ' num2str(worm.posture.coils.frequency) ' Hz' ...
    titlePad], ...
    ['Ratio = ' num2str(worm.posture.coils.timeRatio) ' Time/Total' ...
    titlePad]};
xAxisName = [dataNames ' (seconds)'];
resolutions = [];
histColors = str2colors('g', 0, true);
statColors = str2colors('k', 0, true);
plotHistogram(data, resolutions, titleName, xAxisName, {dataNames}, ...
    histColors, statColors, 3, 2, true);

% Show the worm not coiled times.
subplot(2, 3, 4);
hold on;
data = {[worm.posture.coils.frames.interTime]};
dataNames = 'Not Coiled Time';
titleName = ['WORM ' upper(dataNames) titlePad];
xAxisName = [dataNames ' (seconds)'];
resolutions = [];
histColors = str2colors('r', 0, true);
statColors = str2colors('k', 0, true);
plotHistogram(data, resolutions, titleName, xAxisName, {dataNames}, ...
    histColors, statColors, 3, 2, true);

% Show the worm not coiled distances.
subplot(2, 3, 2);
hold on;
data = {[worm.posture.coils.frames.interDistance]};
dataNames = 'Not Coiled Distance';
titleName = ['WORM ' upper(dataNames) titlePad];
xAxisName = [dataNames ' (microns)'];
resolutions = [];
histColors = str2colors('r', 0, true);
statColors = str2colors('k', 0, true);
plotHistogram(data, resolutions, titleName, xAxisName, {dataNames}, ...
    histColors, statColors, 3, 2, true);



%% Show the kinks.

% Show the worm kinks.
subplot(2, 3, 3);
hold on;
data = {worm.posture.kinks};
titleName = ['WORM KINKS' titlePad];
xAxisName = 'Kinks (count)';
dataNames = {'Kinks'};
resolutions = 1;
histColors = str2colors('k', 0.25, true);
statColors = str2colors('r', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors, 3, 2, true);

% Show the forward/paused/backward worm amplitude.
subplot(2, 3, 6);
hold on;
dataAll = worm.posture.kinks;
data = cell(length(motionModes), 1);
for i = 1:length(motionModes)
    data{i} = dataAll(motionMode == motionModes{i});
end
samplesAll = sum(~isnan(dataAll));
meanAll = nanmean(dataAll);
stdDevAll = nanstd(dataAll);
titleName = ['WORM KINKS (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Kinks (count)';
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Kinks'];
end
resolutions = 1;
histColors = str2colors('rkb', [0, 0.25, 0], true);
statColors = str2colors('rkb', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors, 3, 2, true);



%% Save the figure to a file.
saveFile = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    
    % Construct the title.
    figureTitle = 'POSTURE: COILS AND KINKS';
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
    saveFile = [varargin{1} '_posture_coils_kinks.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if length(varargin) < 3 || isempty(varargin{3}) || varargin{3}
        close(h);
    end
end
end
