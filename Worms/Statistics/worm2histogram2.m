function worm2histogram(filename, wormFiles, varargin)
%WORM2HISTOGRAM Convert worm features to their histogram.
%
%   WORM2HISTOGRAM(FILENAME, WORMFILES)
%
%   WORM2HISTOGRAM(FILENAME, WORMFILES, CONTROLFILES)
%
%   Inputs:
%       filename     - the file name for the histograms;
%                      the file includes:
%
%                      wormInfo    = the worm information
%                      worm        = the worm histograms
%                      controlInfo = the control information (if it exists)
%                      worm        = the control histograms (if they exist)
%
%       wormFiles    - the feature files to use for the worm
%       controlFiles - the feature files to use for the control;
%                      if empty, the worm has no control
%
% See also WORM2CSV, WORMDISPLAYINFO, HISTOGRAM
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
wormInfo = cellfun(@(x) load(x, 'info'), wormFiles);
if isempty(controlFiles)
    save(filename, 'wormInfo');
else
    controlInfo = cellfun(@(x) load(x, 'info'), controlFiles);
    save(filename, 'wormInfo', 'controlInfo');
end

% Free memory.
clear('wormInfo', 'controlInfo');

% Initialize the histogram display information.
histInfo = wormDisplayInfo();

% Save the worm histograms.
saveHistogram(wormFiles, histInfo, 'worm', filename);

% Save the control histograms.
if ~isempty(controlFiles)
    saveHistogram(controlFiles, histInfo, 'control', filename);
end
end



%% Load worm data from files.
function data = loadWormFiles(filenames, field)
data = cellfun(@(x) loadStructField(x, 'worm', field), filenames, ...
    'UniformOutput', false);
end



%% Save the worm histograms.
function saveHistogram(wormFiles, histInfo, wormName, filename)

% Determine the locomotion modes.
motionModes = loadWormFiles(wormFiles, 'locomotion.motion.mode');
motionNames = { ...
    'forward', ...
    'paused', ...
    'backward'};
motionEvents = { ...
    cellfun(@(x) x == 1, motionModes, 'UniformOutput', false), ...
    cellfun(@(x) x == 0, motionModes, 'UniformOutput', false), ...
    cellfun(@(x) x == -1, motionModes, 'UniformOutput', false)};



%% Compute the morphology histograms.

% Compute the length histograms.
field = 'morphology.length';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the width histograms.
fields = { ...
    'morphology.width.head', ...
    'morphology.width.midbody', ...
    'morphology.width.tail'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    histData = motion2histograms(data, motionEvents, motionNames, ...
        getStructField(histInfo, fields{i}));
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the area histograms.
field = 'morphology.area';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
   getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the area/length histograms.
field = 'morphology.areaPerLength';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the width/length histograms.
field = 'morphology.widthPerLength';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);



%% Compute the posture histograms.

