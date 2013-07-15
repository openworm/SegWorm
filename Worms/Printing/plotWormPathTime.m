%PLOTWORMPATHTIME Plot the worm path integral.
%
%   PLOTWORMPATHTIME(ARENA, TIME, TITLENAME, AXISNAME)
%
%   PLOTWORMPATHTIME(ARENA, TIME, TITLENAME, AXISNAME, ISSTATS)
%
%   Inputs:
%       arena - a struct of the arena/path size with subfields:
%
%               height = the arena height
%                        (for the matrix of time spent at each point)
%               width  = the arena width
%                        (for the matrix of time spent at each point)
%
%               min:
%                  x = the path location of the arena's minimum x coordinate
%                  y = the path location of the arena's minimum y coordinate
%
%               max:
%                  x = the path location of the arena's maximum x coordinate
%                  y = the path location of the arena's maximum y coordinate
%
%       times - a struct of the time spent on the path with subfields:
%
%               indices = the indices for the non-zero time points in the
%                         arena matrix
%               times   = the non-zero time point values (in seconds)
%                         corresponding to the arena matrix indices
%
%       titleName - the title for the figure
%       axisName  - the name to label the path axes
%       isStats   - are we showing the summary statistics in the X label?
%                   the default is yes (true)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function plotWormPathTime(arena, time, titleName, axisName, varargin)

% Are we showing summary statistics?
isStats = true;
if ~isempty(varargin)
    isStats = varargin{1};
end

% Construct the path integral image.
img = zeros(arena.height, arena.width);
img(time.indices) = time.times;

% Show the image.
imgHandle = ...
    imagesc([arena.min.x, arena.max.x], [arena.max.y, arena.min.y], img);
axis image;
set(get(imgHandle, 'Parent'), 'YDir', 'normal');

% Label the figure.
if isStats
    meanStr = ['Mean = ' num2str(nanmean(time.times)) ' seconds'];
    stdStr = ['Std Dev = ' num2str(nanstd(time.times)) ' seconds'];
    title({titleName, meanStr, stdStr});
else
    title(titleName);
end
xlabel(['X ' axisName]);
ylabel(['Y ' axisName]);

% Label the figure values.
colorbarHandle = colorbar;
caxis([min(time.times), max(time.times)]);
set(get(colorbarHandle, 'YLabel'), 'String', 'Time (seconds)');
end
