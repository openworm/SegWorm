function hexColors = colors2hex(colors)
%COLORS2HEX Convert colors to their hex codes (e.g, for HTML).
%
%   HEXCOLORS = COLORS2HEX(COLORS)
%
%   Input:
%       colors - the colors to convert (a matrix of color x RGB values)
%
%   Output:
%       hexColors - the hex color codes (color x 6 character hex string)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

hexI = [1 4 2 5 3 6];
hexColors = char(zeros(size(colors,1), 6));
for i = 1:size(colors,1)
    hexColor = dec2hex(colors(i,:) * 255, 2);
    hexColors(i,:) = hexColor(hexI);
end
end

