function [filename pages] = worm2summaryTIF(filename, worm, wormName, ...
    varargin)
%WORM2SUMMARYTIF Save a worm summary to a TIF.
%
%   [FILENAME PAGES] = WORM2SUMMARYTIF(FILENAME, WORM, WORMNAME)
%
%   [FILENAME PAGES] = WORM2SUMMARYTIF(FILENAME, WORM, WORMNAME,
%                                      WORMINFOFILTER, WORMFEATFILTER,
%                                      CONTROL, CONTROLNAME,
%                                      CONTROLINFOFILTER, CONTROLFEATFILTER,
%                                      SIGNIFICANCE, ISSHOW, PAGE,
%                                      SAVEQUALITY, ISCLOSE, ISVERBOSE)
%
%   Inputs:
%       filename          - the TIF filename;
%                           if empty, the file is named
%                           "<wormName> [vs <controlName>].tif"
%       worm              - the worm histograms or filename
%       wormName          - the name for the worm;
%                           or, a function handle of the form:
%
%                   LABEL = WORM2LABEL(WORMINFO)
%
%                           wormInfo = the worm information
%                           label    = the worm label
%
%                           if empty, we use WORM2STRAINLABEL
%
%       wormInfoFilter    - the worm information filtering criteria;
%                           a structure with any of the fields:
%
%              minFPS     = the minimum video frame rate (frames/seconds)
%              minTime    = the minimum video time (seconds)
%              maxTime    = the maximum video time (seconds)
%              minSegTime = the minimum time for segmented video (seconds)
%              minRatio   = the minimum ratio for segmented video frames
%              minDate    = the minimum date to use (DATENUM)
%              maxDate    = the maximum date to use (DATENUM)
%              years      = the years to use
%              months     = the months to use (1-12)
%              weeks      = the weeks to use (1-52)
%              days       = the days (of the week) to use (1-7)
%              hours      = the hours to use (1-24)
%              trackers   = the trackers to use (1-8)
%
%       wormFeatFilter    - the worm feature filtering criteria;
%                           a structure with the fields:
%
%               featuresI = the feature indices (see WORMDATAINFO)
%               minThr    = the minimum feature value (optional)
%               maxThr    = the maximum feature value (optional)
%               indices   = the sub indices for the features (optional)
%               subFields = the subFields for the features (optional)
%
%       control           - the control histograms or filename;
%                           if empty; no control is shown
%       controlName       - the name for the control;
%                           or, a function handle of the form:
%
%                   LABEL = WORM2LABEL(WORMINFO)
%
%                           wormInfo = the worm information
%                           label    = the worm label
%
%                           if empty, we use WORM2STRAINLABEL
%
%       controlInfoFilter - the control indices to use;
%                           or, the control filtering criteria
%       controlFeatFilter - the control feature filtering criteria
%       significance      - the feature statistical significance or filename;
%                           if empty; no statistical significance is shown
%                           if a struct, the fields are:
%
%                           p     = the p-value, per feature
%                           q     = the q-value, per feature
%
%       isShow            - are we showing the figures onscreen?
%                           Note: hiding the figures is faster.
%       page              - the page number;
%                           if empty, the page number is not shown
%       saveQuality       - the quality (magnification) for saving the figures;
%                           if empty, the figures are not saved
%                           the default is none (empty)
%       isClose           - shoud we close the figures after saving them?
%                           when saving the figure, the default is yes (true)
%                           otherwise, the default is no (false)
%       isVerbose         - verbose mode displays the progress;
%                           the default is yes (true)
%   Output:
%       filename - the TIF file containing the saved figures;
%                  if empty, the figures were not saved
%       pages    - the number of pages in the figure file
%
% See also FILTERWORMINFO, FILTERWORMHIST, WORM2HISTOGRAM, WORM2STATSINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Load the worm.
wormInfo = [];
if ischar(worm)
    load(worm, 'worm', 'wormInfo');
end

% Determine the worm name.
if isempty(wormName) && ~isempty(wormInfo)
    wormName = worm2StrainLabel(wormInfo);
elseif isa(wormName, 'function_handle')
    if ~isempty(wormInfo)
        wormName = wormName(wormInfo);
    else
        wormName = '';
    end
end

% Filter the worm information.
isWormUsed = [];
if ~isempty(varargin)
    wormInfoFilter = varargin{1};
    isWormUsed = filterWormInfo(wormInfo, wormInfoFilter);
end

% Filter the worm features.
if length(varargin) > 1
    
    % Filter the worm features.
    wormFeatFilter = varargin{2};
    isUsed = filterWormHist(worm, wormFeatFilter);
    
    % Combine the filters.
    if isempty(isWormUsed)
        isWormUsed = isUsed;
    else
        isWormUsed = isWormUsed & isUsed;
    end
end

