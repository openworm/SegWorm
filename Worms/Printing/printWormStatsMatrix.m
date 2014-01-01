function printWormStatsMatrix(filename, wormFile, varargin)
%PRINTWORMSTATSMATRIX Print a worms x features matrix to a CSV file.
%
%   PRINTWORMSTATSMATRIX(FILENAME, WORMFILES)
%
%   PRINTWORMSTATSMATRIX(FILENAME, WORMFILES, ISTRANSPOSE,
%                        ISHOWMAIN, SHOWCATEGORY, SHOWTYPE, SHOWSIGN, SHOWI,
%                        VERBOSE)
%
%   Inputs:
%       filename - the file name for the worms x features matrix
%       wormFile - the worms x features matrix file;
%                  a file containing structures with fields:
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
%                                e = event data
%                                f = event summary
%
%                     sign     = the feature's sign, where:
%
%                                d = all data
%                                a = the absolute value of the data
%                                p = the positive data
%                                n = the negative data
%
%                  worm:
%
%                     label   = the worm labels
%                     mean    = the worm data means (worms x features)
%                     zScore  = the worm data z-scores (worms x features)
%                     pValue  = the worm data p-values (worms x features)
%                     qValue  = the worm data q-values (worms x features)
%                     power   = the worm data power (worms x features)
%
%       isTranspose  - are we transposing the file to features x worms?
%       isShowMain   - are we showing the main features?
%                      the default is yes (true)
%       showCategory - which feature categories should we show?
%                      the default is all categories ([] or 'mslp')
%
%                      m = morphology
%                      s = posture (shape)
%                      l = locomotion
%                      p = path
%
%       showType     - which feature types should we show?
%                      the default is all types ([] or 'smef')
%
%                      s = simple data
%                      m = motion data
%                      e = event data
%                      f = event summary
%
%       showSign     - which feature signs should we show?
%                      the default is all signs ([] or 'dapn')
%
%                      d = all data
%                      a = the absolute value of the data
%                      p = the positive data
%                      n = the negative data
%
%       showI        - the indices of the features to show;
%                      the default is all ([])
%       isVerbose    - verbose mode displays the progress;
%                      the default is yes (true)
%
% See also WORM2STATSMATRIX
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we transposing the plot to features x worms?
isTranspose = false;
if ~isempty(varargin)
    isTranspose = varargin{1};
end

% Are we showing the main features?
isShowMain = true;
if length(varargin) > 1
    isShowMain = varargin{2};
end

% Which feature categories should we show?
showCategory = [];
if length(varargin) > 2
    showCategory = varargin{3};
end

% Which feature types should we show?
showType = [];
if length(varargin) > 3
    showType = varargin{4};
end

% Which feature signs should we show?
showSign = [];
if length(varargin) > 4
    showSign = varargin{5};
end

% Determine the indices of the features to show.
showI = [];
if length(varargin) > 5
    showI = varargin{6};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 6
    isVerbose = varargin{7};
end

% Load the matrix.
data = load(wormFile);

% Initialize the feature information.
dataInfo = wormStatsInfo();

% Determine the worm labels.
strains = data.worm.strain;
genotypes = data.worm.genotype;

% Remove unwanted features.
isShow = true(length(dataInfo), 1);
if ~isShowMain
    isShow([dataInfo.isMain]) = false;
end
if ~isempty(showCategory)
    hide = setdiff('mslp', showCategory);
    for i = 1:length(hide)
        isShow([dataInfo.category] == hide(i)) = false;
    end
end
if ~isempty(showType)
    hide = setdiff('smef', showType);
    for i = 1:length(hide)
        isShow([dataInfo.type] == hide(i)) = false;
    end
end
if ~isempty(showSign)
    hide = setdiff('dapn', showSign);
    for i = 1:length(hide)
        isShow([dataInfo.sign] == hide(i)) = false;
    end
end
if ~isempty(showI)
    isShow(showI) = true;
end

% Remove paused motion features.
featureLabels = {dataInfo.name};
lowerLabels = lower(featureLabels);
pausedI = cellfun(@(x) ~isempty(strfind(x, 'paused')), lowerLabels);
bendI = cellfun(@(x) ~isempty(strfind(x, 'bend')), lowerLabels);
amplitudeI = cellfun(@(x) ~isempty(strfind(x, 'amplitude')), lowerLabels);
frequencyI = cellfun(@(x) ~isempty(strfind(x, 'frequency')), lowerLabels);
isShow(pausedI & bendI & (amplitudeI | frequencyI)) = false;
dataInfo = dataInfo(isShow);

