function [filename pages] = worm2summaryPDF(filename, worm, wormName, ...
    varargin)
%WORM2SUMMARYPDF Save a worm summary to a PDF.
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME)
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME, WORMFILTER)
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME, WORMFILTER,
%                                      CONTROL, CONTROLNAME)
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME, WORMFILTER,
%                                      CONTROL, CONTROLNAME, CONTROLFILTER)
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME,
%                                      CONTROL, CONTROLNAME, CONTROLFILTER,
%                                      ISSHOW)
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME,
%                                      CONTROL, CONTROLNAME, CONTROLFILTER,
%                                      ISSHOW, PAGE)
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME,
%                                      CONTROL, CONTROLNAME, CONTROLFILTER,
%                                      ISSHOW, PAGE, ISSAVE)
%
%   [FILENAME PAGES] = WORM2SUMMARYPDF(FILENAME, WORM, WORMNAME,
%                                      CONTROL, CONTROLNAME, CONTROLFILTER,
%                                      ISSHOW, PAGE, ISSAVE, ISCLOSE)
%
%   Inputs:
%       filename      - the PDF filename;
%                       if empty, the file is named
%                       "<wormName> [vs <controlName>].pdf"
%       worm          - the worm histograms or filename
%       wormName      - the name for the worm;
%                       or, a function handle of the form:
%
%                       LABEL = WORM2LABEL(WORMINFO)
%
%                       wormInfo = the worm information
%                       label    = the worm label
%
%                       if empty, we use WORM2STRAINLABEL
%
%       wormFilter    - the worms indices to use;
%                       or, the worm filtering criteria;
%                       a structure with any of the fields:
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
%       control       - the control histograms or filename;
%                       if empty; no control is shown
%       controlName   - the name for the control;
%                       or, a function handle of the form:
%
%                       LABEL = WORM2LABEL(WORMINFO)
%
%                       wormInfo = the worm information
%                       label    = the worm label
%
%                       if empty, we use WORM2STRAINLABEL
%       controlFilter - the control indices to use;
%                       or, the control filtering criteria
%       isShow        - are we showing the figures onscreen?
%                       Note: hiding the figures is faster.
%       page          - the page number;
%                       if empty, the page number is not shown
%       isSave        - are we saving the figures?
%       isClose       - shoud we close the figures after saving them?
%                       when saving the figure, the default is yes (true)
%                       otherwise, the default is no (false)
%
%   Output:
%       filename - the PDF file containing the saved figures;
%                  if empty, the figures were not saved
%       pages    - the number of pages in the figure file
%
% See also FILTERWORMINFO, WORM2HISTOGRAM, WORMDISPLAYINFO
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

% Which worms should we use?
isWormUsed = [];
if ~isempty(varargin)
    wormFilter = varargin{1};
    
    % Use the specified indices.
    if isnumeric(wormFilter)
        isWormUsed = wormFilter;
        
    % Filter the worms.
    elseif isstruct(wormFilter) && ~isempty(wormInfo)
        isWormUsed = filterWormInfo(wormInfo, wormFilter);
    end
end

% Do we have a control?
control = [];
controlName = [];
if length(varargin) > 2
    control = varargin{2};
    controlName = varargin{3};
    
    % Load the control.
    controlInfo = [];
    if ischar(control)
        controlData = load(control, 'worm', 'wormInfo');
        control = controlData.worm;
        controlInfo = controlData.wormInfo;
        clear controlData;
    end
    
    % Determine the control name.
    if isempty(controlName) && ~isempty(controlInfo)
        controlName = worm2StrainLabel(controlInfo);
    elseif isa(controlName, 'function_handle')
        if ~isempty(controlInfo)
            controlName = controlName(controlInfo);
        else
            controlName = '';
        end
    end
    
    % Which controls should we use?
    isControlUsed = [];
    if length(varargin) > 3
        controlFilter = varargin{4};
        
        % Use the specified indices.
        if isnumeric(controlFilter)
            isControlUsed = controlFilter;
            
        % Filter the controls.
        elseif isstruct(controlFilter) && ~isempty(controlInfo)
            isControlUsed = filterWormInfo(controlInfo, controlFilter);
        end
    end
end

