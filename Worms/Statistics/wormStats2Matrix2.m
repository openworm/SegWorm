function wormStats2Matrix(filename, wormFiles, varargin)
%WORMSTATS2MATRIX Construct and save a features x worms matrix.
%
%   WORMSTATS2MATRIX(FILENAME, WORMFILES)
%
%   WORMSTATS2MATRIX(FILENAME, WORMFILES, FILT)
%
%   WORMSTATS2MATRIX(FILENAME, WORMFILES, FILT, ISVERBOSE)
%
%   Inputs:
%       filename - the features x worms matrix filename containing:
%
%                  stats    = the features x worms matrix
%                  gene     = the worm gene
%                  allele   = the worm allele
%                  strain   = the worm strain
%                  genotype = the worm genotype
%                  sex      = the worm sex
%                  food     = the worm food
%                  name     = the feature names
%                  type     = the feature type per row:
%
%                             m = morphology
%                             s = posture (shape)
%                             l = locomotion
%                             p = path
%
%                  isMain   = for each row, is it a main feature?
%                  isAbs    = for each row, is it an absolute features?
%                  isPos    = for each row, is it a positive features?
%                  isNeg    = for each row, is it a negative features?
%                  isMotion = for each row, is it a motion feature subsets?
%                  isEvent  = for each row, is it an event feature subsets?
%
%       wormFiles - the worm statistics files
%       filt - the filtering criteria; a structure with any of the fields:
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
%       isVerbose    - verbose mode displays the progress;
%                      the default is yes (true)
%
% See also WORM2STATS, FILTERWORMINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Determine the worm file filter.
filt = [];
if ~isempty(varargin)
    filt = varargin{1};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 1
    isVerbose = varargin{2};
end

% Fix the worm files.
if ~iscell(wormFiles)
    wormFiles =  {wormFiles};
end

% Initialize the feature information.
dataInfo = wormDataInfo();
histInfo = wormDisplayInfo();

% Initialize the locomotion modes.
motionNames = { ...
    'Forward', ...
    'Paused', ...
    'Backward'};

% Initialize the statistics fields.
allStr = '.statistics.data.mean.all';
absStr = '.statistics.data.mean.abs';
posStr = '.statistics.data.mean.pos';
negStr = '.statistics.data.mean.neg';

