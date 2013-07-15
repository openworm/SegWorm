function [filename pages] = worm2detailsTIF(filename, worm, wormName, ...
    varargin)
%WORM2DETAILSTIF Save worm details to a TIF.
%
%   [FILENAME PAGES] = WORM2DETAILSTIF(FILENAME, WORM, WORMNAME)
%
%   [FILENAME PAGES] = WORM2DETAILSTIF(FILENAME, WORM, WORMNAME,
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
%                           p = the p-value, per feature
%                           q = the q-value, per feature
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
            tifName = [wormName ' details'];
        else
            tifName = [wormName ' vs ' controlName ' details'];
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

% Draw the features.
i = 1;
while i <= length(dataInfo)
    
    % Draw the features.
    switch dataInfo(i).type
        
        % Draw a quadrant of simple features.
        case 's'
            
            % Compute the page.
            page = page + 1;
            
            % Display the progress.
            if isVerbose
                disp(['Printing details ' num2str(i) '/' ...
                    num2str(length(dataInfo)) ' ...']);
            end
    
            % Add up to 3 more simple features to the page.
            j = i;
            endJ = min(i + 3, length(dataInfo));
            while j < endJ
                j = j + 1;
            end
            
            % Draw the feature.
            drawSimpleData(filename, page, i:j, worm, wormName, ...
                isWormUsed, control, controlName, isControlUsed, ...
                sig, dispInfo, dataInfo, statsInfo, ...
                isShow, saveQuality, isClose);
            
            % Advance.
            i = j;
            
        % Draw the quadrants of the motion features.
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
                    
                    % Compute the page.
                    page = page + 1;
                    
                    % Display the progress.
                    if isVerbose
                        disp(['Printing details ' num2str(i) '/' ...
                            num2str(length(dataInfo)) ' ...']);
                    end
            
                    % Draw the feature.
                    drawMotionData(filename, page, i, j, ...
                        wormData(j), wormName,  isWormUsed, [], [], [], ...
                        sig, dispData(j), dataInfo, statsInfo, ...
                        isShow, saveQuality, isClose);
                end
                
            % Draw the controlled data.
            else
                for j = 1:length(wormData)
                    
                    % Compute the page.
                    page = page + 1;
                    
                    % Display the progress.
                    if isVerbose
                        disp(['Printing details ' num2str(i) '/' ...
                            num2str(length(dataInfo)) ' ...']);
                    end
            
                    % Draw the feature.
                    drawMotionData(filename, page, i, j, ...
                        wormData(j), wormName,  isWormUsed, ...
                        controlData(j), controlName, isControlUsed, ...
                        sig, dispData(j), dataInfo, statsInfo, ...
                        isShow, saveQuality, isClose);
                end
            end
            
        % Draw the quadrants of the event.
        case 'e'
            
            % Compute the page.
            page = page + 1;
            
            % Display the progress.
            if isVerbose
                disp(['Printing details ' num2str(i) '/' ...
                    num2str(length(dataInfo)) ' ...']);
            end
            
            % Draw the feature.
            drawEventData(filename, page, i, worm, wormName, ...
                isWormUsed, control, controlName,  isControlUsed, ...
                sig, dispInfo, dataInfo, statsInfo, ...
                isShow, saveQuality, isClose);
    end
    
    % Advance.
    i = i + 1;
end

% Compute the pages.
pages = page - pages;
end



%% Draw a quadrant of simple features.
function drawSimpleData(filename, page, featureI, worm, wormName, ...
    isWormUsed, control, controlName, isControlUsed, sig, ...
    dispInfo, dataInfo, statsInfo, isShow, saveQuality, isClose)

% Initialize the fonts.
smallFontStr = '\rm\fontsize{10}';
bigFontStr = '\bf\fontsize{14}';
axisFontSize = 12;

% Initialize the color scheme.
statColorScale = 0.6;
wormColor = str2colors('n');
controlColor = str2colors('k');
if isempty(control)
    histColors = wormColor;
else
    histColors = [controlColor; wormColor];
end
statColors = histColors * statColorScale;

% Create a figure.
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);
hold on;

% Draw the feature histograms.
statsInfoTitle1I = [statsInfo.title1I];
featureNames = cell(length(featureI), 1);
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
    
    % Get the statistics.
    sigI = find(statsInfoTitle1I == featureI(i), 1);
    disp = getStructField(dispInfo, field);
    featureNames{i} = disp.name;
    [statsStrs sigs] = stats2strs(wormHist, controlHist, sig, sigI);
    
    % Create the labels.
