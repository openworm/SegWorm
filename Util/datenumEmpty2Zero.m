function value = datenumEmpty2Zero(varargin)
%DATENUMEMPTY2ZERO Call datenum and replace empty return values with 0.
%
% See also DATENUM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

value = datenum(varargin{:});
if isempty(value)
    value = 0;
end
end
