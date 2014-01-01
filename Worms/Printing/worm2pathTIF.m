function [filename pages] = worm2pathTIF(filename, worm, wormName, varargin)
%WORM2PATHTIF Save worm information to a TIF.
%
%   [FILENAME PAGES] = WORM2PATHTIF(FILENAME, WORM, WORMNAME)
%
%   [FILENAME PAGES] = WORM2PATHTIF(FILENAME, WORM, WORMNAME,
%                                   WORMINFOFILTER, WORMFEATFILTER,
%                                   WORMFEATDIR,
%                                   CONTROL, CONTROLNAME,
%                                   CONTROLINFOFILTER, CONTROLFEATFILTER,
%                                   CONTROLFEATDIR,
%                                   ISSHOW, PAGE, SAVEQUALITY, ISCLOSE,
%                                   ISVERBOSE)
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
%       wormFeatDir       - the directory to search for worm files;
%                           if empty, search in the current directory
%                           the default is the current directory (empty)
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
%       controlFeatDir    - the directory to search for control files;
%                           if empty, search in the current directory
%                           the default is the current directory (empty)
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

% Initialize drawing information.
maxPaths = 24;
speedI = 21:29; % the skeleton indices for speed
foragingI = 1:2; % the skeleton indices for foraging
speedLim = [-500, 500]; % the speed scale
foragingLim = [0, 90]; % the foraging amplitude magnitude scale
speedAlpha = 0.9; % the speed transparency
foragingAlpha = 0.9; % the foraging transparency

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
wormInfo = wormInfo(isWormUsed);

% Sort the worms.
dates = arrayfun(@(x) ...
    datenumEmpty2Zero(x.experiment.environment.timestamp), wormInfo);
[~, dateI] = sort(dates);
wormInfo = wormInfo(dateI);

% Where should we search for the feature files?
wormFeatDir = [];
if length(varargin) > 2
    wormFeatDir = varargin{3};
end

% Do we have a control?
control = [];
controlName = [];
controlInfo = [];
if length(varargin) > 3
    
    % Load the control.
    control = varargin{4};
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
        if length(varargin) > 4
            controlName = varargin{5};
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
        if length(varargin) > 5
            controlInfoFilter = varargin{6};
            isControlUsed = filterWormInfo(controlInfo, controlInfoFilter);
        end
        
        % Filter the control features.
        if length(varargin) > 6
            
            % Filter the worm features.
            controlFeatFilter = varargin{7};
            isUsed = filterWormHist(control, controlFeatFilter);
            
            % Combine the filters.
            if isempty(isControlUsed)
                isControlUsed = isUsed;
            else
                isControlUsed = isControlUsed & isUsed;
            end
        end
        controlInfo = controlInfo(isControlUsed);
        
        % Sort the controls.
        dates = arrayfun(@(x) ...
            datenumEmpty2Zero(x.experiment.environment.timestamp), ...
            controlInfo);
        [~, dateI] = sort(dates);
        controlInfo = controlInfo(dateI);
    end
    
    % Where should we search for the feature files?
    controlFeatDir = [];
    if length(varargin) > 7
        controlFeatDir = varargin{8};
    end
end

% Are we showing the figures onscreen?
% Note: hiding the figures is faster.
isShow = true;
if length(varargin) > 8
    isShow = varargin{9};
end

% Determine the page number.
pages = 0;
page = 0;
if length(varargin) > 9
    page = varargin{10};
    pages = page;
end

% Determine the quality (magnification) for saving the figures.
saveQuality = []; % don't save the figures
if length(varargin) > 10
    saveQuality = varargin{11};
end

% Are we closing the figures after saving them?
if saveQuality > 0
    isClose = true;
else
    isClose = false;
end
if length(varargin) > 11
    isClose = varargin{12};
end
if ~isShow
    isClose = true;
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 12
    isVerbose = varargin{13};
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
            tifName = [wormName ' path'];
        else
            tifName = [wormName ' vs ' controlName ' path'];
        end
    end
    
    % Add the TIF extension.
    filename = [tifName '.tif'];

% We are not saving a file.
else
    filename = [];
end

% Initialize the files and drawing information.
if length(wormInfo) > maxPaths
    wormInfo = wormInfo(round(linspace(1, length(wormInfo), maxPaths)));
end
if length(controlInfo) > maxPaths
    controlInfo = ...
        controlInfo(round(linspace(1, length(controlInfo), maxPaths)));
end

% Load the worm path information.
if isVerbose
    disp('Loading experiments ...');