% Are we showing the figures onscreen?
% Note: hiding the figures is faster.
isShow = true;
if length(varargin) > 4
    isShow = varargin{5};
end

% Determine the page number.
pages = 0;
page = [];
if length(varargin) > 5
    page = varargin{6};
end

% Are we saving the figures?
isSave = true;
if length(varargin) > 6
    isSave = varargin{7};
end

% Are we closing the figures after saving them?
if isSave
    isClose = true;
else
    isClose = false;
end
if length(varargin) > 7
    isClose = varargin{8};
end

% Construct the file name.
if isempty(filename)
    if isempty(controlName)
        pdfName = [wormName ' summary'];
    else
        pdfName = [wormName ' vs ' controlName ' summary'];
    end
else
    pdfName = strrep(filename, '.pdf', '');
end
filename = [];
if isSave
    filename = [pdfName '.pdf'];
end

% Initialize the pages.
pdfPageNum = 1;
pdfPages = [];

% Initialize the color scheme.
controlColor = 'k';
morphologyHistColors1 = str2colors(['g' controlColor]);
morphologyStatColors1 = str2colors(['g' controlColor], -0.1);
morphologyHistColors2 = str2colors(['l' controlColor]);
morphologyStatColors2 = str2colors(['l' controlColor], -0.1);
morphologyHistColors3 = str2colors(['g' controlColor], [0.5, 0]);
morphologyStatColors3 = str2colors(['g' controlColor], [0.4, -0.1]);
postureHistColors1 = str2colors(['r' controlColor]);
postureStatColors1 = str2colors(['r' controlColor], -0.1);
postureHistColors2 = str2colors(['m' controlColor]);
postureStatColors2 = str2colors(['m' controlColor], -0.1);
postureHistColors3 = str2colors(['r' controlColor], [0.5, 0]);
postureStatColors3 = str2colors(['r' controlColor], [0.4, -0.1]);
locomotionHistColors1 = str2colors(['b' controlColor]);
locomotionStatColors1 = str2colors(['b' controlColor], -0.1);
locomotionHistColors2 = str2colors(['c' controlColor]);
locomotionStatColors2 = str2colors(['c' controlColor], -0.1);
locomotionHistColors3 = str2colors(['s' controlColor]);
locomotionStatColors3 = str2colors(['s' controlColor], -0.1);
locomotionHistColors4 = str2colors(['b' controlColor], [0.5, 0]);
locomotionStatColors4 = str2colors(['b' controlColor], [0.4, -0.1]);
pathHistColors1 = str2colors(['y' controlColor]);
pathStatColors1 = str2colors(['y' controlColor], -0.1);
pathHistColors2 = str2colors(['o' controlColor]);
pathStatColors2 = str2colors(['o' controlColor], -0.1);

% Initialize special ascii symbols.
stdDevChar = 177;

% Construct the page titles.
pageTitle = [];
if isSave
    
    % Convert the colors to hex.
    morphologyTextColors = colors2hex(morphologyHistColors1(1,:));
    postureTextColors = colors2hex(postureHistColors1(1,:));
    locomotionTextColors = colors2hex(locomotionHistColors1(1,:));
    pathTextColors = colors2hex(pathHistColors2(1,:));
    
    % Construct the page title prefix.
    if isempty(controlName)
        wormStr = wormName;
    else
        wormStr = [wormName ' vs ' controlName];
    end
    
    % Construct the page title.
    pageTitle = [wormStr ...
        ' <FONT COLOR="' morphologyTextColors '"> Morphology</FONT>,' ...
        ' <FONT COLOR="' postureTextColors '"> Posture</FONT>,' ...
        ' <FONT COLOR="' locomotionTextColors '"> Locomotion</FONT>,' ...
        ' <FONT COLOR="' pathTextColors '"> Path</FONT> Summary'];
end

% Get the display information.
displayInfo = wormDisplayInfo();



%% Draw page 1.

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

% Draw an example.
subplotHandle = subplot(4,5,1);
drawHistogramExample(subplotHandle, isSave);

% Draw the length.
field = 'morphology.length';
histColors = morphologyHistColors3;
statColors = morphologyStatColors3;
subplot(4,5,6);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors);

% Draw the width.
field = 'morphology.width';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = [7 2 12];
histColors = morphologyHistColors1;
statColors = morphologyStatColors1;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i}], [], isSave, histColors, statColors);
end