%     titleLabel{1} = [bigFontStr wormName];
%     if ~isempty(controlName)
%         titleLabel{1} = [titleLabel{1} '   [' controlName ']'];
%     end
    titleLabel{1} = [bigFontStr upper(disp.name) smallFontStr];
    titleLabel(2:(length(statsStrs) + 1)) = statsStrs;
    xLabel = [bigFontStr disp.unit ' '];
    
    % Draw the data.
    subplot(2,2,i);
    hold on;
    plotHistogram(hist, titleLabel, xLabel, bigFontStr, [], ...
        histColors, statColors, 1, 0, 1, 1);
    
    % Embiggen the x-axis ticks.
    set(gca, 'FontSize', axisFontSize);
        
    % Color the significance.
    set(gca, 'Color', p2BackColor(min(sigs)));
end

% Draw the legend.
drawSimpleLegend(h);

% Save the figure.
if saveQuality > 0
    pageTitle = info2pageTitle(wormName, controlName, featureI, ...
        featureNames, dataInfo);
    saveTIF(h, filename, saveQuality, true, pageTitle, page, isClose);

% Close the figure.
elseif ~isShow || isClose
    close(h);
end
end



%% Draw a quadrant of the motion features.
function drawMotionData(filename, page, featureI, index, worm, wormName, ...
    isWormUsed, control, controlName, isControlUsed, sig, ...
    dispInfo, dataInfo, statsInfo, isShow, saveQuality, isClose)

% Initialize the fonts.
smallFontStr = '\rm\fontsize{10}';
bigFontStr = '\bf\fontsize{14}';
axisFontSize = 12;

% Initialize the color scheme.
% Note: the order for 3 color schemes is forward, backward, paused.
statColorScale = 0.6;
wormColor = str2colors('n');
%wormColor3 = str2colors('rgb', [0, -0.5, 0]);
wormColor3 = str2colors('mgb', [0, -1/3, 0]);
controlColor = str2colors('k');

% Initialize the motion fields.
motionField = {
    'forward'
    'paused'
    'backward'};

% Get the worm histograms.
numPlots = 6;
wormHist = filterHistogram(worm.histogram, isWormUsed);
wormHist3 = [];
for i = 1:length(motionField)
    wormHist3 = cat(1, wormHist3, worm.(motionField{i}).histogram);
end
wormHist3 = filterHistogram(wormHist3, isWormUsed);

% Group the control histograms.
if ~isempty(control)
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
histColors = cell(numPlots, 1);
statColors = cell(numPlots, 1);
histModes = cell(numPlots, 1);
logModes = cell(numPlots, 1);
sigColors = cell(numPlots, 1);

% Get the feature information.
numSigns = 1;
if wormHist.isSigned
    numSigns = 4;
end
if index > 1
    sigI = find([statsInfo.title1I] == featureI & ...
        [statsInfo.index] == index, 1);
else
    sigI = find([statsInfo.title1I] == featureI, 1);
end

% Create the x-axis label.
%xLabel = [bigFontStr dispInfo.name ' (' dispInfo.unit ') '];
xLabel = [bigFontStr dispInfo.unit ' '];

% Group the worm drawings.
if isempty(control)
    
    % Draw the worm.
    [statsStrs sigs] = stats2strs(wormHist, [], sig, sigI);
    titleStrs = [];
%     titleStrs{1} = [bigFontStr wormName ' [' controlName ']: ' ...
%         upper(dispInfo.name) smallFontStr];
    titleStrs{1} = [bigFontStr upper(dispInfo.name) smallFontStr];
    titleStrs(2:(length(statsStrs) + 1)) = statsStrs;
    titles{1} = titleStrs;
    hists{1} = downSampleHistogram(wormHist);
    histColors{1} = wormColor;
    statColors{1} = histColors{1} * statColorScale;
    histModes{1} = 1;

    % Draw the worm motion vs. the worm.
    titles{2} = [bigFontStr wormName ': ' upper(dispInfo.name)];
    hists{2} = downSampleHistogram([wormHist3; wormHist]);
    histColors{2} = [wormColor3; controlColor];
    histModes{2} = 2;
    
    % Draw the worm motion.
    for i = 1:3
        
        % Create the title.
        [statsStrs sigs] = stats2strs(wormHist3(i), [], ...
            sig, sigI + i * numSigns);
        titleStrs = [];
%         titleStrs{1} = [bigFontStr wormName ' [' controlName ']: ' ...
%             upper([motionField{i} ' ' dispInfo.name]) smallFontStr ];
        titleStrs{1} = [bigFontStr ...
            upper([motionField{i} ' ' dispInfo.name]) smallFontStr ];
        titleStrs(2:(length(statsStrs) + 1)) = statsStrs;
        titles{i + 3} = titleStrs;
        
        % Create the histogram.
        hists{i + 3} = downSampleHistogram(wormHist3(i));
        histColors{i + 3} = wormColor3(i,:);
        statColors{i + 3} = histColors{i + 3} * statColorScale;
        histModes{i + 3} = 1;
    end
    