end
[wormInfo, wormSkeleton, wormCoils, wormOmegas, ...
    wormSpeed, wormForaging] = loadWorms(wormFeatDir, wormInfo, isVerbose);
if isVerbose
    disp('Loading controls ...');
end
[controlInfo, controlSkeleton, controlCoils, controlOmegas, ...
    controlSpeed, controlForaging] = ...
    loadWorms(controlFeatDir, controlInfo, isVerbose);

% Translate the skeletons to a common origin.
% [xLims, yLims] = centerSkeletons(wormSkeleton, controlSkeleton);
% xLims = xLims ./ 1000;
% yLims = yLims ./ 1000;
xLims = [];
yLims = [];

% Draw the paths.
pageRows = 2;
pageCols = 3;
page = drawPaths(filename, page, ...
    wormName, wormInfo, ...
    wormSkeleton, wormCoils, wormOmegas, ...
    controlName, controlInfo, ...
    controlSkeleton, controlCoils, controlOmegas, ...
    xLims, yLims, isShow, saveQuality, isClose, isVerbose);
page = drawPath(filename, page, wormName, wormInfo, ...
    wormSkeleton, wormCoils, wormOmegas, xLims, yLims, ...
    pageRows, pageCols, isShow, saveQuality, isClose, isVerbose);
page = drawPath(filename, page, controlName, controlInfo, ...
    controlSkeleton, controlCoils, controlOmegas, xLims, yLims, ...
    pageRows, pageCols, isShow, saveQuality, isClose, isVerbose);

% Draw the speed.
dataName = 'Midbody Speed';
unitName = 'Microns/Seconds';
page = drawPathsData(filename, page, dataName, unitName, ...
    wormName, wormInfo, ...
    wormSkeleton, wormCoils, wormOmegas, ...
    controlName, controlInfo, ...
    controlSkeleton, controlCoils, controlOmegas, ...
    wormSpeed, controlSpeed, speedI, speedLim, speedAlpha, ...
    xLims, yLims, isShow, saveQuality, isClose, isVerbose);
page = drawPathData(filename, page, dataName, unitName, wormName, ...
    wormInfo, wormSkeleton, wormCoils, wormOmegas, ...
    speedI, wormSpeed, speedLim, speedAlpha, xLims, yLims, ...
    pageRows, pageCols, isShow, saveQuality, isClose, isVerbose);
page = drawPathData(filename, page, dataName, unitName, controlName, ...
    controlInfo, controlSkeleton, controlCoils, controlOmegas, ...
    speedI, controlSpeed, speedLim, speedAlpha, xLims, yLims, ...
    pageRows, pageCols, isShow, saveQuality, isClose, isVerbose);

% Draw the foraging.
dataName = 'Foraging Amplitude';
unitName = 'Degrees';
page = drawPathsData(filename, page, dataName, unitName, ...
    wormName, wormInfo, ...
    wormSkeleton, wormCoils, wormOmegas, ...
    controlName, controlInfo, ...
    controlSkeleton, controlCoils, controlOmegas, ...
    wormForaging, controlForaging, foragingI, foragingLim, foragingAlpha, ...
    xLims, yLims, isShow, saveQuality, isClose, isVerbose);
page = drawPathData(filename, page, dataName, unitName, wormName, ...
    wormInfo, wormSkeleton, wormCoils, wormOmegas, ...
    foragingI, wormForaging, foragingLim, foragingAlpha, xLims, yLims, ...
    pageRows, pageCols, isShow, saveQuality, isClose, isVerbose);
page = drawPathData(filename, page, dataName, unitName, controlName, ...
    controlInfo, controlSkeleton, controlCoils, controlOmegas, ...
    foragingI, controlForaging, foragingLim, foragingAlpha, xLims, yLims, ...
    pageRows, pageCols, isShow, saveQuality, isClose, isVerbose);

% Compute the pages.
pages = page - pages;
end



%% Translate the skeletons to a common origin.
function [xLims, yLims] = centerSkeletons(wormSkeleton, controlSkeleton)

% Translate the worm skeletons.
xMax = nan;
yMax = nan;
for i = 1:length(wormSkeleton)
    wormSkeleton{i}.x = wormSkeleton{i}.x - min(wormSkeleton{i}.x(:));
    wormSkeleton{i}.y = wormSkeleton{i}.y - min(wormSkeleton{i}.y(:));
    xMax = max(xMax, max(wormSkeleton{i}.x(:)));
    yMax = max(yMax, max(wormSkeleton{i}.y(:)));
end

