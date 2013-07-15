function str = color2TeX(color)
%COLOR2TEX Convert a color to a TeX string.
%
%   STR = COLOR2TEX(COLOR)
%
%   Input:
%       color - the RGB color vector
%
%   Output:
%       str - a TeX string for the color
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
str = sprintf('\\color[rgb]{%f %f %f}', color(1), color(2), color(3));
end
