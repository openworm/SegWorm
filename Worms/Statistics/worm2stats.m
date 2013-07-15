function worm2stats(filename, wormFiles, varargin)
%WORM2STATS Convert worms to a set of statistics.
%
%   WORMS2STATS(FILENAME, WORMFILES)
%
%   WORMS2STATS(FILENAME, WORMFILES, CONTROLFILES)
%
%   WORMS2STATS(FILENAME, WORMFILES, CONTROLFILES, ISOLDCONTROL)
%
%   WORMS2STATS(FILENAME, WORMFILES, CONTROLFILES, ISOLDCONTROL, VERBOSE)
%
%   Inputs:
%       filename     - the file name for the statistics;
%                      the file includes:
%
%                      wormInfo    = the worm information
%                      worm        = the worm statistics
%                      controlInfo = the control information (if it exists)
%                      worm        = the control statistics (if they exist)
%
%       wormFiles    - the histogram files to use for the worm(s)
%       controlFiles - the histogram files to use for the control(s);
%                      if empty, the worm has no new control
%       isOldControl - are we adding the old controls?
%                      the default is yes (true)
%       isVerbose    - verbose mode display the progress;
%                      the default is no (false)
%
% See also WORM2HISTOGRAM, HISTOGRAM, WORMDISPLAYINFO, WORMDATAINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Do we have a control?
controlFiles = [];
if ~isempty(varargin)
    controlFiles = varargin{1};
end

% Are we adding the old controls?
isOldControl = true;
if length(varargin) > 1
    isOldControl = varargin{2};
end

% Are we in verbose mode?
isVerbose = false;
if length(varargin) > 2
    isVerbose = varargin{3};
end

% Organize the worm files.
if ~iscell(wormFiles)
    wormFiles = {wormFiles};
end
if ~isempty(controlFiles) && ~iscell(controlFiles)
    controlFiles = {controlFiles};
end

% Delete the file if it already exists.
if exist(filename, 'file')
    delete(filename);
end

% Save the worm information.
if isVerbose
    disp('Combining "wormInfo" ...');
end
newWormInfo = [];
for i = 1:length(wormFiles)
    wormInfo = [];
    load(wormFiles{i}, 'wormInfo');
    newWormInfo = cat(1, newWormInfo, wormInfo);
end
wormInfo = newWormInfo;
save(filename, 'wormInfo');
clear wormInfo;

% Collect the new control information.
if isVerbose
    disp('Combining "controlInfo" ...');
end
newControlInfo = [];
if ~isempty(controlFiles)
    for i = 1:length(controlFiles)
        wormInfo = [];
        load(controlFiles{i}, 'wormInfo');
        newControlInfo =  cat(1, newControlInfo, wormInfo);
    end
end

% Collect the old control information.
if isOldControl
    for i = 1:length(wormFiles)
        controlInfo = who('-FILE', wormFiles{i}, 'controlInfo');
        if ~isempty(controlInfo)
            load(wormFiles{i}, 'controlInfo');
            newControlInfo =  cat(1, newControlInfo, controlInfo);
        end
    end
end

% Save the control information.
if ~isempty(newControlInfo)
    controlInfo = newControlInfo;
    save(filename, 'controlInfo', '-append');
end
clear controlInfo;

% Initialize the data information.
dataInfo = wormDataInfo();

% Save the worm statistics.
saveStatistics(filename, wormFiles, dataInfo, 'worm', 'worm', isVerbose);

% Are we adding the old controls?
if isOldControl
    
    % Initialize the new control names.
    controlNames = cell(length(controlFiles), 1);
    for i = 1:length(controlFiles)
        controlNames{i} = 'worm';
    end
    
    % Initialize the old control names.
    for i = 1:length(wormFiles)
        control = who('-FILE', wormFiles{i}, 'control');
        if ~isempty(control)
            controlFiles{end + 1} = wormFiles{i};
            controlNames{end + 1} = 'control';
        end
    end
    
% Initialize the new control names.
else
    controlNames = 'worm';
end

% Save the control statistics.
if ~isempty(controlFiles)
    saveStatistics(filename, controlFiles, dataInfo, controlNames, ...
        'control', isVerbose);
end
end



%% Load worm data from files.
function data = loadWormFiles(filenames, wormName, field)

% Fix the data.
if ~iscell(wormName)
    wormName = {wormName};
end

% Load each worm by name.
if length(wormName) > 1
    data = cell(length(wormName), 1);
    for i = 1:length(wormName)
        data{i} = loadStructField(filenames{i}, wormName{i}, field);
    end
    
% Load all worms using the same name.
else
    data = cellfun(@(x) loadStructField(x, wormName{1}, field), ...
        filenames, 'UniformOutput', false);
end
end



%% Save the worm statistics.
function saveStatistics(filename, wormFiles, dataInfo, loadName, ...
    saveName, isVerbose)

% Initialize the locomotion modes.
motionNames = { ...
    'forward', ...
    'paused', ...
    'backward'};

% Combine the statistics.
for i = 1:length(dataInfo)
    field = dataInfo(i).field;
    if isVerbose
        disp(['Combining "' field '" ...']);
    end
    switch dataInfo(i).type
        
        % Combine simple statistics.
        case 's'
            data = addStatistics(wormFiles, loadName, field);
            eval([saveName '.' field '=data;']);
            
        % Combine motion statistics.
        case 'm'
            data = addMotionStatistics(wormFiles, loadName, field, ...
                motionNames);
            eval([saveName '.' field '=data;']);
            
        % Combine event statistics.
        case 'e'
            
            % Combine the event data statistics.
            subFields = dataInfo(i).subFields.summary;
            for j = 1:length(subFields);
                subField = [field '.' subFields{j}];
                data = addEventStatistics(wormFiles, loadName, subField);
                eval([saveName '.' subField '=data;']);
            end
            
            % Combine the event statistics.
            subFields = dataInfo(i).subFields.data;
            for j = 1:length(subFields);
                subField = [field '.' subFields{j}];
                data = addStatistics(wormFiles, loadName, subField);
                eval([saveName '.' subField '=data;']);
            end
    end