% Translate the control skeletons.
for i = 1:length(controlSkeleton)
    controlSkeleton{i}.x = ...
        controlSkeleton{i}.x - min(controlSkeleton{i}.x(:));
    controlSkeleton{i}.y = ...
        controlSkeleton{i}.y - min(controlSkeleton{i}.y(:));
    xMax = max(xMax, max(controlSkeleton{i}.x(:)));
    yMax = max(yMax, max(controlSkeleton{i}.y(:)));
end

% Determine the axial limits.
xLims = [0, xMax];
yLims = [0, yMax];
end



%% Load the worm path information.
function [wormInfo, skeleton, coils, omegas, speed foraging] = ...
    loadWorms(featDir, wormInfo, isVerbose)

% Initialize the video extension.
videoExt = '.avi';

% Load the worm path information.
skeleton = cell(length(wormInfo), 1);
coils = cell(length(wormInfo), 1);
omegas = cell(length(wormInfo), 1);
speed = cell(length(wormInfo), 1);
foraging = cell(length(wormInfo), 1);
keepI = true(length(wormInfo), 1);
for i = 1:length(wormInfo)
    
    % Get the file name.
    file = wormInfo(i).files.video;
    sepI = strfind(file, '\');
    
    % Remove the directory
    if ~isempty(sepI)
        file = file((sepI(end) + 1):end);
    end
    
    % Fix the extension.
    if strcmp(file((end - length(videoExt) + 1):end), videoExt)
        file = file(1:(end - length(videoExt)));
    end
    file = [file '_features.mat'];
    
    % Display the progress.
    if isVerbose
        disp(['Loading ' num2str(i) '/' ...
            num2str(length(wormInfo)) ' "' file '" ...']);
    end

    % Find the file.
    if ~exist(file, 'file')
        files = rdir([featDir filesep '**' filesep file]);
        if length(files) ~= 1
            warning('worm2pathTIF:NoFile', strrep(['"' featDir ...
                '" does not contain a subdirectory with the file "' ...
                file '". The worm will not be used.'], '\', '\\'));
            keepI(i) = false;
            continue;
        end
        file = files.name;
    end
    
    % Load the file.
    worm = [];
    load(file, 'worm');
    
    % Get the worm features.
    if isempty(worm)
        warning('worm2pathTIF:NoWorm', ...
            ['"' file '" does not contain a "worm" and will not be used.']);
        keepI(i) = false;
        continue;
    end
    
    % Add the worm information.
    skeleton{i} = worm.posture.skeleton;
    coils{i} = worm.posture.coils;
    omegas{i} = worm.locomotion.turns.omegas;
    speed{i} = worm.locomotion.velocity.midbody.speed;
    foraging{i} = abs(worm.locomotion.bends.foraging.amplitude);
end

% Remove the missing worms.
wormInfo = wormInfo(keepI);
skeleton = skeleton(keepI);
coils = coils(keepI);
omegas = omegas(keepI);
speed = speed(keepI);
foraging = foraging(keepI);
end



%% Draw the worm multi-paths.
function page = drawPaths(filename, page, ...
    wormName, wormInfo, wormSkeleton, wormCoils, wormOmegas, ...
    controlName, controlInfo, controlSkeleton, controlCoils, controlOmegas, ...
    xLims, yLims, isShow, saveQuality, isClose, isVerbose)

% Do we have multiple worms?
if isempty(wormInfo) || (length(wormInfo) < 2 && length(controlInfo) < 2)
    return;
end

% Initialize special ascii symbols.
sepStr = '   ¤   ';
sepStr2 = '   \rightarrow   ';

% Initialize the path information.
centerMode = 1;
rotateMode = 2;
sortMode = -1;

% Determine the shape.
numWorms = max(length(wormInfo), length(controlInfo));
rows = ceil(sqrt(numWorms));
cols = ceil(numWorms / rows);
shapeMode = [rows, cols];

% Construct the titles.
wormTitleStr = ['\it' wormName ' \rm' sepStr2 ...
    '\bf' num2str(length(wormInfo)) ' Worms'];
wormPageStr = ['\it' wormName];
if ~isempty(controlInfo)
    controlTitleStr = ['\it' controlName ' \rm' sepStr2 ...
        '\bf' num2str(length(controlInfo)) ' Worms'];
    wormPageStr = [wormPageStr ' vs. ' controlName];
end
wormPageStr = [wormPageStr ' \rm'];


%% Draw the worm path overlay.

% Display the progress.
if isVerbose
    if isempty(controlName)
        disp(['Printing path overlay for "' wormName '" page 1/2 ...']);
    else
        disp(['Printing path overlay for "' wormName '" vs. "' ...
            controlName '" page 1/2 ...']);
    end
end

% Open a new figure.
page = page + 1;
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);

% Show the legend.
drawPathsLegend(h, true);

% Draw the worm path overlay.
if isempty(controlInfo)
    plotWormPath(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, xLims, yLims, ...
        centerMode, rotateMode, 0, 0, true, subplot(1, 1, 1, 'Parent', h));
    
% Draw the worm vs. control path overlay.
else
    
    % Draw the worm and control.
    wormAxes = plotWormPath(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, xLims, yLims, ...
        centerMode, rotateMode, 0, 0, true, subplot(1, 2, 1, 'Parent', h));
    controlAxes = plotWormPath(controlTitleStr, controlSkeleton, ...
        controlCoils, controlOmegas, xLims, yLims, ...
        centerMode, rotateMode, 0, 0, true, subplot(1, 2, 2, 'Parent', h));
    
    % Use a common scale.
    wormXLim = get(wormAxes, 'XLim');
    wormYLim = get(wormAxes, 'YLim');
    controlXLim = get(controlAxes, 'XLim');
    controlYLim = get(controlAxes, 'YLim');
    limX = [min(wormXLim(1), controlXLim(1)), ...
        max(wormXLim(2), controlXLim(2))];
    limY = [min(wormYLim(1), controlYLim(1)), ...
        max(wormYLim(2), controlYLim(2))];
    set(wormAxes, 'XLim', limX);
    set(wormAxes, 'YLim', limY);
    set(controlAxes, 'XLim', limX);
    set(controlAxes, 'YLim', limY);
end
    
% Save the figure.
if saveQuality > 0
    pageTitle = [wormPageStr sepStr '\bfPath Overlay'];
    saveTIF(h, filename, saveQuality, true, pageTitle, ...
        page, isClose);
    
% Close the figure.
elseif ~isShow || isClose
    close(h);
end



%% Draw multiple paths spaced out on a single figure.

% Display the progress.
if isVerbose
    if isempty(controlName)
        disp(['Printing path overview for "' wormName '" page 2/2 ...']);
    else
        disp(['Printing path overview for "' wormName '" vs. "' ...
            controlName '" page 2/2 ...']);
    end
end

% Open a new figure.
page = page + 1;
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);

% Show the legend.
drawPathsLegend(h, false);

% Draw the worm path overlay.
if isempty(controlInfo)
    plotWormPath(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, xLims, yLims, ...
        centerMode, rotateMode, shapeMode, sortMode, true, ...
        subplot(1, 1, 1, 'Parent', h));
    
% Draw the worm vs. control path overlay.
else
    
    % Draw the worm and control.
    wormAxes = plotWormPath(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, xLims, yLims, ...
        centerMode, rotateMode, shapeMode, sortMode, true, ...
        subplot(1, 2, 1, 'Parent', h));
    controlAxes = plotWormPath(controlTitleStr, controlSkeleton, ...
        controlCoils, controlOmegas, xLims, yLims, ...
        centerMode, rotateMode, shapeMode, sortMode, true, ...
        subplot(1, 2, 2, 'Parent', h));
    
    % Use a common scale.
%     wormXLim = get(wormAxes, 'XLim');
%     wormYLim = get(wormAxes, 'YLim');
%     controlXLim = get(controlAxes, 'XLim');
%     controlYLim = get(controlAxes, 'YLim');
%     limX = [min(wormXLim(1), controlXLim(1)), ...
%         max(wormXLim(2), controlXLim(2))];
%     limY = [min(wormYLim(1), controlYLim(1)), ...
%         max(wormYLim(2), controlYLim(2))];
%     set(wormAxes, 'XLim', limX);
%     set(wormAxes, 'YLim', limY);
%     set(controlAxes, 'XLim', limX);
%     set(controlAxes, 'YLim', limY);
end
    
% Save the figure.
if saveQuality > 0
    pageTitle = [wormPageStr sepStr '\bfPath Overview'];
    saveTIF(h, filename, saveQuality, true, pageTitle, ...
        page, isClose);
    
% Close the figure.
elseif ~isShow || isClose
    close(h);
end
end



%% Draw the worms path.
function page = drawPath(filename, page, wormName, wormInfo, skeleton, ...
    coils, omegas, xLims, yLims, rows, cols, ...
    isShow, saveQuality, isClose, isVerbose)

% Do we have any worms?
if isempty(wormInfo)
    return;
end

% Initialize special ascii symbols.
sepStr = '   ¤   ';
sepStr2 = '   \rightarrow   ';

% Initialize the path information.
centerMode = 1;
rotateMode = 0;

% Draw the paths.
pathsPerPage = rows * cols;
h = [];
for i = 1:length(wormInfo)
    
    % Find the path page index.
    pathI = mod(i - 1, pathsPerPage) + 1;
    
    % Are we creating a new figure?
    if pathI == 1
        
        % Save and/or close the previous figure.
        if i > 1
            
            % Save the figure.
            if saveQuality > 0
                pageTitle = ['\it' wormName ' \rm' sepStr '\bfPath'];
                saveTIF(h, filename, saveQuality, true, pageTitle, ...
                    page, isClose);
                
            % Close the figure.
            elseif ~isShow || isClose
                close(h);
            end
        end
        
        % Open a new figure.
        page = page + 1;
        h = figure;
        visStr = 'off';
        if isShow
            visStr = 'on';
        end
        set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
            'PaperType', 'A2', 'Visible', visStr);
        hold on;
        
        % Show the legend.
        drawPathLegend(h);
        
        % Display the progress.
        if isVerbose
            disp(['Printing path for "' wormName '" page ' ...
                num2str(ceil(i / pathsPerPage)) '/' ...
                num2str(ceil(length(wormInfo) / pathsPerPage)) ' ...']);
        end
    end
    
    % Draw the path.
    timestamp = wormInfo(i).experiment.environment.timestamp;
    dateStr = datestr(datenum(timestamp), 31);
    titleName = ['\it' wormName ' \rm' sepStr2 '\bf' dateStr];
    plotWormPath(titleName, skeleton{i}, coils{i}, omegas{i}, ...
        xLims, yLims, centerMode, rotateMode, 0, 0, false, ...
        subplot(rows, cols, pathI, 'Parent', h));
