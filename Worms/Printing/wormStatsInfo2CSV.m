function wormStatsInfo2CSV(filename, wormFile, varargin)
%WORMSTATSINFO2CSV Convert the worm statistics to a set of CSV files.
%
%   WORMSTATSINFO2CSV(FILENAME, WORMFILE)
%   WORMSTATSINFO2CSV(FILENAME, WORMFILE, SIGFILE, SEPARATOR, VERBOSE)
%
%   Inputs:
%       filename  - the CSV filename
%       wormFile  - the filename containing the worm statistics
%                   (see WORM2STATSINFO)
%       sigFile   - a file containing a matrix of worm significance to use
%                   in place of those in the wormFile
%                   (see WORMSTATS2MATRIX)
%                   the default is none ([])
%       separator - the separator string to use
%                   the default is ','
%       isVerbose - verbose mode displays the progress;
%                   the default is yes (true)
%
% See also WORM2STATSINFO, WORMSTATS2MATRIX
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% What string should we use as the separator?
sigFile = [];
if ~isempty(varargin)
    sigFile = varargin{1};
end

% What string should we use as the separator?
sepStr = ',';
if length(varargin) > 1
    sepStr = varargin{2};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 2
    isVerbose = varargin{3};
end

% Load the statistics data.
wormInfo = [];
controlInfo = [];
wormData = [];
controlData = [];
significance = [];
load(wormFile, 'wormInfo', 'controlInfo', 'wormData', 'controlData', ...
    'significance');

% Is there any data?
if isempty(wormInfo)
    warning('wormStatsInfo2CSV:NoWormInfo', ...
        [wormFile ' does not contain "wormInfo"']);
    return;
end
if isempty(wormData)
    warning('wormStatsInfo2CSV:NoWormData', ...
        [wormFile ' does not contain "wormData"']);
    return;
end
if isempty(controlInfo)
    warning('wormStatsInfo2CSV:NoControlInfo', ...
        [wormFile ' does not contain "wormInfo"']);
end
if isempty(controlData)
    warning('wormStatsInfo2CSV:NoControlData', ...
        [wormFile ' does not contain "wormData"']);
end
if isempty(significance)
    warning('wormStatsInfo2CSV:NoSignificance', ...
        [wormFile ' does not contain "significance"']);
end

% Use the matrix statistics.
sig = [];
if ~isempty(sigFile)
    
    % Is there any significance data?
    if isempty(whos('-FILE', sigFile, 'worm'))
        warning('wormStatsInfo2CSV:NoMatrix', ...
            [sigFile ' does not contain "worm" significance']);
        
    % Load the significance matrix.
    else
        sigData = load(sigFile, 'worm', 'control');
        
        % Find the genotype.
        genotype = worm2GenotypeLabel(wormInfo);
        strainI = find(cellfun(@(x) strcmp(genotype, x), ...
            sigData.worm.info.genotype));
        
        % Determine the significance.
        if length(strainI) == 1
            sig.pNWorm = sigData.worm.stats.pNormal(strainI,:);
            sig.qNWorm = sigData.worm.stats.qNormal.all(strainI,:);
            sig.pNControl = sigData.control.stats.pNormal(strainI,:);
            sig.qNControl = sigData.control.stats.qNormal.all(strainI,:);
            sig.pW = sigData.worm.sig.pWValue(strainI,:);
            sig.qW = sigData.worm.sig.qWValue.all(strainI,:);
            sig.pT = sigData.worm.sig.pTValue(strainI,:);
            sig.qT = sigData.worm.sig.qTValue.all(strainI,:);
%             sig.power = sigData.worm.sig.power(strainI,:);
            sig.pWorm = min(sig.pW);
            sig.qWorm = min(sig.qW);
            
        % We can't find the strain.
        elseif isempty(strainI)
            warning('wormStatsInfo2CSV:NoGenotype', ...
                [sigFile ' is missing "' genotype '"']);
            
        % We found too many strains.
        elseif length(strainI) > 1
            warning('wormStatsInfo2CSV:ManyGenotypes', ...
                [sigFile ' has more than 1 "' genotype '"']);
        end
    end
end

