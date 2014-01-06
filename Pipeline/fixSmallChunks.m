function hAndtData = fixSmallChunks(datFileName, myAviInfo, lastBlockSize, blockSize, samples)
% This function will run over the video and fix small chunks that might
% have bad confidences and hence be assigned wrong head and tail
% assignments. It will use surrounding chunks with high confidence to
% correct them. It will set the reliability for each chunk. The possible
% values are these:
% 1 - chunk is reliable. Its length is significant and head coloration is
% larger
% 2 - chunk is quite reliable. It has short length but the correction wasnt
% needed because even with small length the confidences were in agreement
% with the neigbourting highly relibel chunk
% 3 - chunk is not so reliable. It has short length and its own confidences
% were in disagreement with the neigbouring reliable chunk
% 4 - chunk is not reliable. There were no reliable chunks in this video altogether  
%
% Input:
% datFileName - file path to the segmentation data file
% myAviInfo - video information struct, i use it here for getting frame rate 
% lastBlockSize - value that tells me how many frames were in the last chunk
% blockSize - constant that tells me the size of our blocks
% samples - constant that is used in worm alignment
%
% Output:
% hAndtData - worm chunk data with reliability values
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

%samples = [1:3 5:7] / 8;
blockSize = 500;
%load(datFileName,'myAviInfo');
load(datFileName, 'hAndtData');

%number of chunks
chunkNo = length(hAndtData); %#ok<NODEF>
chunkPositionNo = 0; 


%lets create a value in each chunk struct for the last frame of the chunk
for i=1:chunkNo-1
    hAndtData{i}.endFrame = hAndtData{i+1}.startFrame; %#ok<AGROW>
end
hAndtData{end}.endFrame = lastBlockSize;

for i=1:chunkNo
    %if chunk is longer than one quarter of a second, and if its head
    %coloration confidence is larger than its tail and if its head movement
    %confidence is larger than its tail - we've got a solid chunk
    if (hAndtData{i}.chunkValidFrameCounter/myAviInfo.fps) > 1/4 && hAndtData{i}.hColourConf > hAndtData{i}.tColourConf && hAndtData{i}.hMoveConf > hAndtData{i}.tMoveConf
        %here we can have three options - this solid chunk is either the
        %first chunk of the video, its somewhere in the middle or its the
        %last chunk of the video or last but not least there are not chunks
        %with this criteria
        if i==1
            %reliable chunk is first chunk
            chunkPositionFlag = 1;
        elseif i==chunkNo
            %reliable chunk is the last chunk
            chunkPositionFlag = 3;
        else
            %reliable chunk is in the middle
            chunkPositionFlag = 2;
        end
        %save the index of the chunk
        chunkPositionNo = i;
        break;
    else
        %no chunks actually are solid reliable chunks, the whole video
        %needs to be labeled as unreliable
        chunkPositionFlag = 4;
    end
end

%this is the case where reliablie chunk is the first chunk
if chunkPositionFlag == 1
    %we go through the rest of the chunks. starting from 2 to the one
    %before the last one
    
    %here we set the confidence level for this chunk 
    hAndtData{1}.reliability = 1;
    for i=2:(chunkNo)
        %if they are short and unreliable we will use proximity instead of
        %coloration to decide their head and tail orientatoin
        if (hAndtData{i}.chunkValidFrameCounter/myAviInfo.fps) < 1/4
            chunk1 = hAndtData{i};
            
            lastWorm = getLastWormFromChunk(datFileName, hAndtData{i-1});

            chunk1.hColourConf = 0;
            chunk1.tColourConf = 0;
            chunk1.proximityConf = 0;
            chunk1.flipProximityConf = 0;
            chunk1.hMoveConf = 0;
            chunk1.tMoveConf = 0;
            
            chunk1.vColourConf = 0;
            chunk1.nvColourConf = 0;
            chunkBlocks = [{chunk1.startBlock}, chunk1.blocks];
            chunkBlocks(cellfun(@isempty,chunkBlocks)) = [];
            %dependig on the number of blocks in the chunk we will load the
            %data, calculate the proximity and save it back
            %there can be three cases: 1. chunk is in one block. 2. chunks
            %spans 2 blocks. 3. Chunk spans more than two blocks.
            
            %case where there is only one block in the chunk
            if length(chunkBlocks)==1
                %first and last block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, chunk1.startFrame, chunk1.endFrame, chunkBlocks{1}, samples);
                %case where there are 2 blocks in the chunk
            elseif length(chunkBlocks)==2
                %first block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, hAndtData{i}.startFrame, blockSize, chunkBlocks{1}, samples);
                %last block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
                %case where there are more than 2 blocks in the chunk
            else
                %first block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, hAndtData{i}.startFrame, blockSize, chunkBlocks{1}, samples);
                for j=2:length(chunkBlocks)-1
                    %middle blocks
                    chunk1 = fixChunk(datFileName, chunk1, lastWorm, 1, blockSize, chunkBlocks{j}, samples);
                end
                %last block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
            end
            
            %here we will establish the reliability of this chunk. if it
            %has been edited and its confidence in the head is still higher
            %- then it was correct to begin with. if not then it is not as
            %reliable
            if chunk1.hColourConf > chunk1.tColourConf && chunk1.hMoveConf > chunk1.tMoveConf
                chunk1.reliability = 2; 
            else
                chunk1.reliability = 3; 
            end
            hAndtData{i} = chunk1;
        end
    end
