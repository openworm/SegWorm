function data = emptyHistogram(varargin)
%HISTOGRAM Get a histogram full of NaNs.
%
%   DATA = EMPTYHISTOGRAM()
%
%   Inputs:
%       isSigned - is the data signed (+/-)?
%                  if empty, the data is assumed to be not signed
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
% See also HISTOGRAM, NANHISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Is the data signed.
isSigned = false;
if ~isempty(varargin) && ~isempty(varargin{1})
    isSigned = varargin{1};
end

% Organize the histogram set data.
data.sets.samples = [];
data.sets.mean.all = [];
data.sets.stdDev.all = [];
if isSigned
    
    % Set the absolute value statisitics.
    data.sets.mean.abs = [];
    data.sets.stdDev.abs = [];
    
    % Set the positive value statisitics.
    data.sets.mean.pos = [];
    data.sets.stdDev.pos = [];
    
    % Set the negative value statisitics.
    data.sets.mean.neg = [];
    data.sets.stdDev.neg = [];
end

% Organize the histogram data sets.
data.data.counts = [];
data.data.samples = [];
data.data.mean.all = [];
data.data.stdDev.all = [];
if isSigned
    
    % Set the absolute value statisitics.
    data.data.mean.abs = [];
    data.data.stdDev.abs = [];
    
    % Set the positive value statisitics.
    data.data.mean.pos = [];
    data.data.stdDev.pos = [];
    
    % Set the negative value statisitics.
    data.data.mean.neg = [];
    data.data.stdDev.neg = [];
end

% Organize the histogram total data.
data.allData.counts = [];
data.allData.samples = [];
data.allData.mean.all = [];
data.allData.stdDev.all = [];
if isSigned
    
    % Set the absolute value statisitics.
    data.allData.mean.abs = [];
    data.allData.stdDev.abs = [];
    
    % Set the positive value statisitics.
    data.allData.mean.pos = [];
    data.allData.stdDev.pos = [];
    
    % Set the negative value statisitics.
    data.allData.mean.neg = [];
    data.allData.stdDev.neg = [];
end

% Organize the histogram.
data.PDF = [];
data.bins = [];
data.resolution = [];
data.isZeroBin = [];
data.isSigned = [];
end
