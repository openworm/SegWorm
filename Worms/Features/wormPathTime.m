function [arena times] = wormPathTime(skeletonX, skeletonY, points, ...
    scale, fps)
%WORMPATHTIME Compute the time spent at each point along the worm path.
%
%   [ARENA TIMES] = WORMPATHTIME(SKELETON, POINTS, SCALE, FPS)
%
%   Inputs:
%       skeletonX - the worm skeleton's x coordinates per frame
%                   (x-coordinates x frames)
%       skeletonY - the worm skeleton's y coordinates per frame
%                   (y-coordinates x frames)
%       points    - the skeleton points (cell array) to use; each set of
%                   skeleton points delineates a separate path
%       scale     - the coordinate scale for the path
%                   Note: if the path time is integrated at the standard
%                   micron scale, the matrix will be too large and the
%                   worm's width will be too skinny. Therefore, I suggest
%                   using an a scale of 1/width to match the worm's width
%                   to a pixel edge; or, if you want to account for the
%                   long diagonal axis in the taxi-cab metric of pixels,
%                   use sqrt(2)/width to match the worm's width to a
%                   pixel's diagonal length
%       fps       - the frames/seconds
%
%   Output:
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
%       times - a struct(s) of the time(s) spent, per path, with subfields:
%
%               indices = the indices for the non-zero time points in the
%                         arena matrix
%               times   = the non-zero time point values (in seconds)
%                         corresponding to the arena matrix indices
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Organize the skeleton points.
if ~iscell(points)
    points = {points};
end

% Compute the arena.
xMin = min(skeletonX(:));
xMax = max(skeletonX(:));
yMin = min(skeletonY(:));
yMax = max(skeletonY(:));

% The skeletons are empty.
if isempty(xMin) || isnan(xMin)
    arena.height = NaN;
    arena.width = NaN;
    arena.min.x = NaN;
    arena.min.y = NaN;
    arena.max.x = NaN;
    arena.max.y = NaN;
    times(length(points)).indices = NaN;
    times(length(points)).times = NaN;
    return;
end

% Scale the skeleton.
skeletonX = round(skeletonX * scale);
skeletonY = round(skeletonY * scale);

% Translate the skeleton to a zero origin.
xScaledMin = min(skeletonX(:));
xScaledMax = max(skeletonX(:));
yScaledMin = min(skeletonY(:));
yScaledMax = max(skeletonY(:));
skeletonX = skeletonX - xScaledMin + 1;
skeletonY = skeletonY - yScaledMin + 1;

% Construct the empty arena(s).
arenaSize = [yScaledMax - yScaledMin + 1, xScaledMax - xScaledMin + 1];
zeroArena = zeros(arenaSize);
arenas = cell(length(points),1);
for i = 1:length(points)
    arenas{i} = zeroArena;
end

% Compute the time spent at each point for the path(s).
for i = 1:size(skeletonX, 2)

    % Is there a skeleton for this frame?
    if isnan(skeletonX(1,i))
        continue;
    end

    % Compute the worm.
    wormI = sub2ind(arenaSize, skeletonY(:,i), skeletonX(:,i));
    
    % Compute the time at each point for the worm points path(s).
    for j = 1:length(arenas)
        
        % Compute the unique worm points.
        wormPointsI = unique(wormI(points{j}));
        
        % Integrate the path.
        arenas{j}(wormPointsI) = arenas{j}(wormPointsI) + 1;
    end
end

% Correct the y-axis (from image space).
for i = 1:length(arenas)
    arenas{i} = flipud(arenas{i});
end

% Organize the arena size.
arena.height = arenaSize(1);
arena.width = arenaSize(2);
arena.min.x = xMin;
arena.min.y = yMin;
arena.max.x = xMax;
arena.max.y = yMax;

% Organize the arena/path time(s).
times(length(arenas)).indices = [];
times(length(arenas)).times = [];
for i = 1:length(arenas)
    times(i).indices = find(arenas{i} > 0);
    times(i).times = double(arenas{i}(times(i).indices)) / fps;
end
end
