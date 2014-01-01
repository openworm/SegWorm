function data = worm2func(func, state, wormFile, startFrame, endFrame, ...
    backScale, frontScale, varargin)
%WORM2FUNC Apply a function to worm data (normalized within blocks).
%
%   DATA = WORM2FUNC(FUNC, STATE, WORMFILE, STARTFRAME, ENDFRAME,
%                    BACKSCALE, FRONTSCALE)
%
%   DATA = WORM2FUNC(FUNC, STATE, WORMFILE, STARTFRAME, ENDFRAME,
%                    BACKSCALE, FRONTSCALE, ISEXTENDED)
%
%   Inputs:
%       func       - the function to apply per data block;
%                    this function must follow the form:
%
%                    [DATA STATE] = FUNC(DATABLOCKINFO, STATE)
%
%                    DATA = the function output per block
%                    DATABLOCKINFO is a struct with fields:
%                    data            = a superset containing the current
%                                      data block, extended by the scale in
%                                      the front, with both the back and
%                                      front then extended to the next
%                                      available segmented frames or the
%                                      end of the data if these are not
%                                      available; see "wormFile" below for
%                                      an explanation of the data format
%                    state           = the function state
%                    startFrame      = the frame number for the starting
%                                      frame of the data superset
%                    startDataFrame  = the frame number for the starting
%                                      frame in the block
%                    startDataFrameI = the index into the data superset for
%                                      the starting frame in the block
%                    endFrame        = the frame number for the ending
%                                      frame of the data superset
%                    endDataFrame    = the frame number for the ending
%                                      frame in the block
%                    endDataFrameI   = the index into the data superset for
%                                      the ending frame in the block
%                    fps             = the data frames/seconds
%
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
%       startFrame - the first frame to use;
%                    if empty, we start at the first frame
%       endFrame   - the last frame to use;
%                    if empty, we end at the last frame
%       backScale  - the back end time scale required by the function;
%                    this scale is used to ensure that, for each data block
%                    to which the function is applied:
%
%                    1. The first frame in the data block has been extended
%                       backward by the scale or to the start of the data
%                       if there is insufficient data to accomodate the
%                       extension.
%                    2. The first and last frames of the data block have
%                       been extended to either the next segmented frames
%                       or they represent, respectively, the first and/or
%                       last frames of all the data.
%       frontScale - the front end time scale required by the function;
%                    this scale is used to ensure that, for each data block
%                    to which the function is applied:
%
%                    1. The last frame in the data block has been extended
%                       by the scale or to the end of the data if there is
%                       insufficient data to accomodate the extension.
%                    2. The first and last frames of the data block have
%                       been extended to either the next segmented frames
%                       or they represent, respectively, the first and/or
%                       last frames of all the data.
%
%       isExtended - are the back and front of the data extended to the
%                    next segmented frame? If true, the first and last
%                    frames of the data block are extended to either the
%                    next segmented frames or they represent, respectively,
%                    the first and/or last frames of all the data. The
%                    default is true.
%
%   Output:
%       data - the function output per block
%
%   See also SAVEWORMVIDEOFRAMES, NORMWORMS
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we extending the back and front of the data blocks to the next
% segmented frames?
isExtended = true;
if ~isempty(varargin)
    isExtended = varargin{1};
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
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    else
        samples = SAMPLES;
    end
    varName = 'myAviInfo';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    else
        fps = myAviInfo.fps;
    end
    varName = 'pixel2MicronScale';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'normBlockList';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
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
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'fps';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'pixel2MicronScale';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'firstFrame';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'lastFrame';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'blockSize';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
    varName = 'blocks';
    if ~exist(varName, 'var')
        error('worm2func:BadVariable', ...
            ['Cannot load ''' varName ''' from ''' wormFile '''']);
    end
end

% The worms must be normalized.
if isempty(samples)
    error('worm2func:NotNormalized', ...
        ['The worms in  ''' wormFile ''' are not normalized']);
end

% Check the starting frame.
if isempty(startFrame)
    startFrame = firstFrame;
end
if startFrame < firstFrame
    error('worm2func:StartFrame', ['The requested starting frame ' ...
        num2str(startFrame) ' is less than the first frame ' ...
        num2str(firstFrame) ' in ''' wormFile '''']);
elseif startFrame > lastFrame
    error('worm2func:StartFrame', ['The requested starting frame ' ...
        num2str(startFrame) ' is greater than the last frame ' ...
        num2str(lastFrame) ' in ''' wormFile '''']);
end

% Check the ending frame.
if isempty(endFrame)
    endFrame = lastFrame;
end
if endFrame < firstFrame
    error('worm2func:EndFrame', ['The requested ending frame ' ...
        num2str(endFrame) ' is less than the first frame ' ...
        num2str(firstFrame) ' in ''' wormFile '''']);
elseif endFrame > lastFrame
    error('worm2func:EndFrame', ['The requested ending frame ' ...
        num2str(endFrame) ' is greater than the last frame ' ...
        num2str(lastFrame) ' in ''' wormFile '''']);
end

% Correct the data types.
startFrame = double(startFrame);
endFrame = double(endFrame);
fps = double(fps);
firstFrame = double(firstFrame);
lastFrame = double(lastFrame);
blockSize = double(blockSize);
blocks = double(blocks);

% Compute the scales.
if isempty(backScale) || backScale < 0
    backScale = 0;
end
backScale = round(backScale * fps);
if isempty(frontScale) || frontScale < 0
    frontScale = 0;
end
frontScale = round(frontScale * fps);

% Apply the function to the data.
blockInfo = []; % the information for the loaded blocks
startBlockI = ... % the starting block's index
    floor((startFrame - firstFrame) / blockSize) + 1;
endBlockI = ... % the ending block's index
    floor((endFrame - firstFrame) / blockSize) + 1;
data = cell(endBlockI - startBlockI + 1, 1);
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
    backScaleFrames = min(backScale, startDataBlockFrame);
    frontScaleFrames = min(frontScale, lastFrame - endDataBlockFrame);
    [dataInfo blockInfo] = loadData(wormFile, fps, ...
        startDataBlockFrame, endDataBlockFrame, backScaleFrames, ...
        frontScaleFrames, isExtended, firstFrame, blocks, blockSize, ...
        blockInfo);
    
    % Apply the function.
    [data{i - startBlockI + 1} state] = func(dataInfo, state);
end
end

% Load data by index.
function [dataInfo blockInfo] = loadData(wormFile, fps, startFrame, ...
    endFrame, backScale, frontScale, isExtended, firstFrame, ...
    lastBlockI, blockSize, blockInfo)

% Compute the start frame.
startFrame = startFrame - backScale;

% Compute the end frame.
endFrame = endFrame + frontScale;

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
if isExtended
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
if isExtended
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
end

% Construct the data.
startUseFrame = ... % the starting usable frame number
    startUseI + ((startBlockI - 1) * blockSize) + firstFrame - 1;
endUseFrame = ... % the ending usable frame number
    endUseI + ((endBlockI - 1) * blockSize) + firstFrame - 1;
blockInfo = newBlockInfo;
if startBlockI == endBlockI
    data = blockInfo.blocks{startBlockI - blockInfo.index  + 1};
    data = dataSubset(data, startUseI, endUseI);
else
    startData = blockInfo.blocks{startBlockI - blockInfo.index  + 1};
    startData = dataSubset(startData, startUseI, []);
    midData = [];
    for i = (startBlockI + 1):(endBlockI - 1)
        midData = catData(midData, ...
            blockInfo.blocks{i - blockInfo.index  + 1});
    end
    endData = blockInfo.blocks{endBlockI - blockInfo.index  + 1};
    endData = dataSubset(endData, 1, endUseI);
    data = catData(startData, midData, endData);
end

% Organize the data information.
startFrameI = startFrame + backScale - startUseFrame + 1;
endFrameI = endFrame - frontScale - startUseFrame + 1;
dataInfo = struct( ...
    'startFrame', startUseFrame, ...
    'startDataFrame', startFrame + backScale, ...
    'startDataFrameI', startFrameI, ...
    'endFrame', endUseFrame, ...
    'endDataFrame', endFrame - frontScale, ...
    'endDataFrameI', endFrameI, ...
    'data', {data}, ...
    'fps', fps);
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

% Extract a subset of the data.
function subset = dataSubset(data, startI, endI)

% Fix the start and end indices.
if isempty(startI)
    startI = 1;
end
if isempty(endI)
    endI = length(data{1});
end

% Extract the subset of the data.
subset = cell(length(data), 1);
for i = 1:length(data)
    switch normDataDims(i)
        case 2
            subset{i} = data{i}(:,startI:endI);
        case 3
            subset{i} = data{i}(:,:,startI:endI);
        otherwise
            error('worm2func:BadVariable', ['Data cell ' ...
                num2str(i) ' has inappropropriate dimensionality']);
    end
end
end

% Concatenate the data.
function data = catData(varargin)

% We only have 1 data block.
data = cell(normDataLength(), 1);
if length(varargin) == 1
    data = varargin{1};

% Concatenate the data blocks.
elseif length(varargin) > 1
    for i = 1:length(varargin)
        if ~isempty(varargin{i})
            
            % Save the first data block.
            if isempty(data)
                data = varargin{i};
                
            % Concatenate the data block.
            else
                for j = 1:length(data)
                    switch normDataDims(j)
                        case 2
                            data{j} = cat(2, data{j}, varargin{i}{j});
                        case 3
                            data{j} = cat(3, data{j}, varargin{i}{j});
                        otherwise
                            error('worm2func:BadVariable', ...
                                ['Data cell ' num2str(i) ...
                                ' has inappropropriate dimensionality']);
                    end
                end
            end
        end
    end
end
end


% How many dimensions does this normed data cell element have?
function dims = normDataDims(index)
dims = [];
if index >= 2 && index <= 4
    dims = 3;
elseif index <= normDataLength()
    dims = 2;
end
end

% How many elements are in our normed data cell array?
function dataLength = normDataLength()
dataLength = 12;
end
