function wormStats2Matrix(filename, wormFiles, varargin)
%WORMSTATS2MATRIX Construct and save a worms x features matrix.
%
%   WORM2STATSINFO(FILENAME, WORMFILES)
%
%   WORM2STATSINFO(FILENAME, WORMFILES, ISVERBOSE)
%
%   Inputs:
%       filename - the file name for the worm statistics information;
%                  a file containing structures with fields:
%
%                  dataInfo:
%
%                  name     = the feature's name
%                  units    = the feature's units
%                  title1   = the feature's 1st title
%                  title1I  = the feature's 1st title index
%                  title2   = the feature's 2nd title
%                  title2I  = the feature's 2nd title index
%                  title3   = the feature's 3rd title
%                  title3I   = the feature's 3rd title index
%                  field    = the feature's path; a struct where:
%
%                             histogram  = the histogram data path
%                             statistics = the statistics data path
%
%                  index    = the feature's field index
%                  isMain   = is this a main feature?
%                  category = the feature's category, where:
%
%                             m = morphology
%                             s = posture (shape)
%                             l = locomotion
%                             p = path
%
%                  type     = the feature's type, where:
%
%                             s = simple data
%                             m = motion data
%                             d = event summary data
%                             e = event data
%                             i = inter-event data
%
%                  subType  = the feature's sub-type, where:
%
%                             n = none
%                             f = forward motion data
%                             b = backward motion data
%                             p = paused data
%                             t = time data
%                             d = distance data
%                             h = frequency data (Hz)
%
%                  sign     = the feature's sign, where:
%
%                             s = signed data
%                             u = unsigned data
%                             a = the absolute value of the data
%                             p = the positive data
%                             n = the negative data
%
%
%                  worm.info:
%
%                  strain   = the worm strain
%                  genotype = the worm genotyope
%                  gene     = the worm's mutant gene(s)
%                  allele   = the worm's mutant allele(s)
%
%
%                  worm.stats & control.stats (worms x features):
%                  mean    = the mean, per feature
%                  stdDev  = the standard deviation, per feature
%                  samples = the samples, per feature
%                  pNormal = the Shapiro-Wilk p-values, per feature
%                  qNormal.all = the Shapiro-Wilk q-values, per feature,
%                                correcting across all strains
%                  qNormal.strain = the Shapiro-Wilk q-values, per feature,
%                                   correcting per strain
%                  zScore  = the z-scores (for worms only), per feature
%
%
%                  worm.sig & control.stats:
%                  pTValue = the Student's t-test p-value, per feature
%                  qTValue.all = the Student's t-test q-value,
%                                per feature, correcting across all strains
%                  qTValue.strain = the Student's t-test q-value,
%                                   per feature, correcting per strain
%                  pWValue = the Wilcoxon rank-sum p-value, per feature
%                  qWValue.all = the Wilcoxon rank-sum q-value,
%                                per feature, correcting across all strains
%                  qWValue.strain = the Wilcoxon rank-sum q-value,
%                                   per feature, correcting per strain
%
%       wormFiles - the worm statistics information files
%       isVerbose - verbose mode displays the progress;
%                   the default is yes (true)
%
% See also WORM2STATSINFO, WORMSTATSINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we displaying the progress?
isVerbose = false;
if ~isempty(varargin)
    isVerbose = varargin{1};
end

% Delete the file if it already exists.
if exist(filename, 'file')
    delete(filename);
end

% Fix the worm files.
if ~iscell(wormFiles)
    wormFiles =  {wormFiles};
end

% Initialize the feature information.
dataInfo = wormStatsInfo();

