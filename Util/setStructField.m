function data = setStructField(data, field, value)
%SETSTRUCTFIELD Set a field in a structure.
%
%   DATA = SETSTRUCTFIELD(DATA, FIELD, VALUE)
%
%   Inputs:
%       data  - the structure
%       field - the field to set (a period delimited string)
%       value - the value for the field
%
%   Output:
%       data - a structure with the field set to the value
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

eval(['data.' field '=value;']);
end
