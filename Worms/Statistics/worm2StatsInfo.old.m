function worm2StatsInfo(filename, wormFiles, varargin)
%WORM2STATSINFO Compute worm statistics information and save it to a file.
%
%   WORM2STATSINFO(FILENAME, WORMFILES)
%
%   WORM2STATSINFO(FILENAME, WORMFILES, WORMFILTER)
%
%   WORM2STATSINFO(FILENAME, WORMFILES, WORMFILTER,
%                  CONTROLFILES, CONTROLFILTER)
%
%   WORM2STATSINFO(FILENAME, WORMFILES, WORMFILTER,
%                  CONTROLFILES, CONTROLFILTER, ZSCOREMODE)
%
%   WORM2STATSINFO(FILENAME, WORMFILES, WORMFILTER,
%                  CONTROLFILES, CONTROLFILTER, ZSCOREMODE, PERMUTATIONS)
%
%   WORM2STATSINFO(FILENAME, WORMFILES, WORMFILTER,
%                  CONTROLFILES, CONTROLFILTER, ZSCOREMODE, PERMUTATIONS,
%                  ISVERBOSE)
%
%   Inputs:
%       filename - the file name for the worm statistics information;
%                  a file containing a structure with fields:
%
%                  wormInfo & controlInfo = the worm information
%
%                  dataInfo:
%
%                     name     = the feature's name
%                     field    = the feature's path; a struct where:
%
%                                histogram  = the histogram data path
%                                statistics = the statistics data path
%
%                     index    = the feature's field index
%                     isMain   = is this a main feature?
%                     category = the feature's category, where:
%
%                                m = morphology
%                                s = posture (shape)
%                                l = locomotion
%                                p = path
%
%                     type     = the feature's type, where:
%
%                                s = simple data
%                                m = motion data
%                                d = event summary data
%                                e = event data
%                                i = inter-event data
%
%                     sign     = the feature's sign, where:
%
%                                s = signed data
%                                u = unsigned data
%                                a = the absolute value of the data
%                                p = the positive data
%                                n = the negative data
%
%                  wormData & controlData:
%
%                     zScore  = the feature z-scores
%                               (normalized to the controls)
%                               Note 1: if no controls are present, the
%                               zScore is left empty
%                               Note 2: if a feature is present in more
%                               than one worm but absent in the controls,
%                               the z-score is set to infinite;
%                               conversely, if a feature is absent from the
%                               worms but present in more than 1 control,
%                               the z-score is set to -infinite.
%                     data    = the feature data
%                     mean    = the feature means
%                     stdDev  = the feature standard deviations
%                     samples = the number of samples per feature
%
%                  significance.worm & significance.features:
%
%                     Note: this field is only present with a control
%
%                     pValue = the worm or feature p-value(s)
%                     qValue = the worm or feature q-value(s)
%                     power  = the feature discrimination power
%
%       wormFiles     - the worm histogram or statistics files
%       wormFilter    - the worm filtering criteria;
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
%       controlFiles  - the control histogram or statistics files
%       controlFilter - the control filtering criteria
%       zScoreMode    - the z-score normalization mode; if one mode is
%                       provided, it's applied to both the worm and
%                       control; otherwise, the first mode applies to the
%                       worm and the second mode is applied to the control;
%                       the default is 'os'.
%
%                       o = normalize the worm to the Opposing group
%                       s = normalize the worm to itself (Same)
%                       p = normalize the worm to both groups (Population)
%
%       permutations  - the number of permutations to run for significance
%                       testing; if zero or empty, no permutations are run;
%                       the default is none
%       isVerbose     - verbose mode displays the progress;
%                       the default is yes (true)
%
% See also WORM2HISTOGRAM, WORM2STATS, FILTERWORMINFO, WORMSTATSINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Determine the worm file filter.
wormFilter = [];
if ~isempty(varargin)
    wormFilter = varargin{1};
end

% Determine the control files
controlFiles = [];
if length(varargin) > 1
    controlFiles = varargin{2};
    
    % Determine the control file filter.
    controlFilter = [];
    if length(varargin) > 2
        controlFilter = varargin{3};
    end
end

% Determine the z-score mode.
zScoreMode = [];
if length(varargin) > 3
    zScoreMode = varargin{4};
end
if isempty(zScoreMode)
    zScoreMode = 'os';
end

% Are we permuting the data?
permutations = [];
if length(varargin) > 4
    permutations = varargin{5};
end

% Are we displaying the progress?
isVerbose = false;
if length(varargin) > 5
    isVerbose = varargin{6};
end

% Delete the file if it already exists.
if exist(filename, 'file')
    delete(filename);
end

% Fix the worm files.
if ~iscell(wormFiles)
    wormFiles =  {wormFiles};
end

