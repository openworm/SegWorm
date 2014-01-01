function worm2 = orientWormPostCoil(worm1, worm2, varargin)
%ORIENTWORMPOSTCOIL Orient worm2 to match worm1's orientation (by setting
%   worm2.orientation.head.isFlipped
%   and worm2.orientation.vulva.isClockwiseFromHead) assuming:
%
%       a) the worm coiled between worm1 and worm2
%       b) the coiled worm traveled on a path through its maximal bends
%
% The algorithm is as follows:
%
% 1. If the worms are separated by a stage movement, use absolute
%    coordinates.
%
% 2. Both worms must have a concave contour bend less than -75 degrees and,
%    these contour bends must be closer than 1/12 (2 overlapping, muscle
%    segments) of the worm's skeleton length.
%
% 3. For each worm, find the skeleton point nearest to its minimal
%    contour bend (from step 1).
%
% 4. Find the midpoint between both worms' skeleton points (from step 2).
%    Then, for each worm, find the skeleton point nearest this midpoint.
%    This ensures we're comparing the same location along both worms'
%    skeleton's paths.
%
% 5. Take 2 points, 1/24 (1 muscle segment) in either direction from the
%    skeleton points (from step 3). The points must not hit the head nor
%    tail. Use these points to construct a vector approximately tangent to
%    the skeleton point from which they were measured.
%
% 6. If these vectors (from step 4) are nearly perpendicular, the worm may
%    have taken a complex path during the coil and we cannot orient worm 2.
%    Otherwise, assume the worm's path snaked through its bend and make
%    sure the vectors share the same direction as the worms' orientations.
%
%   WORM2 = ORIENTWORMPOSTCOIL(WORM1, WORM2)
%
%   WORM2 = ORIENTWORMPOSTCOIL(WORM1, WORM2, VERBOSE)
%
%   WORM2 = ORIENTWORMPOSTCOIL(WORM1, WORM2, MOVES, ORIGINS, 
%                              PIXEL2MICRONSCALE, ROTATION, VERBOSE)
%
%   Input:
%       worm1             - the reference worm
%       worm2             - the worm to orient relative to the reference
%       moves             - a 2-D matrix with, respectively, the start and
%                           end frame indices of stage movements
%                           (see findStageMovements, movesI)
%       origins           - the real-world micron origins (stage locations)
%                           for the worms; if empty, ignore stage movements
%                           (see findStageMovements, locations)
%       pixel2MicronScale - the scale for converting pixels to microns; if
%                           empty, ignore stage movements
%                           (see readPixels2Microns, pixel2MicronScale)
%       rotation          - the rotation matrix for onscreen pixels; if
%                           empty, ignore stage movements
%                           (see readPixels2Microns, rotation)
%       verbose           - verbose mode shows the results in a figure
%
%   Output:
%       worm2 - the oriented worm (with worm2.orientation.head.isFlipped
%               and worm2.orientation.vulva.isClockwiseFromHead correctly
%               set so that worm1 and worm2 share the same orientation);
%               or, empty if the worm cannot be oriented
%
% See also SEGWORM, FINDSTAGEMOVEMENT, READPIXELS2MICRONS, ORIENTWORM,
% ORIENTWORMATCENTROID
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we in verbose mode?
if length(varargin) > 4
    verbose = varargin{5};
    isOriented = true;
elseif ~isempty(varargin)
    verbose = varargin{1};
    isOriented = true;
else
    verbose = false;
end

% Are we using stage movements?
if length(varargin) >= 4
    moves = varargin{1};
    origins = varargin{2};
    pixel2MicronScale = varargin{3};
    rotation = varargin{4};
else
    moves = [];
    origins = [];
    pixel2MicronScale = [];
    rotation = [];
end

% The worm is roughly divided into 24 segments of musculature (i.e., hinges
% that represent degrees of freedom) on each side. Therefore, 48 segments
% around a 2-D contour.
% Note: "In C. elegans the 95 rhomboid-shaped body wall muscle cells are
% arranged as staggered pairs in four longitudinal bundles located in four
% quadrants. Three of these bundles (DL, DR, VR) contain 24 cells each,
% whereas VL bundle contains 23 cells." - www.wormatlas.org
sWormSegs = 24;
cWormSegs = 2 * sWormSegs;

