function [filename pages] = worm2TIF(filename, worm, wormName, varargin)
%WORM2TIF Save worm information to a TIF.
%
%   [FILENAME PAGES] = WORM2TIF(FILENAME, WORM, WORMNAME)
%
%   [FILENAME PAGES] = WORM2TIF(FILENAME, WORM, WORMNAME,
%                               WORMINFOFILTER, WORMFEATFILTER,
%                               WORMFEATDIR,
%                               CONTROL, CONTROLNAME,
%                               CONTROLINFOFILTER, CONTROLFEATFILTER,
%                               CONTROLFEATDIR,
%                               SIGNIFICANCE, ISSHOW, SAVEQUALITY, ISCLOSE,
%                               ISVERBOSE)
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
%       significance      - the feature statistical significance or filename;
%                           if empty; no statistical significance is shown
%                           if a struct, the fields are:
%
%                           p     = the p-value, per feature
%                           q     = the q-value, per feature
%                           power = the power, per feature
%
%       isShow            - are we showing the figures onscreen?
%                           Note: hiding the figures is faster.
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
    load(worm, 'wormInfo');
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

% Get the worm information filter.
wormInfoFilter = [];
if ~isempty(varargin)
    wormInfoFilter = varargin{1};
end

% Get the worm feature filter.
wormFeatFilter = [];
if length(varargin) > 1
    wormFeatFilter = varargin{2};
end

% Where should we search for the feature files?
wormFeatDir = [];
if length(varargin) > 2
    wormFeatDir = varargin{3};
end

% Do we have a control?
control = [];
controlName = [];
if length(varargin) > 3
    
    % Load the control.
    control = varargin{4};
    controlInfo = [];
    if ~isempty(control) && ischar(control)
        controlData = load(control, 'wormInfo');
        controlInfo = controlData.wormInfo;
        clear controlData;
    end
    
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
end

% Get the worm information filter.
controlInfoFilter = [];
if length(varargin) > 5
    controlInfoFilter = varargin{6};
end

% Get the worm feature filter.
controlFeatFilter = [];
if length(varargin) > 6
    controlFeatFilter = varargin{7};
end

% Where should we search for the feature files?
controlFeatDir = [];
if length(varargin) > 7
    controlFeatDir = varargin{8};
end

% Do we have the statistical significance?
significance = [];
if length(varargin) > 8
    significance = varargin{9};
end

% Are we showing the figures onscreen?
% Note: hiding the figures is faster.
isShow = true;
if length(varargin) > 9
    isShow = varargin{10};
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
            tifName = [wormName ' info'];
        else
            tifName = [wormName ' vs ' controlName ' info'];
        end
    end
    
    % Add the TIF extension.
    filename = [tifName '.tif'];

% We are not saving a file.
else
    filename = [];
end

% Create the table of contents and ontology information.
if isVerbose
    disp('Printing TOC and ontology ...');
end
page = 0;
[filename pages] = worm2TOCOntologyTIF(filename, worm, wormName, ...
    wormInfoFilter, wormFeatFilter, control, controlName, ...
    controlInfoFilter, controlFeatFilter, significance, isShow, page, ...
    saveQuality, isClose, isVerbose);

% Create the summary information.
if isVerbose
    disp('Printing summary ...');
end
page = page + pages;
[filename pages] = worm2summaryTIF(filename, worm, wormName, ...
    wormInfoFilter, wormFeatFilter, control, controlName, ...
    controlInfoFilter, controlFeatFilter, significance, isShow, page, ...
    saveQuality, isClose, isVerbose);

% Create the detailed information.
if isVerbose
    disp('Printing details ...');
end
page = page + pages;
[filename pages] = worm2detailsTIF(filename, worm, wormName, ...
    wormInfoFilter, wormFeatFilter, control, controlName, ...
    controlInfoFilter, controlFeatFilter, significance, isShow, page, ...
    saveQuality, isClose, isVerbose);

% Create the path information.
if isVerbose
    disp('Printing paths ...');
end
page = page + pages;
[filename pages] = worm2pathTIF(filename, worm, wormName, ...
    wormInfoFilter, wormFeatFilter, wormFeatDir, control, controlName, ...
    controlInfoFilter, controlFeatFilter, controlFeatDir, ...
    isShow, page, saveQuality, isClose, isVerbose);

% Create the methods information.
if isVerbose
    disp('Printing methods ...');
end
page = page + pages;
methodsTIF(filename, isShow, page, saveQuality, isClose, isVerbose);
end
