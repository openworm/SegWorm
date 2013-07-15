function histogram = filterHistogram(histogram, isUsed)
%FILTERHISTOGRAM Filter a histogram to remove data.
%
%   HISTOGRAM = FILTERHISTOGRAM(HISTOGRAM)
%
%   HISTOGRAM = FILTERHISTOGRAM(HISTOGRAM, ISUSED)
%
%   Input:
%       histogram - the histogram(s) to filter
%       isUsed    - which data entries should we use?
%
%   Output:
%       histogram - the filtered histogram(s)
%
% See also HISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Filter the histogram(s).
for i = 1:length(histogram)
    
    % Is there any data?
    data = histogram(i);
    bins = data.bins;
    if isempty(data) || isempty(bins) || isnan(bins(1))
        continue;
    end
    if all(~isUsed)
        histogram(i) = nanHistogram();
    end
    
    % Filter the data sets.
    data.data.counts = data.data.counts(isUsed,:);
    data.data.samples = data.data.samples(isUsed);
    data.data.mean.all = data.data.mean.all(isUsed);
    data.data.stdDev.all = data.data.stdDev.all(isUsed);
    if data.isSigned
        data.data.mean.abs = data.data.mean.abs(isUsed);
        data.data.mean.pos = data.data.mean.pos(isUsed);
        data.data.mean.neg = data.data.mean.neg(isUsed);
        data.data.stdDev.abs = data.data.stdDev.abs(isUsed);
        data.data.stdDev.pos = data.data.stdDev.pos(isUsed);
        data.data.stdDev.neg = data.data.stdDev.neg(isUsed);
    end
    
    % Filter the set data.
    data.sets.samples = sum(~isnan(data.data.mean.all));
    data.sets.mean.all = nanmean(data.data.mean.all);
    data.sets.stdDev.all = nanstd(data.data.mean.all);
    if data.isSigned
        data.sets.mean.abs = nanmean(data.data.mean.abs);
        data.sets.stdDev.abs = nanstd(data.data.mean.abs);
        data.sets.mean.pos = nanmean(data.data.mean.pos);
        data.sets.stdDev.pos = nanstd(data.data.mean.pos);
        data.sets.mean.neg = nanmean(data.data.mean.neg);
        data.sets.stdDev.neg = nanstd(data.data.mean.neg);
    end
    
    % Filter the total data.
    data.allData.counts = nansum(data.data.counts, 1);
    data.allData.samples = nansum(data.data.samples);
    data.allData.mean.all = ...
        nansum(data.data.mean.all .* data.data.samples) ...
        ./ data.allData.samples;
    data.allData.stdDev.all = NaN;
    if data.isSigned
        data.allData.mean.abs = NaN;
        data.allData.mean.pos = NaN;
        data.allData.mean.neg = NaN;
        data.allData.stdDev.abs = NaN;
        data.allData.stdDev.pos = NaN;
        data.allData.stdDev.neg = NaN;
    end
    
    % Compute the PDFs.
    PDFs = zeros(1, length(bins));
    numSets = 0;
    for j = 1:length(data.data.samples)
        if data.data.samples(j) > 0
            PDFs = PDFs + data.data.counts(j,:) ./ data.data.samples(j);
            numSets = numSets + 1;
        end
    end
    data.PDF = PDFs;
    if numSets > 0
        data.PDF = data.PDF ./ numSets;
    end
    
    % Find the start of the new bins.
    startI = 1;
    while startI <= length(PDFs) && PDFs(startI) == 0
        startI = startI + 1;
    end
    if startI > length(PDFs)
        histogram(i) = nanHistogram();
        continue;
    end
    
    % Find the end of the new bins.
    endI = length(PDFs);
    while endI >= 0 && PDFs(endI) == 0
        endI = endI - 1;
    end
    
    % Remove unused bins.
    data.data.counts = data.data.counts(:,startI:endI);
    data.allData.counts = data.allData.counts(startI:endI);
    data.bins = data.bins(startI:endI);
    data.PDF = data.PDF(startI:endI);
    
    % Update the histogram.
    histogram(i) = data;
end
end
