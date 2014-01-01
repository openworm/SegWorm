function isUsed = filterWormHist(hist, filt)
%FILTERWORMHIST Filter worm features to meet specific criteria.
%
%   ISUSED = FILTERWORMHIST(HIST, FILT)
%
%   Inputs:
%       hist - the worm histogram
%       filt - the filtering criteria; a structure with any of the fields:
%
%              featuresI = the feature indices (see WORMDATAINFO)
%              minThr    = the minimum feature value (optional)
%              maxThr    = the maximum feature value (optional)
%              indices   = the sub indices for the features (optional)
%              subFields = the subFields for the features (optional)
%
%   Outputs:
%       isUsed - for each worm, did it meet the criteria?
%
% See also WORMDATAINFO, WORM2HISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Check the filter.
isUsed = true(length(hist.morphology.length.histogram.data.samples), 1);
if isempty(filt)
    return;
end

% Unpack the features.
featuresI = filt.featuresI;
if isempty(featuresI)
    return;
end

% Unpack the thresholds.
minThrs = [];
maxThrs = [];
if isfield(filt, 'minThrs')
    minThrs = filt.minThrs;
end
if isfield(filt, 'maxThrs')
    maxThrs = filt.maxThrs;
end

% Check the the thresholds.
if isempty(minThrs) && isempty(maxThrs)
    return;
elseif isempty(minThrs) 
    minThrs = nan(length(featuresI), 1);
elseif isempty(maxThrs) 
    maxThrs = nan(length(featuresI), 1);
end

% Unpack the indices and subFields
if isfield(filt, 'indices')
    indices = filt.indices;
else
    indices = ones(length(featuresI), 1);
end
if isfield(filt, 'subFields')
    subFields = filt.subFields;
else
    subFields = cell(length(featuresI), 1);
end

% Filter the features.
info = wormDataInfo();
for i = 1:length(featuresI)
    
    % Get the data.
    feature = info(featuresI(i));
    data = getStructField(hist, feature.field);
    data = data(indices(i));
    if ~isempty(subFields{i})
        data = getStruct(data, subFields{i});
    end
    data = data.histogram;
    
    % Filter the data.
    for j = 1:length(isUsed)
        values = data.bins(data.data.counts(j,:) > 0);
        if ~isempty(values) && ...
                (min(values) < minThrs(i) || max(values) > maxThrs(i))
            isUsed(j) = false;
        end
    end
end
end
