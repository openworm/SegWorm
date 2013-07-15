function histogram = downSampleHistogram(histogram, varargin)
%DOWNSAMPLEHISTOGRAM Downsample a histogram(s).
%
%   HISTOGRAM = DOWNSAMPLEHISTOGRAM(HISTOGRAM)
%
%   HISTOGRAM = DOWNSAMPLEHISTOGRAM(HISTOGRAM, SCALE)
%
%   Input:
%       histogram - the histogram(s) to downsample
%       scale     - the scale to use for downsampling;
%                   if empty/NaN/0, the scale is guessed by using the
%                   square root of the smallest, non-zero data sample size
%                   as the number of bins to aim for
%
%   Output:
%       histogram - the downsampled histogram(s)
%
% See also HISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Is the histogram empty?
if isempty(histogram)
    return;
end

% Determine the scale for downsampling.
scale = [];
if ~isempty(varargin)
    scale = varargin{1};
    
    % Compute the scale.
    if isnan(scale) || scale == 0
        scale = [];
    end
end

% Check the scale.
if scale < 1
    error('downSampleHistogram:Scale', ...
        'The scale must be a positive integer')
end

% Are any of the histograms empty?
empty = arrayfun(@(x) isempty(x.bins) || isnan(x.bins(1)), histogram);
if all(empty)
    return;
end

% Use the smallest data sets to compute the downsampling.
samples = nan(length(histogram),1);
numBins = nan(length(histogram),1);
resolutions = nan(length(histogram),1);
isZeroBins = false(length(histogram),1);
for i = 1:length(histogram)
    if ~empty(i) && histogram(i).allData.samples > 0
        samples(i) = histogram(i).allData.samples;
        numBins(i) = length(histogram(i).bins);
        resolutions(i) = histogram(i).resolution;
        isZeroBins(i) = histogram(i).isZeroBin;
    end
end
minSamples = min(samples);
maxResolution = max(resolutions);
if isnan(minSamples)
    return;
end

% Compute the histogram scales.
scales = double(maxResolution) ./ double(resolutions);

% Check the histogram(s) compatibility.
isZeroBin = isZeroBins(~empty);
isZeroBins(empty) = isZeroBin(1);
if length(histogram) > 1
    if any(~isequalwithequalnans(scales, floor(scales))) || ...
            any(isZeroBins(1) ~= isZeroBins(2:end))
        warning('downSampleHistogram:UnequalBins', ...
            ['Two or more histograms have inconsistent bins and, ' ...
            'therefore, none can be downsampled']);
        return;
    end
end

% Compute the scale.
numBins = numBins ./ scales;
%minNumBins = min(numBins);
if isempty(scale)
    %scale = min(ceil(double(numBins) ./ sqrt(samples)));
    %scale = ceil(mean(double(numBins) ./ sqrt(samples)));
    scale = max(ceil(double(numBins) ./ sqrt(samples)));
end

% Check the scales.
if scale < 1
    scale = 1;
end
if all(scales * scale <= 1)
    return;
end

% Downsample the histogram(s).
for i = 1:length(histogram)
    if ~empty(i)
        histogram(i) = scaleHistogram(histogram(i), scales(i) * scale);
    end
end
end



%% Scale a histogram.
function data = scaleHistogram(data, scale)

% Can the histogram be scaled down?
if scale <= 1
    return;
end

% Compute the bin range.
bins = data.bins;
minBins = min(bins);
maxBins = max(bins);

% Compute the padding.
resolution = data.resolution * scale;
halfResolution = resolution / 2;
if minBins < 0
    minPad = resolution - abs(rem(minBins, resolution));
else
    minPad = abs(rem(minBins, resolution));
end
if maxBins < 0
    maxPad = abs(rem(maxBins, resolution));
else
    maxPad = resolution - abs(rem(maxBins, resolution));
end

% Translate the bins by half the resolution to create a zero bin.
% Note: we compute just enough padding to capture the data.
if data.isZeroBin
    if minPad > halfResolution
        minPad = minPad - halfResolution;
    else
        minPad = minPad + halfResolution;
    end
    if maxPad > halfResolution
        maxPad = maxPad - halfResolution;
    else
        maxPad = maxPad + halfResolution;
    end
end

% Compute the edge range.
minEdge = minBins - minPad;
maxEdge = maxBins + maxPad;

% Compute the bins and their edges.
numBins = round((maxEdge - minEdge) / resolution);
oldBins = bins;
bins = linspace(minEdge + halfResolution, maxEdge - halfResolution, ...
    numBins);
edges = bins - halfResolution;
edges(end + 1) = edges(end) + resolution;

% Fix the zero bin.
% Note: IEEE floating point issues may shift us just off zero.
if data.isZeroBin
    [zeroBin, zeroI] = min(abs(bins));
    if zeroBin < halfResolution / 2
        bins(zeroI) = 0;
    end
end

% Redistribute the data into the new bins.
PDFs = zeros(1, length(bins));
dataCounts = zeros(size(data.data.counts, 1), length(bins));
allDataCounts = zeros(1, length(bins));
oldPDFs = data.PDF;
oldDataCounts = data.data.counts;
oldAllDataCounts = data.allData.counts;
oldBinsI = 1;
for j = 1:(length(edges) - 1)
    while oldBinsI <= length(oldBins) && ...
            (oldBins(oldBinsI) >= edges(j) && ...
            oldBins(oldBinsI) < edges(j + 1))
        PDFs(j) = PDFs(j) + oldPDFs(oldBinsI);
        dataCounts(:,j) = dataCounts(:,j) + oldDataCounts(:, oldBinsI);
        allDataCounts(j) = allDataCounts(j) + ...
            oldAllDataCounts(oldBinsI);
        oldBinsI = oldBinsI + 1;
    end
end

% Update the data.
data.bins = bins;
data.PDF = PDFs;
data.data.counts = dataCounts;
data.allData.counts = allDataCounts;
data.resolution = resolution;
end
