function [filename pages] = worm2detailsPDF(filename, worm, wormName, ...
    varargin)
%WORM2DETAILSPDF Save worm details to a PDF.
%
%   [FILENAME PAGES] = WORM2DETAILSPDF(FILENAME, WORM, WORMNAME)
%
%   [FILENAME PAGES] = WORM2DETAILSPDF(FILENAME, WORM, WORMNAME, WORMFILTER,
%                                      CONTROL, CONTROLNAME, CONTROLFILTER,
%                                      SIGNIFICANCE, ISSHOW, PAGE, ISSAVE,
%                                      ISCLOSE)
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
%       significance  - the feature statistical significance or filename;
%                       if empty; no statistical significance is shown
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
    if ~isempty(control) && ischar(control)
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

% Do we have the statistical significance?
significance = [];
if length(varargin) > 4
    significance = varargin{5};
    
    % Load the significance.
    if ischar(significance)
        wormData = [];
        controlData = [];
        load(significance, 'significance', 'wormData', 'controlData');
        
        % Copy the normality tests into the significance.
        for i = 1:length(significance.features)
            significance.features(i).pWNormal = wormData(i).pNormal;
            significance.features(i).qWNormal = wormData(i).pNormal;
        end
        if ~isempty(controlData)
            for i = 1:length(significance.features)
                significance.features(i).pCNormal = controlData(i).pNormal;
                significance.features(i).qCNormal = controlData(i).pNormal;
            end
        end
    end
end

% Are we showing the figures onscreen?
% Note: hiding the figures is faster.
isShow = true;
if length(varargin) > 5
    isShow = varargin{6};
end

% Determine the page number.
pages = 0;
page = [];
if length(varargin) > 6
    page = varargin{7};
end

% Are we saving the figures?
isSave = true;
if length(varargin) > 7
    isSave = varargin{8};
end

% Are we closing the figures after saving them?
if isSave
    isClose = true;
else
    isClose = false;
end
if length(varargin) > 8
    isClose = varargin{9};
end

% Construct the file name.
if isSave
    
    % Remove the PDF extension.
    pdfExt = '.pdf';
    pdfName = filename;
    if length(pdfName) >= length(pdfExt) && ...
            strcmp(filename((end - length(pdfExt) + 1):end), pdfExt)
        pdfName = filename(1:(end - length(pdfExt)));
    end
    
    % Create the filename.
    if isempty(pdfName)
        if isempty(controlName)
            pdfName = [wormName ' summary'];
        else
            pdfName = [wormName ' vs ' controlName ' summary'];
        end
    end
    
    % Add the PDF extension.
    filename = [pdfName '.pdf'];

% We are not saving a file.
else
    filename = [];
end

% Initialize the pages.
pdfPageNum = 1;
pdfPages = [];

% Initialize the color scheme.
% Note: the order for 3 color schemes is forward, backward, paused.
wormColor = str2colors('m');
controlColor = str2colors('k');
wormColor3 = str2colors('mcl');
controlColor3 = str2colors('kkk', [0, .3, .9]);

% Initialize special ascii symbols.
stdDevChar = 177;

% Initialize the feature information.
dispInfo = wormDisplayInfo();
dataInfo = wormDataInfo();
statsInfo = wormStatsInfo();

% Draw the features.
page = 1;
i = 2;
while i <= 2 %<= length(dataInfo)
    switch dataInfo(i).type
        
        % Draw a quadrant of simple features.
        case 's'
            
            % Add up to 3 more simple features to the page.
            j = i;
            endJ = min(i + 3, length(dataInfo));
            while j < endJ
                j = j + 1;
            end
            
            % Draw the feature.
            drawSimpleData(filename, page, i:j, worm, wormName, ...
                isWormUsed, control, controlName, isControlUsed, ...
                significance, dispInfo, dataInfo, statsInfo, ...
                isShow, isSave, isClose);
            
            % Advance.
            i = j;
            
        % Draw a quadrant of the motion features.
        case 'm'
            
            % Get the data.
            field = dataInfo(i).field;
            dispData = getStructField(dispInfo, field);
            wormData = getStructField(worm, field);
            controlData = [];
            if ~isempty(control)
                controlData = getStructField(control, field);
            end
            
            % Draw the data.
            if isempty(controlData)
                for j = 1:length(wormData)
                    drawMotionData(filename, page, i, ...
                        wormData(j), wormName,  isWormUsed, [], [], [], ...
                        significance, dispData(j), dataInfo, statsInfo, ...
                        isShow, isSave, isClose);
                end
                
            % Draw the controlled data.
            else
                for j = 1:length(wormData)
                    drawMotionData(filename, page, i, ...
                        wormData(j), wormName,  isWormUsed, ...
                        controlData(j), controlName, isControlUsed, ...
                        significance, dispData(j), dataInfo, statsInfo, ...
                        isShow, isSave, isClose);
                end
            end
            
        % Draw a quadrant of the event.
        case 'e'
            drawEventData(filename, page, i, worm, wormName, ...
                isWormUsed, control, controlName,  isControlUsed, ...
                significance, dispInfo, dataInfo, statsInfo, ...
                isShow, isSave, isClose);
    end
    
    % Advance.
    i = i + 1;