% Use the strain statistics.
if isempty(sig) && ~isempty(significance)
    sig.pNWorm = [wormData.pNormal];
    sig.qNWorm = [wormData.qNormal];
    sig.pNControl = [controlData.pNormal];
    sig.qNControl = [controlData.qNormal];
    sig.pW = [significance.features.pWValue];
    sig.qW = [significance.features.qWValue];
    sig.pT = [significance.features.pTValue];
    sig.qT = [significance.features.qTValue];
%     sig.power = [significance.features.power];
    sig.pWorm = significance.worm.pValue;
    sig.qWorm = significance.worm.qValue;
end

% Sort the worm and controls by date.
% [~, wormSortI] = sort(arrayfun(@(x) ...
%     datenum(x.experiment.environment.timestamp), wormInfo));
% controlSortI = [];
% if ~isempty(controlInfo)
%     [~, controlSortI] = sort(arrayfun(@(x) ...
%         datenum(x.experiment.environment.timestamp), controlInfo));
% end

% Initialize the feature information.
info = wormStatsInfo();

% Fix the file name
csvExt = '.csv';
if strcmpi(filename((end - length(csvExt) + 1):end), csvExt)
    filename = filename(1:(end - length(csvExt)));
end

% Initialize the feature CSV files.
filenames = {
    [filename '.morphology' csvExt]
    [filename '.posture' csvExt]
    [filename '.motion' csvExt]
    [filename '.path' csvExt]};
names = {
    'Morphology Features'
    'Posture Features'
    'Motion Features'
    'Path Features'};
categories = [ ...
    'm', ...
    's', ...
    'l', ...
    'p'];

% Print the feature categories separately.
for i = 1:length(filenames)
    if isVerbose
        disp(['Printing ' num2str(i) '/' num2str(length(filenames)) ...
            '"' filenames{i} '" ...']);
    end
    printFile(filenames{i}, names{i}, categories(i), info, sepStr, ...
        wormInfo, controlInfo, wormData, controlData, sig);
end
end



%% Print the feature file.
function printFile(filename, featureName, category, info, sepStr, ...
    wormInfo, controlInfo, wormData, controlData, significance)

% Initialize the experimnet information fields.
genotypeField = 'experiment.worm.genotype';
strainField = 'experiment.worm.strain';
dateField = 'experiment.environment.timestamp';
sep1 = repmat(sepStr, 1, 2);

% Open the file.
file = fopen(filename, 'w');

% Print header.
if isempty(controlInfo)
    fprintf(file, 'INFO%sEXPERIMENTS', sep1);
else
    fprintf(file, 'INFO%sEXPERIMENTS%sCONTROLS', sep1, ...
        repmat(sepStr, 1, length(wormInfo) + 1));
end
fprintf(file, '\n');
fprintf(file, '\n');

% Print the genotype.
fprintf(file, 'Strain%s', sep1);
printField(wormInfo, strainField, sepStr, file);
if ~isempty(controlInfo)
    fprintf(file, '%s', sepStr);
    printField(controlInfo, strainField, sepStr, file);
end
fprintf(file, '\n');

% Print the strain.
fprintf(file, 'Genotype%s', sep1);
printField(wormInfo, genotypeField, sepStr, file);
if ~isempty(controlInfo)
    fprintf(file, '%s', sepStr);
    printField(controlInfo, genotypeField, sepStr, file);
end
fprintf(file, '\n');

% Print the date.
fprintf(file, 'Date%s', sep1);
printField(wormInfo, dateField, sepStr, file, @(x) datestr(datenum(x)));
if ~isempty(controlInfo)
    fprintf(file, '%s', sepStr);
    printField(controlInfo, dateField, sepStr, file, ...
        @(x) datestr(datenum(x)));
end
fprintf(file, '\n\n\n\n');

% Print the significance.
if ~isempty(significance) && ~isempty(significance.pWorm)
    fprintf(file, 'TOTAL FEATURE SIGNIFICANCE\n');
    fprintf(file, 'p-value%s%d\n', sep1, significance.pWorm);
    fprintf(file, 'q-value%s%d%s%s\n', sep1, significance.qWorm, ...
        sepStr, p2stars(significance.qWorm));
    fprintf(file, '\n\n\n');
