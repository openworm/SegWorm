function featureData = addFeatureData(featureData, featureList, dataToAdd)
% ADDFEATUREDATA This function will take feature data for a particular block
% and will add it to the master featureData variable which contains the 
% values for all of the blocks computerd so far.
%
% Input:
%   featureData - struct that holds arrays for all of the features
%   featureList - a cell of strings indicating witch features are to be
%       added to the featureData struct.
%   dataToAdd - the data for block of interest
%
% Output:
%   featureData - the updated feature data
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

len1 = length(featureList);
len2 = length(dataToAdd);

if len1~=len2
    error('featureProcess:addFeatureData', ['feature list and data are not' ...
        'of the same length! Make sure you are passing all the data and all the'...
        'labels.']);
end

for i=1:len1
    featureData.(featureList{i}) = [featureData.(featureList{i}), dataToAdd{i}];
end