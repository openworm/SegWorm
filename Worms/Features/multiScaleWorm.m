          function [diffData startFrame endFrame fps useSamples] = ...
    multiScaleWorm(wormFile, startFrame, endFrame, useSamples, ...
    useFrames, type, scales, isSparse, offMode, isNoisy, htDirMode, ...
    isAbsDir, varargin)
%MULTISCALEWORM Differentiate worm data at multiple scales.
%
%   [DIFFDATA STARTFRAME ENDFRAME FPS USESAMPLES] =
%       MULTISCALEWORM(WORMFILE, STARTFRAME, ENDFRAME, USESAMPLES,
%                      USEFRAMES, TYPE, SCALES, ISSPARSE, OFFMODE, ISNOISY,
%                      HTDIRMODE, ISABSDIR)
%
%   [DIFFDATA STARTFRAME ENDFRAME FPS USESAMPLES] =
%       MULTISCALEWORM(WORMFILE, STARTFRAME, ENDFRAME, USESAMPLES,
%                      USEFRAMES, TYPE, SCALES, ISSPARSE, OFFMODE, ISNOISY)
%                      HTDIRMODE, ISABSDIR, VENTRALMODE)
%
%   [DIFFDATA STARTFRAME ENDFRAME FPS USESAMPLES] =
%       MULTISCALEWORM(WORMFILE, STARTFRAME, ENDFRAME, USESAMPLES,
%                      USEFRAMES, TYPE, SCALES, ISSPARSE, OFFMODE, ISNOISY)
%                      HTDIRMODE, ISABSDIR, VENTRALMODE, VERBOSE)
%
%   [DIFFDATA STARTFRAME ENDFRAME FPS USESAMPLES] =
%       MULTISCALEWORM(WORMFILE, STARTFRAME, ENDFRAME, USESAMPLES,
%                      USEFRAMES, TYPE, SCALES, ISSPARSE, OFFMODE, ISNOISY,
%                      HTDIRMODE, ISABSDIR, VENTRALMODE, VERBOSE, SHOWDATA)
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
%       startFrame - the first frame to use; if the value is an integer, we
%                    interpret it as a frame number; if the value is a
%                    float, we interpret it as a time (in seconds);
%                    if empty, we start at the first frame
%       endFrame   - the last frame to use; if the value is an integer, we
%                    interpret it as a frame number; if the value is a
%                    float, we interpret it as a time (in seconds);
%                    if empty, we end at the last frame
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
%       useFrames  - if not empty, for each frame, is it usable?
%                    The 'use' vector allows one to test replacement
%                    algorithms (e.g., interpolation, nearest neighbor,
%                    etc.), in differentiation, by comparing the results
%                    from real data with tests where elements of this
%                    data have been removed by being declared unusable.
%                    Note: stage movements and failed segmentation are
%                    ALWAYS treated as unusable.
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
%       isSparse   - is the differentiation sparse? for each scale,
%                    sparse differentiation only calculates the data
%                    differences at multiples of that scale
%       offMode    - the offset mode; in other words, how should the data
%                    be offset relative to the differentiation?
%                    The modes are:
%                    
%                    1 = center the data between the start and end times
%                        of the differentiation scale
%                    2 = place the data at the start time of the
%                        differentiation scale
%                    3 = place the data at the end time of the
%                        differentiation scale
%
%       isNoisy    - should the noise be reduced? If so, differentials less
%                    than the sampling resolution (the Nyquist value of
%                    2 * diagonal microns/pixels) are set to zero.
%       htDirMode  - the head-tail orientation computation mode:
%
%                    1 = the direction between the tail and head endpoints
%                    2 = the direction between points 1/6 inwards from the
%                        tail and head endpoints
%                    3 = the mean direction between all subsequent points
%                        from the tail to the head endpoints
%                    4 = the mean direction between all subsequent points
%                        1/6 inwards from the tail and head endpoints
%
%                    Note: the head-tail orientation is used in signing
%                    velocity and computing velocity direction.
%       isAbsDir   - should the skeleton's velocity direction be shown as
%                    an absolute angle or, relative to the head-tail
%                    orientation at time T1?
%       ventralMode - the ventral side mode:
%
%                     0 = the ventral side is unknown
%                     1 = the ventral side is clockwise
%                     2 = the ventral side is anticlockwise
%
%       verbose    - verbose mode 1 shows the results in figures;
%                    verbose mode 2 adds the histogram;
%                    verbose mode 3 adds the worm path;
%                    verbose mode x.5 adds frame information to the figures
%       showData   - a vector of the data indices to show; if empty, all
%                    the data is shown. The indices are defined as follows:
%
%                    1  = the vulval contour's velocity
%                    2  = the vulval contour's velocity direction
%                    3  = the non-vulval contour's velocity
%                    4  = the non-vulval contour's velocity direction
%                    5  = the skeleton's velocity
%                    6  = the skeleton's velocity direction
%                    7  = the skeleton's angles' derivative
%                    8  = the skeleton's touching point's velocity
%                    9  = the skeleton's length's derivative
%                    10 = the contour's widths' derivative
%                    11 = the head area's derivative
%                    12 = the tail area's derivative
%                    13 = the vulval area's derivative
%                    14 = the non-vulval area's derivative
%
%   Output:
%       diffData   - the data differences at each scale. The first dimension
%                    corresponds to the input data's first dimension. The
%                    second dimension is the data differences at each scale.
%                    Multidimensional data (e.g., point coordinates) is
%                    presented as its vector magnitude (e.g., for point
%                    coordinates, the data is presented as sqrt(dX^2 + dY^2)).
%
%                    The differentiated data is as follows:
%
%                    diffData{1}  = the unscaled frame status:
%                                   s = segmented
%                                   f = segmentation failed
%                                   m = stage movement
%                                   d = dropped frame
%                                   u = unused frame
%                    diffData{2}  = the data's frames at each scale
%                    diffData{3}  = the vulval contour's velocity
%                    diffData{4}  = the vulval contour's velocity direction
%                    diffData{5}  = the non-vulval contour's velocity
%                    diffData{6}  = the non-vulval contour's velocity direction
%                    diffData{7}  = the skeleton's velocity
%                    diffData{8}  = the skeleton's velocity direction
%                    diffData{9}  = the skeleton's angles' derivative
%                    diffData{10} = the skeleton's touching point's velocity
%                    diffData{11} = the skeleton's length's derivative
%                    diffData{12} = the contour's widths' derivative
%                    diffData{13} = the head area's derivative
%                    diffData{14} = the tail area's derivative
%                    diffData{15} = the vulval area's derivative
%                    diffData{16} = the non-vulval area's derivative
%       startFrame - the data's starting frame
%       endFrame   - the data's ending frame
%       useSamples - the data's worm sample indices
%       fps        - the data's frames/seconds
%
%   See also SAVEWORMFRAMES, NORMWORMS, MULTISCALEDIFF
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

% Are we showing the data?
verbose = false;
if length(varargin) > 1
    verbose = varargin{2};
end

% What data are we showing?
showData = [];
if length(varargin) > 2
    showData = varargin{3};
end