end

% Print the features.
if isempty(controlData)
    printFeatures(file, featureName, category, info, sepStr, sep1, ...
        wormData);
else
    printSignificantFeatures(file, featureName, category, info, sepStr, ...
        sep1, wormInfo, wormData, controlData, significance);
end

% Close the file.
fclose(file);
end



%% Print the features significance.
function printSignificantFeatures(file, featureName, category, info, ...
    sepStr, sep1, wormInfo, wormData, controlData, significance)

% Print the header.
fprintf(file, '%s\n\n', upper(featureName));

% Find the categorical features.
features = find([info.category] == category);

% Remove paused motion features.
if category == 'l'
    featureLabels = {info.name};
    lowerLabels = lower(featureLabels);
    pausedI = cellfun(@(x) ~isempty(strfind(x, 'paused')), lowerLabels);
    crawlI = cellfun(@(x) ~isempty(strfind(x, 'crawl')), lowerLabels);
    remI = find(pausedI & crawlI);
    features = setdiff(features, remI);
end

% Print the features.
for i = 1:length(features)
    
    % Print the title.
    featI = features(i);
    featTitle = upper([info(featI).name ' (' info(featI).unit ')']);
    if info(featI).title2I == 1 && info(featI).title3I == 1 
        fprintf(file, '\n\n\n"> %s"\n\n', featTitle);
    elseif info(featI).title3I == 1
        fprintf(file, '\n">> %s"\n\n', featTitle);
    else
        fprintf(file, '">>> %s"\n\n', featTitle);
    end
    
    % Print the significance.
    if ~isempty(significance)
        fprintf(file, 'SIGNIFICANCE\n');
        fprintf(file, 'Rank-sum p%s%d\n', sep1, significance.pW(featI));
        fprintf(file, 'Rank-sum q%s%d%s%s\n', sep1, ...
            significance.qW(featI), sepStr, ...
            p2stars(significance.qW(featI)));
        fprintf(file, 'T-test p%s%d\n', sep1, significance.pT(featI));
        fprintf(file, 'T-test q%s%d%s%s\n\n', sep1, ...
            significance.qT(featI), sepStr, ...
            p2stars(significance.qT(featI)));
%         fprintf(file, 'Power%s%d\n\n', sep1, significance.power(featI));
    end
    
    % Print the normality.
    fprintf(file, 'NORMALITY%sEXPERIMENT%s%sCONTROL\n', sep1, sep1, ...
        sepStr);
    fprintf(file, 'Shapiro-Wilk p%s%d%s%s%d\n', sep1, ...
        significance.pNWorm(featI), sep1, sepStr, ...
        significance.pNControl(featI));
    fprintf(file, 'Shapiro-Wilk q%s%d%s%s%s%d%s%s\n\n', sep1, ...
        significance.qNWorm(featI), sepStr, ...
        p2stars(significance.qNWorm(featI)), sep1, ...
        significance.qNControl(featI), sepStr, ...
        p2stars(significance.qNControl(featI)));
    
    % Print the summary data.
    fprintf(file, 'SUMMARY%sEXPERIMENT%s%sCONTROL\n', sep1, sep1, sepStr);
    fprintf(file, 'Mean%s%d%s%s%d\n', sep1, wormData(featI).mean, ...
        sep1, sepStr, controlData(featI).mean);
    fprintf(file, 'S.D.%s%d%s%s%d\n', sep1, wormData(featI).stdDev, ...
        sep1, sepStr, controlData(featI).stdDev);
    fprintf(file, 'Samples%s%d%s%s%d\n\n', sep1, wormData(featI).samples, ...
        sep1, sepStr, controlData(featI).samples);
    
    % Print all the data.
    fprintf(file, 'DETAILS%sEXPERIMENT%sCONTROL\n', sep1, ...
        repmat(sepStr, 1, length(wormInfo) + 1));
    if info(featI).type == 'd'
        fprintf(file, 'Value%s', sep1);
        printData(file, wormData(featI).dataMeans, sepStr);
        fprintf(file, '%s', sepStr);
        printData(file, controlData(featI).dataMeans, sepStr);
    else
        fprintf(file, 'Mean%s', sep1);
        printData(file, wormData(featI).dataMeans, sepStr);
        fprintf(file, '%s', sepStr);
        printData(file, controlData(featI).dataMeans, sepStr);
        fprintf(file, '\nS.D.%s', sep1);
        printData(file, wormData(featI).dataStdDevs, sepStr);
        fprintf(file, '%s', sepStr);
        printData(file, controlData(featI).dataStdDevs, sepStr);
        fprintf(file, '\nSamples%s', sep1);
        printData(file, wormData(featI).dataSamples, sepStr);
        fprintf(file, '%s', sepStr);
        printData(file, controlData(featI).dataSamples, sepStr);
    end
    fprintf(file, '\n\n');