% Group the worm and control drawings.
else
    
    % Draw the worm vs. the control.
    [statsStrs sigs] = stats2strs(wormHist, controlHist, sig, sigI);
    titleStrs = [];
%     titleStrs{1} = [bigFontStr wormName ' [' controlName ']: ' ...
%         upper(dispInfo.name) smallFontStr];
    titleStrs{1} = [bigFontStr upper(dispInfo.name) smallFontStr];
    titleStrs(2:(length(statsStrs) + 1)) = statsStrs;
    titles{1} = titleStrs;
    hists{1} = downSampleHistogram([controlHist; wormHist]);
    histColors{1} = [controlColor; wormColor];
    statColors{1} = histColors{1} * statColorScale;
    histModes{1} = 1;
    sigColors{1} = p2BackColor(min(sigs));

    % Draw the worm motion vs. the worm.
    titles{2} = [bigFontStr wormName ': ' upper(dispInfo.name)];
    hists{2} = downSampleHistogram([wormHist3; wormHist]);
    histColors{2} = [wormColor3; controlColor];
    histModes{2} = 2;

    % Draw the control motion vs. the control.
    titles{3} = [bigFontStr controlName ': ' upper(dispInfo.name)];
    hists{3} = downSampleHistogram([controlHist3; controlHist]);
    histColors{3} = [wormColor3; controlColor];
    histModes{3} = 2;
    
    % Draw the worm motion vs. control motion.
    for i = 1:3
        
        % Create the title.
        [statsStrs sigs] = stats2strs(wormHist3(i), controlHist3(i), ...
            sig, sigI + i * numSigns);
        titleStrs = [];
%         titleStrs{1} = [bigFontStr wormName ' [' controlName ']: ' ...
%             upper([motionField{i} ' ' dispInfo.name]) smallFontStr ];
        titleStrs{1} = [bigFontStr ...
            upper([motionField{i} ' ' dispInfo.name]) smallFontStr ];
        titleStrs(2:(length(statsStrs) + 1)) = statsStrs;
        titles{i + 3} = titleStrs;
        
        % Create the histogram.
        hists{i + 3} = downSampleHistogram([controlHist3(i); wormHist3(i)]);
        histColors{i + 3} = [controlColor; wormColor3(i,:)];
        statColors{i + 3} = histColors{i + 3} * statColorScale;
        histModes{i + 3} = 1;
        sigColors{i + 3} = p2BackColor(min(sigs));
    end
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

% Draw the features.
for i = 1:length(hists)
    if ~isempty(titles{i})
        
        % Draw the data.
        subplot(2,3,i);
        hold on;
        plotHistogram(hists{i}, titles{i}, xLabel, bigFontStr, [], ...
            histColors{i}, statColors{i}, histModes{i}, 0, 1, 1, ...
            logModes{i});
        
        % Embiggen the x-axis ticks.
        set(gca, 'FontSize', axisFontSize);
        
        % Color the significance.
        if ~isempty(sigColors{i})
            set(gca, 'Color', sigColors{i});
        end
    end
end

% Draw the legend.
drawMotionLegend(h);

% Save the figure.
if saveQuality > 0
    pageTitle = info2pageTitle(wormName, controlName, featureI, ...
        {dispInfo.name}, dataInfo);
    saveTIF(h, filename, saveQuality, true, pageTitle, page, isClose);

% Close the figure.
elseif ~isShow || isClose
    close(h);
end
end



%% Draw a quadrant of the event.
function drawEventData(filename, page, featureI, worm, wormName, ...
    isWormUsed, control, controlName, isControlUsed, sig, ...
    dispInfo, dataInfo, statsInfo, isShow, saveQuality, isClose)

% Initialize the fonts.
smallFontStr = '\rm\fontsize{10}';
bigFontStr = '\bf\fontsize{14}';
axisFontSize = 12;

% Initialize the color scheme.
% Note: the order for 2 color schemes is feature and inter-feature.
statColorScale = 0.6;
wormColor = str2colors('n');
wormColor2 = str2colors('gm', [-1/3, 0]);
controlColor = str2colors('k');
controlColor2 = str2colors('kk', [0 .6]);

% Initialize the fields.
field = dataInfo(featureI).field;
summaryFields = dataInfo(featureI).subFields.summary;
dataFields = dataInfo(featureI).subFields.data;

% Group the worm summary fields.
worm = getStructField(worm, field);
wormFields = [];
for i = 1:length(summaryFields)
    subField = getStructField(worm, summaryFields{i});
    wormFields = cat(1, wormFields, subField);
end

