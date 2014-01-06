% Segmentation main function
% Loads video, segments frames, extracts and saves info
%
% Copyright:
% Tadas Jucikas, Ev Yemini
% MRC Laboratory of Molecular Biology, Cambridge, UK
%
% Last edited: 30 01 2012
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

function fileInfo = segmentationMain(hObject, ~, handles, fileInfo)
% Retrieve GUI data
mydata = guidata(hObject);

% Checking if the directory is passed to this function
if ~isfield(mydata, 'experimentList')
    set(handles.status1,'String','Please load the directory first.');
    return;
end
% Create segmentation directory variable
segFileDir = fullfile(fileInfo.expList.dir,'.data', strcat(fileInfo.expList.fileName,'_seg'));

% Lets check again if the dir has been created
if exist(segFileDir, 'dir') == 7
    %rmdir(segFileDir,'s');
else
    % Create the dir
    mkdir(segFileDir);
end

% Initialize main file name
datFileName = fullfile(segFileDir, 'segInfo.mat');

% Lets check if the file exists, delete if yes
if exist(datFileName, 'file') == 2
    delete(datFileName);
end

% Write first value, initialize file
dateStamp = datestr(now()); 
save(datFileName, 'dateStamp');

% Initialize failed frames file name
failedFramesFile = fullfile(fileInfo.expList.dir, '.data',...
    strcat(fileInfo.expList.fileName,'_failedFrames.mat'));

% Printing out a status message to the GUI
str1 = strcat('Segmentation for video file', {' '},...
    fileInfo.expList.fileName, {' '}, 'started at', {' '}, datestr(now));
set(handles.status1,'String',str1{1});

% Lets initialize helper variables
vidName = fileInfo.expList.avi;

