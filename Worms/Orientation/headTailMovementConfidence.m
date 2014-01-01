function [headOrthoConfidence tailOrthoConfidence ...
    headParaConfidence tailParaConfidence ...
    headMagConfidence tailMagConfidence] = ...
    headTailMovementConfidence(worm1, worm2, varargin)
%HEADTAILMOVEMENTCONFIDENCE How much confidence do we have in the head and
%   tail assignment based on their movement in successive frames?
%
%   Note: both frames must share the same worm orientation (see ORIENTWORM).
%
%   [HEADORTHOCONFIDENCE TAILORTHOCONFIDENCE
%    HEADPARACONFIDENCE TAILPARACONFIDENCE
%    HEADMAGCONFIDENCE TAILMAGCONFIDENCE] =
%       HEADTAILMOVEMENTCONFIDENCE(WORM1, WORM2)
%
%   Inputs:
%       worm1 - the worm from the first frame
%       worm2 - the worm from the successive frame (oriented relative to
%               worm1 -- see ORIENTWORM)
%       verbose - verbose mode shows the worms in a figure
%
%   Output:
%       headOrthoConfidence - how much confidence do we have in the head
%                             choice as the worm's head based on its
%                             orthogonal (side-to-side) movement in these
%                             successive frames? 
%       tailOrthoConfidence - how much confidence do we have in the tail
%                             choice as the worm's head based on its
%                             orthogonal (side-to-side) movement in these
%                             successive frames? 
%       headParaConfidence  - how much confidence do we have in the head
%                             choice as the worm's head based on its
%                             parallel (back-to-front) movement in these
%                             successive frames? 
%       tailParaConfidence  - how much confidence do we have in the tail
%                             choice as the worm's head based on its
%                             parallel (back-to-front) movement in these
%                             successive frames?
%       headMagConfidence   - how much confidence do we have in the head
%                             choice as the worm's head based on its
%                             movement magnitude in these successive
%                             frames? 
%       tailMagConfidence   - how much confidence do we have in the tail
%                             choice as the worm's head based on its
%                             movement magnitude in these successive
%                             frames? 
%
%   See also SEGWORM, ORIENTWORM, ORIENTWORMATCENTROID, ORIENTWORMPOSTCOIL
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we in verbose mode?
if isempty(varargin)
    verbose = false;
else
    verbose = varargin{1};
end

% Find 3 points on worm 1's head and tail.
% Note: the point indices decrease distally from their respective ends.
skeleton1 = worm1.skeleton;
pixels1 = skeleton1.pixels;
ccLengths1 = skeleton1.chainCodeLengths;
head1 = worm1.head;
tail1 = worm1.tail;
hBounds1 = head1.bounds.skeleton;
hPixels1(3,:) = pixels1(hBounds1(1),:);
hPixels1(2,:) = chainCodeLengthInterp(pixels1, ...
    (ccLengths1(hBounds1(1)) + ccLengths1(hBounds1(2))) / 2, ccLengths1);
hPixels1(1,:) = pixels1(hBounds1(2),:);
tBounds1 = tail1.bounds.skeleton;
tPixels1(3,:) = pixels1(tBounds1(2),:);
tPixels1(2,:) = chainCodeLengthInterp(pixels1, ...
    (ccLengths1(tBounds1(1)) + ccLengths1(tBounds1(2))) / 2, ccLengths1);
tPixels1(1,:) = pixels1(tBounds1(1),:);
if worm1.orientation.head.isFlipped
    tmp = hPixels1;
    hPixels1 = tPixels1;
    tPixels1 = tmp;
end

% Compute the origin.
ohVector = mean(diff(hPixels1));
ohAngle = atan2(ohVector(1), ohVector(2));
otVector = mean(diff(tPixels1));
otAngle = atan2(otVector(1), otVector(2));

% Find 3 points on worm 2's head and tail.
% Note: the point indices decrease distally from their respective ends.
skeleton2 = worm2.skeleton;
pixels2 = skeleton2.pixels;
ccLengths2 = skeleton2.chainCodeLengths;
head2 = worm2.head;
tail2 = worm2.tail;
hBounds2 = head2.bounds.skeleton;
hPixels2(3,:) = pixels2(hBounds2(1),:);
hPixels2(2,:) = chainCodeLengthInterp(pixels2, ...
    (ccLengths2(hBounds2(1)) + ccLengths2(hBounds2(2))) / 2, ccLengths2);
