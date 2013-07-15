function worm2NormTimes(filename, seconds, wormFiles, varargin)
%WORM2NORMTIMES Normalize worm feature time series.
%
%   WORM2NORMTIMES(FILENAME, SECONDS, WORMFILES)
%
%   WORM2NORMTIMES(FILENAME, SECONDS, WORMFILES, CONTROLFILES)
%
%   WORM2NORMTIMES(FILENAME, SECONDS, WORMFILES, CONTROLFILES,
%                  ISOLDCONTROL)
%
%   WORM2NORMTIMES(FILENAME, SECONDS, WORMFILES, CONTROLFILES,
%                  ISOLDCONTROL, ISSAVEMEMORY, VERBOSE)
%
%   WORM2NORMTIMES(FILENAME, SECONDS, WORMFILES, CONTROLFILES,
%                  ISOLDCONTROL, ISSAVEMEMORY, VERBOSE)
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
%       seconds      - the time bin size in seconds
%       wormFiles    - the histogram files to use for the worm(s)
%       controlFiles - the histogram files to use for the control(s);
%                      if empty, the worm has no new control
%       isOldControl - are we adding the old controls?
%                      the default is no (false)
%       isSaveMemory - are we conserving memory?
%                      if yes, each feature is loaded, as needed, from disk
%                      if no, all the features are loaded at once
%                      the default is no (false)
%       isVerbose    - verbose mode display the progress;
%                      the default is yes (true)
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
isOldControl = false;
if length(varargin) > 1
    isOldControl = varargin{2};
end

% Are we conserving memory?
isSaveMemory = false;
if length(varargin) > 2
    isSaveMemory = varargin{3};
end

% Are we in verbose mode?
isVerbose = true;
if length(varargin) > 3
    isVerbose = varargin{4};
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
newFPS = 1.0 / double(seconds);
isNormWorm = [];
wormFrames = [];
wormScales = [];
newWormInfo = [];
for i = 1:length(wormFiles)
    
    % Load the worm information.
    wormInfo = who('-FILE', wormFiles{i}, 'wormInfo');
    if isempty(wormInfo)
        isNormWorm = cat(1, isNormWorm, false);
        info = [];
        load(wormFiles{i}, 'info');
        wormInfo = info;
    else
        isNormWorm = cat(1, isNormWorm, true);
        load(wormFiles{i}, 'wormInfo');
    end
    
    % Can the features be downsampled?
    fps = arrayfun(@(x) x.video.resolution.fps, wormInfo);
    if any(round(double(newFPS) / double(fps)) > 1)
        error('worm2NormTimes:FrameRate', ['"' wormFiles{i} ...
            '" is sampled at ' num2str(fps) ...
            ' frames/second and cannot be downsampled to ' ...
            num2str(newFPS) ' frames/second']);
    end
    
    % Compute the new frames/seconds.
    frames = arrayfun(@(x) x.video.length.frames, wormInfo);
    wormFrames{end + 1} = frames;
    scales = round(fps * seconds);
    wormScales{end + 1} = scales;
    for j = 1:length(wormInfo)
        wormInfo(j).video.resolution.fps = fps(j) ./ scales(j);
    end
    
    % Save the worm information.
    newWormInfo = cat(1, newWormInfo, wormInfo);
end

% Collect the new control information.
if isVerbose
    disp('Combining "controlInfo" ...');
end
isNormControl = [];
controlFrames = [];
controlScales = [];
newControlInfo = [];
if ~isempty(controlFiles)
    for i = 1:length(controlFiles)
        
        % Load the worm information.
        controlInfo = who('-FILE', controlFiles{i}, 'wormInfo');
        if isempty(controlInfo)
            isNormControl = cat(1, isNormControl, false);
            info = [];
            load(controlFiles{i}, 'info');
            controlInfo = info;
        else
            isNormControl = cat(1, isNormControl, true);
            load(controlFiles{i}, 'wormInfo');
            controlInfo = wormInfo;
        end
        
        % Can the features be downsampled?
        fps = arrayfun(@(x) x.video.resolution.fps, controlInfo);
        if any(round(double(newFPS) / double(fps)) > 1)
            error('worm2NormTimes:FrameRate', ['"' controlFiles{i} ...
                '" is sampled at ' num2str(fps) ...
                ' frames/second and cannot be downsampled to ' ...
                num2str(newFPS) ' frames/second']);
        end
        
        % Compute the new frames/seconds.
        frames = arrayfun(@(x) x.video.length.frames, controlInfo);
        controlFrames{end + 1} = frames;
        scales = round(fps * seconds);
        controlScales{end + 1} = scales;
        for j = 1:length(controlInfo)
            controlInfo(j).video.resolution.fps = fps(j) ./ scales(j);
        end
        
        % Save the worm information.
        newControlInfo = cat(1, newControlInfo, wormInfo);
    end
