function [skeleton cWidths] = skeletonize2(s1, e1, i1, s2, e2, i2, c1, c2, ...
    isAcross)
%SKELETONIZE2 Skeletonize takes the 2 pairs of start and end points on a
%contour(s), then traces the skeleton between them using the specified
%increments.
%
%   [SKELETON CWIDTHS] = SKELETONIZE2(S1, E1, I1, S2, E2, I2, C1, C2)
%
%   Inputs:
%       s1       - The starting index for the first contour segment.
%       e1       - The ending index for the first contour segment.
%       i1       - The increment to walk along the first contour segment.
%                  Note: a negative increment means walk backwards.
%                  Contours are circular, hitting an edge wraps around.
%       s2       - The starting index for the second contour segment.
%       e2       - The ending index for the second contour segment.
%       i2       - The increment to walk along the second contour segment.
%                  Note: a negative increment means walk backwards.
%                  Contours are circular, hitting an edge wraps around.
%       c1       - The contour for the first segment.
%       c2       - The contour for the second segment.
%       isAcross - Does the skeleton cut across, connecting s1 with e2?
%                  Otherwise, the skeleton simply traces the midline
%                  between both contour segments.
%
%   Output:
%       skeleton - the skeleton traced between the 2 sets of contour points.
%       cWidths  - the widths between the 2 sets of contour points.
%                  Note: there are no widths when cutting across.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% The first starting index is before the ending one.
ws1 = [];
if s1 <= e1
    
    % We are going forward.
    if i1 > 0
        size1 = (e1 - s1 + 1) / i1;
        
    % We are wrapping backward.
    else
        ws1 = s1;
        we1 = size(c1, 1) - e1 + 1;
        size1 = (ws1 + we1) / i1;
    end
    
% The first starting index is after the ending one.
else
    % We are going backward.
    if i1 < 0
        size1 = (s1 - e1 + 1) / i1;

    % We are wrapping forward.
    else
        ws1 = size(c1, 1) - s1 + 1;
        we1 = e1;
        size1 = (ws1 + we1) / i1;
    end
end

% The second starting index is before the ending one.
ws2 = [];
if s2 <= e2
    
    % We are going forward.
    if i2 > 0
        size2 = (e2 - s2 + 1) / i2;
        
    % We are wrapping backward.
    else
        ws2 = s2;
        we2 = size(c2, 1) - e2 + 1;
        size2 = (ws2 + we2) / i2;
    end
    
% The second starting index is after the ending one.
else
    % We are going backward.
    if i2 < 0
        size2 = (s2 - e2 + 1) / i2;

    % We are wrapping forward.
    else
        ws2 = size(c2, 1) - s2 + 1;
        we2 = e2;
        size2 = (ws2 + we2) / i2;
    end
end

% How many skeleton points do we have?
points = max(abs(size1), abs(size2));
i1 = size1 / points;
i2 = size2 / points;

% Initialize the starting indices to work with the offsets.
s1 = s1 - i1;
s2 = s2 - i2;

% Initialize the first contour's wrapping, starting sections to work with
% wrapped offsets.
if ~isempty(ws1)
    if i1 > 0
        
        % Initialize the wrapped offset.
        o1 = -size(c1, 1);
        
        % Determine the number of points till we wrap.
        % Note: IEEE floating-point issues force us to use the same
        % equation, both here and when we wrap, to avoid rounding errors.
        ws1 = floor((ws1 - 0.5) / i1) + 1;
        if round(s1 + ws1 * i1) > -o1
            ws1 = ws1 - 1;
        end
    else
        % Initialize the wrapped offset.
        o1 = size(c1, 1);

        % Determine the number of points till we wrap.
        % Note: IEEE floating-point issues force us to use the same
        % equation, both here and when we wrap, to avoid rounding errors.
        ws1 = floor((ws1 - 0.5) / -i1) + 1;
        if round(s1 + ws1 * i1) < 1
            ws1 = ws1 - 1;
        end
    end
end

% Initialize the second contour's wrapping, starting sections to work with
% wrapped offsets.
if ~isempty(ws2)
    if i2 > 0
        
        % Initialize the wrapped offset.
        o2 = -size(c2, 1);
        
        % Determine the number of points till we wrap.
        % Note: IEEE floating-point issues force us to use the same
        % equation, both here and when we wrap, to avoid rounding errors.
        ws2 = floor((ws2 - 0.5) / i2) + 1;
        if round(s2 + ws2 * i2) > -o2
            ws2 = ws2 - 1;
        end
    else
        % Initialize the wrapped offset.
        o2 = size(c2, 1);

        % Determine the number of points till we wrap.
        % Note: IEEE floating-point issues force us to use the same
        % equation, both here and when we wrap, to avoid rounding errors.
        ws2 = floor((ws2 - 0.5) / -i2) + 1;
        if round(s2 + ws2 * i2) < 1
            ws2 = ws2 - 1;
        end
    end
end

