function img1 = getWormImage(img, normBlock, frameNo, ...
    pixel2MicronScale, rotation, locations, movesI, ...
    globalFrameNo, toggleROIBox)
% GETWORMIMAGE function will retrieve data form the normBlock to create a
% worm image that can be displayed
% Input:
%       normBlock - current normBlock
%       frameNo - frame number relative to the block
%       pixel2MicronScale - scale varialbe
%       rotation - rotation parameter
%       locations - stage movement data
%       movesI - stage movement data
%       globalFrameNo - global frame number
%       toggleROIBox - flag indicating ROI crop
% Output:
%       img1 - overlayed worm
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

%get the details for the old worm
eval( ['vulvaContour = normBlock', '{2}(:,:,' num2str(frameNo) ');' ]);
eval( ['nonVulvaContour = normBlock', '{3}(:,:,' num2str(frameNo) ');' ]);
eval( ['skeleton = normBlock', '{4}(:,:,' num2str(frameNo) ');' ]);
eval( ['skeletonAngles = normBlock', '{5}(:,' num2str(frameNo) ');' ]);
eval( ['inOutTouch = normBlock', '{6}(:,' num2str(frameNo) ');' ]);
eval( ['skeletonLength = normBlock', '{7}(:,' num2str(frameNo) ');' ]);
eval( ['widths = normBlock', '{8}(:,' num2str(frameNo) ');' ]);
eval( ['headArea = normBlock', '{9}(:,' num2str(frameNo) ');' ]);
eval( ['tailArea = normBlock', '{10}(:,' num2str(frameNo) ');' ]);
eval( ['vulvaArea = normBlock', '{11}(:,' num2str(frameNo) ');' ]);
eval( ['nonVulvaArea = normBlock', '{12}(:,' num2str(frameNo) ');' ]);

%construct the old worm, if the positions are not NaN
if any(any(vulvaContour))
    worm = norm2Worm(globalFrameNo, vulvaContour, nonVulvaContour, ...
        skeleton, skeletonAngles, inOutTouch, skeletonLength, widths, ...
        headArea, tailArea, vulvaArea, nonVulvaArea, ...
        getOrigin(locations, movesI, globalFrameNo), pixel2MicronScale, rotation, []);
    
    % Construct a pattern to identify the head.
    draw.ahImg = [1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1];
    [draw.ahPattern(:,1) draw.ahPattern(:,2)] = find(draw.ahImg == 1);
    draw.ahPattern(:,1) = draw.ahPattern(:,1) - ceil(size(draw.ahImg, 1) / 2);
    draw.ahPattern(:,2) = draw.ahPattern(:,2) - ceil(size(draw.ahImg, 2) / 2);
    
    % Construct a pattern to identify the vulva.
    draw.avImg = [1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1; ...
        1 1 1 1 1];
    [draw.avPattern(:,1) draw.avPattern(:,2)] = find(draw.avImg == 1);
    draw.avPattern(:,1) = draw.avPattern(:,1) - ceil(size(draw.avImg, 1) / 2);
    draw.avPattern(:,2) = draw.avPattern(:,2) - ceil(size(draw.avImg, 2) / 2);
    
    % Choose the color scheme.
    draw.blue = zeros(360, 3);
    draw.blue(:,3) = 255;
    draw.red = zeros(360, 3);
    draw.red(:,1) = 255;
    draw.acRGB = [draw.blue(1:90,:); jet(181) * 255; draw.red(1:90,:)]; % thermal
    draw.asRGB = draw.acRGB;
    %asRGB = [blue(1:90,:); jet(181) * 255; red(1:90,:)]; % thermal
    draw.asRGBNaN = [255 0 0]; % red
    draw.ahRGB = [0 255 0]; % green
    draw.isAHOpaque = 1;
    draw.avRGB = [255 0 0]; % red
    draw.isAVOpaque = 1;
    
    
    sImg = overlayWormAngles(img, worm, draw.acRGB, ...
        draw.asRGB, draw.asRGBNaN, draw.ahPattern, draw.ahRGB, draw.isAHOpaque, ...
        draw.avPattern, draw.avRGB, draw.isAVOpaque);
else
    sImg = uint8(img);
end
% Convert the image to uint8
img1 = uint8(sImg);

if toggleROIBox
    % Define padding for ROI
    padding = 10;
    % Get ROI
    min1 = min(worm.contour.pixels(:,1))-padding;
    min2 = min(worm.contour.pixels(:,2))-padding;
    max1 = max(worm.contour.pixels(:,1))+padding;
    max2 = max(worm.contour.pixels(:,2))+padding;
    % Crop image
    img1 = img1(min1:max1,min2:max2,:);
end
end

    function currentOrigin = getOrigin(locations, movesI, globalFrameNo)
    % Orientation funcion
        currentOrigin = locations(end,:);
        for i=1:length(movesI(:,1))-1
            if globalFrameNo > movesI(i, 2) && globalFrameNo <= movesI(i+1, 2)
                currentOrigin = locations(i,:);
            end
        end
    end
    
