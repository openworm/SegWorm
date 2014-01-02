function htStats = headTail(datFileName, fileInfo, blockSize, lastBlockSize, globalFrameCounter, preferences)
% HEADTAIL This function will flip the raw segmentation data according to the head and tail
% assignment by the LDA. 
% Input:
%       datFileName - file name for experiment segmentation data
%       fileInfo - experiment status and file location 
%       blockSize - size of blocks
%       lastBlockSize - size of the  last block
%       globalFrameCounter - total number of frames
% Output:
%       htStats - struct that contains chunk statistics and class data
%
%
% Contains functions: 
%   getTrainingData - this function will load training data from the
%   package or cusom calibration file
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Here we load the head and tail data
hAndtData = [];
load(datFileName,'hAndtData');
hAndtDataLen = length(hAndtData);

% We loop through all of the chunks and add relevant inforamtion about
% chunk length
for i=1:hAndtDataLen-1
    % Here we subtract 1 because the end of the chunk needs to be a frame before
    % the first valid frame of the next chunk. We also check if the start
    % frame is not the first frame in the block. Subtracting 1 from that
    % would result in a start frame 0 which is incorrect. So we have an
    % else clause that sets the end farme to the last frame of a previous
    % block and removes one block from the block list.
    if hAndtData{i+1}.startFrame ~= 1
        hAndtData{i}.endFrame = hAndtData{i+1}.startFrame - 1;
        hAndtData{i}.globalEndFrame = hAndtData{i+1}.globalStartFrame - 1;
    else
        if ~isempty(hAndtData{i}.blocks)
            hAndtData{i}.endFrame = blockSize;
            hAndtData{i}.blocks = hAndtData{i}.blocks(1:end-1);
            hAndtData{i}.globalEndFrame = hAndtData{i+1}.globalStartFrame - 1;
        end
    end
end
% Save values for the last chunk
hAndtData{end}.endFrame = lastBlockSize;
hAndtData{end}.globalEndFrame = globalFrameCounter;

% Define matrix for LDA
LDAchunkData = zeros(hAndtDataLen, 9);

% Main loop for each chunk to compute head and tail data that will be
% compared to the training set
for chunkNo = 1:hAndtDataLen
    % Retrieve chunk data
    chunkData = hAndtData{chunkNo};
    % Get CDF ratios (head CDF sums for all frames in a chunk) divided by (tail CDF sums for all frames in a chunk)
    % Check if some values are not 0
    LDAchunkData(chunkNo, 2:6) = chunkData.statsHT.hCDFsum./chunkData.statsHT.tCDFsum;
    
    % Here check not to divide by zero
    if sum(chunkData.statsHT.tCDFsum==0) > 0
        tmp = LDAchunkData(chunkNo, 2:6);
        tmp(chunkData.statsHT.tCDFsum==0) = 0;
        LDAchunkData(chunkNo, 2:6) = tmp;
    end
    
    % Check if tParaAbsSum is significant for division
    if chunkData.statsHT.tParaAbsSum < 1
        tOrthoVStParaAbs = chunkData.statsHT.tOrthoSum;
    else
        tOrthoVStParaAbs =  chunkData.statsHT.tOrthoSum / chunkData.statsHT.tParaAbsSum;
    end
    % Check if hParaAbsSum is significant for division
    if chunkData.statsHT.hParaAbsSum < 1
        hOrthoVShParaAbs =  chunkData.statsHT.hOrthoSum;
    else
        hOrthoVShParaAbs =  chunkData.statsHT.hOrthoSum / chunkData.statsHT.hParaAbsSum;
    end
    % Record values in LDA matrix
    LDAchunkData(chunkNo, 7:8) = [tOrthoVStParaAbs, hOrthoVShParaAbs];
    % Record frame number that contributed to coloration and motion data
    LDAchunkData(chunkNo, 9) = chunkData.chunkValidFrameCounter;
    % Record chunk number
    LDAchunkData(chunkNo, 10) =  chunkNo;
end
% Here we have two modes that we operate in. Normal chunks that have both
% coloration and motion data and rare chunks that have very little frames
% thus dont have motion data. In these cases we will rely only on the
% coloration data to determine head and tail.

% Identify chunks that have motion data
LDAchunkDataOrthoFlag = (LDAchunkData(:,7) ~= 0);

% Extract sample chunks that have motion data
sampleOrtho = LDAchunkData(LDAchunkDataOrthoFlag, :);
% Extract sample chunks that dont have motion data. for these chunks we
% will use the classifier without motion data
sampleNoOrtho = LDAchunkData(~LDAchunkDataOrthoFlag, :);

