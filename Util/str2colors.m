function colors = str2colors(string, varargin)
%STR2COLORS Convert a string of colors to RGB values.
%
%   COLORS = STR2COLORS(STRING)
%
%   COLORS = STR2COLORS(STRING, INTENSITY)
%
%   COLORS = STR2COLORS(STRING, INTENSITY, ISCELL)
%
%   Inputs:
%       string    - the string of colors; if one value is specified for
%                   multiple intensities, all intensities are adjusted for
%                   the same color:
%
%                   r = red
%                   g = green
%                   b = blue
%                   c = cyan
%                   m = magenta
%                   y = yellow
%                   o = orange
%                   p = purple
%                   s = sky blue
%                   t = turquoise
%                   l = lime green
%                   n = brown
%                   k = black
%                   w = white
%
%       intensity - the color(s) intensity (-1 to 1, this value is added to
%                   the color(s)); if one value is specified for multiple
%                   colors, all colors are adjusted to the same intensity;
%                   the default is 0
%       isCell    - should we return the colors in a cell array;
%                   the default is false
%
%   Output:
%       colors - the list of colors (color x RGB value)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Convert the string to colors.
colors = nan(length(string),3);
for i =1:length(string)
    switch string(i)
        
        % Red.
        case 'r'
            colors(i,:) = [1 0 0];
        
        % Green.
        case 'g'
            colors(i,:) = [0 1 0];
        
        % Blue.
        case 'b'
            colors(i,:) = [0 0 1];
            
        % Cyan.
        case 'c'
            colors(i,:) = [0 1 1];
            
        % Magenta.
        case 'm'
            colors(i,:) = [1 0 1];
            
        % Yellow.
        case 'y'
            colors(i,:) = [1 1 0];
            
        % Orange.
        case 'o'
            colors(i,:) = [1 1/2 0];
            
        % Purple.
        case 'p'
            colors(i,:) = [1/2 0 1];
            
        % Sky blue.
        case 's'
            colors(i,:) = [1/3 2/3 1];
            
        % Turquoise.
        case 't'
            colors(i,:) = [1/3 1 2/3];
            
        % Lime green.
        case 'l'
            colors(i,:) = [2/3 1 1/3];
            
        % Brown.
        case 'n'
            colors(i,:) = [1/2 1/4 0];
            
        % Black.
        case 'k'
            colors(i,:) = [0 0 0];
            
        % White.
        case 'w'
            colors(i,:) = [1 1 1];
    end
end

% Adjust the color intensity.
if ~isempty(varargin)
    
    % We have more intensities than colors.
    intensity = varargin{1};
    sizeDiff = length(intensity) - size(colors, 1);
    if sizeDiff > 0
        for i = (size(colors, 1) + 1):(size(colors, 1) + sizeDiff)
            colors(i,:) = colors(end,:);
        end
        
    % We may have more colors than intensities.
    else
        intensity((end + 1):(end - sizeDiff)) = intensity(end);
    end
    
    % Compute the color intensity.
    for i = 1:length(intensity)
        
        % Adjust the intensity.
        color = colors(i,:) + intensity(i);
        
        % Bound the colors between [0,1].
        color(color > 1) = 1;
        color(color < 0) = 0;
        
        % Store the color.
        colors(i,:) = color;
    end
end

% Should we return the colors in a cell array?
if length(varargin) > 1 && varargin{2}
    colors = num2cell(colors, 2);
end
end