% Construct the feature matrix.
worm = [];
control = [];
worm.info.strain = cell(length(wormFiles), 1);
worm.info.genotype = cell(length(wormFiles), 1);
worm.info.gene = cell(length(wormFiles), 1);
worm.info.allele = cell(length(wormFiles), 1);
worm.stats.mean = nan(length(wormFiles), length(dataInfo));
worm.stats.stdDev = nan(length(wormFiles), length(dataInfo));
worm.stats.samples = nan(length(wormFiles), length(dataInfo));
worm.stats.pNormal = nan(length(wormFiles), length(dataInfo));
worm.stats.qNormal.strain = nan(length(wormFiles), length(dataInfo));
worm.stats.qNormal.all = nan(length(wormFiles), length(dataInfo));
worm.stats.zScore = nan(length(wormFiles), length(dataInfo));
control.stats.mean = nan(length(wormFiles), length(dataInfo));
control.stats.stdDev = nan(length(wormFiles), length(dataInfo));
control.stats.samples = nan(length(wormFiles), length(dataInfo));
control.stats.pNormal = nan(length(wormFiles), length(dataInfo));
control.stats.qNormal.strain = nan(length(wormFiles), length(dataInfo));
control.stats.qNormal.all = nan(length(wormFiles), length(dataInfo));
worm.sig.pTValue = nan(length(wormFiles), length(dataInfo));
worm.sig.pWValue = nan(length(wormFiles), length(dataInfo));
worm.sig.qTValue.strain = nan(length(wormFiles), length(dataInfo));
worm.sig.qTValue.all = nan(length(wormFiles), length(dataInfo));
worm.sig.qWValue.strain = nan(length(wormFiles), length(dataInfo));
worm.sig.qWValue.all = nan(length(wormFiles), length(dataInfo));
%worm.sig.power = nan(length(wormFiles), length(dataInfo));
for i = 1:length(wormFiles)
    
    if isVerbose
        disp(['Adding ' num2str(i) '/' num2str(length(wormFiles)) ' "' ...
            wormFiles{i} '" ...']);
    end
    
    % Load the data.
    data = load(wormFiles{i}, 'wormInfo', 'wormData', 'controlData', ...
        'significance');
    
    % Label the worm.
    worm.info.strain{i} = worm2StrainLabel(data.wormInfo);
    worm.info.genotype{i} = worm2GenotypeLabel(data.wormInfo);
    worm.info.gene{i} = worm2GeneLabel(data.wormInfo);
    worm.info.allele{i} = worm2AlleleLabel(data.wormInfo);
    if ~isempty([data.wormData.zScore])
        worm.stats.zScore(i,:) = [data.wormData.zScore];
    end
    
    % Store the worm feature statistics.
    worm.stats.mean(i,:) = [data.wormData.mean];
    worm.stats.stdDev(i,:) = [data.wormData.stdDev];
    worm.stats.samples(i,:) = [data.wormData.samples];
    worm.stats.pNormal(i,:) = [data.wormData.pNormal];
    worm.stats.qNormal.strain(i,:) = [data.wormData.qNormal];
    
    % Store the control feature statistics.
    if isfield(data, 'controlData')
        control.stats.mean(i,:) = [data.controlData.mean];
        control.stats.stdDev(i,:) = [data.controlData.stdDev];
        control.stats.samples(i,:) = [data.controlData.samples];
        control.stats.pNormal(i,:) = [data.controlData.pNormal];

        % Compute the FDR for the strain's feature normality p-values.
        pNormal = [worm.stats.pNormal(i,:); control.stats.pNormal(i,:)];
        qNormal = nan(size(pNormal));
        qNormal(~isnan(pNormal)) = mafdr(pNormal(~isnan(pNormal)));
        worm.stats.qNormal.strain(i,:) = qNormal(1,:);
        control.stats.qNormal.strain(i,:) = qNormal(2,:);
    end
    
    % Store the worm feature significance.
    if isfield(data, 'significance')
        worm.sig.pTValue(i,:) = [data.significance.features.pTValue];
        worm.sig.pWValue(i,:) = [data.significance.features.pWValue];
        worm.sig.qTValue.strain(i,:) = [data.significance.features.qTValue];
        worm.sig.qWValue.strain(i,:) = [data.significance.features.qWValue];
%         worm.sig.power(i,:) = [data.significance.features.power];
    end
end

% Compute the FDR for all feature normality p-values.
pNormal = [worm.stats.pNormal; control.stats.pNormal];
qNormal = nan(size(pNormal));
qNormal(~isnan(pNormal)) = mafdr(pNormal(~isnan(pNormal)));
worm.stats.qNormal.all = qNormal(1:size(worm.stats.pNormal, 1),:);
control.stats.qNormal.all = qNormal((size(worm.stats.pNormal, 1) + 1):end,:);

% Compute the FDR for all feature significance p-values.
worm.sig.qTValue.all = nan(size(worm.sig.pTValue));
worm.sig.qTValue.all(~isnan(worm.sig.pTValue)) = ...
    mafdr(worm.sig.pTValue(~isnan(worm.sig.pTValue)));
worm.sig.qWValue.all = nan(size(worm.sig.pWValue));
worm.sig.qWValue.all(~isnan(worm.sig.pWValue)) = ...
    mafdr(worm.sig.pWValue(~isnan(worm.sig.pWValue)));

% Save the features matrix.
save(filename, 'dataInfo', 'worm', 'control', '-v7.3');
end