%----------------------------------------------------------------------
% This section loads the stage movement data
%----------------------------------------------------------------------
% Check stage movement
stageMovementFile = fileInfo.expList.stageMotion;
if exist(stageMovementFile,'file') == 2
    str1 = strcat('Reading stage movement data file: ',{' '},stageMovementFile,{'.'});
    set(handles.status1,'String',str1{1});
    
    existsStegeMovVar = whos('-file', stageMovementFile,'-regexp','frames');
    if isempty(existsStegeMovVar)
        missingStr = strcat('Frames varialbe could not be found in stage movement file:',{' '},strrep(stageMovementFile,'\','_'));
        error('segmentationMain:variableNotFound', missingStr{1});
    end
    
    drawnow;
    load(stageMovementFile, 'frames', 'locations', 'movesI');
    origins = locations;
    clear('locations');
    execStr = strcat('movementFrames = frames;');
    eval(execStr);
else
    missingStr = strcat('Stege movement file not found for experiment:',{' '},fileInfo.expList.fileName, {' '},'Dir:',{' '}, strrep(fileInfo.expList.dir,'\','_'));
    error('segmentationMain:fileNotFound', missingStr{1});
end

calibrationFile = fileInfo.expList.xml;
if exist(calibrationFile, 'file') == 2
    [pixel2MicronScale, rotation] = readPixels2Microns(calibrationFile);
else
    missingStr = strcat('Experiment info file not found for experiment:', {' '}, fileInfo.expList.fileName, {' '},'Dir:',{' '}, strrep(fileInfo.expList.dir,'\','_'));
    error('segmentationMain:fileNotFound', missingStr{1});
end

%--------------------------------------------------------------------------
% This section will load vignette
%--------------------------------------------------------------------------
vImg = [];
try
    % The logic here will be the following:
    % If a preference for computing vignette is selected we will compute
    % vignette even if the vignette was saved and defined while tracking
    % If the
    if handles.preferences.bgsubtract
        videoFile = fileInfo.expList.avi;
        vigFile   = strrep(fileInfo.expList.log, '.log.csv', '.info.xml.vignette.dat');
        infoFile  = fileInfo.expList.xml;
        logFile   = fileInfo.expList.log;
        diffFile  = fileInfo.expList.videoDiff;
        
        % Create the new vignette file.
        vImg = video2Vignette(videoFile, [], [], [], 5, 0, 5, vigFile, infoFile, ...
            logFile, diffFile);
        
        % Save an image of the new and old vignette.
        vigImg = vignette2RGB(vigFile, 10);
        imwrite(vigImg, strrep(vigFile, '.info.xml.vignette.dat', '.info.xml.vignette.png'), 'PNG');
        
        fileInfo.expList.vignette = vigFile;
    else
        % In case the preference to recompute is not selected we will check
        % if the vignette actualy exists and if yes load it.
        vignetteFile = fileInfo.expList.vignette;
        if exist(vignetteFile, 'file')
            fid = fopen(vignetteFile, 'r');
            vImg = fread(fid, [640 480],'int32=>int8', 0, 'b')';
            fclose(fid);
        end
    end
    
catch ME12
    msgString = getReport(ME12, 'extended','hyperlinks','off');
    error('segmentationMain:vignetteError', msgString);
end

%--------------------------------------------------------------------------
% Main loop
%--------------------------------------------------------------------------
% Initialize block size


%?????????
%-> Block size is 500???????

blockSize = 500;

% Open the video and get the seconds / frame.
vr = videoReader(fileInfo.expList.avi, 'plugin', 'DirectShow');

% cleanup call
obj1 = onCleanup(@()cleanupFun(vr));

vrBackground = 0; 
fps = get(vr, 'fps');
myAviInfo = get(vr);
spf = 1 / fps;
totalFrames = get(vr, 'numFrames') + get(vr, 'nHiddenFinalFrames');

% Is the video grayscale?
% Note: if there's no difference between the red and green channel, we
% consider all 3 RGB channels identical grayscale images.
isGray = false;
isVideoFrame = next(vr);
if isVideoFrame
    img = getframe(vr);
    if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
        isGray = true;
    end
end

% Pre-compute the values for orienting successive worm frames.
prevOrientWorm = [];
orientSamples = [1:5 7:11] / 12;

% Compute the time boundaries for small head movements.
% Note: at around, 1/30 of a second, worm movements are dwarfed by camera
% noise. On the other hand, small worm head movements can complete in just
% under 1/6 of a second. Therefore, when evaluating the head and tail
% movement confidences, we attempt to differentiate at 1/6 of a second.
% Unfortunately, due to dropped frames, stage movement, and failed
% segmentation, the requisite frame for differentiation may be missing.
% Therefore, we set an upper bound of 1/4 of a second (1.5 * 1/6) so as at
% to catch any small head movements without the possibility that the head
% returned to its initial location.
htMoveMinDiff = round(fps / 6) - 1;
htMoveMaxDiff = round(fps / 4) - 1  ;
prevWorms = cell(htMoveMaxDiff + 1,1);

% Pre-allocate memory for the color, movement, and proximity confidences.
hOrthoConfidence = 0;
tOrthoConfidence = 0;
hParaConfidence  = 0;
tParaConfidence  = 0;

% Measure the video frame statistics.
totalSegmentedFrames     = 0;
totalUnsegmentedFrames   = 0;
totalDroppedFrames       = 0;
totalStageMovementFrames = 0;

% The frames at which segmentation failed.
failedFrames = NaN(totalFrames, 2);

blockOpen{blockSize} = [];
if totalFrames >= blockSize
    blockList{round(totalFrames/blockSize)} = [];
else
    blockList{1} = [];
end

save(datFileName, '-append', 'myAviInfo');

% Segment the video.
prevTimestamp = -spf;
j = 0;
isDebugVideo = 0;
blockCounter = 1;
globalFrameCounter = 0;
blockNameStr = 'block1';
droppedFramesModeCounter = 0;
%initialize data for chunks
chunkData.startFrame = 1;
chunkData.startBlock = blockNameStr;
chunkData.blocks = [];
chunkData.lastValidTimestamp = prevTimestamp;
statsHT = initializeChunkHTstats;
chunkData.statsHT = statsHT;
chunkData.globalStartFrame = 1;
chunkData.chunkValidFrameCounter = 0;
chunkData.reliability = 1;
chunkData.movementBased = 1;

% This flag is for showing the occurance of stage movement. All unique
% stage movements will be counted as the segmentation is performed
newStageMovFlag = 1;

hAndtData = [];
execString = strcat('save('' ',datFileName,''',''-append'',''hAndtData'');');
eval(execString);

% This variable signals for us to start a new chunk
chunkOccured = 0;

TIMETHR1 = 1/4;
TIMETHR2 = 1/2;
TIMETHR3 = 3/2;

while isVideoFrame
    % Initial check if we are not exceeding the block size. If so then we
    % will save that block into a file. This part of the code is first in
    % the loop because other sections will call continue and the loop will
    % resume here. This block then will deal with the situation where a new
    % block needs to be created.
    
    if j >= blockSize
        % Save finished block
        execString = strcat(blockNameStr,' = blockOpen;');
        eval(execString);
        datFileNameBlock = fullfile(segFileDir, strcat(blockNameStr,'.mat'));
        execString = strcat('save('' ',datFileNameBlock,''',''',blockNameStr,''');');
        eval(execString);
        
        blockList{blockCounter} = blockNameStr;
        
        clear('blockOpen');
        execString = strcat('clear(''',blockNameStr,''');');
        eval(execString);
        
        blockCounter = blockCounter + 1;
        blockNameStr = strcat('block', sprintf('%d',blockCounter));
        
        %update chunk data
        if ~strcmp(chunkData.startBlock, blockNameStr)
            chunkData.blocks = [chunkData.blocks, {blockNameStr}];
        end
        
        % initialize new block open
        blockOpen{blockSize} = [];
        % initialize new block frame counter
        j=0;
    end
    
    % COUNTERS & FLAGS
    %--------------------
    % block frame counter
    j = j + 1;
    % global frame counter
    globalFrameCounter = globalFrameCounter + 1;
    % Getting frame time stamp
    timestamp = get(vr, 'timeStamp');
    % Current frame number
    frame = round(timestamp * fps);
    
    % Lets check if its not a movement frame. Retrieve frame if its not, if
    % if its movement - make dummy image to be passed in to clear function
    % at the end of the loop.
    if ~isempty(movementFrames) && ~movementFrames(frame + 1) && droppedFramesModeCounter == 0
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
    else
        img = 0;
    end
    
    % Here we know that the chunk must be created but we wait till the
    % first valid frame of subsequent chunk. The original chunk will end
    % where the new one will start.
    if chunkOccured
        %%if chunk is shorter thatn 1/4s then we treat is as part of the
        %%previous chunk, even if lastValidTimestamp was a while ago
        %we've got an end of the chunk
        %[blockOpen, chunkData] = headTail(chunkData, blockOpen, j, datFileName, timestamp, globalFrameCounter, blockNameStr);
        
        % Update hAndtData to the output file
        load(datFileName,'hAndtData');
        if isempty(hAndtData)
            hAndtData = {chunkData}; 
        else
            hAndtData = [hAndtData, chunkData]; 
        end
        execString = strcat('save('' ',datFileName,''',''-append'',''hAndtData'');');
        eval(execString);
        chunkData.startFrame = j;
        chunkData.startBlock = blockNameStr;
        chunkData.globalStartFrame = globalFrameCounter;
        chunkData.blocks = [];
        chunkData.lastValidTimestamp = timestamp;
        statsHT = initializeChunkHTstats;
        chunkData.statsHT = statsHT;
        chunkData.chunkValidFrameCounter = 0;
        chunkData.reliability = 1;
        chunkData.movementBased = 1;
        chunkOccured = 0;
    end
    
    if globalFrameCounter >= length(movementFrames)
        warning('segmentationWorm:VideoLengthMismatch',...
            'Stage movement vector smaller than available frames');
        movementFrames(globalFrameCounter) = 0; %#ok<AGROW>
    end
    
    % Variable prevWorms contains previous worms that will be used in
    % headTailMovementConfidence function. It is organized like a stack and
    % each frame last value of the stack will be updated. This line pushes
    % the stack removing the top value and freeing the bottom value to be
    % filled in later in the loop
    prevWorms(1:end-1) = prevWorms(2:end);
    
    % Check for dropped frames
    % Don't compute them if we are already inside a dropped frame region
    if droppedFramesModeCounter == 0
        droppedFrames = round((timestamp - prevTimestamp) * fps - 1);
        totalDroppedFrames = totalDroppedFrames + droppedFrames;
    end
    
    prevTimestamp = timestamp;
    
    % If we find dropped frames lets record them to droppedFramesModeCounter
    % variable.
    if droppedFrames > 0
        droppedFramesModeCounter = droppedFrames;
        droppedFrames = 0;
    end
    
    if droppedFramesModeCounter > 0
        % Decrease the dropped frames counter
        droppedFramesModeCounter = droppedFramesModeCounter - 1;
        
        % In case of dropped frames the bottom value of the stack is
        % updated with empty cell. Since dropped frames are being
        % included in this inner loop, pushing the stack also needs to
        % be done here.
        prevWorms{end} = [];
        prevWorms(1:end-1) = prevWorms(2:end);
        
        % Determine frame calss, 3 stands for dropped frame and will be the
        % value here
        blockOpen{j} = [];
        % Move to the next iteration
        continue;
    end
    
    %----------------------------------------------------------------------
    str1 = strcat('Analyzing frame number:', {' '}, sprintf('%d',...
        globalFrameCounter), {' '}, 'out of', {' '}, sprintf('%d',...
        totalFrames));
    set(handles.status1,'String',str1{1});
    drawnow;
    %----------------------------------------------------------------------
    
    % The stage is moving.
    if ~isempty(movementFrames) && movementFrames(frame + 1)
        % Since we have movement frame we add empty cell into the prevWorms
        % cell array.
        prevWorms{end} = [];
        
        % Flag for stage movement
        wormCell = 2;
        totalStageMovementFrames = totalStageMovementFrames + 1;
        
        % Compute stage movement statistics for head and tail
        if newStageMovFlag == 1
            chunkData.statsHT.stageMovCount = chunkData.statsHT.stageMovCount +1;
            newStageMovFlag = 0;
        end
        chunkData.statsHT.stageMovFrameNo = chunkData.statsHT.stageMovFrameNo + 1;
        
        % Segment the video frame.
    else
        % Stage movement finished and the next stage movement will be
        % unique
        newStageMovFlag = 1;
        
        % Main segmentation step
        worm = segWorm(img, frame, 1, isDebugVideo);
        
        % Segmentation failed.
        if isempty(worm)
            % If the worm could not be segmented prevWorms is updated with
            % an empty cell for this fram
            prevWorms{end} = [];
            
            [~, warningMessageId] = lastwarn;
            warningLabel = warningMessageId2warningLabel(handles.warningList, warningMessageId);
            %update the structures
            totalUnsegmentedFrames = totalUnsegmentedFrames + 1;
            failedFrames(totalUnsegmentedFrames, :) = [frame + 1, warningLabel];
            % flag for segmentation error
            wormCell = 1;
            
        else
            % The frame segmented.
            totalSegmentedFrames = totalSegmentedFrames + 1;
            
            % Increase a valid frame counter
            chunkData.chunkValidFrameCounter = chunkData.chunkValidFrameCounter + 1;
            
            % Determine the worm orientation.
            if isempty(prevOrientWorm)
                chunkData.statsHT.hColourSum = chunkData.statsHT.hColourSum + worm.orientation.head.confidence.head;
                chunkData.statsHT.tColourSum = chunkData.statsHT.tColourSum + worm.orientation.head.confidence.tail;
                
                chunkData.statsHT.vColourSum = chunkData.statsHT.vColourSum + worm.orientation.vulva.confidence.vulva;
                chunkData.statsHT.nvColourSum = chunkData.statsHT.nvColourSum + worm.orientation.vulva.confidence.nonVulva;
                
                % CDF statistics. Here we have to refer to flip flag
                % to determine our head and tail
                
                if isWormStructHeadFlipped(worm)
                    headStr = 'head';
                    tailStr = 'tail';
                else
                    headStr = 'tail';
                    tailStr = 'head';
                end
                chunkData.statsHT.hCDFsum     = chunkData.statsHT.hCDFsum + worm.(headStr).cdf;
                chunkData.statsHT.tCDFsum     = chunkData.statsHT.tCDFsum + worm.(tailStr).cdf;
                chunkData.statsHT.cdfRatioSum = chunkData.statsHT.cdfRatioSum + worm.(headStr).cdf ./ worm.(tailStr).cdf;
                
                % STD
                chunkData.statsHT.hStdevSum = chunkData.statsHT.hStdevSum + worm.(headStr).stdev;
                chunkData.statsHT.tStdevSum = chunkData.statsHT.tStdevSum + worm.(tailStr).stdev;
                
                if worm.(tailStr).stdev < 1
                    chunkData.statsHT.stdevRatioSum = chunkData.statsHT.stdevRatioSum + worm.(headStr).stdev;
                else
                    chunkData.statsHT.stdevRatioSum = chunkData.statsHT.stdevRatioSum + worm.(headStr).stdev/worm.(tailStr).stdev;
                end
                
                % Advance.
                prevOrientWorm = worm;
                
                % We have segmented this frame but couldnt find previous
                % frame therefore we dont compute movement statistics
                prevWorms{end} = worm;
                
                %record result in wormCell for output
                wormCell = worm2cell(worm);
                
                % Orient the worm relative to the nearest segmented frame.
            else
                % Check if we are missing data for more then TIMETHR1 which
                % is a quarter of a second. If not, continue normally
                % without chunking. If yes, we call orientWormPostCoil.
                % Here is the rest of the algorithm:
                % 1. OrientWormPostCoil returns empty worm (no coil)
                %   1.1. Is the missing data shorter than TIMETHR2 which is
                %       half a second?
                %       1.1.1. If shorter - call regular orientWorm code.
                %       1.1.2. If longer - chunk it.
                % 2. If orientWormPostCoil worked - continue.
                
                missingDataTime = timestamp - chunkData.lastValidTimestamp;
                if missingDataTime > TIMETHR1
                    % If missing data is longer than 1.5s we dont call
                    % orientWormPostCoil 
                    if missingDataTime < TIMETHR3
                        postGapWorm = orientWormPostCoil(prevOrientWorm, worm, movesI, origins, pixel2MicronScale, rotation, 0);
                    else
                        postGapWorm = [];
                    end
                    
                    if ~isempty(postGapWorm)
                        % Worm chunking statistics counter
                        if missingDataTime > TIMETHR1 && missingDataTime <= TIMETHR2
                            % For the 1/4 to 1/2 second window, how many times did
                            % orientWormPostCoil return a worm
                            chunkData.statsHT.orientWormPostCoil1 = chunkData.statsHT.orientWormPostCoil1 + 1;
                        end
                        
                        if missingDataTime > TIMETHR2 && missingDataTime <= TIMETHR3
                            % For the 0.5 to 1.5 window, how many times
                            % did orientWormPostCoil return a worm.
                            chunkData.statsHT.orientWormPostCoil2 = chunkData.statsHT.orientWormPostCoil2 + 1;
                        end
                        
                        if missingDataTime > TIMETHR3
                              % After the 1.5 second thresh how many times 
                              % did orientWormPostCoil return a worm.
                            chunkData.statsHT.orientWormPostCoil3 = chunkData.statsHT.orientWormPostCoil3 + 1;
                        end
                    end
                    
                    % Lets check if wormPostGap is empty. In case its
                    % empty we will have to chunk
                    if isempty(postGapWorm)
                        % Is our data gap is smaller than half a second?
                        % Don't chunk -
                        if missingDataTime < TIMETHR2
                            % On 17-01-2012 I have found an error here when
                            % the first frame of the video is segmented and
                            % then there are no subsequently segmented
                            % frames. When the algorithm arrives to this
                            % point chunkData.lastValidTimestamp is equal
                            % to 0, because timestamp at the first frame is
                            % zero. However, the movementFrames vector is
                            % indexed from 1 so we will set the time stamp
                            % here chunkData.lastValidTimestamp to the end
                            % of first frame (seconds per frame).
                            if chunkData.lastValidTimestamp == 0
                                chunkData.lastValidTimestamp = spf;
                            end
                            % Checking for movement frames backwards
                            movFramesCheck = ...
                                movementFrames(...
                                    round(chunkData.lastValidTimestamp * fps):round(timestamp * fps)...
                                );
                            % Is previous frame a movement frame
                            if ~isempty(movementFrames) && sum(movFramesCheck) > 0
                                % Orient the worm at centroid and record its orientation confidences.
                                [worm, proximityConf, flipProximityConf] = ...
                                    orientWormAtCentroid(prevOrientWorm, worm, orientSamples);
                            else
                                % Orient the worm and record its orientation confidences.
                                [worm, proximityConf, flipProximityConf] = ...
                                    orientWorm(prevOrientWorm, worm, orientSamples);
                            end
                            %chunkData.proximityConf = chunkData.proximityConf + proximityConf;
                            %chunkData.flipProximityConf = chunkData.flipProximityConf + flipProximityConf;
                        else                        
                        % Chunk it!
                        % Here we have to subtract 1 from all of the
                        % counters because we are essentially re-doing
                        % this frame by calling continue at the bottom
                        j = j - 1;
                        globalFrameCounter = globalFrameCounter - 1;
                        % The frame segmented.
                        totalSegmentedFrames = totalSegmentedFrames - 1;
                        % Increase a valid frame counter
                        chunkData.chunkValidFrameCounter = chunkData.chunkValidFrameCounter - 1;
                        chunkOccured = 1;
                        % Reconstruct prev worms since we are redoing
                        % the frame.
                        prevWorms(2:end) = prevWorms(1:end-1);
                        % If chunking is innitiated then prevOrientWorm
                        % can no longer be used, because it comes from
                        % the previous chunk and proximity is not valid
                        % anymore (because there were too many missing frames).
                        prevOrientWorm = [];
                        prevTimestamp = (frame-1)/fps;
                        continue;
                        end
                    else
                        % Carry on
                        chunkOccured = 0;
                        worm = postGapWorm;
                    end
                else
                    if chunkData.lastValidTimestamp == 0
                        chunkData.lastValidTimestamp = spf;
                    end
                    % Edit 23-02-2013
                    %----------------
                    % Checking for movement frames backwards
                    movFramesCheck = ...
                        movementFrames(...
                        round(chunkData.lastValidTimestamp * fps):round(timestamp * fps)...
                        );
                    % Is previous frame a movement frame
                    if ~isempty(movementFrames) && sum(movFramesCheck) > 0
                    % Used to be: 
                    % Cbecm if there are movement frames at all and also
                    % check if the previous frame was movement frame
                    % if ~isempty(movementFrames) && movementFrames(frame)

                        % Orient the worm at centroid and record its orientation confidences.
                        [worm, proximityConf, flipProximityConf] = ...
                            orientWormAtCentroid(prevOrientWorm, worm, orientSamples);
                    else
                        % Orient the worm and record its orientation confidences.
                        [worm, proximityConf, flipProximityConf] = ...
                            orientWorm(prevOrientWorm, worm, orientSamples);
                    end
                    
                    %chunkData.proximityConf = chunkData.proximityConf + proximityConf;
                    %chunkData.flipProximityConf = chunkData.flipProximityConf + flipProximityConf;
                    
                    % Record the head and tail movement confidences.
                    if htMoveMinDiff <= frame
                        % Find the nearest previous differentiable worm.
                        % Initialize index to 0
                        prevWormsI = 0;
                        % Extract valid frames for movement differentiation
                        % from prevWorms cell array. Only the worms between
                        % 1/4th and 1/6th of a second before the current
                        % frame are considered. If there are some non empty
                        % worms we not the index and save it to prevWormsI
                        % variable.
                        prevWormsValid = prevWorms(1:(htMoveMaxDiff - htMoveMinDiff));
                        for i = 1:length(prevWormsValid)
                            if ~isempty(prevWorms{i})
                                prevWormsI = i;
                            end
                        end
                        
                        % Record the head and tail movement confidences if
                        % correct worm was found
                        if prevWormsI > 0
                            [hOrthoConfidence, tOrthoConfidence, ...
                                hParaConfidence, tParaConfidence, ...
                                headMagConfidence, tailMagConfidence] = ...
                                headTailMovementConfidence( ...
                                prevWorms{prevWormsI}, worm); %#ok<NASGU,ASGLU>
                        end
                    end
                    %------------------------------------------------------
                    % Ok, here we will record the confidecnes for head and
                    % tail detection.  
                    % 
                    % Record the confidences
                    % I don't check for the flip flag here because everything
                    % in the orientation part of the wormstruct is set
                    % correctly by orientWorm.
                    chunkData.statsHT.hColourSum = chunkData.statsHT.hColourSum + worm.orientation.head.confidence.head;
                    chunkData.statsHT.tColourSum = chunkData.statsHT.tColourSum + worm.orientation.head.confidence.tail;
                    
                    chunkData.statsHT.vColourSum = chunkData.statsHT.vColourSum + worm.orientation.vulva.confidence.vulva;
                    chunkData.statsHT.nvColourSum = chunkData.statsHT.nvColourSum + worm.orientation.vulva.confidence.nonVulva;
                    
                    chunkData.statsHT.hOrthoSum = chunkData.statsHT.hOrthoSum + hOrthoConfidence;
                    chunkData.statsHT.tOrthoSum = chunkData.statsHT.tOrthoSum + tOrthoConfidence;
                    
                    chunkData.statsHT.hParaAbsSum = chunkData.statsHT.hParaAbsSum + abs(hParaConfidence);
                    chunkData.statsHT.tParaAbsSum = chunkData.statsHT.tParaAbsSum + abs(tParaConfidence);
                    
                    chunkData.statsHT.hParaNASum = chunkData.statsHT.hParaNASum + hParaConfidence;
                    chunkData.statsHT.tParaNASum = chunkData.statsHT.tParaNASum + tParaConfidence;
                    
                    % If denominator is less than 1 we will default the
                    % value to 1
                    if tOrthoConfidence < 1
                        chunkData.statsHT.hOrthoVStOrthoRatio = chunkData.statsHT.hOrthoVStOrthoRatio + abs(hOrthoConfidence);
                    else
                        chunkData.statsHT.hOrthoVStOrthoRatio = chunkData.statsHT.hOrthoVStOrthoRatio + abs(hOrthoConfidence/tOrthoConfidence);                        
                    end
                    
                    if hParaConfidence < 1
                        chunkData.statsHT.hOrthoParaRatio = chunkData.statsHT.hOrthoParaRatio + abs(hOrthoConfidence);
                    else
                        chunkData.statsHT.hOrthoParaRatio = chunkData.statsHT.hOrthoParaRatio + abs(hOrthoConfidence/hParaConfidence);                        
                    end
                    
                    if tParaConfidence < 1
                        chunkData.statsHT.tOrthoParaRatio = chunkData.statsHT.tOrthoParaRatio + abs(tOrthoConfidence);
                    else
                        chunkData.statsHT.tOrthoParaRatio = chunkData.statsHT.tOrthoParaRatio + abs(tOrthoConfidence/tParaConfidence);
                    end
                    
                    % CDF statistics. Here we have to refer to flip flag
                    % to determine our head and tail
                    
                    if isWormStructHeadFlipped(worm)
                        headStr = 'head';
                        tailStr = 'tail';
                    else
                        headStr = 'tail';
                        tailStr = 'head';
                    end
                    chunkData.statsHT.hCDFsum  = chunkData.statsHT.hCDFsum + worm.(headStr).cdf;
                    chunkData.statsHT.tCDFsum  = chunkData.statsHT.tCDFsum + worm.(tailStr).cdf;
                    chunkData.statsHT.cdfRatioSum = chunkData.statsHT.cdfRatioSum + worm.(headStr).cdf ./ worm.(tailStr).cdf;
                    
                    % STD
                    chunkData.statsHT.hStdevSum = chunkData.statsHT.hStdevSum + worm.(headStr).stdev;
                    chunkData.statsHT.tStdevSum = chunkData.statsHT.tStdevSum + worm.(tailStr).stdev;
                    
                    if worm.(tailStr).stdev < 1
                        chunkData.statsHT.stdevRatioSum = chunkData.statsHT.stdevRatioSum + worm.(headStr).stdev;
                    else
                        chunkData.statsHT.stdevRatioSum = chunkData.statsHT.stdevRatioSum + worm.(headStr).stdev/worm.(tailStr).stdev;
                    end
                    
                    %------------------------------------------------------
                    % Reser the values to zero
                    hOrthoConfidence = 0;
                    tOrthoConfidence = 0;
                    hParaConfidence = 0;
                    tParaConfidence = 0;
                end
                % Advance.
                prevOrientWorm = worm;
                
                %prevWorms{mod(frame, length(prevWorms)) + 1} = worm;
                prevWorms{end} = worm;
                
                wormCell = worm2cell(worm);
            end
            % Get the new valid timestamp
            chunkData.lastValidTimestamp = timestamp;
        end
    end
    
    % Store worm data structure that now is in a cell
    blockOpen{j} = wormCell;
    
    % Advance to the next video frame.
    isVideoFrame = next(vr);
    clear('img');
    clear('worm');
end

%deal with the last block of the video file
blockOpen = blockOpen(1:j); %#ok<NASGU>
lastBlockSize = j; %#ok<NASGU>
%deal with H&T
%[blockOpen, ~] = headTail(chunkData, blockOpen, j, datFileName, timestamp, globalFrameCounter, blockNameStr); %#ok<ASGLU>

execString = strcat(blockNameStr,' = blockOpen;');
eval(execString);
datFileNameBlock = fullfile(segFileDir, [blockNameStr,'.mat']);
execString = strcat('save('' ', datFileNameBlock, ''',''', blockNameStr, ''');');
eval(execString);
blockList{blockCounter} = blockNameStr;  %#ok<NASGU>

load(datFileName, 'hAndtData');
if isempty(hAndtData)
    hAndtData = {chunkData}; %#ok<*NASGU>
else
    hAndtData = [hAndtData, chunkData];
end
execString = strcat('save('' ', datFileName,''',''-append'',''hAndtData'');');
eval(execString);

%--------------------------------------------------------------------------
% Here we will do postprocessing of the chunks and figure out which ones
% need to be reversed
%--------------------------------------------------------------------------
%hAndtData = fixSmallChunks(datFileName, myAviInfo, lastBlockSize, blockSize, samples);

%--------------------------------------------------------------------------
% Lets record  constants and other variables
save(datFileName, '-append', 'blockList', 'blockSize', 'lastBlockSize', 'orientSamples', 'pixel2MicronScale', 'rotation', 'vImg', 'fps', 'globalFrameCounter');

% Clean up
clear('blockOpen');
clear('blockList');
execString = strcat('clear(''',blockNameStr,''');');
eval(execString);
close(vr);

% Clean up failed frames
failedFrames((totalUnsegmentedFrames + 1):end,:) = []; %#ok<NASGU>
% Save failed frames file.
save(failedFramesFile, 'failedFrames');

% Update file locations
fileInfo.expList.segDat = datFileName;
fileInfo.expList.segDatDir = segFileDir;
fileInfo.expList.failedFramesFile = failedFramesFile;
% Update segmentation status
fileInfo.segmentation.version = mydata.preferences.version;
fileInfo.segmentation.completed = 1;
fileInfo.segmentation.timeStamp = datestr(now);
fileInfo.segmentation.totalSegmentedFrames = totalSegmentedFrames;
fileInfo.segmentation.totalUnsegmentedFrames = totalUnsegmentedFrames;
fileInfo.segmentation.totalStageMovementFrames = totalStageMovementFrames;
fileInfo.segmentation.totalDroppedFrames = totalDroppedFrames;
% Save the status
save(fileInfo.expList.status, 'fileInfo');

% Update GUI variable
mydata.experimentList{mydata.currentFile}.segDat = datFileName;
guidata(hObject, mydata);

function cleanupFun(videoHandle)
% This function will make sure video resources are released in case the
% function ends prematurely
try
    % Lets check if the variable is a valid handle if not - do nothing
    close(videoHandle);
catch ME1
end
