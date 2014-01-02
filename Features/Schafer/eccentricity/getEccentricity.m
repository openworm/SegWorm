function [eccentricity orientation] = getEccentricity(xOutline, yOutline, gridSize)

% GETPOLYECCENTRICITY  Given x and y coordinates of the outline of a region
% of interest, fill the outline with a grid of evenly spaced points and use
% these to calculate the eccentricity and orientation of the equivalent 
% ellipse.
% 
% Input:
%   xOutline - The x coordinates of the outline of the region of interest
%   yOutline - The y coordinates of the outline of the region of interest
%   gridSize - The side length of grid to be used to fill in the region of
%              interest.  50 gives reasonable values quickly for our data.
% 
% Output:
%   eccentricity - The eccentricity of the equivalent ellipse of the region
%                  of interest.
%   orientation  - The orientation angle of the equivalent ellipse of the
%                  region of interest.
%
% NOTE: this function uses the eccentricity code from regionprops 
% essentially unchanged.
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

%center the worm at its centroid
xOutline = xOutline - mean(xOutline);
yOutline = yOutline - mean(yOutline); 

% make a grid of points that covers the worm area based on the max and min
% values of xOutline and yOutline.  
xRange = max(xOutline) - min(xOutline);
yRange = max(yOutline) - min(yOutline);
gridAspectRatio = xRange/yRange;

% if the bounding box aspect ratio is skewed, use a smaller number of
% grid points for the smaller of the two dimensions.  This ensures more
% uniform sampling of the region inside the polygon.
if xRange > yRange
    % x size is larger so scale down the number of grid points in the y
    % direction
    [m n] = meshgrid( linspace(min(xOutline), max(xOutline), gridSize),...
        linspace(min(yOutline), max(yOutline), ...
        round(gridSize / gridAspectRatio)) );
else
    % y size is larger so scale down the number of grid points in the x
    % direction
    [m n] = meshgrid( linspace(min(xOutline), max(xOutline), ...
        round(gridSize * gridAspectRatio)),...
        linspace(min(yOutline), max(yOutline), gridSize) );
end

% get the indices of the points inside of the polygon
inPointInds = inpoly([m(:) n(:)], [xOutline yOutline]);

% get the x and y coordinates of the new set of points to be used in
% calculating eccentricity.
x = m(inPointInds);
y = n(inPointInds);

N = length(x);

% Calculate normalized second central moments for the region.
uxx = sum(x.^2)/N;
uyy = sum(y.^2)/N;
uxy = sum(x.*y)/N;

% Calculate major axis length, minor axis length, and eccentricity.
common = sqrt((uxx - uyy)^2 + 4*uxy^2);
majorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy + common);
minorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy - common);
eccentricity = 2*sqrt((majorAxisLength/2)^2 - ...
    (minorAxisLength/2)^2) / majorAxisLength;

% Calculate orientation.
if (uyy > uxx)
    num = uyy - uxx + sqrt((uyy - uxx)^2 + 4*uxy^2);
    den = 2*uxy;
else
    num = 2*uxy;
    den = uxx - uyy + sqrt((uxx - uyy)^2 + 4*uxy^2);
end
if (num == 0) && (den == 0)
    orientation = 0;
else
    orientation = (180/pi) * atan(num/den);
end