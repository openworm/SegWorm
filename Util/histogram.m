function histData = histogram(data, varargin)
%HISTOGRAM Compute the data's histogram.
%
%   HISTDATA = HISTOGRAM(DATA)
%
%   HISTDATA = HISTOGRAM(DATA, RESOLUTIONS)
%
%   HISTDATA = HISTOGRAM(DATA, RESOLUTIONS, ISZEROBIN)
%
%   HISTDATA = HISTOGRAM(DATA, RESOLUTIONS, ISZEROBIN, ISSIGNED)
%
%   HISTDATA = HISTOGRAM(DATA, RESOLUTIONS, ISZEROBIN, ISSIGNED, VERBOSE)
%
%   Inputs:
%       data       - the data for the histogram(s) (a cell array of
%                    observed sets)
%       resolution - the data resolution;
%                    if empty, the resolution is estimated from the square
%                    root of the data's length (a very popular method)
%       isZeroBin  - is there a bin center at 0?
%                    if empty, data with values greater and less than 0 is
%                    centered at 0
%       isSigned   - is the data signed (+/-)?
%                    if empty, the data is tested to see whether its signed
%       verbose    - verbose mode shows the results in a figure
%
%   Outputs:
%       histData - the histogram(s) data. A struct with fields:
%                  Note: the absolute, positive, and negative value
%                  statistics are only available when the data is signed
%                  (see wormDisplayInfo).
%
%                  PDF        = the PDF (probability density of each bin)
%                  bins       = the center of each bin
%                  resolution = the data resolution
%                  isZeroBin  = is there a bin center at 0
%                  isSigned   = is the data signed (+/-)?
%                  sets       = a struct with fields:
%                     samples    = the number of set samples
%                     mean.all   = the mean of the sets
%                     stdDev.all = the standard deviation of the sets
%                     mean.abs   = the mean of the set magnitudes
%                     stdDev.abs = the deviation of the set magnitudes
%                     mean.pos   = the mean of the positive set values
%                     stdDev.pos = the deviation of the positive set values
%                     mean.neg   = the mean of the negative set values
%                     stdDev.neg = the deviation of the negative set values
%                  data       = a struct with fields:
%                     counts     = the count per set per bin (sets x bins)
%                     samples    = the number of data samples per set
%                     mean.all   = the mean of the data per set
%                     stdDev.all = the standard deviation the data per set
%                     mean.abs   = the mean of the data magnitudes per set
%                     stdDev.abs = the deviation of the data magnitudes per set
%                     mean.pos   = the mean of the positive data per set
%                     stdDev.pos = the deviation of the positive data per set
%                     mean.neg   = the mean of the negative data per set
%                     stdDev.neg = the deviation of the negative data per set
%                  allData    = a struct with fields:
%                     counts     = the count per bin
%                     samples    = the total number of all data samples
%                     mean.all   = the mean of all the data
%                     stdDev.all = the standard deviation of all the data
%                     mean.abs   = the mean of all the data magnitudes
%                     stdDev.abs = the deviation of all the data magnitudes
%                     mean.pos   = the mean of all the positive data
%                     stdDev.pos = the deviation of all the positive data
%                     mean.neg   = the mean of all the negative data
%                     stdDev.neg = the deviation of all the negative data
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Organize the data.
if ~iscell(data)
    data = {data};
end

% Determine the data resolution.
resolution = [];
if ~isempty(varargin)
    resolution = varargin{1};
end

% Is there a bin center at 0?
isZeroBin = [];
if length(varargin) > 1
    isZeroBin = varargin{2};
end

% Is the data signed (+/-)?
isSigned = [];
if length(varargin) > 2
    isSigned = varargin{3};
end

% Are we displaying the results?
verbose = false;
if length(varargin) > 3
    verbose = varargin{4};
end

% Combine the data into a single array of observations.
if size(data, 1) ~= size(data{1}, 1) && size(data, 2) ~= size(data{1}, 2)
    data = data';
end
allData = cell2mat(data);
allData = allData(:);

% Remove empty data.
samples = cellfun(@(x) sum(~isnan(x)), data);
keepI = find(samples > 0);
if length(data) ~= length(keepI)
    data = data(keepI);
end

% Remove infinite data measurements.
for i = 1:length(data)
    data{i}(data{i} == -inf) = NaN;
    data{i}(data{i} == inf) = NaN;
end