end

% Collect the old control information.
if isOldControl
    for i = 1:length(wormFiles)
        if isNormWorm(i)
            
            % Load the worm information.
            controlInfo = [];
            load(wormFiles{i}, 'controlInfo');
            if ~isempty(controlInfo)
                isNormControl = cat(1, isNormControl, true);
            
                % Can the features be downsampled?
                fps = arrayfun(@(x) x.video.resolution.fps, controlInfo);
                if any(round(double(newFPS) / double(fps)) > 1)
                    error('worm2NormTimes:FrameRate', ['"' wormFiles{i} ...
                        '" is sampled at ' num2str(fps) ...
                        ' frames/second and cannot be downsampled to ' ...
                        num2str(newFPS) ' frames/second']);
                end
                
                % Compute the new frames/seconds.
                frames = arrayfun(@(x) x.video.length.frames, controlInfo);
                controlFrames{end + 1} = frames;
                scales = round(fps * seconds);
                controlScales{end + 1} = scales;
                for j = 1:length(controlInfo)
                    controlInfo(j).video.resolution.fps = ...
                        fps(j) ./ scales(j);
                end
                
                % Save the worm information.
                newControlInfo =  cat(1, newControlInfo, controlInfo);
            end
        end
    end
end

% Save the worm information.
wormInfo = newWormInfo;
if isempty(newControlInfo)
    save(filename, 'wormInfo');
else
    controlInfo = newControlInfo;
    save(filename, 'wormInfo', 'controlInfo');
    clear newControlInfo;
    clear controlInfo;
end
clear newWormInfo;
clear wormInfo;

% Initialize the worm data information.
histInfo = wormDisplayInfo();
dataInfo = wormDataInfo();

% Load the worm file data into memory.
wormFileData = [];
if ~isSaveMemory
    for i = 1:length(wormFiles)
        worm = [];
        load(wormFiles{i}, 'worm');
        wormFileData = cat(1, wormFileData, worm);
    end
end

% Save the normalized worm features.
if isempty(wormFileData)
    saveFeatures(filename, wormScales, wormFrames, isNormWorm, ...
        wormFiles, histInfo, dataInfo, 'worm', 'worm', isVerbose);
else
    saveFeatures(filename, wormScales, wormFrames, isNormWorm, ...
        wormFileData, histInfo, dataInfo, 'worm', 'worm', isVerbose);
end

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

% Load the control file data into memory.
controlFileData = [];
if ~isSaveMemory
    for i = 1:length(controlFiles)
        worm = [];
        load(controlFiles{i}, controlNames{i});
        controlFileData = cat(1, controlFileData, worm);
    end
end

% Save the normalized control features.
if ~isempty(controlFiles)
    if isempty(controlFileData)
        saveFeatures(filename, controlScales, controlFrames, ...
            isNormControl, controlFiles, histInfo, dataInfo, ...
            controlNames, 'control', isVerbose);
    else
        saveFeatures(filename, controlScales, controlFrames, ...
            isNormControl, controlFileData, histInfo, dataInfo, ...
            controlNames, 'control', isVerbose);
    end
end
end



%% Load worm data from files.
% varargin = empty
function data = loadWormFiles(files, wormName, field, varargin)

% Should any of the data be left empty?
empty = false(size(files));
if ~isempty(varargin)
    empty = varargin{1};
end

% Load the field from memory.
if isstruct(files)
    data = cell(length(files), 1);
    for i = 1:length(files)
            if ~empty(i)
                data{i} = getStructField(files(i), field);
            end
    end
    
