function normWormProcess(fileInfo, handles)
%NORMWORMPROCESS This function loads the raw segmentation and outputs it in
%normalized format. It saves the blocks in the normalized folder and
%organizes them just like raw segmentation
%
% Input:
%       fileInfo -  structure containing location of all files and pipeline
%                   status information 
%       handles -   GUI handle object
% Output:
%       normBlocks files - each contain a blockN variable wher N is from 1
%       to number of blocks. The variable is organized in this fashion:
%       blockN{1}  = status:
%                    s = segmented
%                    f = segmentation failed
%                    m = stage movement
%                    d = dropped frame
%       blockN{2}  = vulvaContours
%       blockN{3}  = nonVulvaContours
%       blockN{4}  = skeletons
%       blockN{5}  = angles
%       blockN{6}  = inOutTouches
%       blockN{7}  = lengths
%       blockN{8}  = widths
%       blockN{9}  = headAreas
%       blockN{10} = tailAreas
%       blockN{11} = vulvaAreas
%       blockN{12} = nonVulvaAreas
%
%       segNormInfo -   file containing the information about the experiment
%                       normBlockList - string array with block names
%                       myAviInfo - video file information structure
%                       datestamp - date that this file was created
%                       SAMPLES - number of "joints" that the worm is
%                       downsampled to
%                       hAndTData - head and tail data for each chunk and
%                       its starting locations.
%                       pixel2MicronScale - conversion coefficient from
%                       pixels to microns
%                       rotation - camera rotation values
%                       reliabilityLevels - structure recording each chunks
%                       reliability level
%
% See also: segmentationMain, populateDatabase
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

stageMovementFile = fileInfo.expList.stageMotion;

%read stage movement files
if exist(stageMovementFile,'file') == 2
    str1 = strcat('Reading stage movement data file: ',{' '},stageMovementFile,{'.'});
    set(handles.status1,'String',str1{1});
    drawnow;
    load(getRelativePath(stageMovementFile), 'movesI', 'locations');
    origins = locations;
    clear('locations');
end

%read calibration xml file
calibrationFile = fileInfo.expList.xml;
if exist(calibrationFile, 'file') == 2
    [pixel2MicronScale, rotation] = readPixels2Microns(calibrationFile);
else
    error(['Experiment annotation file', calibrationFile, 'not found!']);
end

%read block list
datFileName = fileInfo.expList.segDat;
if exist(datFileName,'file') == 2
    load(datFileName, 'blockList', 'myAviInfo', 'hAndtData');
