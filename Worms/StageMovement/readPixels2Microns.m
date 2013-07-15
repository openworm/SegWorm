function [pixel2MicronScale rotation] = readPixels2Microns(infoFile)
%READPIXELS2MICRONS Read the experiment information file and compute the
%   scale for converting pixels to microns as well as the rotation matrix.
%
%   [PIXEL2MICRONSCALE ROTATION] = READPIXELS2MICRONS(INFOFILE)
%
%   Input:
%       infoFile - the XML file with the experiment information
%
%   Outputs:
%       pixel2MicronScale - the scale for converting pixels to microns
%       rotation          - the rotation matrix
%
% See also PIXELS2MICRONS
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Open the information file.
if ~exist(infoFile, 'file')
    error('findStageMovement:BadInfoFile', ['Cannot open ' infoFile]);
end
xml = xmlread(infoFile);

% Read the steps/microns.
micronsX = str2double(xmlReadTag(xml, ...
    'configuration.info.stage.steps.equivalent.microns.x'));
micronsY = str2double(xmlReadTag(xml, ...
    'configuration.info.stage.steps.equivalent.microns.y'));

% Read the steps/pixels.
pixelsX = str2double(xmlReadTag(xml, ...
    'configuration.info.stage.steps.equivalent.pixels.x'));
pixelsY = str2double(xmlReadTag(xml, ...
    'configuration.info.stage.steps.equivalent.pixels.y'));

% Compute the microns/pixels.
%pixel2MicronScale = [pixelsX / micronsX, pixelsY / micronsY];
pixel2MicronX = pixelsX / micronsX;
pixel2MicronY = pixelsY / micronsY;
normScale = sqrt((pixel2MicronX ^ 2 + pixel2MicronY ^ 2) / 2);
pixel2MicronScale =  normScale * [sign(pixel2MicronX) sign(pixel2MicronY)];

% Compute the rotation matrix.
%rotation = 1;
angle = atan(pixel2MicronY / pixel2MicronX);
if angle > 0
    angle = pi / 4 - angle;
else
    angle = pi / 4 + angle;
end
cosAngle = cos(angle);
sinAngle = sin(angle);
rotation = [cosAngle, -sinAngle; sinAngle, cosAngle];
end