end

% Save the last figure.
if saveQuality > 0
    pageTitle = ['\it' wormName ' \rm' sepStr '\bfPath'];
    saveTIF(h, filename, saveQuality, true, pageTitle, ...
        page, isClose);
    
% Close the figure.
elseif ~isShow || isClose
    close(h);
end
end



%% Draw the worm multi-paths data.
function page = drawPathsData(filename, page, dataName, unitName, ...
    wormName, wormInfo, wormSkeleton, wormCoils, wormOmegas, ...
    controlName, controlInfo, controlSkeleton, controlCoils, controlOmegas, ...
    wormData, controlData, bodyI, dLim, alpha, xLims, yLims, ...
    isShow, saveQuality, isClose, isVerbose)

% Do we have multiple worms?
if isempty(wormInfo) || (length(wormInfo) < 2 && length(controlInfo) < 2)
    return;
end

% Initialize special ascii symbols.
sepStr = '   ¤   ';
sepStr2 = '   \rightarrow   ';

% Initialize the path information.
centerMode = 1;
rotateMode = 2;
sortMode = -1;

% Determine the shape.
numWorms = max(length(wormInfo), length(controlInfo));
rows = ceil(sqrt(numWorms));
cols = ceil(numWorms / rows);
shapeMode = [rows, cols];