% Find the wild-type control values.
%controlStr = 'N2: C. elegans Wild Isolate, Schafer Lab N2 (Bristol, UK)';
controlStr = 'C. elegans Wild Isolate, Schafer Lab N2 (Bristol, UK)';
controlI = cellfun(@(x) strcmp(x, controlStr), genotypes);
controlI = find(controlI);
if length(controlI) ~= 1
    warning('plotWormStatsMatrix:NoControl', ...
        'Cannot find the wild-type control');
end

% Find the wild-type males.
maleI = find(cellfun(@(x) ~isempty(strfind(x, 'Male')), genotypes)');

% Find the axenic CGC wild-type.
axenicI = find(cellfun(@(x) ~isempty(strfind(x, 'Axenic')), genotypes)');

% Find the axenic CGC wild-type.
CGCI = find(cellfun(@(x) ~isempty(strfind(x, 'CGC')), genotypes)');
CGCI = setdiff(CGCI, axenicI);

% Find the N2 month, day, and time controls.
N2I = find(cellfun(@(x) ~isempty(strfind(x, 'Lab N2')), genotypes))';
N2I = setdiff(N2I, [controlI, maleI, axenicI, CGCI]);

% Find the wild-type isolates.
wildI = find(cellfun(@(x) ~isempty(strfind(x, 'Wild')), genotypes))';
wildI = setdiff(wildI, [controlI, maleI, axenicI, CGCI, N2I]);

% Find the non wild types.
wormI = 1:length(genotypes);
wormI = setdiff(wormI, [controlI, maleI, axenicI, CGCI, N2I, wildI]);
[~, sortI] = sort(lower(genotypes(wormI)));
wormI = wormI(sortI);

% Initialize the worm data.
wormMeans = data.worm.mean(:,isShow);
wormStdDevs = data.worm.stdDev(:,isShow);
wormSamples = data.worm.samples(:,isShow);
qValues = data.worm.qValue(:,isShow);
powers = data.worm.power(:,isShow);

% Initialize the control data.
controlMeans = data.control.mean(:,isShow);
controlStdDevs = data.control.stdDev(:,isShow);
controlSamples = data.control.samples(:,isShow);

% Clean up the worm labels.
genotypes = cellfun(@(x) strrep(x, ',', '.'), genotypes, ...
    'UniformOutput', false);

% Delete the file if it already exists.
if exist(filename, 'file')
    delete(filename);
end

% Open the file.
fid = fopen(filename, 'w');

% Print the features x worms.
if isTranspose

    % Reorganize the worms.
    wormI = [controlI, maleI, CGCI, axenicI, wildI, wormI, N2I];
    strains = strains(wormI);
    genotypes = genotypes(wormI);
    wormMeans = wormMeans(wormI,:);
    wormStdDevs = wormStdDevs(wormI,:);
    wormSamples = wormSamples(wormI,:);
    qValues = qValues(wormI,:);
    powers = powers(wormI,:);
    
    % Reorganize the controls.
    controlMeans = controlMeans(wormI,:);
    controlStdDevs = controlStdDevs(wormI,:);
    controlSamples = controlSamples(wormI,:);
    
    % Print the worm header.
    fprintf(fid, ',Strain & Genotype,,,');
    for i = 1:length(strains)
        fprintf(fid, '%s,%s,,', strains{i}, genotypes{i});
    end
    fprintf(fid, '\n');
    
    % Print the worm samples header.
    fprintf(fid, ',,,,');
    for i = 1:length(genotypes)
        fprintf(fid, 'Samples,%d,,', wormSamples(i,1));
    end
    fprintf(fid, '\n');
    
    % Print the control samples header.
    fprintf(fid, ',,,,,,,');
    for i = 2:length(genotypes)
        fprintf(fid, 'Control Samples,%d,,', controlSamples(i,1));
    end
    fprintf(fid, '\n');
    
    % Print the features.
    fprintf(fid, 'Feature,\n');
    printFeatures(fid, dataInfo, wormMeans, wormStdDevs, wormSamples, ...
        qValues, powers, controlMeans, controlStdDevs, controlSamples, ...
        isVerbose);
    
% Print the worms x features.
else
    
    % Print the features 1st title.
    fprintf(fid, ',Feature,');
    for i = 1:length(dataInfo)
        if dataInfo(i).title2I == 1 && dataInfo(i).title3I == 1
            fprintf(fid, '%s,', dataInfo(i).title1);
        else
            fprintf(fid, ',');
        end
    end
    fprintf(fid, '\n');
    
    % Print the features 2nd title.
    fprintf(fid, ',,');
    for i = 1:length(dataInfo)
        if dataInfo(i).title3I == 1
            fprintf(fid, '%s,', dataInfo(i).title2);
        else
            fprintf(fid, ',');
        end
    end
    fprintf(fid, '\n');
    
    % Print the features 3rd title.
    fprintf(fid, ',,');
    for i = 1:length(dataInfo)
        fprintf(fid, '%s,', dataInfo(i).title3);
    end
    fprintf(fid, '\n');
    
    % Print the features 2nd title.
    fprintf(fid, ',Units,');
    for i = 1:length(dataInfo)
        fprintf(fid, '%s,', dataInfo(i).unit);
    end
    fprintf(fid, '\n');
    
    % Print the control.
    fprintf(fid, 'Strain & Genotype\n');
    printControl(fid, strains{controlI}, genotypes{controlI}, ...
        wormMeans(controlI,:), wormStdDevs(controlI,:), ...
        wormSamples(controlI,:), isVerbose);

    % Print the males.
    printWorms(fid, strains(maleI), genotypes(maleI), ...
        wormMeans(maleI,:), wormStdDevs(maleI,:), ...
        wormSamples(maleI,:), qValues(maleI,:), powers(maleI,:), ...
        controlMeans(maleI,:), controlStdDevs(maleI,:), ...
        controlSamples(maleI,:), isVerbose);
    
    % Print the CGC N2.
    printWorms(fid, strains(CGCI), genotypes(CGCI), ...
        wormMeans(CGCI,:), wormStdDevs(CGCI,:), ...
        wormSamples(CGCI,:), qValues(CGCI,:), powers(CGCI,:), ...
        controlMeans(CGCI,:), controlStdDevs(CGCI,:), ...
        controlSamples(CGCI,:), isVerbose);
    
    % Print the axenic CGC N2.
    printWorms(fid, strains(axenicI), genotypes(axenicI), ...
        wormMeans(axenicI,:), wormStdDevs(axenicI,:), ...
        wormSamples(axenicI,:), qValues(axenicI,:), powers(axenicI,:), ...
        controlMeans(axenicI,:), controlStdDevs(axenicI,:), ...
        controlSamples(axenicI,:), isVerbose);
    
    % Print the wild-type isolates.
    printWorms(fid, strains(wildI), genotypes(wildI), ...
        wormMeans(wildI,:), wormStdDevs(wildI,:), ...
        wormSamples(wildI,:), qValues(wildI,:), powers(wildI,:), ...
        controlMeans(wildI,:), controlStdDevs(wildI,:), ...
        controlSamples(wildI,:), isVerbose);
    
    % Print the worms.
    printWorms(fid, strains(wormI), genotypes(wormI), ...
        wormMeans(wormI,:), wormStdDevs(wormI,:), ...
        wormSamples(wormI,:), qValues(wormI,:), powers(wormI,:), ...
        controlMeans(wormI,:), controlStdDevs(wormI,:), ...
        controlSamples(wormI,:), isVerbose);
    
    % Print the N2s.
    printWorms(fid, strains(N2I), genotypes(N2I), ...
        wormMeans(N2I,:), wormStdDevs(N2I,:), ...
        wormSamples(N2I,:), qValues(N2I,:), powers(N2I,:), ...
        controlMeans(N2I,:), controlStdDevs(N2I,:), ...
        controlSamples(N2I,:), isVerbose);
end

% Clean up.
fclose(fid);
end



%% Print the control.
function printControl(fid, strain, genotype, wormMean, wormStdDev, ...
    wormSamples, isVerbose)

% Display the progress.
if isVerbose
    disp(['Printing ' genotype ' ...']);
end

% Print the mean.
fprintf(fid, '%s,Mean,', strain);
for i = 1:length(wormMean)
    fprintf(fid, '%d,', wormMean(i));
end
fprintf(fid, '\n');

% Print the standard deviation.
fprintf(fid, '%s,S.D.,', genotype);
for i = 1:length(wormStdDev)
    fprintf(fid, '%d,', wormStdDev(i));
end
fprintf(fid, '\n');

% Print the wormSamples.
fprintf(fid, 'Samples,\n');
fprintf(fid, '%d,', wormSamples(1));
fprintf(fid, '\n\n');
end



%% Print the worms.
function printWorms(fid, strains, genotypes, wormMean, wormStdDev, ...
    wormSamples, qValues, powers, controlMean, controlStdDev, ...
    controlSamples, isVerbose)

% Print the worms and display the progress.
if isVerbose
    for i = 1:length(genotypes)
        disp(['Printing ' genotypes{i} ' ...']);
        printWormData(fid, strains{i}, genotypes{i}, wormMean(i,:), ...
            wormStdDev(i,:), wormSamples(i,:), qValues(i,:), ...
            powers(i,:), controlMean(i,:), controlStdDev(i,:), ...
            controlSamples(i,:));
    end
    
% Print the worms.
else
    for i = 1:length(genotypes)
        printWormData(fid, strains{i}, genotypes{i}, wormMean(i,:), ...
            wormStdDev(i,:), wormSamples(i,:), qValues(i,:), ...
            powers(i,:), controlMean(i,:), controlStdDev(i,:), ...
            controlSamples(i,:));
    end
end
end



%% Print the worm data.
function printWormData(fid, strain, genotype, wormMean, wormStdDev, ...
    wormSamples, qValue, power, controlMean, controlStdDev, controlSamples)

% Print the worm mean.
fprintf(fid, '%s,Mean,', strain);
for i = 1:length(wormMean)
    fprintf(fid, '%d,', wormMean(i));
end
fprintf(fid, '\n');

% Print the worm standard deviation.
fprintf(fid, '%s,S.D.,', genotype);
for i = 1:length(wormStdDev)
    fprintf(fid, '%d,', wormStdDev(i));
end
fprintf(fid, '\n');

% Print the worm samples and q-value.
fprintf(fid, 'Samples,Q-Value,');
for i = 1:length(wormStdDev)
    fprintf(fid, '%d,', qValue(i));
end
fprintf(fid, '\n');

% Print the power.
fprintf(fid, '%d,Power,', wormSamples(1));
for i = 1:length(wormStdDev)
    fprintf(fid, '%d,', power(i));
end
fprintf(fid, '\n');

% Print the control mean.
fprintf(fid, 'Control Samples,Control Mean,');
for i = 1:length(controlMean)
    fprintf(fid, '%d,', controlMean(i));
end
fprintf(fid, '\n');

% Print the control standard deviation.
fprintf(fid, '%d,Control S.D.,', controlSamples(1));
for i = 1:length(controlStdDev)
    fprintf(fid, '%d,', controlStdDev(i));
end
fprintf(fid, '\n\n');
end



%% Print the features.
function printFeatures(fid, dataInfo, wormMean, wormStdDev, ...
    wormSamples, qValues, powers, controlMean, controlStdDev, ...
    controlSamples, isVerbose)

% Print the worms and display the progress.
if isVerbose
    for i = 1:length(dataInfo)
        disp(['Printing ' dataInfo(i).name ' ...']);
        printFeatureData(fid, dataInfo(i), wormMean(:,i), ...
            wormStdDev(:,i), wormSamples(:,i), qValues(:,i), ...
            powers(:,i), controlMean(:,i), controlStdDev(:,i), ...
            controlSamples(:,i));
    end
    
% Print the worms.
else
    for i = 1:length(dataInfo)
        printFeatureData(fid, dataInfo(i), wormMean(:,i), ...
            wormStdDev(:,i), wormSamples(:,i), qValues(:,i), ...
            powers(:,i), controlMean(:,i), controlStdDev(:,i), ...
            controlSamples(:,i));
    end
end
end



%% Print the feature data.
function printFeatureData(fid, dataInfo, wormMean, wormStdDev, ...
    wormSamples, qValue, power, controlMean, controlStdDev, controlSamples)

% Organize the feature titles.
title1 = '';
if dataInfo.title2I == 1 && dataInfo.title3I == 1
    title1 = dataInfo.title1;
end
title2 = '';
if dataInfo.title3I == 1
    title2 = dataInfo.title2;
end
title3 = dataInfo.title3;

% Print the mean.
fprintf(fid, '%s,%s,%s,Mean,', title1, title2, title3);
for i = 1:length(wormMean)
    fprintf(fid, '%d,,,', wormMean(i));
end
fprintf(fid, '\n');

% Print the standard deviation.
fprintf(fid, ',,,S.D.,');
for i = 1:length(wormStdDev)
    fprintf(fid, '%d,,,', wormStdDev(i));
end
fprintf(fid, '\n');

% Print the q-value.
fprintf(fid, ',,,Q-Value,,,,');
for i = 2:length(qValue)
    fprintf(fid, '%d,,,', qValue(i));
end
fprintf(fid, '\n');

% Print the power.
fprintf(fid, ',,,Power,,,,');
for i = 2:length(power)
    fprintf(fid, '%d,,,', power(i));
end
fprintf(fid, '\n');

% Print the standard deviation.
fprintf(fid, ',,,Control Mean,,,,');
for i = 2:length(controlMean)
    fprintf(fid, '%d,,,', controlMean(i));
end
fprintf(fid, '\n');

% Print the standard deviation.
fprintf(fid, ',,,Control S.D.,,,,');
for i = 2:length(controlStdDev)
    fprintf(fid, '%d,,,', controlStdDev(i));
end
fprintf(fid, '\n\n');
end