% Do we have a control?
control = [];
controlName = [];
isControlUsed = [];
if length(varargin) > 2
    
    % Load the control.
    control = varargin{3};
    controlInfo = [];
    if ~isempty(control) && ischar(control)
        controlData = load(control, 'worm', 'wormInfo');
        control = controlData.worm;
        controlInfo = controlData.wormInfo;
        clear controlData;
    end
    
    % Do we have a control?
    if ~isempty(control)
        
        % Determine the control name.
        if length(varargin) > 3
            controlName = varargin{4};
        end
        if isempty(controlName) && ~isempty(controlInfo)
            controlName = worm2StrainLabel(controlInfo);
        elseif isa(controlName, 'function_handle')
            if ~isempty(controlInfo)
                controlName = controlName(controlInfo);
            else
                controlName = '';
            end
        end
        
        % Filter the control information.
        isControlUsed = [];
        if length(varargin) > 4
            controlInfoFilter = varargin{5};
            isControlUsed = filterWormInfo(controlInfo, controlInfoFilter);
        end
        
        % Filter the control features.
        if length(varargin) > 5
            
            % Filter the worm features.
            controlFeatFilter = varargin{6};
            isUsed = filterWormHist(control, controlFeatFilter);
            
            % Combine the filters.
            if isempty(isControlUsed)
                isControlUsed = isUsed;
            else
                isControlUsed = isControlUsed & isUsed;
            end
        end
    end
end

% Do we have the statistical significance?
sig = [];
if length(varargin) > 6
    significance = varargin{7};
    
    % Load the significance.
    if ~isempty(significance) && ischar(significance)
        
        % Load the significance matrix.
        if ~isempty(whos('-FILE', significance, 'worm'))
            sigData = load(significance, 'worm');
            
            % Find the genotype.
            genotype = worm2GenotypeLabel(wormInfo);
            strainI = find(cellfun(@(x) strcmp(genotype, x), ...
                sigData.worm.info.genotype));
            
            % Determine the significance.
            if length(strainI) == 1
                sig.p = sigData.worm.sig.pWValue(strainI,:);
                sig.q = sigData.worm.sig.qWValue.all(strainI,:);
%                 sig.power = sigData.worm.sig.power(strainI,:);
            end
            
        % Load the strain matrix.
        elseif ~isempty(whos('-FILE', significance, 'significance'))
            sigData = load(significance, 'significance');
            
            % Determine the significance.
            sig.p = [sigData.significance.features.pWValue];
            sig.q = [sigData.significance.features.qWValue];
%             sig.power = [sigData.significance.features.power];
        end
        
    % Determine the significance.
    else
        sig = significance;
    end
end

% Are we showing the figures onscreen?
% Note: hiding the figures is faster.
isShow = true;
if length(varargin) > 7
    isShow = varargin{8};
end

% Determine the page number.
pages = 0;
page = 0;
if length(varargin) > 8
    page = varargin{9};
    pages = page;
end

% Determine the quality (magnification) for saving the figures.
saveQuality = []; % don't save the figures
if length(varargin) > 9
    saveQuality = varargin{10};
end

% Are we closing the figures after saving them?
if saveQuality > 0
    isClose = true;
else
    isClose = false;
end
if length(varargin) > 10
    isClose = varargin{11};
end
if ~isShow
    isClose = true;
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 11
    isVerbose = varargin{12};
end

% Construct the file name.
if saveQuality > 0
    
    % Remove the TIF extension.
    tifExt = '.tif';
    tifName = filename;
    if length(tifName) >= length(tifExt) && ...
            strcmp(filename((end - length(tifExt) + 1):end), tifExt)
        tifName = filename(1:(end - length(tifExt)));
    end
    
    % Create the filename.
    if isempty(tifName)
        if isempty(controlName)
            tifName = [wormName ' summary'];
        else
            tifName = [wormName ' vs ' controlName ' summary'];
        end
    end
    
    % Add the TIF extension.
    filename = [tifName '.tif'];

% We are not saving a file.
else
    filename = [];
end

% Initialize the feature information.
dispInfo = wormDisplayInfo();
dataInfo = wormDataInfo();
statsInfo = wormStatsInfo();
dataInfoField = {dataInfo.field};
statsInfoTitle1I = [statsInfo.title1I];
statsInfoIndex = [statsInfo.index];

% Initialize the color scheme.
statColorScale = 0.6;
controlColor = str2colors('k');
morphologyColor = str2colors('m');
morphologyColors1 = [controlColor; str2colors('m')];
morphologyColors2 = [controlColor; str2colors('p')];
postureColor = str2colors('b');
postureColors1 = [controlColor; str2colors('b')];
postureColors2 = [controlColor; str2colors('c')];
postureColors3 = [controlColor; str2colors('s')];
locomotionColor = str2colors('g', -0.5);
locomotionColors1 = [controlColor; str2colors('g')];
locomotionColors2 = [controlColor; str2colors('g', -0.75)];
locomotionColors3 = [controlColor; str2colors('l')];
locomotionColors4 = [controlColor; str2colors('t')];
pathColor = str2colors('n');
pathColors1 = [controlColor; str2colors('n', 0.25)];
pathColors2 = [controlColor; str2colors('n', -0.25)];