% % Draw the area.
% field = 'morphology.area';
% histColors = morphologyHistColors2;
% statColors = morphologyStatColors2;
% subplot(4,5,6);
% drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
%     control, controlName, isControlUsed, ...
%     field, [], isSave, histColors, statColors);

% Draw the track length.
field = 'posture.tracklength';
histColors = postureHistColors2;
statColors = postureStatColors2;
subplot(4,5,11);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors);

% Draw the amplitude.
field = 'posture.amplitude.max';
histColors = postureHistColors3;
statColors = postureStatColors3;
subplot(4,5,16);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors);

% Draw the wavelength.
field = 'posture.wavelength.primary';
histColors = postureHistColors3;
statColors = postureStatColors3;
subplot(4,5,17);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors);

% Draw the head/midbody/tail bend means.
field = 'posture.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 3:5;
histColors = postureHistColors1;
statColors = postureStatColors1;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i} '.mean'], [], isSave, histColors, ...
        statColors, 1, 1);
end

% Draw the head/midbody/tail bend standard deviations.
field = 'posture.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 8:10;
histColors = postureHistColors1;
statColors = postureStatColors1;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i} '.stdDev'], [], isSave, histColors, ...
        statColors, 1, 1);
end

% Draw the head/midbody/tail bend amplitudes.
field = 'locomotion.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 13:15;
histColors = locomotionHistColors1;
statColors = locomotionStatColors1;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i} '.amplitude'], [], isSave, histColors, ...
        statColors, 1, 1);
end

% Draw the head/midbody/tail bend frequencies.
field = 'locomotion.bends';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 18:20;
histColors = locomotionHistColors1;
statColors = locomotionStatColors1;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i} '.frequency'], [], isSave, histColors, ...
        statColors, 1, 1, true);
end



%% Save page 1.
if isSave
    pdfPages{pdfPageNum} = [pdfName ' ' num2str(pdfPageNum) '.pdf'];
    savePDF(h, pdfPages{pdfPageNum}, pageTitle, page, isClose);
    page = page + 1;
    pdfPageNum = pdfPageNum + 1;
elseif isClose
    close(h);
end



%% Draw page 2.

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
histColors = locomotionHistColors2;
statColors = locomotionStatColors2;
subplot(4,5,1);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors, 1, 1);

% Draw the foraging speed.
field = 'locomotion.bends.foraging.angleSpeed';
histColors = locomotionHistColors2;
statColors = locomotionStatColors2;
subplot(4,5,2);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors, 1, 1, true);

% Draw the eigen projections.
field = 'posture.eigenProjection';
locations = [6:7, 11:12, 16:17];
histColors = postureHistColors1;
statColors = postureStatColors1;
for i = 1:length(locations)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        field, i, isSave, histColors, statColors);
end

% Draw the head/midbody/tail speed.
field = 'locomotion.velocity';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 3:5;
histColors = locomotionHistColors3;
statColors = locomotionStatColors3;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i} '.speed'], [], isSave, histColors, ...
        statColors, 1, 1, true);
end

% Draw the head/midbody/tail direction.
field = 'locomotion.velocity';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = 8:10;
histColors = locomotionHistColors3;
statColors = locomotionStatColors3;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i} '.direction'], [], isSave, histColors, ...
        statColors, 1, 1);
end

% Draw the omega turns time/inter-time/inter-distance.
field = 'locomotion.turns.omegas';
subFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
extraFields = {
    [], ...
    {[field '.timeRatio.mean'], [field '.timeRatio.stdDev']}, ...
    {[field '.frequency.mean'], [field '.frequency.stdDev']}};
extraFieldNames = {
    [], ...
    {'T=', stdDevChar}, ...
    {'F=', stdDevChar}};
locations = 13:15;
histColors = locomotionHistColors1;
statColors = locomotionStatColors1;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i}], [], isSave, histColors, statColors, ...
        1, 1, true, extraFields{i}, extraFieldNames{i});
end

% Draw the upsilon turns time/inter-time/inter-distance.
field = 'locomotion.turns.upsilons';
subFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
extraFields = {
    [], ...
    {[field '.timeRatio.mean'], [field '.timeRatio.stdDev']}, ...
    {[field '.frequency.mean'], [field '.frequency.stdDev']}};