% Load the field from a file.
else
    
    % Fix the data.
    if ~iscell(wormName)
        wormName = {wormName};
    end
    
    % Load each worm by name.
    data = cell(length(wormName), 1);
    if length(wormName) > 1
        for i = 1:length(files)
            if ~empty(i)
                data{i} = loadStructField(files{i}, wormName{i}, field);
            end
        end
        
        % Load all worms using the same name.
    else
        for i = 1:length(files)
            if ~empty(i)
                data{i} = loadStructField(files{i}, wormName{1}, field);
            end
        end
    end
end
end



%% Save the normalized features.
function saveFeatures(filename, wormScales, wormFrames, isNormWorm, ...
    wormFiles, histInfo, dataInfo, loadName, saveName, isVerbose)

% Determine the locomotion modes.
motionModes = loadWormFiles(wormFiles, loadName, ...
    'locomotion.motion.mode', isNormWorm);
motionNames = { ...
    'forward', ...
    'paused', ...
    'backward'};
motionEvents = { ...
    cellfun(@(x) x == 1, motionModes, 'UniformOutput', false), ...
    cellfun(@(x) x == 0, motionModes, 'UniformOutput', false), ...
    cellfun(@(x) x == -1, motionModes, 'UniformOutput', false)};

% Normalize the features.
for i = 1:length(dataInfo)
    
    % Can the feature be normalized?
    if ~dataInfo(i).isTimeSeries
        continue;
    end
    
    % Normalize the feature.
    field = dataInfo(i).field;
    if isVerbose
        disp(['Normalizing "' field '" ...']);
    end
    switch dataInfo(i).type
        
        % Normalize a simple feature.
        case 's'
            data = normFeatures(wormScales, isNormWorm, wormFiles, ...
                histInfo, loadName, field);
            eval([saveName '.' field '=data;']);
            
        % Normalize a motion feature.
        case 'm'
            data = normMotionFeatures(wormScales, wormFrames, ...
                isNormWorm, wormFiles, histInfo, loadName, field, ...
                motionNames, motionEvents);
            eval([saveName '.' field '=data;']);
            
        % Normalize an event feature.
        case 'e'
            data = normEventFeatures(wormScales, wormFrames, ...
                isNormWorm, wormFiles, histInfo, loadName, field, ...
                dataInfo(i).subFields.data, dataInfo(i).subFields.sign);
            eval([saveName '.' field '=data;']);
    end
end

% Save the normalized features.
save(filename, saveName, '-append');
end



%% Normalize the features.
function data = normFeatures(wormScales, isNormWorm, wormFiles, ...
    histInfo, wormName, field)

% Get the data.
info = getStructField(histInfo, field);
normData = loadWormFiles(wormFiles, wormName, field);

% Organize the data.
for i = 1:length(normData)
    if ~isNormWorm(i)
        newNormData.all = {normData(i)};
        
        % Organize the signed data.
        if info.isSigned
            newNormData.abs = {abs(normData(i))};
            newNormData.pos = {nan(length(normData{i}))};
            posI = normData{i} > 0;
            newNormData.pos{1}(posI) = {normData{i}(posI)};
            newNormData.neg = {nan(length(normData{i}))};
            negI = normData{i} > 0;
            newNormData.neg{1}(negI) = {normData{i}(negI)};
        end
        normData{i} = newNormData;
    end
end

% Normalize the feature data.
data = normFeaturesData(wormScales, normData, info.isSigned);
end



%% Normalize the motion features.
function data = normMotionFeatures(wormScales, wormFrames, isNormWorm, ...
    wormFiles, histInfo, wormName, field, motionNames, motionEvents)

% Get the data.
info = getStructField(histInfo, field);
normData = loadWormFiles(wormFiles, wormName, field);

% Initialize the data.
dataLength = size(normData{1}, 1);
newNormData(dataLength,1).all = [];
for i = 1:length(motionNames)
    newNormData(dataLength,1).(motionNames{i}) = [];
end
        
