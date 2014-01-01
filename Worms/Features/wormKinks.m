function [numKinks kinkAngles kinkIndices] = ...
    wormKinks(wormAngles, varargin)
%WORMKINKS Compute the kinks in a worm.
%
%   [NUMKINKS KINKANGLES KINKINDICES] = WORMKINKS(WORMANGLES)
%
%   [NUMKINKS KINKANGLES KINKINDICES] = WORMKINKS(WORMANGLES, LENGTHTHR)
%
%   [NUMKINKS KINKANGLES KINKINDICES] = WORMKINKS(WORMANGLES, LENGTHTHR,
%                                                 AMPTHR)
%
%   [NUMKINKS KINKANGLES KINKINDICES] = WORMKINKS(WORMANGLES, LENGTHTHR,
%                                                 AMPTHR, ISSMOOTHING)
%
%   [NUMKINKS KINKANGLES KINKINDICES] = WORMKINKS(WORMANGLES, LENGTHTHR,
%                                                 AMPTHR, ISSMOOTHING,
%                                                 WORMSKELETONS)
%
%   Inputs:
%       wormAngles    - the worm(s) bend angles at each skeleton point
%       lengthThr     - the bend segment length threshold, shorter segments
%                       are considered noise, not bends;
%                       the default is 1/12 of the worm
%       ampThr        - the bend amplitude threshold, smaller amplitudes
%                       are considered noise, not bends;
%                       the default is 0 degrees
%       issmoothing   - are we smoothing the worm angles? If so, the angles
%                       are convolved with a gaussian filter of the same
%                       size as the length threshold; the default is true
%       wormSkeletons - a 3-D matrix of worms (the first 2 dimensions are
%                       the x and y coordinates and the 3rd dimension is
%                       worms); when present, the worm kinks are displayed
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

% Determine the bend segment length threshold.
lengthThr = round(size(wormAngles, 1) / 12);
if ~isempty(varargin) && ~isempty(varargin{1})
    lengthThr = varargin{1};
end
%endLengthThr = round(lengthThr / 2) + 1;
%endLengthThr = round(lengthThr * 0.75);
endLengthThr = lengthThr;

% Determine the bend amplitude threshold.
ampThr = 0;
if length(varargin) > 1 && ~isempty(varargin{2})
    ampThr = varargin{2};
end

% Are we smoothing the worm angles?
isSmoothing = true;
if length(varargin) > 2
    isSmoothing = varargin{3};
end

% Should we show the results on the worm(s)?
wormSkeletons = [];
if length(varargin) > 3
    wormSkeletons = squeeze(varargin{4});
end

% Orient the worm correctly.
wormAngles = squeeze(wormAngles);
if size(wormAngles, 1) == 1
    wormAngles = wormAngles';
end

% Compute a guassian filter for the angles.
if isSmoothing
    halfLengthThr = round(lengthThr / 2);
    gaussFilter = gausswin(halfLengthThr * 2 + 1) / halfLengthThr;
end

% Compute the kinks for the worms.
numWorms = size(wormAngles, 2);
numKinks = nan(1, numWorms);
kinkAngles = cell(1, numWorms);
kinkIndices = cell(1, numWorms);
for i = 1:size(wormAngles, 2)
    
    % Do we have a worm?
    bends = wormAngles(:,i);
    nanBends = isnan(bends);
    if all(nanBends)
        continue;
    end
    
    % Filter the worm bends.
    if isSmoothing
        bends = conv(bends, gaussFilter, 'same');
    end
    
    % Compute the kinks.
    bendSigns = sign(bends);
    kinkAngle = nan(1, length(bendSigns));
    kinkIndex = nan(1, length(bendSigns));
    numKink = 0;
    numSameSign = 0; % the number of adjacent bends with the same sign
    for j = 1:(length(bendSigns) - 1) % the last bend is NaN
        
        % Compute the kink information.
        % Note: data at the zero crossing is counted for both bend sides.
        if bendSigns(j) ~= 0 && ~isnan(bendSigns(j)) && ...
                ~isnan(bendSigns(j + 1)) && ...
                bendSigns(j) ~= bendSigns(j + 1)
            if bendSigns(j) > 0
                amp = max(bends((j - numSameSign):j));
            elseif bendSigns(j) < 0
                amp = min(bends((j - numSameSign):j));
            else
                amp = 0;
            end
            
            % Compute the bend length.
            if numKink == 0
                bendLength = j;
            else
                bendLength = numSameSign + 1;
            end
            
            % Include the zero bend.
            if bendSigns(j+1) == 0
                bendLength = bendLength + 1;
            end
            
            % Add the first kink.
            if numKink == 0
                if bendLength >= endLengthThr && abs(amp) >= ampThr
                    numKink = numKink + 1;
                    kinkAngle(numKink) = amp;
                    kinkIndex(numKink) = j - (bendLength - 1) / 2;
                end
                
            % Add the kink.
            else
                if bendLength >= lengthThr && abs(amp) >= ampThr
                    numKink = numKink + 1;
                    kinkAngle(numKink) = amp;
                    kinkIndex(numKink) = j - (bendLength - 1) / 2;
                end
            end
            
            % Reset the count for adjacent bends with the same sign.
            numSameSign = 0;
            
        % Advance.
        else
            numSameSign = numSameSign + 1;
        end
    end

    % Compute the kink information for the last bend.
    bendLength = numSameSign + 1;
    segSigns = bendSigns((end - bendLength + 1):end);
    segSigns = segSigns(~isnan(segSigns));
    if isempty(segSigns) || segSigns(1) == 0
        amp = 0;
    elseif segSigns(1) == 1
        amp = max(bends((end - bendLength + 1):end));
    else % if segSigns(1) == -1
        amp = min(bends((end - bendLength + 1):end));
    end
    if bendLength >= endLengthThr && abs(amp) >= ampThr
        numKink = numKink + 1;
        kinkAngle(numKink) = amp;
        kinkIndex(numKink) = length(bends) - (bendLength - 1) / 2;
    end
    
    % Clean up the kink information.
    kinkAngle((numKink + 1):end) = [];
    kinkIndex((numKink + 1):end) = [];
    
    % Record the kink information.
    numKinks(i) = numKink;
    kinkAngles{i} = kinkAngle;
    kinkIndices{i} = kinkIndex;
    
    % Show the results.
    if ~isempty(wormSkeletons)
        
        % Orient the worm correctly.
        worm = squeeze(wormSkeletons(:,:,i));
        if size(worm, 1) == 2
            worm = worm';
        end
            
        % Show the results.
        figure;
        hold on;
        plot(worm(:,1), worm(:,2), 'k.');
        plot(worm(nanBends,1), worm(nanBends,2), 'r.');
        if numKinks(i) > 0
            indices = round(kinkIndices{i});
            plot(worm(indices,1), worm(indices,2), 'g.');
        end
        axis image;
    end
end
end