% What features do we have?
fieldName = {};
name = {};
type = [];
isMain = [];
isAbs = [];
isPos = [];
isNeg = [];
isSign = [];
isMotion = [];
isEvent = [];
totalFeatures = 0;
for i = 1:length(dataInfo)
    
    % Count the features
    field = dataInfo(i).field;
    feature = getStructField(histInfo, field);
    switch dataInfo(i).type
        
        % Count the simple features.
        case 's'
            
            % Store the main feature.
            featureName = feature.name;
            isMain(totalFeatures + 1) = true;
            fieldName{end + 1} = [field allStr];
            name{end + 1} = featureName;
            isSign(end + 1) = false;
            isAbs(end + 1) = false;
            isPos(end + 1) = false;
            isNeg(end + 1) = false;
            
            % Sign the feature.
            isSigned = getStructField(histInfo, [field '.isSigned']);
            if isSigned
                numFeatures = 4;
                fieldName{end + 1} = [field absStr];
                fieldName{end + 1} = [field posStr];
                fieldName{end + 1} = [field negStr];
                name{end + 1} = ['Absolute ' featureName];
                name{end + 1} = ['Positive ' featureName];
                name{end + 1} = ['Negative ' featureName];
                isSign((end + 1):(end + 3)) = true;
                isAbs((end + 1):(end + 3)) = [true  false false];
                isPos((end + 1):(end + 3)) = [false true false];
                isNeg((end + 1):(end + 3)) = [false false true];
            else
                numFeatures = 1;
            end
            isMotion((end + 1):(end + numFeatures)) = false;
            isEvent((end + 1):(end + numFeatures)) = false;
            
            % Count the total features
            totalFeatures = totalFeatures + numFeatures;
            isMain((end + 1):totalFeatures) = false;
            
            % Categorize the features.
            type(end + 1:end + numFeatures) = dataInfo(i).category;
            
        % Count the motion features.
        case 'm'

            % Store the main feature.
            for j = 1:length(feature)
                indexStr = ['(' num2str(j) ')'];
                featureName = feature(j).name;
                isMain(totalFeatures + 1) = true;
                numFeatures = length(motionNames) + 1;
                fieldName{end + 1} = [field indexStr allStr];
                name{end + 1} = featureName;
                isSign(end + 1) = false;
                isAbs(end + 1) = false;
                isPos(end + 1) = false;
                isNeg(end + 1) = false;
                
                % Sign the feature.
                isSigned = getStructField(histInfo, [field '.isSigned']);
                if isSigned
                    fieldName{end + 1} = [field indexStr absStr];
                    fieldName{end + 1} = [field indexStr posStr];
                    fieldName{end + 1} = [field indexStr negStr];
                    name{end + 1} = ['Absolute ' featureName];
                    name{end + 1} = ['Positive ' featureName];
                    name{end + 1} = ['Negative ' featureName];
                    isSign((end + 1):(end + 3)) = true;
                    isAbs((end + 1):(end + 3)) = [true  false false];
                    isPos((end + 1):(end + 3)) = [false true false];
                    isNeg((end + 1):(end + 3)) = [false false true];
                end
                if isSigned
                    numFeatures = numFeatures * 4;
                end
                
                % Store the feature motion.
                for k = 1:length(motionNames)
                    fieldName{end + 1} = ...
                        [field indexStr '.' lower(motionNames{k}) allStr];
                    name{end + 1} = [motionNames{k} ' ' featureName];
                    isSign(end + 1) = false;
                    isAbs(end + 1) = false;
                    isPos(end + 1) = false;
                    isNeg(end + 1) = false;
                    
                    % Sign the feature motion.
                    if isSigned
                        fieldName{end + 1} = ...
                            [field indexStr '.' lower(motionNames{k}) absStr];
                        fieldName{end + 1} = ...
                            [field indexStr '.' lower(motionNames{k}) posStr];
                        fieldName{end + 1} = ...
                            [field indexStr '.' lower(motionNames{k}) negStr];
                        name{end + 1} = ...
                            ['Absolute ' motionNames{k} ' ' featureName];
                        name{end + 1} = ...
                            ['Positive ' motionNames{k} ' ' featureName];
                        name{end + 1} = ...
                            ['Negative ' motionNames{k} ' ' featureName];
                        isSign((end + 1):(end + 3)) = true;
                        isAbs((end + 1):(end + 3)) = [true  false false];
                        isPos((end + 1):(end + 3)) = [false true false];
                        isNeg((end + 1):(end + 3)) = [false false true];
                    end
                end
                isMotion((end + 1):(end + numFeatures)) = true;
                isEvent((end + 1):(end + numFeatures)) = false;
    
                % Count the total features
                totalFeatures = totalFeatures + numFeatures;
                isMain((end + 1):totalFeatures) = false;
                
                % Categorize the features.
                type(end + 1:end + numFeatures) = dataInfo(i).category;
            end
            
        % Count the event features.
        case 'e'
            
            % Store the main feature.
            featureName = feature.name;
            
            % Count the event summary features.
            subFields = dataInfo(i).subFields.summary;
            numFeatures = length(subFields);
            for j = 1:length(subFields)
                subField = [field '.' subFields{j}];
                subData = getStructField(histInfo, subField);
                fieldName{end + 1} = [subField '.data'];
                name{end + 1} = subData.name;
            end
            isMain((end + 1):(end + numFeatures)) = true;
            isSign((end + 1):(end + numFeatures)) = false;
            isAbs((end + 1):(end + numFeatures)) = false;
            isPos((end + 1):(end + numFeatures)) = false;
            isNeg((end + 1):(end + numFeatures)) = false;
            
            % Count the event data features.
            subFields = dataInfo(i).subFields.data;
            for j = 1:length(subFields)
                isSign(end + 1) = false;
                isAbs(end + 1) = false;
                isPos(end + 1) = false;
                isNeg(end + 1) = false;
                subField = [field '.' subFields{j}];
                subData = getStructField(histInfo, subField);
                
                % Sign the event data features.
                if subData.isSigned
                    numFeatures = numFeatures + 4;
                    fieldName{end + 1} = [subField allStr];
                    fieldName{end + 1} = [subField absStr];
                    fieldName{end + 1} = [subField posStr];
                    fieldName{end + 1} = [subField negStr];
                    name{end + 1} = subData.name;
                    name{end + 1} = ['Absolute ' subData.name];
                    name{end + 1} = ['Positive ' subData.name];
                    name{end + 1} = ['Negative ' subData.name];
                    isSign((end + 1):(end + 3)) = true;
                    isAbs((end + 1):(end + 3)) = [true  false false];
                    isPos((end + 1):(end + 3)) = [false true false];
                    isNeg((end + 1):(end + 3)) = [false false true];
                else
                    numFeatures = numFeatures + 1;
                    fieldName{end + 1} = [subField allStr];
                    name{end + 1} = subData.name;
                end
            end
            isMotion((end + 1):(end + numFeatures)) = false;
            isEvent((end + 1):(end + numFeatures)) = true;
    
            % Count the total features
            totalFeatures = totalFeatures + numFeatures;
            isMain((end + 1):totalFeatures) = false;
            
            % Categorize the features.
            type(end + 1:end + numFeatures) = dataInfo(i).category;
    end