% Organize the data.
for i = 1:length(normData)
    if ~isNormWorm(i)
        
        % Organize the feature data.
        for j = 1:dataLength
            newNormData(j,1).all.all = {normData{i}(j,:)};
            
            % Organize the motion feature data.
            for k = 1:length(motionNames)
                newNormData(j,1).(motionNames{k}).all = ...
                    {nan(1, wormFrames{i})};
                newNormData(j,1).(motionNames{k}).all{1}(motionEvents{k}{i}) = ...
                    normData{i}(j, motionEvents{k}{i});
            end
            
            % Organize the signed feature data.
            if info(j).isSigned
                newNormData(j,1).all.abs = {abs(normData{i}(j,:))};
                posI = normData{i}(j,:) > 0;
                newNormData(j,1).all.pos = {nan(1, wormFrames{i})};
                newNormData(j,1).all.pos{1}(posI) = normData{i}(j,posI);
                negI = normData{i}(j,:) < 0;
                newNormData(j,1).all.neg = {nan(1, wormFrames{i})};
                newNormData(j,1).all.neg{1}(negI) = normData{i}(j,negI);
                
                % Organize the motion feature data.
                for k = 1:length(motionNames)
                    newNormData(j,1).(motionNames{k}).abs = ...
                        {nan(1, wormFrames{i})};
                    newNormData(j,1).(motionNames{k}).abs{1}(motionEvents{k}{i}) = ...
                        abs(normData{i}(j, motionEvents{k}{i}));
                    newNormData(j,1).(motionNames{k}).pos = ...
                        {nan(1, wormFrames{i})};
                    posI = motionEvents{k}{i} & normData{i}(j, :) > 0;
                    newNormData(j,1).(motionNames{k}).pos{1}(posI) = ...
                        normData{i}(j, posI);
                    newNormData(j,1).(motionNames{k}).neg = ...
                        {nan(1, wormFrames{i})};
                    negI = motionEvents{k}{i} & normData{i}(j, :) < 0;
                    newNormData(j,1).(motionNames{k}).neg{1}(negI) = ...
                        normData{i}(j, negI);
                end
            end
        end
        normData{i} = newNormData;
    end
end

% Initialize the data.
data(dataLength,1).all = [];
for i = 1:length(motionNames)
    data(dataLength,1).(motionNames{i}) = [];
end

% Normalize the feature data.
for i = 1:dataLength
    
    % Normalize the feature data.
    subData = cellfun(@(x) x(i).all, normData, 'UniformOutput', false);
    data(i,1).all = normFeaturesData(wormScales, subData, info(i).isSigned);
    
    % Normalize the motion feature data.
    for j = 1:length(motionNames)
        subData = cellfun(@(x) x(i).(motionNames{j}), normData, ...
            'UniformOutput', false);
        data(i,1).(motionNames{j}) = normFeaturesData(wormScales, ...
            subData, info(i).isSigned);
    end
end
end



%% Normalize event features.
function data = normEventFeatures(wormScales, wormFrames, isNormWorm, ...
    wormFiles, histInfo, wormName, field, subFields, signField)

% Get the data.
info = getStructField(histInfo, field);
normData = loadWormFiles(wormFiles, wormName, field);
isSigned = ~isempty(signField);

% Organize the event data.
for i = 1:length(normData)
    if ~isNormWorm(i)
        
        % Initialize the event data.
        newNormData.start.all = {zeros(1, wormFrames{i})};
        newNormData.end.all = {zeros(1, wormFrames{i})};
        if isSigned
            newNormData.start.pos = {zeros(1, wormFrames{i})};
            newNormData.start.neg = {zeros(1, wormFrames{i})};
            newNormData.end.pos = {zeros(1, wormFrames{i})};
            newNormData.end.neg = {zeros(1, wormFrames{i})};
        end
        for j = 1:length(subFields)
            newNormData.(subFields{j}).all = {nan(1, wormFrames{i})};
            if info.(subFields{j}).isSigned
                newNormData.(subFields{j}).abs = {nan(1, wormFrames{i})};
                newNormData.(subFields{j}).pos = {nan(1, wormFrames{i})};
                newNormData.(subFields{j}).neg = {nan(1, wormFrames{i})};
            end
        end
        
        % Organize the data.
        events = normData{i}.frames;
        events = removePartialEvents(events, wormFrames{i});
        signs = ones(1, length(events));
        if isSigned
            signs([events.(signField)]) = -1;
        end
        for j = 1:length(events)
            
            % Mark the event start and end.
            startI = events(j).start + 1;
            endI = events(j).end + 1;
            newNormData.start.all{1}(startI) = ...
                newNormData.start.all{1}(startI) + 1;
            newNormData.end.all{1}(endI) = ...
                newNormData.end.all{1}(endI) + 1;
            if isSigned
                if signs(j) >= 0
                    newNormData.start.pos{1}(startI) = ...
                        newNormData.start.pos{1}(startI) + 1;
                    newNormData.end.pos{1}(endI) = ...
                        newNormData.end.pos{1}(endI) + 1;
                else
                    newNormData.start.neg{1}(startI) = ...
                        newNormData.start.neg{1}(startI) - 1;
                    newNormData.end.neg{1}(endI) = ...
                        newNormData.end.neg{1}(endI) - 1;
                end
            end

            % Organize the data.
            for k = 1:length(subFields)
                eventData = events(j).(subFields{k}) * signs(j);
                newNormData.(subFields{k}).all{1}(startI) = eventData;
                
                % Organize the signed data.
                if info.(subFields{k}).isSigned
                    newNormData.(subFields{k}).abs{1}(startI) = ...
                        abs(eventData);
                    if eventData > 0
                        newNormData.(subFields{k}).pos{1}(startI) = ...
                            eventData;
                    end
                    if eventData < 0
                        newNormData.(subFields{k}).neg{1}(startI) = ...
                            eventData;
                    end
                end
            end
        end
        normData{i} = newNormData;
    end
