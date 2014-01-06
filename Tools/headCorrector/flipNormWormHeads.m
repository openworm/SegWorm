function [vulvaContours nonVulvaContours skeletons angles inOutTouches ...
    widths headAreas tailAreas vulvaAreas nonVulvaAreas] = ...
    flipNormWormHeads(vulvaContours, nonVulvaContours, skeletons, ...
    angles, inOutTouches, widths, headAreas, tailAreas, ...
    vulvaAreas, nonVulvaAreas)
%FLIPNORMWORMHEADS Flip the head-to-tail orientation of the normalized worms.
%
%Note: since the vulva is specified relative to the head, its location
%flips to preserve its orientation.
%
%   [VULVACONTOURS NONVULVACONTOURS SKELETONS ANGLES INOUTTOUCHES
%    WIDTHS HEADAREAS TAILAREAS VULVAAREAS NONVULVAAREAS] =
%       FLIPNORMWORMHEADS(VULVACONTOURS, NONVULVACONTOURS, SKELETONS,
%       ANGLES, INOUTTOUCHES, WIDTHS, HEADAREAS, TAILAREAS,
%       VULVAAREAS, NONVULVAAREAS)
%
%   Inputs/Outputs:
%       Note 1: all outputs are oriented head to tail.
%       Note 2: all coordinates are oriented as (x,y); in contrast,
%       previously in the worm structure, coordinates were oriented as
%       (row,column) = (y,x).
%
%       vulvaContours    - the worms' normalized vulval-side contours
%       nonVulvaContours - the worms' normalized non-vulval-side contours
%       skeletons        - the worms' normalized skeletons
%       angles           - the worms' normalized skeleton angles
%                          Note: positive skeleton angles now bulge towards
%                          the vulva; in contrast, previously in the worm
%                          structure, positive skeleton angles bulged
%                          towards the side clockwise from the worm's head
%                          (unless the worm was flipped).
%       inOutTouches     - in coiled worms, for each skeleton sample:
%                          -1 = the contours are inside the coil
%                          -2 = the contours are outside the coil
%                          -3 = the contours are both inside and outside
%                               the coil (one half of the contour is inside
%                               the coil, the other half of the contour is
%                               outside it)
%                          1+ = the contour is touching itself to form the
%                               coil; the specific number represents the
%                               contraposed skeleton index being touched
%       widths           - the worms' contours normalized widths
%       headAreas        - the worms' head areas
%       tailAreas        - the worms' tail areas
%       vulvaAreas       - the worms' vulval-side areas
%                          (excluding the head and tail)
%       nonVulvaAreas    - the worms' non-vulval-side areas
%                          (excluding the head and tail)
%
% See also NORMWORMS, FLIPNORMWORMVULVAS
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Flip the contour.
for i = 1:size(vulvaContours,3)
    tmp = flipud(vulvaContours(:,:,i));
    vulvaContours(:,:,i) = flipud(nonVulvaContours(:,:,i));
    nonVulvaContours(:,:,i) = tmp;
end

% Flip the skeletons and their angles.
for i = 1:size(skeletons,3)
    skeletons(:,:,i) = flipud(skeletons(:,:,i));
end
angles = -flipud(angles);

% Flip the inside/outside/touching skeleton points.
inOutTouches = flipud(inOutTouches);
touch = inOutTouches > 0;
inOutTouches(touch) = length(inOutTouches) - inOutTouches(touch) + 1;

% Flip the widths.
widths = flipud(widths);

% Flip the areas.
tmp = headAreas;
headAreas = tailAreas;
tailAreas = tmp;
tmp = vulvaAreas;
vulvaAreas = nonVulvaAreas;
nonVulvaAreas = tmp;
end