% Construct the titles.
wormTitleStr = ['\it' wormName ' \rm' sepStr2 ...
    '\bf' num2str(length(wormInfo)) ' Worms'];
wormPageStr = ['\it' wormName];
if ~isempty(controlInfo)
    controlTitleStr = ['\it' controlName ' \rm' sepStr2 ...
        '\bf' num2str(length(controlInfo)) ' Worms'];
    wormPageStr = [wormPageStr ' vs. ' controlName];
end
wormPageStr = [wormPageStr ' \rm'];



%% Draw the worm path data overlay.

% Display the progress.
if isVerbose
    if isempty(controlName)
        disp(['Printing ' dataName ' overlay for "' wormName ...
            '" page 1/2 ...']);
    else
        disp(['Printing ' dataName ' overlay for "' wormName '" vs. "' ...
            controlName '" page 1/2 ...']);
    end
end

% Open a new figure.
page = page + 1;
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);

% Show the legend.
drawPathsDataLegend(h, dataName, unitName, dLim, true);

% Draw the worm path overlay.
if isempty(controlInfo)
    plotWormPathData(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, bodyI, wormData, dLim, alpha, ...
        xLims, yLims, centerMode, rotateMode, 0, 0, true, ...
        subplot(1, 1, 1, 'Parent', h));
    