hPixels2(1,:) = pixels2(hBounds2(2),:);
tBounds2 = tail2.bounds.skeleton;
tPixels2(3,:) = pixels2(tBounds2(2),:);
tPixels2(2,:) = chainCodeLengthInterp(pixels2, ...
    (ccLengths2(tBounds2(1)) + ccLengths2(tBounds2(2))) / 2, ccLengths2);
tPixels2(1,:) = pixels2(tBounds2(1),:);
if worm2.orientation.head.isFlipped
    tmp = hPixels2;
    hPixels2 = tPixels2;
    tPixels2 = tmp;
end

% Compute the differential.
dhVectors = hPixels2 - hPixels1;
dhAngles = atan2(dhVectors(:,1), dhVectors(:,2));
dtVectors = tPixels2 - tPixels1;
dtAngles = atan2(dtVectors(:,1), dtVectors(:,2));

% Compute worm 2's directions relative to worm 1.
hAngles = dhAngles - ohAngle;
wrap = hAngles > pi;
hAngles(wrap) = hAngles(wrap) - 2 * pi;
wrap = hAngles < -pi;
hAngles(wrap) = hAngles(wrap) + 2 * pi;
tAngles = dtAngles - otAngle;
wrap = tAngles > pi;
tAngles(wrap) = tAngles(wrap) - 2 * pi;
wrap = tAngles < -pi;
tAngles(wrap) = tAngles(wrap) + 2 * pi;

% Compute the parallel and orthogonal vector components.
dhMags = sqrt(sum(dhVectors .^ 2, 2));
dhOrthos = dhMags .* sin(hAngles);
dhParas = dhMags .* cos(abs(hAngles));
dtMags = sqrt(sum(dtVectors .^ 2, 2));
dtOrthos = dtMags .* sin(tAngles);
dtParas = dtMags .* cos(abs(tAngles));

% Compute the head vs. tail confidence.
headOrthoConfidence = abs(mean(dhOrthos));
tailOrthoConfidence = abs(mean(dtOrthos));
headParaConfidence = mean(dhParas);
tailParaConfidence = mean(dtParas);
headMagConfidence = mean(dhMags);
tailMagConfidence = mean(dtMags);