extraFieldNames = {
    [], ...
    {'T=', stdDevChar}, ...
    {'F=', stdDevChar}};
locations = 18:20;
histColors = locomotionHistColors4;
statColors = locomotionStatColors4;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i}], [], isSave, histColors, statColors, ...
        1, 1, true, extraFields{i}, extraFieldNames{i});
end



%% Save page 2.
if isSave
    pdfPages{pdfPageNum} = [pdfName ' ' num2str(pdfPageNum) '.pdf'];
    savePDF(h, pdfPages{pdfPageNum}, pageTitle, page, isClose);
    page = page + 1;
    pdfPageNum = pdfPageNum + 1;
elseif isClose
    close(h);
end



%% Draw page 3.

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
histColors = pathHistColors1;
statColors = pathStatColors1;
subplot(4,5,1);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors, 1, 0, true);

% Draw the worm/head/midbody/tail durations.
field = 'path.duration';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
locations = [6, 11, 16];
histColors = pathHistColors2;
statColors = pathStatColors2;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i}], [], isSave, histColors, statColors, ...
        1, 0, true);
end

% Draw the kinks.
field = 'posture.kinks';
histColors = postureHistColors2;
statColors = postureStatColors2;
subplot(4,5,2);
drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, ...
    field, [], isSave, histColors, statColors);

% Draw the coils time/inter-time/inter-distance.
field = 'posture.coils';
subFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
extraFields = {
    [], ...
    {[field '.timeRatio.mean'], [field '.timeRatio.stdDev']}, ...
    {[field '.frequency.mean'], [field '.frequency.stdDev']}};
extraFieldNames = {
    [], ...
    {'T=', stdDevChar}, ...
    {'F=', stdDevChar}};
locations = 3:5;
histColors = postureHistColors1;
statColors = postureStatColors1;
for i = 1:length(subFields)
    subplot(4,5,locations(i));
    drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
        control, controlName, isControlUsed, ...
        [field '.' subFields{i}], [], isSave, histColors, statColors, ...
        1, 0, true, extraFields{i}, extraFieldNames{i});
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
extraFields = {
    [], ...
    {'ratio.time.mean', 'ratio.time.stdDev'}, ...
    {'ratio.distance.mean', 'ratio.distance.stdDev'}, ...
    {'frequency.mean', 'frequency.stdDev'}};
extraFieldNames = {
    [], ...
    {'T=', stdDevChar}, ...
    {'D=', stdDevChar}, ...
    {'F=', stdDevChar}};
locations = [7:10, 12:15, 17:20];
histColors = { ...
    locomotionHistColors1, ...
    locomotionHistColors2, ...
    locomotionHistColors3};
statColors = { ...
    locomotionStatColors1, ...
    locomotionStatColors2, ...
    locomotionStatColors3};
for i = 1:length(subFields1)
    for j = 1:length(subFields2)
        
        % Assemble the extra fields.
        extraField = [];
        if ~isempty(extraFields{j})
            extraField = cell(length(extraFields{j}), 1);
            for k = 1:length(extraFields{j})
                extraField{k} = ...
                    [field '.' subFields1{i} '.' extraFields{j}{k}];
            end
        end
        
        % Plot the histogram.
        subplot(4,5,locations((i - 1) * length(subFields2) + j));
        drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
            control, controlName, isControlUsed, ...
            [field '.' subFields1{i} '.' subFields2{j}], ...
            [], isSave, histColors{i}, statColors{i}, 1, 0, true, ...
            extraField, extraFieldNames{j});
    end
end


%% Save page 3.
if isSave
    pdfPages{pdfPageNum} = [pdfName ' ' num2str(pdfPageNum) '.pdf'];
    savePDF(h, pdfPages{pdfPageNum}, pageTitle, page, isClose);
elseif isClose
    close(h);
end



%% Merge the PDFs.
if isSave
    mergePDFs(filename, pdfPages, true);
end
end



%% Draw a histogram example.
function drawHistogramExample(h, isSave)

% Initialize the plot.
set(h, 'Box', 'on');
set(h, 'LineWidth', 1);
%set(h, 'Color', str2colors('r', 0.75));

