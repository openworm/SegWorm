function filenames = worm2CSV(filename, wormInfo, worm, wormName, varargin)
%WORM2CSV Convert worm features to a CSV file.
%
%   [FILENAME] = WORM2CSV(FILENAME, WORMINFO, WORM, WORMNAME)
%
%   [FILENAME] = WORM2CSV(FILENAME, WORMINFO, WORM, WORMNAME,
%                         CONTROLINFO, CONTROL, CONTROLNAME)
%
%   Inputs:
%       filename    - the CSV filename;
%                     if empty, the file is named
%                     "<wormName> [vs <controlName>].csv"
%       wormInfo    - the worm information (see worm2histogram)
%       worm        - the worm histograms (see worm2histogram)
%       wormName    - the name for the worm
%       controlInfo - the control information (see worm2histogram)
%       control     - the control histograms (see worm2histogram);
%                     if empty; no control is shown
%       controlName - the name for the control
%
%   Output:
%       filenames - the CSV filenames
%
% See also WORM2HISTOGRAM, WORMDISPLAYINFO, HISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Do we have a control?
controlInfo = [];
control = [];
controlName = [];
if length(varargin) > 2
    controlInfo = varargin{1};
    control = varargin{2};
    controlName = varargin{3};
end

% Construct the worm name(s).
if isempty(wormName)
    wormName = 'worm';
end
if isempty(controlName)
    wormName = 'control';
end

% Construct the filename.
if isempty(filename)
    filename = wormName;
    if ~isempty(controlName)
        filename = [filename ' vs ' controlName];
    end
    
% Remove the file extension.
elseif strcmp(filename((end - 3):end), '.csv')
    filename = filename(1:(end - 4));
end

% Initialize the data separators.
separator1 = 3;
separator2 = 2;
separator3 = 1;

% Initialize the experiment display information.
expDispInfo = experimentDisplayInfo();

% Initialize the worm display information.
wormDispInfo = wormDisplayInfo();

% Initialize the file names.
filenames = [];


%% Print the morphology features.

% Add the file extension.
filenames{end + 1} = [filename ' morphology.csv'];

% Delete the file if it already exists.
if exist(filenames{end}, 'file')
    delete(filenames{end});
end

% Open the file.
file = fopen(filenames{end}, 'w');

% Print the experiment header.
expFields = { ...
    'experiment.worm.strain', ...
    'experiment.worm.genotype', ...
    'experiment.environment.timestamp'};
printExpHeaderCSV(file, expDispInfo, expFields, wormInfo, controlInfo);

% Print the morphology header.
field = 'morphology';
printSeparator(file, separator2);
label = getStructField(wormDispInfo, [field '.name']);
printCSV(file, upper(label));
printSeparator(file, separator3);

% Print the length.
field = 'morphology.length';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Print the width.
field = 'morphology.width';
subFields = { ...
    'head', ...
    'midbody', ...
    'tail'};
printWormMotionCSV(file, wormDispInfo, field, subFields, worm, control);
printSeparator(file, separator3);

% Print the area.
field = 'morphology.area';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Print the area/length.
field = 'morphology.areaPerLength';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Print the width/length.
field = 'morphology.widthPerLength';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Close the file.
fclose(file);



%% Print the posture.

% Add the file extension.
filenames{end + 1} = [filename ' posture.csv'];

% Delete the file if it already exists.
if exist(filenames{end}, 'file')
    delete(filenames{end});
end

% Open the file.
file = fopen(filenames{end}, 'w');

% Print the experiment header.
expFields = { ...
    'experiment.worm.strain', ...
    'experiment.worm.genotype', ...
    'experiment.environment.timestamp'};
printExpHeaderCSV(file, expDispInfo, expFields, wormInfo, controlInfo);

% Print the posture header.
field = 'posture';
printSeparator(file, separator2);
label = getStructField(wormDispInfo, [field '.name']);
printCSV(file, upper(label));
printSeparator(file, separator3);

% Print the bends.
field = 'posture.bends';
subFields1 = { ...
    'head', ...
    'neck', ...
    'midbody', ...
    'hips', ...
    'tail'};
subFields2 = { ...
    'mean', ...
    'stdDev'};
for i = 1:length(subFields1)
    printWormMotionCSV(file, wormDispInfo, [field '.' subFields1{i}], ...
        subFields2, worm, control);
    printSeparator(file, separator3);
end

% Print the amplitude.
fields = { ...
    'posture.amplitude.max', ...
    'posture.amplitude.ratio'};
for i = 1:length(fields)
    printWormMotionCSV(file, wormDispInfo, fields{i}, [], worm, control);
    printSeparator(file, separator3);
end

% Print the wavelength.
field = 'posture.wavelength';
subFields = { ...
    'primary', ...
    'secondary'};
