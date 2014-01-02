function [vulvaContours nonVulvaContours angles vulvaAreas nonVulvaAreas] = ...
    flipNormWormVulvas(vulvaContours, nonVulvaContours, angles, ...
    vulvaAreas, nonVulvaAreas)
%FLIPNORMWORMVULVAS Flip the vulval-side orientation of the normalized
%worms.
%
%   [VULVACONTOURS NONVULVACONTOURS ANGLES VULVAAREAS NONVULVAAREAS] =
%       FLIPNORMWORMVULVAS(VULVACONTOURS, NONVULVACONTOURS, ANGLES,
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
%       angles           - the worms' normalized skeleton angles
%                          Note: positive skeleton angles now bulge towards
%                          the vulva; in contrast, previously in the worm
%                          structure, positive skeleton angles bulged
%                          towards the side clockwise from the worm's head
%                          (unless the worm was flipped).
%       vulvaAreas       - the worms' vulval-side areas
%                          (excluding the head and tail)
%       nonVulvaAreas    - the worms' non-vulval-side areas
%                          (excluding the head and tail)
%
% See also NORMWORMS, FLIPNORMWORMHEADS
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Flip the contour.
tmp = vulvaContours;
vulvaContours = nonVulvaContours;
nonVulvaContours = tmp;

% Flip the skeleton angles.
angles = -angles;

% Flip the areas.
tmp = vulvaAreas;
vulvaAreas = nonVulvaAreas;
nonVulvaAreas = tmp;
end