end
end



%% Draw a quadrant of simple features.
function drawSimpleData(filename, page, featureI, worm, wormName, ...
    isWormUsed, control, controlName, isControlUsed, significance, ...
    dispInfo, dataInfo, statsInfo, isShow, isSave, isClose)

% Initialize the color scheme.
wormColor = str2colors('m');
controlColor = str2colors('k');
colors = [controlColor; wormColor];

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

% Draw the feature histograms.
for i = 1:length(featureI)
   
    % Get the data.
    field = dataInfo(featureI(i)).field;
    wormHist = getStructField(worm, [field '.histogram']);
    wormHist = filterHistogram(wormHist, isWormUsed);
    controlHist = [];
    if ~isempty(control)
        controlHist = getStructField(control, [field '.histogram']);
        controlHist = filterHistogram(controlHist, isControlUsed);
    end
    
    % Downsample the data.
    hist = [controlHist, wormHist];
    hist = downSampleHistogram(hist);
    
    % Get the labels.
    sigI = find([statsInfo.title1I] == featureI(i), 1);
    disp = getStructField(dispInfo, field);
    [statsStrs sigs] = stats2strs(wormHist, wormName, ...
        controlHist, controlName, significance, sigI);
    titleLabel{1} = disp.name;
    titleLabel(2:(length(statsStrs) + 1)) = statsStrs;
    xLabel = [disp.name ' (' disp.unit ')'];
    
    % Draw the data.
    subplot(2,2,i);
    hold on;
    plotHistogram(hist, titleLabel, xLabel, '', [], colors, colors, 1, 0);
end

% Save the figure.
if 0 && isSave
    pdfPages{pdfPageNum} = [pdfName ' ' num2str(pdfPageNum) '.pdf'];
    savePDF(h, pdfPages{pdfPageNum}, pageTitle, page, isClose);
    page = page + 1;
    pdfPageNum = pdfPageNum + 1;
end

% Close the figure.
if 0 && isClose
    close(h);
end
end



%% Draw a quadrant of the motion features.
function drawMotionData(filename, page, featureI, worm, wormName, ...
    isWormUsed, control, controlName, isControlUsed, significance, ...
    dispInfo, dataInfo, statsInfo, isShow, isSave, isClose)

% Initialize the color scheme.
% Note: the order for 3 color schemes is forward, backward, paused.
wormColor = str2colors('y');
controlColor = str2colors('k');
wormColor3 = str2colors('rgb');

% Initialize the motion fields.
motionField = {
    'forward'
    'paused'
    'backward'};

% Get the worm histograms.
numPlots = 4;
wormHist = filterHistogram(worm.histogram, isWormUsed);
wormHist3 = [];
for i = 1:length(motionField)
    wormHist3 = cat(1, wormHist3, worm.(motionField{i}).histogram);
end
wormHist3 = filterHistogram(wormHist3, isWormUsed);

% Group the control histograms.
if ~isempty(control)
    numPlots = 6;
    controlHist = filterHistogram(control.histogram, isControlUsed);
    controlHist3 = [];
    for i = 1:length(motionField)
        controlHist3 = cat(1, controlHist3, ...
            control.(motionField{i}).histogram);
    end
    controlHist3 = filterHistogram(controlHist3, isControlUsed);
end

% Allocate the memory.
titles = cell(numPlots, 1);
hists = cell(numPlots, 1);
colors = cell(numPlots, 1);
histModes = cell(numPlots, 1);

% Get the feature and labels.
sigI = find([statsInfo.title1I] == featureI, 1);
xLabel = [dispInfo.name ' (' dispInfo.unit ')'];

% Group the worm drawings.
if isempty(control)
    