% Initialize special ascii symbols.
stdDevChar = 177;

% Initialize special text symbols and directives.
titleFont = '\fontsize{12}';
if isSave
    statFont = '\fontsize{10}';
else
    statFont = '\fontsize{8}';
end
axisFont = '\fontsize{10}';
legendFont = '\fontsize{10}';

% Pad the titles.
% Note: Matlab has a bug that cuts off the title when saving figures.
titlePad = '     ';

% Construct the title text.
titleStr = 'FEATURE NAME (D="DORSAL" V="VENTRAL")';
wormStr = ['Strain: \itStatistic=Mean ' stdDevChar 'Standard Deviation\rm'];
controlStr = 'Control: M="Mean" A="Absolute Mean" N="Samples"';
titleName = {[titleFont titlePad titleStr titlePad ], ...
    [statFont titlePad wormStr titlePad ], ...
    [statFont titlePad controlStr titlePad ]};

% Construct the x-axis label.
xStr = 'Phenotypic Feature (Units)';
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
histData(1).data.mean.all = wormMean;
histData(1).data.stdDev.all = wormStdDev;
histData(1).data.samples = 1;

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
histData(2).data.mean.all = NaN; %wormMean;
histData(2).data.stdDev.all = NaN; %wormStdDev;
histData(2).data.samples = 1;

% Plot the histogram(s).
histColors = str2colors(['p' 'k']);
statColors = str2colors(['p' 'k'], -0.1);
plotHistogram(histData, titleName, xAxisName, axisFont, [], ...
    histColors, statColors, 1, 0);
ylim([0 1.9]);

% Show the legend.
legendStr = { ...
    [legendFont 'Strain Histogram']
    'Absolute Mean'
    'Standard Deviation'
    'Control Histogram'};
legendHandle = legend(legendStr, 'Location', 'NorthWest');
set(legendHandle, 'Box', 'off');

% Explain the extra statistics.
extraStr = {
    'Extra Title Statistics:'
    'F = "Frequency" (Hz)'
    'T = "Time Ratio" (0 to 1)'
    'D = "Distance Ratio" (0 to 1)'
    };
text(1.1, 1, extraStr, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'BackgroundColor', str2colors('y'), ...
    'EdgeColor', str2colors('k'));
end



%% Draw a histogram.
%
% varargin:
%
% histMode        - the histogram display mode
% absMode         - the absolute value mode
% isLogPlot       - are we using a log plot?
% extraFields     - the extra fields to show in the title
% extraFieldNames - the names for the extra fields to show in the title
% page            - the page number (for details) to show in the title
function drawHistogram(displayInfo, worm, wormName, isWormUsed, ...
    control, controlName, isControlUsed, field, index, isSave, ...
    histColors, statColors, varargin)

% Get the worm histogram data.
data = getStructField(worm, field);
if ~isempty(index)
    data = data(index);
end
histData = data.histogram;

% Filter the histogram.
if ~isempty(isWormUsed)
    histData = filterHistogram(histData, isWormUsed);
end

% How are we displaying the histogram(s)?
histMode = 1;
if ~isempty(varargin)
    histMode = varargin{1};
end

% Are we using absolute histograms?
absMode = 0;
if length(varargin) > 1
    absMode = varargin{2};
end

% Are we using a log plot?
isLogPlot = false;
if length(varargin) > 2
    isLogPlot = varargin{3};
end

% Are we showing any extra fields?
extraFields = [];
extraFieldNames = [];
if length(varargin) > 4
    extraFields = varargin{4};
    extraFieldNames = varargin{5};
end

% Are we showing a page number for the non-summary details?
pageStr = '';
if length(varargin) > 6 && ~isempty(varargin{6})
    pageStr = [' (P.' num2str(varargin{6}) ')'];
end

% Initialize special text symbols and directives.
titleFont = '\fontsize{12}';
if isSave
    statFont = '\fontsize{10}';
else
    statFont = '\fontsize{8}';
end
axisFont = '\fontsize{10}';
statSepChar = ': '; %'\rightarrow';

% Pad the titles.
% Note: Matlab has a bug that cuts off the title when saving figures.
titlePad = '     ';

% Determine the data index.
if isempty(index)
    index = 1;
end