elseif chunkPositionFlag == 2
    %this case is when the first reliable chunk is in the middle. we will
    %have to go backwards and forwards from the relabialbe chunk to fix
    %everything 
    
    %here we set the confidence level for this chunk 
    hAndtData{chunkPositionNo}.reliability = 1;
    
    %first we go forward from the relaible chunk to the end of the list. 
    for i=chunkPositionNo+1:chunkNo
        %if they are short and unreliable we will use proximity instead of
        %coloration to decide their head and tail orientatoin
        if (hAndtData{i}.chunkValidFrameCounter/myAviInfo.fps) < 1/4
            chunk1 = hAndtData{i};
            lastWorm = getLastWormFromChunk(datFileName, hAndtData{i-1});
            
            chunk1.hColourConf = 0;
            chunk1.tColourConf = 0;
            chunk1.proximityConf = 0;
            chunk1.flipProximityConf = 0;
            chunk1.hMoveConf = 0;
            chunk1.tMoveConf = 0;
            
            chunk1.vColourConf = 0;
            chunk1.nvColourConf = 0;
            
            chunkBlocks = [{chunk1.startBlock}, chunk1.blocks];
            chunkBlocks(cellfun(@isempty,chunkBlocks)) = [];
            %dependig on the number of blocks in the chunk we will load the
            %data, calculate the proximity and save it back
            %there can be three cases: 1. chunk is in one block. 2. chunks
            %spans 2 blocks. 3. Chunk spans more than two blocks.
            
            %case where there is only one block in the chunk
            if length(chunkBlocks)==1
                %first and last block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, chunk1.startFrame, chunk1.endFrame, chunkBlocks{1}, samples);
                %case where there are 2 blocks in the chunk
            elseif length(chunkBlocks)==2
                %first block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, chunk1.startFrame, blockSize, chunkBlocks{1}, samples);
                %last block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
                %case where there are more than 2 blocks in the chunk
            else
                %first block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, chunk1.startFrame, blockSize, chunkBlocks{1}, samples);
                for j=2:length(chunkBlocks)-1
                    %middle blocks
                    chunk1 = fixChunk(datFileName, chunk1, lastWorm, 1, blockSize, chunkBlocks{j}, samples);
                end
                %last block
                chunk1 = fixChunk(datFileName, chunk1, lastWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
            end
            
            %here we will establish the reliability of this chunk. if it
            %has been edited and its confidence in the head is still higher
            %- then it was correct to begin with. if not then it is not as
            %reliable
            if chunk1.hColourConf > chunk1.tColourConf && chunk1.hMoveConf > chunk1.tMoveConf
                chunk1.reliability = 2; 
            else
                chunk1.reliability = 3; 
            end
            hAndtData{i} = chunk1;
        end
    end
    
    %here we go backward from the correct chunk
    for i=(chunkPositionNo-1):-1:1
        %if they are short and unreliable we will use proximity instead of
        %coloration to decide their head and tail orientatoin
        if (hAndtData{i}.chunkValidFrameCounter/myAviInfo.fps) < 1/4
            chunk1 = hAndtData{i};
            firstWorm = getFirstWormFromChunk(datFileName, hAndtData{i+1});
            
            chunk1.hColourConf = 0;
            chunk1.tColourConf = 0;
            chunk1.proximityConf = 0;
            chunk1.flipProximityConf = 0;
            chunk1.hMoveConf = 0;
            chunk1.tMoveConf = 0;
            
            chunk1.vColourConf = 0;
            chunk1.nvColourConf = 0;
            chunkBlocks = [{chunk1.startBlock}, chunk1.blocks];
            chunkBlocks(cellfun(@isempty,chunkBlocks)) = [];
            %dependig on the number of blocks in the chunk we will load the
            %data, calculate the proximity and save it back
            %there can be three cases: 1. chunk is in one block. 2. chunks
            %spans 2 blocks. 3. Chunk spans more than two blocks.
            
            %case where there is only one block in the chunk
            if length(chunkBlocks)==1
                %first and last block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, chunk1.startFrame, chunk1.endFrame, chunkBlocks{1}, samples);
                %case where there are 2 blocks in the chunk
            elseif length(chunkBlocks)==2
                %first block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, chunk1.startFrame, blockSize, chunkBlocks{1}, samples);
                %last block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
                %case where there are more than 2 blocks in the chunk
            else
                %first block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, chunk1.startFrame, blockSize, chunkBlocks{1}, samples);
                for j=2:length(chunkBlocks)-1
                    %middle blocks
                    chunk1 = fixChunk(datFileName, chunk1, firstWorm, 1, blockSize, chunkBlocks{j}, samples);
                end
                %last block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
            end
            
            %here we will establish the reliability of this chunk. if it
            %has been edited and its confidence in the head is still higher
            %- then it was correct to begin with. if not then it is not as
            %reliable
            if chunk1.hColourConf > chunk1.tColourConf && chunk1.hMoveConf > chunk1.tMoveConf
                chunk1.reliability = 2; 
            else
                chunk1.reliability = 3; 
            end
            hAndtData{i} = chunk1;
        end
    end