% Group the worm and control drawings.
else
    
    % Draw the worm vs. the control.
    [statsStrs sigs] = stats2strs(wormHist, wormName, ...
        controlHist, controlName, significance, sigI);
    titleStrs{1} = upper([wormName ' vs. ' controlName ': ' dispInfo.name]);
    titleStrs(2:(length(statsStrs) + 1)) = statsStrs;
    titles{1} = titleStrs;
    hists{1} = downSampleHistogram([controlHist; wormHist]);
    colors{1} = [controlColor; wormColor];
    histModes{1} = 1;

    % Draw the worm motion vs. the worm.
    titles{2} = upper([wormName ': ' dispInfo.name]);
    hists{2} = downSampleHistogram([wormHist3; wormHist]);
    colors{2} = [wormColor3; controlColor];
    histModes{2} = 2;

    % Draw the control motion vs. the control.
    titles{3} = upper([controlName ': ' dispInfo.name]);
    hists{3} = downSampleHistogram([controlHist3; controlHist]);
    colors{3} = [wormColor3; controlColor];
    histModes{3} = 2;

    % Draw the worm motion vs. control motion.
    for i = 1:3
        [statsStrs sigs] = stats2strs(wormHist, wormName, ...
            controlHist, controlName, significance, sigI + i * 4);
        titleStrs{1} = upper([wormName ' vs. ' controlName ': ' dispInfo.name]);
        titleStrs(2:(length(statsStrs) + 1)) = statsStrs;
        titles{i + 3} = titleStrs;
        hists{i + 3} = downSampleHistogram([controlHist3(i); wormHist3(i)]);
        colors{i + 3} = [controlColor; wormColor3(i,:)];
        histModes{i + 3} = 1;
    end
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

% Draw the worm feature histograms.
if isempty(control)
    plotHistogram(hists{1}, titles{1}, xLabel, '', [], colors{1}, ...
        colors{1}, histModes{1}, 0);

% Draw the worm vs. control feature histograms.
else
    for i = 1:length(hists)
        subplot(2,3,i);
        hold on;
        plotHistogram(hists{i}, titles{i}, xLabel, '', [], colors{i}, ...
            colors{i}, histModes{i}, 0);
    end
end

% Save the figure.
if 0 && isSave
    pdfPages{pdfPageNum} = [pdfName ' ' num2str(pdfPageNum) '.pdf'];
    savePDF(h, pdfPages{pdfPageNum}, pageTitle, page, isClose);
    page = page + 1;
    pdfPageNum = pdfPageNum + 1;
end

% Close the figure.
if 0 && isClose
    close(h);
end
end



%% Draw a quadrant of the event.
function drawEventData(filename, page, featureI, worm, wormName, ...
    isWormUsed, control, controlName, isControlUsed, significance, ...
    dispInfo, dataInfo, statsInfo, isShow, isSave, isClose)

% Initialize the color scheme.
% Note: the order for 2 color schemes is feature and inter-feature.
wormColor = str2colors('m');
controlColor = str2colors('k');
wormColor2 = str2colors('mc');

% Initialize the fields.
field = dataInfo(featureI).field;
subFields = dataInfo(featureI).subFields.data;

% Group the worm histograms.
worm = getStructField(worm, field);
wormHists = [];
for i = 1:length(subFields)
    wormHists = cat(1, wormHists, worm.(subFields{i}).histogram);
end
wormHists = filterHistogram(wormHists, isWormUsed);

% Group the control histograms.
if ~isempty(control)
    control = getStructField(control, field);
    controlHists = [];
    for i = 1:length(subFields)
        controlHists = ...
            cat(1, controlHists, control.(subFields{i}).histogram);
    end
    controlHists = filterHistogram(controlHists, isControlUsed);
end

% Get the labels.
disp = getStructField(dispInfo, field);
names = cell(length(subFields), 1);
units = cell(length(subFields), 1);
for i = 1:length(subFields)
    names{i} = disp.(subFields{i}).name;
    units{i} = disp.(subFields{i}).unit;
end

% Group the worm histograms with their controls.
titles = cell(length(wormHists), 1);
hists = cell(length(wormHists), 1);
colors = cell(length(wormHists), 1);
if isempty(control)
    for i = 1:length(hists)
        titles{i} = upper([names{i} ' (' units{i} ')']);
        hists{i} = downSampleHistogram(wormHists(i));
        colors{i} = wormColor;
    end
else
    for i = 1:length(hists)
        titles{i} = upper([names{i} ' (' units{i} ')']);
        hists{i} = downSampleHistogram([controlHists(i); wormHists(i)]);
        colors{i} = [controlColor; wormColor];
    end
end

% Group the 4 drawings.
if length(hists) == 3
    
    % Re-order the existing drawings.
    oldI = 3;
    newI = 4;
    titles(newI) = titles(oldI);
    hists(newI) = hists(oldI);
    colors(newI) = colors(oldI);
    
    % Add the comparative drawings.
    titles{3} = upper([names{1} ' vs. ' names{2} ' (' units{1} ')']);
    hists{3} = downSampleHistogram([wormHists(1); wormHists(2);]);
    colors{3} = wormColor2;
    
