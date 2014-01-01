function curvature = wormPathCurvature(wormFile, useSamples, type, ...
    scales, varargin)
%WORMDIRECTION Compute the worm path curvature (angle/distance).
%
%   CURVATURE = WORMDIRECTION(WORMFILE, USESAMPLES, TYPE, SCALES)
%
%   CURVATURE = WORMDIRECTION(WORMFILE, USESAMPLES, TYPE, SCALES,
%                             VENTRALMODE)
%
%   Inputs:
%       wormFile   - the name of the file containing normalized worms (see
%                    saveWormFrames). The file format is MAT (Matlab's
%                    '.mat') and contains the following variables:
%                   
%                    samples      = the samples per normalized worm; if
%                                   empty, the worms are in structs
%                    fps          = frames/seconds
%                    firstFrame   = the first frame number (in block1)
%                    lastFrame    = the last frame number (in the last block)
%                    blockSize    = the size of a block
%                    blocks       = the number of blocks
%                    block1       = the first block
%                    ...
%                    blockN       = the N-th (last) block
%
%                    If the data is normalized, the blocks are cell arrays
%                    with following structure (see normWorms):
%
%                    blockN{1}  = status:
%                                 s = segmented
%                                 f = segmentation failed
%                                 m = stage movement
%                                 d = dropped frame
%                    blockN{2}  = vulvaContours
%                    blockN{3}  = nonVulvaContours
%                    blockN{4}  = skeletons
%                    blockN{5}  = angles
%                    blockN{6}  = inOutTouches
%                    blockN{7}  = lengths
%                    blockN{8}  = widths
%                    blockN{9}  = headAreas
%                    blockN{10} = tailAreas
%                    blockN{11} = vulvaAreas
%                    blockN{12} = nonVulvaAreas
%
%                    Otherwise, the blocks are just cell arrays of worm
%                    cells; missing worms are labeled with their frame
%                    status instead:
%
%                    blockN = 1 to, at most, blockSize number of worm cells;
%                             or, for missing worms, their frame status:
%                             f = segmentation failed
%                             m = stage movement
%                             d = dropped frame
%
%       useSamples - the worm samples to use. Samples can be:
%                    
%                    empty      = use all samples
%                    fractional = the fraction of samples to use
%                    vector     = the samplig points to use
%                    cell array = each cell element is a group of sampling
%                                 points to average together; or, if you
%                                 include just a a single fractional
%                                 element, the worm will be fractionated
%                                 into these groups and each group will be
%                                 averaged; e.g., {1/7} produces 7 averaged
%                                 groups, each is 1/7 the worm
%
%       type       - the type of algorithm to use when replacing unusable
%                    data samples (e.g., due to stage movements or failed
%                    segmentation). Differentiation is expressed as:
%
%                    dX/dT = -(X1 - X2)/(T1 - T2)
%
%                    type is a 1 or 2 letter string indicating which
%                    method to use when replacing an unusable X1 and/or
%                    X2. If type is 2 characters long:
%
%                    type(1) = X1
%                    type(2) = X2
%
%                    Otherwise, type(1) is used for both X1 and X2. The
%                    methods are as follows:
%
%                    i = linearly interpolate unusable data
%                        (type(2) is ignored)
%                    e = exact match, if data is unusable, the result is NaN
%                    b = backwards nearest neighbor
%                    f = forwards nearest neighbor
%                    n = nearest neighbor
%
%                    Note: the nearest-neighbor type algorithms adjust
%                    the time accordingly. If there is no nearest
%                    neighbor, differentiation results in NaN.
%       scales     - a vector of the scales (in seconds) to use for
%                    spacing X1 from X2
%
%
%       ventralMode - the ventral side mode:
%
%                     0 = the ventral side is unknown
%                     1 = the ventral side is clockwise
%                     2 = the ventral side is anticlockwise
%
%   Output:
%       curvature - the worm path curvature (the angle between every 3 
%                   subsequent locations at the given scale, divided by the
%                   distance traveled between these 3 subsequent locations)
%
%   See also MULTISCALEWORM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Where is the ventral side located?
ventralMode = 0;
if ~isempty(varargin)
    ventralMode = varargin{1};
end

% Determine the worm direction.
isSparse = false;
offMode = 1;
isNoisy = false;
htDirMode = 3;
isAbsDir = true;
[diffData, ~, ~, fps, ~] = multiScaleWorm(wormFile, [], [], useSamples, ...
    [], type, scales, isSparse, offMode, isNoisy, htDirMode, isAbsDir);


% Compute the worm direction and path curvature for each scale.
curvature = cell(length(scales),1);
for i = 1:length(scales)
    curvature{i} = ...
        computeCurvature(diffData{8}{i}, diffData{7}{i}, scales(i), ...
        fps, offMode);
    if ventralMode > 1
        curvature{i} = -curvature{i};
    end
end
end

% Compute the worm path curvature.
function curvature = ...
    computeCurvature(direction, speed, scale, fps, offMode)

% Compute the angle differentials and distances.
frameScale = round(scale * fps);
speed = abs(speed);
dDir = nan(size(speed));
distance = nan(size(dDir));
switch offMode
    case 1
        startOff = round((frameScale + 1) / 2);
        endOff = frameScale - startOff;
    case 2
        startOff = 0;
        endOff = frameScale;
    case 3
        startOff = frameScale;
        endOff = 0;
end
dDir(:,1:(end - frameScale + 1)) = ...
    direction(:,frameScale:end) - direction(:,1:(end - frameScale + 1));
distanceI = startOff:(length(speed) - frameScale);
distance(:,distanceI) = (speed(:,distanceI) * scale + ...
    speed(:,distanceI + frameScale) * scale) / 2;

% Wrap the direction.
wrap = dDir >= 180;
dDir(wrap) = dDir(wrap) - 360;
wrap = dDir <= -180;
dDir(wrap) = dDir(wrap) + 360;

% Compute the worm path curvature.
%curvature = dDir .* distance;
distance(distance < 1) = NaN;
curvature = (dDir ./ distance) * (pi / 180);
end
