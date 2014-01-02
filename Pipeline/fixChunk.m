function chunk1 = fixChunk(datFileName, chunk1, prevWorm, startFrame, endFrame, blockName, samples)
%this function fixes chunks that are small or have something wrong with
%them
%input:
% chunk1 - chunk that needs to be fixed
% prevWorm - prevWorm of previous correct alignment
% startFrame - startFrame of the chunk
% endFrame - end frame of the chunk, start frame of the subsequent chunk
% blockName - blocks that belong to this chunk
% samples - values for orientWormAtCentroid
%
%output:
% chunk1 - chunk data
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
datFileNameBlock = strrep(datFileName, 'segInfo', blockName);

load(datFileNameBlock, blockName);
eval(['currentBlock=', blockName,';']);
execString = strcat('clear(''',blockName,''');');
eval(execString);

for j=startFrame:endFrame
%     try 
%        iscell(currentBlock{j}) 
%     catch ME1
%         1;
%     end
    if iscell(currentBlock{j})
        [worm, proximityConf, flipProximityConf] = orientWormAtCentroid(prevWorm, cell2worm(currentBlock{j}), samples);
        chunk1.proximityConf = chunk1.proximityConf + proximityConf;
        chunk1.flipProximityConf = chunk1.flipProximityConf + flipProximityConf;
        if isWormCellHeadFlipped(worm2cell(worm))
            worm = flipWormData(worm);
            worm = flipWormVulva(worm);
            %flipWormHead
            worm = flipWormConfidenceData(worm);
        end
        [hMoveConf, tMoveConf] = headTailMovementConfidence(prevWorm, worm);
        
        if isWormCellHeadFlipped(worm2cell(worm))
            chunk1.hMoveConf = chunk1.hMoveConf + tMoveConf;
            chunk1.tMoveConf = chunk1.tMoveConf + hMoveConf;
            %chcek flip flag
            chunk1.hColourConf = chunk1.hColourConf + worm.orientation.head.confidence.tail;
            chunk1.tColourConf = chunk1.tColourConf + worm.orientation.head.confidence.head;
        else
            chunk1.hMoveConf = chunk1.hMoveConf + hMoveConf;
            chunk1.tMoveConf = chunk1.tMoveConf + tMoveConf;
            %chcek flip flag
            chunk1.hColourConf = chunk1.hColourConf + worm.orientation.head.confidence.head;
            chunk1.tColourConf = chunk1.tColourConf + worm.orientation.head.confidence.tail;
        end
        % Where is the vulva?
        chunk1.vColourConf = chunk1.vColourConf + worm.orientation.vulva.confidence.vulva;
        chunk1.nvColourConf = chunk1.nvColourConf + worm.orientation.vulva.confidence.nonVulva;
        currentBlock{j}=worm2cell(worm);
        prevWorm = worm;
    end
end
eval([blockName,'=currentBlock',';']);

%datFileName2 = strrep(datFileName, '.mat', '_test.mat');

execString = strcat('save('' ',datFileNameBlock,''',''',blockName,''');');
eval(execString);
           
%save(datFileNameBlock,'-append', blockName);

execString = strcat('clear(''','currentBlock',''');');
eval(execString);
execString = strcat('clear(''',blockName,''');');
eval(execString);