else
    errorStr = strcat('Segmentation file', {' '}, strrep(datFileName,'\','/'), {' '}, 'not found!');
    error('normWorms:fileNotFound', errorStr{1});
end

varName = 'blockList';
if ~exist(varName, 'var')
    error('normWormProcess:BadVariable', ...
        ['Cannot load ''' varName ''' from ''' datFileName '''']);
end

varName = 'myAviInfo';
if ~exist(varName, 'var')
    error('normWormProcess:BadVariable', ...
        ['Cannot load ''' varName ''' from ''' datFileName '''']);
end

varName = 'hAndtData';
if ~exist(varName, 'var')
    error('normWormProcess:BadVariable', ...
        ['Cannot load ''' varName ''' from ''' datFileName '''']);
end

normBlockList = cell(1, length(blockList)); %#ok<USENS>

%here we check if the normalized dir already exists, create if it doesnt
normalizedSegFileDir = fullfile(fileInfo.expList.segDatDir, 'normalized');
if exist(normalizedSegFileDir, 'dir') == 7
    rmdir(normalizedSegFileDir, 's');
end
mkdir(getRelativePath(normalizedSegFileDir));

%initialize the values
SAMPLES = 49;
%totalFrames = myAviInfo.numFrames + myAviInfo.nHiddenFinalFrames;

%do the values
for i=1:length(blockList)
    %initialize normBlock
    if ~isempty(SAMPLES)
        normBlock = cell(12,1);
    end
    %load block
    blockNameStr = blockList{i};
    [dirPart, ~] =fileparts(datFileName);
    %datFileNameBlock = strrep(datFileName, 'segInfo', blockNameStr);
    datFileNameBlock = fullfile(dirPart, [blockNameStr,'.mat']);
    load(getRelativePath(datFileNameBlock), blockNameStr);
    eval(['currentBlock = ', blockNameStr,';']);
    execString = strcat('clear(''',blockNameStr,''');');
    eval(execString);
    
    %create normBlock storage site
    normBlockNameStr = ['normBlock',sprintf('%d', i)];
    normBlockList{i} = normBlockNameStr;
    %datFileNameNormalizedBlock = fullfile(fileInfo.expList.segDatDir, 'normalized', [fileInfo.expList.fileName, '_', normBlockNameStr,'.mat']);
    datFileNameNormalizedBlock = fullfile(fileInfo.expList.segDatDir, 'normalized', [normBlockNameStr,'.mat']);
    
    %output progress
    str1 = strcat('Normalizing block number:', {' '}, sprintf('%d', i), {' '}, 'out of', {' '}, sprintf('%d', length(blockList)), '.');
    set(handles.status1,'String',str1{1});
    drawnow;
    
    % Normalize the worms.
    [vulvaContours, nonVulvaContours, skeletons, angles, inOutTouches, ...
        lengths, widths, headAreas, tailAreas, vulvaAreas, nonVulvaAreas, isNormed] = ...
        normWorms(currentBlock, SAMPLES, movesI, origins, pixel2MicronScale, ...
        rotation, 0);
    
    % Define framesStatus
    framesStatus = '';
    framesStatus(1:length(currentBlock)) = 's';
    %all the empty elements were dropped frames
    framesStatus(cellfun(@isDroppedFrame, currentBlock)) = 'd';
    framesStatus(cellfun(@isStageMovementFrame, currentBlock)) = 'm';
    framesStatus(cellfun(@isSegFailFrame, currentBlock)) = 'f';
    
    %correctFlag = frameStatus == 's';
    %correctFlag(~isNormed) == 's'
    
    normFailedFlag = ~(framesStatus == 'd' | framesStatus == 'm' | framesStatus == 'f') & ~isNormed;
    framesStatus(normFailedFlag) = 'n';
    
    if sum(normFailedFlag) > 0
        1;
    end
    
    % Convert the block.
    normBlock{1} = framesStatus;
    normBlock{2} = vulvaContours;
    normBlock{3} = nonVulvaContours;
    normBlock{4} = skeletons;
    normBlock{5} = angles;
    normBlock{6} = inOutTouches;
    normBlock{7} = lengths;
    normBlock{8} = widths;
    normBlock{9} = headAreas;
    normBlock{10} = tailAreas;
    normBlock{11} = vulvaAreas;
    normBlock{12} = nonVulvaAreas;
    
    %assignment
    execString = strcat(normBlockNameStr,' = normBlock;');
    eval(execString);
    
    %save
    execString = strcat('save('' ', datFileNameNormalizedBlock, ''',''', normBlockNameStr, ''');');
    eval(execString);
    
    %cleanup
    clear('normBlock', 'framesStatus');
    execString = strcat('clear(''',normBlockNameStr,''');');
    eval(execString);
end

%write the overview mat file
%segNormInfoFile = fullfile(fileInfo.expList.segDatDir, 'normalized', [fileInfo.expList.fileName, '_segNormInfo','.mat']);
segNormInfoFile = fullfile(fileInfo.expList.segDatDir, 'normalized', ['segNormInfo','.mat']);

if exist(datFileName,'file') == 2
    load(datFileName, 'blockSize', 'lastBlockSize', 'globalFrameCounter');
else
    errorStr = strcat('Segmentation file', {' '}, strrep(datFileName,'\','/'), {' '}, 'not found!');
    error('normWorms:fileNotFound', errorStr{1});
end

datestamp = datestr(now); %#ok<NASGU>

save(segNormInfoFile, 'normBlockList', 'myAviInfo', 'datestamp', 'SAMPLES', 'hAndtData', 'pixel2MicronScale', 'rotation', 'blockSize', 'lastBlockSize', 'globalFrameCounter');