function wormStatsMatrix2CSV(filename, wormFile, varargin)
%WORMSTATSMATRIX2CSV Print a worms x features CSV matrix.
%
%   WORMSTATSMATRIX2CSV(FILENAME, WORMFILE)
%
%   WORMSTATSMATRIX2CSV(FILENAME, WORMFILE, ISTRANSPOSE, ISZSCORE, ISNORM,
%                       MINPCA, MAXQVALUE, MINPOWER, IMPUTEFACTOR,
%                       ISHOWMAIN, SHOWCATEGORY, SHOWTYPE, SHOWSIGN, SHOWI,
%                       DELIMITER, ISVERBOSE)
%
%   Inputs:
%       filename - the file name for the worms x features CSV matrix
%       wormFile - the worms x features matrix file;
%                  a file containing structures with fields:
%1
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
%
%       isTranspose  - are we transposing the file to features x worms?
%       isZScore     - are we using the normalized feature z-scores?
%                      if not, we use the feature means;
%                      the default is yes (true)
%       isNorm       - are we normalizing the features to z-scores?
%                      (using the population mean and variance)?
%       minPCA       - the minimum threshold for PCA covariance to use;
%                      the default is not to use PCA ([])
%
%                      [] = do not use PCA to transform the features
%                      1  = use all eigenfeatures
%
%       maxQValue    - the maximum q-value to use (insignificant features
%                      are not used); the default is all ([])
%       imputeFactor - unmeasurable data is imputed to the maximum and
%                      minimum of the worm population, respectively, when
%                      the worm or the control are NaN (if both are NaN,
%                      the data is imputed to 0); the imputation factor is
%                      a scale for multiplying the imputed value (e.g., use
%                      0 to zero the imputed data)
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
%       delimiter    - the delimiting string (e.g., ',' or '\t')
%                      the default is a tab ('\t')
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

% Are we transposing the file to features x worms?
isTranspose = true;
if ~isempty(varargin)
    isTranspose = varargin{1};
end

% Are we using the normalized feature z-scores?
isZScore = true;
if length(varargin) > 1
    isZScore = varargin{2};
end

% Are we normalizing the feature population to z-scores?
isNorm = true;
if length(varargin) > 2
    isNorm = varargin{3};
end

% Determine the minimum threshold for PCA covariance to use.
minPCA = [];
if length(varargin) > 3
    minPCA = varargin{4};
end

% Determine the maximum q-value to use.
maxQValue = [];
if length(varargin) > 4
    maxQValue = varargin{5};
end

% % Determine the minimum power to use.
% minPower = [];
% if length(varargin) > 5
%     minPower = varargin{6};
% end

% Determine the imputation factor.
% Note: unmeasurable data is imputed to the maximum and minimum of the worm
% population, respectively, when the worm or the control are NaN (if both
% are NaN, the data is imputed to 0). The imputation factor is a scale for
% multiplying the imputed value (e.g., use 0 to zero the imputed data).
imputeFactor = 2;
if length(varargin) > 5
    imputeFactor = varargin{6};
end

% Are we showing the main features?
isShowMain = true;
if length(varargin) > 6
    isShowMain = varargin{7};
end

% Which feature categories should we show?
showCategory = [];
if length(varargin) > 7
    showCategory = varargin{8};
end

% Which feature types should we show?
showType = [];
if length(varargin) > 8
    showType = varargin{9};
end

% Which feature signs should we show?
showSign = [];
if length(varargin) > 9
    showSign = varargin{10};
end

% Determine the indices of the features to show.
showI = [];
if length(varargin) > 10
    showI = varargin{11};
end

% Determine the delimiting string.
delimiter = '\t';
if length(varargin) > 11
    delimiter = varargin{12};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 12
    isVerbose = varargin{3};
end

% Load the matrix.
data = load(wormFile);

% Initialize the feature information.
dataInfo = wormStatsInfo();

% Determine the worm labels.
wormLabels = data.worm.info.genotype;

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
crawlI = cellfun(@(x) ~isempty(strfind(x, 'crawl')), lowerLabels);
isShow(pausedI & crawlI) = false;
featureLabels = featureLabels(isShow);