% Check the worm file.
if ~exist(wormFile, 'file')
    error('multiScaleWorm:BadWormFile', ['Cannot find ''' wormFile '''']);
end

% Are the normalized blocks separate?
global blockFilePath;
blockFilePath = [];
load(wormFile, 'block1');
if ~exist('block1', 'var')
    
    % Get the path from the file.
    blockFilePath = fileparts(wormFile);
    
    % Use the current path.
    if isempty(blockFilePath)
        blockFilePath = pwd;
    end
    
% Clean up memory.
else
    clear('block1');
end

% Determine the variables (the blocks are in separate files).
if ~isempty(blockFilePath)
    
    % Load the worm information.
    load(wormFile, 'SAMPLES', 'myAviInfo', 'pixel2MicronScale', ...
        'normBlockList');
    
    % Check the variables.
    varName = 'SAMPLES';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    else
        samples = SAMPLES;
    end
    varName = 'myAviInfo';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    else
        fps = myAviInfo.fps;
    end
    varName = 'pixel2MicronScale';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'normBlockList';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    
    % Determine the number of blocks.
    blocks = length(normBlockList);
    
    % Determine the block size.
    load(fullfile(blockFilePath, normBlockList{1}));
    eval(['block = ' normBlockList{1} ';']);
    clear(normBlockList{1});
    blockSize = size(block{1}, 2);
    
    % Determine the first and last frame.
    firstFrame = 0;
    load(fullfile(blockFilePath, normBlockList{end}));
    eval(['block = ' normBlockList{end} ';']);
    clear(normBlockList{end});
    lastBlockSize = size(block{1}, 2);
    lastFrame = (blocks - 1) * blockSize + lastBlockSize - 1; 
    clear('block');
    
% Check the variables (the blocks are in a single file).
else
    
    % Load the worm information.
    load(wormFile, 'samples', 'fps', 'firstFrame', 'lastFrame', ...
        'pixel2MicronScale', 'blockSize', 'blocks');
    
    % Check the variables.
    varName = 'samples';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'fps';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'pixel2MicronScale';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'firstFrame';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'lastFrame';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'blockSize';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'blocks';
    if ~exist(varName, 'var')
        error('multiScaleWorm:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
end

% The worms must be normalized.
if isempty(samples)
    error('multiScaleWorm:NotNormalized', ...
        ['The worms in  ''' wormFile ''' are not normalized']);
end

% Determine the samples to use.
meanSamples = [];
if ~isempty(useSamples)
    
    % Determine the samples to combine.
    if iscell(useSamples)
        meanSamples = useSamples;
        useSamples = [];
        
        % Break the worm up into sample groups.
        if length(meanSamples) == 1 && isscalar(meanSamples{1}) && ...
                meanSamples{1} ~= floor(meanSamples{1})
            
            % How many samples in each group?
            numSamples = round(samples * meanSamples{1});
            meanSamples = [];
            useSamples = 1:samples;
            startSample = 1;
            endSample = numSamples;
            
            % Create the sample groups.
            i = 1;
            while endSample < samples
                meanSamples{i} = startSample:endSample;
                startSample = endSample + 1;
                endSample = startSample + numSamples - 1;
                i = i + 1;
            end
            
            % Create the last sample group.
            meanSamples{i} = startSample:samples;
            
        % Determine which samples we need.
        else
            
            % Which samples are we using?
            for i = 1:length(meanSamples)
                useSamples = union(useSamples, meanSamples{i});
            end
            useSamples = sort(useSamples);
            
            % Are the samples in range?
            if useSamples(1) < 1
                error('multiScaleWorm:BadSample', ['Sample ' ...
                    num2str(useSamples(1)) ' is out of range']);
            end
            if useSamples(end) > samples
                error('multiScaleWorm:BadSample', ['Sample ' ...
                    num2str(useSamples(end)) ' is out of range']);
            end
            
            % Switch the samples to their useSample indices.
            for i = 1:length(meanSamples)
                for j = 1:length(meanSamples{i})
                    meanSamples{i}(j) = ...
                        find(meanSamples{i}(j) == useSamples, 1);
                end
            end
        end
        
    % Compute the samples to use.
    elseif isscalar(useSamples) && useSamples ~= floor(useSamples)
        useSampleSize = round(samples * useSamples);
        
        % Use the middle sample.
        if useSampleSize == 1
            useSamples = round((samples + 1) / 2);
            
        % Compute the sample indices to use.
        % Note: we offset then scale the existing samples so that they lie
        % on the interval spanning 0 to 1. Then we divide this interval
        % into the requested number of new samples where 0 and 1 are,
        % respectively, the first and last new samples. Finally, we
        % de-scale and de-offset the interval to obtain the indices to
        % choose from the exisiting samples.
        else
            useSamples = round((samples - 1) * ...
                ((0:(useSampleSize - 1)) / (useSampleSize - 1))) + 1;
        end
    end
        
end

% Check the starting frame.
if isempty(startFrame)
    startFrame = firstFrame;
elseif startFrame ~= floor(startFrame)
    startFrame = round(startFrame * fps);
end
if startFrame < firstFrame
    error('multiScaleWorm:StartFrame', ['The requested starting frame ' ...
        num2str(startFrame) ' is less than the first frame ' ...
        num2str(firstFrame) ' in ''' wormFile '''']);
elseif startFrame > lastFrame
    error('multiScaleWorm:StartFrame', ['The requested starting frame ' ...
        num2str(startFrame) ' is greater than the last frame ' ...
        num2str(lastFrame) ' in ''' wormFile '''']);
end

% Check the ending frame.
if isempty(endFrame)
    endFrame = lastFrame;
elseif endFrame ~= floor(endFrame)
    endFrame = round(endFrame * fps);
end
if endFrame < firstFrame
    error('multiScaleWorm:EndFrame', ['The requested ending frame ' ...
        num2str(endFrame) ' is less than the first frame ' ...
        num2str(firstFrame) ' in ''' wormFile '''']);
elseif endFrame > lastFrame
    error('multiScaleWorm:EndFrame', ['The requested ending frame ' ...
        num2str(endFrame) ' is greater than the last frame ' ...
        num2str(lastFrame) ' in ''' wormFile '''']);
end

% Correct the data types.
startFrame = double(startFrame);
endFrame = double(endFrame);
samples = double(samples);
fps = double(fps);
firstFrame = double(firstFrame);
lastFrame = double(lastFrame);
blockSize = double(blockSize);
blocks = double(blocks);

% Are we interpolating the missing data?
isInterp = false;
if lower(type(1)) == 'i'
    isInterp = true;
    type = 'ee';
end

% Compute the scales.
scales = round(scales * fps);

% Check the scales.
isAtT1 = false;
if isAtT1
    badScalesMask = scales >= endFrame - firstFrame + 1;
else
    badScalesMask = scales >= lastFrame - startFrame + 1;
end
if any(badScalesMask)
    
    % Remove scales that are too large.
    badScales = scales(badScalesMask);
    scales(badScalesMask) = [];
    for i = 1:length(badScales)
        warning('multiScaleWorm:BadScale', ['The %.3f second ' ...
            'differentiation cannot be computed as their are an ' ...
            'insufficient number of frames'], badScales(i) / fps);
    end
end

% There are no scales to compute.
if isempty(scales)
    warning('multiScaleWorm:NoScales', ...
        'There are no scales to differentiate');
    diffData = [];
    return;
end

% Determine the method for computing orientation.
switch htDirMode
    
    % Use the head and tail end points.
    case 1,
        htDirSamples = fliplr([1 samples]);
        if ~isempty(useSamples)
            if ~any(useSamples == htDirSamples(1)) || ...
                    ~any(useSamples == htDirSamples(end))
                htDirSamples = fliplr([1 length(useSamples)]);
                warning('multiScaleWorm:Orientation', ...
                    ['The samples necessary to compute the head-to-tail ' ...
                    'orientation are not available! Using points ' ...
                    num2str(min(useSamples)) ' and ' ...
                    num2str(max(useSamples)) ' instead.']);
                
                % Convert the samples to their subsample index.
            else
                for i = 1:length(htDirSamples)
                    htDirSamples(i) = find(htDirSamples(i) == useSamples);
                end
            end
        end
        
    % Use the head and tail start points.
    case 2,
        htPoint = ceil(samples / 6);
        htDirSamples = fliplr([htPoint, samples - htPoint + 1]);
        if ~isempty(useSamples)
            if ~any(useSamples == htDirSamples(1)) || ...
                    ~any(useSamples == htDirSamples(end))
                htDirSamples = fliplr([1 length(useSamples)]);
                warning('multiScaleWorm:Orientation', ...
                    ['The samples necessary to compute the head-to-tail ' ...
                    'orientation are not available! Using points ' ...
                    num2str(min(useSamples)) ' and ' ...
                    num2str(max(useSamples)) ' instead.']);
                
                % Convert the samples to their subsample index.
            else
                for i = 1:length(htDirSamples)
                    htDirSamples(i) = find(htDirSamples(i) == useSamples);
                end
            end
        end
        
    % Use the average orientation of the worm.
    case 3,
        htDirSamples = fliplr(1:samples);
        if ~isempty(useSamples)
            if ~any(useSamples == htDirSamples(1)) || ...
                    ~any(useSamples == htDirSamples(end))
                htDirSamples = fliplr(1:length(useSamples));
                warning('multiScaleWorm:Orientation', ...
                    ['The samples necessary to compute the head-to-tail ' ...
                    'orientation are not available! Using all available ' ...
                    'points from ' ...
                    num2str(min(useSamples)) ' to ' ...
                    num2str(max(useSamples)) ' instead.']);
                
                % Convert the samples to their subsample index.
            else
                for i = 1:length(htDirSamples)
                    htDirSamples(i) = find(htDirSamples(i) == useSamples);
                end
            end
        end
        
    % Use the average orientation of the worm midbody.
    otherwise,
        htPoint = ceil(samples / 6);
        htDirSamples = fliplr(htPoint:(samples - htPoint + 1));
        if ~isempty(useSamples)
            if ~any(useSamples == htDirSamples(1)) || ...
                    ~any(useSamples == htDirSamples(end))
                htDirSamples = fliplr(1:length(useSamples));
                warning('multiScaleWorm:Orientation', ...
                    ['The samples necessary to compute the head-to-tail ' ...
                    'orientation are not available! Using all available ' ...
                    'points from ' ...
                    num2str(min(useSamples)) ' to ' ...
                    num2str(max(useSamples)) ' instead.']);
                
                % Convert the samples to their subsample index.
            else
                for i = 1:length(htDirSamples)
                    htDirSamples(i) = find(htDirSamples(i) == useSamples);
                end
            end
        end
end

% Pre-allocate memory.
noise = 0; % the noise threshold
if isNoisy
    noise = 2 * sqrt(sum(pixel2MicronScale .^ 2));
end
dataSize = 16;
diffData = cell(dataSize,1);
for i = 2:dataSize
    diffData{i} = cell(length(scales),1);
end

% Differentiate the sparse data.
blockInfo = []; % the information for the loaded blocks
if isSparse

    % Load the data.
    if isAtT1
        startScaleFrames = max(scales(scales <= startFrame));
        if isempty(startScaleFrames)
            startScaleFrames = 0;
        end
        endScaleFrames = 0;
    else
        startScaleFrames = 0;
        endScaleFrames = max(scales(scales <= (lastFrame - endFrame)));
        if isempty(endScaleFrames)
            endScaleFrames = 0;
        end
    end
    [dataInfo blockInfo] = loadData(wormFile, ...
        startFrame - startScaleFrames, endFrame + endScaleFrames, ...
        firstFrame, blocks, blockSize, blockInfo, useSamples, isInterp);
    
    % Which frames can we use?
    frameData = dataInfo.data{1}; % the frame data
    if ~isempty(useFrames)
        useDataFrames = useFrames((dataInfo.startUseFrame - ...
            startFrame + 1):(dataInfo.endUseFrame - startFrame + 1));
        frameData(~useDataFrames) = 'u';
    end
    useDataFrames = frameData == 's';
    frameData = frameData( ...
        (dataInfo.startDataFrameI + startScaleFrames): ...
        (dataInfo.endDataFrameI - endScaleFrames));
    
    % Store the frame data.
    diffData{1} = frameData;
    
    % Differentiate the normalized worm data.
    [splitDiffData diffDataUsedFramesI] = ...
        multiScaleDiff(dataInfo.data(2:end), useDataFrames, ...
        dataInfo.startDataFrameI + startScaleFrames, ...
        dataInfo.endDataFrameI - endScaleFrames, 1 / fps, type, scales, ...
        isSparse, isAtT1);

    % Is there any differentiated data?
    if isempty(diffDataUsedFramesI)
        return;
    end
    
    % Store the data's frames at each scale.
    for j = 1:length(scales)
        if ~isempty(diffDataUsedFramesI{j})
            diffData{2}{j} = diffDataUsedFramesI{j} + ...
                (dataInfo.startUseFrame - 1);
        end
    end
    
    % Compute the data groups.
    if ~isempty(meanSamples)
        for j = 1:length(splitDiffData)
            for k = 1:length(scales)
                if ~isempty(diffDataUsedFramesI{k})
                    if size(splitDiffData{j}{k}, 1) > 1
                        splitDiffData{j}{k} = ...
                            meanData(splitDiffData{j}{k}, meanSamples);
                    end
                end
            end
        end
    end
    
    % Merge the split data.
    dataCellOff = 0;
    diffDataOff = 3;
    block = blockInfo.blocks{1};
    for j = 3:(length(block) + 1)
        
        % Store 2-dimensional data.
        if ndims(block{j - 1}) <= 2
            
            % Advance the split data.
            dataCellOff = dataCellOff + 1;
                
            % Store the new data.
            for k = 1:length(scales)
                
                % Is there any differentiated data?
                if isempty(diffDataUsedFramesI{k})
                    continue;
                end
        
                % Store the new data.
                splitDiffData{dataCellOff}{k} ...
                    (abs(splitDiffData{dataCellOff}{k}) < noise) = 0;
                diffData{diffDataOff}{k} = splitDiffData{dataCellOff}{k};
            end
            
            % Advance the merged data.
            diffDataOff = diffDataOff + 1;
            
        % Compute the magnitude for multi-dimensional data, then store.
        else
            
            % Compute the magnitude.
            for k = 1:length(scales)
                
                % Is there any differentiated data?
                if isempty(diffDataUsedFramesI{k})
                    continue;
                end
        
                % Compute the magnitude.
                splitDiffData{dataCellOff + 1}{k} ...
                    (abs(splitDiffData{dataCellOff + 1}{k}) < noise) = 0;
                diffData{diffDataOff}{k} = ...
                    splitDiffData{dataCellOff + 1}{k} .^ 2;
                for dim = 2:size(block{j - 1}, 2)
                    splitDiffData{dataCellOff + dim}{k} ...
                        (abs(splitDiffData{dataCellOff + dim}{k}) < ...
                        noise) = 0;
                    diffData{diffDataOff}{k} = ...
                        diffData{diffDataOff}{k} + ...
                        splitDiffData{dataCellOff + dim}{k} .^ 2;
                end
                diffData{diffDataOff}{k} = sqrt(diffData{diffDataOff}{k});
                
                % Compute the direction.
                if size(block{j - 1}, 2) == 2
                    diffData{diffDataOff + 1}{k} = ...
                        atan2(splitDiffData{dataCellOff + 2}{k}, ...
                        splitDiffData{dataCellOff + 1}{k}) * 180 / pi;
                    
                    % Sign the magnitude.
                    if length(useSamples) ~= 1
                        
                        % Compute the initial sample orientation.
                        htDirX = ...
                            mean(diff(dataInfo.data{dataCellOff + 2} ...
                            (htDirSamples,diffDataUsedFramesI{k}(1,:)), ...
                            1, 1), 1);
                        htDirY = ...
                            mean(diff(dataInfo.data{dataCellOff + 3} ...
                            (htDirSamples,diffDataUsedFramesI{k}(1,:)), ...
                            1, 1), 1);
                        htDir = atan2(htDirY, htDirX) * 180 / pi;
                        
                        % Compute the differences in direction.
                        diffDir = zeros(size(diffData{diffDataOff}{k}));
                        for l = 1:size(diffDir, 1)
                            diffDir(l,:) = htDir - ...
                                diffData{diffDataOff + 1}{k}(l,:);
                        end
                        wrap = diffDir >= 180;
                        diffDir(wrap) = diffDir(wrap) - 360;
                        wrap = diffDir <= -180;
                        diffDir(wrap) = diffDir(wrap) + 360;
                        
                        % Are we computing the absolute direction?
                        if ~isAbsDir
                            velocityDir = diffDir;
                            if ventralMode < 2 % + = dorsal direction
                                velocityDir = -velocityDir;
                            end
                            diffData{diffDataOff + 1}{k} = velocityDir;
                        end
                        
                        % Sign the magnitude.
                        negDir = abs(diffDir) > 90;
                        diffData{diffDataOff}{k}(negDir) = ...
                            -diffData{diffDataOff}{k}(negDir);
                        
                    end
                end
            end
            
            % Advance.
            dataCellOff = dataCellOff + size(block{j - 1}, 2);
            if size(block{j - 1}, 2) == 2
                diffDataOff = diffDataOff + 2;
            else
                diffDataOff = diffDataOff + 1;
            end
        end
    end

% Differentiate the data, in blocks, then merge.
else
    startBlockI = ... % the starting block's index
        floor((startFrame - firstFrame) / blockSize) + 1;
    endBlockI = ... % the ending block's index
        floor((endFrame - firstFrame) / blockSize) + 1;
    for i = startBlockI:endBlockI
        
        % Compute the data offset in the starting block.
        if i == startBlockI
            startDataBlockOffI = startFrame - firstFrame + 1 - ...
                ((i - 1) * blockSize);
        else
            startDataBlockOffI = 1;
        end
        
        % Compute the data offset in the ending block.
        if i == endBlockI
            endDataBlockOffI = endFrame - firstFrame + 1 - ...
                ((i - 1) * blockSize);
        else
            endDataBlockOffI = blockSize;
        end
        
        % Compute the start and end frames.
        startDataBlockFrame = startDataBlockOffI + ...
            ((i - 1) * blockSize) + firstFrame - 1;
        endDataBlockFrame = endDataBlockOffI + ((i - 1) * blockSize) ...
            + firstFrame - 1;
        
        % Load the data.
        if isAtT1
            startScaleFrames = ...
                max(scales(scales <= startDataBlockFrame - firstFrame));
            if isempty(startScaleFrames)
                startScaleFrames = 0;
            end
            endScaleFrames = 0;
        else
            startScaleFrames = 0;
            endScaleFrames = ...
                max(scales(scales <= (lastFrame - endDataBlockFrame)));
            if isempty(endScaleFrames)
                endScaleFrames = 0;
            end
        end
        [dataInfo blockInfo] = loadData(wormFile, ...
            startDataBlockFrame - startScaleFrames, ...
            endDataBlockFrame + endScaleFrames, ...
            firstFrame, blocks, blockSize, blockInfo, useSamples, isInterp);
        
        % Which frames can we use?
        blockFrameData = dataInfo.data{1}; % the frame data for the block
        if ~isempty(useFrames)
            useBlockFrames = useFrames((dataInfo.startUseFrame - ...
                startFrame + 1):(dataInfo.endUseFrame - startFrame + 1));
            blockFrameData(~useBlockFrames) = 'u';
        end
        useBlockFrames = blockFrameData == 's';
        blockFrameData = blockFrameData( ...
            (dataInfo.startDataFrameI + startScaleFrames): ...
            (dataInfo.endDataFrameI - endScaleFrames));
        
        % Merge the frame data.
        diffData{1}((end + 1):(end + length(blockFrameData))) = ...
            blockFrameData;
        
        % Differentiate the normalized worm data.
        [blockDiffData blockDiffDataUsedFramesI] = ...
            multiScaleDiff(dataInfo.data(2:end), useBlockFrames, ...
            dataInfo.startDataFrameI + startScaleFrames, ...
            dataInfo.endDataFrameI - endScaleFrames, 1 / fps, type, ...
            scales, isSparse, isAtT1);
        
        % Was there any data to differentiate?
        if isempty(blockDiffDataUsedFramesI)
            continue;
        end
            
        % Store the data's frames at each scale.
        for j = 1:length(scales)
            if ~isempty(blockDiffDataUsedFramesI{j})
                newData = blockDiffDataUsedFramesI{j};
                diffData{2}{j}(:,(end + 1):(end + size(newData, 2))) = ...
                    newData + (dataInfo.startUseFrame - 1);
            end
        end
        
        % Compute the data groups.
        if ~isempty(meanSamples)
            for j = 1:length(blockDiffData)
                for k = 1:length(scales)
                    if ~isempty(blockDiffDataUsedFramesI{k})
                        if size(blockDiffData{j}{k}, 1) > 1
                            blockDiffData{j}{k} = ...
                                meanData(blockDiffData{j}{k}, meanSamples);
                        end
                    end
                end
            end
        end
    
        % Merge the block of split data.
        dataCellOff = 0;
        diffDataOff = 3;
        block = blockInfo.blocks{1};
        for j = 3:(length(block) + 1)
            
            % Merge 2-dimensional data.
            if ndims(block{j - 1}) <= 2
                
                % Advance the split data.
                dataCellOff = dataCellOff + 1;
                
                % Merge the new data.
                for k = 1:length(scales)
                    
                    % Is there any differentiated data?
                    if isempty(blockDiffDataUsedFramesI{k})
                        continue;
                    end
                    
                    % Merge the new data.
                    newData = blockDiffData{dataCellOff}{k};
                    newData(abs(newData) < noise) = 0;
                    diffData{diffDataOff}{k} ...
                        (:,(end + 1):(end + size(newData, 2))) = newData;
                end
                
                % Advance the merged data.
                diffDataOff = diffDataOff + 1;
            
            % Compute the magnitude for multi-dimensional data, then merge.
            else
                
                % Compute the magnitude and merge the new data.
                for k = 1:length(scales)
                    
                    % Is there any differentiated data?
                    if isempty(blockDiffDataUsedFramesI{k})
                        continue;
                    end
                    
                    % Compute the magnitude
                    blockDiffData{dataCellOff + 1}{k} ...
                        (abs(blockDiffData{dataCellOff + 1}{k}) < ...
                        noise) = 0;
                    newData = blockDiffData{dataCellOff + 1}{k} .^ 2;
                    for dim = 2:size(block{j - 1}, 2)
                        blockDiffData{dataCellOff + 1}{k} ...
                            (abs(blockDiffData{dataCellOff + dim}{k}) < ...
                            noise) = 0;
                        newData = newData + ...
                            blockDiffData{dataCellOff + dim}{k} .^ 2;
                    end
                    newData = sqrt(newData);
                    
                    % Compute the direction.
                    if size(block{j - 1}, 2) == 2
                        diffData{diffDataOff + 1}{k} ...
                            (:,(end + 1):(end + size(newData, 2))) = ...
                            atan2(blockDiffData{dataCellOff + 2}{k}, ...
                            blockDiffData{dataCellOff + 1}{k}) * 180 / pi;
                        
                        % Sign the magnitude.
                        if length(useSamples) ~= 1
                            
                            % Compute the initial sample orientation.
                            htDirX = ...
                                mean(diff( ...
                                dataInfo.data{dataCellOff + 2} ...
                                (htDirSamples, ...
                                blockDiffDataUsedFramesI{k}(1,:)), ...
                                1, 1), 1);
                            htDirY = ...
                                mean(diff( ...
                                dataInfo.data{dataCellOff + 3} ...
                                (htDirSamples, ...
                                blockDiffDataUsedFramesI{k}(1,:)), ...
                                1, 1), 1);
                            htDir = atan2(htDirY, htDirX) * 180 / pi;
                            
                            % Compute the differences in direction.
                            diffDir = zeros(size(newData));
                            for l = 1:size(diffDir, 1)
                                diffDir(l,:) = htDir - ...
                                    diffData{diffDataOff + 1}{k} ...
                                    (l,(end - size(newData, 2) + 1):end);
                            end
                            wrap = diffDir >= 180;
                            diffDir(wrap) = diffDir(wrap) - 360;
                            wrap = diffDir <= -180;
                            diffDir(wrap) = diffDir(wrap) + 360;
                            
                            % Are we computing the absolute direction?
                            if ~isAbsDir
                                velocityDir = diffDir;
                                if ventralMode < 2 % + = dorsal direction
                                    velocityDir = -velocityDir;
                                end
                                diffData{diffDataOff + 1}{k} ...
                                    (:,(end - size(newData, 2) + 1):end) = ...
                                    velocityDir;
                            end
                            
                            % Sign the magnitude.
                            negDir = abs(diffDir) > 90;
                            newData(negDir) = -newData(negDir);
                        end
                    end

                    % Store the signed magnitude.
                    diffData{diffDataOff}{k}(:,(end + 1): ...
                        (end + size(newData, 2))) = newData;
                end
                
                % Advance.
                dataCellOff = dataCellOff + size(block{j - 1}, 2);
                if size(block{j - 1}, 2) == 2
                    diffDataOff = diffDataOff + 2;
                else
                    diffDataOff = diffDataOff + 1;
                end
            end
        end
    end
end

% Offset the data to the correct time.
switch offMode
    
    % Offset the data to the center of the differentiated scale.
    case 1
        for j = 1:length(scales)
            offStart = round((scales(j) + 1) / 2);
            offEnd = scales(j) - offStart;
            for i = 2:length(diffData)
                tmp = nan(size(diffData{i}{j}));
                tmp(:,(1 + offStart):(end - offEnd)) = ...
                    diffData{i}{j}(:,1:(end - scales(j)));
                diffData{i}{j} = tmp;
            end
        end
        
        % Offset the data to the start of the differentiated scale.
    case 2
        for j = 1:length(scales)
            for i = 2:length(diffData)
                tmp = nan(size(diffData{i}{j}));
                tmp(:,1:(end - scales(j))) = ...
                    diffData{i}{j}(:,1:(end - scales(j)));
                diffData{i}{j} = tmp;
            end
        end
        
        % Offset the data to the end of the differentiated scale.
    case 3
        for j = 1:length(scales)
            for i = 2:length(diffData)
                tmp = nan(size(diffData{i}{j}));
                tmp(:,(1 + scales(j)):end) = ...
                    diffData{i}{j}(:,1:(end - scales(j)));
                diffData{i}{j} = tmp;
            end
        end
        
    otherwise
        warning('multiScaleWorm:OffsetMode', ...
            ['Offset mode "' num2str(offMode) ...
            '" is an unknown mode. Using mode 1 (offset to the ' ...
            'center of the differentiated scale) instead.']);
end

% Clear the global variable link.
clear blockFilePath;

% Show the results in a figure.
if verbose
    
    % What data are we showing?
    if isempty(showData)
        showData = 1:14;
    end
    
    % Construct the figure titles.
    titles = { ...
        'Vulval Contour Velocity', ...
        'Vulval Contour Velocity Direction', ...
        'Non-Vulval Contour Velocity', ...
        'Non-Vulval Contour Velocity Direction', ...
        'Skeleton Velocity', ...
        'Skeleton Velocity Direction', ...
        'Skeleton Angle Change', ...
        'Skeleton Touching Points Velocity', ...
        'Skeleton Length Change', ...
        'Contour Width Change', ...
        'Head Area Change', ...
        'Tail Area Change', ...
        'Vulval-Side Area Change', ...
        'Non-Vulval-Side Area Change'};
    
    % Construct the figure y-axis labels.
    yLabels = { ...
        'Microns / Second', ...
        'Orientation Angle (degrees)', ...
        'Microns / Second', ...
        'Orientation Angle (degrees)', ...
        'Microns / Second', ...
        'Orientation Angle (degrees)', ...
        '\Delta Bend Angle (degrees)', ...
        '\Delta Microns', ...
        '\Delta Microns', ...
        '\Delta Microns', ...
        '\Delta Microns Squared', ...
        '\Delta Microns Squared', ...
        '\Delta Microns Squared', ...
        '\Delta Microns Squared'};
    
    % Construct the figure scales.
    scaleStrings = cell(length(scales),1);
    for i = 1:length(scales)
        if scales(i) < fps
            scaleStrings{i} = ['Scale =  ' ...
                num2str(round(1000 * scales(i) / fps)) ...
                ' milliseconds'];
        else
            scaleStrings{i} = ['Scale = ' ...
                num2str(scales(i) / fps, '%0.2f') ' seconds'];
        end
    end
    
    % Construct the frame infomation legend.
    legends = { ...
        'Unused Frames', ...
        'Segmentation Failures', ...
        'Stage Movements', ...
        'Dropped Frames'};
    
    % Construct the data legend.
    dataLegends = legends;
    dataLegends{end + 1} = 'Data';
    
    % Compute the samples to use.
    if isempty(useSamples)
        useSamples = 1:samples;
    end
    
    % Pre-allocate memory.
    sampleLegends = legends;
    if isempty(sampleLegends)
        legendsOff = 0;
        if isempty(meanSamples)
            sampleLegends = cell(length(useSamples),1);
        else
            sampleLegends = cell(length(meanSamples),1);
        end
        
    % Append the worm samples legend.
    else
        legendsOff = length(sampleLegends);
        if isempty(meanSamples)
            sampleLegends((legendsOff + 1): ...
                (legendsOff + length(useSamples))) = ...
                cell(length(useSamples),1);
        else
            sampleLegends((legendsOff + 1): ...
                (legendsOff + length(meanSamples))) = ...
                cell(length(meanSamples),1);
        end
    end
    
    % Construct the worm samples legend.
    if isempty(meanSamples)
        
        % Label the samples.
        for i = 1:length(useSamples)
            
            % Label the head.
            if useSamples(i) == 1
                sampleLegends{legendsOff + i} = 'Head';
                
            % Label the tail.
            elseif useSamples(i) == samples
                sampleLegends{legendsOff + i} = 'Tail';
                
            % Label the middle.
            elseif useSamples(i) == (samples + 1) / 2
                sampleLegends{legendsOff + i} = 'Middle';
                
            % Label the fractional point.
            else
                sampleLegends{legendsOff + i} = ...
                    [num2str((useSamples(i) - 1) / (samples - 1), ...
                    '%0.2f') ' of the worm'];
            end
        end
        
    % Label the groups of samples.
    else
        for i = 1:length(meanSamples)
            
            % Compute the group samples and their spacing.
            groupSamples = useSamples(sort(meanSamples{i}));
            groupDiffs = diff(groupSamples);
            groupDiffsI = find(groupDiffs ~= 1);
            
            % Record the only sample.
            if length(groupSamples) == 1
                legendStr = ...
                    num2str((groupSamples(1) - 1) / (samples - 1), ...
                    '%0.2f');
                
            % Record a continuous sample.
            elseif isempty(groupDiffsI)
                legendStr = ...
                    [num2str((groupSamples(1) - 1) / (samples - 1), ...
                    '%0.2f') '-' ...
                    num2str((groupSamples(end) - 1) / (samples - 1), ...
                    '%0.2f')];
                
            % Record the samples.
            else
                legendStr = [];
                prevSample = groupSamples(1) - 1;
                for k = 1:length(groupDiffsI)
                    
                    % Place a comma between discontinuities.
                    if k > 1
                        legendStr = [legendStr ',' ];
                    end
                    
                    % Record the lone sample.
                    sample = groupSamples(groupDiffsI(k));
                    if groupDiffsI(k) == prevSample + 1
                        legendStr = [legendStr ...
                            num2str((sample - 1) / (samples - 1), ...
                            '%0.2f')];
                        
                    % Record the continuous sequence.
                    else
                        prevSample = prevSample + 1;
                        legendStr = [legendStr ...
                            num2str((prevSample - 1) / (samples - 1), ...
                            '%0.2f') '-' ...
                            num2str((sample - 1) / (samples - 1), ...
                            '%0.2f')];
                    end
                    
                    % Advance.
                    prevSample = sample;
                end
            
                % Record the last sample.
                legendStr = [legendStr ',' ];
                sample = groupSamples(end);
                
                % Record the lone sample.
                if groupDiffs(end) > 1
                    legendStr = [legendStr ...
                        num2str((sample - 1) / (samples - 1), ...
                        '%0.2f')];
                    
                % Record the continuous sequence.
                else
                    prevSample = prevSample + 1;
                    legendStr = [legendStr ...
                        num2str((prevSample - 1) / (samples - 1), ...
                        '%0.2f') '-' ...
                        num2str((sample - 1) / (samples - 1), ...
                        '%0.2f')];
                end
            end
            
            % Record the legend.
            sampleLegends{legendsOff + i} = [legendStr ' of the worm'];
        end
    end
    
    % Construct the figures.
    for i = (showData + 2)
        
        % Skip the skeleton touching points' velocity.
        if i == 10
            continue;
        end
        
        % Open a big figure.
        figure('OuterPosition', [50 -50 1280 960]);
        
        % Plot the data at each scale.
        for j = 1:length(scales)
            
            % Compute the x-axis time.
            if isSparse
                timeX = (startFrame:scales(j):endFrame) / fps;
            else
                timeX = (startFrame:endFrame) / fps;
            end
                
            % Plot the data and frame information.
            if verbose - floor(verbose) == 0.5
                
                % Compute the data range.
                minData = min(diffData{i}{j}(:));
                maxData = max(diffData{i}{j}(:));
                
                % Setup the data plot.
                h = subplot(length(scales), 1, j);
                set(zoom(h), 'Motion', 'horizontal', 'Enable', 'on');
                hold on;
                
                % Plot the data and frame information on the same axis.
                dataScale = (maxData - minData) * .999999999;
                frameX = startFrame:endFrame;
                [ax h1 h2] = plotyy(frameX, ...
                    (diffData{1} == 'u') * dataScale + minData, ...
                    timeX, diffData{i}{j});
                set(ax(2), 'XAxisLocation', 'top');
                set(h1, 'Color', 'y');
                if size(diffData{i}{j}, 1) == 1
                    set(h2, 'Color', 'k');
                end
                if 0 && any(i == [4 6 8])
                    set(h2, 'LineStyle', 'none');
                    set(h2, 'Marker', '.');
                end
                
                % Setup the data axes numbering.
                linkaxes(ax, 'y');
                if length(frameX) > 1
                    
                    % Frames.
                    xlim(ax(1), [frameX(1), frameX(end)]);
                    
                    % Seconds.
                    xlim(ax(2), [frameX(1) / fps, frameX(end) / fps]);
                end
                if minData ~= maxData
                    
                    % Differentiation data.
                    ylim(ax(1), [minData maxData]);
                    
                    % Frame data.
                    set(ax(1), 'YTick', minData:(dataScale / 5):maxData);
                end
                set(ax(2), 'YTick', []);
                
                % Setup the data axes labels.
                xlabel(ax(1), 'Frame');
                ylabel(ax(1), yLabels{i - 2});
                xlabel(ax(2), 'Time (seconds)');
                title(ax(2), [titles{i - 2} ' (' scaleStrings{j} ')']);
                
                % Plot the failed frames.
                plot(ax(1), frameX, ...
                    (diffData{1} == 'f') * dataScale + minData, 'm');
                
                % Plot the stage movements.
                plot(ax(1), frameX, ...
                    (diffData{1} == 'm') * dataScale + minData, 'g');
                
                % Plot the dropped frames.
                plot(ax(1), frameX, ...
                    (diffData{1} == 'd') * dataScale + minData, 'c');
                
                % Setup the data legend.
                if i > 10 && i ~= 12
                    legend(dataLegends, 'Location', 'NorthEast');
                else
                    legend(sampleLegends, 'Location', 'NorthEast');
                end
                
            % Plot the data.
            else
                
                % Setup the data plot.
                h = subplot(length(scales), 1, j);
                set(zoom(h), 'Motion', 'horizontal', 'Enable', 'on');
                hold on;
                
                % Plot the data.
                if size(diffData{i}{j}, 1) == 1
                    h = plot(timeX, diffData{i}{j}, 'k');
                else
                    h = plot(timeX, diffData{i}{j});
                end
                if 0 && any(i == [4 6 8])
                    set(h, 'LineStyle', 'none');
                    set(h, 'Marker', '.');
                end
                
                % Setup the data axes numbering.
                if startFrame ~= endFrame
                    xlim([startFrame / fps, endFrame / fps]);
                end
                
                % Setup the data labels.
                title([titles{i - 2} ' (' scaleStrings{j} ')']);
                xlabel('Time (seconds)');
                ylabel(yLabels{i - 2});
                
                % Setup the data legend.
                if i > 10 && i ~= 12
                    legend(dataLegends(5:end), 'Location', 'NorthEast');
                else
                    legend(sampleLegends(5:end), 'Location', 'NorthEast');
                end
            end
        end
        
        % Plot the histogram.
        if verbose > 1.5
            
            % Open a big figure.
            figure('OuterPosition', [50 -50 1280 960]);
            
            % Plot the histogram at each scale.
            for j = 1:length(scales)
                
                % Compute the data range.
                minData = min(diffData{i}{j}(:));
                maxData = max(diffData{i}{j}(:));
                
                % Compute the x-axis time.
                if isSparse
                    timeX = (startFrame:scales(j):endFrame) / fps;
                else
                    timeX = (startFrame:endFrame) / fps;
                end
                
                % Setup the histogram plot.
                h = subplot(length(scales), 1, j);
                set(zoom(h), 'Motion', 'horizontal', 'Enable', 'on');
                
                % Plot the histogram.
                if sign(minData) == sign(maxData)
                    bins = linspace(minData, maxData, sqrt(length(timeX)));
                else % align the bins with 0
                    binWidth = (maxData - minData) / sqrt(length(timeX));
                    minBins = binWidth:binWidth:(abs(minData) + binWidth);
                    maxBins = 0:binWidth:(maxData + binWidth);
                    bins = [-fliplr(minBins) maxBins];
                end
                histogram = histc(diffData{i}{j}', bins);
                plot(bins, histogram);
                %hist(diffData{i}{j}', sqrt(length(timeX)));
                xlim([minData maxData]);
                
                % Setup the histogram labels.
                title([titles{i - 2} ' Histogram (' scaleStrings{j} ')']);
                xlabel(yLabels{i - 2});
                ylabel('Counts');
                
                % Setup the histogram legend.
                if i > 10 && i ~= 12
                    legend(dataLegends(5:end), 'Location', 'NorthEast');
                else
                    legend(sampleLegends(5:end), 'Location', 'NorthEast');
                end
            end
        end
        
        % Plot the worm's path.
        if verbose > 2.5  && isempty(meanSamples)
            
            % Are we using the contour or skeleton?
            if i - 2 <= 2
                bodyBlockI = 2;
                wormPathString = 'Vulval Contour Path';
            elseif i - 2 <= 4
                bodyBlockI = 3;
                wormPathString = 'Non-Vulval Contour Path';
            else
                bodyBlockI = 4;
                wormPathString = 'Skeleton Path';
            end
            
            % Find the middle.
            bodySampleI = [];
            bodySampleTitles = [];
            middleSample = round((samples + 1) / 2);
            [~, middleI] = min(abs(useSamples - middleSample));
            bodySampleI(1) = middleI;
            if useSamples(middleI) == middleSample
                bodySampleTitles{1} = 'Middle';
            else
                if useSamples(middleI) == 1
                    bodySampleTitles{1} = 'Head';
                elseif  useSamples(middleI) == samples
                    bodySampleTitles{1} = 'Tail';
                else
                    bodySampleTitles{1} = ...
                        [num2str(round(((useSamples(middleI) - 1) / ...
                        (samples - 1)) * 100)) '% From The Head'];
                end
            end
            
            % Find the head and tail.
            if i < 9
                
                % Find the head.
                headI = find(useSamples == 1, 1);
                k = 2;
                if ~isempty(headI) && headI ~= middleI
                    bodySampleI(k) = headI;
                    bodySampleTitles{k} = 'Head';
                    k = k + 1;
                end
                
                % Find the tail.
                tailI = find(useSamples == samples, 1);
                if ~isempty(tailI) && tailI ~= middleI
                    bodySampleI(k) = tailI;
                    bodySampleTitles{k} = 'Tail';
                end
                
            % Find points 1/6 from the head and tail.
            elseif i == 9 || i == 12
                
                % Find the head.
                headSample = round((samples + 1) / 6);
                [~, headI] = min(abs(useSamples - headSample));
                k = 2;
                if useSamples(headI) == 1
                    bodySampleI(k) = headI;
                    bodySampleTitles{k} = 'Head';
                    k = k + 1;
                elseif headI ~= middleI
                    bodySampleI(k) = headI;
                    bodySampleTitles{k} = ...
                        [num2str(round(((useSamples(headI) - 1) / ...
                        (samples - 1)) * 100)) '% From The Head'];
                    k = k + 1;
                end
                
                % Find the tail.
                tailSample = round((samples + 1) * (5 / 6));
                [~, tailI] = min(abs(useSamples - tailSample));
                if useSamples(tailI) == samples
                    bodySampleI(k) = tailI;
                    bodySampleTitles{k} = 'Tail';
                elseif tailI ~= middleI
                    bodySampleI(k) = tailI;
                    bodySampleTitles{k} = ...
                        [num2str(round(((useSamples(tailI) - 1) / ...
                        (samples - 1)) * 100)) '% From The Head'];
                end
                
            % The data applies to the entire worm.
            else
                bodySampleTitles{1} = 'Worm';
            end
            
            % Plot the worm's path at each scale.
            if length(bodySampleI) > 1
                plotRows = 2;
                plotCols = 2;
            else
                plotRows = 1;
                plotCols = 2;
            end
            for j = 1:length(scales)
                
                % Get the locations.
                frames = diffData{2}{j}(2,:);
                frameBlocks = floor(double(frames - firstFrame) / ...
                    blockSize) + 1;
                locations = zeros(length(useSamples),2,length(frames));
                lengths = zeros(length(frames),1);
                off = 1;
                for k = frameBlocks(1):frameBlocks(end)
                    blockInfo = loadBlock(wormFile, k);
                    framesI = frames(frameBlocks == k) - firstFrame + ...
                        1 - ((k - 1) * blockSize);
                    locations(:,:,off:(off + length(framesI) - 1)) = ...
                        blockInfo.blocks{1}{bodyBlockI} ...
                        (useSamples,:,framesI);
                    lengths(off:(off + length(framesI) - 1)) = ...
                        blockInfo.blocks{1}{7}(framesI);
                    off = off + length(framesI);
                end
                
                % Open a big figure.
                figure('OuterPosition', [50 -50 1280 960]);
            
                % Plot the worm's path.
                ax = zeros(1 + length(bodySampleI),1);
                ax(1) = subplot(plotRows, plotCols, 1);
                hold on;
                x = squeeze(locations(:,1,:));
                y = squeeze(locations(:,2,:));
                if length(useSamples) == 1
                    x = x';
                    y = y';
                end
                colors = lines(length(useSamples));
                for k = 1:length(useSamples)
                    quiver(x(k,1:end-1), y(k,1:end-1), ...
                        diff(x(k,:)), diff(y(k,:)), 0, 'Color', ...
                        colors(k,:));
                end
                
                % Plot the path's start and end.
                k = middleI;
                text(x(k,1), y(k,1), ...
                    ['\bf\leftarrow\color{black}Start'], ...
                    'HorizontalAlignment', 'left', ...
                    'VerticalAlignment', 'middle');
                text(x(k,end), y(k,end), ...
                    ['\bf\leftarrow\color{black}End'], ...
                    'HorizontalAlignment', 'left', ...
                    'VerticalAlignment', 'middle');
                
                % Label the axes.
                xlabel('X Location (Microns)');
                ylabel('Y Location (Microns)');
                time = round((endFrame - startFrame) / fps);
                timeString = ['(Time = ' num2str(time) ' seconds, ' ...
                    scaleStrings{j} ')'];
                title({wormPathString, timeString});
                legend(sampleLegends(5:end), 'Location', 'Best');
                
                % Plot the worm length.
                minX = min(x(:));
                maxX = max(x(:));
                minY = min(y(:));
                maxY = max(y(:));
                meanLength = round(nanmean(lengths));
                offset = meanLength / 4;
                xLength = minX - [offset, offset + meanLength];
                yLength = minY - [offset, offset];
                plot(xLength, yLength, '-ko', 'LineWidth', 2, ...
                    'MarkerFaceColor', 'g');
                text(xLength(1), yLength(1), ...
                    ['   \color{red}\leftarrow\color{black}   ' ...
                    'Mean Worm Length = \color{red}' ...
                    num2str(meanLength) ' microns'], ...
                    'HorizontalAlignment', 'left', ...
                    'VerticalAlignment', 'middle');
                
                % Fix the axes.
                axis equal;
                xlim([xLength(2) - offset, maxX + offset])
                ylim([yLength(2) - offset, maxY + offset])
                
                % Plot the middle head and tail.
                z = diffData{i}{j};
                minZ = min(diffData{i}{j}(:));
                maxZ = max(diffData{i}{j}(:));
                for k = 1:length(bodySampleI)
                    
                    % Plot the path.
                    ax(k + 1) = subplot(plotRows, plotCols, k + 1);
                    hold on;
                    quiver(x(bodySampleI(k),1:end-1), ...
                        y(bodySampleI(k),1:end-1), ...
                        diff(x(bodySampleI(k),:)), ...
                        diff(y(bodySampleI(k),:)), 0, 'Color', 'k');
                    if i < 10 || i == 12
                        scatter(x(bodySampleI(k),:), ...
                            y(bodySampleI(k),:), 3, z(bodySampleI(k),:), ...
                            'filled');
                    else
                        scatter(x(bodySampleI(k),:), ...
                            y(bodySampleI(k),:), 3, z, 'filled');
                    end
                    h = colorbar;
                    caxis([minZ maxZ]);
                    set(get(h, 'YLabel'), 'String', titles{i - 2});
                    xlabel('X Location (Microns)');
                    ylabel('Y Location (Microns)');
                    title({[bodySampleTitles{k} ' Path'], timeString});
                    
                    % Plot the path's start and end.
                    text(x(bodySampleI(k),1), y(bodySampleI(k),1), ...
                        '\bf\leftarrow\color{black}Start', ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'middle');
                    text(x(bodySampleI(k),end), y(bodySampleI(k),end), ...
                        '\bf\leftarrow\color{black}End', ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'middle');
                    
                    % Plot the worm length.
                    hold on;
                    plot(xLength, yLength, '-ko', 'LineWidth', 2, ...
                        'MarkerFaceColor', 'g');
                    text(xLength(1), yLength(1), ...
                        ['   \color{red}\leftarrow\color{black}   ' ...
                        'Mean Worm Length = \color{red}' ...
                        num2str(meanLength) ' microns'], ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'middle');
                    axis equal;
                end
                
                % Link the axes.
                linkaxes(ax);
                axis equal;
                xlim([xLength(2) - offset, maxX + offset])
                ylim([yLength(2) - offset, maxY + offset])
            end
        end
    end
end
end

% Load a block by index.
function blockInfo = loadBlock(wormFile, index)

% Load the block.
global blockFilePath;
block = [];
if ~isempty(blockFilePath)
    blockName = ['normBlock' num2str(index)];
    load(fullfile(blockFilePath, blockName), blockName);
else
    blockName = ['block' num2str(index)];
    load(wormFile, blockName);
end
eval(['block = ' blockName ';']);

% Organize the block information.
blockInfo = struct('index', index, 'blocks', {{block}});
end

% Load data by index.
function [dataInfo blockInfo] = loadData(wormFile, startFrame, ...
    endFrame, firstFrame, lastBlockI, blockSize, blockInfo, useSamples, ...
    isInterp)

% Load the starting block.
startBlockI = floor(double(startFrame - firstFrame) / blockSize) + 1;
if isempty(blockInfo)
    blockInfo = loadBlock(wormFile, startBlockI);
end

% Find the starting block.
if startBlockI >= blockInfo.index && ...
        startBlockI <= blockInfo.index + length(blockInfo.blocks) - 1
    startBlock = blockInfo.blocks{startBlockI - blockInfo.index + 1};
    newBlockInfo = struct('index', startBlockI, 'blocks', {{startBlock}});
    
% Load the starting block.
else
    newBlockInfo = loadBlock(wormFile, startBlockI);
    startBlock = newBlockInfo.blocks{1};
end

% Search for a usable starting index.
startUseI = startFrame - firstFrame + 1 - ((startBlockI - 1) * blockSize);
while startBlock{1}(startUseI) ~= 's'
    
    % Search in the previous block.
    if startUseI <= 1
        
        % We're at the first block.
        if startBlockI <= 1
            break;
            
        % Find the previous block in the list of loaded blocks.
        elseif startBlockI > blockInfo.index && ...
                startBlockI <= blockInfo.index + length(blockInfo.blocks)
            
            % Find the new starting block.
            startBlock =  blockInfo.blocks{startBlockI - blockInfo.index};
            startBlockI = startBlockI - 1;
            startUseI = blockSize;
            
            % Copy the list of new blocks.
            newBlocks = cell(length(newBlockInfo.blocks) + 1,1);
            for i = 1:length(newBlockInfo.blocks)
                newBlocks{i + 1} = newBlockInfo.blocks{i};
            end
            
            % Update the list of new blocks.
            newBlockInfo.index = startBlockI;
            newBlocks{1} = startBlock;
            newBlockInfo.blocks = newBlocks;
            
        % Load the previous block.
        else
            
            % Load the new starting block.
            startBlockI = startBlockI - 1;
            startBlockInfo = loadBlock(wormFile, startBlockI);
            startBlock = startBlockInfo.blocks{1};
            startUseI = blockSize;
            
            % Copy the list of new blocks.
            newBlocks = cell(length(newBlockInfo.blocks) + 1,1);
            for i = 1:length(newBlockInfo.blocks)
                newBlocks{i + 1} = newBlockInfo.blocks{i};
            end
            
            % Update the list of new blocks.
            newBlockInfo.index = startBlockI;
            newBlocks{1} = startBlockInfo.blocks{1};
            newBlockInfo.blocks = newBlocks;
        end
        
    % Go backwards.
    else
        startUseI = startUseI - 1;
    end
end

% Find any missing blocks.
endBlockI = floor((endFrame - firstFrame) / blockSize) + 1;
newEndBlockI = newBlockInfo.index + length(newBlockInfo.blocks) - 1;
missingBlocks = endBlockI - newEndBlockI;
if missingBlocks > 0
    
    % Copy the list of new blocks.
    newBlocks = cell(length(newBlockInfo.blocks) + missingBlocks,1);
    for i = 1:length(newBlockInfo.blocks)
        newBlocks{i} = newBlockInfo.blocks{i};
    end

    % Copy any missing blocks from the the list of loaded blocks.
    maxStartBlockI = max(newEndBlockI + 1, blockInfo.index);
    oldEndBlockI = blockInfo.index + length(blockInfo.blocks) - 1;
    minEndBlockI = min(endBlockI, oldEndBlockI);
    offset = blockInfo.index - newBlockInfo.index;
    for i = (maxStartBlockI - blockInfo.index + 1): ...
            (minEndBlockI - blockInfo.index + 1)
        newBlocks{i + offset} = blockInfo.blocks{i};
    end
    
    % Load any remaining, missing blocks.
    for i = 1:length(newBlocks)
        if isempty(newBlocks{i})
            missingBlockInfo = loadBlock(wormFile, ...
                newBlockInfo.index + i - 1);
            newBlocks{i} = missingBlockInfo.blocks{1};
        end
    end
    newBlockInfo.blocks = newBlocks;
end

% Search for a usable ending index.
endBlock = newBlockInfo.blocks{end};
endUseI = endFrame - firstFrame + 1 - ((endBlockI - 1) * blockSize);
while endBlock{1}(endUseI) ~= 's'
    
    % Search in the next block.
    if endUseI >= length(endBlock{1})
        
        % We're at the last block.
        if endBlockI >= lastBlockI
            break;
            
        % Find the next block in the list of loaded blocks.
        elseif endBlockI + 1 > blockInfo.index && ...
                endBlockI + 2 <= blockInfo.index + length(blockInfo.blocks)
            
            % Update the list of new blocks.
            endBlockI = endBlockI + 1;
            newBlockInfo.blocks{end + 1} = ...
                blockInfo.blocks{endBlockI - blockInfo.index + 1};
            endBlock = newBlockInfo.blocks{end};
            endUseI = 1;
            
        % Load the next block.
        else
            
            % Update the list of new blocks.
            endBlockI = endBlockI + 1;
            endBlockInfo = loadBlock(wormFile, endBlockI);
            newBlockInfo.blocks{end + 1} = endBlockInfo.blocks{1};
            endBlock = newBlockInfo.blocks{end};
            endUseI = 1;
        end
        
    % Go forwards.
    else
        endUseI = endUseI + 1;
    end
end

% Construct the data.
startUseFrame = ... % the starting usable frame number
    startUseI + ((startBlockI - 1) * blockSize) + firstFrame - 1;
endUseFrame = ... % the ending usable frame number
    endUseI + ((endBlockI - 1) * blockSize) + firstFrame - 1;
blockInfo = newBlockInfo;
data = blocks2Data(blockInfo, startUseFrame, endUseFrame, firstFrame, ...
    blockSize, useSamples); % the data split into matrices of samples x time

% Interpolate the missing data.
if isInterp
    isData = data{1} == 's';
    dataI = find(isData);
    interpI = find(~isData);
    if ~isempty(interpI) && length(dataI) > 1
        for i = 2:length(data)
            for j = 1:size(data{i}, 1)
                if ~all(isnan(data{i}(j,dataI)))
                    data{i}(j,interpI) = ...
                        interp1(dataI, data{i}(j,dataI), interpI, 'linear');
                end
            end
        end
    end
end

% Organize the data information.
startFrameI = startFrame - startUseFrame + 1;
endFrameI = endFrame - startUseFrame + 1;
dataInfo = struct('startUseFrame', startUseFrame, ...
    'endUseFrame', endUseFrame, 'startDataFrameI', startFrameI, ...
    'endDataFrameI', endFrameI, 'data', {data});
end

% Convert a block into differentiable data.
function data = blocks2Data(blockInfo, startFrame, endFrame, ...
    firstFrame, blockSize, useSamples)

% Compute the size of the data.
dataSize = endFrame - startFrame + 1;

% Pre-allocate memory.
dataCells = 0; % the current number of data cells
block = blockInfo.blocks{1}; % a block of data
data = [];
for i = 1:length(block)
    
    % Compute the new cells.
    if ndims(block{i}) <= 2
        newDataCells = 1;
    else
        newDataCells = size(block{i}, 2);
    end
    
    % Compute the new rows.
    newDataRows = size(block{i}, 1);
    if newDataRows > 1 && ~isempty(useSamples)
        newDataRows = length(useSamples);
    end
        
    % Allocate memory.
    dataNaNs = [];
    dataNaNs(newDataRows,1:dataSize) = NaN;
    for j = 1:newDataCells
        data{dataCells + j} = dataNaNs;
    end
    
    % Advance.
    dataCells = dataCells + newDataCells;
end

% Split the data into 2 dimensions, then merge it into singles matrices of
% samples x time.
startBlockI = ... % the starting block's index
    floor((startFrame - firstFrame) / blockSize) + 1;
endBlockI = ... % the ending block's index
    floor((endFrame - firstFrame) / blockSize) + 1;
startBlockInfoI = ... % the starting block's index in the info struct
    blockInfo.index - startBlockI + 1;
endBlockInfoI = ... % the ending block's index in the info struct
    startBlockInfoI + endBlockI - startBlockI;
dataOff = 1; % the merged data offset
for i = startBlockInfoI:endBlockInfoI
    
    % Compute the starting offset in the current block.
    if i == startBlockInfoI
        startBlockOffI = startFrame - firstFrame + 1 - ...
            ((startBlockI - 1) * blockSize);
    else
        startBlockOffI = 1;
    end
    
    % Compute the ending offset in the current block.
    if i == endBlockInfoI
        endBlockOffI = endFrame - firstFrame + 1 - ...
            ((endBlockI - 1) * blockSize);
    else
        endBlockOffI = blockSize;
    end
    
    % Split the data into 2 dimensions, then merge it.
    newDataOff = ... % the current block's new data offset in the merged 
        ...          % data matrix
        dataOff + endBlockOffI - startBlockOffI;
    block = blockInfo.blocks{i}; % the current block
    dataCellOff = 0; % the merged data cell offset
    for j = 1:length(block)
        
        % Merge 2-dimensional data.
        if ndims(block{j}) <= 2
            
            % Advance.
            dataCellOff = dataCellOff + 1;
            
            % Use all samples (or we're only sampling once per frame).
            if isempty(useSamples) || size(block{j}, 1) <= 1
                data{dataCellOff}(:,dataOff:newDataOff) = ...
                    block{j}(:,startBlockOffI:endBlockOffI);
                
            % Only use the specified sampling points.
            else
                data{dataCellOff}(:,dataOff:newDataOff) = ...
                    block{j}(useSamples,startBlockOffI:endBlockOffI);
            end
            
        % Split multi-dimensional data, then merge it as 2-dimensional data.
        else
            for k = 1:size(block{j}, 2)
                
                % Use all samples (or we're only sampling once per frame).
                if isempty(useSamples) || size(block{j}, 1) <= 1
                    data{dataCellOff + k}(:,dataOff:newDataOff) = ...
                        block{j}(:,k,startBlockOffI:endBlockOffI);
                    
                % Only use the specified sampling points.
                else
                    data{dataCellOff + k}(:,dataOff:newDataOff) = ...
                        block{j}(useSamples,k, startBlockOffI:endBlockOffI);
                end
            end
            
            % Advance.
            dataCellOff = dataCellOff + k;
        end
    end
    
    % Advance.
    dataOff = newDataOff + 1;
end
end

% Compute the data mean for the sample groups.
function newData = meanData(data, meanSamples)
newData(1:length(meanSamples),1:size(data,2)) = NaN;
for i = 1:length(meanSamples)
    newData(i,:) = nanmean(data(meanSamples{i},:), 1);
end
end
