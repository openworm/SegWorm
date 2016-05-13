function [vig vimg] = saveVig(filename, video)
%SAVEVIG Save the vignette correction to a file.
%
%   [vig vimg] = saveVig(filename, video)
%
%   Input:
%       filename - the file in which to save the vignette:
%                  vig  = the vignette correction
%                  vimg = an image of the vignette
%       video    - a video file containing just an out-of-focus vignette
%
%   Output:
%       vig  - the vignette correction
%       vimg - an image of the vignette
%
%
%
% © Eviatar Yemini and Columbia University 2013
% You will not remove any copyright or other notices from the Software;
% you must reproduce all copyright notices and other proprietary notices
% on any copies of the Software.

% Read in the first frame of the vignette video.
vr = VideoReader(video);
vimg = vr.read(1);

% Compute the vignette correction (to add to each uncorrected frame).
vig = mean(vimg(:)) - double(vimg);

% Save everything.
save(filename, 'vig', 'vimg');
end