% Initialize special ascii symbols.
semChar = '±';
sepStr = '   ¤   ';

% Initialize the page offset for details.
detailPageOff = page + 3;

% Initialize the histogram logarithm mode.
logMode = 2;

% Construct the page titles.
pageTitle = [];
if saveQuality > 0
    
    % Add the names.
    pageTitle = wormName;
    if ~isempty(controlName)
        pageTitle = ['\it' pageTitle ' vs. ' controlName ' \rm'];
    end

    % Construct the page title.
    pageTitle = [pageTitle sepStr '\bf' ...
        ' ' color2TeX(morphologyColor) 'Morphology\color{black},' ...
        ' ' color2TeX(postureColor) 'Posture\color{black},' ...
        ' ' color2TeX(locomotionColor) 'Motion\color{black},' ...
        ' ' color2TeX(pathColor) 'Path' ...
        ' \color{black}Summary '];
end



%% Draw page 1.

% Display the progress.
if isVerbose
    disp('Printing summary 1/3 ...');
end

% Create a figure.
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);
hold on;

% Draw an example.
subplotHandle = subplot(4,5,1);
drawHistogramExample(subplotHandle);

% Draw the length.
field = 'morphology.length';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = morphologyColors2;
statColors = histColors * statColorScale;
refPage = detailPageOff + 1;
subplot(4,5,6);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, field, [], ...
    histColors, statColors, refPage);

% Draw the width.
field = 'morphology.width';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = [7 2 12];
histColors = morphologyColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 1;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i}];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, refPage + i);
end

% % Draw the area.
% field = 'morphology.area';
% histColors = morphologyColors2;
% statColors = morphologyColors2;
% refPage = detailPageOff + 5;
% subplot(4,5,6);
% drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
%     control, controlName, isControlUsed, ...
%     field, [], histColors, statColors, refPage);

% Draw the track length.
field = 'posture.tracklength';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = postureColors2;
statColors = histColors * statColorScale;
refPage = detailPageOff + 22;
subplot(4,5,11);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, ...
    field, [], histColors, statColors, refPage);

% Draw the amplitude.
field = 'posture.amplitude.max';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = postureColors3;
statColors = histColors * statColorScale;
refPage = detailPageOff + 18;
subplot(4,5,16);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, ...
    field, [], histColors, statColors, refPage);

% Draw the wavelength.
field = 'posture.wavelength.primary';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = postureColors3;
statColors = histColors * statColorScale;
refPage = detailPageOff + 20;
subplot(4,5,17);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, ...
    field, [], histColors, statColors, refPage);

% Draw the head/midbody/tail bend means.
field = 'posture.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 3:5;
histColors = postureColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 6;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i} '.mean'];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, ...
        refPage + 2 * i);
end

% Draw the head/midbody/tail bend standard deviations.
field = 'posture.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 8:10;
histColors = postureColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 11;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i} '.stdDev'];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, refPage + 2 * i);
end

% Draw the head/midbody/tail bend amplitudes.
field = 'locomotion.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 13:15;
histColors = locomotionColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 48;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i} '.amplitude'];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, refPage + i);
end

% Draw the head/midbody/tail bend frequencies.
field = 'locomotion.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 18:20;
histColors = locomotionColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 52;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i} '.frequency'];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, refPage + i, logMode);
end



%% Save page 1.
% Draw the legend.
drawLegend(h);

% Save the figure.
page = page + 1;
if saveQuality > 0
    saveTIF(h, filename, saveQuality, true, pageTitle, page, isClose);

% Close the figure.
elseif ~isShow || isClose
    close(h);
end



%% Draw page 2.

% Display the progress.
if isVerbose
    disp('Printing summary 2/3 ...');
end

% Create a figure.
h = figure;
if isShow
    set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
        'PaperType', 'A2');
else
    set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
        'PaperType', 'A2', 'Visible', 'off');
end
hold on;

% Draw the foraging amplitude.
field = 'locomotion.bends.foraging.amplitude';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = locomotionColors4;
statColors = histColors * statColorScale;
refPage = detailPageOff + 48;
subplot(4,5,1);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, ...
    field, [], histColors, statColors, refPage);

% Draw the foraging speed.
field = 'locomotion.bends.foraging.angleSpeed';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = locomotionColors4;
statColors = histColors * statColorScale;
refPage = detailPageOff + 52;
subplot(4,5,2);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, ...
    field, [], histColors, statColors, refPage, logMode);

