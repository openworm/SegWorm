function oImg = overlayWormAnglesSimple( imImg, worm )
%Wrapper around overlayWormAngles that provides defaults for the head/vulva
%patterns and heat maps
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

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
vImg = [1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1];
[vPattern(:,1) vPattern(:,2)] = find(vImg == 1);
vPattern(:,1) = vPattern(:,1) - ceil(size(vImg, 1) / 2);
vPattern(:,2) = vPattern(:,2) - ceil(size(vImg, 2) / 2);

% Construct the values for the contour and skeleton curvature heat map.
blue = zeros(360, 3);
blue(:,3) = 255;
red = zeros(360, 3);
red(:,1) = 255;
cRGB = [blue(1:90,:); jet(181) * 255; red(1:90,:)]; % thermal
sRGB = [blue(1:90,:); jet(181) * 255; red(1:90,:)]; % thermal
sRGBNaN = [255 0 0]; % red
hRGB = [0 255 0]; % green
vRGB = [255 0 0]; % red


oImg = overlayWormAngles(imImg, worm, cRGB, sRGB, sRGBNaN, ...
    hPattern, hRGB, 1, vPattern, vRGB, 1);

end