% Does worm 1 have a sharp enough bend to coil?
minAngleThreshold = -75;
contour1 = worm1.contour;
skeleton1 = worm1.skeleton;
cWormSegLength1 = (contour1.chainCodeLengths(1) + ...
    contour1.chainCodeLengths(end)) / cWormSegs;
[minCA1 minCI1] = minPeaksCircDist(contour1.angles, ...
    2 * cWormSegLength1, contour1.chainCodeLengths);
minCI1 = minCI1(minCA1 < minAngleThreshold);
if isempty(minCI1)
    warning('orientWormPostCoil:Bend1', ['Worm 1''s contour has no' ...
        ' concave bends smaller than ' num2str(minAngleThreshold) ...
        ' and, therefore, is unlikely to coil']);
    if verbose
        isOriented = false;
        [~, minCI1] = min(minCA1);
    else
        worm2 = [];
        return;
    end
end

% Does worm 2 have a sharp enough bend to have coiled?
contour2 = worm2.contour;
skeleton2 = worm2.skeleton;
cWormSegLength2 = (contour2.chainCodeLengths(1) + ...
    contour2.chainCodeLengths(end)) / cWormSegs;
[minCA2 minCI2] = minPeaksCircDist(contour2.angles, ...
    2 * cWormSegLength2, contour2.chainCodeLengths);
minCI2 = minCI2(minCA2 < minAngleThreshold);
if isempty(minCI2)
    warning('orientWormPostCoil:Bend2', ['Worm 2''s contour has no' ...
        ' concave bends smaller than ' num2str(minAngleThreshold) ...
        ' and, therefore, is unlikely to have coiled']);
    if verbose
        isOriented = false;
        [~, minCI2] = min(minCA2);
    else
        worm2 = [];
        return;
    end
end

% Are the worms separated by a stage movement?
isStageMove = false;
if ~(isempty(moves) || isempty(origins) || ...
        isempty(pixel2MicronScale) || isempty(rotation))
    
    % Find worm 1's origin.
    i = 1;
    while i < size(moves,1) && worm1.video.frame >= moves(i + 1,2)
        i = i + 1;
    end
    
    % Find worm 2's origin.
    if worm2.video.frame >= worm1.video.frame
        j = i;
    else
        j = 1;
    end
    while j < size(moves,1) && worm2.video.frame >= moves(j + 1,2)
        j = j + 1;
    end
    
    % Are the worms separated by a stage movement?
    if i ~= j
        isStageMove = true;
        
        % Convert the worms to absolute coordinates.
        % Note: for convenience, we use image coordinates (row and column)
        % rather than Euclidean coordinates (x and y).
        fPixel2MicronScale = fliplr(pixel2MicronScale);
        fRotation = rotation';
        contour1.pixels = pixels2Microns(fliplr(origins(i,:)), ...
            contour1.pixels, fPixel2MicronScale, fRotation);
        skeleton1.pixels = pixels2Microns(fliplr(origins(i,:)), ...
            skeleton1.pixels, fPixel2MicronScale, fRotation);
        contour2.pixels = pixels2Microns(fliplr(origins(j,:)), ...
            contour2.pixels, fPixel2MicronScale, fRotation);
        skeleton2.pixels = pixels2Microns(fliplr(origins(j,:)), ...
            skeleton2.pixels, fPixel2MicronScale, fRotation);
%         contour1.pixels = fliplr(pixels2Microns(origins(i,:), ...
%             fliplr(contour1.pixels), pixel2MicronScale, rotation));
%         skeleton1.pixels = fliplr(pixels2Microns(origins(i,:), ...
%             fliplr(skeleton1.pixels), pixel2MicronScale, rotation));
%         contour2.pixels = fliplr(pixels2Microns(origins(j,:), ...
%             fliplr(contour2.pixels), pixel2MicronScale, rotation));
%         skeleton2.pixels = fliplr(pixels2Microns(origins(j,:), ...
%             fliplr(skeleton2.pixels), pixel2MicronScale, rotation));
    end