% Find the wild-type control values.
%controlStr = 'N2: C. elegans Wild Isolate, Schafer Lab N2 (Bristol, UK)';
controlStr = 'Schafer Lab N2 (Bristol, UK)';
maleStr = 'Male';
controlI = cellfun(@(x) strcmp(x, controlStr), wormLabels);
controlI = find(controlI);
if length(controlI) ~= 1
    warning('plotWormStatsMatrix:NoControl', ...
        'Cannot find the wild-type control');
end
maleI = find(cellfun(@(x) ~isempty(strfind(x, maleStr)), wormLabels));
allControlI = find(cellfun(@(x) ~isempty(strfind(x, controlStr)), wormLabels));
hourDayMonthControlI = setdiff(allControlI, [maleI controlI]);

% Use the normalized feature z-scores.
isImputeNeg = [];
isImputePos = [];
if isZScore
    worms = data.worm.stats.zScore(:,isShow);
    
%     % Find unmeasurable data.
%     finiteWorms = worms;
%     finiteWorms(abs(finiteWorms) == inf) = NaN;
% 
%     % Fix unmeasurable data.
%     maxFeature = nanmax(finiteWorms);
%     minFeature = nanmin(finiteWorms);
%     [i, j] = find(worms == inf);
%     worms(sub2ind(size(worms), i, j)) = maxFeature(j) * imputeFactor;
%     [i, j] = find(worms == -inf);
%     worms(sub2ind(size(worms), i, j)) = minFeature(j) * imputeFactor;
    
    % Set the control to zero.
    worms(controlI,:) = 0;
    
    % Find the imputed values.
    isImputeNeg = worms == -inf;
    isImputePos = worms == inf;
    worms(isImputeNeg | isImputePos) = NaN;

% Use the feature means.
else
    worms = data.worm.stats.mean(:,isShow);
end

    %worms(hourDayMonthControlI, :) = [];
    isLabel = true(size(wormLabels));
    %isLabel(hourDayMonthControlI) = false;
    wormLabels = wormLabels(isLabel);
% Remove statistically insignificant data.
if ~isempty(maxQValue)

    sigValues = data.worm.sig.qWValue.all(isLabel, isShow);
    %worms(sigValues > maxQValue) = 0;
    
    sigs = zeros(size(sigValues));
    sigs(sigValues <= 0.05) = 1;
    sigs(sigValues <= 0.01) = 2;
    sigs(sigValues <= 0.001) = 3;
    sigs(sigValues <= 0.0001) = 4;
    sigs = sigs .* sign(worms);
    sigs(isnan(sigs)) = 0;
    [vars, varI] = sort(var(sigs), 'descend');
    keepI = varI(1:498);
    worms = worms(:, keepI);
    featureLabels = featureLabels(keepI);
    isImputeNeg = isImputeNeg(keepI);
    isImputePos = isImputePos(keepI);
    
    %489
    %525
    
    % Use MRMR to select features.
%     numMRMR = 50;
%     sigValues = data.worm.sig.qWValue.all(:, isShow);
%     worms(isnan(worms)) = 0;
%     worms(sigValues > maxQValue) = 0;
%     mrmrFeatures = mRMR_feature_select(worms, 1:size(worms,1), numMRMR);
%     worms = worms(:, mrmrFeatures);
%     featureLabels = featureLabels(mrmrFeatures);
%     isImputeNeg = isImputeNeg(mrmrFeatures);
%     isImputePos = isImputePos(mrmrFeatures);
    
%     signs = sign(worms);
%     worms = log(1 ./ data.worm.sig.qWValue.all(:, isShow));
%     worms = worms .* signs;
%     isNorm = false;
%     worms(isnan(worms)) = 0;
%     if isZScore
%         sigValues = data.worm.sig.qWValue.all(:, isShow);
%         worms(sigValues > maxQValue) = 0;
%     else
%         controlValues = repmat(data.worm.stats.mean(controlI, isShow), ...
%             size(data.worm.sig.qWValue.all, 1), 1);
%         controlValuesI = data.worm.sig.qWValue.all > maxQValue;
%         worms(controlValuesI) = controlValues(controlValuesI);
%     end
end

