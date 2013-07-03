function failedFrames = saveWormFrames(wormFile, videoFile, frames, ...
    blockSize, varargin)
%SAVEWORMFRAMES Segment the worm in a set of video frames and save
%   the information in a file.
%
%   - Save every segmented frame:
%   FAILEDFRAMES = SAVEWORMFRAMES(WORMFILE, VIDEOFILE, FRAMES, BLOCKSIZE)
%
%   - Save segmented frames, normalize the worms:
%   FAILEDFRAMES = SAVEWORMFRAMES(WORMFILE, VIDEOFILE, FRAMES, BLOCKSIZE,
%                                 SAMPLES)
%
%   - Save segmented frames, normalize the worms, exclude stage movements:
%   FAILEDFRAMES = SAVEWORMFRAMES(WORMFILE, VIDEOFILE, FRAMES, BLOCKSIZE,
%                                 SAMPLES, INFOFILE, LOGFILE, DIFFFILE)
%
%   Inputs:
%       wormFile  - the name of the file in which to store the worm blocks.
%                   The file format is MAT (Matlab's '.mat') and contains
%                   the following variables:
%                   
%                   samples      = the samples per normalized worm; if
%                                  empty, the worms are in structs
%                   fps          = frames/seconds
%                   firstFrame   = the first frame number (in block1)
%                   lastFrame    = the last frame number (in the last block)
%                   blockSize    = the size of a block
%                   blocks       = the number of blocks
%                   block1       = the first block
%                   ...
%                   blockN       = the N-th (last) block
%
%                   If the data is normalized, the blocks are cell arrays
%                   with following structure (see normWorms):
%
%                   blockN{1}  = status:
%                                s = segmented
%                                f = segmentation failed
%                                m = stage movement
%                                d = dropped frame
%                   blockN{2}  = vulvaContours
%                   blockN{3}  = nonVulvaContours
%                   blockN{4}  = skeletons
%                   blockN{5}  = angles
%                   blockN{6}  = inOutTouches
%                   blockN{7}  = lengths
%                   blockN{8}  = widths
%                   blockN{9}  = headAreas
%                   blockN{10} = tailAreas
%                   blockN{11} = vulvaAreas
%                   blockN{12} = nonVulvaAreas
%
%                   Otherwise, the blocks are just cell arrays of worm
%                   cells; missing worms are labeled with their frame
%                   status instead:
%
%                   blockN = 1 to, at most, blockSize number of worm cells;
%                            or, for missing worms, their frame status:
%                            f = segmentation failed
%                            m = stage movement
%                            d = dropped frame
%
%       videoFile - the name of the video to segment
%       frames    - the frames of the video to segment; if empty, all
%                   frames are segmented
%                   Note: video frame indexing begins at 0
%       blockSize - the size for blocks of worm information (i.e., the
%                   number of worms in a block); if empty, all worms are
%                   stored in a single block
%       samples   - the number of samples to use in order to normalize the
%                   worms (see normWorms)
%                   Note: if the samples is undefined, the worms are stored
%                   as cells (see worm2cell); otherwise, the worms are
%                   stored as normalized matrices (see normWorms).
%       infoFile  - the XML file with the experiment information
%                   Note: if infoFile, logFile, and diffFile are undefined,
%                   all video frames are segmented (including those
%                   containing stage movements)
%       logFile   - the CSV file with the stage locations
%       diffFile  - the MAT file with the video differentiation
%
%   Outputs:
%       failedFrames - the frame numbers at which segmentation failed
%
%   See also SEGWORM, SEGWORMFRAMES, CELL2WORM, NORMWORMS

% Check the variable input arguments.
if ~isempty(varargin) && length(varargin) ~= 1 && length(varargin) ~= 4
    error('saveWormFrames:varargin', ['There are too many or too few ' ...
        'input arguments. Please check the function usage with ''help''']);
end

% Remove the worm-blocks-file name's extension.
matExt = '.mat';
if isequal(wormFile((end - length(matExt) + 1):end), matExt) 
    wormFile((end - length(matExt) + 1):end) = [];
end

% Are we normalizing the worms?
samples = [];
if ~isempty(varargin)
    samples = varargin{1};
    
    % Setup the stage movements.
    moves = [0, 0];
    origins = [0,0];
    pixel2MicronScale = [-1, -1];
    rotation = 1;
end

% Are we excluding stage movement frames?
moveFrames = [];
if length(varargin) == 4
    
    % Assign the variable input arguments.
    infoFile = varargin{2};
    logFile = varargin{3};
    diffFile = varargin{4};
    
    % Read the info to convert onscreen pixels to real-world microns.
    [pixel2MicronScale rotation] = readPixels2Microns(infoFile);
    
    % Find the stage movements.
    [moveFrames moves origins] = findStageMovement(infoFile, logFile, ...
        diffFile, 0);
end

% Open the video and get its information.
if ispc()
    vr = videoReader(videoFile, 'plugin', 'DirectShow');
else
    vr = videoReader(videoFile, 'plugin', 'ffmpegDirect');
end
if ~next(vr)
    error('saveWormFrames:NoFrames', ...
        ['''' videoFile ''' has no video frames']);
end
fps = get(vr, 'fps');

% Get the vignette.
vImg = 0;
vignetteFile = strrep(videoFile, '.avi', '.info.xml.vignette.dat');
if exist(vignetteFile, 'file')
    height = get(vr, 'height');
    width = get(vr, 'width');
    fid = fopen(vignetteFile, 'r');
    vImg = fread(fid, [width height], 'int32=>int8', 0, 'b')';
    fclose(fid);
end

% Is the video grayscale?
% Note: if there's no difference between the red and green channel, we
% consider all 3 RGB channels identical grayscale images.
img = getframe(vr);
isGray = false;
if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
    isGray = true;
end
frame = 0;

% If we're normalizing the worms, the frames must be a continuous sequence.
if ~isempty(frames)
    if ~isempty(samples) && any(diff(frames) ~= 1)
        error(['saveWormFrames:NormalizedContinuity', 'When normalizing' ...
            ', the saved frames must form a continuous sequence.']);
    end
    
% Segment and save every frame.
else
    frames = 0:(get(vr, 'numFrames') + get(vr, 'nHiddenFinalFrames') - 1);
end

% Pre-allocate memory.
failedFrames(1:length(frames)) = NaN;
if isempty(blockSize)
    blockSize = length(frames);
end
framesStatus(1:blockSize) = 'd';
block = cell(blockSize,1);
if ~isempty(samples)
    normBlock = cell(12,1);
end

% Pre-compute values.
orientationSamples = [1:5 7:11] / 12;

% Segment the video frames.
isSaved = false;
prevWorm = [];
frames = sort(frames);
isDone = false;
i = 1;
failI = 1;
while ~isDone && i <= length(frames)

    % Use the next video frame.
    if frames(i) - frame == 1
        if next(vr)
            timestamp = get(vr, 'timeStamp');
            frame = round(timestamp * fps);
            
        % We reached the end of the video.
        else
            frames(i:end) = [];
            i = i - 1;
            isDone = true;
        end
        
    % Seek the video frame.
    elseif frames(i) > frame
        prevWorm = [];
        
        % Find the requested frame.
        % Note: seek is inaccurate.
        seek(vr, frames(i));
        timestamp = get(vr, 'timeStamp');
        
        % We overshot the requested frame.
        j = frames(i);
        while j > 0 && round(timestamp * fps) > frames(i)
            j = j - 1;
            seek(vr, j);
            timestamp = get(vr, 'timeStamp');
        end
        
        % We undershot the requested frame.
        while ~isDone && round(timestamp * fps) < frames(i)
            if next(vr)
                timestamp = get(vr, 'timeStamp');
                
            % We reached the end of the video.
            else
                frames(i:end) = [];
                i = i - 1;
                isDone = true;
            end
        end
        frame = round(timestamp * fps);
    end
    
    % Did we drop any frames?
    blockI = mod(i - 1, blockSize) + 1;
    if isDone
        isSeg = false;
    else
        isSeg = true;
        if frames(i) ~= frame
            isSeg = false;
            
        % Skip stage movement frames.
        elseif ~isempty(moveFrames)
            if moveFrames(frames(i) + 1)
                isSeg = false;
                framesStatus(blockI) = 'm';
            end
        end
    end
    
    % Are we segmenting this frame?
    if isSeg
        
        % Get the video frame and convert it to grayscale.
        if isGray
            img = getframe(vr);
            img = img(:,:,1);
        else
            img = rgb2gray(getframe(vr));
        end
        
        % Correct the vignette.
        if ~isempty(vImg)
            img = uint8(single(img) - single(vImg));
        end
        
        % Segment the worm.
        worm = segWorm(img, frames(i), 1, false);
        if ~isempty(worm)
            
            % Orient the worm.
            if isempty(prevWorm)
                if worm.orientation.head.confidence.head < ...
                        worm.orientation.head.confidence.tail
                    worm = flipWormHead(worm);
                end
            else
                [worm, ~, ~] = orientWormAtCentroid(prevWorm, worm, ...
                    orientationSamples);
            end
            
            % Save the worm.
            framesStatus(blockI) = 's';
            block{blockI} = worm2cell(worm);
            prevWorm = worm;
            
        % Segmentation failed.
        else
            failedFrames(failI) = frames(i);
            failI = failI + 1;
            framesStatus(blockI) = 'f';
            warning('segWormFrames:NoWorm', ...
                ['No worm at frame = ' num2str(frame) ...
                ', timestamp = ' num2str(timestamp)]);
        end
    end
    
    % Save the block.
    if blockI == blockSize || i == length(frames) || isDone
        
        % Trim the block.
        if blockI < blockSize
            framesStatus((blockI + 1):end) = [];
            block = block(1:blockI);
        end
        
        % Record the frame status for missing worms.
        if isempty(samples)
            for j = 1:size(block)
                if isempty(block{j})
                    block{j} = framesStatus(j);
                end
            end
            saveBlock = block;
            
        % Normalize the worms.
        else
            
            % Normalize the worms.
            [vulvaContours nonVulvaContours skeletons angles ...
                inOutTouches lengths widths headAreas tailAreas ...
                vulvaAreas nonVulvaAreas] = normWorms(block, samples, ...
                moves, origins, pixel2MicronScale, rotation, false);
            
            % Convert the block.
            normBlock{1} = framesStatus;
            normBlock{2} = vulvaContours;
            normBlock{3} = nonVulvaContours;
            normBlock{4} = skeletons;
            normBlock{5} = angles;
            normBlock{6} = inOutTouches;
            normBlock{7} = lengths;
            normBlock{8} = widths;
            normBlock{9} = headAreas;
            normBlock{10} = tailAreas;
            normBlock{11} = vulvaAreas;
            normBlock{12} = nonVulvaAreas;
            saveBlock = normBlock;
        end
        
        % Save the block.
        % Note: I don't trust IEEE floating point arithmetic.
        blockName = ['block' num2str(floor((i - 1) / blockSize) + 1)];
        eval([blockName ' = saveBlock;']);
        if isSaved
            save([wormFile '.mat'], blockName, '-append');
        else
            save([wormFile '.mat'], blockName);
            isSaved = true;
        end
        framesStatus(1:blockSize) = 'd';
        block = cell(blockSize,1);
    end
    
    % Advance.
    i = i + 1;    
end

% Clean up.
close(vr);
failedFrames(failI:end) = [];

% Save the remaining information.
% Note: I don't trust IEEE floating point arithmetic.
firstFrame = frames(1);
lastFrame = frames(end);
blocks = floor((i - 2) / blockSize) + 1;
if isSaved
    save([wormFile '.mat'], 'blocks', 'blockSize', 'firstFrame', ...
        'lastFrame', 'samples', 'fps', 'pixel2MicronScale', 'rotation', ...
        '-append');
else
    save([wormFile '.mat'], 'blocks', 'blockSize', 'firstFrame', ...
        'lastFrame', 'samples', 'fps', 'pixel2MicronScale', 'rotation');
end
end