% Group the worm control fields.
controlFields = [];
if ~isempty(control)
    control = getStructField(control, field);
    for i = 1:length(summaryFields)
        subField = getStructField(control, summaryFields{i});
        controlFields = cat(1, controlFields, subField);
    end
end

% Create the summary statistics strings.
sigI = find([statsInfo.title1I] == featureI, 1);
[summaryStrs summarySigs] = eventStats2strs(wormFields, isWormUsed, ...
    controlFields, isControlUsed, sig, sigI);

% Group the worm histograms.
wormHists = [];
numSigns = ones(length(dataFields), 1);
for i = 1:length(dataFields)
    wormHists = cat(1, wormHists, worm.(dataFields{i}).histogram);
    if ~isnan(wormHists(i).isSigned) && wormHists(i).isSigned
        numSigns(i) = 4;
    end
end
wormHists = filterHistogram(wormHists, isWormUsed);

% Group the control histograms.
if ~isempty(control)
    controlHists = [];
    for i = 1:length(dataFields)
        controlHists = ...
            cat(1, controlHists, control.(dataFields{i}).histogram);
    end
    controlHists = filterHistogram(controlHists, isControlUsed);
end

% Create the data statistics strings.
dataStrs = cell(length(wormHists), 1);
dataSigs = cell(length(wormHists), 1);
sigI = sigI + length(summaryFields);
if isempty(control)
    for i = 1:length(wormHists)
        [dataStrs{i} dataSigs{i}] = stats2strs(wormHists(i), [], ...
            sig, sigI + (i - 1) * numSigns(i));
    end
else
    for i = 1:length(wormHists)
        [dataStrs{i} dataSigs{i}] = stats2strs(wormHists(i), ...
            controlHists(i), sig, sigI + (i - 1) * numSigns(i));
    end
end

% Get the labels.
disp = getStructField(dispInfo, field);
names = cell(length(dataFields), 1);
units = cell(length(dataFields), 1);
for i = 1:length(dataFields)
    names{i} = disp.(dataFields{i}).name;
    units{i} = disp.(dataFields{i}).unit;
end

% Group the histograms.
titles = cell(length(wormHists), 1);
xLabels = cell(length(wormHists), 1);
hists = cell(length(wormHists), 1);
histModes = cell(length(wormHists), 1);
sigColors = cell(length(wormHists), 1);
for i = 1:length(hists)
    
    % Create the title.
    titleStrs = [];
%     titleStrs{1} = [bigFontStr wormName];
%     if ~isempty(control)
%         titleStrs{1} = [titleStrs{1} '   [' controlName ']'];
%     end
%     titleStrs{1} = [titleStrs{1} ': ' upper(names{i}) smallFontStr];
    titleStrs{1} = [bigFontStr upper(names{i}) smallFontStr];
    titleStrs(2:(length(dataStrs{i}) + 1)) = dataStrs{i};
    titles{i} = titleStrs;
    
    % Create the x-axis label.
%     xLabels{i} = [bigFontStr names{i} ' (' units{i} ') '];
    xLabels{i} = [bigFontStr units{i} ' '];
    
    % Create the histogram.
    if isempty(control)
        hists{i} = downSampleHistogram(wormHists(i));
    else
        hists{i} = downSampleHistogram([controlHists(i); wormHists(i)]);
    end
    histModes{i} = 1;
    sigColors{i} = p2BackColor(min(dataSigs{i}));
end

% Group the 4 drawings.
histColors = cell(length(wormHists), 1);
statColors = cell(length(wormHists), 1);
if length(hists) == 3
    
    % Re-order the existing drawings.
    oldI = 3;
    newI = 4;
    titles(newI) = titles(oldI);
    xLabels(newI) = xLabels(oldI);
    hists(newI) = hists(oldI);
    histModes(newI) = histModes(oldI);
    sigColors(newI) = sigColors(oldI);
    logModes = cell(4, 1);
    
    % Color the existing drawings.
    if isempty(control)
        histColors{1} = wormColor2(1,:);
        histColors{2} = wormColor2(2,:);
        histColors{4} = wormColor;
    else
        histColors{1} = [controlColor2(1,:); wormColor2(1,:)];
        histColors{2} = [controlColor2(2,:); wormColor2(2,:)];
        histColors{4} = [controlColor; wormColor];
    end
    for i = 1:length(histColors)
        statColors{i} = histColors{i} * statColorScale;
    end
    
    % Create the comparative titles.
    titleStrs = [];
    titleStrs{1} = [bigFontStr upper(['Inter vs. ' names{1}]) smallFontStr];
    titleStrs(2:(length(summaryStrs) + 1)) = summaryStrs;
    titles{3} = titleStrs;
