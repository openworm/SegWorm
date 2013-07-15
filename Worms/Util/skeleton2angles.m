function angles = skeleton2angles(skeletonX, skeletonY, varargin)
%SKELETON2ANGLES Compute the angles across a worm skeleton.
%
%   ANGLES = SKELETON2ANGLES(SKELETONX, SKELETONY)
%
%   ANGLES = SKELETON2ANGLES(SKELETONX, SKELETONY, EDGELENGTH)
%
%   Inputs:
%       skeletonX  - the skeleton's x-axis coordinates per frame
%       skeletonY  - the skeleton's y-axis coordinates per frame
%       edgeLength - the edge length for computing the angles; if empty,
%                    the edge length defaults to 1/12 the number of
%                    skeleton points (as used in segWorm)
%
%   Outputs:
%       angles - the angles between each pair of coordinates per frame
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Construct the skeleton.
skeleton = cat(3, skeletonX, skeletonY);

% Compute the angle edge.
edgeLength = size(skeleton, 1) / 12;
if ~isempty(varargin)
    edgeLength = varargin{1};
end

% Compute the angles.
angles = nan(size(skeleton, 1), size(skeleton, 2));
for i = 1:size(skeleton, 2)
    angles(:,i) = curvature(squeeze(skeleton(:,i,:)), edgeLength);
end
end