end

% Normalize the event data.
subData = cellfun(@(x) x.start, normData, 'UniformOutput', false);
data.start = normFeaturesData(wormScales, subData, isSigned, false, @nansum);
subData = cellfun(@(x) x.end, normData, 'UniformOutput', false);
data.end = normFeaturesData(wormScales, subData, isSigned, false, @nansum);

% Normalize the event feature data.
for i = 1:length(subFields)
    subData = cellfun(@(x) x.(subFields{i}), normData, 'UniformOutput', ...
        false);
    data.(subFields{i}) = normFeaturesData(wormScales, subData, ...
        info.(subFields{i}).isSigned);
end
end



%% Normalize the feature data.
% varargin = [isAbs, normOp]
function data = normFeaturesData(wormScales, normData, isSigned, varargin)

% If signed, are we computing the absolute value?
isAbs = true;
if ~isempty(varargin)
    isAbs = varargin{1};
end

% Are we summing the data?
normOp = @nanmean;
if length(varargin) > 1
    normOp = varargin{2};
end

% Initialize the data.
data.all = [];
if isSigned
    data.pos = [];
    data.neg = [];
    if isAbs
        data.abs = [];
    end
end

% Normalize the feature data.
for i = 1:length(normData)
    
    % Initialize the feature data.
    scales = wormScales{i};
    for j = 1:length(normData{i}.all)
        
        % Is the feature data at the appropriate scale?
        if wormScales{i} == 1
            data.all{end + 1,1} = normData{i}.all{j};
            if isSigned
                data.pos{end + 1,1} = normData{i}.pos{j};
                data.neg{end + 1,1} = normData{i}.neg{j};
                if isAbs
                    data.abs{end + 1,1} = normData{i}.abs{j};
                end
            end
            continue;
        end
        
        % Normalize the feature data.
        data.all{end + 1,1} = ...
            nan(1, floor(size(normData{i}.all{j}, 2) / scales(j)));
        if isSigned
            data.pos{end + 1,1} = ...
                nan(1, floor(size(normData{i}.pos{j}, 2) / scales(j)));
            data.neg{end + 1,1} = ...
                nan(1, floor(size(normData{i}.neg{j}, 2) / scales(j)));
            if isAbs
                data.abs{end + 1,1} = ...
                    nan(1, floor(size(normData{i}.abs{j}, 2) / scales(j)));
            end
        end
        
        % Normalize the feature data.
        for k = 1:length(data.all{end})
            index = (k - 1) * scales(j) + 1;
            data.all{end}(k) = ...
                normOp(normData{i}.all{j}(index:(index + scales(j) - 1)));
        end
        if isSigned
            for k = 1:length(data.all{end})
                index = (k - 1) * scales(j) + 1;
                range = index:(index + scales(j) - 1);
                data.pos{end}(k) = normOp(normData{i}.pos{j}(range));
                data.neg{end}(k) = normOp(normData{i}.neg{j}(range));
                if isAbs
                    data.abs{end}(k) = normOp(normData{i}.abs{j}(range));
                end
            end
        end
    end
end
end