end
end



%% Print the features.
function printFeatures(file, featureName, category, info, sepStr, sep1, ...
    wormData)

% Print the header.
fprintf(file, '%s\n\n', upper(featureName));

% Find the categorical features.
features = find([info.category] == category);

% Remove paused motion features.
if category == 'l'
    featureLabels = {info.name};
    lowerLabels = lower(featureLabels);
    pausedI = cellfun(@(x) ~isempty(strfind(x, 'paused')), lowerLabels);
    bendI = cellfun(@(x) ~isempty(strfind(x, 'bend')), lowerLabels);
    amplitudeI = ...
        cellfun(@(x) ~isempty(strfind(x, 'amplitude')), lowerLabels);
    frequencyI = ...
        cellfun(@(x) ~isempty(strfind(x, 'frequency')), lowerLabels);
    remI = find(pausedI & bendI & (amplitudeI | frequencyI));
    features = setdiff(features, remI);
end

% Print the features.
for i = 1:length(features)
    
    % Print the title.
    featI = features(i);
    featTitle = upper([info(featI).name ' (' info(featI).unit ')']);
    if info(featI).title2I == 1 && info(featI).title3I == 1 
        fprintf(file, '\n\n\n"> %s"\n\n', featTitle);
    elseif info(featI).title3I == 1
        fprintf(file, '\n">> %s"\n\n', featTitle);
    else
        fprintf(file, '">>> %s"\n\n', featTitle);
    end
    
    % Print the normality.
    fprintf(file, 'NORMALITY%sEXPERIMENT\n', sep1);
    fprintf(file, 'Shapiro-Wilk p%s%d\n', sep1, ...
        wormData(featI).pNormal);
    fprintf(file, 'Shapiro-Wilk q%s%d%s%s\n\n', sep1, ...
        wormData(featI).qNormal, sepStr, p2stars(wormData(featI).qNormal));
    
    % Print the summary data.
    fprintf(file, 'SUMMARY%sEXPERIMENT\n', sep1);
    fprintf(file, 'Mean%s%d\n', sep1, wormData(featI).mean);
    fprintf(file, 'S.D.%s%d\n', sep1, wormData(featI).stdDev);
    fprintf(file, 'Samples%s%d\n\n', sep1, wormData(featI).samples);
    
    % Print all the data.
    fprintf(file, 'DETAILS%sEXPERIMENT\n', sep1);
    if info(featI).type == 'd'
        fprintf(file, 'Value%s', sep1);
        printData(file, wormData(featI).dataMeans, sepStr);
    else
        fprintf(file, 'Mean%s', sep1);
        printData(file, wormData(featI).dataMeans, sepStr);
        fprintf(file, '\nS.D.%s', sep1);
        printData(file, wormData(featI).dataStdDevs, sepStr);
        fprintf(file, '\nSamples%s', sep1);
        printData(file, wormData(featI).dataSamples, sepStr);
    end
    fprintf(file, '\n\n');
end
end



%% Print a struct field.
% varargin = func
% func - a function to run on the field data
function printField(structs, field, sepStr, file, varargin)

% Are we running a function over the field data?
func = @(x) x;
if ~isempty(varargin)
    func = varargin{1};
end

% Print the field data.
for i = 1:length(structs)
    fprintf(file, '"%s"%s', func(getStructField(structs(i), field)), ...
        sepStr);
end
end



%% Print the data.
function printData(file, data, sepStr)
for i = 1:length(data)
    fprintf(file, '%d%s', data(i), sepStr);
end
end
