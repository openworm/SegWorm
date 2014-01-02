function [hAndtData, warningLevels] = chunkWarningLevels(fileInfo, hAndtData, myAviInfo, datFileName, lastBlockSize, globalFrameCounter)
% CHUNKWARNINGLEVELS Will compute reliability levels for chunks
%
%
% Input:
%           hAndtData - chunk data
%           myAviInfo - video information data
%           datFileName - file name of the segmentation annotation file
% Output:
%           warningLevels
%
% hAndtData, frames, myAviInfo
%
% See also: CHUNKVIEWER
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

totalFrames = globalFrameCounter;
chunkLen = length(hAndtData);
samples = [1:3 5:7] / 8;
thrSeconds = 3;

coloConfBased = zeros(1, chunkLen);
orthoConfBased = zeros(1, chunkLen);
paraAbsConfBased = zeros(1, chunkLen);
sizeBased = zeros(1, chunkLen);
chunkFrameLength = zeros(1, chunkLen);
chunkValidFrameLength = zeros(1, chunkLen);
chunkGap = zeros(1, chunkLen);
chunkIsFlippedBefore = false(1, chunkLen);
chunkIsFlippedAfter = false(1, chunkLen);
chunkProximity = nan(chunkLen, 4);

warningLevels{chunkLen} = [];

verbose = 0;


chunkPositions = zeros(chunkLen, 2);

% get the chunk frame number boundaries
for i=1:chunkLen
    if i==chunkLen
        chunkEnd = totalFrames;
    else
        chunkEnd = hAndtData{i+1}.globalStartFrame;
    end
    % chunk boundaries
    chunkPositions(i,1) = hAndtData{i}.globalStartFrame;
    chunkPositions(i,2) = chunkEnd;
    
    % confidence measures
    if hAndtData{i}.statsHT.hOrthoSum > hAndtData{i}.statsHT.tOrthoSum
        orthoConfBased(i) = 1;
    end
    
    if hAndtData{i}.statsHT.hParaAbsSum > hAndtData{i}.statsHT.tParaAbsSum
        paraAbsConfBased(i) = 1;
    end
    
    
    if hAndtData{i}.statsHT.hColourSum > hAndtData{i}.statsHT.tColourSum
        coloConfBased(i) = 1;
    end
    
    % size measure
    if (hAndtData{i}.chunkValidFrameCounter/myAviInfo.fps) > thrSeconds
        sizeBased(i) = 1;
    else
        sizeBased(i) = 0;
    end
    
    % chunk size and valid frame inside the chunk lengths
    chunkFrameLength(i) = diff(chunkPositions(i,:));
    chunkValidFrameLength(i) = hAndtData{i}.chunkValidFrameCounter;
end

