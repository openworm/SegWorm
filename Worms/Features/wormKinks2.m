function [numKinks indices] = wormKinks2(worms, distance, varargin)
%WORMKINKS Compute the kinks in a worm.
%
%   [numKinks indices] = wormKinks(angles, distance)
%
%   [numKinks indices] = wormKinks(angles, distance, isPeaks)
%
%   [numKinks indices] = wormKinks(angles, distance, iPeaks, peakThr)
%
%   [numKinks indices] = wormKinks(angles, distance, iPeaks, peakThr,
%                        verbose)
%
%   Inputs:
%       worms    - a 2-D worm (x and y coordinates in rows); or,
%                  a 3-D matrix of worms (the 3rd dimension is worms)
%       distance - the distance to use in computing the angle and peaks
%       isPeaks  - are we computing the peaks or crossovers between peaks
%       peakThr  - the peak threshold (to ignore noise)
%       verbose  - verbose mode shows the results in a figure
%
%   Outputs:
%       numKinks - the number of kinks
%       indices  - the indices of the kinks
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Return the peak indices as the default.
isPeaks = 1;
if ~isempty(varargin)
    isPeaks = varargin{1};
end

% Use no peak threshold as the default.
peakThr = [];
if length(varargin) > 1
    peakThr = varargin{2};
end

% Should we show the results on the worm?
verbose = 0;
if length(varargin) > 2
    verbose = varargin{3};
end

% Compute the kinks for the worms.
indices = cell(size(worms, 3),1);
numKinks(1:size(worms, 3)) = NaN;
for i = 1:size(worms, 3)
    
    % Compute the worm curvature.
    angles = curvature(worms(:,:,i), distance);
    
    % Compute the worm kinks.
    indices(i) = {findWormKinks(angles, distance, isPeaks, peakThr)};
    if ~isnan(indices{i})
        numKinks(i) = length(indices{i});
        
        % Show the results on the worm.
        if verbose
            
            % Orient the worm correctly.
            worm = squeeze(worms(:,:,i));
            if size(worm, 2) > 2
                worm = worm';
            end
            
            % Determine which angles have not been computed.
            nanAngles = isnan(angles);
            
            % Show the results.
            figure;
            hold on;
            plot(worm(:,1), worm(:,2), 'k.');
            if numKinks(i) > 0
                plot(worm(indices{i},1), worm(indices{i},2), 'g.');
            end
            plot(worm(nanAngles,1), worm(nanAngles,2), 'r.');
            axis image;
        end
    end
end
end

% Compute the kinks for a worm.
function indices = findWormKinks(angles, distance, isPeaks, peakThr)

% Find the start of the angles.
i = 1;
while i <= length(angles) && isnan(angles(i))
    i = i + 1;
end
angleStart = i;

% Find the end of the angles.
i = length(angles);
while i >= 1 && isnan(angles(i))
    i = i - 1;
end
angleEnd = i;

% Use the non-NaN angles.
angles = angles(angleStart:angleEnd);

% Empty worm.
if isempty(angles)
    indices = NaN;
    
% Locate the peak angles.
elseif isPeaks
    aAngles = abs(angles);
    [~, indices] = maxPeaksDist(aAngles, distance);
    %[~, minIs] = minPeaksDist(angles, distance);
    %indices = [minIs; maxIs];
    
    % Clean up the indices.
    indices = sort(indices);
    %indices = unique(indices);
    
    % Remove small peaks.
    if ~isempty(peakThr)
        indices(aAngles(indices) < peakThr) = [];
    
    % Remove the start and end peaks, if necessary.
    else
        if indices(1) == 1
            indices(1) = [];
        end
        if indices(end) == length(aAngles)
            indices(end) = [];
        end
    end
    
% Locate the cross over points (where the derivative of the angles is 0).    
else
    aAngles = abs(angles);
    [~, indices] = minPeaksDist(aAngles, distance);
    
    % Remove large peaks.
    if ~isempty(peakThr)
        indices(aAngles(indices) > peakThr) = [];
        
    % Remove the start and end peaks, if necessary.
    else
        if indices(1) == 1
            indices(1) = [];
        end
        if indices(end) == length(aAngles)
            indices(end) = [];
        end
    end
end

% Offset the indices to their correct values.
indices = indices + angleStart - 1;
end