%     xLabels{3} = [bigFontStr names{1} ' vs. ' names{2} ' (' units{1} ') '];
    xLabels{3} = [bigFontStr units{1} ' '];
    histModes{3} = 2;
    logModes{3} = 1;
    sigColors{3} = p2BackColor(min(summarySigs));

    % Create the comparative drawings.
    if isempty(control)
        hists{3} = downSampleHistogram([wormHists(1); wormHists(2)]);
        histColors{3} = wormColor2;
    else
        hists{3} = ...
            downSampleHistogram([controlHists(1); controlHists(2); ...
            wormHists(1); wormHists(2)]);
        histColors{3} = [controlColor2; wormColor2];
    end
    
% Group the 6 drawings.
else % length(dataFields) == 4

    % Re-order the existing drawings.
    oldI = [2 3 4];
    newI = [4 2 5];
    titles(newI) = titles(oldI);
    xLabels(newI) = xLabels(oldI);
    hists(newI) = hists(oldI);
    histModes(newI) = histModes(oldI);
    sigColors(newI) = sigColors(oldI);
    logModes = cell(6, 1);

    % Color the existing drawings.
    if isempty(control)
        histColors{1} = wormColor2(1,:);
        histColors{2} = wormColor2(2,:);
        histColors{4} = wormColor2(1,:);
        histColors{5} = wormColor2(2,:);
    else
        histColors{1} = [controlColor2(1,:); wormColor2(1,:)];
        histColors{2} = [controlColor2(2,:); wormColor2(2,:)];
        histColors{4} = [controlColor2(1,:); wormColor2(1,:)];
        histColors{5} = [controlColor2(2,:); wormColor2(2,:)];
    end
    for i = 1:length(histColors)
        statColors{i} = histColors{i} * statColorScale;
    end
    statColors{6} = [];

    % Create the comparative titles for the time.
    titleStrs = [];
    titleStrs{1} = [bigFontStr upper(['Inter vs. ' names{1}]) smallFontStr];
    titleStrs(2:4) = summaryStrs(1:3);
    titles{3} = titleStrs;
%     xLabels{3} = [bigFontStr names{1} ' vs. ' names{3} ' (' units{1} ') '];
    xLabels{3} = [bigFontStr units{1} ' '];
    histModes{3} = 2;
    logModes{3} = 1;
    sigColors{3} = p2BackColor(min(summarySigs(1:2)));

    % Create the comparative titles for the distance.
    titleStrs = [];
    titleStrs{1} = [bigFontStr upper(['Inter vs. ' names{2}]) smallFontStr];
    titleStrs(2:3) = summaryStrs([1,4]);
    titles{6} = titleStrs;
%     xLabels{6} = [bigFontStr names{2} ' vs. ' names{4} ' (' units{2} ') '];
    xLabels{6} = [bigFontStr units{2} ' '];
    histModes{6} = 2;
    logModes{6} = 1;
    sigColors{6} = p2BackColor(summarySigs(3));

    % Create the comparative drawings.
    if isempty(control)
        hists{3} = downSampleHistogram([wormHists(1); wormHists(3)]);
        hists{6} = downSampleHistogram([wormHists(2); wormHists(4)]);
        histColors{3} = wormColor2;
        histColors{6} = wormColor2;
    else
        hists{3} = ...
            downSampleHistogram([controlHists(1); controlHists(3); ...
            wormHists(1); wormHists(3)]);
        hists{6} = ...
            downSampleHistogram([controlHists(2); controlHists(4); ...
            wormHists(2); wormHists(4)]);
        histColors{3} = [controlColor2; wormColor2];
        histColors{6} = [controlColor2; wormColor2];
    end
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


% Draw the feature histograms.
for i = 1:length(hists)
    
    % Draw the data.
    subplot(2,3,i);
    hold on;
    plotHistogram(hists{i}, titles{i}, xLabels{i}, bigFontStr, [], ...
        histColors{i}, statColors{i}, histModes{i}, 0, 1, 1, logModes{i});
    
    % Embiggen the x-axis ticks.
    set(gca, 'FontSize', axisFontSize);
        
    % Color the significance.
    if ~isempty(sigColors{i})
        set(gca, 'Color', sigColors{i});
    end
end

% Draw the legend.
drawEventLegend(h);

% Save the figure.
if saveQuality > 0
    pageTitle = info2pageTitle(wormName, controlName, featureI, ...
        {disp.name}, dataInfo);
    saveTIF(h, filename, saveQuality, true, pageTitle, page, isClose);

% Close the figure.
elseif ~isShow || isClose
    close(h);
end
end



%% Show the simple legend.
function drawSimpleLegend(h)

% Initialize the drawing information.
fontSize = 20;
black = str2colors('k');
white = str2colors('w');
experimentColor = str2colors('n');
controlColor = str2colors('k');

