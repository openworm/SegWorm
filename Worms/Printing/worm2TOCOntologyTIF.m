function [filename pages] = worm2TOCOntologyTIF(filename, worm, wormName, ...
    varargin)
%WORM2TOCONTOLOGYTIF Save worm details to a TIF.
%
%   [FILENAME PAGES] = WORM2TOCONTOLOGYTIF(FILENAME, WORM, WORMNAME)
%
%   [FILENAME PAGES] = WORM2TOCONTOLOGYTIF(FILENAME, WORM, WORMNAME,
%                                          WORMINFOFILTER, WORMFEATFILTER,
%                                          CONTROL, CONTROLNAME,
%                                          CONTROLINFOFILTER,
%                                          CONTROLFEATFILTER,
%                                          SIGNIFICANCE, ISSHOW, PAGE,
%                                          SAVEQUALITY, ISCLOSE, ISVERBOSE)
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

% Filter the worms.
if ~isempty(isWormUsed)
    wormInfo = wormInfo(isWormUsed);
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
        
        % Filter the controls.
        if ~isempty(isControlUsed)
            controlInfo = controlInfo(isControlUsed);
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
statTitle1I = [statsInfo.title1I];
statIndex = [statsInfo.index];


%% Create a figure.
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);
hold on;



%% Draw the table of contents.

% Display the progress.
if isVerbose
    disp('Printing table of contents 1/3 ...');
end

% Initialize the drawing information.
headerColor = str2colors('k', 0.5);
sigSepStr = '   ';
tocHeadHeight = 0.05;
tocHeadWidth = 0.5;
tocHeight = 1 - tocHeadHeight;
tocWidth = tocHeadWidth / 2;
fontSize1 = 32;
fontSize2 = 20;
fontSize3 = 14;
yStart = 0.99;
xOff1 = 0.99;
xOff2 = 0.93;
yOff = 0.0261;

% Initialize the feature categories.
morphologyStr = 'Morphology';
postureStr = 'Posture';
motionStr = 'Motion';
pathStr = 'Path';

% Draw the table of contents header.
tocHeadPosition = [0, tocHeight, tocHeadWidth, tocHeadHeight];
tocHeadAxis = axes('units', 'normalized', 'Position', tocHeadPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);
text(0.5, 0.5, ...
    [' \bf' upper('Table of Contents') ' '], ...
    'Color', headerColor, ...
    'FontSize', fontSize1, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'Parent', tocHeadAxis);

% Prepare the table of contents.
pageNum = page + 2;
pageI = 0;
tocPosition1 = [0, 0, tocWidth, tocHeight];
tocAxis1 = axes('units', 'normalized', 'Position', tocPosition1, ...
    'XTick', [], 'YTick', [], 'Parent', h);