% Determine the figure information.
info = getStructField(displayInfo, field);
fieldName = info(index).name;
fieldUnit = info(index).unit;

% Construct the worm statistics text.
statStr = hist2StatStr(histData, worm, extraFields, extraFieldNames, ...
    absMode);
titleName = {[titleFont titlePad upper(fieldName) pageStr titlePad ], ...
    [statFont titlePad wormName statSepChar statStr titlePad ]};

% Get the control histogram data.
if ~isempty(control)
    data = getStructField(control, field);
    if ~isempty(index)
        data = data(index);
    end
    
    % Set the control data.
    if isempty(histData) % transform it into a struct
        histData = emptyHistogram();
    end
    if isempty(data.histogram)
        histData(2) = emptyHistogram();
    else
        histData(2) = data.histogram;
        
        % Filter the histogram.
        if ~isempty(isControlUsed)
            histData(2) = filterHistogram(histData(2), isControlUsed);
        end
    end
    
    % Construct the control statistics text.
    statStr = hist2StatStr(histData(2), control, extraFields, ...
        extraFieldNames, absMode);
    titleName{3} = [statFont titlePad controlName statSepChar statStr ...
        titlePad ];
end

% Construct the x-axis label.
logStr = '';
unitStr = fieldUnit;
if isLogPlot
    superPad = '   ';
    logStr = 'Log ';
    unitStr = ['10^{' unitStr superPad '}'];
end
xAxisName = [axisFont logStr fieldName ' (' unitStr  ')'];

% Plot the histogram(s).
plotHistogram(histData, titleName, xAxisName, axisFont, [], ...
    histColors, statColors, histMode, 0, absMode, isLogPlot, true);
end



%% Convert a histogram to a string of summary statistics.
function statStr = hist2StatStr(data, worm, extraFields, ...
    extraFieldNames, isAbs)

% Is there any data?
if isempty(data) || isempty(data.bins) || all(isnan(data.bins))
    statStr = 'NO DATA';
    return;
end

% Initialize special ascii symbols.
stdDevChar = 177;

% Initialize the numerical format for statistics.
sampleFormat = '%.0g';
shortFormat = '%.1g';
medFormat = '%.2g';
longFormat = '%.3g';

% Choose a numerical format.
statFormat = shortFormat;
if isempty(extraFields) && ~isAbs
    statFormat = longFormat;
elseif isempty(extraFields) || ~isAbs
    statFormat = medFormat;
end

% Construct the text for the extra fields.
extraFieldStr = [];
for i = 1:length(extraFields)
    extraFieldData = getStructField(worm, extraFields{i});
    extraFieldStr = [ extraFieldStr ' ' ...
        extraFieldNames{i} num2str(extraFieldData, statFormat)];
end

% Determine the worm mean and standard deviation.
histMean = data.sets.mean.all;
if data.sets.samples > 1
    histStd = data.sets.stdDev.all;
else
    histStd = data.allData.stdDev.all;
end

% Construct the text for the statistics.
statStr = extraFieldStr;
if isempty(extraFields) || ~isAbs
    meanStr = num2str(histMean, statFormat);
    stdStr = num2str(histStd, statFormat);
    if isempty(statStr)
        statStr = ['M=' meanStr ' ' stdDevChar stdStr];
    else
        statStr = ['M=' meanStr ' ' stdDevChar stdStr ' ' statStr];
    end
end

% Construct the text for the absolute value statistics.
if isAbs && data.isSigned
    
    % Determine the worm absolute mean and standard deviation.
    histAbsMean = data.sets.mean.abs;
    if data.sets.samples > 1
        histAbsStd = data.sets.stdDev.abs;
    else
        histAbsStd = data.allData.stdDev.abs;
    end
    
    % Construct the text for the absolute value statistics.
    absMeanStr = num2str(histAbsMean, statFormat);
    absStdStr = num2str(histAbsStd, statFormat);
    if isempty(statStr)
        statStr = ['A=' absMeanStr ' ' stdDevChar absStdStr];
    else
        statStr = ['A=' absMeanStr ' ' stdDevChar absStdStr ' ' statStr];
    end
end

% Add the sample size.
sampleStr = num2str(data.allData.samples, sampleFormat);
statStr = [statStr ' N=' sampleStr];
end
