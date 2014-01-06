function splitChunk(handles)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
mydata = guidata(handles.figure1);

currentFrame = mydata.currentFrame;
    
if mydata.useDB == 0
    
    %set c to the number of the current chunk
    c = mydata.currentChunk;
    
    
    
    %gt hAndtData from segNormInfo.mat
    load(mydata.segNormInfoPath);
    
    %if we split a chunk, we will change the confidences
    hAndtData{c}.hColourConf = '';
    hAndtData{c}.tColourConf = '';
    hAndtData{c}.vColourConf = '';
    hAndtData{c}.nvColourConf = '';
    hAndtData{c}.proximityConf = '';
    hAndtData{c}.flipProximityConf = '';
    hAndtData{c}.hMoveConf = '';
    hAndtData{c}.tMoveConf = '';
    hAndtData{c}.reliability = '';
    hAndtData{c}.chunkValidFrameCounter = '';
    hAndtData{c}.lastValidTimestamp = '';
    
    
    %we must insert a new chunk
    hAndtData(c+1: length(hAndtData)+1) = hAndtData(c:length(hAndtData))
    
    hAndtData{c+1}.StartFrame = mod(currentFrame, mydata.blockLength);
    hAndtData{c+1}.startBlock = ['block' floor(currentFrame/mydata.blockLength) ]
    
    hAndtData{c+1}.globalStartFrame = currentFrame;
    
    hAndtData{c+1}.hColourConf = '';
    hAndtData{c+1}.tColourConf = '';
    hAndtData{c+1}.vColourConf = '';
    hAndtData{c+1}.nvColourConf = '';
    hAndtData{c+1}.proximityConf = '';
    hAndtData{c+1}.flipProximityConf = '';
    hAndtData{c+1}.hMoveConf = '';
    hAndtData{c+1}.tMoveConf = '';
    hAndtData{c+1}.reliability = '';
    hAndtData{c+1}.chunkValidFrameCounter = '';
    hAndtData{c+1}.lastValidTimestamp = '';
    
    
    %get a list of all the blocks spanned by the chunk
    blockList{1} = hAndtData{c}.startBlock;
    
    for i=1:length(hAndtData{c}.blocks)
        blockList{ end+1 } = hAndtData{c}.blocks{i};
    end
    
    
    %initialize empty arrays
    blocks1 = '';
    blocks2 = '';
    
    %loop through each block
    for i=1:length(blockList)
        currentBlock = str2num(strrep(blockList{i}, 'block', '' ));
        
        %if a block *starts before* the current time, it includes part of the first chunk
        if (currentBlock-1)*mydata.blockLength <= currentFrame
            blocks1{end+1} = ['block' num2str(currentBlock)];
        end
        
        %if a block *ends after* the current time, it includes part of the second chunk
        if  currentBlock*mydata.blockLength >= currentFrame
            blocks2{end+1} = ['block' num2str(currentBlock)];
        end
        
    end
    
    %update the block list for the truncated chunk
    hAndtData{c}.blocks = blocks1;
    hAndtData{c+1}.blocks = blocks2;
    
    %save the modified data
    save(mydata.segNormInfoPath, 'hAndtData', '-append');
    
else
    
    % get list of chunk IDs
    query = ['SELECT entryid, start, end FROM main.wormmorphology WHERE experiment_id = ' num2str(mydata.experiment_id) ' ORDER BY start'];
    curs = exec(mydata.conn, query);
    setdbprefs('DataReturnFormat','numeric');
    curs = fetch(curs, 100);
    
    ids=curs.data(:,:);
    
    %update the chunk that was split
    query = ['UPDATE wormmorphology SET end = ' num2str(mydata.currentFrame) ', reliability = NULL, hColourConf = NULL, tColourConf = NULL, vColourConf = NULL, nvColourConf = NULL, proximityConf = NULL, flipProximityConf = NULL, hMoveConf = NULL, tMoveConf = NULL WHERE experiment_id =' num2str(mydata.experiment_id) ' AND start = ' num2str(mydata.chunktimes(mydata.currentChunk)) ]
    curs = exec(mydata.conn, query);
    
    %get the end-time of that chunk
    
    
    %create the new chunk
    query = ['INSERT into wormmorphology SET start = ' num2str(currentFrame) ', end = ' num2str(ids(mydata.currentChunk+1, 3)) ', experiment_id = ' num2str(mydata.experiment_id) ', chunk_id = ' num2str(length(mydata.chunktimes)+1)]
    curs = exec(mydata.conn, query);
    
end


%
% redraw the chunkBar
%

%refresh the chunktimes array
getchunktimes(handles.openButton);

mydata = guidata(handles.figure1);
if isfield(handles, 'chunktimes')
    drawChunkBar(handles);
    drawZoomedChunkBar(handles);
end
