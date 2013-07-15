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



%% Show the amplitude.

% Create a figure.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;

% Show the worm amplitude.
subplot(2, 3, 1);
hold on;
data = {worm.posture.amplitude.max};
titleName = ['WORM AMPLITUDE' titlePad];
xAxisName = 'Amplitude (microns)';
dataNames = {'Amplitude'};
resolutions = 5;
histColors = str2colors('k', 0, true);
statColors = str2colors('r', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm amplitude.
subplot(2, 3, 4);
hold on;
dataAll = worm.posture.amplitude.max;
data = cell(length(motionModes), 1);
for i = 1:length(motionModes)
    data{i} = dataAll(motionMode == motionModes{i});
end
samplesAll = sum(~isnan(dataAll));
meanAll = nanmean(dataAll);
stdDevAll = nanstd(dataAll);
titleName = ['WORM AMPLITUDE (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Amplitude (microns)';
dataNames = cell(length(motionModes),1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Amplitude'];
end
resolutions = 5;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);



%% Show the wavelengths.

% Show the worm primary wavelength.
subplot(2, 3, 2);
hold on;
maxWavelength = worm.morphology.length * 2;
primaryWavelength = worm.posture.wavelength.primary;
wrap = primaryWavelength > maxWavelength;
primaryWavelength(wrap) = maxWavelength(wrap);
data = {primaryWavelength};
titleName = ['WORM PRIMARY WAVELENGTH' titlePad];
xAxisName = 'Wavelength (microns)';
dataNames = {'Wavelength'};
resolutions = 25;
histColors = str2colors('k', 0, true);
statColors = str2colors('r', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm primary wavelength.
subplot(2, 3, 5);
hold on;
dataAll = primaryWavelength;
data = cell(length(motionModes), 1);
for i = 1:length(motionModes)
    data{i} = dataAll(motionMode == motionModes{i});
end
samplesAll = sum(~isnan(dataAll));
meanAll = nanmean(dataAll);
stdDevAll = nanstd(dataAll);
titleName = ['WORM PRIMARY WAVELENGTH (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Wavelength (microns)';
dataNames = cell(length(motionModes), 1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Wavelength'];
end
resolutions = 25;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the worm secondary wavelength.
subplot(2, 3, 3);
hold on;
secondaryWavelength = worm.posture.wavelength.secondary;
wrap = secondaryWavelength > maxWavelength;
secondaryWavelength(wrap) = maxWavelength(wrap);
data = {secondaryWavelength};
titleName = ['WORM SECONDARY WAVELENGTH' titlePad];
xAxisName = 'Wavelength (microns)';
dataNames = {'Wavelength'};
resolutions = 5;
histColors = str2colors('k', 0, true);
statColors = str2colors('r', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);

% Show the forward/paused/backward worm secondary wavelength.
subplot(2, 3, 6);
hold on;
dataAll = secondaryWavelength;
dataAll(dataAll == -inf) = NaN;
dataAll(dataAll == inf) = NaN;
data = cell(length(motionModes), 1);
for i = 1:length(motionModes)
    data{i} = dataAll(motionMode == motionModes{i});
end
samplesAll = sum(~isnan(dataAll));
meanAll = nanmean(dataAll);
stdDevAll = nanstd(dataAll);
titleName = ['WORM SECONDARY WAVELENGTH (N = ' num2str(samplesAll) ...
    ', MEAN = ' num2str(meanAll) ...
    ', S.D. = ' num2str(stdDevAll) ')' titlePad];
xAxisName = 'Wavelength (microns)';
dataNames = cell(length(motionModes), 1);
for i = 1:length(motionModes)
    dataNames{i} = [motionNames{i} ' Wavelength'];
end
resolutions = 5;
histColors = str2colors('rkb', 0, true);
statColors = str2colors('rkb', -0.1, true);
plotHistogram(data, resolutions, titleName, xAxisName, dataNames, ...
    histColors, statColors);



%% Save the figure to a file.
saveFile = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    
    % Construct the title.
    figureTitle = 'POSTURE: AMPLITUDE AND WAVELENGTH';
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
    saveFile = [varargin{1} '_posture_wave1.pdf'];
    saveFigure(h, saveFile);
    
    % Close the figure.
    if length(varargin) < 3 || isempty(varargin{3}) || varargin{3}
        close(h);
    end
end
end