% Draw the worm vs. control path overlay.
else
    
    % Draw the worm and control.
    wormAxes = plotWormPathData(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, bodyI, wormData, dLim, alpha, ...
        xLims, yLims, centerMode, rotateMode, 0, 0, true, ...
        subplot(1, 2, 1, 'Parent', h));
    controlAxes = plotWormPathData(controlTitleStr, controlSkeleton, ...
        controlCoils, controlOmegas, bodyI, controlData, dLim, alpha, ...
        xLims, yLims, centerMode, rotateMode, 0, 0, true, ...
        subplot(1, 2, 2, 'Parent', h));
    
    % Use a common scale.
    wormXLim = get(wormAxes, 'XLim');
    wormYLim = get(wormAxes, 'YLim');
    controlXLim = get(controlAxes, 'XLim');
    controlYLim = get(controlAxes, 'YLim');
    limX = [min(wormXLim(1), controlXLim(1)), ...
        max(wormXLim(2), controlXLim(2))];
    limY = [min(wormYLim(1), controlYLim(1)), ...
        max(wormYLim(2), controlYLim(2))];
    set(wormAxes, 'XLim', limX);
    set(wormAxes, 'YLim', limY);
    set(controlAxes, 'XLim', limX);
    set(controlAxes, 'YLim', limY);
end
    
% Save the figure.
if saveQuality > 0
    pageTitle = [wormPageStr sepStr '\bf' dataName ' Overlay'];
    saveTIF(h, filename, saveQuality, true, pageTitle, ...
        page, isClose);
    
% Close the figure.
elseif ~isShow || isClose
    close(h);
end



%% Draw multiple path data spaced out on a single figure.

% Display the progress.
if isVerbose
    if isempty(controlName)
        disp(['Printing ' dataName ' overview for "' wormName ...
            '" page 2/2 ...']);
    else
        disp(['Printing ' dataName ' overview for "' wormName '" vs. "' ...
            controlName '" page 2/2 ...']);
    end
end

% Open a new figure.
page = page + 1;
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);

% Show the legend.
drawPathsDataLegend(h, dataName, unitName, dLim, false);

% Draw the worm path overlay.
if isempty(controlInfo)
    plotWormPathData(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, bodyI, wormData, dLim, alpha, ...
        xLims, yLims, centerMode, rotateMode, shapeMode, sortMode, ...
        true, subplot(1, 1, 1, 'Parent', h));
    
% Draw the worm vs. control path overlay.
else
    
    % Draw the worm and control.
    wormAxes = plotWormPathData(wormTitleStr, wormSkeleton, ...
        wormCoils, wormOmegas, bodyI, wormData, dLim, alpha, ...
        xLims, yLims, centerMode, rotateMode, shapeMode, sortMode, ...
        true, subplot(1, 2, 1, 'Parent', h));
    controlAxes = plotWormPathData(controlTitleStr, controlSkeleton, ...
        controlCoils, controlOmegas, bodyI, controlData, dLim, alpha, ...
        xLims, yLims, centerMode, rotateMode, shapeMode, sortMode, ...
        true, subplot(1, 2, 2, 'Parent', h));
    
    % Use a common scale.
%     wormXLim = get(wormAxes, 'XLim');
%     wormYLim = get(wormAxes, 'YLim');
%     controlXLim = get(controlAxes, 'XLim');
%     controlYLim = get(controlAxes, 'YLim');
%     limX = [min(wormXLim(1), controlXLim(1)), ...
%         max(wormXLim(2), controlXLim(2))];
%     limY = [min(wormYLim(1), controlYLim(1)), ...
%         max(wormYLim(2), controlYLim(2))];
%     set(wormAxes, 'XLim', limX);
%     set(wormAxes, 'YLim', limY);
%     set(controlAxes, 'XLim', limX);
%     set(controlAxes, 'YLim', limY);
end
    
% Save the figure.
if saveQuality > 0
    pageTitle = [wormPageStr sepStr '\bf' dataName ' Overview'];
    saveTIF(h, filename, saveQuality, true, pageTitle, ...
        page, isClose);
    
% Close the figure.
elseif ~isShow || isClose
    close(h);
end
end



%% Draw the worms path data.
function page = drawPathData(filename, page, dataName, unitName, ...
    wormName, wormInfo, skeleton, coils, omegas, ...
    bodyI, data, dLim, alpha, xLims, yLims, rows, cols, ...
    isShow, saveQuality, isClose, isVerbose)

% Do we have any worms?
if isempty(wormInfo)
    return;
end

% Initialize special ascii symbols.
sepStr = '  ¤   ';
sepStr2 = '   \rightarrow   ';

% Initialize the path information.
centerMode = 1;
rotateMode = 0;