% Setup the label information.
label = {
    ' \bfEXPERIMENT '
    ' \bfCONTROL '
    ' \bfn.s. '
    ' \bf*\rm (\itq \leq 0.05\rm) '
    ' \bf**\rm (\itq \leq 0.01\rm) '
    ' \bf***\rm (\itq \leq 0.001\rm) '
    ' \bf****\rm (\itq \leq 0.0001\rm) '};
backColor = {
    experimentColor
    controlColor
    white
    p2BackColor(0.03)
    p2BackColor(0.003)
    p2BackColor(0.0003)
    p2BackColor(0.00003)};
foreColor = {
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
yStart2 = 0.16;
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
    if i == 2
        yStart = yStart2 + i * yOff;
    end
end
end



%% Show the motion legend.
function drawMotionLegend(h)

% Initialize the drawing information.
fontSize = 20;
black = str2colors('k');
white = str2colors('w');
experimentColor = str2colors('n');
controlColor = str2colors('k');
forwardColor = str2colors('m');
pausedColor = str2colors('g', -1/3);
backwardColor = str2colors('b');

% Setup the label information.
label = {
    ' \bfEXPERIMENT '
    ' \bfCONTROL '
    ' \bfBACKWARD '
    ' \bfFORWARD '
    ' \bfPAUSED '
    ' \bfn.s. '
    ' \bf*\rm (\itq \leq 0.05\rm) '
    ' \bf**\rm (\itq \leq 0.01\rm) '
    ' \bf***\rm (\itq \leq 0.001\rm) '
    ' \bf****\rm (\itq \leq 0.0001\rm) '};
backColor = {
    experimentColor
    controlColor
    backwardColor
    forwardColor
    pausedColor
    white
    p2BackColor(0.03)
    p2BackColor(0.003)
    p2BackColor(0.0003)
    p2BackColor(0.00003)};
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
yStart2 = 0.55;
yStart3 = 0.16;
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
    if i == 2
        yStart = yStart2 + i * yOff;
    elseif i == 5
        yStart = yStart3 + i * yOff;
    end
end
end



%% Show the event legend.
function drawEventLegend(h)

% Initialize the drawing information.
fontSize = 20;
black = str2colors('k');
white = str2colors('w');
experimentColor = str2colors('n');
controlColor = str2colors('k');
eventColor = str2colors('g', -1/3);
interEventColor = str2colors('m', 0);
interControlColor = str2colors('k', 0.5);

% Setup the label information.
label = {
    ' \bfEXPERIMENT '
    ' \bfCONTROL '
    ' \bfINTER CONTROL'
    ' \bfINTER EVENT '
    ' \bfEVENT '
    ' \bfn.s. '
    ' \bf*\rm (\itq \leq 0.05\rm) '
    ' \bf**\rm (\itq \leq 0.01\rm) '
    ' \bf***\rm (\itq \leq 0.001\rm) '
    ' \bf****\rm (\itq \leq 0.0001\rm) '};
backColor = {
    experimentColor
    controlColor
    interControlColor
    interEventColor
    eventColor
    white
    p2BackColor(0.03)
    p2BackColor(0.003)
    p2BackColor(0.0003)
    p2BackColor(0.00003)};
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
yStart2 = 0.55;
yStart3 = 0.16;
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
    if i == 2
        yStart = yStart2 + i * yOff;
    elseif i == 5
        yStart = yStart3 + i * yOff;
    end
end
end



%% Convert a p-value to a foreground color representing significance.
function color = p2ForeColor(p)

% The p-value is not significant.
color = str2colors('c');

% Determine the significance of the p-value.
if p <= 0.0001
    color = str2colors('m');
elseif p <= 0.001
    color = str2colors('r');
elseif p <= 0.01
    color = str2colors('o');
elseif p <= 0.05
    color = str2colors('y');
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
sepStr = '   ¤   ';

% Initialize the fields.
fields = {
    'all'
    'abs'
    'pos'
    'neg'};

% Is the feature signed?
if ~isnan(worm.isSigned) && worm.isSigned
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

% Show the worm samples.
%str{1} = [str{1} sepStr 'WORMS=' num2str(worm.sets.samples, '%.0G')];
if isnan(worm.sets.samples)
    wormsStr = '0';
else
    wormsStr = num2str(worm.sets.samples, '%.3G');
end
str{1} = ['WORMS = ' wormsStr];

% Show the control samples.
if ~isempty(control)
    if isnan(control.sets.samples)
        controlsStr = '0';
    else
        controlsStr = num2str(control.sets.samples, '%.3G');
    end
    str{1} = [str{1} '   [' controlsStr ']'];
end

% Show the total worm samples.
if isnan(worm.allData.samples)
    wormsTotalStr = '0';
else
    wormsTotalStr = num2str(worm.allData.samples, '%.3G');
end
str{1} = [str{1} sepStr 'SAMPLES = ' wormsTotalStr];

% Show the total control samples.
if ~isempty(control)
    if isnan(control.allData.samples)
        controlsTotalStr = '0';
    else
        controlsTotalStr = num2str(control.allData.samples, '%.3G');
    end
    str{1} = [str{1} '   [' controlsTotalStr ']'];
end

% Determine the square root of the sample sets.
wormSqrt = sqrt(worm.sets.samples);
if ~isempty(control)
    controlSqrt = sqrt(control.sets.samples);
end

% Convert the statistics to strings.
for i = 1:endI
    
    % Determine the inequality between experiment and control.
    wormMean = worm.sets.mean.(fields{i});
    eqStr = '   ';
    if ~isempty(control)
        controlMean = control.sets.mean.(fields{i});
        if wormMean > controlMean
            %eqStr = ' > ';
            eqStr = ' >>> ';
        elseif wormMean < controlMean
            %eqStr = ' < ';
            eqStr = ' <<< ';
        end
    end
    
    % Don't show the inequality between experiment and control.
    sigStr = [];
    if isempty(sig)
        eqStr = '   ';
        
    % Determine the significance.
    else
        k = sigI + i - 1;
        sigs(i) = sig.q(k);
        
        % The significance was not measured.
        if isnan(sigs(i))
            eqStr = '   ';
            
        % Show the significance.
        else
            
%             % Determine the power.
%             if isnan(sig.power(k))
%                 betaStr = '1';
%             else
%                 betaStr = num2str(1 - sig.power(k), '%.2G');
%             end
            
            % Show the significance.
            sigStr = [sepStr '(p=' num2str(sig.p(k), '%.2G') ...
                ', q=' num2str(sig.q(k), '%.2G')];
%                 ', \beta=' betaStr];
            sigStr = [sigStr ')   ' p2stars(sigs(i))];
            
            % Don't show the inequality between experiment and control.
            if sigs(i) > 0.05
                eqStr = '   ';
            end
        end
    end
    
    % Determine the separator string.
    preStr = [];
