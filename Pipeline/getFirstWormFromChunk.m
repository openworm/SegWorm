function firstWorm = getFirstWormFromChunk(datFileName, chunk0)
% we will try to load the first frame of a chunk
% Input:
% datFileName - filename of the segmentation result file
% chunk0 - chunk of interest
% Output:
% firstWorm - first valid worm from chunk of interest
%
% Also see: getLastWormFromPreviousChunk
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

%we go through the blocks to find first valid frame
for i=1:length(allBlocks)
    %get the block
    blockName = allBlocks{i};
    datFileNameBlock = strrep(datFileName, 'segInfo', blockName);
    load(getRelativePath(datFileNameBlock), blockName);
    eval(['currentBlock=', blockName,';']);
    execString = strcat('clear(''',blockName,''');');
    eval(execString);
    
    %here we decide from what part of the block to look for valid frame
    %if its the very first block we need to run from startFrame, if it is any
    %other block after that we need to run from 1
    if i == 1
        startFrame = chunk0.startFrame;
    else
        startFrame = 1;
    end
    for j = startFrame:length(currentBlock)
        if iscell(currentBlock{j})
            firstWorm = currentBlock{j};
            finFlag = 1;
            break;
        end
    end
    clear('currentBlock');
    if finFlag
        break;
    end
end

firstWorm = cell2worm(firstWorm);