% Draw the paths.
pathsPerPage = rows * cols;
h = [];
for i = 1:length(wormInfo)
    
    % Find the path page index.
    pathI = mod(i - 1, pathsPerPage) + 1;
    
    % Are we creating a new figure?
    if pathI == 1
        
        % Save and/or close the previous figure.
        if i > 1
            
            % Save the figure.
            if saveQuality > 0
                pageTitle = ['\it' wormName ' \rm' sepStr '\bf' dataName];
                saveTIF(h, filename, saveQuality, true, pageTitle, ...
                    page, isClose);
                
            % Close the figure.
            elseif ~isShow || isClose
                close(h);
            end
        end
        
        % Open a new figure.
        page = page + 1;
        h = figure;
        visStr = 'off';
        if isShow
            visStr = 'on';
        end
        set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
            'PaperType', 'A2', 'Visible', visStr);
        hold on;
        
        % Show the legend.
        drawPathDataLegend(h, dataName, unitName, dLim);
        
        % Display the progress.
        if isVerbose
            disp(['Printing "' dataName '" for "' wormName '" page ' ...
                num2str(ceil(i / pathsPerPage)) '/' ...
                num2str(ceil(length(wormInfo) / pathsPerPage)) ' ...']);
        end
    end
    
    % Draw the path.
    timestamp = wormInfo(i).experiment.environment.timestamp;
    dateStr = datestr(datenum(timestamp), 31);
    titleName = ['\it' wormName ' \rm' sepStr2 '\bf' dateStr];
    plotWormPathData(titleName, skeleton{i}, coils{i}, omegas{i}, ...
        bodyI, data{i}, dLim, alpha, xLims, yLims, ...
        centerMode, rotateMode, 0, 0, false, ...
        subplot(rows, cols, pathI, 'Parent', h));
end

% Save the last figure.
if saveQuality > 0
    pageTitle = ['\it' wormName ' \rm' sepStr '\bf' dataName];
    saveTIF(h, filename, saveQuality, true, pageTitle, ...
        page, isClose);
    
% Close the figure.
elseif ~isShow || isClose
    close(h);
end
end



%% Show the multi-path legend.
function drawPathsLegend(h, isEvents)

% Initialize the drawing information.
fontSize = 24;
black = str2colors('k');
white = str2colors('w');
headColor = str2colors('m');
midbodyColor = str2colors('g');
tailColor = str2colors('b', 1/3);
firstColor = str2colors('k', 0.5);
lastColor = str2colors('k')';
coilColor = str2colors('n');
omegaColor = str2colors('n');

% Setup the label information.
label = {
    ' \bfMIDBODY '
    ' \bfHEAD '
    ' \bfTAIL '
    ' \bfSTART '
    ' \bfEND '
    ' \bfOMEGA = x '
    ' \bfCOIL = + '};
backColor = {
    midbodyColor
    headColor
    tailColor
    firstColor
    lastColor
    omegaColor
    coilColor};
foreColor = {
    black
    black
    black
    white
    white
    white
    white};

