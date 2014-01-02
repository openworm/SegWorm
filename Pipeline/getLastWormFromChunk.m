function lastWorm = getLastWormFromChunk(datFileName, chunk0)
% GETLASTWORMFROMCHUNK This function will load the last segmented frame 
% from the given chunk
% Input:
%       datFileName - filename of the segmentation result file
%       chunk0 - chunk of interest
% Output:
%       lastWorm - last valid worm from chunk of interest
%
% Also see: getFirstWormFromSubsequentChunk
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

%here we concatate all blocks that the chunk spans in a cell array
allBlocks = [{chunk0.startBlock}, chunk0.blocks];
%make sure to throw away empty block names
allBlocks(cellfun(@isempty, allBlocks)) = [];

finFlag = 0;
lastWorm = [];

%we go backwards from the end of this list
for i=length(allBlocks):-1:1
    %get the block
    blockName = allBlocks{i};
    datFileNameBlock = strrep(datFileName, 'segInfo', blockName);
    load(getRelativePath(datFileNameBlock), blockName);
    eval(['currentBlock=', blockName,';']);
    execString = strcat('clear(''',blockName,''');');
    eval(execString);
    
    blockSize = length(currentBlock);
    
    %here we decide from what part of the block to look for valid frame
    %if its the very last block we need to run from endFrame, if it is any
    %other block after that we need to run from the blockSize
    if i == length(allBlocks)
        %IMPORTANT: -1 here is to make sure that we are not getting the
        %first frame of subsequent chunk. The endFrame variable will be the
        %same number as the startFrame for subseqent chunk, must make sure
        %that the same frame is not sellected
        endFrame = chunk0.endFrame-1;
    else
        endFrame = blockSize;
    end
    for j = endFrame:-1:1
        if iscell(currentBlock{j})
            lastWorm = currentBlock{j};
            finFlag = 1;
            break;
        end
    end
    clear('currentBlock');
    if finFlag
        break;
    end
end
if ~isempty(lastWorm)
    lastWorm = cell2worm(lastWorm);
end