% Group the 6 drawings.
else % length(subFields) == 4

    % Re-order the existing drawings.
    oldI = [2 3 4];
    newI = [4 2 5];
    titles(newI) = titles(oldI);
    hists(newI) = hists(oldI);
    colors(newI) = colors(oldI);

    % Add the comparative drawings.
    titles{3} = upper([names{1} ' vs. ' names{3} ' (' units{1} ')']);
    titles{6} = upper([names{2} ' vs. ' names{4} ' (' units{2} ')']);
    hists{3} = downSampleHistogram([wormHists(1); wormHists(3);]);
    hists{6} = downSampleHistogram([wormHists(2); wormHists(4);]);
    colors{3} = wormColor2;
    colors{6} = wormColor2;
end

% % Log scale the histograms.
% for i = 1:length(hists)
%     hists{i} = logHistogram(hists{i}, 1);
% end

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

% Draw the feature histograms.
for i = 1:length(hists)
    subplot(2,3,i);
    hold on;
    plotHistogram(hists{i}, titles{i}, '', '', [], colors{i}, ...
        colors{i}, 1, 0);
end

% Save the figure.
if 0 && isSave
    pdfPages{pdfPageNum} = [pdfName ' ' num2str(pdfPageNum) '.pdf'];
    savePDF(h, pdfPages{pdfPageNum}, pageTitle, page, isClose);
    page = page + 1;
    pdfPageNum = pdfPageNum + 1;
end

% Close the figure.
if 0 && isClose
    close(h);
end
end



%% Convert the statistics to strings.
function [str sigs] = stats2strs(wormHist, wormName, ...
    controlHist, controlName, significance, sigI)

% Initialize special ascii symbols.
semChar = '±';
sepStr = '  ¤  ';

% Initialize the fields.
fields = {
    'all'
    'abs'
    'pos'
    'neg'};

% Is the feature signed?
if wormHist.isSigned
    endI = 4;
else
    endI = 1;
end

% Allocate memory.
str = cell(endI + 1, 1);
sigs = nan(endI, 1);

% % Show the names.
% str{1} = wormName;
% if ~isempty(controlName)
%     str{1} = [str{1} ' [' controlName ']'];
% end

% Show the samples.
%str{1} = [str{1} sepStr 'WORMS=' num2str(wormHist.sets.samples, '%.0G')];
str{1} = ['WORMS = ' num2str(wormHist.sets.samples, '%.0G')];
if ~isempty(controlHist)
    str{1} = [str{1} '   [' num2str(controlHist.sets.samples, '%.0G') ']'];
end

% Show the total worm samples.
str{1} = [str{1} sepStr 'SAMPLES = ' ...
    num2str(wormHist.allData.samples, '%.0G')];
if ~isempty(controlHist)
    str{1} = [str{1} '   [' num2str(controlHist.allData.samples, '%.0G') ']'];
end

% Determine the square root of the sample sets.
wormSqrt = sqrt(wormHist.sets.samples);
if ~isempty(controlHist)
    controlSqrt = sqrt(controlHist.sets.samples);
end

% Convert the statistics to strings.
for i = 1:endI
    
    % Determine the inequality between experiment and control.
    wormMean = wormHist.sets.mean.(fields{i});
    eqStr = '   ';
    if ~isempty(controlHist)
        controlMean = controlHist.sets.mean.(fields{i});
        if wormMean > controlMean
            eqStr = ' > ';
        elseif wormMean < controlMean
            eqStr = ' < ';
        end
    end
    
    % Don't show the inequality between experiment and control.
    sigStr = [];
    if isempty(significance)
        eqStr = '   ';
        
    % Determine the significance.
    else
        stats = significance.features(sigI + i - 1);
        sigs(i) = max(stats.pWValue, stats.qWValue);
        sigStr = [' ' p2stars(sigs(i))];
        
        % Don't show the inequality between experiment and control.
        if sigs(i) > 0.05
            eqStr = '   ';
        end
    end
    
    % Determine the separator string.
    preStr = [];
    if 0 && ~mod(i, 2)
        preStr = sepStr;
    end
    
    % Show the worm statistics.
    wormMean = wormHist.sets.mean.(fields{i});
    meanStr = num2str(wormMean, '%.3G');
    semStr = num2str(wormHist.sets.stdDev.(fields{i}) / wormSqrt, '%.3G');
    j = floor((i + 3) / 2);
    j = i + 1;
    str{j} = [str{j} preStr upper(fields{i}) ' = ' meanStr semChar semStr];
    
    % Show the control statistics.
    if ~isempty(controlHist)
        meanStr = num2str(controlHist.sets.mean.(fields{i}), '%.3G');
        semStr = num2str(controlHist.sets.stdDev.(fields{i}) / ...
            controlSqrt, '%.3G');
        str{j} = [str{j} eqStr '[' meanStr semChar semStr ']'];
        
    end
    
    % Show the significance.
     str{j} = [str{j} '   ' sigStr];
end
end
