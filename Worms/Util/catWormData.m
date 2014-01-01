function data = catWormData(wormFile, varargin)
%CATWORMBLOCKS Concatenate the worm data.
%
%   DATA = CATWORMDATA(WORMFILE)
%   DATA = CATWORMDATA(WORMFILE, INDEX)
%   DATA = CATWORMDATA(WORMFILE, INDEX, STARTFRAME)
%   DATA = CATWORMDATA(WORMFILE, INDEX, STARTFRAME, ENDFRAME)
%
%   Inputs:
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
%       index      - the data index in the block;
%                    if empty, return all data
%       startFrame - the first frame to use;
%                    if empty, we start at the first frame
%       endFrame   - the last frame to use;
%                    if empty, we end at the last frame
%
%   Output:
%
%       data - the concatenated worm data
%
%   See also SAVEWORMVIDEOFRAMES, NORMWORMS
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Determine the data index.
index = 1:12;
if ~isempty(varargin)
    index = varargin{1};
end

% Determine the start and end frames.
startFrame = [];
if length(varargin) > 1
    startFrame = varargin{2};
end
endFrame = [];
if length(varargin) > 2
    endFrame = varargin{3};
end

% Get the data blocks.
state = index;
dataBlocks = worm2func(@echoFunc, state, wormFile, startFrame, ...
    endFrame, 0, 0);

% Concatenate the data blocks.
data = cell(length(dataBlocks{1}), 1);
for i = 1:length(dataBlocks)
    for j = 1:length(data)
        if ~isempty(dataBlocks{i})
            switch ndims(dataBlocks{i}{j})
                case 2
                    data{j} = cat(2, data{j}, dataBlocks{i}{j});
                case 3
                    data{j} = cat(3, data{j}, dataBlocks{i}{j});
                otherwise
                    error('catWormBlocks:BadVariable', ['Data cell ' ...
                        num2str(i) ' has inappropropriate dimensionality']);
            end
        end
    end
end
end

% Echo the data.
function [data dataBlockI] = echoFunc(dataInfo, dataBlockI)

% Initialize the variables.
dataBlock = dataInfo.data;
startI = dataInfo.startDataFrameI;
endI = dataInfo.endDataFrameI;

% Extract the subset of the data.
data = cell(length(dataBlockI), 1);
for i = 1:length(data)
    j = dataBlockI(i);
    switch ndims(dataBlock{j})
        case 2
            data{i} = dataBlock{j}(:,startI:endI);
        case 3
            data{i} = dataBlock{j}(:,:,startI:endI);
        otherwise
            error('catWormBlocks:BadVariable', ['Data cell ' ...
                num2str(j) ' has inappropropriate dimensionality']);
    end
end
end