% Is there any data?
if isempty(data)
    warning('histogram:NoData', 'There is no data to bin');
    histData = nanHistogram(isSigned);
    return;
end
empty = cellfun(@(x) isempty(x) || all(isnan(x)), data);
if all(empty)
    warning('histogram:NoData', 'There is no data to bin');
    histData = nanHistogram(isSigned, length(empty));
    return;
end

% Compute the data range.
minDataLength = min(cellfun('length', data));
minData = min(cellfun(@min, data));
maxData = max(cellfun(@max, data));

% Compute the data resolution.
if isempty(resolution)
    resolution = (maxData - minData) / sqrt(minDataLength);
end

% Compute the bin center.
if isempty(isZeroBin)
    isZeroBin = sign(minData) ~= sign(maxData);
end

% Compute the data sign.
if isempty(isSigned)
    isSigned = any(allData < 0);
end

% Compute the padding.
if minData < 0
    minPad = resolution - abs(rem(minData, resolution));
else
    minPad = abs(rem(minData, resolution));
end
if maxData < 0
    maxPad = abs(rem(maxData, resolution));
else
    maxPad = resolution - abs(rem(maxData, resolution));
end

% Translate the bins by half the resolution to create a zero bin.
% Note: we compute just enough padding to capture the data.
halfResolution = resolution / 2;
if isZeroBin
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
minEdge = minData - minPad;
maxEdge = maxData + maxPad;

% Compute the bins and their edges.
% Note: histc fills all bins with edges(k) <= data < edges(k + 1).
% The last bin is filled with data == edges(end).
% Therefore, we keep the last bin empty and throw it away to preserve
% equal bin sizes. For this reason the bin centers are spaced for
% their final composition (what they will look like after tossing away
% the empty last bin).
numBins = round((maxEdge - minEdge) / resolution);
bins = linspace(minEdge + halfResolution, maxEdge - halfResolution, ...
    numBins);
edges = bins - halfResolution;
edges(end + 1) = edges(end) + resolution;

% Fix the zero bin.
% Note: IEEE floating point issues may shift us just off zero.
if isZeroBin
    [zeroBin, zeroI] = min(abs(bins));
    if zeroBin < halfResolution / 2
        bins(zeroI) = 0;
    end
end
    
% Compute the histogram counts for all the data.
counts(1,:) = histc(allData, edges);
if length(edges) > 1
    
    % Add the very last bin.
    if counts(1,end) > 0
        bins(end + 1) = bins(end) + resolution;
        
    % Strip off the empty last bin.
    else
        counts(end) = [];
    end
    
    % Strip off the empty first bin.
    if counts(1,1) == 0
        bins(1) = [];
        counts(1) = [];
    end
end

% Compute the counts for the data set.
allCounts(1,:) = counts;
if length(data) == 1
    pdfs(1,:) = counts ./ sum(counts);
    
% Compute the normalized histogram for the data sets.
else
    counts = zeros(length(data), length(edges));
    pdfs = zeros(length(data), length(edges));
    for i = 1:length(data)
        if ~empty(i)
            counts(i,:) = histc(data{i}, edges);
            pdfs(i,:) = counts(i,:) ./ sum(counts(i,:));
        end
    end
    pdfs = mean(pdfs, 1);
    
    % Strip off the empty bin.
    if length(edges) > 1
        
        % Add a bin (this should never happen).
        if any(counts(:,end) > 0)
            bins(end + 1) = bins(end) + resolution;
            warning('histogram:LastBinNotEmpty', ...
                ['The last bin in the histogram is not empty like it ' ...
                'should be. Please contact the programmer)']);
            
        % Strip off the empty bin.
        else
            counts(:,end) = [];
            pdfs(:,end) = [];
        end
    end
end

% Compute the means of the data sets.
means = cellfun(@nanmean, data);
stdDevs = cellfun(@nanstd, data);
if isSigned
    
    % Compute the absolute value statisitics.
    absData = cellfun(@(x) abs(x), data, 'UniformOutput', false);
    absMeans = cellfun(@(x) nanmean(x), absData);
    absStdDevs = cellfun(@(x) nanstd(x), absData);
    
    % Compute the positive value statisitics.
    posData = cellfun(@(x) x(x > 0), data, 'UniformOutput', false);
    posMeans = cellfun(@(x) nanmean(x), posData);
    posStdDevs = cellfun(@(x) nanstd(x), posData);
    
    % Compute the negative value statisitics.
    negData = cellfun(@(x) x(x < 0), data, 'UniformOutput', false);
    negMeans = cellfun(@(x) nanmean(x), negData);
    negStdDevs = cellfun(@(x) nanstd(x), negData);