% How many frames after valid frame till the end of chunk?
if lastBlockSize == 0
    lastChunkBlocks = [hAndtData{end}.startBlock, hAndtData{end}.blocks];
    blockName = lastChunkBlocks{end};
    [dirPart, ~] =fileparts(datFileName);
    %datFileNameBlock = strrep(datFileName, 'segInfo', blockName);
    datFileNameBlock = fullfile(dirPart, [blockName, '.mat']);                
    
    load(getRelativePath(datFileNameBlock), blockName);
    eval(['currentBlock = ', blockName,';']);
    execString = strcat('clear(''', blockName, ''');');
    eval(execString);
    lastBlockSize = length(currentBlock);
end


% Lets create a value in each chunk struct that stores the value of the last frame of the chunk
for i=1:chunkLen-1
    hAndtData{i}.endFrame = hAndtData{i+1}.startFrame;
end
hAndtData{end}.endFrame = lastBlockSize;

% exctarct flipping information. For this we will need to load the first and
% last frames of three chunks. If the chunks are a,b,c we will load last
% frame from chunk a, first and last from chunk b and first from chunk c.

% first lets check whats the size of the chunks, if its 1 chunk or 2 chunks
% we can't use the regular mode to load chunks a b c because we don't have
% them.

if chunkLen == 1
    chunkIsFlippedBefore(chunkLen) = true;
    chunkIsFlippedAfter(chunkLen) = true;
    
    chunkProximity(chunkLen,:) = [0, 0, 0, 0];
    
    firstChunkLast = getLastWormFromChunk(datFileName, hAndtData{chunkLen});
    
    if ~isempty(firstChunkLast)
        chunkGap(chunkLen) = totalFrames - firstChunkLast.video.frame;
    else
        chunkGap(chunkLen) = 0;
    end
    
elseif chunkLen == 2
    firstChunkLast = getLastWormFromChunk(datFileName, hAndtData{1});
    nextChunkFirst = getFirstWormFromChunk(datFileName, hAndtData{2});
    nextChunkLast = getLastWormFromChunk(datFileName, hAndtData{2});
    [worm2, proximityConf2, flipProximityConf2] = orientWormAtCentroid(firstChunkLast, nextChunkFirst, samples);
    chunkIsFlippedBefore(1) = true;
    chunkIsFlippedAfter(1) = worm2.orientation.head.isFlipped~=nextChunkFirst.orientation.head.isFlipped;
    chunkIsFlippedBefore(2) = worm2.orientation.head.isFlipped~=nextChunkFirst.orientation.head.isFlipped;
    chunkIsFlippedAfter(2) = true;
    
    if worm2.orientation.head.isFlipped == nextChunkFirst.orientation.head.isFlipped
        chunkProximity(1, :) = [0, 0, proximityConf2, flipProximityConf2];
    else
        chunkProximity(1, :) = [0, 0, flipProximityConf2, proximityConf2];
    end
    
    chunkGap(1) = nextChunkFirst.video.frame - firstChunkLast.video.frame;
    chunkGap(2) = totalFrames - nextChunkLast.video.frame;
    
    chunkProximity(2, :) = [0, 0, 0, 0];
else
    
    % special case for first chunk
    midChunkLast = getLastWormFromChunk(datFileName, hAndtData{1});
    nextChunkFirst = getFirstWormFromChunk(datFileName, hAndtData{2});
    [worm2, proximityConf2, flipProximityConf2] = orientWormAtCentroid(midChunkLast, nextChunkFirst, samples);
    chunkIsFlippedBefore(1) = true;
    chunkIsFlippedAfter(1) = worm2.orientation.head.isFlipped~=nextChunkFirst.orientation.head.isFlipped;

    if worm2.orientation.head.isFlipped == nextChunkFirst.orientation.head.isFlipped
        chunkProximity(1, :) = [0, 0, proximityConf2, flipProximityConf2];
    else
        chunkProximity(1, :) = [0, 0, flipProximityConf2, proximityConf2];
    end
    
    chunkGap(1) = nextChunkFirst.video.frame - midChunkLast.video.frame;
    for i=2:chunkLen-1
        prevChunkLast = getLastWormFromChunk(datFileName, hAndtData{i-1});
        midChunkFirst = getFirstWormFromChunk(datFileName, hAndtData{i});
        
        midChunkLast = getLastWormFromChunk(datFileName, hAndtData{i});
        nextChunkFirst = getFirstWormFromChunk(datFileName, hAndtData{i+1});
        
        [worm1, proximityConf1, flipProximityConf1] = orientWormAtCentroid(prevChunkLast, midChunkFirst, samples);
        [worm2, proximityConf2, flipProximityConf2] = orientWormAtCentroid(midChunkLast, nextChunkFirst, samples);
        
        chunkIsFlippedBefore(i) = worm1.orientation.head.isFlipped~=midChunkFirst.orientation.head.isFlipped;
        chunkIsFlippedAfter(i) = worm2.orientation.head.isFlipped~=nextChunkFirst.orientation.head.isFlipped;
        
        if worm1.orientation.head.isFlipped == midChunkLast.orientation.head.isFlipped
            chunkProximity(i, 1:2) = [proximityConf1, flipProximityConf1];
        else
            chunkProximity(i, 1:2) = [flipProximityConf1, proximityConf1];
        end
        if worm2.orientation.head.isFlipped == nextChunkFirst.orientation.head.isFlipped
            chunkProximity(i, 3:4) = [proximityConf2, flipProximityConf2];
        else
            chunkProximity(i, 3:4) = [flipProximityConf2, proximityConf2];
        end
    
        chunkGap(i) = nextChunkFirst.video.frame - midChunkLast.video.frame;
        
        if verbose
            drawImages(nextChunkFirst, midChunkLast, myAviInfo);
        end
    end
    % special case for last chunk
    prevChunkLast = getLastWormFromChunk(datFileName, hAndtData{i-1});
    midChunkFirst = getFirstWormFromChunk(datFileName, hAndtData{i});
    [worm1, proximityConf1, flipProximityConf1] = orientWormAtCentroid(prevChunkLast, midChunkFirst, samples);
    chunkIsFlippedBefore(chunkLen) = worm1.orientation.head.isFlipped~=midChunkFirst.orientation.head.isFlipped;
    chunkIsFlippedAfter(chunkLen) = true;
    chunkGap(chunkLen) = nextChunkFirst.video.frame - midChunkLast.video.frame;
    
    if worm1.orientation.head.isFlipped == midChunkFirst.orientation.head.isFlipped
        chunkProximity(chunkLen,:) = [proximityConf1, flipProximityConf1, 0, 0];
    else
        chunkProximity(chunkLen,:) = [flipProximityConf1, proximityConf1, 0, 0];
    end
end
%--------------------------------------------------------------------------


for i=1:chunkLen
    warningLevels{i}.chunkNumber = i;
    warningLevels{i}.sizeFlag = sizeBased(i);
    warningLevels{i}.colorationFlag = coloConfBased(i);
    warningLevels{i}.movementOrthoFlag = orthoConfBased(i);
    warningLevels{i}.movementParaAbsFlag = paraAbsConfBased(i);
    warningLevels{i}.flipBefore = chunkIsFlippedBefore(i);
    warningLevels{i}.flipAfter = chunkIsFlippedAfter(i);
    
    % CDF
    hCDFsumStr = 'hCDFsum';
    tCDFsumStr = 'tCDFsum';
    cdfRatioSumStr = 'cdfRatioSum';
    cdfRatioOfSumsStr = 'cdfRatioOfSums';
    
    tmp = hAndtData{i}.statsHT.hCDFsum./hAndtData{i}.statsHT.tCDFsum;
    for j=1:length(hAndtData{i}.statsHT.hCDFsum)
        warningLevels{i}.([hCDFsumStr,num2str(j)]) = hAndtData{i}.statsHT.hCDFsum(j);
        warningLevels{i}.([tCDFsumStr,num2str(j)]) = hAndtData{i}.statsHT.tCDFsum(j);
        if length(hAndtData{i}.statsHT.cdfRatioSum) == length(hAndtData{i}.statsHT.hCDFsum)
            warningLevels{i}.([cdfRatioSumStr,num2str(j)]) = hAndtData{i}.statsHT.cdfRatioSum(j);
        else
            warningLevels{i}.([cdfRatioSumStr,num2str(j)]) = hAndtData{i}.statsHT.cdfRatioSum(1);
        end
        warningLevels{i}.([cdfRatioOfSumsStr,num2str(j)]) = tmp(j);
    end
    
    % STD
    warningLevels{i}.hStdevSum = hAndtData{i}.statsHT.hStdevSum;
    warningLevels{i}.tStdevSum = hAndtData{i}.statsHT.tStdevSum;
    warningLevels{i}.stdevRatioSum = hAndtData{i}.statsHT.stdevRatioSum;
    warningLevels{i}.cdfRatioOfSums = warningLevels{i}.hStdevSum/warningLevels{i}.tStdevSum;
    % Ortho
    warningLevels{i}.hOrthoSum = hAndtData{i}.statsHT.hOrthoSum;
    warningLevels{i}.tOrthoSum = hAndtData{i}.statsHT.tOrthoSum;
    
    if warningLevels{i}.tOrthoSum < 1
        warningLevels{i}.orthoRatioOfSums = warningLevels{i}.hOrthoSum;
    else
        warningLevels{i}.orthoRatioOfSums = warningLevels{i}.hOrthoSum/warningLevels{i}.tOrthoSum;
    end
    warningLevels{i}.hOrthoVStOrthoRatio = hAndtData{i}.statsHT.hOrthoVStOrthoRatio;
    
    % Para
    warningLevels{i}.hParaAbsSum = hAndtData{i}.statsHT.hParaAbsSum;
    warningLevels{i}.tParaAbsSum = hAndtData{i}.statsHT.tParaAbsSum;
    if warningLevels{i}.tParaAbsSum < 1
        warningLevels{i}.paraAbsRatioOfSums = warningLevels{i}.hParaAbsSum;
    else
        warningLevels{i}.paraAbsRatioOfSums = warningLevels{i}.hParaAbsSum/warningLevels{i}.tParaAbsSum;
    end
    
    warningLevels{i}.hParaNASum = hAndtData{i}.statsHT.hParaNASum;
    warningLevels{i}.tParaNASum = hAndtData{i}.statsHT.tParaNASum;
    if abs(warningLevels{i}.tParaNASum) < 1
        warningLevels{i}.paraNARatioOfSums = warningLevels{i}.hParaNASum;
    else
        warningLevels{i}.paraNARatioOfSums = warningLevels{i}.hParaNASum/warningLevels{i}.tParaNASum;
    end
    % Proximity
    proxStr = 'proxFrameConfidence';
    for j =1:length(chunkProximity(i,:))
        warningLevels{i}.([proxStr,num2str(j)]) = chunkProximity(i,j);
    end
    
    warningLevels{i}.proxRatio1 = warningLevels{i}.([proxStr,num2str(1)])/warningLevels{i}.([proxStr,num2str(2)]);
    warningLevels{i}.proxRatio2 = warningLevels{i}.([proxStr,num2str(3)])/warningLevels{i}.([proxStr,num2str(4)]);
    %determine chunk gap
    warningLevels{i}.gapBetweenChunks = chunkGap(i);
    if i ==1
        prevChunkGap = 1;
        nextChunkGap = warningLevels{i}.gapBetweenChunks;
    elseif i == chunkLen
        prevChunkGap = warningLevels{i-1}.gapBetweenChunks;
        nextChunkGap = 1;
    else
        prevChunkGap = warningLevels{i-1}.gapBetweenChunks;
        nextChunkGap = warningLevels{i}.gapBetweenChunks;
    end
    warningLevels{i}.proxRatio1byGap = (warningLevels{i}.([proxStr,num2str(1)])/warningLevels{i}.([proxStr,num2str(2)]))/prevChunkGap;
    warningLevels{i}.proxRatio2byGap = (warningLevels{i}.([proxStr,num2str(3)])/warningLevels{i}.([proxStr,num2str(4)]))/nextChunkGap;
    
    warningLevels{i}.stageMovCount = hAndtData{i}.statsHT.stageMovCount;
    warningLevels{i}.stageMovFrameNo = hAndtData{i}.statsHT.stageMovFrameNo;
    
	% previous criteria
    if hAndtData{i}.statsHT.tOrthoParaRatio < 1
        warningLevels{i}.HTorthoParaSumOfRatios = hAndtData{i}.statsHT.hOrthoParaRatio;
    else
        warningLevels{i}.HTorthoParaSumOfRatios = hAndtData{i}.statsHT.hOrthoParaRatio / hAndtData{i}.statsHT.tOrthoParaRatio;
    end
    % HTorthoParaSumOfRatios - email how its done
    
    if hAndtData{i}.statsHT.tParaAbsSum < 1
        warningLevels{i}.tOrthoVStParaAbs = hAndtData{i}.statsHT.tOrthoSum;
        warningLevels{i}.hParaAbsVStParaAbs = hAndtData{i}.statsHT.hParaAbsSum;
    else
        warningLevels{i}.tOrthoVStParaAbs =  hAndtData{i}.statsHT.tOrthoSum / hAndtData{i}.statsHT.tParaAbsSum;
        warningLevels{i}.hParaAbsVStParaAbs = hAndtData{i}.statsHT.hParaAbsSum / hAndtData{i}.statsHT.tParaAbsSum;
    end
    
    if hAndtData{i}.statsHT.hParaAbsSum < 1
        warningLevels{i}.hOrthoVShParaAbs =  hAndtData{i}.statsHT.hOrthoSum;
    else
        warningLevels{i}.hOrthoVShParaAbs =  hAndtData{i}.statsHT.hOrthoSum / hAndtData{i}.statsHT.hParaAbsSum;
    end
       
    warningLevels{i}.hParaNAvsValid = hAndtData{i}.statsHT.hParaNASum/chunkValidFrameLength(i);
    warningLevels{i}.tParaNAvsValid = hAndtData{i}.statsHT.tParaNASum/chunkValidFrameLength(i);
    
    warningLevels{i}.hParaAbsByValidSqrt =  hAndtData{i}.statsHT.hParaAbsSum/sqrt(chunkValidFrameLength(i));
    warningLevels{i}.hParaAbsByTotalSqrt =  hAndtData{i}.statsHT.hParaAbsSum/sqrt(chunkFrameLength(i));
    
    warningLevels{i}.hParaNAByValidSqrt =  hAndtData{i}.statsHT.hParaNASum/sqrt(chunkValidFrameLength(i));
    warningLevels{i}.hParaNAByTotalSqrt =  hAndtData{i}.statsHT.hParaNASum/sqrt(chunkFrameLength(i));
    
    warningLevels{i}.tParaAbsByValidSqrt = hAndtData{i}.statsHT.tParaAbsSum/sqrt(chunkValidFrameLength(i));   
    warningLevels{i}.tParaAbsByTotalSqrt = hAndtData{i}.statsHT.tParaAbsSum/sqrt(chunkFrameLength(i));   
    warningLevels{i}.tParaNAByValidSqrt = hAndtData{i}.statsHT.tParaNASum/sqrt(chunkValidFrameLength(i));   
    warningLevels{i}.tParaNAByTotalSqrt = hAndtData{i}.statsHT.tParaNASum/sqrt(chunkFrameLength(i));   
    
    warningLevels{i}.frameLength = chunkFrameLength(i);
    warningLevels{i}.validFrameLength = chunkValidFrameLength(i);
    
    warningLevels{i}.chunkStart = chunkPositions(i,1);
    warningLevels{i}.chunkEnd = chunkPositions(i,2);
    
    warningLevels{i}.orientWormPostCoil1 = hAndtData{i}.statsHT.orientWormPostCoil1;
    warningLevels{i}.orientWormPostCoil2 = hAndtData{i}.statsHT.orientWormPostCoil2;
    warningLevels{i}.orientWormPostCoil3 = hAndtData{i}.statsHT.orientWormPostCoil3;
    
    %--
    % Reliability
    warningLevels{i}.reliability = -~sizeBased(i) - ...
        ~(orthoConfBased(i) & coloConfBased(i)) - ...
        ~(orthoConfBased(i) & paraAbsConfBased(i)) - ...
        chunkIsFlippedBefore(i) - ...
        chunkIsFlippedAfter(i);
    hAndtData{i}.reliability = warningLevels{i}.reliability;
end
verbose = 1;

if verbose
    %chunkLabelsFile = strrep(datFileName,'segInfo','chunkLabels');
    chunkLabelsFile = strrep(datFileName,'segInfo','chunkLabels');
    
    if exist(chunkLabelsFile,'file')
        load(getRelativePath(chunkLabelsFile));
    else
        chunkLabels = zeros(1,chunkLen);
    end
    
    for i=1:chunkLen
        warningLevels{i}.chunkCheck = chunkLabels(i);
    end
    
    outputName = fullfile('c:\home\chunkLabels2\',[fileInfo.expList.fileName,'_','chunk_labels_new.csv']);
    
    
    %Ok, here we will write out the csv file programatically
    
    headerLabels = fields(warningLevels{1})';
    fprintfString = repmat('%s, ', 1, length(headerLabels));
    fprintfStringFinal = [fprintfString(1:end-2),'\n'];
    
    
    fid = fopen(getRelativePath(outputName), 'wt');
    [~, fileName]= fileparts(outputName);
    fprintf(fid, '%s\n', fileName);
    
%     headerlabels = {'Chunk no', 'Manual Check', 'Size', 'Ortho based flag', '(hOrhto/hPara)/(tOrtho/tPara)', 'hOrtho/tOrtho', 'hPara/tPara',...
%        'tOrtho/tPara', 'hOrtho/hPara', 'Para based flag', 'Para head Valid', 'Para head total',  'Para tail valid', 'Para tail total',...
%        'NAhPara/valid frames','NAtPara/validFrames', 'Coloration based flag',...
%        'Flipped before', 'Flipped after', 'Proximity 1', 'Flip proximity 1', 'Proximity 2', 'Flip proximity2', 'Proximity ratio','Frame no',...
%        'Valid Frames', 'Chunk gap', 'Reliability', 'Start', 'End'};

    fprintf(fid, fprintfStringFinal, headerLabels{1,:});
    
    for i=1:chunkLen
        dataToPrint = struct2cell(warningLevels{i})';
        fprintfString = repmat('%3.5f, ', 1, length(dataToPrint));
        fprintfStringFinal = [fprintfString(1:end-2),'\n'];
        fprintf(fid, fprintfStringFinal, dataToPrint{1,:});
        
%         fprintf(fid, '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n', ...
%             i, ...
%             chunkLabels(i), ...
%             warningLevels{i}.sizeConfidence, ...
%             warningLevels{i}.movementOrthoConfidence, ...
%             warningLevels{i}.movementOrthoParaRatio, ...
%             warningLevels{i}.hOrthoTOrthoRatio,...
%             warningLevels{i}.hParaTParaRatio,...
%             warningLevels{i}.tOrthoTParaRatio,...
%             warningLevels{i}.hOrthoHParaRatio,...
%             warningLevels{i}.movementParaConfidence, ...
%             warningLevels{i}.movementParaConfidenceHeadValid, ...
%             warningLevels{i}.movementParaConfidenceHeadTotal, ...
%             warningLevels{i}.movementParaConfidenceTailValid, ...
%             warningLevels{i}.movementParaConfidenceTailTotal, ...
%             warningLevels{i}.NAhParaValidFrames,...
%             warningLevels{i}.NAtParaValidFrames,...
%             warningLevels{i}.colorationConfidence, ...
%             warningLevels{i}.flipBefore, ...
%             warningLevels{i}.flipAfter, ...
%             warningLevels{i}.proxFrameConfidence(1), ...
%             warningLevels{i}.proxFrameConfidence(2), ...
%             warningLevels{i}.proxFrameConfidence(3), ...
%             warningLevels{i}.proxFrameConfidence(4), ...
%             warningLevels{i}.proxFrameConfidenceRatio, ...        
%             warningLevels{i}.frameLength, ...
%             warningLevels{i}.validFrameLength, ...
%             warningLevels{i}.gapBetweenChunks, ...
%             warningLevels{i}.reliability, ...
%             chunkPositions(i,1), ...
%             chunkPositions(i,2) ...
%             );
    end
    fclose(fid);
end