% Draw the eigen projections.
field = 'posture.eigenProjection';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
locations = [6:7, 11:12, 16:17];
histColors = postureColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 28;
for i = 1:length(locations)
    
    % Find the info.
    sigI = find(statsInfoTitle1I == featureI & statsInfoIndex == i, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        field, i, histColors, statColors, refPage + i);
end

% Draw the head/midbody/tail speed.
field = 'locomotion.velocity';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 3:5;
histColors = locomotionColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 38;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i} '.speed'];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, refPage + i, logMode);
end

% Draw the head/midbody/tail direction.
field = 'locomotion.velocity';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 8:10;
histColors = locomotionColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 43;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i} '.direction'];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, refPage + i, logMode);
end

% Draw the omega turns time/inter-time/inter-distance.
field = 'locomotion.turns.omegas';
subFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
extraFields = { ...
    [field '.timeRatio'], ...
    [field '.frequency'], ...
    []};
extraFieldNames = { ...
    'TIME(%)', ...
    'FREQ', ...
    []};
isExtraPercent = { ...
    true, ...
    false, ...
    []};
extraSigI = { ...
    sigI + 1, ...
    sigI, ...
    []};
sigI = sigI + 2; % skip the summary statistics
locations = 13:15;
histColors = locomotionColors2;
statColors = histColors * statColorScale;
refPage = detailPageOff + 56;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI + (i - 1) * 4, ...
        [field '.' subFields{i}], [], histColors, statColors, refPage, ...
        logMode, extraFields{i}, extraFieldNames{i}, isExtraPercent{i}, ...
        extraSigI{i});
end

% Draw the upsilon turns time/inter-time/inter-distance.
field = 'locomotion.turns.upsilons';
subFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
extraFields = { ...
    [field '.timeRatio'], ...
    [field '.frequency'], ...
    []};
extraFieldNames = { ...
    'TIME(%)', ...
    'FREQ', ...
    []};
isExtraPercent = { ...
    true, ...
    false, ...
    []};
extraSigI = { ...
    sigI + 1, ...
    sigI, ...
    []};
sigI = sigI + 2; % skip the summary statistics
locations = 18:20;
histColors = locomotionColors3;
statColors = histColors * statColorScale;
refPage = detailPageOff + 57;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI + (i - 1) * 4, ...
        [field '.' subFields{i}], [], histColors, statColors, refPage, ...
        logMode, extraFields{i}, extraFieldNames{i}, isExtraPercent{i}, ...
        extraSigI{i});
end



%% Save page 2.
% Draw the legend.
drawLegend(h);

% Save the figure.
page = page + 1;
if saveQuality > 0
    saveTIF(h, filename, saveQuality, true, pageTitle, page, isClose);

% Close the figure.
elseif ~isShow || isClose
    close(h);
end



%% Draw page 3.

% Display the progress.
if isVerbose
    disp('Printing summary 3/3 ...');
end

% Create a figure.
h = figure;
if isShow
    set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
        'PaperType', 'A2');
else
    set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
        'PaperType', 'A2', 'Visible', 'off');
end
hold on;

% Draw the range.
field = 'path.range';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = pathColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 58;
subplot(4,5,1);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, ...
    field, [], histColors, statColors, refPage, logMode);

% Draw the worm/head/midbody/tail durations.
field = 'path.duration';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = [6, 11, 16];
histColors = pathColors2;
statColors = histColors * statColorScale;
refPage = detailPageOff + 59;
for i = 1:length(subFields)
    
    % Find the info.
    dataField = [field '.' subFields{i}];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI, ...
        dataField, [], histColors, statColors, refPage, logMode);
end

% Draw the kinks.
field = 'posture.kinks';
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
histColors = postureColors2;
statColors = histColors * statColorScale;
refPage = detailPageOff + 24;
subplot(4,5,2);
drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, ...
    field, [], histColors, statColors, refPage);

% Draw the coils time/inter-time/inter-distance.
field = 'posture.coils';
subFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
featureI = find(cellfun(@(x) strcmp(x, field), dataInfoField));
sigI = find(statsInfoTitle1I == featureI, 1);
extraFields = { ...
    [field '.timeRatio'], ...
    [field '.frequency'], ...
    []};
extraFieldNames = { ...
    'TIME(%)', ...
    'FREQ', ...
    []};
isExtraPercent = { ...
    true, ...
    false, ...
    []};
extraSigI = { ...
    sigI + 1, ...
    sigI, ...
    []};
sigI = sigI + 2; % skip the summary statistics
locations = 3:5;
histColors = postureColors1;
statColors = histColors * statColorScale;
refPage = detailPageOff + 25;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, sig, sigI + i - 1, ...
        [field '.' subFields{i}], [], histColors, statColors, refPage, ...
        logMode, extraFields{i}, extraFieldNames{i}, isExtraPercent{i}, ...
        extraSigI{i});
end