end

% Are the worm bends close enough to be correlated?
sWormSegLength = (skeleton1.chainCodeLengths(end) + ...
    skeleton2.chainCodeLengths(end)) / (2 * sWormSegs);
distanceThreshold = (sWormSegLength * 2) ^ 2;
if isStageMove
    distanceThreshold = distanceThreshold * sum(pixel2MicronScale .^ 2);
end
isFarBends = true;
for i = 1:length(minCI1)
    for j = 1:length(minCI2)
        minCP1 = contour1.pixels(minCI1(i),:);
        minCP2 = contour2.pixels(minCI2(j),:);
        if sum((minCP1 - minCP2) .^ 2) < distanceThreshold
            isFarBends = false;
            break;
        end
    end
end
if isFarBends
    warning('orientWormPostCoil:BendsTooFar', ...
        'The worms'' contour bends are too far apart to be correlated');
    if verbose
        isOriented = false;
    else
        worm2 = [];
        return;
    end
end

% Find the nearest skeleton point to each bend.
[~, sI1] = min((skeleton1.pixels(:,1) - minCP1(1)) .^ 2 + ...
    (skeleton1.pixels(:,2) - minCP1(2)) .^ 2);
[~, sI2] = min((skeleton2.pixels(:,1) - minCP2(1)) .^ 2 + ...
    (skeleton2.pixels(:,2) - minCP2(2)) .^ 2);

% Find the nearest skeleton points to the midpoint between both bends.
midBPixels = (skeleton1.pixels(sI1,:) + skeleton2.pixels(sI2,:)) / 2;
[~, sI1] = min((skeleton1.pixels(:,1) - midBPixels(1)) .^ 2 + ...
    (skeleton1.pixels(:,2) - midBPixels(2)) .^ 2);
[~, sI2] = min((skeleton2.pixels(:,1) - midBPixels(1)) .^ 2 + ...
    (skeleton2.pixels(:,2) - midBPixels(2)) .^ 2);

% Find the tangent direction at worm 1's nearest skeleton point.
startSL1 = skeleton1.chainCodeLengths(sI1) - sWormSegLength;
if startSL1 <= 0
    warning('orientWormPostCoil:Bend1AtEnd', ...
        'Worm 1''s contour bend is too close to its head or tail');
    if verbose
        startSI1 = 1;
        isOriented = false;
    else
        worm2 = [];
        return;
    end
else
    startSI1 = chainCodeLength2Index(startSL1, skeleton1.chainCodeLengths);
end
startSP1 = skeleton1.pixels(startSI1,:);
endSL1 = skeleton1.chainCodeLengths(sI1) + sWormSegLength;
if endSL1 >= skeleton1.chainCodeLengths(end)
    warning('orientWormPostCoil:Bend1AtEnd', ...
        'Worm 1''s contour bend is too close to its head or tail');
    if verbose
        endSI1 = length(skeleton1.chainCodeLengths);
        isOriented = false;
    else
        worm2 = [];
        return;
    end
else
    endSI1 = chainCodeLength2Index(endSL1, skeleton1.chainCodeLengths);
end
endSP1 = skeleton1.pixels(endSI1,:);
vector1 = endSP1 - startSP1;
dir1 = atan2(vector1(1), vector1(2));

% Find the tangent direction at worm 2's nearest skeleton point.
startSL2 = skeleton2.chainCodeLengths(sI2) - sWormSegLength;
if startSL2 <= 0
    warning('orientWormPostCoil:Bend1AtEnd', ...
        'Worm 2''s contour bend is too close to its head or tail');
    if verbose
        startSI2 = 1;
        isOriented = false;
    else
        worm2 = [];
        return;
    end
else
    startSI2 = chainCodeLength2Index(startSL2, skeleton2.chainCodeLengths);
