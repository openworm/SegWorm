function info = wormStatsInfo()
%WORMFEATUREINFO Get information for computing the worm statistics.
%
%   INFO = WORMSTATSINFO()
%
%   Output:
%       info - information for computing the worm data; a structure where:
%
%              name     = the feature's name
%              units    = the feature's units
%              title1   = the feature's 1st title
%              title1I  = the feature's 1st title index
%              title2   = the feature's 2nd title
%              title2I  = the feature's 2nd title index
%              title3   = the feature's 3rd title
%              title3I   = the feature's 3rd title index
%              field    = the feature's path; a struct where:
%
%                         histogram  = the histogram data path
%                         statistics = the statistics data path
%
%              index    = the feature's field index
%              isMain   = is this a main feature?
%              category = the feature's category, where:
%
%                         m = morphology
%                         s = posture (shape)
%                         l = locomotion
%                         p = path
%
%              type     = the feature's type, where:
%
%                         s = simple data
%                         m = motion data
%                         d = event summary data
%                         e = event data
%                         i = inter-event data
%
%              subType  = the feature's sub-type, where:
%
%                         n = none
%                         f = forward motion data
%                         b = backward motion data
%                         p = paused data
%                         t = time data
%                         d = distance data
%                         h = frequency data (Hz)
%
%              sign     = the feature's sign, where:
%
%                         s = signed data
%                         u = unsigned data
%                         a = the absolute value of the data
%                         p = the positive data
%                         n = the negative data
%
% See also WORM2STATSINFO, WORM2HISTOGRAM, ADDWORMHISTOGRAMS, WORM2STATS
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Initialize the event summary data type.
eventSummaryType = 'd';

% Initialize the feature information.
dataInfo = wormDataInfo();
histInfo = wormDisplayInfo();

% What features do we have?
info = [];
for i = 1:length(dataInfo)
    field = dataInfo(i).field;
    category = dataInfo(i).category;
    type = dataInfo(i).type;
    switch type
        
        % Add simple features.
        case 's'
            info = addInfo(info, histInfo, i, field, category, type);
            
        % Add motion features.
        case 'm'
            info = addInfo(info, histInfo, i, field, category, type);
            
        % Count the event features.
        case 'e'
            
            % Add the event summary features.
            subFields = dataInfo(i).subFields.summary;
            [info offset] = addEventSummaryInfo(info, histInfo, i, ...
                field, subFields, category, eventSummaryType);
            
            % Add the event data features.
            subFields = dataInfo(i).subFields.data;
            info = addEventInfo(info, histInfo, i, offset, ...
                field, subFields, category);
    end
end
end



%% Add the feature information.
function info = addInfo(info, histInfo, featureI, field, category, type)

% Initialize the data fields.
histStr = '.histogram.';
statStr = '.statistics.';

% Initialize the locomotion fields.
motionNames = { ...
    '', ...
    'Forward ', ...
    'Paused ', ...
    'Backward '};
motionFields = { ...
    '', ...
    '.forward', ...
    '.paused', ...
    '.backward'};
motionTypes = {
    'n'
    'f'
    'p'
    'b'};

% Initialize the signed fields.
signNames = {
    ''
    'Absolute '
    'Positive '
    'Negative '
    };
signFields = {
    'data.mean.all'
    'data.mean.abs'
    'data.mean.pos'
    'data.mean.neg'};
unsignedType = {'u'};
signedTypes = {
    's'
    'a'
    'p'
    'n'};

% Is the feature subdivided by motion?
motionEndI = 1;
if type == 'm'
    motionEndI = length(motionNames);
end

% Get the feature information.
feature = getStructField(histInfo, field);

% Add the feature information.
for i = 1:length(feature)
    
    
    % Is the feature signed?
    signEndI = 1;
    signTypes = unsignedType;
    if feature(i).isSigned
        signEndI = length(signNames);
        signTypes = signedTypes;
    end
    
    % Create the new feature.
    for j = 1:motionEndI
        for k = 1:signEndI
            newInfo = [];
            newInfo.name = ...
                [signNames{k} motionNames{j} feature(i).name];
            newInfo.unit = feature(i).unit;
            newInfo.title1 = feature(i).name;
            newInfo.title2 = motionNames{j}(1:(end - 1));
            newInfo.title3 = signNames{k}(1:(end - 1));
            newInfo.title1I = featureI;
            newInfo.title2I = j;
            newInfo.title3I = k;
            indexStr = '';
            newInfo.index = nan;
            if length(feature) > 1
                indexStr = ['(' num2str(i) ')'];
                newInfo.index = i;
            end
            newInfo.field.histogram = ...
                [field indexStr motionFields{j} histStr signFields{k}];
            newInfo.field.statistics = ...
                [field indexStr motionFields{j} statStr signFields{k}];
            newInfo.isMain = j == 1 && k == 1;
            newInfo.category = category;
            newInfo.type = type;
            newInfo.subType = motionTypes{j};
            newInfo.sign = signTypes{k};
            
            % Add the new feature.
            info = cat(1, info, newInfo);
        end
    end