% Fix the control files.
if ~isempty(controlFiles)
    if ~iscell(controlFiles)
        controlFiles =  {controlFiles};
    end
end

% Load the worm files.
useWorm = cell(length(wormFiles), 1);
wormInfo = [];
wormData = cell(length(wormFiles), 1);
for i = 1:length(wormFiles)
    data = load(wormFiles{i});
    [useWorm{i}, ~] = filterWormInfo(data.wormInfo, wormFilter);
    wormInfo = cat(1, wormInfo, data.wormInfo(useWorm{i}));
    wormData{i} = data.worm;
end

% Is there any worm data?
if length(wormInfo) <= 1
    warning('worm2StatsInfo:InsufficientWormData', ...
        'Insufficient worm data was found');
    return;
end

% Load the control files.
if ~isempty(controlFiles)
    useControl = cell(length(controlFiles), 1);
    controlInfo = [];
    controlData = cell(length(controlFiles), 1);
    for i = 1:length(controlFiles)
        data = load(controlFiles{i});
        [useControl{i}, ~] = filterWormInfo(data.wormInfo, controlFilter);
        controlInfo = cat(1, controlInfo, data.wormInfo(useControl{i}));
        controlData{i} = data.worm;
    end
    
    % Is there any control data?
    if length(controlInfo) <= 1
        warning('worm2StatsInfo:InsufficientControlData', ...
            'Insufficient control data was found');
        controlFiles = [];
    end
end

% Initialize the worm file formats.
histStr = 'histogram';
statStr = 'statistics';
isWormHist = ...
    cellfun(@(x) isfield(x.morphology.length, histStr), wormData);
wormField = cell(length(isWormHist), 1);
for i = 1:length(isWormHist)
    if isWormHist(i)
        wormField{i} = histStr;
    else
        wormField{i} = statStr;
    end
end

% Initialize the control file formats.
if ~isempty(controlFiles)
    isControlHist = ...
        cellfun(@(x) isfield(x.morphology.length, histStr), controlData);
    controlField = cell(length(isControlHist), 1);
    for i = 1:length(isWormHist)
        if isControlHist(i)
            controlField{i} = histStr;
        else
            controlField{i} = statStr;
        end
    end
end

% Initialize the feature information.
dataInfo = wormStatsInfo();

% Organize the worm features.
wormData = worm2data(dataInfo, useWorm, wormData, wormField, isVerbose);
if ~isempty(controlFiles)
    controlData = worm2data(dataInfo, useControl, controlData, ...
        controlField, isVerbose);
end

% Normalize the worm features.
if ~isempty(controlFiles)
    wormData = normalizeData(wormData, controlData, zScoreMode(1));
    if length(zScoreMode) > 1
        controlData = normalizeData(controlData, wormData, zScoreMode(2));
    else
        controlData = normalizeData(controlData, wormData, zScoreMode(1));
    end
end

% Determine the significance of the worm features.
significance.worm.pValue = [];
significance.worm.qValue = [];
significance.features = [];
if ~isempty(controlFiles)
    
    % Are any of the features present in one strain but not the other?
    isNaNWorm = isnan([wormData.data]);
    isNaNControl = isnan([controlData.data]);
    isExclusive = xor(all(isNaNWorm), all(isNaNControl));
    significance.worm.exclusiveFeaturesI = find(isExclusive);
    if ~isempty(significance.worm.exclusiveFeaturesI)
        significance.worm.pValue = 0;
        significance.worm.qValue = 0;
    end
    
    % Compute the worm feature significance.
    pTValues = mattest([wormData.data]', [controlData.data]');
    pWValues = nan(length(dataInfo), 1);
    for i = 1:length(pWValues)
        if ~(all(isNaNWorm(:,i)) || all(isNaNControl(:,i)))
            wData = [wormData(i).data];
            cData = [controlData(i).data];
            pWValues(i) = ranksum(wData(~isNaNWorm(:,i)), ...
                cData(~isNaNControl(:,i)));
        end
    end
    
    % Correct for multiple testing.
    [~, qTValues] = mafdr(pTValues);
    [~, qWValues] = mafdr(pWValues);
    
    % Organize the worm feature significance.
    significance.features(length(dataInfo), 1).pTValue = [];
    significance.features(length(dataInfo), 1).pWValue = [];
    for i = 1:length(significance.features)
        
        
        % The feature exclusively occurs within the worm or its control.
        if isExclusive(i)
            significance.features(i).pTValue = 0;
            significance.features(i).qTValue = 0;
            significance.features(i).pWValue = 0;
            significance.features(i).qWValue = 0;
            significance.features(i).power = 1;
            