end

% Load the worms.
stats = nan(totalFeatures, length(wormFiles));
gene = cell(1, length(wormFiles));
allele = cell(1, length(wormFiles));
strain = cell(1, length(wormFiles));
genotype = cell(1, length(wormFiles));
sex = cell(1, length(wormFiles));
food = cell(1, length(wormFiles));
for i = 1:length(wormFiles)
    
    % Display our progress.
    if isVerbose
        disp(['Computing "' wormFiles{i} '" ...'])
    end
    
    % Load the file.
    wormInfo = [];
    worm = [];
    load(wormFiles{i}, 'wormInfo', 'worm');
    if isempty(wormInfo) || isempty(worm)
        continue;
    end
    
    % Filter the worm file.
    if isempty(filt)
        isUsed = true(length(wormInfo),1);
    else
        [isUsed, ~] = filterWormInfo(wormInfo, filt);
        if ~sum(isUsed)
            continue;
        end
    end
    
    % Store the worm information.
    gene{i} = wormInfo(1).experiment.worm.gene;
    allele{i} = wormInfo(1).experiment.worm.allele;
    strain{i} = wormInfo(1).experiment.worm.strain;
    genotype{i} = wormInfo(1).experiment.worm.genotype;
    sex{i} = wormInfo(1).experiment.worm.sex;
    food{i} = wormInfo(1).experiment.environment.food;
    
    % Store the worm statistics.
    for j = 1:length(fieldName)
        data = [];
        eval(['data = worm.' fieldName{j} ';']);
        if ~isnan(data)
            stats(j,i) = nanmean(data(isUsed));
        end
    end
end

% Delete the file if it already exists.
if exist(filename, 'file')
    delete(filename);
end

% Save the file.
name = name';
type = type';
isMain = isMain';
isAbs = isAbs';
isPos = isPos';
isNeg = isNeg';
isSign = isSign';
isMotion = isMotion';
isEvent = isEvent';
save(filename, 'stats', 'gene', 'allele', 'strain', 'genotype', 'sex', ...
    'food', 'name', 'type', 'isMain', 'isAbs', 'isPos', 'isNeg', ...
    'isSign', 'isMotion', 'isEvent');
end