end

% Save the statistics.
save(filename, saveName, '-append');
end



%% Combine statistics.
function data = addStatistics(wormFiles, wormName, field)
addData = loadWormFiles(wormFiles, wormName, field);
data(length(addData{1})).statistics = [];
for i = 1:length(addData{1})
    subData = cellfun(@(x) x(i).histogram, addData, 'UniformOutput', false);
    data(i).statistics = addStatisticsData(subData);
end
end



%% Combine motion statistics.
function data = addMotionStatistics(wormFiles, wormName, field, motionNames)

% Initialize the data.
data.statistics = [];
for i = 1:length(motionNames)
    data.(motionNames{i}).statistics = [];
end

% Get the data.
addData = loadWormFiles(wormFiles, wormName, field);
if isempty(addData)
    return;
end

% Combine the statistics.
data(length(addData{1})).statistics = [];
for i = 1:length(addData{1})
    
    % Combine the data statistics.
    subData = cellfun(@(x) x(i).histogram, addData, 'UniformOutput', false);
    data(i).statistics = addStatisticsData(subData);
    
    % Combine the motion statistics.
    for j = 1:length(motionNames)
        subData = cellfun(@(x) x(i).(motionNames{j}).histogram, addData, ...
            'UniformOutput', false);
        data(i).(motionNames{j}).statistics = addStatisticsData(subData);
    end
end
end



%% Combine statistics.
function data = addStatisticsData(addData)

% Is the data signed?
data = [];
isSigned = [];
numSets = 0;
for i = 1:length(addData)
    
    % Add the set.
    if isempty(addData{i})
        numSets = numSets + 1;
        
    % Sign the data.
    else
        % Add the sets.
        numSets = numSets + length(addData{i});
        
        % Sign the data.
        if ~isempty(addData{i}.isSigned) && ~isnan(addData{i}.isSigned)
            if isempty(isSigned)
                isSigned = addData{i}.isSigned;
            elseif ~addData{i}.isSigned
                isSigned = false;
            end
        end
    end
end

% Is there any data?
if isempty(isSigned)
    data = nanHistogram(numSets);
    data = rmfield(data, ...
        {'sets', 'allData', 'PDF', 'bins', 'resolution', 'isZeroBin'});
    return;
end

% Initialize the statistics.
% Note: this must match the field order in worm2histogram.
data.data = [];
data.isSigned = isSigned;

% Combine the data.
data.data.samples = [];
data.data.mean.all = [];
data.data.stdDev.all = [];
for i = 1:length(addData)
    if isempty(addData{i})
        data.data.samples = cat(1, data.data.samples, 0);
        data.data.mean.all = cat(1, data.data.mean.all, NaN);
        data.data.stdDev.all = cat(1, data.data.stdDev.all, NaN);
    else
        data.data.samples = ...
            cat(1, data.data.samples, addData{i}.data.samples);
        data.data.mean.all = ...
            cat(1, data.data.mean.all, addData{i}.data.mean.all);
        data.data.stdDev.all = ...
            cat(1, data.data.stdDev.all, addData{i}.data.stdDev.all);
    end
end
if isSigned
    data.data.mean.abs = [];
    data.data.stdDev.abs = [];
    data.data.mean.pos = [];
    data.data.stdDev.pos = [];
    data.data.mean.neg = [];
    data.data.stdDev.neg = [];
    for i = 1:length(addData)
        if isempty(addData{i})
            data.data.mean.abs = cat(1, data.data.mean.abs, NaN);
            data.data.stdDev.abs = cat(1, data.data.stdDev.abs, NaN);
            data.data.mean.pos = cat(1, data.data.mean.pos, NaN);
            data.data.stdDev.pos = cat(1, data.data.stdDev.pos, NaN);
            data.data.mean.neg = cat(1, data.data.mean.neg, NaN);
            data.data.stdDev.neg = cat(1, data.data.stdDev.neg, NaN);
        else
            data.data.mean.abs = ...
                cat(1, data.data.mean.abs, addData{i}.data.mean.abs);
            data.data.stdDev.abs = ...
                cat(1, data.data.stdDev.abs, addData{i}.data.stdDev.abs);
            data.data.mean.pos = ...
                cat(1, data.data.mean.pos, addData{i}.data.mean.pos);
            data.data.stdDev.pos = ...
                cat(1, data.data.stdDev.pos, addData{i}.data.stdDev.pos);
            data.data.mean.neg = ...
                cat(1, data.data.mean.neg, addData{i}.data.mean.neg);
            data.data.stdDev.neg = ...
                cat(1, data.data.stdDev.neg, addData{i}.data.stdDev.neg);
        end
    end
end
end



%% Combine event data statistics.
function data = addEventStatistics(wormFiles, wormName, field)

% Initialize the combined statistics.
addData = loadWormFiles(wormFiles, wormName, field);
data = [];
if isempty(addData)
    data.data = NaN;
    return;
end

% Combine the data.
data.data = [];
for i = 1:length(addData)
    if isempty(addData{i})
        data.data = cat(1, data.data, NaN);
    else
        data.data = cat(1, data.data, addData{i}.data);
    end
end
end
