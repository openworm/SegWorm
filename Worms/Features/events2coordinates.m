function coordinates = events2coordinates(skeleton, points, frames)
%EVENT2COORDINATES Convert events to their coordinate locations.
%
%   COORDINATES = EVENT2COORDINATES(SKELETON, POINTS, EVENTS)
%
%   Inputs:
%       skeleton - the worm skeleton matrix (points x coordinates x frames)
%       points   - the skeleton points (array) to average
%       frames   - the frames at which the event took place;
%                  a structure array with fields:
%
%                  start = the start frame
%                  end   = the end frame
%
%   Output:
%       coordinates - the events coordinates (XY coordinates x event number)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Compute the event coordinates.
coordinates = nan(2, length(events));
for i = 1:length(events)
    
    % Find a starting index with a skeleton.
    startI = [];
    j = frames(i).start + 1;
    while j >= 1 && isnan(skeleton(1,1,j))
        j = j - 1;
    end
    if j >= 1
        startI = j;
    end
    
    % Find an ending index with a skeleton.
    endI = [];
    j = frames(i).end + 1;
    while j <= size(skeleton,3) && isnan(skeleton(1,1,j))
        j = j + 1;
    end
    if j <= size(skeleton,3)
        endI = j;
    end
    
    % Compute the event coordinates.
    startSkeleton = NaN;
    if ~isempty(startI)
        startSkeleton = mean(skeleton(points, :, startI), 1);
    end
    endSkeleton = NaN;
    if ~isempty(endI)
        endSkeleton = mean(skeleton(points, :, endI), 1);
    end
    coordinates(:,i) = squeeze(nanmean([startSkeleton, endSkeleton], 1));
end
end