end
end



%% Add the event information.
function info = addEventInfo(info, histInfo, featureI, offset, ...
    field, subFields, category)

% Initialize the feature type.
eventType = 'e';
interType = 'i';
interStr = 'inter';

% Initialize the data fields.
histStr = '.histogram.';
statStr = '.statistics.';

% Initialize the signed fields.
signNames = {
    ''
    'Absolute '
    'Positive '
    'Negative '
    };
signFields = {
    'data.mean.all'
    'data.mean.abs'
    'data.mean.pos'
    'data.mean.neg'};
unsignedType = {'u'};
signedTypes = {
    's'
    'a'
    'p'
    'n'};

% Get the feature information.
feature = getStructField(histInfo, field);

% Add the feature information.
for i = 1:length(feature)
    for j = 1:length(subFields)
        
        % Get the feature information.
        subFeature = getStructField(feature(i), subFields{j});
        
        % Determine the feature type.
        if strncmp(subFields{j}, interStr, length(interStr))
            type = interType;
            subType = lower(subFields{j}(length(interStr) + 1));
        else
            type = eventType;
            subType = subFields{j}(1);
        end
        
        % Is the feature signed?
        signEndI = 1;
        signTypes = unsignedType;
        if subFeature(i).isSigned
            signEndI = length(signNames);
            signTypes = signedTypes;
        end
        
        % Create the new feature.
        for k = 1:signEndI
            newInfo = [];
            newInfo.name = [signNames{k} subFeature.name];
            newInfo.unit = subFeature.unit;
            newInfo.title1 = feature(i).name;
            newInfo.title2 = subFeature.shortName;
            newInfo.title3 = signNames{k}(1:(end - 1));
            newInfo.title1I = featureI;
            newInfo.title2I = j + offset;
            newInfo.title3I = k;
            indexStr = '.';
            newInfo.index = nan;
            if length(feature) > 1
                indexStr = ['(' num2str(i) ').'];
                newInfo.index = i;
            end
            newInfo.field.histogram = ...
                [field indexStr subFields{j} histStr signFields{k}];
            newInfo.field.statistics = ...
                [field indexStr subFields{j} statStr signFields{k}];
            newInfo.isMain = k == 1;
            newInfo.category = category;
            newInfo.type = type;
            newInfo.subType = subType;
            newInfo.sign = signTypes{k};
            
            % Add the new feature.
            info = cat(1, info, newInfo);
        end
    end
end
end



%% Add the event summary information.
function [info offset] = addEventSummaryInfo(info, histInfo, featureI, ...
    field, subFields, category, type)

% Initialize the summary features sign.
summarySign = 'u';

%I nitialize the event summary fields.
dataStr = '.data';
ratioStr = 'ratio.';

% Add the event summary sub fields.
for i = 1:length(subFields)
    
    % Get the feature information.
    feature = getStructField(histInfo, field);
    subFeature = getStructField(feature, subFields{i});
    
    % Determine the sub-feature type.
    if subFields{i}(1) == 'f'
        subType = 'h';
    elseif subFields{i}(1) == ratioStr(1)
        subType = subFields{i}(length(ratioStr) + 1);
    else
        subType = subFields{i}(1);
    end
        
    % Create the new feature.
    newInfo = [];
    newInfo.name = subFeature.name;
    newInfo.unit = subFeature.unit;
    newInfo.title1 = feature.name;
    newInfo.title2 = subFeature.shortName;
    newInfo.title3 = '';
    newInfo.title1I = featureI;
    newInfo.title2I = i;
    newInfo.title3I = 1;
    newInfo.field.histogram = [field '.' subFields{i} dataStr];
    newInfo.field.statistics = newInfo.field.histogram;
    newInfo.index = nan;
    newInfo.isMain = false;
    newInfo.category = category;
    newInfo.type = type;
    newInfo.subType = subType;
    newInfo.sign = summarySign;
    
    % Add the new feature.
    info = cat(1, info, newInfo);
end

% Set the offset.
offset = i;
end