tocPosition2 = [tocWidth, 0, tocWidth, tocHeight];
tocAxis2 = axes('units', 'normalized', 'Position', tocPosition2, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the summary table of contents header.
tocAxis = tocAxis1;
text(1 - xOff1, yStart - pageI * yOff, ...
    [' \bf' upper('Introduction') ' '], ...
    'FontSize', fontSize2, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'Parent', tocAxis);
pageI = pageI + 1;

% Draw the summary table of contents pages.
appendixPageName = {
    'Summary'};
pageOff = {
    3};
for i = 1:length(appendixPageName)
    
    % Draw the summary name.
    text(xOff2, yStart - pageI * yOff, ...
        [' ' appendixPageName{i} ' '], ...
        'FontSize', fontSize3, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'Parent', tocAxis);
    
    % Draw the page number.
    text(xOff1, yStart - pageI * yOff, ...
        [' ' num2str(pageNum) ' '], ...
        'FontSize', fontSize3, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'Parent', tocAxis);
    
    % Advance.
    pageI = pageI + 1;
    pageNum = pageNum + pageOff{i};
end

% Draw the feature table of contents.
category = [];
simpleNum = 0;
for i = 1:length(dataInfo)
    
    % Draw the category.
    if isempty(category) || dataInfo(i).category ~= category
        
        % Determine the category.
        category = dataInfo(i).category;
        switch category
            case 'm'
                categoryStr = morphologyStr;
            case 's'
                categoryStr = postureStr;
            case 'l'
                categoryStr = motionStr;
                
                % Start a new column.
                tocAxis = tocAxis2;
                pageI = 0;
                
            case 'p'
                categoryStr = pathStr;
        end
        
        % Draw the category.
        text(1 - xOff1, yStart - pageI * yOff, ...
            [' \bf' upper(categoryStr) ' '], ...
            'FontSize', fontSize2, ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', ...
            'Parent', tocAxis);
        
        % Advance.
        pageI = pageI + 1;
    end
    
    % Draw the feature.
    field = dataInfo(i).field;
    feature = getStructField(dispInfo, field);
    for j = 1:length(feature)
        
        % Get the significance.
        sigStr = [];
        if ~isempty(sig)
            
            % Find the minimum significance.
            isFeatSig = statTitle1I == i;
            if length(feature) > 1
                isFeatSig = isFeatSig & statIndex == j;
            end
            minSig = min(sig.q(isFeatSig));
            
            % Convert the significance to a string.
            if minSig <= 0.05
                sigStr = [ '\bf' p2stars(minSig) sigSepStr];
            else
                sigStr = '\it';
            end
        end
        
        % Draw the feature.
        text(xOff2, yStart - pageI * yOff, ...
            [' ' sigStr feature(j).name ' '], ...
            'FontSize', fontSize3, ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'top', ...
            'Parent', tocAxis);
        
        % Draw the page number.
        text(xOff1, yStart - pageI * yOff, ...
            [' ' num2str(pageNum) ' '], ...
            'FontSize', fontSize3, ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'top', ...
            'Parent', tocAxis);
        
        % Advance the simple feature.
        if dataInfo(i).type == 's'
            if simpleNum > 3;
                simpleNum = 0;
                pageNum = pageNum + 1;
            elseif i < length(dataInfo) && dataInfo(i + 1).type ~= 's'
                pageNum = pageNum + 1;
            end
            simpleNum = simpleNum + 1;
            
        % Advance.
        else
            pageNum = pageNum + 1;
        end
        pageI = pageI + 1;
    end
end

% Draw the path table of contents header.
text(1 - xOff1, yStart - pageI * yOff, ...
    [' \bf' upper('Path Plots') ' '], ...
    'FontSize', fontSize2, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'Parent', tocAxis);
pageI = pageI + 1;

% Compute the number of path pages.
maxPaths = 24;
pathsPerPage = 6;
wormPaths = min(length(wormInfo), maxPaths);
pathPages = ceil(wormPaths / pathsPerPage);
if ~isempty(isControlUsed)
    controlPaths = min(length(controlInfo), maxPaths);
    pathPages = pathPages + ceil(controlPaths / pathsPerPage);
end
if length(wormInfo) > 1 || sum(isControlUsed) > 1
    pathPages = pathPages + 2;
end

% Draw the path table of contents pages.
pathPageName = {
    'Head, Midbody, Tail'
    'Speed'
    'Foraging'};
for i = 1:length(pathPageName)
    
    % Draw the path name.
    text(xOff2, yStart - pageI * yOff, ...
        [' ' pathPageName{i} ' '], ...
        'FontSize', fontSize3, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'Parent', tocAxis);
    
    % Draw the page number.
    text(xOff1, yStart - pageI * yOff, ...
        [' ' num2str(pageNum) ' '], ...
        'FontSize', fontSize3, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'Parent', tocAxis);
    
    % Advance.
    pageI = pageI + 1;
    pageNum = pageNum + pathPages;
end

% Draw the appendix table of contents header.
text(1 - xOff1, yStart - pageI * yOff, ...
    [' \bf' upper('Appendix') ' '], ...
    'FontSize', fontSize2, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'Parent', tocAxis);
pageI = pageI + 1;

% Draw the appendix table of contents pages.
appendixPageName = {
    'Methods'};
for i = 1:length(appendixPageName)
    
    % Draw the appendix name.
    text(xOff2, yStart - pageI * yOff, ...
        [' ' appendixPageName{i} ' '], ...
        'FontSize', fontSize3, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'Parent', tocAxis);
    
    % Draw the page number.
    text(xOff1, yStart - pageI * yOff, ...
        [' ' num2str(pageNum) ' '], ...
        'FontSize', fontSize3, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'Parent', tocAxis);
    
    % Advance.
    pageI = pageI + 1;
    pageNum = pageNum + 1;
end



%% Draw the experiment annotation.

% Display the progress.
if isVerbose
    disp('Printing experiment information 2/3 ...');
end

% Initialize the drawing information.
expWidth = 0.5;
expHeight = 0.3;
expHeights = expHeight / 2;
xStart = tocWidth * 2;
yStart1 = 1 - expHeights;
yStart2 = 1 - expHeight;

% Do we have a control.
if isempty(control)
    expHeights = expHeight;
    yStart1 = yStart2;
end

% Prepare the annotation.
expPosition1 = [xStart, yStart1, expWidth, expHeights];
expAxis1 = axes('units', 'normalized', 'Position', expPosition1, ...
    'XTick', [], 'YTick', [], 'Parent', h);
if ~isempty(control)
    expPosition2 = [xStart, yStart2, expWidth, expHeights];
    expAxis2 = axes('units', 'normalized', 'Position', expPosition2, ...
        'XTick', [], 'YTick', [], 'Parent', h);
end

% Draw the experiment annotation.
drawExperiment(expAxis1, 'Experiment', wormInfo);

% Draw the control annotation.
if ~isempty(control)
%     controlInfo(1).experiment.worm.genotype = ...
%         strrep(wormInfo(1).experiment.worm.genotype, '), ', '), Not ');
    drawExperiment(expAxis2, 'Control', controlInfo);
end



%% Draw the contact information.

% Initialize the drawing information.
headColorStr = color2TeX(headerColor);
infoColorStr = color2TeX(str2colors('k'));
fontSize1 = 16;
fontSize2 = 14;
contactWidth = 0.5;
contactHeight = 0.1;
xStart = tocWidth * 2;
xOff = 0.01;
yOff = 0.15;
emailYOff = .95;
paperYOff = 0.05;

% Initialize the contact information.
emailStr = {[headColorStr 'For questions, please contact ' infoColorStr ...
    '\bfEviatar Yemini\rm' headColorStr ' at ' infoColorStr ...
    '\it\bfEv.Yemini.WT2@gmail.com']};
paperStr = {[headColorStr '\itPlease cite our publication: ' infoColorStr]
    '\bfYemini EI, Grundy LJ, Jucikas T, Brown AEX, Schafer WR'
    '\bfTitle ???'
    '\bfJournal ???'};

% Prepare the contact information.
contactPosition = [xStart, 0, contactWidth, contactHeight];
contactAxis = axes('units', 'normalized', 'Position', contactPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the contact information.
for i = 1:length(emailStr)
    text(xOff, emailYOff - (i - 1) * yOff, ...
        [' ' emailStr{i} ' '], ...
        'FontSize', fontSize1, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top', ...
        'Parent', contactAxis);
end

% Draw the paper information.
for i = 1:length(paperStr)
    text(xOff, paperYOff + (i - 1) * yOff, ...
        [' ' paperStr{length(paperStr) - i + 1} ' '], ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'bottom', ...
        'Parent', contactAxis);
end



%% Draw the ontology.

% Display the progress.
if isVerbose
    disp('Printing ontology 3/3 ...');
end

% Initialize the drawing information.
fontSize = 32;
ontHeadWidth = 0.5;
ontHeadHeight = 0.05;
ontWidth = ontHeadWidth / 2;
ontHeight = (1 - expHeight - ontHeadHeight - contactHeight) / 2;
xStart1 = tocWidth * 2;
xStart2 = xStart1 + ontWidth;
yStart1 = ontHeight * 2 + contactHeight;
yStart2 = ontHeight + contactHeight;
yStart3 = contactHeight;

% Draw the ontology header.
ontHeadPosition = [xStart1, yStart1, ontHeadWidth, ontHeadHeight];
ontHeadAxis = axes('units', 'normalized', 'Position', ontHeadPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);
text(0.5, 0.5, ...
    [' \bf' upper('Phenotype') ' '], ...
    'Color', headerColor, ...
    'FontSize', fontSize, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'Parent', ontHeadAxis);

% Prepare the annotation.
ontPosition1 = [xStart1, yStart2, ontWidth, ontHeight];
ontAxis1 = axes('units', 'normalized', 'Position', ontPosition1, ...
    'XTick', [], 'YTick', [], 'Parent', h);
ontPosition2 = [xStart2, yStart2, ontWidth, ontHeight];
ontAxis2 = axes('units', 'normalized', 'Position', ontPosition2, ...
    'XTick', [], 'YTick', [], 'Parent', h);
ontPosition3 = [xStart1, yStart3, ontWidth, ontHeight];
ontAxis3 = axes('units', 'normalized', 'Position', ontPosition3, ...
    'XTick', [], 'YTick', [], 'Parent', h);
ontPosition4 = [xStart2, yStart3, ontWidth, ontHeight];
ontAxis4 = axes('units', 'normalized', 'Position', ontPosition4, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Compute the ontology.
ontology = [];
if ~isempty(significance)
    genotype = worm2GenotypeLabel(wormInfo);
    ontology = wormStats2Ontology(significance, genotype, true);
    if length(ontology) > 1
        error('worm2TOCOntologTIF:Ontology', ...
            ['multiple genotypes match "' genotype '" for ontology']);
    end
end
    
% Annotate the experiment.
drawOntology(ontAxis1, 'Body', 'Body', ontology);
drawOntology(ontAxis2, 'Posture', 'Posture', ontology);
drawOntology(ontAxis3, 'Motion', 'Motion', ontology);
drawOntology(ontAxis4, 'Path', 'Path', ontology);



%% Draw the legends.

% Draw the table of contents legend.
drawTOCLegend(h);

% Draw the ontology legend.
if ~isempty(significance)
    drawOntologyLegend(h);
end



%% Save the page.

% Save the figure.
page = page + 1;
if saveQuality > 0
    saveTIF(h, filename, saveQuality, true, [], [], isClose);

% Close the figure.
elseif ~isShow || isClose
    close(h);
end

% Compute the pages.
pages = page - pages;
end



%% Draw the experiment.
function drawExperiment(expAxis, name, wormInfo)

% Initialize the drawing information.
nameColor = str2colors('k', 0.5);
infoColor = str2colors('k');
fontSize1 = 24;
fontSize2 = 18;
xStart1 = 0.05;
xStart2 = 0.2;
yStart = 0.7;
yOff = 0.2;

% Draw the header.
text(0, 1, ...
    [' \it\bf' upper(name) ' '], ...
    'FontSize', fontSize1, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'Parent', expAxis);

% Determine the worm information.
name = {
    'Strain'
    'Genotype'
    'Worms'};
info = {
    worm2StrainLabel(wormInfo)
    ['\it' worm2GenotypeLabel(wormInfo)]
    num2str(length(wormInfo))};

% Draw the worm information.
for i = 1:length(name)
    
    % Draw the information header.
    text(xStart1, yStart - (i - 1) * yOff, ...
        [' ' upper(name{i}) ': '], ...
        'Color', nameColor, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top', ...
        'Parent', expAxis);
    
    % Draw the information.
    text(xStart2, yStart - (i - 1) * yOff, ...
        [' \bf' info{i} ' '], ...
        'Color', infoColor, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top', ...
        'Parent', expAxis);
end
end



% Draw the ontology.
function drawOntology(ontologyAxis, name, category, ontology)

% Initialize the drawing information.
fontSize1 = 24;
fontSize2 = 18;
xStart1 = 0.1;
xStart2 = 0.2;
xStart3 = 0.25;
yStart = 0.97;
yOff = 0.08;
hAlign = 'left';
vAlign = 'top';

% No data.
if isempty(ontology)
    xStart3 = 0.5;
    yStart = 0.5 + yOff;
    hAlign = 'center';
    vAlign = 'middle';
    signs{1} = '';
    terms{1} = 'NO STATISTICS';
    stars{1} = '';
    colors{1} = str2colors('r');
    
% No significance.
elseif isempty(ontology.annotation)
    xStart3 = 0.5;
    yStart = 0.5 + yOff;
    hAlign = 'center';
    vAlign = 'middle';
    signs{1} = '';
    terms{1} = 'NOT SIGNIFICANT';
    stars{1} = '';
    colors{1} = str2colors('r');

% Find the categorical terms.
else
    categoryI = strcmp(category, {ontology.annotation.category});
    terms = {ontology.annotation(categoryI).term};
    qValues = cellfun(@min, {ontology.annotation(categoryI).qValues});
    stars = arrayfun(@p2stars, qValues, 'UniformOutput', false);
    signs = sign2str([ontology.annotation(categoryI).sign]);
    colors = sign2color([ontology.annotation(categoryI).sign]);
end

% Draw the category.
text(0.5, 1, ...
    [' \it\bf' upper(name) ' '], ...
    'FontSize', fontSize1, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'top', ...
    'Parent', ontologyAxis);

% Draw the terms.
for i = 1:length(terms)
    
    % Draw the stars.
    text(xStart1, yStart - i * yOff, ...
        [' ' stars{i} ' '], ...
        'Color', colors{i}, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', hAlign, ...
        'VerticalAlignment', vAlign, ...
        'Parent', ontologyAxis);

    % Draw the sign.
    text(xStart2, yStart - i * yOff, ...
        [' \bf' signs{i} ' '], ...
        'Color', colors{i}, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', hAlign, ...
        'VerticalAlignment', vAlign, ...
        'Parent', ontologyAxis);
    
    % Draw the term.
    text(xStart3, yStart - i * yOff, ...
         ...%[' \bf' terms{i} ' \rm' stars{i} ' '], ...
        [' \bf' terms{i} ' '], ...
        'Color', colors{i}, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', hAlign, ...
        'VerticalAlignment', vAlign, ...
        'Parent', ontologyAxis);
end
end



%% Show the table of contents legend.
function drawTOCLegend(h)

% Initialize the drawing information.
fontSize = 20;
black = str2colors('k');
white = str2colors('w');

% Setup the label information.
label = {
    ' \bfDORSAL (D) '
    ' \bfVENTRAL (V) '};
backColor = {
    black
    black};
foreColor = {
    white
    white};

% Setup the margin.
xOff = 10^-3;
xPosOff = 1 - xOff;
textPosition = [xPosOff, 0, xOff, 1];
textAxis = axes('units', 'normalized', 'Position', textPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the labels.
yStart = 0.955;
yOff = 0.035;
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
end
end



%% Show the ontology legend.
function drawOntologyLegend(h)

% Initialize the drawing information.
fontSize = 20;
black = str2colors('k');
white = str2colors('w');
negColor = str2colors('b');
posColor = str2colors('m');
zeroColor = str2colors('g', -1/3);

% Setup the label information.
label = {
    ' \bfLESS (-) '
    ' \bfMORE (+) '
    ' \bfDIFFERENT (\Delta) '};
backColor = {
    negColor
    posColor
    zeroColor};
foreColor = {
    white
    white
    white};

% Setup the margin.
xOff = 10^-3;
xPosOff = 1 - xOff;
textPosition = [xPosOff, 0, xOff, 1];
textAxis = axes('units', 'normalized', 'Position', textPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the labels.
yStart = 0.824;
yOff = 0.035;
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
end
end



%% Convert signs to strings.
function str = sign2str(signs)
str = cell(length(signs), 1);
for i = 1:length(signs)
    if signs(i) < 0
        str{i} = '-';
    elseif signs(i) > 0
        str{i} = '+';
    else
        str{i} = '\Delta';
    end
end
end

%% Convert signs to colors.
function color = sign2color(signs)

% Initialize the colors.
negColor = str2colors('b');
posColor = str2colors('m');
zeroColor = str2colors('g', -1/3);

% Convert the signs to colors.
color = cell(length(signs), 1);
for i = 1:length(signs)
    if signs(i) < 0
        color{i} = negColor;
    elseif signs(i) > 0
        color{i} = posColor;
    else
        color{i} = zeroColor;
    end
end
end