printWormMotionCSV(file, wormDispInfo, field, subFields, worm, control);
printSeparator(file, separator3);

% Print the track length.
field = 'posture.tracklength';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Print the eccentricity.
field = 'posture.eccentricity';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Print the kinks.
field = 'posture.kinks';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Print the coils.
field = 'posture.coils';
statFields = { ...
    'frequency', ...
    'timeRatio'};
eventFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
printWormEventCSV(file, wormDispInfo, field, statFields, ...
    eventFields, worm, control);
printSeparator(file, separator3);

% Print the directions.
field = 'posture.directions';
subFields = { ...
    'tail2head', ...
    'head', ...
    'tail'};
printWormMotionCSV(file, wormDispInfo, field, subFields, worm, control);
printSeparator(file, separator3);

% Print the eigen projection.
field = 'posture.eigenProjection';
for i = 1:length(getStructField(wormDispInfo, field))
    printWormMotionCSV(file, wormDispInfo, field, [], worm, control, i);
    printSeparator(file, separator3);
end

% Close the file.
fclose(file);



%% Print the locomotion.

% Add the file extension.
filenames{end + 1} = [filename ' locomotion.csv'];

% Delete the file if it already exists.
if exist(filenames{end}, 'file')
    delete(filenames{end});
end

% Open the file.
file = fopen(filenames{end}, 'w');

% Print the experiment header.
expFields = { ...
    'experiment.worm.strain', ...
    'experiment.worm.genotype', ...
    'experiment.environment.timestamp'};
printExpHeaderCSV(file, expDispInfo, expFields, wormInfo, controlInfo);

% Print the locomotion header.
field = 'locomotion';
printSeparator(file, separator2);
label = getStructField(wormDispInfo, [field '.name']);
printCSV(file, upper(label));
printSeparator(file, separator3);

% Print the motion.
field = 'locomotion.motion';
subFields = { ...
    'forward', ...
    'paused', ...
    'backward'};
statFields = { ...
    'frequency', ...
    'ratio.time', ...
    'ratio.distance'};
eventFields = { ...
    'time', ...
    'distance', ...
    'interTime', ...
    'interDistance'};
for i = 1:length(subFields)
    printWormEventCSV(file, wormDispInfo, [field '.' subFields{i}], ...
        statFields, eventFields, worm, control);
end

% Print the velocity.
field = 'locomotion.velocity';
subFields1 = { ...
    'headTip', ...
    'head', ...
    'midbody', ...
    'tail', ...
    'tailTip'};
subFields2 = { ...
    'speed', ...
    'direction'};
for i = 1:length(subFields1)
    printWormMotionCSV(file, wormDispInfo, [field '.' subFields1{i}], ...
        subFields2, worm, control);
    printSeparator(file, separator3);
end

% Print the bends.
field = 'locomotion.bends';
subFields1 = { ...
    'head', ...
    'midbody', ...
    'tail'};
subFields2 = { ...
    'amplitude', ...
    'frequency'};
for i = 1:length(subFields1)
    printWormMotionCSV(file, wormDispInfo, [field '.' subFields1{i}], ...
        subFields2, worm, control);
    printSeparator(file, separator3);
end

% Print the foraging.
field = 'locomotion.bends.foraging';
subFields = { ...
    'amplitude', ...
    'angleSpeed'};
printWormMotionCSV(file, wormDispInfo, field, subFields, worm, control);
printSeparator(file, separator3);

% Print the turns.
field = 'locomotion.turns';
subFields = { ...
    'omegas', ...
    'upsilons'};
statFields = { ...
    'frequency', ...
    'timeRatio'};
eventFields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
for i = 1:length(subFields)
    printWormEventCSV(file, wormDispInfo, [field '.' subFields{i}], ...
        statFields, eventFields, worm, control);
    printSeparator(file, separator3);
end

% Close the file.
fclose(file);



%% Print the path.

% Add the file extension.
filenames{end + 1} = [filename ' path.csv'];

% Delete the file if it already exists.
if exist(filenames{end}, 'file')
    delete(filenames{end});
end

% Open the file.
file = fopen(filenames{end}, 'w');

% Print the experiment header.
expFields = { ...
    'experiment.worm.strain', ...
    'experiment.worm.genotype', ...
    'experiment.environment.timestamp'};
printExpHeaderCSV(file, expDispInfo, expFields, wormInfo, controlInfo);

% Print the path header.
field = 'path';
printSeparator(file, separator2);
label = getStructField(wormDispInfo, [field '.name']);
printCSV(file, upper(label));
printSeparator(file, separator3);

% Print the curvature.
field = 'path.curvature';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Print the range.
field = 'path.range';
printWormMotionCSV(file, wormDispInfo, field, [], worm, control);
printSeparator(file, separator3);

