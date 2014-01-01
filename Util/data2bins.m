%DATA2BINS Quantize data into bins.
%
%   DATABINS = DATA2BINS(DATA, NUMBINS)
%
%   Inputs:
%       data    - the data to quantize
%       numBins - the number of bins (quantization)
%
%   Output:
%       dataBins - the quantized data bins (i.e., the data bin indices)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function dataBins = data2bins(data, numBins)

% Normalize the data.
minData = min(data);
data = data - minData;
data = data / max(data);

% Convert the data to its bin index.
dataBins = round((numBins - 1) * data) + 1;
end