% Compute the bend histograms.
fields = { ...
    'posture.bends.head.mean', ...
    'posture.bends.head.stdDev', ...
    'posture.bends.neck.mean', ...
    'posture.bends.neck.stdDev', ...
    'posture.bends.midbody.mean', ...
    'posture.bends.midbody.stdDev', ...
    'posture.bends.hips.mean', ...
    'posture.bends.hips.stdDev', ...
    'posture.bends.tail.mean', ...
    'posture.bends.tail.stdDev'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    histData = motion2histograms(data, motionEvents, motionNames, ...
        getStructField(histInfo, fields{i}));
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the amplitude histograms.
fields = { ...
    'posture.amplitude.max', ...
    'posture.amplitude.ratio'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    histData = motion2histograms(data, motionEvents, motionNames, ...
        getStructField(histInfo, fields{i}));
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the wavelength histograms.
fields = { ...
    'posture.wavelength.primary', ...
    'posture.wavelength.secondary'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    histData = motion2histograms(data, motionEvents, motionNames, ...
        getStructField(histInfo, fields{i}));
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the track length histograms.
field = 'posture.tracklength';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the eccentricity histograms.
field = 'posture.eccentricity';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the kinks histograms.
field = 'posture.kinks';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the coils histograms.
field = 'posture.coils';
statFields = { ...
    'frequency', ...
    'timeRatio'};
eventFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
data = loadWormFiles(wormFiles, field);
infos = cell(length(eventFields),1);
if ~isempty(histInfo)
    for i = 1: length(eventFields)
        infos{i} = getStructField(histInfo, [field '.' eventFields{i}]);
    end
end
histData = event2histograms(data, statFields, eventFields, infos);
eval([wormName '.' field '=histData;']);

% Compute the directions histograms.
fields = { ...
    'posture.directions.tail2head', ...
    'posture.directions.head', ...
    'posture.directions.tail'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    histData = motion2histograms(data, motionEvents, motionNames, ...
        getStructField(histInfo, fields{i}));
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the eigen projection histograms.
field = 'posture.eigenProjection';
data = loadWormFiles(wormFiles, field);
histData(:) = [];
info = getStructField(histInfo, field);
for i = 1:size(data{1},1)
    subData = cellfun(@(x) x(i,:), data, 'UniformOutput', false);
    histData(i) = motion2histograms(subData, motionEvents, motionNames, ...
        info);
end
eval([wormName '.' field '=histData;']);



%% Compute the locomotion histograms.

% Compute the motion histograms.
fields = { ...
    'locomotion.motion.forward', ...
    'locomotion.motion.paused', ...
    'locomotion.motion.backward'};
statFields = { ...
    'frequency', ...
    'ratio.time', ...
    'ratio.distance', ...
    };
eventFields = { ...
    'time', ...
    'distance', ...
    'interTime', ...
    'interDistance'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    infos = cell(length(eventFields),1);
    if ~isempty(histInfo)
        for j = 1: length(eventFields)
            infos{j} = getStructField(histInfo, ...
                [fields{i} '.' eventFields{j}]);
        end
    end
    histData = event2histograms(data, statFields, eventFields, infos);
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the velocity histograms.
fields = { ...
    'locomotion.velocity.headTip.speed', ...
    'locomotion.velocity.headTip.direction', ...
    'locomotion.velocity.head.speed', ...
    'locomotion.velocity.head.direction', ...
    'locomotion.velocity.midbody.speed', ...
    'locomotion.velocity.midbody.direction', ...
    'locomotion.velocity.tail.speed', ...
    'locomotion.velocity.tail.direction', ...
    'locomotion.velocity.tailTip.speed', ...
    'locomotion.velocity.tailTip.direction'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    histData = motion2histograms(data, motionEvents, motionNames, ...
        getStructField(histInfo, fields{i}));
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the bend histograms.
fields = { ...
    'locomotion.bends.foraging.amplitude', ...
    'locomotion.bends.foraging.angleSpeed', ...
    'locomotion.bends.head.amplitude', ...
    'locomotion.bends.head.frequency', ...
    'locomotion.bends.midbody.amplitude', ...
    'locomotion.bends.midbody.frequency', ...
    'locomotion.bends.tail.amplitude', ...
    'locomotion.bends.tail.frequency'};
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    histData = motion2histograms(data, motionEvents, motionNames, ...
        getStructField(histInfo, fields{i}));
    eval([wormName '.' fields{i} '=histData;']);
end

% Compute the turn histograms.
fields = { ...
    'locomotion.turns.omegas', ...
    'locomotion.turns.upsilons'};
statFields = { ...
    'frequency', ...
    'timeRatio', ...
    };
eventFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
isSigned = [ ...
    true, ...
    true, ...
    true];
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, fields{i});
    infos = cell(length(eventFields),1);
    if ~isempty(histInfo)
        for j = 1: length(eventFields)
            infos{j} = getStructField(histInfo, ...
                [fields{i} '.' eventFields{j}]);
        end
    end
    histData = event2histograms(data, statFields, eventFields, infos, ...
        isSigned);
    eval([wormName '.' fields{i} '=histData;']);
end



%% Compute the path histograms.

% Compute the curvature histograms.
field = 'path.curvature';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the range histograms.
field = 'path.range';
data = loadWormFiles(wormFiles, field);
histData = motion2histograms(data, motionEvents, motionNames, ...
    getStructField(histInfo, field));
eval([wormName '.' field '=histData;']);

% Compute the duration histograms.
fields = { ...
    'path.duration.worm', ...
    'path.duration.head', ...
    'path.duration.midbody', ...
    'path.duration.tail'};
clear histData;
for i = 1:length(fields)
    data = loadWormFiles(wormFiles, [fields{i} '.times']);
    info = getStructField(histInfo, fields{i});
    histData.histogram = histogram(data, info.resolution, ...
        info.isZeroBin, info.isSigned);
    eval([wormName '.' fields{i} '=histData;']);
end

%% Save the histograms.
save(filename, wormName, '-append');
end



%% Convert motion data to a set of histograms.
function histData = motion2histograms(data, motionEvents, ...
    motionNames, histInfo)

% Get the histogram information.
resolution = [];
isZeroBin = [];
isSigned = [];
if ~isempty(histInfo)
    resolution = histInfo.resolution;
    isZeroBin = histInfo.isZeroBin;
    isSigned = histInfo.isSigned;
end

% Create the histogram structures.
histData.histogram = [];
for i = 1:length(motionNames)
    histData.(motionNames{i}).histogram = [];
end

% Compute the data histogram.
histData.histogram = histogram(data, resolution, isZeroBin);

% Compute the motion histograms.
for i = 1:length(motionEvents)
    
    % Organize the motion data.
    isData = false;
    motionData = cell(length(data),1);
    for j = 1:length(data)
        motionData{j} = data{j}(motionEvents{i}{j});
        if ~isempty(motionData{j})
            isData = true;
        end
    end
    
    % Compute the motion histogram.
    if isData
        histData.(motionNames{i}).histogram = ...
            histogram(motionData, resolution, isZeroBin, isSigned);
    end
end
end



%% Convert event data to a set of histograms.
%
% varargin:
%
% isSigned - are we signing the event field (dorsal/ventral = -/+)?
function histData = event2histograms(data, statFields, eventFields, ...
    histInfos, varargin)

% Are we signing the event field (dorsal/ventral = -/+)?
isEventSigned = false(length(eventFields));
if ~isempty(varargin)
    isEventSigned = varargin{1};
end

% Create the statistics structures.
histData = [];
for i = 1:length(statFields)
    histData = setStructField(histData, statFields{i}, []);
end

% Compute the event statistics.
for i = 1:length(statFields)

    % Organize the event data.
    isData = false;
    eventData = nan(length(data),1);
    for j = 1:length(data)
        field = getStructField(data{j}, statFields{i});
        if ~isempty(field)
            eventData(j) = field;
            isData = true;
        end
    end
    
    % Compute the event statistics.
    if isData
        histData = setStructField(histData, [statFields{i} '.mean'], ...
            nanmean(eventData));
        histData = setStructField(histData, [statFields{i} '.stdDev'], ...
            nanstd(eventData));
    end
end

% Create the histogram structures.
for i = 1:length(eventFields)
    histData.(eventFields{i}).histogram = [];
end

% Compute the event histograms.
for i = 1:length(eventFields)
    
    % Organize the event data.
    isData = false;
    eventData = cell(length(data),1);
    isSigning = isEventSigned(i);
    for j = 1:length(data)
        field = data{j}.frames;
        if ~isempty(field)
            eventData{j} = [field.(eventFields{i})];
            
            % Sign the event.
            if isSigning
                ventral = [field.isVentral];
                eventData{j}(~ventral) = -eventData{j}(~ventral);
            end
            isData = true;
        end
    end
    
    % Get the histogram information.
    resolution = [];
    isZeroBin = [];
    isSigned = [];
    if ~isempty(histInfos(i))
        resolution = histInfos{i}.resolution;
        isZeroBin = histInfos{i}.isZeroBin;
        isSigned = histInfos{i}.isSigned;
    end

    % Compute the event histogram.
    if isData
        histData.(eventFields{i}).histogram = ...
            histogram(eventData, resolution, isZeroBin, isSigned);
    end
end
end
