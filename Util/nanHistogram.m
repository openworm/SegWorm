function data = nanHistogram(varargin)
%HISTOGRAM Get a histogram full of NaNs.
%
%   DATA = NANHISTOGRAM()
%
%   DATA = NANHISTOGRAM(ISSIGNED)
%
%   DATA = NANHISTOGRAM(ISSIGNED, NUMSETS)
%
%   Inputs:
%       isSigned   - is the data signed (+/-)?
%                    if empty, the data is assumed to be not signed
%       numSets    - the number of NaN data sets;
%                    if empty, the number of data sets is set to 1
%
%   Outputs:
%       data - the NaN histogram data. A struct with fields:
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
% See also HISTOGRAM, EMPTYHISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.


% Is the data signed (+/-)?
isSigned = [];
if ~isempty(varargin) && ~isempty(varargin{1})
    isSigned = varargin{1};
end
if isempty(isSigned) || isnan(isSigned)
    isSigned = false;
end

% How many data sets are there?
numSets = 1;
if length(varargin) > 1
    numSets = varargin{2};
end

% Organize the histogram set data.
data.sets.samples = numSets;
data.sets.mean.all = NaN;
data.sets.stdDev.all = NaN;
if isSigned
    
    % Set the absolute value statisitics.
    data.sets.mean.abs = NaN;
    data.sets.stdDev.abs = NaN;
    
    % Set the positive value statisitics.
    data.sets.mean.pos = NaN;
    data.sets.stdDev.pos = NaN;
    
    % Set the negative value statisitics.
    data.sets.mean.neg = NaN;
    data.sets.stdDev.neg = NaN;
end

% Organize the histogram data sets.
nanSets = nan(numSets, 1);
data.data.counts = nanSets;
data.data.samples = nanSets;
data.data.mean.all = nanSets;
data.data.stdDev.all = nanSets;
if isSigned
    
    % Set the absolute value statisitics.
    data.data.mean.abs = nanSets;
    data.data.stdDev.abs = nanSets;
    
    % Set the positive value statisitics.
    data.data.mean.pos = nanSets;
    data.data.stdDev.pos = nanSets;
    
    % Set the negative value statisitics.
    data.data.mean.neg = nanSets;
    data.data.stdDev.neg = nanSets;
end

% Organize the histogram total data.
data.allData.counts = NaN;
data.allData.samples = NaN;
data.allData.mean.all = NaN;
data.allData.stdDev.all = NaN;
if isSigned
    
    % Set the absolute value statisitics.
    data.allData.mean.abs = NaN;
    data.allData.stdDev.abs = NaN;
    
    % Set the positive value statisitics.
    data.allData.mean.pos = NaN;
    data.allData.stdDev.pos = NaN;
    
    % Set the negative value statisitics.
    data.allData.mean.neg = NaN;
    data.allData.stdDev.neg = NaN;
end

% Organize the histogram.
data.PDF = NaN;
data.bins = NaN;
data.resolution = NaN;
data.isZeroBin = NaN;
data.isSigned = isSigned;
end
