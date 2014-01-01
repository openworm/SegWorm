function histogram = absHistogram(histogram)
%ABSHISTOGRAM Convert a histogram to its absolute value.
%
%   HISTOGRAM = ABSHISTOGRAM(HISTOGRAM)
%
%   Input:
%       histogram - the histogram(s) to convert
%
%   Output:
%       histogram - the absolute value of the histogram(s)
%
% See also HISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Convert the histogram(s).
for i = 1:length(histogram)
    
    % Is there any data?
    data = histogram(i);
    if isempty(data) || isempty(data.bins)
        continue;
    end
    
    % Is the histogram already positive?
    quarterResolution = double(data.resolution) / 4.0;
    if data.bins(1) < 0
        
        % Take the absolute value of the histogram.
        if data.isSigned
            
            % Take the absolute value of the set data.
            data.sets.mean.all = data.sets.mean.abs;
            data.sets.stdDev.all = data.sets.stdDev.abs;
            data.sets.mean = ...
                rmfield(data.sets.mean, {'abs', 'pos', 'neg'});
            data.sets.stdDev = ...
                rmfield(data.sets.stdDev, {'abs', 'pos', 'neg'});
            
            % Take the absolute value of the data sets.
            data.data.mean.all = data.data.mean.abs;
            data.data.stdDev.all = data.data.stdDev.abs;
            data.data.mean = ...
                rmfield(data.data.mean, {'abs', 'pos', 'neg'});
            data.data.stdDev = ...
                rmfield(data.data.stdDev, {'abs', 'pos', 'neg'});
            
            % Take the absolute value of the total data.
            data.allData.mean.all = data.allData.mean.abs;
            data.allData.stdDev.all = data.allData.stdDev.abs;
            data.allData.mean = ...
                rmfield(data.allData.mean, {'abs', 'pos', 'neg'});
            data.allData.stdDev = ...
                rmfield(data.allData.stdDev, {'abs', 'pos', 'neg'});
            
            % Unsign the histogram.
            data.isSigned = false;
            histogram(i) = data;
        end
        
        % Find the histogram center.
        % Note: to deal with IEEE floating point uncertainty and dual
        % possibilities for where 0 is located, we >= the quarter
        % resolution in place of >= 0.
        isOffCenter = ~(data.isZeroBin);
        pivot = find(data.bins >= quarterResolution, 1);
            
        % Fold the bins.
        histogram(i).bins = fold(abs(data.bins), pivot, isOffCenter, []);
        
        % Fold the PDF.
        histogram(i).PDF = fold(data.PDF, pivot, isOffCenter);
        
        % Fold the data counts.
        histogram(i).data.counts = fold(data.data.counts, pivot, ...
            isOffCenter);
        
        % Fold all data counts.
        histogram(i).allData.counts = fold(data.allData.counts, pivot, ...
            isOffCenter);
    end
end
end

% Fold data at a pivot.
function data = fold(data, pivot, isOffCenter, varargin)

% Determine the folding operation.
op = @plus;
if ~isempty(varargin)
    op = varargin{1};
end

% The pivot is just above the data center.
if isOffCenter
    
    % Determine the data on either side of the pivot.
    data1 = fliplr(data(:,1:(pivot - 1)));
    data2 = data(:,pivot:end);
    
    % Fold the data.
    data = zeros(size(data, 1), max(size(data1, 2), size(data2, 2)));
    data(:,1:size(data1, 2)) = data1;
    if isempty(op)
        data(:,1:size(data2, 2)) = data2;
    else
        data(:,1:size(data2, 2)) =  op(data(:,1:size(data2, 2)), data2);
    end
    
% The pivot is at the data center.
else
    
    % Determine the data on either side of the pivot.
    dataP = data(:,pivot);
    data1 = fliplr(data(:,1:(pivot - 1)));
    data2 = data(:,(pivot + 1):end);
    
    % Fold the data.
    data = zeros(size(data, 1), max(size(data1, 2), size(data2, 2)) + 1);
    data(:,1) = dataP;
    data(:,2:(size(data1,2) + 1)) = data1;
    if isempty(op)
        data(:,2:(size(data2, 2) + 1)) = data2;
    else
        data(:,2:(size(data2, 2) + 1)) = ...
            op(data(:,2:(size(data2, 2) + 1)), data2);
    end
end
end