% % Fix unmeasurable data.
% maxFeature = nanmax(worms);
% minFeature = nanmin(worms);
% nanWorms = isnan(worms);
% nanControls = repmat(nanWorms(controlI,:), size(nanWorms, 1), 1);
% nanWorms(controlI,:) = false;
% nanControls(controlI,:) = false;
% [i, j] = find(nanWorms & ~nanControls);
% worms(sub2ind(size(worms), i, j)) = maxFeature(j) * imputeFactor;
% [i, j] = find(~nanWorms & nanControls);
% worms(sub2ind(size(worms), i, j)) = minFeature(j) * imputeFactor;
% worms(isnan(worms)) = 0;
%     
% % Set insignificant features to their wild-type value.
% controlValue = worms(controlI,:);
% if ~isempty(maxQValue)
%     
%     % Set insignificant features to zero.
%     if isZScore
%         worms(data.worm.sig.qWValue.all(:,isShow) > maxQValue) = 0;
%         
%     % Set insignificant features to their wild-type value.
%     else
%         for i = 1:size(worms, 1)
%             insignificant = data.worm.sig.qWValue.all(i,isShow) > maxQValue;
%             worms(i,insignificant) = controlValue(insignificant);
%         end
%     end
% end

% % Set non-powerful features to their wild-type value.
% if ~isempty(minPower)
%     
%     % Set non-powerful features to zero.
%     if isZscore
%         worms(data.worm.stats.power(:,isShow) < minPower) = 0;
%         
%     % Set non-powerful features to their wild-type value.
%     else
%         for i = 1:size(worms, 1)
%             insignificant = data.worm.stats.power(i,isShow) < minPower;
%             worms(i,insignificant) = controlValue(insignificant);
%         end
%     end
% end

% Normalize the feature matrix.
if isNorm
    dataMean = nanmean(worms);
    dataStdDev = nanstd(worms);
    for i = 1:size(worms, 1)
        worms(i,:) = (worms(i,:) - dataMean) ./ dataStdDev;
    end
    worms(isnan(worms)) = 0;
end

% Impute the missing values.
finiteWorms = worms;
finiteWorms(isImputeNeg | isImputePos) = NaN;
maxFeature = nanmax(finiteWorms);
minFeature = nanmin(finiteWorms);
[i, j] = find(isImputeNeg);
worms(sub2ind(size(worms), i, j)) = minFeature(j) * imputeFactor;
[i, j] = find(isImputePos);
worms(sub2ind(size(worms), i, j)) = maxFeature(j) * imputeFactor;

% Take the PCA of the features and transform them to eigenfeatures.
if ~isempty(minPCA)
    
    % Compute the principal components.
    [pc, score, latent, t2] = princomp(worms);
    
    % Compute the number of components necessary.
    compVar = cumsum(latent) ./ sum(latent);
    compNum = find(compVar >= minPCA, 1);
    
    % Sort the coefficients by their loading.
    pcSign = sign(pc);
    [pcWeight, pcFeature] = sort(abs(pc), 2, 'descend');
    
    % Transform the features to eigenfeatures.
    eigenLabel = 'eigenfeature ';
    featureLabels = cell(compNum, 1);
    for i = 1:length(featureLabels)
        featureLabels{i} = [eigenLabel num2str(i)];
    end
    worms = score(:,1:compNum);
end

% Transpose the plot to features x worms.
if isTranspose
    worms = worms';
    rowLabels = featureLabels;
    colLabels = wormLabels;
else
    rowLabels = wormLabels;
    colLabels = featureLabels;
end

% Open the file.
fid = fopen(filename, 'w');

% Print the column labels.
strFormat = ['"%s"' delimiter];
fprintf(fid, delimiter);
for i = 1:length(colLabels)
    fprintf(fid, strFormat, colLabels{i});
end
fprintf(fid, '\n');

% Print the row labels, values, and progress.
numFormat = ['%d' delimiter];
if isVerbose
    for i = 1:length(rowLabels)
        disp(['Printing "' rowLabels{i} '" ...']);
        fprintf(fid, strFormat, rowLabels{i});
        for j = 1:size(worms, 2)
            fprintf(fid, numFormat, worms(i,j));
        end
        fprintf(fid, '\n');
    end
    
% Print the row labels and values.
else
    for i = 1:length(rowLabels)
        fprintf(fid, strFormat, rowLabels{i});
        for j = 1:size(worms, 2)
            fprintf(fid, numFormat, worms(i,j));
        end
        fprintf(fid, '\n');
    end
end
end