% Retrive the training set - trainingOrtho will be the training set to be
% used for chunks that have motion information. trainingNoOrtho will be the
% training set for chunks without motion data. In case there are no
% training set chunks with no motion data this funcion will issue a warning
% and will use the data with motion data as a training set. It will also
% issue a warning if not enough samples are provided for the training set.
[trainingOrtho, trainingNoOrtho, groupOrtho, groupNoOrtho] = getTrainingData(preferences, sampleNoOrtho);

% Define posterior probability matrix
posteriorProbs = zeros(chunkNo,2);
% Classify chunks with motion data
[classOrtho, ~, POSTERIORortho, ~] = classify(sampleOrtho(:,2:end-2), trainingOrtho(:,2:end-1), groupOrtho);
% Classify chunks without motion data
if ~isempty(sampleNoOrtho)
    [classNoOrtho, ~, POSTERIORnoOrtho, ~] =  classify(sampleNoOrtho(:,2:end-4), trainingNoOrtho(:,2:end-3), groupNoOrtho);
else
    classNoOrtho = zeros(0,1);
    POSTERIORnoOrtho = zeros(0,2);
end
% For chunks with motion data assign class and posterior probability
for i=1:length(classOrtho)
    LDAchunkData(sampleOrtho(i, 10), 1) = classOrtho(i);
    posteriorProbs(sampleOrtho(i, 10), :) = POSTERIORortho(i,:);
end
% For chunks without motion data assign class and posterior probability
for i=1:length(classNoOrtho)
    LDAchunkData(sampleNoOrtho(i, 10),1) = classNoOrtho(i);
    posteriorProbs(sampleNoOrtho(i, 10), :) = POSTERIORnoOrtho(i,:);
end

% Here lets determine the reliability scores for each chunk
reliabilityBoundaries = 0:0.01:0.5;
% Function histc will bin everything in such a manner where first bin is
% values between 0..0.01, second 0.01..0.02, etc. and the last value
% 0.5..0.51. Which means that everything in bin 0.49..0.5 should get
% minimum score, it will be one before last bin. Below we will add 0 score
% for the last bin and remove the first score. Effectively we will score
% from 0 to length(reliabilityBoundaires)-1
scores = [length(reliabilityBoundaries):-1:1, 0];
scores = scores(2:end);

for chunkNo = 1 : hAndtDataLen
    reliability = histc(abs(posteriorProbs(chunkNo,1) - 0.5), reliabilityBoundaries);
    hAndtData{chunkNo}.reliability = scores(logical(reliability)); %#ok<*AGROW>#
end