end
startSP2 = skeleton2.pixels(startSI2,:);
endSL2 = skeleton2.chainCodeLengths(sI2) + sWormSegLength;
if endSL2 >= skeleton2.chainCodeLengths(end)
    warning('orientWormPostCoil:Bend1AtEnd', ...
        'Worm 2''s contour bend is too close to its head or tail');
    if verbose
        endSI2 = length(skeleton2.chainCodeLengths);
        isOriented = false;
    else
        worm2 = [];
        return;
    end
else
    endSI2 = chainCodeLength2Index(endSL2, skeleton2.chainCodeLengths);
end
endSP2 = skeleton2.pixels(endSI2,:);
vector2 = endSP2 - startSP2;
dir2 = atan2(vector2(1), vector2(2));

% Are the worms in the same orientation?
isSameOrient = true;
if worm1.orientation.head.isFlipped ~= worm2.orientation.head.isFlipped
    isSameOrient = false;
end

% Are the worms facing the same direction?
dDirs = dir1 - dir2;
if dDirs > pi
    dDirs = dDirs - 2 * pi;
elseif dDirs < -pi
    dDirs = dDirs + 2 * pi;
end
dDirs = abs(dDirs);
if dDirs > pi * (3 / 8) && dDirs < pi * (5 / 8)
    warning('orientWormPostCoil:Directions', ['The worm skeletons are ' ...
        'nearly perpendicular to each other at their bends']);
    if verbose
        isOriented = false;
    else
        worm2 = [];
        return;
    end
end
isSameDirs = true;
if dDirs > pi / 2
    isSameDirs = false;
end

% Orient worm 2 to face the same direction as worm 1.
if isSameOrient ~= isSameDirs
    worm2 = flipWormHead(worm2);
end

% Flip the vulval side.
if worm2.orientation.vulva.isClockwiseFromHead ~= ...
    worm1.orientation.vulva.isClockwiseFromHead
    worm2 = flipWormVulva(worm2);
end