% Draw the forward/paused/backward time/distance/inter-time/inter-distance.
field = 'locomotion.motion';
subFields1 = { ...
    'forward', ...
    'paused', ...
    'backward'};
subFields2 = { ...
    'time', ...
    'distance', ...
    'interTime', ...
    'interDistance'};
extraFields = { ...
    'ratio.time', ...
    'ratio.distance', ...
    'frequency', ...
    []};
extraFieldNames = { ...
    'TIME(%)', ...
    'DIST(%)', ...
    'FREQ', ...
    []};
isExtraPercent = { ...
    true, ...
    true, ...
    false, ...
    []};
extraSigOff = { ...
    1, ...
    2, ...
    0, ...
    []};
locations = [7:10, 12:15, 17:20];
histColors = { ...
    locomotionColors3, ...
    locomotionColors1, ...
    locomotionColors2};
statColors = { ...
    histColors{1} * statColorScale, ...
    histColors{2} * statColorScale, ...
    histColors{3} * statColorScale};
refPage = detailPageOff + 34;
for i = 1:length(subFields1)
    
    % Find the info.
    dataField = [field '.' subFields1{i}];
    featureI = find(cellfun(@(x) strcmp(x, dataField), dataInfoField));
    sigI = find(statsInfoTitle1I == featureI, 1);
    
    % Draw the data.
    for j = 1:length(subFields2)
        
        % Assemble the extra field.
        extraField = [];
        if ~isempty(extraFields{j})
            extraField = [field '.' subFields1{i} '.' extraFields{j}];
        end
        
        % Draw the data.
        subplot(4,5,locations((i - 1) * length(subFields2) + j));
        drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
            control, controlName, isControlUsed, sig, sigI + 3 + j - 1, ...
            [dataField  '.' subFields2{j}], [], ...
            histColors{i}, statColors{i}, refPage + i, ...
            logMode, extraField, extraFieldNames{j}, isExtraPercent{j}, ...
            sigI + extraSigOff{j});
    end
end


%% Save page 3.
% Draw the legend.
drawLegend(h);

% Save the figure.
page = page + 1;
if saveQuality > 0
    saveTIF(h, filename, saveQuality, true, pageTitle, page, isClose);

% Close the figure.
elseif ~isShow || isClose
    close(h);
end

% Compute the pages.
pages = page - pages;
end



%% Show the legend.
function drawLegend(h)

% Initialize the drawing information.
fontSize = 18;
black = str2colors('k');
white = str2colors('w');
controlColor = str2colors('k');
morphologyColor = str2colors('m');
postureColor = str2colors('b');
locomotionColor = str2colors('g', -0.5);
pathColor = str2colors('n');

% Setup the label information.
label = {
    ' \bfCONTROL '
    ' \bfMORPHOLOGY '
    ' \bfPOSTURE '
    ' \bfMOTION '
    ' \bfPATH '
    ' \bf****\rm (\itq \leq 0.0001\rm) '
    ' \bf***\rm (\itq \leq 0.001\rm) '
    ' \bf**\rm (\itq \leq 0.01\rm) '
    ' \bf*\rm (\itq \leq 0.05\rm) '
    ' \bfn.s. '};
backColor = {
    controlColor
    morphologyColor
    postureColor
    locomotionColor
    pathColor
    p2BackColor(0.00003)
    p2BackColor(0.0003)
    p2BackColor(0.003)
    p2BackColor(0.03)
    white};
foreColor = {
    white
    white
    white
    white
    white
    black
    black
    black
    black
    black};