for chunkNo = 1 : hAndtDataLen
    chunkData = hAndtData{chunkNo};

    if LDAchunkData(chunkNo, 1)
        % everything that is head should stay head and that is labeled
        % as flipped should be flipped
        % 'head is head';
        
        % first lets create a list of blocks that we will have to deal with
        allBlocks = [chunkData.startBlock, chunkData.blocks];
        if ~iscell(allBlocks)
            allBlocks = {allBlocks};
        end
        % here lets deal with all of the blocks
        for blockNumber = 1:length(allBlocks)
            % first block needs to be indexed from startFrame, other from
            % the beginning
            if blockNumber == 1
                startIndex = chunkData.startFrame;
            else
                startIndex = 1;
            end
            
            % Here lets define the endIndex. If its the last block the
            % endIndex is the endFrame from the chunkData
            if blockNumber == length(allBlocks)
                endIndex = chunkData.endFrame;
            else
                endIndex = blockSize;
            end
            
            [dirPart, ~] = fileparts(datFileName);
            datFileNameBlock = fullfile(dirPart, [allBlocks{blockNumber},'.mat']);
            chunkDataBlock = load(datFileNameBlock, allBlocks{blockNumber});
            
            fixedBlock = correctWormBlockData(1, chunkDataBlock.(allBlocks{blockNumber}), startIndex, endIndex); %#ok<NASGU>
            
            % save block
            execString = strcat(allBlocks{blockNumber},' = fixedBlock;');
            eval(execString);
            
            execString = strcat('save('' ',datFileNameBlock,''',''',allBlocks{blockNumber},''');');
            eval(execString);
            clear('chunkDataBlock');
            clear('fixedBlock');
            execString = strcat('clear(''',allBlocks{blockNumber},''');');
            eval(execString);
        end
    else
        % everything that is head should now be flipped and
        % labeled as tail
        % flipped flag will become 1 in all of these frames
        % 'head is tail';
        
        % Our head and tail statistics should also flip, what was calculated
        % under head should now be assigned under tail
        chunkData = flipChunkData(chunkData);
        hAndtData{chunkNo} = chunkData;
        
        % first lets create a list of blocks that we will have to deal with
        allBlocks = [chunkData.startBlock, chunkData.blocks];
        if ~iscell(allBlocks)
            allBlocks = {allBlocks};
        end
        for blockNumber = 1:length(allBlocks)
            % first block needs to be indexed from startFrame, other from
            % the beginning
            if blockNumber == 1
                startIndex = chunkData.startFrame;
            else
                startIndex = 1;
            end
            % Here lets define the endIndex. If its the last block the
            % endIndex is the endFrame from the chunkData
            if blockNumber == length(allBlocks)
                endIndex = chunkData.endFrame;
            else
                endIndex = blockSize;
            end
            [dirPart, ~] =fileparts(datFileName);
            datFileNameBlock = fullfile(dirPart, [allBlocks{blockNumber},'.mat']);
            chunkDataBlock = load(datFileNameBlock, allBlocks{blockNumber});

            fixedBlock = correctWormBlockData(0, chunkDataBlock.(allBlocks{blockNumber}), startIndex, endIndex); %#ok<NASGU>
            
            % save block
            execString = strcat(allBlocks{blockNumber},' = fixedBlock;');
            eval(execString);
            
            execString = strcat('save('' ', datFileNameBlock, ''',''', allBlocks{blockNumber}, ''');');
            
            eval(execString);
            clear('chunkDataBlock');
            clear('fixedBlock');
            execString = strcat('clear(''',allBlocks{blockNumber},''');');
            eval(execString);
        end
    end
end

% Construct output struct
htStats = [];
for chunkNo = 1:length(hAndtData)
    htStats{chunkNo}.chunkNo = LDAchunkData(chunkNo,10);
    htStats{chunkNo}.class = LDAchunkData(chunkNo,1);
    htStats{chunkNo}.cdfRatio1 = LDAchunkData(chunkNo,2);
    htStats{chunkNo}.cdfRatio2 = LDAchunkData(chunkNo,3);
    htStats{chunkNo}.cdfRatio3 = LDAchunkData(chunkNo,4);
    htStats{chunkNo}.cdfRatio4 = LDAchunkData(chunkNo,5);
    htStats{chunkNo}.cdfRatio5 = LDAchunkData(chunkNo,6);
    
    htStats{chunkNo}.tOrthoVStParaAbs = LDAchunkData(chunkNo,7);
    htStats{chunkNo}.hOrthoVShParaAbs = LDAchunkData(chunkNo,8);
    
    htStats{chunkNo}.validFrames = LDAchunkData(chunkNo,9);
    htStats{chunkNo}.posteriorReliability = hAndtData{chunkNo}.reliability;
    htStats{chunkNo}.startFrame = hAndtData{chunkNo}.globalStartFrame;
    htStats{chunkNo}.endFrame = hAndtData{chunkNo}.globalEndFrame;
end

execString = strcat('save('' ',datFileName,''',''-append'',''hAndtData'',''htStats'');');
eval(execString);

% Export H&T statistics values
headerLabels = fields(htStats{1})';
fprintfString = repmat('%s, ', 1, length(headerLabels));
fprintfStringFinal = [fprintfString(1:end-2),'\n'];

%outputName = fullfile(fileInfo.expList.segDatDir, 'chunk_labels_new.csv');
outputName = strrep(datFileName, 'segInfo.mat', [fileInfo.expList.fileName,'_H&T.csv']);

fid = fopen(getRelativePath(outputName), 'wt');

fprintf(fid, fprintfStringFinal, headerLabels{1,:});

for i=1:length(hAndtData)
    dataToPrint = struct2cell(htStats{i})';
    fprintfString = repmat('%3.5f, ', 1, length(dataToPrint));
    fprintfStringFinal = [fprintfString(1:end-2),'\n'];
    fprintf(fid, fprintfStringFinal, dataToPrint{1,:});
end
fclose(fid);

function [trainingOrtho, trainingNoOrtho, groupOrtho, groupNoOrtho] = getTrainingData(preferences, sampleNoOrtho)
%GETTRAININGDATA This function will load heand and tail classification
%training data. There are two possible locations - a matlab file that is
%included in the compiled package or a custom local file that has been
%build in the preferences section. This function will issue a warning if
%there are not enough chunks to have a reliable training set. The suggested
%number will be between 150-500. It will also 
%
% Input:
%       preferences - this data structure is inherited from the parent
%       function and has local configuration parameters
%       sampleNoOrtho - sample data for chunks that have no motion data.
%       This will be used to check if warnings and additional steps need to
%       be carried out in case the user has defined custom training set.
% Output:
%       trainingOrtho - classifier training set for chunks that have motion
%       data
%       trainingNoOrtho - classifier trianing set for chunks that don't
%       have motion data
%       groupOrtho - classification flag indicating which chunks are head
%       and which are tail for the group that has motion data
%       groupNoOrtho - classification flag indicating which chunks are head
%       and which are tail for the group that doesnt have motion data