% Show the worms.
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
    
    % Construct a pattern to identify the vulva.
    vImg = [0 0 1 0 0; ...
            0 1 1 1 0; ...
            1 1 1 1 1; ...
            0 1 1 1 0; ...
            0 0 1 0 0];
    [vPattern(:,1) vPattern(:,2)] = find(vImg == 1);
    vPattern(:,1) = vPattern(:,1) - ceil(size(vImg, 1) / 2);
    vPattern(:,2) = vPattern(:,2) - ceil(size(vImg, 2) / 2);
    
    % Construct the values for the contour and skeleton curvature heat map.
    intensity = .7;
    zeros361 = zeros(361, 1);
    c361(1:361,1) = intensity;
    cRGB = [c361, zeros361, zeros361]; % red
    hRGB = [intensity 0 0]; % red
    vRGB = [intensity 0 0]; % red
    
    % Compute the parallel and orthogonal head pixels.
    hParaPixels(:,2) = hPixels1(:,2) + dhParas .* cos(ohAngle);
    hParaPixels(:,1) = hPixels1(:,1) + dhParas .* sin(ohAngle);
    ohOrthoAngle = ohAngle + pi / 2;
    hOrthoPixels(:,2) = hPixels1(:,2) + dhOrthos .* cos(ohOrthoAngle);
    hOrthoPixels(:,1) = hPixels1(:,1) + dhOrthos .* sin(ohOrthoAngle);

    % Compute the parallel and orthogonal tail pixels.
    tParaPixels(:,2) = tPixels1(:,2) + dtParas .* cos(otAngle);
    tParaPixels(:,1) = tPixels1(:,1) + dtParas .* sin(otAngle);
    otOrthoAngle = otAngle + pi / 2;
    tOrthoPixels(:,2) = tPixels1(:,2) + dtOrthos .* cos(otOrthoAngle);
    tOrthoPixels(:,1) = tPixels1(:,1) + dtOrthos .* sin(otOrthoAngle);
    
    % Determine the worms' MER (minimum enclosing rectangle).
    % Note: the skeleton can exit the contour.
    wMinX = min(min(worm1.contour.pixels(:,2)), ...
        min(worm1.skeleton.pixels(:,2)));
    wMaxX = max(max(worm1.contour.pixels(:,2)), ...
        max(worm1.skeleton.pixels(:,2)));
    wMinY = min(min(worm1.contour.pixels(:,1)), ...
        min(worm1.skeleton.pixels(:,1)));
    wMaxY = max(max(worm1.contour.pixels(:,1)), ...
        max(worm1.skeleton.pixels(:,1)));
    wMinX = min([wMinX, min(worm2.contour.pixels(:,2)), ...
        min(worm2.skeleton.pixels(:,2))]);
    wMaxX = max([wMaxX, max(worm2.contour.pixels(:,2)), ...
        max(worm2.skeleton.pixels(:,2))]);
    wMinY = min([wMinY, min(worm2.contour.pixels(:,1)), ...
        min(worm2.skeleton.pixels(:,1))]);
    wMaxY = max([wMaxY, max(worm2.contour.pixels(:,1)), ...
        max(worm2.skeleton.pixels(:,1))]);
    rhParaPixels = round(hParaPixels);
    rhOrthoPixels = round(hOrthoPixels);
    rtParaPixels = round(tParaPixels);
    rtOrthoPixels = round(tOrthoPixels);
    wMinX = min([wMinX, min(rhParaPixels(:,2)), min(rhOrthoPixels(:,2)), ...
        min(rtParaPixels(:,2)), min(rtOrthoPixels(:,2))]);
    wMaxX = max([wMaxX, max(rhParaPixels(:,2)), max(rhOrthoPixels(:,2)), ...
        max(rtParaPixels(:,2)), max(rtOrthoPixels(:,2))]);
    wMinY = min([wMinY, min(rhParaPixels(:,1)), min(rhOrthoPixels(:,1)), ...
        min(rtParaPixels(:,1)), min(rtOrthoPixels(:,1))]);
    wMaxY = max([wMaxY, max(rhParaPixels(:,1)), max(rhOrthoPixels(:,1)), ...
        max(rtParaPixels(:,1)), max(rtOrthoPixels(:,1))]);
    
    % Minimize the worms.
    worm1.contour.pixels(:,1) = worm1.contour.pixels(:,1) - wMinY + 3;
    worm1.contour.pixels(:,2) = worm1.contour.pixels(:,2) - wMinX + 3;
    worm1.skeleton.pixels(:,1) = worm1.skeleton.pixels(:,1) - wMinY + 3;
    worm1.skeleton.pixels(:,2) = worm1.skeleton.pixels(:,2) - wMinX + 3;
    worm2.contour.pixels(:,1) = worm2.contour.pixels(:,1) - wMinY + 3;
    worm2.contour.pixels(:,2) = worm2.contour.pixels(:,2) - wMinX + 3;
    worm2.skeleton.pixels(:,1) = worm2.skeleton.pixels(:,1) - wMinY + 3;
    worm2.skeleton.pixels(:,2) = worm2.skeleton.pixels(:,2) - wMinX + 3;
    
    % Minimize the head samples.
    hPixels1 = round(hPixels1);
    hPixels1(:,1) = hPixels1(:,1) - wMinY + 3;
    hPixels1(:,2) = hPixels1(:,2) - wMinX + 3;
    hPixels2 = round(hPixels2);
    hPixels2(:,1) = hPixels2(:,1) - wMinY + 3;
    hPixels2(:,2) = hPixels2(:,2) - wMinX + 3;
    hParaPixels(:,1) = hParaPixels(:,1) - wMinY + 3;
    hParaPixels(:,2) = hParaPixels(:,2) - wMinX + 3;
    hOrthoPixels(:,1) = hOrthoPixels(:,1) - wMinY + 3;
    hOrthoPixels(:,2) = hOrthoPixels(:,2) - wMinX + 3;
    
    % Minimize the tail samples.
    tPixels1 = round(tPixels1);
    tPixels1(:,1) = tPixels1(:,1) - wMinY + 3;
    tPixels1(:,2) = tPixels1(:,2) - wMinX + 3;
    tPixels2 = round(tPixels2);
    tPixels2(:,1) = tPixels2(:,1) - wMinY + 3;
    tPixels2(:,2) = tPixels2(:,2) - wMinX + 3;
    tParaPixels(:,1) = tParaPixels(:,1) - wMinY + 3;
    tParaPixels(:,2) = tParaPixels(:,2) - wMinX + 3;
    tOrthoPixels(:,1) = tOrthoPixels(:,1) - wMinY + 3;
    tOrthoPixels(:,2) = tOrthoPixels(:,2) - wMinX + 3;
    
    % Construct the worms' images.
    emptyImg = ones(wMaxY - wMinY + 5, wMaxX - wMinX + 5);
    img1 = overlayWormAngles(emptyImg, worm1, cRGB, [], [], ...
        hPattern, hRGB, 1, vPattern, vRGB, 1);
    img2 = overlayWormAngles(emptyImg, worm2, cRGB, [], [], ...
        hPattern, hRGB, 1, vPattern, vRGB, 1);
    
    % Overlay the worm images.
    rImg = img2(:,:,1);
    gImg = img1(:,:,1);
    bImg = rImg;
    bImg(gImg == intensity) = intensity;
    p1I = sub2ind(size(rImg), [hPixels1(:,1); tPixels1(:,1)], ...
        [hPixels1(:,2); tPixels1(:,2)]);
    rImg(p1I) = intensity;
    gImg(p1I) = 0;
    bImg(p1I) = 0;
    p2I = sub2ind(size(gImg), [hPixels2(:,1); tPixels2(:,1)], ...
        [hPixels2(:,2); tPixels2(:,2)]);
    rImg(p2I) = 0;
    gImg(p2I) = intensity;
    bImg(p2I) = 0;
    rgbImg(:,:,1) = rImg;
    rgbImg(:,:,2) = gImg;
    rgbImg(:,:,3) = bImg;
    
    % Show the overlay.
    figure;
    imshow(rgbImg);
    title(['\color{darkGreen}Worm 2 (frame = ' ...
        num2str(worm2.video.frame) ')']);
    ylabel(['\color{red}Worm 1 (frame = ' num2str(worm1.video.frame) ')']);
    xlabel({['\color{black}Orthogonal Confidence:' ...
        ' Head = ' num2str(headOrthoConfidence)  ...
        '   Tail = ' num2str(tailOrthoConfidence)],  ...
        ['\color{blue}Parallel Confidence:' ...
        ' Head = ' num2str(headParaConfidence)  ...
        '   Tail = ' num2str(tailParaConfidence)],  ...
        ['\color{orange}Magnitude Confidence:' ...
        ' Head = ' num2str(headMagConfidence)  ...
        '   Tail = ' num2str(tailMagConfidence)]});
    
    % Show the vectors.
    hold on;
    dhParaPixels = hParaPixels - hPixels1;
    quiver(hPixels1(:,2), hPixels1(:,1), ...
         dhParaPixels(:,2), dhParaPixels(:,1), 0, 'b');
    dhOrthoPixels = hOrthoPixels - hPixels1;
    quiver(hPixels1(:,2), hPixels1(:,1), ...
         dhOrthoPixels(:,2), dhOrthoPixels(:,1), 0, 'k');
    dtParaPixels = tParaPixels - tPixels1;
    quiver(tPixels1(:,2), tPixels1(:,1), ...
         dtParaPixels(:,2), dtParaPixels(:,1), 0, 'b');
    dtOrthoPixels = tOrthoPixels - tPixels1;
    quiver(tPixels1(:,2), tPixels1(:,1), ...
         dtOrthoPixels(:,2), dtOrthoPixels(:,1), 0, 'k');
end
end
