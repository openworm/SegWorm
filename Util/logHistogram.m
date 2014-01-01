function histogram = logHistogram(histogram, varargin)
%LOGHISTOGRAM Convert a histogram to its base-10 logarithm.
%
%   HISTOGRAM = LOGHISTOGRAM(HISTOGRAM)
%
%   HISTOGRAM = LOGHISTOGRAM(HISTOGRAM, LOGMODE, ISEQUALBINS)
%
%   Input:
%       histogram   - the histogram(s) to convert
%       logMode     - the logarithmic mode:
%                     
%                     1 = convert the PDF to log scale (default)
%                     2 = convert the values to log scale
%                     3 = convert both the PDF and values to log scale
%
%       isEqualBins - are we using equal bin widths?
%                     the default is yes (true)
%
%   Output:
%       histogram - the base-10 logarithm of the histogram(s)
%
% See also HISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Which log mode are we using?
% 1 = convert the PDF to log scale (default)
% 2 = convert the values to log scale
% 3 = convert both the PDF and values to log scale
logMode = 1;
if ~isempty(varargin)
    logMode = varargin{1};
end

% Are we using equal bin widths?
isEqualBins = false;
if length(varargin) > 1
    isEqualBins = varargin{2};
end

% Convert the histogram(s).
for i = 1:length(histogram)
    
    % Is there any data?
    data = histogram(i);
    bins = data.bins;
    if isempty(data) || isempty(bins) || isnan(bins(1))
        continue;
    end
    
    % Convert the PDF to log scale.
    if logMode == 1
        pdfs = data.PDF;
        pdfs(pdfs > 0) = log10(pdfs(pdfs > 0));
        data.PDF = pdfs;
        histogram(i) = data;

    % Convert the values to log scale.
    else
        
        % Convert the set data to log scale.
        data.sets.mean.all = logScale(data.sets.mean.all);
        data.sets.stdDev.all = logScale(data.sets.stdDev.all);
        if data.isSigned
            data.sets.mean.abs = logScale(data.sets.mean.abs);
            data.sets.mean.pos = logScale(data.sets.mean.pos);
            data.sets.mean.neg = logScale(data.sets.mean.neg);
            data.sets.stdDev.abs = logScale(data.sets.stdDev.abs);
            data.sets.stdDev.pos = logScale(data.sets.stdDev.pos);
            data.sets.stdDev.neg = logScale(data.sets.stdDev.neg);
        end
        
        % Convert the data sets to log scale.
        data.data.mean.all = logScale(data.data.mean.all);
        data.data.stdDev.all = logScale(data.data.stdDev.all);
        if data.isSigned
            data.data.mean.abs = logScale(data.data.mean.abs);
            data.data.mean.pos = logScale(data.data.mean.pos);
            data.data.mean.neg = logScale(data.data.mean.neg);
            data.data.stdDev.abs = logScale(data.data.stdDev.abs);
            data.data.stdDev.pos = logScale(data.data.stdDev.pos);
            data.data.stdDev.neg = logScale(data.data.stdDev.neg);
        end
        
        % Convert the total data to log scale.
        data.allData.mean.all = logScale(data.allData.mean.all);
        data.allData.stdDev.all = logScale(data.allData.stdDev.all);
        if data.isSigned
            data.allData.mean.abs = logScale(data.allData.mean.abs);
            data.allData.mean.pos = logScale(data.allData.mean.pos);
            data.allData.mean.neg = logScale(data.allData.mean.neg);
            data.allData.stdDev.abs = logScale(data.allData.stdDev.abs);
            data.allData.stdDev.pos = logScale(data.allData.stdDev.pos);
            data.allData.stdDev.neg = logScale(data.allData.stdDev.neg);
        end
        
        % Convert the bins to log scale.
        data.bins = logScale(bins);
    
        % Are we using equal bin widths?
        if ~isEqualBins
            
            % Are we converting the PDF to log scale?
            if logMode ~= 2
                pdfs = data.PDF;
                pdfs(pdfs > 0) = log10(pdfs(pdfs > 0));
                data.PDF = pdfs;
            end
    
            % Update the histogram.
            histogram(i) = data;
            continue;
        end
        
        % Compute the bin range.
        bins = data.bins;
        minBins = min(bins);
        maxBins = max(bins);
        
        % Compute the padding.
        resolution = log10(data.resolution + 1);
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
        bins = linspace(minEdge + halfResolution, ...
            maxEdge - halfResolution, numBins);
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
                dataCounts(:,j) = dataCounts(:,j) + ...
                    oldDataCounts(:, oldBinsI);
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
        
        % Are we converting the PDF to log scale?
        if logMode ~= 2
            pdfs = data.PDF;
            pdfs(pdfs > 0) = log10(pdfs(pdfs > 0));
            data.PDF = pdfs;
        end
    
        % Update the histogram.
        histogram(i) = data;
    end
end

% Fix the log-scale range.
if logMode ~= 2
    minPDF = min(arrayfun(@(x) min(x.PDF), histogram));
    if ~isnan(minPDF)
        for i = 1:length(histogram)
            pdfs = histogram(i).PDF;
            if length(pdfs) == 1 && ~isnan(pdfs)
                pdfs = pdfs - minPDF + 1;
            else
                pdfs(pdfs < 0) = pdfs(pdfs < 0) - minPDF + 1;
            end
            histogram(i).PDF = pdfs;
        end
    end
end
end



%% Convert data to log scale.
function data = logScale(data)

% Use the absolute value of the data.
negData = data < 0;
data(negData) = -data(negData);

% Translate the data by +1 to avoid negative logarithms.
data = log10(data + 1);

% Re-sign the data.
data(negData) = -data(negData);
end
