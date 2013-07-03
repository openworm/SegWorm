function value = datenumEmpty2Zero(varargin)
%DATENUMEMPTY2ZERO Call datenum and replace empty return values with 0.
%
% See also DATENUM

value = datenum(varargin{:});
if isempty(value)
    value = 0;
end
end
