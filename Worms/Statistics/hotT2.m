function [pAll pMean] = hotT2(data1, data2)
%HOTT2 Use Hoteling T2 (unpaired & unequal variance) to compute p-values
%      comparing 2 normally distributed data sets.
%
%   [PALL PMEAN] = HOTT2(DATA1, DATA2)
%
%   Inputs:
%       data1 - group 1's data (observations x variables)
%       data2 - group 2's data (observations x variables)
%
%   Outputs:
%       pAll  - the p-value using the PCA of the pooled data
%       pMean - the p-value using the PCA of the 2 group means
%
% Note: The technique originates from the following paper,
% "A multivariate approach for integrating genome-wide expression data and
% biological knowledge"
% Kong SW, Pu WT, Park PJ.
% Bioinformatics, 22:2373-80, 2006.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Get the number of samples for each data set.
n1 = size(data1, 1);
n2 = size(data2, 1);

% Do we have enough observations?
numDims = min(n1, n2) - 2;
if numDims < 1
    error('hotT2:InsufficientObservations', ...
        'There are insufficient observations to test the data');
end

% Remove sparsely sampled variables.
useI = ~any(isnan(data1)) & ~any(isnan(data2));
data1 = data1(:, useI);
data2 = data2(:, useI);

% Compute the PCA.
[~, score_all, ~, ~] = princomp(zscore([data1; data2]));
[pc_mean, ~, ~, ~] = princomp(zscore([mean(data1); mean(data2)]));

% Reduce the dimensionality.
data1_all = score_all(1:n1,1:numDims);
data2_all = score_all((n1 + 1):n2,1:numDims);
data1_mean = data1 * pc_mean(:,1:numDims);
data2_mean = data2 * pc_mean(:,1:numDims);

% Compute the covariance.
S_all = cov(data1_all) / n1 + cov(data2_all) / n2;
S_mean = cov(data1_mean) / n1 + cov(data2_mean) / n2;

% Compute the T2.
dM_all = mean(data1_all) - mean(data2_all);
T2_all = (dM_all / S_all) * dM_all';
dM_mean = mean(data1_mean) - mean(data2_mean);
T2_mean = (dM_mean / S_mean) * dM_mean';

% Convert the T2 to an F statistic.
F_all = T2_all * ((n1 + n2 - numDims - 1) / (numDims * (n1 + n2 - 2)));
F_mean = T2_mean * ((n1 + n2 - numDims - 1) / (numDims * (n1 + n2 - 2)));

% Compute the p-values.
pAll = 1 - fcdf(F_all, numDims, n1 + n2 - numDims - 1);
pMean = 1 - fcdf(F_mean, numDims, n1 + n2 - numDims - 1);
end