if preferences.calibrated_ht == 0
    trainingData = [];
    % File trainingData.mat contains LDA data and class for prediction of head
    % and tail. It is stored in GUI directory, is in the path and can be loaded
    % this way.
    load('trainingData.mat');
    
    % Identify chunks in the training set that have motion data
    trainingDataOrthoFlag = (trainingData(:,7) ~= 0);
    
    % Get the training data. First we extract the chunks that have motion data
    trainingOrtho = trainingData(trainingDataOrthoFlag,:);
    % We also extract chunks that dont have motion data
    trainingNoOrtho = trainingData(~trainingDataOrthoFlag,:);
    
    % Define the groups - with motion data
    groupOrtho = trainingData(trainingDataOrthoFlag,1);
    % Define the groups - without motion data
    groupNoOrtho = trainingData(~trainingDataOrthoFlag,1);

else
    % Load file fromt the location next to the exacutable (ctfroot)
    % Define the file name for custom calibration data
    outFileName = [ctfroot,filesep,'wormAnalysisToolboxUserData',filesep,'trainingDataCustom.mat'];

    % Load file if exists
    if exist(outFileName, 'file') == 2
        trainingDataCustom = [];
        load(outFileName);
        trainingData = trainingDataCustom;
        
        if size(trainingData, 1) < 30
            error('headTail:calibrationDataError', 'Custom calibration data has too little information to do accurate automatic head and tail detection. Please add more data in the calibration step. Refer to user guide for more information.')
        end
            
        % Identify chunks in the training set that have motion data
        trainingDataOrthoFlag = (trainingData(:,7) ~= 0);
        
        % Get the training data. First we extract the chunks that have motion data
        trainingOrtho = trainingData(trainingDataOrthoFlag,:);
        % We also extract chunks that dont have motion data
        trainingNoOrtho = trainingData(~trainingDataOrthoFlag,:);
        
        % Define the groups - with motion data
        groupOrtho = trainingData(trainingDataOrthoFlag,1);
        % Define the groups - without motion data
        groupNoOrtho = trainingData(~trainingDataOrthoFlag,1);

        
        % Issure a warning if trainingData has less than 200 chunks or the
        % group of the trainingData that defines chunks that have motion
        % data has less than 200 chunks
        
        warningText = ['Custom head and tail trainging data has less ',...
            'than 200 chunks defined. Add more [exp_file_name]_h&t.csv ',...
            'files at the calibration step to have more reliable training set! ', ...
            'Note: you can disable these warnings in preferences.'];
        
        warningTitle = 'Head and tail detection warning';
        
        if size(trainingData,1) < 200 || size(trainingOrtho,1) < 100 
            if ~preferences.disableWarnings_ht
                warndlg(warningText, warningTitle, 'replace');
            end
        end
        
        % Issue a warning if this video has chunks that have no motion data
        % and our custom training set has no training data for such
        % chunkgs. E.g. its trainingNoOrtho is = 0
        if size(sampleNoOrtho, 1) ~= 0
            % Check if the training set has noOrtho data
            if size(trainingNoOrtho, 1) > 15
                % In case it has some noOrtho data check if the dataset is
                % large enough
                 if size(trainingNoOrtho,1) < 100 
                    if ~preferences.disableWarnings_ht
                        warndlg(warningText, warningTitle, 'replace');
                    end
                 end
            else
                % In case you have no noOrtho data then issue a warning and
                % use the data that has motion data
                %warningText = ['Some portions of the video have not enough ',...
                %    'data to include motion in automaticaly assigning head ',...
                %    'and tail. For these chunks default training set has been ',...
                %    'prepared to '];
                warningText = ['You have not enough data in your custom ',...
                    'head and tail detection training set for very short ',...
                    'chunks. The algorithm will use all of the available ',...
                    'custom training data to determine head and tail. ',...
                    'Note: you can disable these warnings in preferences.'];                
                if ~preferences.disableWarnings_ht
                    warndlg(warningText, warningTitle, 'replace');
                end
                % Here we assign custom training data that has motion
                % data to custon training data that hasnt
                trainingNoOrtho =  trainingData;
                % Define the groups - with motion data
                groupNoOrtho = trainingData(:,1);
                
            end
        end
    else
        error('headTail:calibrationDataError', 'Custom calibration data could not be found.')
    end
end