% Setup the margin.
xOff = 10^-3;
xPosOff = 1 - xOff;
textPosition = [xPosOff, 0, xOff, 1];
textAxis = axes('units', 'normalized', 'Position', textPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the labels.
yStart = 0.99;
yStart2 = 0.95;
yStart3 = 0.73;
yOff = 0.03;
for i = 1:length(label)
    
    % Draw the label.
    text(xOff, yStart - (i - 1) * yOff, label{i}, ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', backColor{i}, ...
        'Color', foreColor{i}, ...
        'EdgeColor', 'k', ...
        'Parent', textAxis);
    
    % Put in a space.
    if i == 1
        yStart = yStart2 + i * yOff;
    elseif i == 5
        yStart = yStart3 + i * yOff;
    end
end
end



%% Draw a histogram example.
function drawHistogramExample(h)

% Initialize the plot.
set(h, 'Box', 'on');
set(h, 'LineWidth', 1);
%set(h, 'Color', str2colors('r', 0.75));

% Initialize special ascii symbols.
semChar = '±';
sepStr = ' \bf¤\rm ';

% Initialize special text symbols and directives.
titleFont = '\fontsize{12}';
statFont = '\fontsize{10}';
axisFont = '\fontsize{10}';
legendFont = '\fontsize{9}';

% Construct the title text.
titleStr = '\bfFEATURE NAME (D="DORSAL" V="VENTRAL")\rm';
statStr1 = ['\bfM\rm = Mean(X)' sepStr '\bfA\rm = Mean(Abs(X))' sepStr ...
    '\bfP\rm = Mean(X > 0)' sepStr '\bfN\rm = Mean(X < 0)'];
statStr2 = ['\bfExperiment[Control]\rm' sepStr ...
    '\itStatistic=Mean ' semChar 'SEM\rm' sepStr ...
    '\bfBold\rightarrow q \leq 0.05\rm'];
titleName = {[titleFont titleStr ' '], ...
    [statFont statStr1 ' '], [statStr2 ' ']};

% Construct the x-axis label.
xStr = '\bfFeature Units \rm\it(Page # for Details)';
xAxisName = [axisFont xStr];

% Construct the worm histogram.
resolution = 1000;
wormAlpha = 6;
wormBound = 1;
wormMean = 4;
wormStdDev = wormBound / wormAlpha;
wormPDF = gausswin(resolution, wormAlpha)';
wormPDF = wormPDF ./ sum(wormPDF);
wormBins = linspace(wormMean - wormBound, wormMean + wormBound, ...
    resolution);
histData = [nanHistogram(), nanHistogram()];
histData(1).bins = wormBins;
histData(1).PDF = wormPDF;
histData(1).sets.mean.all = wormMean;
histData(1).sets.stdDev.all = wormStdDev;
histData(1).sets.samples = 1;
histData(1).resolution = wormBins(2) - wormBins(1);
histData(1).isZeroBin = true;
histData(1).isSigned = false;

% Construct the control histogram.
resolution = 1000;
wormAlpha = 4;
wormBound = 2;
wormMean = 3;
wormStdDev = wormBound / wormAlpha;
wormPDF = gausswin(resolution, wormAlpha)';
wormPDF = wormPDF ./ sum(wormPDF);
wormBins = linspace(wormMean - wormBound, wormMean + wormBound, ...
    resolution);
histData(2).bins = wormBins;
histData(2).PDF = wormPDF;
histData(2).sets.mean.all = nan;
histData(2).sets.stdDev.all = nan;
histData(2).sets.samples = nan;
histData(2).resolution = wormBins(2) - wormBins(1);
histData(2).isZeroBin = true;
histData(2).isSigned = false;

% Plot the histogram(s).
histColors = str2colors(['n' 'k']);
statColors = histColors * 0.6;
plotHistogram(histData, titleName, xAxisName, [axisFont '\bf'], [], ...
    histColors, statColors, 1, 0, 2, 1);
%ylim([0 1.9]);

% Show the legend.
legendStr = { ...
    [legendFont '\bfExperiment Histogram']
    [legendFont '\bfControl Histogram']
    [legendFont '\bfMean\rm(Absolute(X))']
    [legendFont '\bfSEM']};
legendHandle = legend(legendStr, 'Location', 'NorthWest');
set(legendHandle, 'Box', 'off');
set(gca, 'XTick', 1:5);

% Show the significance.
sigFontSize = 9;
xOff = 1.05;
yOff = 0.0005;
stepY = 0.0007;
text(xOff, yOff + stepY * 3, '\bf q \leq 0.0001 ****', ...
    'FontSize', sigFontSize, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', p2BackColor(0.00005), ...
    'EdgeColor', str2colors('k'));
text(xOff, yOff + stepY * 2, '\bf q \leq 0.001 ***', ...
    'FontSize', sigFontSize, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', p2BackColor(0.0005), ...
    'EdgeColor', str2colors('k'));
text(xOff, yOff + stepY * 1, '\bf q \leq 0.01 **', ...
    'FontSize', sigFontSize, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', p2BackColor(0.005), ...
    'EdgeColor', str2colors('k'));
text(xOff, yOff, '\bf q \leq 0.05 *', ...
    'FontSize', sigFontSize, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', p2BackColor(0.03), ...
    'EdgeColor', str2colors('k'));

% Explain the extra statistics.
% extraStr = {
%     'Extra Title Statistics:'
%     'F = "Frequency" (Hz)'
%     'T = "Time Ratio" (0 to 1)'
%     'D = "Distance Ratio" (0 to 1)'
%     };
% text(1.1, 1, extraStr, ...
%     'HorizontalAlignment', 'left', ...
%     'VerticalAlignment', 'top', ...
%     'BackgroundColor', str2colors('y'), ...
%     'EdgeColor', str2colors('k'));
end



%% Draw a histogram.
%
% varargin:
%
% logMode         - are we using a log plot?
% extraField      - the extra field to show in the title
% extraName       - the name for the extra field to show in the title
% isExtraPercent  - should the extra field be converted to a percent?
% extraSigI       - the significance index for the extra field
function drawHistogram(dispInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, sig, sigI, field, index, ...
    histColors, statColors, refPage, varargin)

% Are we using a log plot?
logMode = [];
if ~isempty(varargin)
    logMode = varargin{1};
end

% Are we showing any extra fields?
extraField = [];
extraName = [];
extraSigI = [];
if length(varargin) > 4
    extraField = varargin{2};
    extraName = varargin{3};
    isExtraPercent = varargin{4};
    extraSigI = varargin{5};
end

% Get the worm histogram data.
data = getStructField(worm, field);
if ~isempty(index)
    data = data(index);
end
wormHist = data.histogram;

% Filter the histogram.
if ~isempty(isWormUsed)
    wormHist = filterHistogram(wormHist, isWormUsed);
end

% Fix the colors.
controlHist = [];
if isempty(control)
    histColors = histColors(end,:);
    statColors = statColors(end,:);

% Get the control histogram data.
else
    data = getStructField(control, field);
    if ~isempty(index)
        data = data(index);
    end
    controlHist = data.histogram;
    
    % Filter the histogram.
    if ~isempty(isControlUsed)
        controlHist = filterHistogram(controlHist, isControlUsed);
    end
end

% Are we showing a page number for the non-summary details?
pageStr = '';
if ~isempty(refPage)
    pageStr = [' \it(Page ' num2str(refPage) ')'];
end

% Initialize special text symbols and directives.
titleFont = '\fontsize{10}';
statFont = '\fontsize{8}';
axisFont = '\fontsize{10}';
tickFontSize = 8;

% Determine the data index.
if isempty(index)
    index = 1;
end

% Determine the figure information.
info = getStructField(dispInfo, field);
fieldName = info(index).name;
fieldUnit = info(index).unit;

% Construct the worm statistics text.
titleName{1} = [titleFont '\bf' upper(fieldName) '\rm '];
[str sigs] = stats2strs(wormHist, controlHist, sig, sigI);
str{1} = [statFont str{1}];
titleName(2:(length(str) + 1)) = str;

% Convert the extra field to a string.
if ~isempty(extraField)
    [titleName{end + 1} sigs(end + 1)] = field2str(worm, isWormUsed, ...
        control, isControlUsed, extraField, extraName, isExtraPercent, ...
        sig, extraSigI);
end

% Construct the x-axis label.
logStr = '';
unitStr = fieldUnit;
if logMode > 1
    logStr = 'Log_{10}';
    unitStr = ['' unitStr ''];
end
xAxisName = [axisFont '\bf' logStr unitStr '\rm' pageStr ' '];

% Plot the histogram(s).
histData = downSampleHistogram([controlHist, wormHist]);
plotHistogram(histData, titleName, xAxisName, [axisFont '\bf'], [], ...
    histColors, statColors, 1, 0, 2, 1, logMode);

% Fix the x-axis ticks.
if ~isempty(tickFontSize)
    set(gca, 'FontSize', tickFontSize);
end

% Color the significance.
minSig = min(sigs);
if ~isnan(minSig)
    set(gca, 'Color', p2BackColor(minSig));
end
end



%% Convert the statistics to strings.
function [str sigs] = stats2strs(worm, control, sig, sigI)

% No data.
if (isempty(worm) || isnan(worm.resolution)) && ...
        (isempty(control) || isnan(control.resolution))
    str = {'NO DATA'};
    sigs = NaN;
    return;
end

% Initialize special ascii symbols.
semChar = '±';
sepStr = ' \bf¤\rm ';

% Initialize the fields.
fields = {
    'all'
    'abs'
    'pos'
    'neg'};
names = {
    'M'
    'A'
    'P'
    'N'};

% Is the feature signed?
if ~isnan(worm.isSigned) && worm.isSigned
    endI = 4;
    meanFormat = '%.0G';
    semFormat = '%.1G';
else
    endI = 1;
    meanFormat = '%.3G';
    semFormat = '%.3G';
end

% Allocate memory.
%str = cell(ceil(endI / 2) + 1, 1);
str = cell(ceil(endI / 2), 1);
sigs = nan(endI, 1);

% % Show the worm samples.
% if isnan(worm.sets.samples)
%     wormsStr = '0';
% else
%     wormsStr = num2str(worm.sets.samples, '%.3G');
% end
% str{1} = ['W=' wormsStr];
% 
% % Show the control samples.
% if ~isempty(control)
%     if isnan(control.sets.samples)
%         controlsStr = '0';
%     else
%         controlsStr = num2str(control.sets.samples, '%.3G');
%     end
%     str{1} = [str{1} '[' controlsStr ']'];
% end
% 
% % Show the total worm samples.
% if isnan(worm.allData.samples)
%     wormsTotalStr = '0';
% else
%     wormsTotalStr = num2str(worm.allData.samples, '%.3G');
% end
% str{1} = [str{1} sepStr 'S=' wormsTotalStr];
% 
% % Show the total control samples.
% if ~isempty(control)
%     if isnan(control.allData.samples)
%         controlsTotalStr = '0';
%     else
%         controlsTotalStr = num2str(control.allData.samples, '%.3G');
%     end
%     str{1} = [str{1} '[' controlsTotalStr ']'];
% end

% Determine the square root of the sample sets.
wormSqrt = sqrt(worm.sets.samples);
if ~isempty(control)
    controlSqrt = sqrt(control.sets.samples);
end

% Convert the statistics to strings.
for i = 1:endI
    
    % Determine the inequality between experiment and control.
    wormMean = worm.sets.mean.(fields{i});
    eqStr = '';
    if ~isempty(control)
        controlMean = control.sets.mean.(fields{i});
        if wormMean > controlMean
            eqStr = '>';
        elseif wormMean < controlMean
            eqStr = '<';
        end
    end
    
    % Don't show the inequality between experiment and control.
    if isempty(sig)
        eqStr = '';
        
    % Determine the significance.
    else
        k = sigI + i - 1;
        sigs(i) = sig.q(k);
        if isnan(sigs(i)) || sigs(i) > 0.05
            eqStr = '';
        end
    end
    
    % Determine the separator string.
    preStr = [];
    if ~mod(i, 2)
        preStr = sepStr;
    end

    % Show the worm statistics.
    if isnan(wormMean)
        dataStr = 'X';
    else
        meanStr = num2str(wormMean, meanFormat);
        semStr = num2str(worm.sets.stdDev.(fields{i}) / wormSqrt, ...
            semFormat);
        dataStr = [meanStr semChar semStr];
    end
    statStr = [names{i} '=' dataStr];
    
    % Show the control statistics.
    if ~isempty(control)
        if isnan(controlMean)
            dataStr = 'X';
        else
            meanStr = num2str(controlMean, meanFormat);
            semStr = num2str(control.sets.stdDev.(fields{i}) / ...
                controlSqrt, semFormat);
            dataStr = [meanStr semChar semStr];
        end
        statStr = [statStr eqStr '[' dataStr ']'];
    end
    
    % Show the significance.
    if sigs(i) <= 0.05
        statStr = ['\bf' statStr '\rm'];
    end
    
    %j = floor((i + 3) / 2);
    j = ceil(i / 2);
    str{j} = [str{j} preStr statStr];
end
end



%% Convert the field statistics to a string.
function [str sigs] = field2str(worm, isWormUsed, ...
    control, isControlUsed, field, name, isPercent, sig, sigI)

% Initialize special ascii symbols.
semChar = '±';

% Show the name.
str = [name '='];

% Get the worm data.
wormData = getStructField(worm, [field '.data']);
if ~isempty(isWormUsed)
    wormData = wormData(isWormUsed);
end
wormMean = mean(wormData);
wormSEM = std(wormData) / sqrt(length(wormData));

% Get the control data.
if ~isempty(control)
    controlData = getStructField(control, [field '.data']);
    if ~isempty(isControlUsed)
        controlData = controlData(isControlUsed);
    end
    controlMean = mean(controlData);
    controlSEM = std(controlData) / sqrt(length(controlData));
end

% Convert the data to percent.
if isPercent
    wormMean = wormMean * 100;
    wormSEM = wormSEM * 100;
    if ~isempty(control)
        controlMean = controlMean * 100;
        controlSEM = controlSEM * 100;
    end
end

% Get the significance.
sigs = NaN;
if ~isempty(sig)
    sigs = sig.q(sigI);
end

% Determine the inequality between experiment and control.
eqStr = '';
if sigs <= 0.05 && ~isempty(control)
    if wormMean > controlMean
        eqStr = '>';
    elseif wormMean < controlMean
        eqStr = '<';
    end
end

% Show the worm statistics.
if isnan(wormMean)
    dataStr = 'X';
else
    meanStr = num2str(wormMean, '%.3G');
    semStr = num2str(wormSEM, '%.3G');
    dataStr = [meanStr semChar semStr];
end
str = [str dataStr];

% Show the control statistics.
if ~isempty(control)
    if isnan(controlMean)
        dataStr = 'X';
    else
        meanStr = num2str(controlMean, '%.3G');
        semStr = num2str(controlSEM, '%.3G');
        dataStr = ['[' meanStr semChar semStr ']'];
    end
str = [str eqStr dataStr];
end

% Show the significance.
if sigs <= 0.05
    str = ['\bf' str '\rm'];
end
end



%% Convert a p-value to a background color representing significance.
function color = p2BackColor(p)

% The p-value is not significant.
color = str2colors('w');

% Determine the significance of the p-value.
if p <= 0.0001
    color = [.9, .8, 1];
elseif p <= 0.001
    color = [1, .8, .8];
elseif p <= 0.01
    color = [1, .9, .7];
elseif p <= 0.05
    color = [1, 1, .7];
end
end