% Compute the duration histograms.
field = 'path.duration';
subFields = { ...
    'worm', ...
    'head', ...
    'midbody', ...
    'tail'};
printWormCSV(file, wormDispInfo, field, subFields, worm, control);
printSeparator(file, separator3);

% Close the file.
fclose(file);
end



%% Print the experiment header.
function printExpHeaderCSV(file, expDispInfo, fields, wormInfo, controlInfo)

% Initialize the separator.
separator = 1;

% Print the header.
printCSV(file, 'WORM', cell(2,1), 'EXPERIMENTS', ...
    cell(length(wormInfo), 1), 'CONTROLS');
printSeparator(file, separator);

% Print the data.
for i = 1:length(fields)
    printExpCSV(file, expDispInfo, fields{i}, wormInfo, controlInfo);
end
end



%% Print the experiment information.
function printExpCSV(file, expDispInfo, field, wormInfo, controlInfo)

% Print the data.
label = getStructField(expDispInfo, field);
printWormDataCSV(file, label.name, [], field, wormInfo, controlInfo);
end



%% Print the worm information.
% varargin = field index
function printWormCSV(file, wormDispInfo, dataField, dataSubFields, ...
    worm, control, varargin)

% Which field index are we using?
index = 1;
if ~isempty(varargin)
    index = varargin{1};
end

% Initialize the separator.
separator = 1;

% Organize the data.
if ~iscell(dataSubFields)
    dataSubFields = {dataSubFields};
end

% Get the display index.
wormDispInfo = getStructField(wormDispInfo, dataField);
wormDispInfo = wormDispInfo(index);

% Get the data index.
worm = getStructField(worm, dataField);
worm = worm(index);
control = getStructField(control, dataField);
control = control(index);

% Print the data fields.
for i = 1:length(dataSubFields)
    
    % Print the label.
    info = getStructField(wormDispInfo, dataSubFields{i});
    printCSV(file, ['* ' upper(info.name)]);
    printSeparator(file, separator);
    
    % Print the statistics.
    subWorm = getStructField(worm, dataSubFields{i});
    subControl = getStructField(control, dataSubFields{i});
    printWormStatsCSV(file, info, subWorm, subControl);
end
end



%% Print the worm motion information.
% varargin = field index
function printWormMotionCSV(file, wormDispInfo, dataField, ...
    dataSubFields, worm, control, varargin)

% Which field index are we using?
index = 1;
if ~isempty(varargin)
    index = varargin{1};
end

% Initialize the separator.
separator = 1;

% Organize the data.
if ~iscell(dataSubFields)
    dataSubFields = {dataSubFields};
end

% Initialize the motion information.
fields = { ...
    'forward', ...
    'paused', ...
    'backward'};
labels = { ...
    'Forward', ...
    'Paused', ...
    'Backward'};

% Get the display index.
wormDispInfo = getStructField(wormDispInfo, dataField);
wormDispInfo = wormDispInfo(index);

% Get the data index.
worm = getStructField(worm, dataField);
worm = worm(index);
control = getStructField(control, dataField);
control = control(index);

% Print the data fields.
for i = 1:length(dataSubFields)
    
    % Print the overall statistics.
    printWormCSV(file, wormDispInfo, dataSubFields{i}, [], ...
        worm, control);
    
    % Print the motion statistics.
    for j = 1:length(fields)
        
        % Print the label.
        info = getStructField(wormDispInfo, dataSubFields{i});
        printCSV(file, ['** ' labels{j} ' ' info.name]);
        printSeparator(file, separator);
        
        % Print the statistics.
        if isempty(dataSubFields{i})
            subWorm = getStructField(worm, fields{j});
            subControl = getStructField(control, fields{j});
        else
            subWorm = ...
                getStructField(worm, [dataSubFields{i} '.' fields{j}]);
            subControl = ...
                getStructField(control, [dataSubFields{i} '.' fields{j}]);
        end
        printWormStatsCSV(file, info, subWorm, subControl);
    end
end
end



%% Print the worm event information.
% varargin = field index
function printWormEventCSV(file, wormDispInfo, dataField, statFields, ...
    eventFields, worm, control, varargin)

% Which field index are we using?
index = 1;
if ~isempty(varargin)
    index = varargin{1};
end

% Initialize the separator.
separator = 1;

% Organize the data.
if ~iscell(statFields)
    statFields = {statFields};
end
if ~iscell(eventFields)
    eventFields = {eventFields};
end

% Initialize the statistics information.
fields = { ...
    'mean', ...
    'stdDev'};
labels = { ...
    'Mean', ...
    'S.D.'};

