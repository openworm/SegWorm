function plotWormStatsMatrix(wormFile, varargin)
%PLOTWORMSTATSMATRIX Plot a worms x features matrix.
%
%   PLOTWORMSTATSMATRIX(WORMFILES)
%
%   PLOTWORMSTATSMATRIX(WORMFILES, ISTRANSPOSE, ISZSCORE, ISNORM, MINPCA, 
%                       MINQVALUE, MINPOWER, IMPUTEFACTOR,
%                       ISHOWMAIN, SHOWCATEGORY, SHOWTYPE, SHOWSIGN, SHOWI)
%
%   Inputs:
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
%       isTranspose  - are we transposing the plot to features x worms?
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
%       minPower     - the minimum power to use (insignificant features
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
%
% See also WORM2STATSMATRIX
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we transposing the plot to features x worms?
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

% Determine the minimum q-value to use.
maxQValue = [];
if length(varargin) > 4
    maxQValue = varargin{5};
end

% Determine the minimum power to use.
minPower = [];
if length(varargin) > 5
    minPower = varargin{6};
end

% Determine the imputation factor.
% Note: unmeasurable data is imputed to the maximum and minimum of the worm
% population, respectively, when the worm or the control are NaN (if both
% are NaN, the data is imputed to 0). The imputation factor is a scale for
% multiplying the imputed value (e.g., use 0 to zero the imputed data).
imputeFactor = 2;
if length(varargin) > 6
    imputeFactor = varargin{7};
end

% Are we showing the main features?
isShowMain = true;
if length(varargin) > 7
    isShowMain = varargin{8};
end

% Which feature categories should we show?
showCategory = [];
if length(varargin) > 8
    showCategory = varargin{9};
end

% Which feature types should we show?
showType = [];
if length(varargin) > 9
    showType = varargin{10};
end

% Which feature signs should we show?
showSign = [];
if length(varargin) > 10
    showSign = varargin{11};
end

% Determine the indices of the features to show.
showI = [];
if length(varargin) > 11
    showI = varargin{12};
end

% Load the matrix.
data = load(wormFile);

% Initialize the feature information.
dataInfo = wormStatsInfo();

% Determine the worm labels.
wormLabels = data.worm.genotype;

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
featureLabels = featureLabels(isShow);

% Find the wild-type control values.
%controlStr = 'N2: C. elegans Wild Isolate, Schafer Lab N2 (Bristol, UK)';
controlStr = 'C. elegans Wild Isolate, Schafer Lab N2 (Bristol, UK)';
controlI = cellfun(@(x) strcmp(x, controlStr), wormLabels);
controlI = find(controlI);
if length(controlI) ~= 1
    warning('plotWormStatsMatrix:NoControl', ...
        'Cannot find the wild-type control');
end
allControlI = find(cellfun(@(x) ~isempty(strfind(x, 'N2')), wormLabels));

% Use the normalized feature z-scores.
if isZScore
    worms = data.worm.zScore(:,isShow);
    
    % Find unmeasurable data.
    finiteWorms = worms;
    finiteWorms(abs(finiteWorms) == inf) = NaN;

    % Fix unmeasurable data.
    maxFeature = nanmax(finiteWorms);
    minFeature = nanmin(finiteWorms);
    [i, j] = find(worms == inf);
    worms(sub2ind(size(worms), i, j)) = maxFeature(j) * imputeFactor;
    [i, j] = find(worms == -inf);
    worms(sub2ind(size(worms), i, j)) = minFeature(j) * imputeFactor;
    
    % Set the control to zero.
    worms(controlI,:) = 0;
    
% Use the feature means.
else
    worms = data.worm.mean(:,isShow);
end

% Fix unmeasurable data.
maxFeature = nanmax(worms);
minFeature = nanmin(worms);
nanWorms = isnan(worms);
nanControls = repmat(nanWorms(controlI,:), size(nanWorms, 1), 1);
nanWorms(controlI,:) = false;
nanControls(controlI,:) = false;
[i, j] = find(nanWorms & ~nanControls);
worms(sub2ind(size(worms), i, j)) = maxFeature(j) * imputeFactor;
[i, j] = find(~nanWorms & nanControls);
worms(sub2ind(size(worms), i, j)) = minFeature(j) * imputeFactor;
worms(isnan(worms)) = 0;
    
% Set insignificant features to their wild-type value.
controlValue = worms(controlI,:);
if ~isempty(maxQValue)
    
    % Set insignificant features to zero.
    if isZScore
        worms(data.worm.qValue(:,isShow) > maxQValue) = 0;
        
    % Set insignificant features to their wild-type value.
    else
        for i = 1:size(worms, 1)
            insignificant = data.worm.qValue(i,isShow) > maxQValue;
            worms(i,insignificant) = controlValue(insignificant);
        end
    end
end

% Set non-powerful features to their wild-type value.
if ~isempty(minPower)
    
    % Set non-powerful features to zero.
    if isZscore
        worms(data.worm.power(:,isShow) < minPower) = 0;
        
    % Set non-powerful features to their wild-type value.
    else
        for i = 1:size(worms, 1)
            insignificant = data.worm.power(i,isShow) < minPower;
            worms(i,insignificant) = controlValue(insignificant);
        end
    end
end

% Normalize the feature matrix.
if isNorm
    dataMean = nanmean(worms);
    dataStdDev = nanstd(worms);
    for i = 1:size(worms, 1)
        worms(i,:) = (worms(i,:) - dataMean) ./ dataStdDev;
    end
    worms(isnan(worms)) = 0;
end

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

% Cluster the worms.
linkageType = 'average';
colDistType = 'euclidean';
rowDistType = 'euclidean';
cMap = redbluecmap;
cgo = clustergram(worms, 'Linkage', linkageType, ...
    'RowPDist', rowDistType, 'ColumnPDist', colDistType, ...
    'Standardize', 3, ...
    'Dendrogram', 0, 'Colormap', cMap);
set(cgo, 'RowLabels', rowLabels);
set(cgo, 'ColumnLabels', colLabels);
end