% Trace the midline between the contour segments.
skeleton = zeros(points, 2); % pre-allocate memory
cWidths = []; % there are no widths when cutting across
if ~isAcross
    cWidths = zeros(points, 1); % pre-allocate memory
    
    % We don't wrap.
    if isempty(ws1) && isempty(ws2)
        i = 1:points;
        skeleton(i,:) = (c1(round(s1 + i * i1),:) + ...
            c2(round(s2 + i * i2),:)) / 2;
        cWidths(i) = sqrt(sum((c1(round(s1 + i * i1),:) - ...
            c2(round(s2 + i * i2),:)) .^ 2, 2));
        
    % The first index wraps.
    elseif isempty(ws2)
        i = 1:ws1;
        skeleton(i,:) = (c1(round(s1 + i * i1),:) + ...
            c2(round(s2 + i * i2),:)) / 2;
        cWidths(i) = sqrt(sum((c1(round(s1 + i * i1),:) - ...
            c2(round(s2 + i * i2),:)) .^ 2, 2));
        
        % Wrap the first index.
        i = (i(end) + 1):points;
        skeleton(i,:) = (c1(round(s1 + i * i1) + o1,:) + ...
            c2(round(s2 + i * i2),:)) / 2;
        cWidths(i) = sqrt(sum((c1(round(s1 + i * i1) + o1,:) - ...
            c2(round(s2 + i * i2),:)) .^ 2, 2));
        
    % The second index wraps.
    elseif isempty(ws1)
        i = 1:ws2;
        skeleton(i,:) = (c1(round(s1 + i * i1),:) + ...
            c2(round(s2 + i * i2),:)) / 2;
        cWidths(i) = sqrt(sum((c1(round(s1 + i * i1),:) - ...
            c2(round(s2 + i * i2),:)) .^ 2, 2));
        
        % Wrap the second index.
        i = (i(end) + 1):points;
        skeleton(i,:) = (c1(round(s1 + i * i1),:) + ...
            c2(round(s2 + i * i2) + o2,:)) / 2;
        cWidths(i) = sqrt(sum((c1(round(s1 + i * i1),:) - ...
            c2(round(s2 + i * i2) + o2,:)) .^ 2, 2));
        
    % Both inidices wrap.
    else
        
        % Who wraps first?
        [minWS isMinWS2] = min([ws1 ws2]);
        isMinWS2 = isMinWS2 - 1;
        i = 1:minWS;
        skeleton(i,:) = (c1(round(s1 + i * i1),:) + ...
            c2(round(s2 + i * i2),:)) / 2;
        cWidths(i) = sqrt(sum((c1(round(s1 + i * i1),:) - ...
            c2(round(s2 + i * i2),:)) .^ 2, 2));
        
        % Wrap the second index.
        if isMinWS2
            i = (i(end) + 1):ws1;
            skeleton(i,:) = (c1(round(s1 + i * i1),:) + ...
                c2(round(s2 + i * i2) + o2,:)) / 2;
            cWidths(i) = sqrt(sum((c1(round(s1 + i * i1),:) - ...
                c2(round(s2 + i * i2) + o2,:)) .^ 2, 2));
            
            % Wrap the first index.
        else
            i = (i(end) + 1):ws2;
            skeleton(i,:) = (c1(round(s1 + i * i1) + o1,:) + ...
                c2(round(s2 + i * i2),:)) / 2;
            cWidths(i) = sqrt(sum((c1(round(s1 + i * i1) + o1,:) - ...
                c2(round(s2 + i * i2),:)) .^ 2, 2));
        end
        
        % Wrap both indices.
        i = (i(end) + 1):points;
        skeleton(i,:) = (c1(round(s1 + i * i1) + o1,:) + ...
            c2(round(s2 + i * i2) + o2,:)) / 2;
        cWidths(i) = sqrt(sum((c1(round(s1 + i * i1) + o1,:) - ...
            c2(round(s2 + i * i2) + o2,:)) .^ 2, 2));
    end

% The skeleton cuts across, connecting s1 with e2.
else
    
    % Setup the weights from s1 to e2.
    weights = 2 * (points - (1:points)) / (points - 1);
    w1 = [weights; weights]';
    w2 = flipud(w1);
    
    % We don't wrap.
    if isempty(ws1) && isempty(ws2)
        i = 1:points;
        skeleton(i,:) = (w1 .* c1(round(s1 + i * i1),:) + ...
            w2 .* c2(round(s2 + i * i2),:)) / 2;
        
    % The first index wraps.
    elseif isempty(ws2)
        i = 1:ws1;
        skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1),:) + ...
            w2(i,:) .* c2(round(s2 + i * i2),:)) / 2;
        
        % Wrap the first index.
        i = (i(end) + 1):points;
        skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1) + o1,:) + ...
            w2(i,:) .* c2(round(s2 + i * i2),:)) / 2;
        
    % The second index wraps.
    elseif isempty(ws1)
        i = 1:ws2;
        skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1),:) + ...
            w2(i,:) .* c2(round(s2 + i * i2),:)) / 2;
        
        % Wrap the second index.
        i = (i(end) + 1):points;
        skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1),:) + ...
            w2(i,:) .* c2(round(s2 + i * i2) + o2,:)) / 2;
        
    % Both inidices wrap.
    else
        
        % Who wraps first?
        [minWS isMinWS2] = min([ws1 ws2]);
        isMinWS2 = isMinWS2 - 1;
        i = 1:minWS;
        skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1),:) + ...
            w2(i,:) .* c2(round(s2 + i * i2),:)) / 2;
        
        % Wrap the second index.
        if isMinWS2
            i = (i(end) + 1):ws1;
            skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1),:) + ...
                w2(i,:) .* c2(round(s2 + i * i2) + o2,:)) / 2;
            
            % Wrap the first index.
        else
            i = (i(end) + 1):ws2;
            skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1) + o1,:) + ...
                w2(i,:) .* c2(round(s2 + i * i2),:)) / 2;
        end
        
        % Wrap both indices.
        i = (i(end) + 1):points;
        skeleton(i,:) = (w1(i,:) .* c1(round(s1 + i * i1) + o1,:) + ...
            w2(i,:) .* c2(round(s2 + i * i2) + o2,:)) / 2;
    end
end
end
