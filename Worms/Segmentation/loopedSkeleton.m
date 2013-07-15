function worm = loopedSkeleton(oContour, iContour, wormSegSize)
%LOOPEDSKELETON Summary of this function goes here
%
%   Inputs:
%       oContour -
%       iContour -
%       wormSegSize -
%
%   Output:
%       worm - the worm information organized in a structure
%              This structure contains 6 sub-structures,
%              4 sub-sub-structures, and 2 sub-sub-sub-structures:
%
%              * Contour *
%              contour = {pixels, touchI, inI, outI, angles, headI, tailI,
%                         isHeadTailFlipped, isVulvaClockwiseFromHead}
%
%              * Skeleton *
%              skeleton = {pixels, touchI, inI, outI, inOutI, angles, length, widths}
%
%              * Head *
%              head = {bounds, pixels, cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              head.bounds{contour.left (indices for [start end]),
%                          contour.right (indices for [start end]),
%                          skeleton indices for [start end]}
%
%              * Tail *
%              tail = {bounds, pixels, cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              tail.bounds{contour.left (indices for [start end]),
%                          contour.right (indices for [start end]),
%                          skeleton indices for [start end]}
%
%              * Left Side (Counter Clockwise from the Head) *
%              left = {bounds, pixels, cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              left.bounds{contour (indices for [start end]),
%                          skeleton (indices for [start end])}
%
%              * Right Side (Clockwise from the Head) *
%              right = {bounds, pixels, cdf (at [2.5% 25% 50% 75% 97.5%]), stdev}
%              right.bounds{contour (indices for [start end]),
%                           skeleton (indices for [start end])}
%
%   See also WORM2STRUCT
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

tContourI = [];
oContourI = [];
iContourI = [];
cAngles = [];
mcAngles =[];
skeleton = [];
tSkeletonI = [];
oSkeletonI = [];
iSkeletonI = [];
oiSkeletonI = [];
sLength = [];
cWidths = [];

angleEdgeSize = round(wormSegSize);
oAngles = circCurvature(oContour, angleEdgeSize);
iAngles = circCurvature(iContour, angleEdgeSize);
angleEdgeSize2 = round(2 * wormSegSize);
oAngles2 = circCurvature(oContour, angleEdgeSize2);
iAngles2 = circCurvature(iContour, angleEdgeSize2);

blurLength = round(angleEdgeSize / 2);
blurWin(1:blurLength) = 1 / blurLength;
moAngles = circConv(oAngles, blurWin);
miAngles = circConv(iAngles, blurWin);
blurLength2 = round(angleEdgeSize2 / 2);
blurWin2(1:blurLength2) = 1 / blurLength2;
moAngles2 = circConv(oAngles2, blurWin2);
miAngles2 = circConv(iAngles2, blurWin2);

[moMinP moMinI] = minPeaksCircDist(moAngles, angleEdgeSize);
[moMaxP moMaxI] = maxPeaksCircDist(moAngles, angleEdgeSize);
[miMinP miMinI] = minPeaksCircDist(miAngles, angleEdgeSize);
[miMaxP miMaxI] = maxPeaksCircDist(miAngles, angleEdgeSize);
[moMinP2 moMinI2] = minPeaksCircDist(moAngles2, angleEdgeSize2);
[moMaxP2 moMaxI2] = maxPeaksCircDist(moAngles2, angleEdgeSize2);
[miMinP2 miMinI2] = minPeaksCircDist(miAngles2, angleEdgeSize2);
[miMaxP2 miMaxI2] = maxPeaksCircDist(miAngles2, angleEdgeSize2);

thr = 20;
moMin = moMinP < -thr;
moMinP = moMinP(moMin);
moMinI = moMinI(moMin);
moMax = moMaxP > thr;
moMaxP = moMaxP(moMax);
moMaxI = moMaxI(moMax);
miMin = miMinP < -thr;
miMinP = miMinP(miMin);
miMinI = miMinI(miMin);
miMax = miMaxP > thr;
miMaxP = miMaxP(miMax);
miMaxI = miMaxI(miMax);
moMin2 = moMinP2 < -thr;
moMinP2 = moMinP2(moMin2);
moMinI2 = moMinI2(moMin2);
moMax2 = moMaxP2 > thr;
moMaxP2 = moMaxP2(moMax2);
moMaxI2 = moMaxI2(moMax2);
miMin2 = miMinP2 < -thr;
miMinP2 = miMinP2(miMin2);
miMinI2 = miMinI2(miMin2);
miMax2 = miMaxP2 > thr;
miMaxP2 = miMaxP2(miMax2);
miMaxI2 = miMaxI2(miMax2);

minY = min(oContour(:,1));
maxY = max(oContour(:,1));
minX = min(oContour(:,2));
maxX = max(oContour(:,2));
wImg = zeros(maxY - minY + 3, maxX - minX + 3);
wImg(sub2ind(size(wImg), oContour(:,1) - minY + 2, ...
    oContour(:,2) - minX + 2)) = 1;
wImg(sub2ind(size(wImg), iContour(:,1) - minY + 2, ...
    iContour(:,2) - minX + 2)) = 1;
wImg2 = zeros(maxY - minY + 3, maxX - minX + 3);
wImg2(sub2ind(size(wImg), oContour(:,1) - minY + 2, ...
    oContour(:,2) - minX + 2)) = 1;
wImg2(sub2ind(size(wImg), iContour(:,1) - minY + 2, ...
    iContour(:,2) - minX + 2)) = 1;

figure, subplot(2,2,2), plot(oAngles, 'k');
hold on, plot(moAngles, 'b');
hold on, plot(moMinI, moMinP, 'm*');
hold on, plot(moMaxI, moMaxP, 'g*');
hold on, plot(iAngles, 'r');
hold on, plot(miAngles, 'm');
hold on, plot(miMinI, miMinP, 'm*');
hold on, plot(miMaxI, miMaxP, 'g*');

hold on, subplot(2,2,4), plot(oAngles2, 'k');
hold on, plot(moAngles2, 'b');
hold on, plot(moMinI2, moMinP2, 'm*');
hold on, plot(moMaxI2, moMaxP2, 'g*');
hold on, plot(iAngles2, 'r');
hold on, plot(miAngles2, 'm');
hold on, plot(miMinI2, miMinP2, 'm*');
hold on, plot(miMaxI2, miMaxP2, 'g*');

hold on, subplot(2,2,1), imshow(wImg, 'Colormap', colormap(jet));
hold on, text(oContour(moMaxI,2) - minX + 2, ...
    oContour(moMaxI,1) - minY + 2, '*', 'Color', 'g');
hold on, text(oContour(moMaxI,2) - minX + 2, ...
    oContour(moMaxI,1) - minY + 2, num2str(moMaxI), 'Color', 'g');
hold on, text(oContour(moMinI,2) - minX + 2, ...
    oContour(moMinI,1) - minY + 2, '*', 'Color', 'm');
hold on, text(oContour(moMinI,2) - minX + 2, ...
    oContour(moMinI,1) - minY + 2, num2str(moMinI), 'Color', 'm');
hold on, text(iContour(miMaxI,2) - minX + 2, ...
    iContour(miMaxI,1) - minY + 2, '*', 'Color', 'g');
hold on, text(iContour(miMaxI,2) - minX + 2, ...
    iContour(miMaxI,1) - minY + 2, num2str(miMaxI), 'Color', 'g');
hold on, text(iContour(miMinI,2) - minX + 2, ...
    iContour(miMinI,1) - minY + 2, '*', 'Color', 'm');
hold on, text(iContour(miMinI,2) - minX + 2, ...
    iContour(miMinI,1) - minY + 2, num2str(miMinI), 'Color', 'm');

hold on, subplot(2,2,3), imshow(wImg, 'Colormap', colormap(jet));
hold on, text(oContour(moMaxI2,2) - minX + 2, ...
    oContour(moMaxI2,1) - minY + 2, '*', 'Color', 'g');
hold on, text(oContour(moMaxI2,2) - minX + 2, ...
    oContour(moMaxI2,1) - minY + 2, num2str(moMaxI2), 'Color', 'g');
hold on, text(oContour(moMinI2,2) - minX + 2, ...
    oContour(moMinI2,1) - minY + 2, '*', 'Color', 'm');
hold on, text(oContour(moMinI2,2) - minX + 2, ...
    oContour(moMinI2,1) - minY + 2, num2str(moMinI2), 'Color', 'm');
hold on, text(iContour(miMaxI2,2) - minX + 2, ...
    iContour(miMaxI2,1) - minY + 2, '*', 'Color', 'g');
hold on, text(iContour(miMaxI2,2) - minX + 2, ...
    iContour(miMaxI2,1) - minY + 2, num2str(miMaxI2), 'Color', 'g');
hold on, text(iContour(miMinI2,2) - minX + 2, ...
    iContour(miMinI2,1) - minY + 2, '*', 'Color', 'm');
hold on, text(iContour(miMinI2,2) - minX + 2, ...
    iContour(miMinI2,1) - minY + 2, num2str(miMinI2), 'Color', 'm');




% The head and tail are obscured in the loop.
ocSize = size(oContour, 1);
icSize = size(iContour, 1);
if headI == 0 && tailI ==0
    
    % Find the location of maximum curvature on the outer contour.
    % This is the most likely place where the worm touches itself outside.
    [oMinAllP oMinAllI] = min(oMinP);
    [oMaxAllP oMaxAllI] = max(oMaxP);
    
    % Find the starting points for cutting across the contour.
    if abs(oMinAllP) >=  oMaxAllP
        s1 = oMinI(oMinAllI);
    else
        s1 = oMaxI(oMaxAllI);
    end
    s2 = circNearestPoint(oContour(s1,:), 1, icSize, iContour);
    
    % Find the location of maximum curvature on the inner contour.
    % This is the most likely place where the worm touches itself inside.
    [iMinAllP iMinAllI] = min(iMinP);
    [iMaxAllP iMaxAllI] = max(iMaxP);
    
    % Find the ending points for cutting across the contour.
    if abs(iMinAllP) >=  iMaxAllP
        e2 = iMinI(iMinAllI);
    else
        e2 = iMaxI(iMaxAllI);
    end
    e1 = circNearestPoint(iContour(e2,:), 1, ocSize, oContour);
    
    % In which direction should we cut?
    % Note: worms can't coil very tightly, so the smallest side is where
    % the head and tail touch.
    if s1 < e1
        side1 = e1 - s1;
        side2 = ocSize - e1 + 1 + s1;
    else
        side1 = ocSize - s1 + 1 + e1;
        side2 = s1 - e1;
    end        
    
    % Initialize the directions to walk along the contour segments.
    if side1 <= side2
        i1 = 1;
        i2 = -1;
        
    % Swap the starting and ending points for cutting across the contour.
    else
        tmp = s1;
        s1 = e1;
        e1 = tmp;
        tmp = s2;
        s2 = e2;
        e2 = tmp;
        
        % Initialize the directions to walk along the contour segments.
        i1 = -1;
        i2 = 1;
    end
    
    % Cut across the contour to delineate the head and tail.
    cContour = round(skeletonize(s1, e1, i1, s2, e2, i2, oContour, iContour, 1));
    
    % Reconstruct the contour.
    contour = [cContour; iContour(e2:end,:); iContour(1:e2,:); ...
        flipud(cContour); oContour(s1:end,:); oContour(1:s1,:)];
    contour = cleanContour(contour);
    
    % Compute the contour's local curvature.
    % On a small scale, noise causes contour imperfections that shift an angle
    % from its correct location. Therefore, blurring angles by averaging them
    % with their neighbors can localize them better.
    wormSegs = 50;
    angles = circCurvature(contour, round(size(contour, 1) / (wormSegs / 2)));
    blurLength = 2 * round(size(contour, 1) / (wormSegs * 2)) + 1;
    blurWin(1:blurLength) = 1 / blurLength;
    mAngles = circConv(angles, blurWin);
    
    % Compute the contour's local curvature maxima.
    angleEdgeSize = round(length(mAngles) / (wormSegs / 2));
    [maxP maxI] = maxPeaksCircDist(mAngles, angleEdgeSize);
    [minP minI] = minPeaksCircDist(mAngles, angleEdgeSize);
    
    % Determine the head and tail.
    [~, o] = sort(maxP, 1, 'descend');
    headI = maxI(o(1));
    tailI = maxI(o(2));
    
    % Skeletonize the loop.
    skeleton = linearSkeleton(headI, tailI, minP, minI, contour, 2 * angleEdgeSize);
    
    % Record the touching points.
    touchCPoints = [s1 e1 1; s2 e2 0];
    touchSPoints = [1 size(skeleton, 1)];
end
end