elseif chunkPositionFlag == 3
    %here is the case where the last frame is good and all of the chunks
    %before it need to be changed
    
    %here we set the confidence level for this chunk 
    hAndtData{end}.reliability = 1;
    
    %here we go backward from the correct chunk
    for i=(chunkPositionNo-1):-1:1
        %if they are short and unreliable we will use proximity instead of
        %coloration to decide their head and tail orientatoin
        if (hAndtData{i}.chunkValidFrameCounter/myAviInfo.fps) < 1/4
            chunk1 = hAndtData{i};
            firstWorm = getFirstWormFromChunk(datFileName, hAndtData{i+1});
        
            chunk1.hColourConf = 0;
            chunk1.tColourConf = 0;
            chunk1.proximityConf = 0;
            chunk1.flipProximityConf = 0;
            chunk1.hMoveConf = 0;
            chunk1.tMoveConf = 0;
            
            chunk1.vColourConf = 0;
            chunk1.nvColourConf = 0;
            chunkBlocks = [{chunk1.startBlock}, chunk1.blocks];
            chunkBlocks(cellfun(@isempty,chunkBlocks)) = [];
            %dependig on the number of blocks in the chunk we will load the
            %data, calculate the proximity and save it back
            %there can be three cases: 1. chunk is in one block. 2. chunks
            %spans 2 blocks. 3. Chunk spans more than two blocks.
            
            %case where there is only one block in the chunk
            if length(chunkBlocks)==1
                %first and last block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, chunk1.startFrame, chunk1.endFrame, chunkBlocks{1}, samples);
                %case where there are 2 blocks in the chunk
            elseif length(chunkBlocks)==2
                %first block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, chunk1.startFrame, blockSize, chunkBlocks{1}, samples);
                %last block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
                %case where there are more than 2 blocks in the chunk
            else
                %first block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, chunk1.startFrame, blockSize, chunkBlocks{1}, samples);
                for j=2:length(chunkBlocks)-1
                    %middle blocks
                    chunk1 = fixChunk(datFileName, chunk1, firstWorm, 1, blockSize, chunkBlocks{j}, samples);
                end
                %last block
                chunk1 = fixChunk(datFileName, chunk1, firstWorm, 1, chunk1.endFrame, chunkBlocks{end}, samples);
            end
             %here we will establish the reliability of this chunk. if it
            %has been edited and its confidence in the head is still higher
            %- then it was correct to begin with. if not then it is not as
            %reliable
            if chunk1.hColourConf > chunk1.tColourConf && chunk1.hMoveConf > chunk1.tMoveConf
                chunk1.reliability = 2; 
            else
                chunk1.reliability = 3; 
            end
            hAndtData{i} = chunk1;
        end
    end
else
    %this case is where no chunks are found to be reliable, leave it as it
    %is, label all of them as unreliable
    for i=1:chunkPositionNo
        hAndtData{i}.reliability = 4; 
    end
end
1;