% Get the display index.
wormDispInfo = getStructField(wormDispInfo, dataField);
wormDispInfo = wormDispInfo(index);

% Get the data index.
worm = getStructField(worm, dataField);
worm = worm(index);
control = getStructField(control, dataField);
control = control(index);

% Print the label.
printCSV(file, ['* ' upper(wormDispInfo.name)]);
printSeparator(file, separator);

% Print the statistics fields.
for i = 1:length(statFields)
    
    % Print the statistics.
    info = getStructField(wormDispInfo, statFields{i});
    unit = info.unit;
    for j = 1:length(fields)
        field = [statFields{i} '.' fields{j}];
        label = [labels{j} ' (' unit ')'];
        printWormDataCSV(file, info.name, label, field, worm, control);
    end
    printSeparator(file, separator);
end

% Print the event fields.
for i = 1:length(eventFields)
    
    % Print the label.
    info = getStructField(wormDispInfo, eventFields{i});
    printCSV(file, ['** ' info.name]);
    printSeparator(file, separator);
    
    % Print the statistics.
    subWorm = getStructField(worm, eventFields{i});
    subControl = getStructField(control, eventFields{i});
    printWormStatsCSV(file, info, subWorm, subControl);
end
end



%% Print the worm statistics.
function printWormStatsCSV(file, info, worm, control)

% Initialize the separator.
separator = 1;

% Initialize the statistics information.
fields = { ...
    'data', ...
    'sets', ...
    'allData'};
subFields = { ...
    'samples', ...
    'mean', ...
    'stdDev'};
labels = { ...
    'Set', ...
    'Data', ...
    'All Data'};
subLabels = { ...
    'Samples', ...
    'Mean', ...
    'S.D.'};
if (info.isSigned)
    subLabels{end + 1} = 'Abs Mean';
    subLabels{end + 1} = 'Abs S.D.';
    subFields{end + 1} = 'absMean';
    subFields{end + 1} = 'absStdDev';
end

% Print the statistics.
for i = 1:length(fields)
    
    % Print a header for aggregate statistics.
    histField = ['histogram.' fields{i}];
    numExps = length(getStructField(worm, [histField '.samples']));
    printCSV(file, cell(3,1), '* Experiments', cell(numExps,1), ...
        '* Controls');
    
    % Print the statistics.
    for j = 1:length(subFields)
        field = [histField '.' subFields{j}];
        subLabel = subLabels{j};
        if j > 1
            unit = info.unit;
            subLabel = [subLabel ' (' unit ')'];
        end
        printWormDataCSV(file, labels{i}, subLabel, field, worm, control);
    end
    printSeparator(file, separator);
end
end



%% Print the worm data.
function printWormDataCSV(file, label, subLabel, field, worm, control)

% Get the data.
wormData = arrayfun(@(x) getStructField(x, field), worm, ...
    'UniformOutput', false);
controlData = arrayfun(@(x) getStructField(x, field), control, ...
    'UniformOutput', false);

% Print the data.
printCSV(file, label, subLabel, [], wormData, [], controlData);
end



%% Print a field separator.
function printSeparator(file, num)
for i = 1:num
    printCSV(file, []);
end
end



%% Print a list of comma separated values.
function printCSV(file, varargin)
for i = 1:length(varargin)
    data = varargin{i};
    
    % Print a list of data.
    if iscell(data)
        for j = 1:length(data)
            printVar(file, data{j});
        end
        
    % Print the data.
    else
        printVar(file, data);
    end
end
    
% Print the new line.
fprintf(file, '\n');
end



%% Print a variable to a file.
function printVar(file, data)

% Print a space.
if isempty(data)
    fprintf(file, ' ,');
    
% Print the number.
elseif isnumeric(data)
    fprintf(file, '%d,', data);
    
% Print the string.
elseif ischar(data)
    fprintf(file, '%s,', data);
    
% The data cannot be printed.
else
    warning('worm2CSV:BadData', ...
        'The data cannot be printed, it is in an unrecognized format');
end
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






%% Compute the locomotion histograms.



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
function histData = event2histograms(data, statFields, eventFields, ...
    histInfos)

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
    for j = 1:length(data)
        field = data{j}.frames;
        if ~isempty(field)
            eventData{j} = [field.(eventFields{i})];
            isData = true;
        end
    end
    
    % Get the histogram information.
    resolution = [];
    isZeroBin = [];
    isSigned = [];
    if ~isempty(histInfos(i))
        resolution = histInfo(i).resolution;
        isZeroBin = histInfo(i).isZeroBin;
        isSigned = histInfo(i).isSigned;
    end

    % Compute the event histogram.
    if isData
        histData.(eventFields{i}).histogram = ...
            histogram(eventData, resolution, isZeroBin, isSigned);
    end
end
end
