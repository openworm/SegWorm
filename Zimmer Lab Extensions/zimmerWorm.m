%% PUT YOUR VIDEO NAMES HERE.
inputVideos = {
    'test.avi'
    %'20130612_w6_stream.avi'
    %'20130612_w7_stream.avi'
    %'20130612_w8_stream.avi'
    };
%% NO NEED TO CHANGE ANYTHING BELOW!

%% HOW TO USE THE OUTPUT
%
% 1. <inputVideo>_seg.avi is an annotated, scaled down version of your
%    input video. Please review it to ensure the extracted head and
%    skeletons points are relatively accurate. Red bordered frames, with no
%    skeleton annotated, failed segmentation and are explained below. The
%    head is labeled in white, the tail in black. Each body point is
%    labeled according to its angle of curvature, from blue to red, with
%    green meaning ~0 degrees, no curvature.
%
% 2. <inputVideo>.mat contains a struct array called "worms". worms has 5
%    fields of interest:
%    worms.frame  = the frame number
%    worms.pixels = the pixels, ordered head-to-tail in the form (x,y),
%                   per frame, for the extracted worm
%                   Note 1: the pixels are fractional and sampled using the
%                   chain-code (as opposed to pixel) length for a more
%                   accurate measurement.
%                   Note 2: you can change the number of sampled points by
%                   changing "numWormPoints" below.
%   worms.angles  = the angles, per pixel, measured off the non-downsampled
%                   skeleton (a more accurate measure). The angles are
%                   always measured using chain-code length edges equal
%                   1/12 the skeleton length (a physiologically accurate
%                   sampling frequency). The head and tail pixels have no
%                   angle for obvious reasons (they only have one edge).
%                   Note: You can recompute the angles from the actual
%                   pixels should you wish to do so. The values will be
%                   similar but not identical.
%                   To obtain the angles from the pixels directly,
%                   please use the following code:
%                   diffPixels = diff(worms(frame).pixels);
%                   radAngles = nan(numWormPoints, 1);
%                   radAngles(2:(end - 1)) = ...
%                       -diff(atan2(diffPixels(:,1), diffPixels(:,2)));
%                   radAngles = wrapToPi(radAngles);
%                   degAngles = radAngles * 180 / pi;
%   worms.length  = the chain-code pixel length of the worm. I've included
%                   this for 2 reasons: a) you can remove any poorly
%                   segmented worms by filtering out strange lengths (e.g.,
%                   abs(worm(i).length - mean(length)) > mean(length) / 4);
%                   b) if you know the pixels/microns, you can determine
%                   contractions & elongations.
%   worms.error   = when I couldn't segment the worm, the pixels, angles,
%                   and length will be empty and the error will contain a
%                   number. This error number can be translated to an
%                   actual cause using the code below:
%
%                   disp(mode([worms.error])) % <- most common error
%                   annotations = wormFrameAnnotation();
%                   arrayfun(@(x) disp([num2str(x.id) ' = ' x.message 10]),
%                   annotations);
%
% 3. In summary, I'm using the following algorithm:
%    A. Go through the video, correct the vignette, and downsample the
%       images for speed and to clean them up a bit.
%    B. Segment the worm out of the video (see my thesis if you want to
%       know how this is done, it's quite complicated to explain). I'm
%       using a new trick to clean things up a bit more (your videos have
%       dirt and trails of similar intensity to the worm) by eroding the
%       worm image slightly. No big deal since the watery miniscus around
%       your worm is quite large anyhow.
%    C. Align successive skeletons to together and then choose the head by
%       figuring out which end pixel stays closest to the video center. A
%       worm can complete an omega turn, flipping its head & tail within
%       almost 1/3 of a second. So, if I lose > 1/4 second of successive
%       frames, I orient this chunk of skeletons separately from the
%       previous ones.
%    D. Save everything to a file and annotate a small video for review.



%% Initialize the information for video processing.

% The worm is well-approximated by 12 points
numWormPoints = 12;

% Erode the worm image to improve segmentation (eliminate dirt and trails).
numErode = 5;
numDilate = [];

% Downsample the video to speed up processing and clean up the images.
inputVideoScale = 0.5;

% Downsample the annotated videos to save disk space.
outputVideoScale = 0.25;

% Initialize the vignette information.
%vignetteVideo = 'vignette.avi';
vignetteFile = 'vig.mat';
load(vignetteFile, 'vig');

%% Extract the vignette from a video of just the out-of-focus vignette.
% Note: I've already stored everything in "vig.mat". Unless you reconfigure
% the imaging equipment, there should be no reason to call this function.
% [vig, vimg] = saveVig('vig', vignetteVideo);


%% Extract the worms and annotate the videos.
for i = 1:length(inputVideos)
    
    % Name the extracted worm file.
    inputVideo = inputVideos{i};
    wormFile = strrep(inputVideo, '.avi', '');
    
    % Name the annotated video output.
    outputVideo = strrep(inputVideo, '.avi', '_seg');
    
    % Extract the worm from the video.
    disp([10 '*** Extracting the worms into: "' wormFile '.mat"']);
    worms = saveWorms(wormFile, inputVideo, vig, numWormPoints, ...
        inputVideoScale, numErode, numDilate);
    
    % Create a video annotating the extracted worm.
    disp([10 '*** Annotating the worms video: "' outputVideo '.mp4"']);
    saveWormVideoOverlay(outputVideo, inputVideo, vig, worms, ...
        inputVideoScale, outputVideoScale);
end