% Show the results in a figure.
if verbose
    
    % Construct a pattern to identify the head.
    hImg = [1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1];
    [hPattern(:,1) hPattern(:,2)] = find(hImg == 1);
    hPattern(:,1) = hPattern(:,1) - ceil(size(hImg, 1) / 2);
    hPattern(:,2) = hPattern(:,2) - ceil(size(hImg, 2) / 2);
    
    % Construct the values for the contour and skeleton curvature heat map.
    intensity = .7;
    if isStageMove
        intensity = 0;
    end
    zeros361 = zeros(361, 1);
    c361(1:361,1) = intensity;
    cRGB = [c361, zeros361, zeros361]; % red
    hRGB = [intensity 0 0]; % red
    
    % Copy the worms for verbose mode.
    vWorm1 = worm1;
    vWorm1.contour.pixels = round(contour1.pixels);
    vWorm1.skeleton.pixels = round(skeleton1.pixels);
    vWorm2 = worm2;
    vWorm2.contour.pixels = round(contour2.pixels);
    vWorm2.skeleton.pixels = round(skeleton2.pixels);
    
    % Determine the worms' MER (minimum enclosing rectangle).
    % Note: the skeleton can exit the contour.
    wMinX = min(min(vWorm1.contour.pixels(:,2)), ...
        min(vWorm1.skeleton.pixels(:,2)));
    wMaxX = max(max(vWorm1.contour.pixels(:,2)), ...
        max(vWorm1.skeleton.pixels(:,2)));
    wMinY = min(min(vWorm1.contour.pixels(:,1)), ...
        min(vWorm1.skeleton.pixels(:,1)));
    wMaxY = max(max(vWorm1.contour.pixels(:,1)), ...
        max(vWorm1.skeleton.pixels(:,1)));
    wMinX = min([wMinX, min(vWorm2.contour.pixels(:,2)), ...
        min(vWorm2.skeleton.pixels(:,2))]);
    wMaxX = max([wMaxX, max(vWorm2.contour.pixels(:,2)), ...
        max(vWorm2.skeleton.pixels(:,2))]);
    wMinY = min([wMinY, min(vWorm2.contour.pixels(:,1)), ...
        min(vWorm2.skeleton.pixels(:,1))]);
    wMaxY = max([wMaxY, max(vWorm2.contour.pixels(:,1)), ...
        max(vWorm2.skeleton.pixels(:,1))]);
    
    % Minimize the worms.
    vWorm1.contour.pixels(:,1) = vWorm1.contour.pixels(:,1) - wMinY + 3;
    vWorm1.contour.pixels(:,2) = vWorm1.contour.pixels(:,2) - wMinX + 3;
    vWorm1.skeleton.pixels(:,1) = vWorm1.skeleton.pixels(:,1) - wMinY + 3;
    vWorm1.skeleton.pixels(:,2) = vWorm1.skeleton.pixels(:,2) - wMinX + 3;
    vWorm2.contour.pixels(:,1) = vWorm2.contour.pixels(:,1) - wMinY + 3;
    vWorm2.contour.pixels(:,2) = vWorm2.contour.pixels(:,2) - wMinX + 3;
    vWorm2.skeleton.pixels(:,1) = vWorm2.skeleton.pixels(:,1) - wMinY + 3;
    vWorm2.skeleton.pixels(:,2) = vWorm2.skeleton.pixels(:,2) - wMinX + 3;
    
    % Construct the worms' images.
    emptyImg = ones(wMaxY - wMinY + 5, wMaxX - wMinX + 5);
    img1 = overlayWormAngles(emptyImg, vWorm1, cRGB, [], [], ...
        hPattern, hRGB, 1, [], [], 1);
    img2 = overlayWormAngles(emptyImg, vWorm2, cRGB, [], [], ...
        hPattern, hRGB, 1, [], [], 1);
    
    % Overlay the worm images.
    rImg = img2(:,:,1);
    gImg = img1(:,:,1);
    bImg = rImg;
    bImg(gImg == intensity) = intensity;
    sImgI1 = sub2ind(size(rImg), vWorm1.skeleton.pixels(sI1,1), ...
        vWorm1.skeleton.pixels(sI1,2));
    rImg(sImgI1) = intensity;
    gImg(sImgI1) = 0;
    bImg(sImgI1) = 0;
    sImgI2 = sub2ind(size(rImg), vWorm2.skeleton.pixels(sI2,1), ...
        vWorm2.skeleton.pixels(sI2,2));
    rImg(sImgI2) = 0;
    gImg(sImgI2) = intensity;
    bImg(sImgI2) = 0;
    rgbImg(:,:,1) = rImg;
    if isStageMove
        rgbImg(:,:,2) = bImg;
        rgbImg(:,:,3) = gImg;
    else
        rgbImg(:,:,2) = gImg;
        rgbImg(:,:,3) = bImg;
    end
    
    % Show the overlay.
    figure;
    imshow(rgbImg);
    if isStageMove
        title(['\color{blue}Stage Movement -> Worm 2 (frame = ' ...
            num2str(vWorm2.video.frame) ')']);
    else
        title(['\color{darkgreen}Worm 2 (frame = ' ...
            num2str(vWorm2.video.frame) ')']);
    end
    ylabel(['\color{red}Worm 1 (frame = ' num2str(vWorm1.video.frame) ')']);
    
    % Show the vectors.
    hold on;
    quiver(vWorm1.skeleton.pixels(startSI1,2), ...
        vWorm1.skeleton.pixels(startSI1,1), ...
        vector1(:,2), vector1(:,1), 0, 'r');
    if isStageMove
        quiver(vWorm2.skeleton.pixels(startSI2,2), ...
            vWorm2.skeleton.pixels(startSI2,1), ...
            vector2(:,2), vector2(:,1), 0, 'b');
    else
        quiver(vWorm2.skeleton.pixels(startSI2,2), ...
            vWorm2.skeleton.pixels(startSI2,1), ...
            vector2(:,2), vector2(:,1), 0, 'g');
    end
    
    % Was worm 2 oriented?
    if ~isOriented
        xlabel('\color{orange}ORIENTATION FAILED!');
        worm2 = [];
    end
end
end
