function data = loadStructField(fileName, structName, field)
%LOADSTRUCTFIELD Load a struct field from a file.
%
%   DATA = LOADSTRUCTFIELD(FILENAME, DATA, FIELD)
%
%   Inputs:
%       fileName   - the name of the file with the struct
%       structName - the name of the struct to load
%       field      - the field to get (a period delimited string)
%
%   Output:
%       data - the field data
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Load the struct.
structData = load(fileName, structName);

% Is the struct empty? 
if ~isfield(structData, structName)
    data = [];
    return;
end

% Get the field.
data = getStructField(structData, [structName '.' field]);

% Free the memory.
clear structData;
end
