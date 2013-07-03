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
str = sprintf('\\color[rgb]{%f %f %f}', color(1), color(2), color(3));
end