% Setup the margin.
xOff = 10^-3;
xPosOff = 1 - xOff;
textPosition = [xPosOff, 0, xOff, 1];
textAxis = axes('units', 'normalized', 'Position', textPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Are we showing events?
yStart = 0.99;
yStart2 = 0.155;
yStart3 = 0.072;
yOff = 0.033;
if ~isEvents
    label = label(1:(end - 2));
    backColor = backColor(1:(end - 2));
    foreColor = foreColor(1:(end - 2));
    yStart2 = yStart3;
end

% Draw the labels.
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
    if i == 3
        yStart = yStart2 + i * yOff;
    elseif i == 5
        yStart = yStart3 + i * yOff;
    end
end
end



%% Show the path legend.
function drawPathLegend(h)

% Initialize the drawing information.
fontSize = 32;
black = str2colors('k');
white = str2colors('w');
headColor = str2colors('m');
midbodyColor = str2colors('g');
tailColor = str2colors('b', 1/3);
firstColor = str2colors('k', 0.5);
lastColor = str2colors('k')';
coilColor = str2colors('n');
omegaColor = str2colors('n');

% Setup the label information.
label = {
    ' \bfMIDBODY '
    ' \bfHEAD '
    ' \bfTAIL '
    ' \bfOMEGA = x '
    ' \bfCOIL = + '
    ' \bfSTART '
    ' \bfEND '};
backColor = {
    midbodyColor
    headColor
    tailColor
    omegaColor
    coilColor
    firstColor
    lastColor};
foreColor = {
    black
    black
    black
    white
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
yStart = 0.99;
yStart2 = 0.5;
yStart3 = 0.36;
yOff = 0.05;
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
    if i == 3
        yStart = yStart2 + i * yOff;
    elseif i == 5
        yStart = yStart3 + i * yOff;
    end
end
end



%% Show the multi-path data legend.
function drawPathsDataLegend(h, dataName, unitName, dLim, isEvents)

% Initialize the drawing information.
nameFontSize = 20;
dataFontSize = 14;
legendFontSize = 24;
black = str2colors('k');
white = str2colors('w');
firstColor = str2colors('k', 0.5);
lastColor = str2colors('k')';
coilColor = str2colors('n');
omegaColor = str2colors('n');

% Setup the label information.
label = {
    ' \bfSTART '
    ' \bfEND '
    ' \bfOMEGA = x '
    ' \bfCOIL = + '};
backColor = {
    firstColor
    lastColor
    omegaColor
    coilColor};
foreColor = {
    white
    white
    white
    white};

% Setup the margin.
xOff = 10^-3;
xPosOff = 1 - xOff;
textPosition = [xPosOff, 0, xOff, 1];
textAxis = axes('units', 'normalized', 'Position', textPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the colorbar label.
yStart = .995;
nameStr = [' \bf' dataName '\rm  (\it' unitName '\rm) '];
text(xPosOff, yStart, nameStr, ...
    'FontSize', nameFontSize, ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', ...
    'BackgroundColor', white, ...
    'Color', black, ...
    'EdgeColor', 'k', ...
    'Parent', textAxis);
    
% Draw the colorbar.
yStart = 0.55;
barWidth = .02;
barHeight = 0.4;
barPosition = [xPosOff - barWidth, yStart, barWidth, barHeight];
colormap(textAxis, jet);
set(textAxis, 'CLim', dLim);
colorbar('peer', textAxis, 'Position', barPosition, ...
    'YAxisLocation', 'left', 'FontSize', dataFontSize);

% Are we showing events?
yStart = 0.155;
yStart2 = 0.072;
yOff = 0.033;
if ~isEvents
    label = label(1:(end - 2));
    backColor = backColor(1:(end - 2));
    foreColor = foreColor(1:(end - 2));
    yStart = yStart2;
end

% Draw the labels.
for i = 1:length(label)
    
    % Draw the label.
    text(xOff, yStart - (i - 1) * yOff, label{i}, ...
        'FontSize', legendFontSize, ...
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



%% Show the path data legend.
function drawPathDataLegend(h, dataName, unitName, dLim)

% Initialize the drawing information.
nameFontSize = 20;
dataFontSize = 16;
legendFontSize = 32;
black = str2colors('k');
white = str2colors('w');
firstColor = str2colors('k', 0.5);
lastColor = str2colors('k')';
coilColor = str2colors('n');
omegaColor = str2colors('n');

% Setup the label information.
label = {
    ' \bfOMEGA = x '
    ' \bfCOIL = + '
    ' \bfSTART '
    ' \bfEND '};
backColor = {
    omegaColor
    coilColor
    firstColor
    lastColor};
foreColor = {
    white
    white
    white
    white};

% Setup the margin.
xOff = 10^-3;
xPosOff = 1 - xOff;
textPosition = [xPosOff, 0, xOff, 1];
textAxis = axes('units', 'normalized', 'Position', textPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the colorbar label.
yStart = .995;
nameStr = [' \bf' dataName '\rm  (\it' unitName '\rm) '];
text(xPosOff, yStart, nameStr, ...
    'FontSize', nameFontSize, ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', ...
    'BackgroundColor', white, ...
    'Color', black, ...
    'EdgeColor', 'k', ...
    'Parent', textAxis);
    
% Draw the colorbar.
yStart = 0.55;
barWidth = .05;
barHeight = 0.4;
barPosition = [xPosOff - barWidth, yStart, barWidth, barHeight];
colormap(textAxis, jet);
set(textAxis, 'CLim', dLim);
colorbar('peer', textAxis, 'Position', barPosition, ...
    'YAxisLocation', 'left', 'FontSize', dataFontSize);

% Draw the labels.
yStart = 0.5;
yBreakOff = 0.04;
yOff = 0.05;
for i = 1:length(label)
    
    % Draw the label.
    text(xOff, yStart - (i - 1) * yOff, label{i}, ...
        'FontSize', legendFontSize, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', backColor{i}, ...
        'Color', foreColor{i}, ...
        'EdgeColor', 'k', ...
        'Parent', textAxis);
    
    % Put in a space.
    if i == 2
        yStart = yStart - yBreakOff;
    end
end
end