%     if ~mod(i, 2)
%         preStr = sepStr;
%     end
    
    % Show the worm statistics.
    if isnan(wormMean)
        dataStr = 'NO DATA';
    else
        meanStr = num2str(wormMean, '%.3G');
        semStr = num2str(worm.sets.stdDev.(fields{i}) / wormSqrt, '%.3G');
        dataStr = [meanStr semChar semStr];
    end
%     j = floor((i + 3) / 2);
    j = i + 1;
    str{j} = [str{j} preStr upper(fields{i}) ' = ' dataStr];
    
    % Show the control statistics.
    if ~isempty(control)
        if isnan(controlMean)
            dataStr = 'NO DATA';
        else
            meanStr = num2str(controlMean, '%.3G');
            semStr = num2str(control.sets.stdDev.(fields{i}) / ...
                controlSqrt, '%.3G');
            dataStr = [meanStr semChar semStr];
        end
        str{j} = [str{j} eqStr '[' dataStr ']'];
        
    end
    
    % Show the significance.
    if sigs(i) > 0.05
        str{j} = [str{j} sigStr];
    else
        str{j} = ['\bf' str{j} sigStr '\rm'];
    end
end
end



%% Convert the event statistics to strings.
function [str sigs] = eventStats2strs(worms, isWormUsed, ...
    controls, isControlUsed, sig, sigI)

% Initialize special ascii symbols.
semChar = '±';
sepStr = '   ¤   ';

% Initialize the names.
names = {
    'FREQ'
    'TIME'
    'DIST'};

% Allocate memory.
str = cell(length(worms) + 1, 1);
sigs = nan(length(worms), 1);

% % Show the names.
% str{1} = wormName;
% if ~isempty(controlName)
%     str{1} = [str{1} ' [' controlName ']'];
% end

% Show the worm samples.
%str{1} = [str{1} sepStr 'WORMS=' num2str(wormHist.sets.samples, '%.0G')];
wormSamples = worms(1).samples;
if ~isempty(isWormUsed)
    wormSamples = sum(isWormUsed);
end
str{1} = ['WORMS = ' num2str(wormSamples, '%.3G')];

% Show the control samples.
if ~isempty(controls)
    controlSamples = controls(1).samples;
    if ~isempty(isControlUsed)
        controlSamples = sum(isControlUsed);
    end
    str{1} = [str{1} '   [' num2str(controlSamples, '%.3G') ']'];
end

% Determine the square root of the sample sets.
wormSqrt = sqrt(wormSamples);
if ~isempty(controls)
    controlSqrt = sqrt(controlSamples);
