function [diffData usedFramesI] = multiScaleDiff(data, use, startI, ...
    endI, rate, type, scales, isSparse, isAtT1)
%MULTISCALEDIFF Differentiate data at multiple scales.
%
%   DIFFDATA = MULTISCALEDIFF(DATA, USE, RATE, TYPE, SCALES, ISSPARSE)
%
%   Inputs:
%       data     - a cell array of data to differentiate; each cell must
%                  contain a vector of values equal, in length, to 'use'.
%                  The data must be 2 dimensional and is differentiated
%                  between columns.
%       use      - for each data element, is it usable? (e.g.,
%                  NaN elements are unusable and should be marked false);
%                  if empty, all the data is treated as usable
%       startI   - the index at which to start differentiating usable data;
%                  if empty, we start at the first data value
%       endI     - the index at which to end differentiating usable data;
%                  if empty, we end at the last data value
%       rate     - the data rate (i.e., the time between subsequent elements)
%       type     - the type of algorithm to use when replacing unusable
%                  data elements. Differentiation is expressed as:
%
%                  dX/dT = -(X1 - X2)/(T1 - T2)
%
%                  type is a 1 or 2 letter string indicating which method
%                  to use when replacing an unusable X1 and/or X2. If type
%                  is 2 characters long:
%
%                  type(1) = X1
%                  type(2) = X2
%
%                  Otherwise, type(1) is used for both X1 and X2. The
%                  methods are as follows:
%
%                  i = linearly interpolate unusable data
%                      (type(2) is ignored)
%                  e = exact match, if data is unusable, the result is NaN
%                  b = backwards nearest neighbor
%                  f = forwards nearest neighbor
%                  n = nearest neighbor
%
%                  Note: the nearest-neighbor type algorithms adjust the
%                  time accordingly. If there is no nearest neighbor,
%                  differentiation results in NaN.
%       scales   - a vector of the scales to use for spacing X1 from X2
%       isSparse - is the differentiation sparse? for each scale, sparse
%                  differentiation only calculates the data differences at
%                  multiples of that scale
%       isAtT1   - is the result of differentiation assigned to time T1?
%                  If so, differentiation must begin at startI minus the
%                  requested scale; if there is no data at startI minus the
%                  requested scale, differentiation results in NaN.
%                  Otherwise, the result of differentiation is assigned to
%                  time T2 and begins at startI. If there is no data at 
%                  endI plus the requested scale, differentiation results
%                  in NaN.
%
%   Output:
%       diffData    - the data differences at each scale. The first
%                     cell array dimension corresponds to the input data's
%                     dimension. The second cell array dimension is the
%                     data differences at each scale.
%       usedFramesI - the indices of the frames used at each scale. The
%                     first cell array dimension corresponds to the input
%                     data's dimension. The second cell array dimension is
%                     matrix of the frame indices used at each scale. The
%                     matrix is 2 dimensional. The first matrix dimension
%                     corresponds to X1 and X2, respectively. The second
%                     matrix dimension corresponds to the frame index used.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Correct the data types, if necessary.
if ~iscell(data)
    data = {data};
end
if isempty(use)
    use = true(length(data{1}), 1);
else
    use = logical(use);
end

% Compute the indices.
if isempty(startI)
    startI = 1;
end
if isempty(endI)
    endI = length(use);
end

% The data and its list of usable elements must have the same length.
for i = 1:length(data)
    if size(data{i}, 2) ~= length(use)
        error('multiScaleDiff:UsableData', ['The data at cell ' ...
            num2str(i) ' and its list of usable elements have ' ...
            'different lengths']);
    end
end

% Check the scales.
if isAtT1
    badScalesMask = scales >= endI;
else
    badScalesMask = scales > length(use) - startI;
end
if any(badScalesMask)
    
    % Remove scales that are too large.
    badScales = scales(badScalesMask);
    scales(badScalesMask) = 0;
    for i = 1:length(badScales)
        warning('multiScaleDiff:BadScale', ['The %d scale cannot be ' ...
            'computed as there is insufficient data'], badScales(i));
    end
end

% There are no scales to compute.
if isempty(scales)
    warning('multiScaleDiff:NoScales', ...
        'There are no scales to differentiate');
    diffData = [];
    usedFramesI = [];
    return;
end

% Interpolate the missing data.
if type(1) == 'i'
    for i = 1:length(data)
        for j = 1:size(data{i}, 1)
            useVector = use & ~isnan(data{i}(j,:));
            usedI = find(useVector);
            unusedI = find(~useVector);
            if ~isempty(unusedI) && length(usedI) > 1 
                data{i}(j,unusedI) = interp1(usedI, data{i}(j,usedI), ...
                    unusedI, 'linear');
            end
        end
    end
    
    % Use exact indexing.
    type = 'ee';
end