%         % There is insufficient information to measure significance.
%         elseif any(isNaNWorm(:,i)) || any(isNaNControl(:,i))
%             significance.features(i).pTValue = NaN;
%             significance.features(i).qTValue = NaN;
%             significance.features(i).pWValue = NaN;
%             significance.features(i).qWValue = NaN;
%             significance.features(i).power = NaN;
            
        % The feature significance was measured.
        else
            significance.features(i).pTValue = pTValues(i);
            significance.features(i).qTValue = qTValues(i);
            significance.features(i).pWValue = pWValues(i);
            significance.features(i).qWValue = qWValues(i);
            if controlData(i).stdDev > 0
                significance.features(i).power = sampsizepwr('t', ...
                    [controlData(i).mean controlData(i).stdDev], ...
                    wormData(i).mean, [], wormData(i).samples);
            else
                significance.features(i).power = 1;
            end
        end
    end
end

% Save the features.
if isempty(controlFiles)
    save(filename, 'dataInfo', 'wormInfo', 'wormData', '-v7.3');
else
    save(filename, 'dataInfo', 'wormInfo', 'wormData', ...
        'controlInfo', 'controlData', 'significance', '-v7.3');
end
end



%% Organize the features.
function data = worm2data(info, useWorm, wormData, wormField, isVerbose)

% Organize the worm features.
data(length(info),1).zScore = [];
data(length(info),1).data = [];
for i = 1:length(info)
    
    % Are we displaying the progress?
    if isVerbose
        disp(['Organizing "' info(i).name '" ...']);
    end
    
    % The feature is not indexed.
    if isempty(info(i).index)
        for j = 1:length(wormData)
            
            % Get the feature.
            feature = getStructField(wormData{j}, ...
                info(i).field.(wormField{j}), true);
            
            % Organize the data.
            if isempty(feature)
                data(i).data = ...
                    cat(1, data(i).data, nan(sum(useWorm{j}), 1));
            else
                data(i).data = cat(1, data(i).data, feature(useWorm{j}));
            end
        end
        
        % Compute the feature statistics.
        data(i).mean = nanmean(data(i).data);
        data(i).stdDev = nanstd(data(i).data);
        data(i).samples = sum(~isnan(data(i).data));
        if data(i).samples < 3
            data(i).pNormal = NaN;
        else
            [~, data(i).pNormal, ~] = swtest(data(i).data, 0.05, 0);
        end
        
    % The feature is indexed.
    else
        for j = 1:length(wormData)
            
            % Get the feature.
            field = info(i).field.(wormField{j});
            indexI = strfind(field, ')');
            subField = [];
            eval(['subField = wormData{j}.' field(1:indexI) ';']);
            feature = getStructField(subField, field((indexI + 2):end), ...
                true);
            
            % Organize the data.
            if isempty(feature)
                data(i).data = ...
                    cat(1, data(i).data, nan(sum(useWorm{j}), 1));
            else
                data(i).data = cat(1, data(i).data, feature(useWorm{j}));
            end
        end
        
        % Compute the feature statistics.
        data(i).mean = nanmean(data(i).data);
        data(i).stdDev = nanstd(data(i).data);
        data(i).samples = sum(~isnan(data(i).data));
        if data(i).samples < 3
            data(i).pNormal = NaN;
        else
            [~, data(i).pNormal, ~] = swtest(data(i).data, 0.05, 0);
        end
    end
end

% Correct for multiple testing.
pAllValues = [data.pNormal];
pValues = pAllValues(~isnan(pAllValues));
qNormal = [];
if ~isempty(pValues)
    [~, qNormal] = mafdr(pValues);
end
qAllValues = nan(length(data), 1);
qAllValues(~isnan(pAllValues)) = qNormal;
for i = 1:length(data)
    data(i).qNormal = qAllValues(i);
end
end



%% Normalize the data.
function wormData = normalizeData(wormData, controlData, zScoreMode)
switch zScoreMode
    
    % Normalize the worm to the Opposing group.
    case 'o'
        for i = 1:length(wormData)
            
            % The worm has a feature not present in its control.
            if ~isnan(wormData(i).stdDev) && isnan(controlData(i).mean)
                wormData(i).zScore = inf;
                
            % The worm lacks a feature present in its control.
            elseif isnan(wormData(i).mean) && ~isnan(controlData(i).stdDev)
                wormData(i).zScore = -inf;
                
            % Normalize the worm to its control.
            else
                wormData(i).zScore = ...
                    (wormData(i).mean - controlData(i).mean) / ...
                    controlData(i).stdDev;
            end
        end
        
    % Normalize the worm to itself (Same).
    case 's'
        for i = 1:length(wormData)
            wormData(i).zScore = 0;
        end
        
    % Normalize the worm to both groups (Population).
    case 'p'
        for i = 1:length(wormData)
            allData = cat(1, wormData(i).data, controlData(i).data);
            wormData(i).zScore  = ...
                (wormData(i).mean - nanmean(allData)) / nanstd(allData);
        end
end
end