end

% Convert the statistics to strings.
for i = 1:length(worms)
    
    % Filter the worm data.
    wormData = worms(i).data;
    if ~isempty(isWormUsed)
        wormData = wormData(isWormUsed);
    end
    
    % Filter the control data.
    if ~isempty(controls)
        controlData = controls(i).data;
        if ~isempty(isControlUsed)
            controlData = controlData(isControlUsed);
        end
    end
    
    % Determine the inequality between experiment and control.
    wormMean = mean(wormData);
    eqStr = '   ';
    if ~isempty(controls)
        controlMean = mean(controlData);
        if wormMean > controlMean
            %eqStr = ' > ';
            eqStr = ' >>> ';
        elseif wormMean < controlMean
            %eqStr = ' < ';
            eqStr = ' <<< ';
        end
    end
    
    % Determine the separator string.
    preStr = [];
%     if ~mod(i, 2)
%         preStr = sepStr;
%     end

    % Show the data name.
    j = i + 1;
    str{j} = [str{j} preStr upper(names{i}) ' = ' ];
    
    % No data.
    if isnan(wormMean) && (isempty(controls) || isnan(controlMean))
        str{j} = [str{j} 'NO DATA'];
        sigs(i) = NaN;
        continue;
    end

    % Don't show the inequality between experiment and control.
    sigStr = [];
    if isempty(sig)
        eqStr = '   ';
        
    % Determine the significance.
    else
        k = sigI + i - 1;
        sigs(i) = sig.q(k);
        
        % The significance was not measured.
        if isnan(sigs(i))
            eqStr = '   ';
            
        % Show the significance.
        else
%             % Determine the power.
%             if isnan(sig.power(k))
%                 betaStr = '1';
%             else
%                 betaStr = num2str(1 - sig.power(k), '%.2G');
%             end
            
            % Show the significance.
            sigStr = [sepStr '(p=' num2str(sig.p(k), '%.2G') ...
                ', q=' num2str(sig.q(k), '%.2G')];
%                 ', \beta=' betaStr];
            sigStr = [sigStr ')   ' p2stars(sigs(i))];
            
            % Don't show the inequality between experiment and control.
            if sigs(i) > 0.05
                eqStr = '   ';
            end
        end
    end
    
    % Compute the worm statistics.
    sufStr = [];
    wormSEM = std(wormData) / wormSqrt;
    if i > 1
        wormMean  = wormMean * 100;
        wormSEM = wormSEM * 100;
        sufStr = '%';
    end
    
    % Show the worm statistics.
    if isnan(wormMean)
        dataStr = 'NO DATA';
    else
        meanStr = num2str(wormMean, '%.3G');
        semStr = num2str(wormSEM, '%.3G');
        dataStr = [meanStr semChar semStr sufStr];
    end
    str{j} = [str{j} dataStr];
    
    % Show the control statistics.
    if ~isempty(controls)
        
        % Compute the control statistics.
        controlSEM =  std(controlData) / controlSqrt;
        if i > 1
            controlMean  = controlMean * 100;
            controlSEM = controlSEM * 100;
        end
        
        % Show the control statistics.
        if isnan(controlMean)
            dataStr = 'NO DATA';
        else
            meanStr = num2str(controlMean, '%.3G');
            semStr = num2str(controlSEM, '%.3G');
            dataStr = [meanStr semChar semStr sufStr];
        end
        str{j} = [str{j} eqStr '[' dataStr ']'];
    end
    
    % Show the significance.
    if sigs(i) > 0.05
        str{j} = [str{j} sigStr];
    else
        str{j} = ['\bf' str{j} sigStr '\rm'];
    end
end
end



%% Convert information to a page title.
function str = info2pageTitle(wormName, controlName, featureI, ...
    featureNames, dataInfo)

% Add the names.
str = wormName;
if ~isempty(controlName)
    str = ['\it' str ' vs. ' controlName ' \rm'];
end
%str = [str ' &bull; '];
str = [str '   ¤   \bf'];

% Add the feature categories.
categories = unique([dataInfo(featureI).category]);
for i = 1:length(categories)
    
    % Add a separator.
    if i > 1
        str = [str ', '];
    end
    
    % Add the category.
    switch categories(i)
        case 'm'
            str  = [str 'MORPHOLOGY'];
        case 's'
            str  = [str 'POSTURE'];
        case 'l'
            str  = [str 'MOTION'];
        case 'p'
            str  = [str 'PATH'];
    end
end
str = [str ': '];

% Add the features.
for i = 1:length(featureI)
    
    % Add a separator.
    if i > 1
        str = [str ', '];
    end
    
    % Add the feature.
    str = [str featureNames{i}];
end

% Pad the title.
str = [str ' '];
end
