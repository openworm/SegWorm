function oImg = overlayBadWorm(img, type)
%OVERLAYBADWORM Overlay a bad worm segmentation onto an image.
%
%   OIMG = OVERLAYBADWORM(IMG, TYPE)
%
%   Inputs:
%       img  - the image on which to overlay the bad worm segmentation
%       type - the type of overlay:
%           'd' - a dropped frame
%           'm' - a stage movement
%           'f' - a segmentation failure
%
%
%   Outputs:
%       oImg - an image overlayed with the bad worm segmentation
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Convert the image to grayscale.
if (size(img,3) == 3)
    img = rgb2gray(img);
end

% Pre-allocate memory.
rgbImg(:,:,1) = img;
rgbImg(:,:,2) = img;
rgbImg(:,:,3) = img;

% Compute the border.
if size(img, 1) < size(img, 2)
    border = ceil(size(img, 1) / 50);
else
    border = ceil(size(img, 2) / 50);
end

% What's wrong with the worm?
switch lower(type)
    
    % The image is a dropped frame.
    case 'd'
        %oImg(:,:,3) = img;
        %oImg(:,:,[1 2]) = 96;
        oImg = rgbImg;
        oImg(1:border,1:end,[1 2]) = 96;
        oImg((end - border + 1):end,1:end,[1 2]) = 96;
        oImg(border:(end - border + 1),1:border,[1 2]) = 96;
        oImg(border:(end - border + 1),(end - border + 1):end,[1 2]) = 96;
        
    % The image contains a stage movement.
    case 'm'
        %oImg(:,:,2) = img;
        %oImg(:,:,[1 3]) = 96;
        oImg = rgbImg;
        oImg(1:border,1:end,[1 3]) = 96;
        oImg((end - border + 1):end,1:end,[1 3]) = 96;
        oImg(border:(end - border + 1),1:border,[1 3]) = 96;
        oImg(border:(end - border + 1),(end - border + 1):end,[1 3]) = 96;
        
    % The worm failed to segment.
    case 'f'
        %oImg(:,:,1) = img;
        %oImg(:,:,[2 3]) = 96;
        oImg = rgbImg;
        oImg(1:border,1:end,[2 3]) = 96;
        oImg((end - border + 1):end,1:end,[2 3]) = 96;
        oImg(border:(end - border + 1),1:border,[2 3]) = 96;
        oImg(border:(end - border + 1),(end - border + 1):end,[2 3]) = 96;
        
    % Unrecognized type.
    otherwise
        error('overlayBadWorm:BadType', ['Type ''' type ...
            ''' is not recognized']);
end
end

