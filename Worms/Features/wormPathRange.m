function range = wormPathRange(x, y)
%WORMPATHRANGE Compute the worm path range (i.e., the worm's distance from
%the center of its path).
%
%   RANGE = WORMPATHRANGE(X, Y)
%
%   Input:
%       x - the worm's centroid x-axis coordinates
%       y - the worm's centroid y-axis coordinates
%
%   Output:
%       range - the worm's distance from the center of its path

% Compute the center of the path.
xCentroid = nanmean(x);
yCentroid = nanmean(y);

% Compute the worm's distance from the center of its path.
range = sqrt((x - xCentroid) .^ 2 + (y - yCentroid) .^ 2);
end