end

% Organize the histogram set data.
histData.sets.samples = length(data);
histData.sets.mean.all = nanmean(means);
histData.sets.stdDev.all = nanstd(means);
if isSigned
    
    % Compute the absolute value statisitics.
    histData.sets.mean.abs = nanmean(absMeans);
    histData.sets.stdDev.abs = nanstd(absMeans);
    
    % Compute the positive value statisitics.
    histData.sets.mean.pos = nanmean(posMeans);
    histData.sets.stdDev.pos = nanstd(posMeans);
    
    % Compute the negative value statisitics.
    histData.sets.mean.neg = nanmean(negMeans);
    histData.sets.stdDev.neg = nanstd(negMeans);
end

% Organize the histogram data sets.
histData.data.counts = counts;
histData.data.samples(:,1) = samples;
histData.data.mean.all(:,1) = means;
histData.data.stdDev.all(:,1) = stdDevs;
if isSigned
    
    % Compute the absolute value statisitics.
    histData.data.mean.abs(:,1) = absMeans;
    histData.data.stdDev.abs(:,1) = absStdDevs;
    
    % Compute the positive value statisitics.
    histData.data.mean.pos(:,1) = posMeans;
    histData.data.stdDev.pos(:,1) = posStdDevs;
    
    % Compute the negative value statisitics.
    histData.data.mean.neg(:,1) = negMeans;
    histData.data.stdDev.neg(:,1) = negStdDevs;
end

% Organize the histogram total data.
histData.allData.counts = allCounts;
histData.allData.samples = sum(samples);
histData.allData.mean.all = nanmean(allData);
histData.allData.stdDev.all = nanstd(allData);
if isSigned
    
    % Compute the absolute value statisitics.
    absAllData = abs(allData);
    histData.allData.mean.abs = nanmean(absAllData);
    histData.allData.stdDev.abs = nanstd(absAllData);
    
    % Compute the positive value statisitics.
    posAllData = allData(allData > 0);
    histData.allData.mean.pos = nanmean(posAllData);
    histData.allData.stdDev.pos = nanstd(posAllData);
    
    % Compute the negative value statisitics.
    negAllData = allData(allData < 0);
    histData.allData.mean.neg = nanmean(negAllData);
    histData.allData.stdDev.neg = nanstd(negAllData);
end

% Organize the histogram.
histData.PDF = pdfs;
histData.bins = bins;
histData.resolution = resolution;
histData.isZeroBin = isZeroBin;
histData.isSigned = isSigned;

% Show the results.
if verbose
    
    % Create a figure.
    h = figure;
    set(h, 'units', 'normalized', 'position', [0 0 1 1]);
    hold on;
    
    % Plot the histogram.
    if length(data) > 1
        subplot(1, 2, 1);
    end
    histColor = [0 0 0];
    statColor = [1 0 0];
    plotHistogram(histData, 'Histogram', 'Value', 'Data', '', ...
        histColor, statColor, 2);
    
    % Plot the contributing histograms.
    if length(data) > 1
        
        % Construct the contributing histograms.
        histDatas(1:length(data)) = histData;
        for i = 1:length(data)
            
            % Set the statistics.
            histDatas(i).sets.samples = 1;
            histDatas(i).sets.mean = histData.data.mean(i);
            histDatas(i).sets.stdDev = 0;
            histDatas(i).data.counts = histData.data.counts(i,:);
            histDatas(i).data.samples = histData.data.samples(i);
            histDatas(i).data.mean = histData.data.mean(i);
            histDatas(i).data.stdDev = histData.data.stdDev(i);
            histDatas(i).allData.samples = histData.data.samples(i);
            histDatas(i).allData.mean = histData.data.mean(i);
            histDatas(i).allData.stdDev = histData.data.stdDev(i);
            
            % Set the PDF.
            counts = histDatas(i).data.counts;
            histDatas(i).PDF = counts ./ sum(counts);
        end
        
        % Plot the contributing histograms.
        subplot(1, 2, 2);
        dataNames(1:length(data)) = {'Data'};
        colors = lines(length(data));
        plotHistogram(histDatas, 'Histogram', 'Value', dataNames, ...
            colors, colors);
    end
end
end