% Determine the method to use when X1 is missing.
% Note: the differential is expressed as dX/dT = -(X1 - X2)/(T1 - T2)
switch type(1)
    
    % Do nothing (use the exact index).
    case 'e'
        use1 = @exactIndex;
        
        % Find the back nearest neighbor.
    case 'b'
        use1 = @backNeighbor;
        
        % Find the front nearest neighbor.
    case 'f'
        use1 = @frontNeighbor;
        
        % Find the nearest neighbor.
    case 'n'
        use1 = @nearestNeighbor;
        
        % Unrecognized type.
    otherwise
        error('multiScaleDiff:type', ['Type ''' type(1) ''' is' ...
            'not a recognized method for handling missing data'])
end

% Use the same type as X1 for X2.
if length(type) < 2
    type(2) = type(1);
end

% Determine the method to use when X2 is missing.
% Note: the differential is expressed as dX/dT = -(X1 - X2)/(T1 - T2)
switch type(2)
    
    % Do nothing (use the exact index).
    case 'e'
        use2 = @exactIndex;
        
        % Find the back nearest neighbor.
    case 'b'
        use2 = @backNeighbor;
        
        % Find the front nearest neighbor.
    case 'f'
        use2 = @frontNeighbor;
        
        % Find the nearest neighbor.
    case 'n'
        use2 = @nearestNeighbor;
        
        % Unrecognized type.
    otherwise
        error('multiScaleDiff:type', ['Type ''' type(1) ''' is' ...
            'not a recognized method for handling missing data'])
end

% Correct the data types.
if ~iscell(data)
    data = {data};
end
startI = double(startI);
endI = double(endI);
scales = double(scales);

% Pre-allocate memory.
maxScale = max(scales);
diffData = cell(length(data), 1);
usedFramesI = cell(length(scales), 1);

% Compute the sparse data differences.
if isSparse
    
    % Pre-allocate memory.
    numDataScales = floor((endI - startI) / maxScale) + 1;
    totalDiffSize = 1 + numDataScales * maxScale;
    X1I(1:totalDiffSize) = NaN;
    X2I(1:totalDiffSize) = NaN;
    
    % Initialize X1.
    if ~isAtT1
        X1I(1) = use1(startI, 0, use);
    end
    
    % Only compute X1 and X2 for the used scales.
    sScales = sort(scales);
    for i = 1:length(sScales)
        
        % Are we using a degenerate scale?
        if sScales(i) == 0
            continue;
        end
        
        % Have we already computed (a divisor of) this scale?
        nScales = [];
        if i > 1
            nScales = sScales(i) ./ sScales(1:(i - 1));
        end
        if isempty(nScales) || ~any(nScales == floor(nScales))
            
            % Initialize X1 and X2.
            if isAtT1
                startXI = maxScale + 1;
                startDataI = startI;
                
                % Start at X1 minus the scale.
                if sScales(i) < startI
                    X1I(startXI - sScales(i)) = ...
                        use1(startDataI - sScales(i), 0, use);
                    X2I(startXI) = use2(startDataI, 0, use);
                    
                % Start at X1.
                else
                    X1I(startXI - sScales(i)) = startI;
                    X2I(startXI) = startI;
                end
            
            % Initialize X2.
            else
                startXI = 1 + sScales(i);
                startDataI = startI + sScales(i);
                
                % Start at X1 plus the scale.
                if startDataI <= endI
                    X2I(startXI) = use2(startDataI, 0, use);
                    
                % Start and finish at X1 plus the scale.
                elseif startDataI <= length(use)
                    X2I(startXI) = use2(startDataI, 0, use);
                    continue;
                    
                % Start and finish at X1.
                else
                    X2I(startXI) = X1I(1);
                    continue;
                end
            end
            
            % Compute X1 and X2 for the scale.
            xI = startXI;
            prevXI = xI - sScales(i);
            nextXI = xI + sScales(i);
            dataI = startDataI;
            nextDataI = dataI + sScales(i);
            while nextDataI <= endI
                
                % Compute X1 and X2.
                X1I(xI) = use1(dataI, X1I(prevXI), use);
                X2I(nextXI) = use2(nextDataI, X2I(xI), use);
                
                % Advance.
                prevXI = xI;
                xI = nextXI;
                nextXI = nextXI + sScales(i);
                dataI = nextDataI;
                nextDataI = nextDataI + sScales(i);
            end
            
            % Compute the last X1 and X2 for the scale.
            if ~isAtT1
                
                % End at X2 plus the scale.
                if nextDataI <= length(use)
                    X1I(xI) = use1(dataI, X1I(prevXI), use);
                    X2I(nextXI) = use2(nextDataI, X2I(xI), use);
                    
                % End at X2.
                else
                    X1I(xI) = dataI;
                    X2I(nextXI) = dataI;
                end
            end
        end
    end

    % Compute the data differences.
    for j = 1:length(scales)
        
        % Compute the indices for X1 and X2.
        numDataScales = floor((endI - startI) / scales(j)) + 1;
        if isAtT1
            firstScalesI = (maxScale - scales(j) + 1);
            lastScalesI = firstScalesI + numDataScales * scales(j);
            scalesI = firstScalesI:scales(j):lastScalesI;
        else
            lastScalesI = 1 + numDataScales * scales(j);
            scalesI = 1:scales(j):lastScalesI;
        end
        dataSize = length(scalesI) - 1;
        sX1I = X1I(scalesI(1:(end - 1)));
        sX2I = X2I(scalesI(2:end));
        usedFramesI{j}(1,:) = sX1I;
        usedFramesI{j}(2,:) = sX2I;
            
        % Compute the data difference and divide by the time.
        for i = 1:length(data)
            diffs = [];
            diffs(size(data{i},1),1:dataSize) = NaN;
            diffs(:,1:dataSize) = data{i}(:,sX2I) - data{i}(:,sX1I);
            rates = (sX2I - sX1I) * rate;
            for k = 1:length(rates)
                if rates(k) ~= 0
                    diffs(:,k) = diffs(:,k) / rates(k);
                else
                    diffs(:,k) = NaN;
                end
            end
            diffData{i}{j} = diffs;
        end
    end
    
% Compute the non-sparse data differences.
else
    
    % Pre-allocate memory.
    totalDiffSize = endI - startI + 1 + maxScale;
    X1I(1:totalDiffSize) = NaN;
    X2I(1:totalDiffSize) = NaN;
    
    % Initialize X1 and X2.
    minScale = min(scales);
    if isAtT1
        startData1I = max(startI - maxScale, 1);
        initI = maxScale - (startI - startData1I);
        for i = 1:initI
            X1I(i) =  1;
            X2I(i + minScale) = 1;
        end
        startX1I = initI + 1;
        
    % Initialize X1.
    else
        startData1I = startI;
        startX1I = 1;
    end
    
    % Compute the first X1 and X2.
    startX2I = startX1I + minScale;
    startData2I = startData1I + minScale;
    X1I(startX1I) = use1(startData1I, 0, use);
    X2I(startX2I) = use2(startData2I, 0, use);
    
    % Only compute X1 and X2 for the used scales.
    endData2I = min(endI + maxScale, length(use));
    for i = 1:(endData2I - startData2I)
        X1I(startX1I + i) = ...
            use1(startData1I + i, X1I(startX1I + i - 1), use);
        X2I(startX2I + i) = ...
            use2(startData2I + i, X2I(startX2I + i - 1), use);
    end

    % Compute the last X1 and X2 for the scale.
    if ~isAtT1
        endX1I = startX1I + endData2I - startData2I;
        endX2I = endX1I + minScale;
        for i = 1:(endI + maxScale - length(use))
            X1I(endX1I + i) = endI;
            X2I(endX2I + i) = endI;
        end
    end
    
    % Compute the data differences.
    dataSize = endI - startI + 1;
    for j = 1:length(scales)
        
        % Compute the indices for X1 and X2.
        if isAtT1
            scaleOff = maxScale - scales(j);
            sX1I = X1I((1 + scaleOff):(dataSize + scaleOff));
            sX2I = X2I((1 + maxScale):(dataSize + maxScale));
        else
            sX1I = X1I(1:dataSize);
            sX2I = X2I((1 + scales(j)):(dataSize + scales(j)));
        end
        usedFramesI{j}(1,:) = sX1I;
        usedFramesI{j}(2,:) = sX2I;
            
        % Compute the data difference and divide by the time.
        for i = 1:length(data)
            diffs = [];
            diffs(size(data{i},1),1:dataSize) = NaN;
            diffs(:,1:dataSize) = data{i}(:,sX2I) - data{i}(:,sX1I);
            rates = (sX2I - sX1I) * rate;
            for k = 1:length(rates)
                if rates(k) ~= 0
                    diffs(:,k) = diffs(:,k) / rates(k);
                else
                    diffs(:,k) = NaN;
                end
            end
            diffData{i}{j} = diffs;
        end
    end
end
end

% Do nothing (return the exact index).
function i = exactIndex(i, ~, ~)
end

% Find the back nearest neighbor.
function i = backNeighbor(i, prevI, use)
while i > 1 && ~use(i) && i > prevI
    i = i - 1;
end
end

% Find the front nearest neighbor.
function i = frontNeighbor(i, prevI, use)
if i > prevI
    while i < length(use) && ~use(i)
        i = i + 1;
    end
    
% The previous index is the front nearest neighbor.
else
    i = prevI;
end
end

% Find the nearest neighbor.
function i = nearestNeighbor(i, ~, use)
maxJ = max(i, length(use) -  i + 1);
j = 0;
while j < maxJ
    
    % The nearest neighbor is in back.
    k = i - j;
    if k > 0 && use(k)
        i = k;
        break;
    end
    
    % The nearest neighbor is in front.
    k = i + j;
    if k <= length(use) && use(k)
        i = k;
        break;
    end
    
    % Advance.
    j = j + 1;
end
end
