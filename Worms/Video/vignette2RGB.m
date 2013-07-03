function img = vignette2RGB(vignetteFile, varargin)
%VIGNETTE2RGB Convert the vignette to an RGB image. Positive values are
%   green. Negative values are red.
%
%   IMG = VIGNETTE2RGB(VIGNETTEFILE)
%
%   IMG = VIGNETTE2RGB(VIGNETTEFILE, SCALE)
%
%   IMG = VIGNETTE2RGB(VIGNETTEFILE, SCALE, VERBOSE)
%
%   Inputs:
%       vignetteFile - the name of the vignette file
%       scale        - a multiplicative scale for the vignette values;
%                      if empty, the values are scaled by 1
%       verbose      - verbose mode shows the results in a figure
%
%   Output:
%       img - an RGB image of the vignette
%
%   See also VIDEO2VIGNETTE

% Initialize the scale and verbose mode. 
scale = 1;
verbose = false;

% Are we scaling the vignette values?
if ~isempty(varargin)
    scale = varargin{1};
end

% Are we showing the results in a figure?
if length(varargin) > 1
    verbose = varargin{2};
end

% Get the vignette.
fid = fopen(vignetteFile, 'r');
vImg = fread(fid, [640 480],'int32=>float', 0, 'b')' / 255;
fclose(fid);

% Color the positive values green and the negative values red.
emptyImg = double(ones(size(vImg)));
rImg = emptyImg;
gImg = emptyImg;
bImg = emptyImg;
posImg = vImg > 0;
rImg(posImg) = 1 - vImg(posImg) * scale;
bImg(posImg) = rImg(posImg);
negImg = vImg < 0;
gImg(negImg) = 1 + vImg(negImg) * scale;
bImg(negImg) = gImg(negImg);

% Construct the RGB image.
img(:,:,1) = rImg;
img(:,:,2) = gImg;
img(:,:,3) = bImg;

% Show the vignette.
if verbose
    figure;
    imshow(img);
    title(strrep(vignetteFile, '_', '\_')); % underscores confuse TeX
end
end

