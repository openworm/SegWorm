function [pixels indices] = downSampleSkeleton(worm, samples)
%DOWNSAMPLESKELETON Downsample the skeleton to fewer points using the chain
%   code length.
%
%   [PIXELS INDICES] = DOWNSAMPLESKELETON(WORM, SAMPLES)
%
%   Inputs:
%       worm    - the worm to downsample
%       samples - the number of samples to take
%
%   Output:
%       pixels  - the interpolated pixels for the samples based on their
%                 chain-code-length spacing
%       indices - the indices for the samples based on their
%                 chain-code-length spacing
%
% See also DOWNSAMPLEPOINTS

% Downsample the skeleton to the requested number of samples.
[pixels, indices, ~] = downSamplePoints(worm.skeleton.pixels, samples, ...
    worm.skeleton.chainCodeLengths);
end
