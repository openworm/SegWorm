function fileInfo = featureProcess(hObject, eventdata, handles, fileInfo, analysisTableName, conn)
% FEATUREPROCESS This function is called in the pipeline and will compute
% the features.
%   Input:
%           hObject   - GUI data object
%           eventdata - GUI data object
%           handles   - GUI data object
%           fileInfo  - experiment information variable contains the status
%           of the pipeline and the location of the experiment files
%           analysisTableName - the name of the analysis table that was
%           selected in preferences
%
%   Output:
%           fileInfo - experiment info
%
% Get the GUI parameters
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
mydata = guidata(hObject);

%INPUTS
%-------------------------------------------
%- location of the normalized worms
%- 




% Define norm worm size
NUMBER_OF_POINTS = 49;

% Define location for normalized worms
datNameIn = strrep(fileInfo.expList.segDat,'segInfo',['normalized\', 'segNormInfo']);


% Check if the file exists, throw an error if it doesn't
if exist(datNameIn, 'file') ~= 2
    errorMsg = strcat('Experiment normalized segmentation file:', {''}, strrep(datNameIn,'\','/'), {' '}, 'not found!');
    error('featureProcess:fileNotFound', errorMsg{1});
end

%% Define experiment annotation
%--------------------------------------------------------
%
% Formulate the feature file save data

% The WT2 information.
trackerVersion    = '2.0.4';
hardwareVersion   = '2.0';
analysisVersion   = '2.0';
systemAnnotations = [];
wt2 = struct( ...
    'tracker',      trackerVersion, ...
    'hardware',     hardwareVersion, ...
    'analysis',     analysisVersion, ...
    'annotations',  systemAnnotations);
% The video information.

globalFrameCounter = [];
load(datNameIn, 'globalFrameCounter');
if isempty(globalFrameCounter)
    load(fileInfo.expList.segDat, 'globalFrameCounter');
    if isempty(globalFrameCounter)
        error('features:missingVariable', ['Variable globalFrameCounter ',...
            'could not be found in the segmentation info file or the norm ',...
            'info file. Please re-run segmentation for this experiment.'])
    end
end

% Define frame rate
load(datNameIn, 'myAviInfo');
fps = myAviInfo.fps;

videoFrames = globalFrameCounter;
videoTime = globalFrameCounter / fps;

videoLength = struct( ...
    'frames',   videoFrames, ...
    'time',     videoTime);

height = myAviInfo.height;
width  = myAviInfo.width;

pixel2MicronScale = [];
load(datNameIn, 'pixel2MicronScale');

pixelsPerMicrons = pixel2MicronScale;

fourcc = myAviInfo.fourcc;
micronsPerPixels = struct( ...
    'x', pixelsPerMicrons(1,1), ...
    'y', pixelsPerMicrons(1,2));

resolution = struct( ...
    'fps', fps, ...
    'height', height, ...
    'width', width, ...
    'micronsPerPixels', micronsPerPixels, ...
    'fourcc', fourcc);

% The experiment information.
videoFile    = fileInfo.expList.avi;
vignetteFile = fileInfo.expList.vignette;
infoFile     = fileInfo.expList.xml;
stageLogFile = fileInfo.expList.log;
expDirectory = fileInfo.expList.dir;
expComputer  = char(java.net.InetAddress.getLocalHost.toString);
expFiles = struct( ...
    'video',        videoFile, ...
    'vignette',     vignetteFile, ...
    'info',         infoFile, ...
    'stage',        stageLogFile, ...
    'directory',    expDirectory, ...
    'computer',     expComputer);

% Initialize the info
expTimestamp = [];
expGenotype = [];
expGene = [];
expAllele = [];
expStrain = [];
expFood = [];
expVentralSide = [];
expAgarSide = [];
expSex = [];
expAge = [];
expIllumination = [];
expTemperature = [];
expChemicals = [];
expArena = [];
expTracker = [];
expExperimenter = [];
expLab = [];
expAddress = [];
expChromosome = []; 
expWormAnnotations = [];
expEnvironmentAnnotations = [];
expLabAnnotations = [];
expHabitutation = [];


if handles.preferences.useDB
    experimentId = getExperimentId(conn, fileInfo.expList.fileName);
    
    % Lets connect to the database and fill in the annotation values
    sqlString = strcat('select EA.id, strain.strainName,', {' '}, ...
        'gene.geneName, allele.alleleName, C.chromosomeName,', {' '},...
        'I.datestamp, food.foodName, ventralSide.ventralSideName,', {' '},...
        'WS.sideName, TN.trackerName, sex.sexName, age.ageName,', {' '},...
        'experimenters.name, EL.address, genotype.genotypeName,', {' '},...
        'H.habitName', {' '},...
        'from exp_annotation EA',{' '},...
        'left join gene on EA.geneid = gene.geneid',{' '},...
        'left join strain on EA.strainID = strain.strainID', {' '},...
        'left join allele on EA.alleleid = allele.alleleid', {' '},...
        'left join chromosome C on EA.chromosomeID = C.chromosomeID', {' '},...
        'left join food on EA.foodID = food.foodID', {' '},...
        'left join ventralSide on EA.ventralSideID = ventralSide.ventralSideID', {' '},...
        'left join wormSide WS on EA.agarSideID = WS.sideID', {' '},...
        'left join trackerNO TN on EA.trackerID = TN.trackerID', {' '},...
        'left join sex on EA.sexID = sex.sexID', {' '},...
        'left join age on EA.ageID = age.ageID', {' '},...
        'left join experimenters on EA.experimenterID = experimenters.expID', {' '},...
        'left join experimenterLocation EL on EA.locationID = EL.locationID', {' '},...
        'left join genotype on EA.genotypeID = genotype.genotypeID', {' '},...
        'left join info I on EA.id = I.id', {' '},...
        'left join habituation H on EA.habitId = H.habitId', {' '},...
        'where EA.id =', {' '}, num2str(experimentId),';');
    curs = exec(conn, sqlString);
    curs = fetch(curs);
    expInfo = curs.Data;
    close(curs);
    
    if isempty(expInfo)
        warningStr = strcat('MYSQL query failed!', sqlString);
        warning('features:DBconnectForAnnotationFailed', warningStr{1});
    elseif strcmp(expInfo, 'No Data')
        % No info
    else        
        expData.id = expInfo{1,1};
        if strcmpi(expInfo{1,2},'null') || strcmpi(expInfo{1,2},'unknown')
            expData.strainName = [];
        else
            expData.strainName = expInfo{1,2};
        end
        if strcmpi(expInfo{1,3},'null') || strcmpi(expInfo{1,3},'unknown')
            expData.geneName = [];
        else
            expData.geneName = expInfo{1,3};
        end
        if strcmpi(expInfo{1,4},'null') || strcmpi(expInfo{1,4},'unknown')
            expData.alleleName = [];
        else
            expData.alleleName = expInfo{1,4};
        end
        
        if strcmpi(expInfo{1,5},'null') || strcmpi(expInfo{1,5},'unknown')
            expData.chromosomeName = [];
        else
            expData.chromosomeName = expInfo{1,5};
        end
        
        if strcmpi(expInfo{1,6},'null') || strcmpi(expInfo{1,6},'unknown')
            expData.datestamp = [];
        else
            expData.datestamp = expInfo{1,6};
        end
        
        if strcmpi(expInfo{1,7},'null') || strcmpi(expInfo{1,7},'unknown')
            expData.foodName = [];
        else
            expData.foodName = expInfo{1,7};
        end
        
        if strcmpi(expInfo{1,8},'null') || strcmpi(expInfo{1,8},'unknown')
            expData.ventralSide = [];
        else
            expData.ventralSide = expInfo{1,8};
        end
        
        if strcmpi(expInfo{1,9},'null') || strcmpi(expInfo{1,9},'unknown')
            expData.agarSide = [];
        else
            expData.agarSide = expInfo{1,9};
        end
        
        if strcmpi(expInfo{1,10},'null') || strcmpi(expInfo{1,10},'unknown')
            expData.trackerName = [];
        else
            expData.trackerName = expInfo{1,10};
        end
        
        if strcmpi(expInfo{1,11},'null') || strcmpi(expInfo{1,11},'unknown')
            expData.sex = [];
        else
            expData.sex = expInfo{1,11};
        end
        
        if strcmpi(expInfo{1,12},'null') || strcmpi(expInfo{1,12},'unknown')
            expData.age = [];
        else
            expData.age = expInfo{1,12};
        end
        
        
        if strcmpi(expInfo{1,13},'null') || strcmpi(expInfo{1,13},'unknown')
            expData.experimenter = [];
        else
            expData.experimenter = expInfo{1,13};
        end
        
        if strcmpi(expInfo{1,14},'null') || strcmpi(expInfo{1,14},'unknown')
            expData.address = [];
        else
            expData.address = expInfo{1,14};
        end
                
        if strcmpi(expInfo{1,15},'null') || strcmpi(expInfo{1,15},'unknown')
            expData.genotype = [];
        else
            expData.genotype = expInfo{1,15};
        end
        
        if strcmpi(expInfo{1,16},'null') || strcmpi(expInfo{1,16},'unknown')
            expData.habituation = [];
        else
            expData.habituation = expInfo{1,16};
        end
        
        expTimestamp  = expData.datestamp;
        expGene       = expData.geneName;
        expAllele     = expData.alleleName;
        expStrain     = expData.strainName;
        expChromosome = expData.chromosomeName;
        expFood       = expData.foodName;
        expVentralSide = expData.ventralSide;
        expAgarSide   =  expData.agarSide;
        expSex = expData.sex;
        expAge = expData.age;
        expHabitutation = expData.habituation;
        expTracker      = strrep(expData.trackerName,'tracker_','');
        expExperimenter = expData.experimenter;
        expAddress      = expData.address;
        
        expGenotype = expData.genotype;
        
        expIllumination = '627nm';
        expTemperature  = '22C';
        expChemicals    = [];
        expArena        = 'low-peptone NGM plate';
       
        
        expLab = 'William R Schafer';
        expWormAnnotations = [];
        expLabAnnotations = [];
        expEnvironmentAnnotations = [];
    end
else
    % get at least the ventralSide if we are operating offline
    try
        wormNameInfo = parseWormFilename(strcat(fileInfo.expList.fileName, '.avi'));
    catch ME1 %#ok<NASGU>
        wormNameInfo.side = 'unknown';
    end
    
    if strcmpi(wormNameInfo.side, 'L')
        expVentralSide = 'clockwise';
    elseif strcmpi(wormNameInfo.side, 'R')
        expVentralSide = 'anticlockwise';
    else
        expVentralSide = [];
    end
end

% Compute ventralMode
% Set ventralMode as follows -- unknown = 0, anticlockwise = 1, clockwise = 2
ventralMode = 0;
if ~isempty(expVentralSide)
    switch expVentralSide
        case 'anticlockwise'
            ventralMode = 2;
        case 'clockwise'
            ventralMode = 1;
    end
end

expWorm = struct( ...
    'genotype', expGenotype, ...
    'gene', expGene, ...
    'allele', expAllele, ...
    'strain', expStrain, ...
    'chromosome', expChromosome, ...
    'ventralSide', expVentralSide, ...
    'agarSide', expAgarSide, ...
    'sex', expSex, ...
    'age', expAge, ...
    'habituation', expHabitutation, ...
    'annotations', expWormAnnotations);   

expEnvironment = struct( ...
    'timestamp', expTimestamp, ...
    'food', expFood, ...    
    'illumination', expIllumination, ...    
    'temperature', expTemperature, ...
    'chemicals', expChemicals, ...
    'arena', expArena, ...
    'tracker', expTracker, ...
    'annotations', expEnvironmentAnnotations);   

expLab = struct( ...
    'name', expLab, ...
    'experimenter', expExperimenter, ...
    'address', expAddress, ...
    'annotations', expLabAnnotations);

experiment = struct( ...
    'worm', expWorm, ...
    'environment', expEnvironment);
% -----------------------------------------------------
%% Start calculating the features
%
% Load eigen worms data

eigenWorms = [];
load('masterEigenWorms_N2.mat');

% Define the output names
featuresOutName = fullfile(fileInfo.expList.dir, 'results', [fileInfo.expList.fileName,'_features.mat']);

% Initialize features
featureData.movementMode = [];
featureData.noseBendFrequency = [];
featureData.headBendFrequency = [];
featureData.middleBendFrequency = [];
featureData.tailBendFrequency = [];

featureData.width = [];
featureData.wormLength = [];
featureData.area = [];
featureData.thickness = [];
featureData.fatness = [];

featureData.amplitudeCronin = [];
featureData.wavelength1 = [];
featureData.wavelength2 = [];
featureData.meanBendAngles = [];
featureData.stdBendAngles = [];

featureData.eccentricity = [];
featureData.numberOfKinks = [];
featureData.skeletonAngles = [];
featureData.skeletonMeanAngles = [];
featureData.eigenProjectedAmps = [];
featureData.widthsAtTips = [];

featureData.trackLength = [];
featureData.amplitudeRatio = [];

featureData.omegaFrames = [];
featureData.upsilonFrames = [];

featureData.angleArray = [];

% Start computing the features
%--------------------------------------------------------------------------

% Load all norm block names
normBlockList = [];
load(datNameIn, 'normBlockList');

% Show a warning if any wormBlockList entries are empty
if sum(cellfun(@isempty, normBlockList))~=0
    warning('featureProcess:normBlockList', [datNameIn ' has empty ', ...
        ' block list values. Some blocks are corrputed.']);
end

% Printing the info to the GUI
str1 = strcat('Block 1 out of', {' '}, num2str(length(normBlockList)),...
    {' '},'| Extracting features.');
set(handles.status1,'String',str1{1});

% Compute multiScaleWorm for all the blocks in one go
segDatDir = fullfile(fileInfo.expList.dir, '.data',[fileInfo.expList.fileName,'_seg']);

% Define feature window. This window will be used to append to the
% block of interest in case the feature needs data for the border
% values of original block of interest
featureWindow = 250;



%-------------------- Overview motion -------------------------------------
% Compute the centroids for head, tail midbody, outline
frame = 1;
% totalNumberOfFrames

outlineCentroid = nan(globalFrameCounter,2);
postureXSkeletons = nan(globalFrameCounter, NUMBER_OF_POINTS);
postureYSkeletons = nan(globalFrameCounter, NUMBER_OF_POINTS);

tailToHeadDirection = nan(1,globalFrameCounter);
headDirection = nan(1,globalFrameCounter);
tailDirection = nan(1,globalFrameCounter);

load(datNameIn, 'blockSize');

frameLabels = [];

for i=1:length(normBlockList)
    blockNo = i;
    blockNameStr      = strcat('normBlock', num2str(blockNo));
    datFileNameBlock  = strrep(datNameIn, 'segNormInfo', blockNameStr);
    load(datFileNameBlock, blockNameStr);
    data = [];
    eval(strcat('data =', blockNameStr,';'));
    
    frameLabels = [frameLabels, data{1}]; %#ok<AGROW>
    
    % Retrieving the mean coordinates of the skeleton
    for j=1:length(data{1})
        if data{1}(j) == 's'
            skCoords = data{4}(:, :, j);
            
            % Computing outline centorid
            outlineCentroid(frame,:) = mean([data{2}(1:end-1,:,j);data{3}(2:end,:,j)]);
            
            postureXSkeletons(frame, :) = skCoords(:,1);
            postureYSkeletons(frame, :) = skCoords(:,2);
            
            % Head and tail centroids
            headCentroid = mean(skCoords(1:round(1/6*NUMBER_OF_POINTS),:));
            tailCentroid = mean(skCoords(round(5/6*NUMBER_OF_POINTS)+1:NUMBER_OF_POINTS,:));
            
            % Compute tail direction
            tailToHeadDirectionFrame = atan2(headCentroid(1, 2) - tailCentroid(1,2), headCentroid(1,1) - tailCentroid(1,1));
            tailToHeadDirection(frame) = tailToHeadDirectionFrame * 180/pi;
            % Compute head and tail direction
            headEnd           = 1:round(1/18*NUMBER_OF_POINTS);
            headBegin         = round(1/6*NUMBER_OF_POINTS)+1 - headEnd;
            headBegin         = fliplr(headBegin);
            headEndCentroid   = mean(skCoords(headEnd,:));
            headBeginCentroid = mean(skCoords(headBegin,:));
            % Tail
            tailEnd           = round(17/18*NUMBER_OF_POINTS) + 1:NUMBER_OF_POINTS;
            tailBegin         = round(5/6*NUMBER_OF_POINTS) + 1:round(16/18*NUMBER_OF_POINTS);
            tailEndCentroid   = mean(skCoords(tailEnd,:));
            tailBeginCentroid = mean(skCoords(tailBegin,:));
            % Direction for head
            headDirectionFrame   = atan2(headEndCentroid(2) - headBeginCentroid(2), headEndCentroid(1) - headBeginCentroid(1));
            headDirection(frame) = headDirectionFrame * 180/pi;
            % Direction for tail
            tailDirectionFrame   = atan2(tailEndCentroid(2) - tailBeginCentroid(2), tailEndCentroid(1) - tailBeginCentroid(1));
            tailDirection(frame) = tailDirectionFrame * 180/pi;
        end
        frame = frame + 1;
    end
end
% save data
featureData.outlineCentroid = outlineCentroid';

postureXSkeletons = postureXSkeletons';
postureYSkeletons = postureYSkeletons';

featureData.tailToHeadDirection = tailToHeadDirection;
featureData.headDirection       = headDirection;
featureData.tailDirection       = tailDirection;

%--------------------------------------------------------------------------
% Omega Bends and other features
%--------------------------------------------------------------------------

% We will define 3 blocks - front block, mid block and end block.`
for blockNo = 1 : length(normBlockList)
    % Update GUI
    str1 = strcat('Block', {' '}, sprintf('%d',blockNo), {' '},'out of',...
        {' '}, sprintf('%d',length(normBlockList)), {' '},...
        '| Extracting Sternberg, morphology & Schafer features.');
    set(handles.status1,'String',str1{1});
    drawnow;
    
    % Get current block
    blockNameStr = normBlockList{blockNo};
    % Get norm block data
    datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
    load(datFileNameBlock, blockNameStr);
    
    if blockNo == 1
        firstBlock = [];
        eval(strcat('firstBlock =', blockNameStr,';'));
        eval(strcat('clear(''',blockNameStr,''');'));
        mainBlock = firstBlock;
    elseif blockNo == 2
        secondBlock = [];
        eval(strcat('secondBlock =', blockNameStr,';'));
        eval(strcat('clear(''',blockNameStr,''');'));
        mainBlock = secondBlock;
    else
        endBlock = [];
        eval(strcat('endBlock =', blockNameStr,';'));
        eval(strcat('clear(''',blockNameStr,''');'));
        mainBlock = endBlock;
    end
    
    % Morphology feature set
    [wormAreaBlock, wormLenBlock, wormWidthBlock, wormThicknessBlock,...
        wormFatnessBlock] = morphology_process(hObject, eventdata, handles, fileInfo, mainBlock);
    
    featureData.area        = [featureData.area, wormAreaBlock];
    featureData.wormLength  = [featureData.wormLength, wormLenBlock];
    featureData.width       = [featureData.width, wormWidthBlock];
    featureData.thickness   = [featureData.thickness, wormThicknessBlock];
    featureData.fatness     = [featureData.fatness, wormFatnessBlock];
    
    % remove the data
    clear('wormAreaBlock', 'wormLenBlock',...
        'wormWidthBlock', 'wormThicknessBlock',...
        'wormFatnessBlock', 'featureList', 'dataList');
    
    % Schafer lab feature set
    [widthsArrayBlock, eccentricityArrayBlock,...
        trackLengthBlock, amplitudeRatioBlock, ...
        meanOfBendAnglesBlock, stdOfBendAnglesBlock, croninAmplitudeBlock,...
        croninWavelength1Block, croninWavelength2Block, numKinksBlock,...
        skeletonAnglesBlock, skeletonMeanAnglesBlock, projectedAmpsBlock]...
        = schaferFeatures_process(hObject, ...
        eventdata, handles, fileInfo, mainBlock, eigenWorms);
    
    featureData.widthsAtTips       = [featureData.widthsAtTips, widthsArrayBlock];
    featureData.eccentricity       = [featureData.eccentricity, eccentricityArrayBlock];
    featureData.trackLength        = [featureData.trackLength, trackLengthBlock];
    featureData.amplitudeRatio     = [featureData.amplitudeRatio, amplitudeRatioBlock];
    featureData.meanBendAngles     = [featureData.meanBendAngles, meanOfBendAnglesBlock];
    featureData.stdBendAngles      = [featureData.stdBendAngles, stdOfBendAnglesBlock];
    featureData.amplitudeCronin    = [featureData.amplitudeCronin, croninAmplitudeBlock];
    featureData.wavelength1        = [featureData.wavelength1, croninWavelength1Block];
    featureData.wavelength2        = [featureData.wavelength2, croninWavelength2Block];
    featureData.numberOfKinks      = [featureData.numberOfKinks, numKinksBlock];
    featureData.skeletonAngles     = [featureData.skeletonAngles, skeletonAnglesBlock];
    featureData.skeletonMeanAngles = [featureData.skeletonMeanAngles, skeletonMeanAnglesBlock];
    featureData.eigenProjectedAmps = [featureData.eigenProjectedAmps, projectedAmpsBlock];
    
    clear('widthsArrayBlock', 'eccentricityArrayBlock',...
        'trackLengthBlock', 'amplitudeRatioBlock', 'curvatureBlock',...
        'meanOfBendAnglesBlock', 'stdOfBendAnglesBlock', 'croninAmplitudeBlock',...
        'croninWavelength1Block', 'croninWavelength2Block', 'numKinksBlock',...
        'skeletonAnglesBlock', 'skeletonMeanAnglesBlock', 'projectedAmpsBlock','featureList', 'dataList');
    
    % ---------------------------------------------------------------------
    if blockNo == 2
        % Define the dataSize bector, this will tell how many frames should be
        % saved and how many frames were a buffer for windowed calculations
        dataSize = [1,length(firstBlock{1})];
        % If featureWindow is larger than the secondBlock (second block in
        % this case would be the last block of the experiment). We will
        % define a smaller featureWindow
        lenSecondBlock = length(secondBlock{1});
        if featureWindow >= lenSecondBlock
            featureWindowEnd = lenSecondBlock;
        else
            featureWindowEnd = lenSecondBlock-featureWindow;
        end
               
        % Calculate omega bends
        % frame class        
        frameClass = [firstBlock{1}, secondBlock{1}(1:featureWindowEnd)];
        % Get a flag for stage movement
        stageFlag = frameClass == 'm';
        % define angle array
        angleArray = [firstBlock{5},secondBlock{5}(:,1:featureWindowEnd)];
        [omegaFramesBlock, upsilonFramesBlock] = omegaUpsilonDetectCurvature(angleArray, stageFlag);
               
        % crop the region to save
        omegaFramesBlock = omegaFramesBlock(dataSize(1):dataSize(2))';
        upsilonFramesBlock = upsilonFramesBlock(dataSize(1):dataSize(2))';
        
        % save data
        featureData.omegaFrames   = [featureData.omegaFrames, omegaFramesBlock];
        featureData.upsilonFrames = [featureData.upsilonFrames, upsilonFramesBlock];
        
        [numSegments, ~] = size(angleArray);
        bodyAngle = nanmean(angleArray(round(numSegments * (1/3) ) + 1:...
            round(numSegments * (2/3)), :));
        bodyAngleBlock = bodyAngle(dataSize(1):dataSize(2))';
        featureData.angleArray = [featureData.angleArray; bodyAngleBlock];
        
        clear('omegaFramesBlock', 'upsilonFramesBlock');
        % change the names
        frontBlock = firstBlock;
        clear('firstBlock');
        midBlock = secondBlock;
        clear('secondBlock');
        
    elseif blockNo > 2
        % Calculate omega bends
        % Figure out the dataSize limits
        lenFront = length(frontBlock{1});
        lenMid = length(midBlock{1});
        lenEnd = length(endBlock{1});
        if featureWindow >= lenEnd
            featureWindowEnd = lenEnd;
        else
            featureWindowEnd = lenEnd-featureWindow;
        end
        dataSize = [featureWindow+1, lenFront-featureWindow+lenMid];
        
        % Get frame class
        frameClass = [frontBlock{1}(end-featureWindow+1:end), midBlock{1}, endBlock{1}(1:featureWindowEnd)];
        stageFlag = frameClass == 'm';
        
        % define angle array
        angleArray = [frontBlock{5}(:,end-featureWindow+1:end),midBlock{5},endBlock{5}(:,1:featureWindowEnd)];
        [omegaFramesBlock, upsilonFramesBlock] = omegaUpsilonDetectCurvature(angleArray, stageFlag);
        
        % crop the region to save
        omegaFramesBlock = omegaFramesBlock(dataSize(1):dataSize(2))';
        upsilonFramesBlock = upsilonFramesBlock(dataSize(1):dataSize(2))';
        
        % % save data
        featureData.omegaFrames = [featureData.omegaFrames, omegaFramesBlock];
        featureData.upsilonFrames = [featureData.upsilonFrames, upsilonFramesBlock];
        
        [numSegments, ~] = size(angleArray);
        bodyAngle = nanmean(angleArray(round(numSegments * (1/3) ) + 1:...
            round(numSegments * (2/3)), :));
        bodyAngleBlock = bodyAngle(dataSize(1):dataSize(2))';
        featureData.angleArray = [featureData.angleArray; bodyAngleBlock];

        clear('omegaFramesBlock', 'upsilonFramesBlock');
        
        %clean up and shift the blocks
        clear('frontBlock');
        frontBlock = midBlock;
        clear('midBlock');
        midBlock = endBlock;
        clear('endBlock');
    end
end

% Display
str1 = strcat('Block', {' '}, sprintf('%d',blockNo), {' '},'out of', {' '}, sprintf('%d', length(normBlockList)), {' '}, '| Extracting Sternberg, morphology & Schafer features.');
set(handles.status1, 'String', str1{1});


if blockNo == 1
    % This case happens when the experiment has only one block
    lenBlock = length(firstBlock{1});
    % Define the part of mainBlock to be saved in the result file
    dataSize = [1,lenBlock];

    % Get length and frame class
    frameClass = firstBlock{1};
	stageFlag = frameClass == 'm';
    angleArray = firstBlock{5};
    [omegaFramesBlock, upsilonFramesBlock] = omegaUpsilonDetectCurvature(angleArray, stageFlag);
    omegaFramesBlock = omegaFramesBlock(dataSize(1):dataSize(2))';
    upsilonFramesBlock = upsilonFramesBlock(dataSize(1):dataSize(2))';
    
    % save data
    featureData.omegaFrames = [featureData.omegaFrames, omegaFramesBlock];
    featureData.upsilonFrames = [featureData.upsilonFrames, upsilonFramesBlock];
    
    [numSegments, ~] = size(angleArray);
    bodyAngle = nanmean(angleArray(round(numSegments * (1/3) ) + 1:...
        round(numSegments * (2/3)), :));
    bodyAngleBlock = bodyAngle(dataSize(1):dataSize(2))';
    featureData.angleArray = [featureData.angleArray; bodyAngleBlock];
    
    clear('omegaFramesBlock', 'upsilonFramesBlock');
    
    %clean up
    clear('firstBlock');
else
    % Calculate omega bends for the last block if it exists
    lastBlock = midBlock;
    clear('midBlock');
    secondLastBlock = frontBlock;
    clear('frontBlock');
    lenMid = length(secondLastBlock{1});
    lenEnd = length(lastBlock{1});
    
    % Define the part of mainBlock to be saved in the result file
    dataSize = [lenMid-featureWindow+1, featureWindow+lenEnd];
    % Get frame class
    frameClass = [secondLastBlock{1}(lenMid-featureWindow+1:end), lastBlock{1}];
    stageFlag = frameClass == 'm';
  
    % Find omega upsilon bends
    angleArray = [secondLastBlock{5}(:,lenMid-featureWindow+1:end),lastBlock{5}];
    [omegaFramesBlock, upsilonFramesBlock] = omegaUpsilonDetectCurvature(angleArray, stageFlag);
    omegaFramesBlock = omegaFramesBlock(dataSize(1):dataSize(2))';
    upsilonFramesBlock = upsilonFramesBlock(dataSize(1):dataSize(2))';
    
    % save data
    featureData.omegaFrames = [featureData.omegaFrames, omegaFramesBlock];
    featureData.upsilonFrames = [featureData.upsilonFrames, upsilonFramesBlock];
    
    [numSegments, ~] = size(angleArray);
    bodyAngle = nanmean(angleArray(round(numSegments * (1/3) ) + 1:...
        round(numSegments * (2/3)), :));
    bodyAngleBlock = bodyAngle(dataSize(1):dataSize(2))';
    featureData.angleArray = [featureData.angleArray; bodyAngleBlock];
    
    
    clear('omegaFramesBlock', 'upsilonFramesBlock');
    
    %clean up
    clear('mainBlock');
    clear('secondLastBlock');
    clear('lastBlock');
end

% Ommega turns based on direction
%--------------------------------------------------------------------------
% First we will clean up the angle array
% We need to normalize angles accounting for dropped frames 
maxFrames = round(fps/2);
lastAngle = tailToHeadDirection(1);
gapCounter = 0;
wormDataFixed = nan(size(tailToHeadDirection));
for i = 2:length(tailToHeadDirection)
    if ~isnan(tailToHeadDirection(i))
        wormDataFixed(i-1) = tailToHeadDirection(i)-lastAngle;
        gapCounter = 0;
        
        lastAngle = tailToHeadDirection(i);
    else
        gapCounter = gapCounter + 1;
    end
    
    if gapCounter > maxFrames
        lastAngle = NaN;
    end
end

positiveJumps = find(wormDataFixed > 180) + 1;
negativeJumps = find(wormDataFixed < -180) + 1;

% subtract 2pi from remainging data after positive jumps
for j = 1:length(positiveJumps)
    tailToHeadDirection(positiveJumps(j):end) = tailToHeadDirection(positiveJumps(j):end) - 2*180;
end

% add 2pi to remaining data after negative jumps
for j = 1:length(negativeJumps)
    tailToHeadDirection(negativeJumps(j):end) = tailToHeadDirection(negativeJumps(j):end) + 2*180;
end

% get long NaN stretches
n = isnan(tailToHeadDirection);
% save start and end indices for the stretches
[start1, end1] = regexp( char(n+'A'), 'B{120,}', 'start', 'end' );

% interpolate missing data
tailToHeadDirection(isnan(tailToHeadDirection)) = interp1(...
    find(~isnan(tailToHeadDirection)),...
    tailToHeadDirection(~isnan(tailToHeadDirection)),...
    find(isnan(tailToHeadDirection)),'linear');

% return long NaN stretches back to NaN
if ~isempty(start1) && ~isempty(end1)
    for kk=1:size(start1,2)
        tailToHeadDirection(start1(kk):end1(kk)) = NaN;
    end
end
% %debug
% plot(abs(wormData));
% ylim(gca,[0, 360]);
% xlim(gca, [1, length(wormData)]);
1;

% Computer angle difference
windowSize = round(fps/4);
newData = nan(1, length(tailToHeadDirection));
for j=windowSize+1:length(tailToHeadDirection)- windowSize;
    newData(j) = tailToHeadDirection(j+windowSize) - tailToHeadDirection(j-windowSize);
end
tailToHeadDirectionChange = abs(newData/(windowSize*2));

tailToHeadDirectionChangeOmega = tailToHeadDirectionChange>3;

% Interpolate body angle
% get long NaN stretches
bodyAngle = featureData.angleArray;

bodyAngle(isnan(bodyAngle)) = interp1(find(~isnan(bodyAngle)),...
    bodyAngle(~isnan(bodyAngle)), find(isnan(bodyAngle)),'linear', 'extrap');


% Filter out all omega bend flags that are shorter than fps/4 frames (1/4 of a second)
n = tailToHeadDirectionChangeOmega == 1; 
% save start and end indices for the stretches
[start1, end1] = regexp( char(n+'A'), strcat('B{',num2str(round(fps/4)),',}'), 'start', 'end' );
tailToHeadDirectionChangeOmega = zeros(size(tailToHeadDirectionChangeOmega));
% return long NaN stretches back to NaN
if ~isempty(start1) && ~isempty(end1)
    for kk=1:size(start1,2)
        if mean(bodyAngle(start1(kk):end1(kk))) > 0
            tailToHeadDirectionChangeOmega(start1(kk):end1(kk)) = 1;
        else
            tailToHeadDirectionChangeOmega(start1(kk):end1(kk)) = -1;
        end
    end
end

featureData.omegaFrames = featureData.omegaFrames | tailToHeadDirectionChangeOmega;

% Now restore the sign
n = featureData.omegaFrames == 1; 
% save start and end indices for the stretches
[start1, end1] = regexp( char(n+'A'), strcat('B{',num2str(round(fps/4)),',}'), 'start', 'end' );
featureData.omegaFrames = zeros(size(featureData.omegaFrames));
% return long NaN stretches back to NaN
if ~isempty(start1) && ~isempty(end1)
    for kk=1:size(start1,2)
        if mean(bodyAngle(start1(kk):end1(kk))) > 0
            featureData.omegaFrames(start1(kk):end1(kk)) = 1;
        else
            featureData.omegaFrames(start1(kk):end1(kk)) = -1;
        end
    end
end

%% --------------------------------------------------------------------------

%-------------------- Worm Velocity ---------------------------------------

[velocity, motionEvents] = wormVelocity(postureXSkeletons, postureYSkeletons, fps, featureData.wormLength,  ventralMode);

pathCurvature = wormPathCurvature(postureXSkeletons, postureYSkeletons, fps, ventralMode);

% Changes 07/06/2012
% [headTipVelocity, headVelocity, midbodyVelocity, tailVelocity, tailTipVelocity,...
%     pathCurvature] = multiScaleWormProcess(segDatDir, NOOFPOINTS, ventralMode);



%-------------------- Path Statistics -------------------------------------
% Compute the normalized moments
pathX = outlineCentroid(:,1);
pathY = outlineCentroid(:,2);
%calculate centroid
pathCentroidX = nanmean(pathX);
pathCentroidY = nanmean(pathY);
distanceFromCenter = sqrt((pathX - pathCentroidX).^2 + (pathY - pathCentroidY).^2);
% Get the std and skewness of the distances
pathStd = nanstd(distanceFromCenter);
%pathSkewness = nanmean((distance/pathStd).^3);
featureData.pathStd = pathStd;

featureData.pathSkewness = skewness(distanceFromCenter, 0);
featureData.pathKurtosis = kurtosis(distanceFromCenter, 0);

%--------------------------------------------------------------------------
% This section will compute warning frame labels
failedFrames = [];
load(fileInfo.expList.failedFramesFile, 'failedFrames');

% We have three kinds of labels each of them will have a number value
% assigned.
% 1. from 1-10 general labels
% 2. from 11-100 normWorm labels
% 3. from 101-1000 segmentation labels

numFrameLabel = zeros(1, length(frameLabels));

numFrameLabel(frameLabels == 's') = 1;
numFrameLabel(frameLabels == 'm') = 2;
numFrameLabel(frameLabels == 'd') = 3;
numFrameLabel(frameLabels == 'n') = 1001;

% Older version <3 of segmentation had a bug in saving the failed frames.
% They have been indexed starting 0 not 1 (because of frame number being
% generated from time stamp rather than globalFrameCounter). To counter act
% it the indices for the frames that failed need to be added 1 to shift the
% failed frames by one and re-allign them. Here we will make a check for
% that and will raise a flag to add 1 in the upcoming loop
shiftFailedFrames = 0;
if ~isempty(failedFrames) && length(failedFrames(:,1)) > 2
    if sum(frameLabels(failedFrames(2:end,1))~='f') ~= 0
        shiftFailedFrames = 1;
    end
end

for i=1:length(failedFrames(:,1))
    % Here for each failed frame we add a warning id, this warning ID will
    % always strat from a value 101 and end 1000. Everything greater than
    % 100 is a failed frame. If 100 is subtracted then the number
    % corresponds to the array element in handles.warningList
    
    if shiftFailedFrames
        failedFrameIndex = failedFrames(i,1) + 1;
    else
        failedFrameIndex = failedFrames(i,1);
    end
    
    if failedFrameIndex > 0 && failedFrameIndex < length(numFrameLabel)
        numFrameLabel(failedFrameIndex) = failedFrames(i,2) + 100;
    else
        warningStr = strcat('Failed frame index is:', {' '}, num2str(failedFrameIndex), {' '},'and the length of the video is:', {' '}, num2str(numFrameLabel),'.');
        warning('features:failedFrameLabel',warningStr{1});
    end
end

% START DEFINING OUTPUT VALUES
% ----------------------------
headWidths    = featureData.widthsAtTips(1,:);
midbodyWidths = featureData.width;
tailWidths    = featureData.widthsAtTips(2,:);
centroidPathX = featureData.outlineCentroid(1,:);
centroidPathY = featureData.outlineCentroid(2,:);
wormSamples   = NUMBER_OF_POINTS;


%% Worm events computations
%--------------------------------------------------------------------------
%Make videos of the events.
%isEventVideos = false;
% *** Check the values.
wormFile = datNameIn;

speed = velocity.midbody.speed;

frameCodes = numFrameLabel;
omegaFrames = featureData.omegaFrames;
upsilonFrames = featureData.upsilonFrames;

% *** COPY STARTS HERE

% *** Make videos of the events.
%isEventVideos = false;

% % *** Check the values.
% isSanityCheck = true;

% Offset the speed to match the frame count.
% speed = [];
% speed(1) = NaN;
% speed(2:(length(midbodySpeed) + 1)) = midbodySpeed;
%lastFrame = totalFrames - 1;

% Compute the distance. This avoids both segmentation noise and having to
% re-interpolate the distance when frames are missing.
distance = abs(speed / fps);

%% Compute the bends.
locomotionBends = wormBends(wormFile, motionEvents.mode, ventralMode);


%% Compute the coiled shapes.

% Compute the coiled frames.
coilFrames = wormTouchFrames(frameCodes, fps);

% Compute the coiled statistics.
[coilEventStats coiledStats] = events2stats(coilFrames, fps, ...
    distance, [], 'interDistance');

% Reorganize everything for the feature file.
coilFrames = coilEventStats;
coilFrequency = [];
coilTimeRatio = [];
if ~isempty(coiledStats)
    coilFrequency = coiledStats.frequency;
    coilTimeRatio = coiledStats.ratio.time;
end
coils = struct( ...
    'frames', coilFrames, ...
    'frequency', coilFrequency, ...
    'timeRatio', coilTimeRatio);


%% Compute the omega turns.

% Compute the omega frames.
omegaFramesDorsal = findEvent(omegaFrames, 1, [], true);
omegaFramesVentral = findEvent(omegaFrames, [], -1, true);

% Unify the ventral and dorsal turns.
omegaFrames = cat(2, omegaFramesVentral, omegaFramesDorsal);
isOmegaVentral = [true(1, length(omegaFramesVentral)), ...
    false(1, length(omegaFramesDorsal))];
if ~isempty(omegaFramesVentral) && ~isempty(omegaFramesDorsal)
    [~, orderI] = sort([omegaFrames.start]);
    omegaFrames = omegaFrames(orderI);
    isOmegaVentral = isOmegaVentral(orderI);
end

% Compute the omega statistics.
[omegaEventStats, omegaStats] = events2stats(omegaFrames, fps, ...
    distance, [], 'interDistance');

% Add the turns ventral/dorsal side.
omegaFrames = omegaEventStats;
if ~isempty(omegaFrames)
    omegaCells = squeeze(struct2cell(omegaFrames));
    omegaCells{end+1,1} = [];
    for i = 1:size(omegaCells, 2)
        omegaCells{end, i} = isOmegaVentral(i);
    end
    omegaFieldNames = fieldnames(omegaFrames);
    omegaFieldNames{end + 1} = 'isVentral';
    omegaFrames = cell2struct(omegaCells, omegaFieldNames, 1);
end

% Reorganize everything for the feature file.
omegaFrequency = [];
omegaTimeRatio = [];
if ~isempty(omegaStats)
    omegaFrequency = omegaStats.frequency;
    omegaTimeRatio = omegaStats.ratio.time;
end
omegas = struct( ...
    'frames', omegaFrames, ...
    'frequency', omegaFrequency, ...
    'timeRatio', omegaTimeRatio);



%% Compute the upsilon turns.

% Compute the upsilon frames.
upsilonFramesDorsal  = findEvent(upsilonFrames, 1, [], true);
upsilonFramesVentral = findEvent(upsilonFrames, [], -1, true);

% Unify the ventral and dorsal turns.
upsilonFrames = cat(2, upsilonFramesVentral, upsilonFramesDorsal);
isUpsilonVentral = [true(1, length(upsilonFramesVentral)), ...
    false(1, length(upsilonFramesDorsal))];
if ~isempty(upsilonFramesVentral) && ~isempty(upsilonFramesDorsal)
    [~, orderI] = sort([upsilonFrames.start]);
    upsilonFrames = upsilonFrames(orderI);
    isUpsilonVentral = isUpsilonVentral(orderI);
end

% Compute the upsilon statistics.
[upsilonEventStats, upsilonStats] = events2stats(upsilonFrames, fps, ...
    distance, [], 'interDistance');

% Add the turns ventral/dorsal side.
upsilonFrames = upsilonEventStats;
if ~isempty(upsilonFrames)
    upsilonCells = squeeze(struct2cell(upsilonFrames));
    upsilonCells{end+1,1} = [];
    for i = 1:size(upsilonCells, 2)
        upsilonCells{end, i} = isUpsilonVentral(i);
    end
    upsilonFieldNames = fieldnames(upsilonFrames);
    upsilonFieldNames{end + 1} = 'isVentral';
    upsilonFrames = cell2struct(upsilonCells, upsilonFieldNames, 1);
end

% Reorganize everything for the feature file.
upsilonFrequency = [];
upsilonTimeRatio = [];
if ~isempty(upsilonStats)
    upsilonFrequency = upsilonStats.frequency;
    upsilonTimeRatio = upsilonStats.ratio.time;
end
upsilons = struct( ...
    'frames', upsilonFrames, ...
    'frequency', upsilonFrequency, ...
    'timeRatio', upsilonTimeRatio);



%% Compute the path range.
pathRange = wormPathRange(centroidPathX, centroidPathY);

%% Compute the path duration.

% Compute the path scale.
headWidth = nanmean(headWidths);
midWidth  = nanmean(midbodyWidths);
tailWidth = nanmean(tailWidths);
meanWidth = (headWidth + midWidth + tailWidth) / 3;
pathScale = sqrt(2) / meanWidth;

% Compute the worm segments.
headI = 1;
tailI = wormSamples;
wormSegSize = round(tailI / 6);
headIs = headI:(headI + wormSegSize - 1);
midbodyIs = (headI + wormSegSize):(tailI - wormSegSize);
tailIs = (tailI - wormSegSize + 1):tailI;

% Compute the skeleton points.
points = { ...
    headI:tailI, ...
    headIs, ...
    midbodyIs, ...
    tailIs};

% Compute the path duration and organize everything for the feature file.
[arena, durations] = wormPathTime(postureXSkeletons, postureYSkeletons, ...
    points, pathScale, fps);
pathDuration = struct( ...
    'arena', arena, ...
    'worm', durations(1), ...
    'head', durations(2), ...
    'midbody', durations(3), ...
    'tail', durations(4));



%% Here we will organize worm feature data
%--------------------------------------------------------------------------


lengths = featureData.wormLength;
areas = featureData.area;
fatness = featureData.fatness;
thickness = featureData.thickness;
headPosMeanBends = featureData.meanBendAngles(1,:);
headPosStdDevBends = featureData.stdBendAngles(1,:);
neckPosMeanBends = featureData.meanBendAngles(2,:);
neckPosStdDevBends = featureData.stdBendAngles(2,:);
midbodyPosMeanBends = featureData.meanBendAngles(3,:);
midbodyPosStdDevBends = featureData.stdBendAngles(3,:);
hipsPosMeanBends = featureData.meanBendAngles(4,:);
hipsPosStdDevBends = featureData.stdBendAngles(4,:);
tailPosMeanBends = featureData.meanBendAngles(5,:);
tailPosStdDevBends = featureData.stdBendAngles(5,:);

maximumAmpPosture = featureData.amplitudeCronin;
ratioAmpPosture = featureData.amplitudeRatio;
wavelength1 = featureData.wavelength1;
wavelength2 = featureData.wavelength2;

tailToHeadDirection = featureData.tailToHeadDirection;
headPosDirection = featureData.headDirection;
tailPosDirection = featureData.tailDirection;

trackLength = featureData.trackLength;
eccentricity = featureData.eccentricity;
kinks = featureData.numberOfKinks;

% featureData.movementMode - remove use evs motionModes
%motionModes

centroidXCoordinates = featureData.outlineCentroid(1,:);
centroidYCoordinates = featureData.outlineCentroid(2,:);

eigenProjections = featureData.eigenProjectedAmps;

% Sign worm bends
%--------------------------------------------------------------------------
% Sign the head bends.
headBendsSign = headPosMeanBends < 0;
headPosStdDevBends(headBendsSign) = -headPosStdDevBends(headBendsSign); 

% Sign the neck bends.
neckBendsSign = neckPosMeanBends < 0;
neckPosStdDevBends(neckBendsSign) = -neckPosStdDevBends(neckBendsSign); 

% Sign the midbody bends.
midbodyBendsSign = midbodyPosMeanBends < 0;
midbodyPosStdDevBends(midbodyBendsSign) = -midbodyPosStdDevBends(midbodyBendsSign); 

% Sign the hips bends.
hipsBendsSign = hipsPosMeanBends < 0;
hipsPosStdDevBends(hipsBendsSign) = -hipsPosStdDevBends(hipsBendsSign); 

% Sign the tail bends.
tailBendsSign = tailPosMeanBends < 0;
tailPosStdDevBends(tailBendsSign) = -tailPosStdDevBends(tailBendsSign); 


% postureXSkeletons
% postureYSkeletons

%% The worm morphology data.

% The worm widths.
widths = struct( ...
    'head', headWidths, ...
    'midbody', midbodyWidths, ...
    'tail', tailWidths);

%% The worm morphology.
morphology = struct( ...
    'length', lengths, ...
    'width', widths, ....
    'area', areas, ...
    'areaPerLength', fatness, ...
    'widthPerLength', thickness);

%% The worm posture data.

% The worm posture bends.
headPosBends = struct( ...
    'mean', headPosMeanBends, ...
    'stdDev', headPosStdDevBends);
neckPosBends = struct( ...
    'mean', neckPosMeanBends, ...
    'stdDev', neckPosStdDevBends);
midbodyPosBends = struct( ...
    'mean', midbodyPosMeanBends, ...
    'stdDev', midbodyPosStdDevBends);
hipsPosBends = struct( ...
    'mean', hipsPosMeanBends, ...
    'stdDev', hipsPosStdDevBends);
tailPosBends = struct( ...
    'mean', tailPosMeanBends, ...
    'stdDev', tailPosStdDevBends);
postureBends = struct( ...
    'head', headPosBends, ...
    'neck', neckPosBends, ...
    'midbody', midbodyPosBends, ...
    'hips', hipsPosBends, ...
    'tail', tailPosBends);

% The worm amplitudes.
postureAmplitudes = struct( ...
    'max', maximumAmpPosture, ...
    'ratio', ratioAmpPosture);

% The worm wavelengths.
wavelengths = struct( ...
    'primary', wavelength1, ...
    'secondary', wavelength2);

% % The worm coils.
% coilFrames = struct( ...
%     'start', coilStartFrames, ...
%     'end', coilEndFrames, ...
%     'time', coilTimes, ...
%     'interTime', coilInterTimes, ...
%     'interDistance', coilInterDistances);
% coils = struct( ...
%     'frames', coilFrames, ...
%     'frequency', coilFrequency, ...
%     'timeRatio', coilTimeRatio);

% The worm posture directions.
postureDirections = struct( ...
    'tail2head', tailToHeadDirection, ...
    'head', headPosDirection, ...
    'tail', tailPosDirection);

% The worm posture skeletons.
% Note: the orientation is from head to tail in the rows; row 1 is the
% head, the end row is the tail. Each frame is represented by a column.
postureSkeletons = struct( ...
    'x', postureXSkeletons, ...
    'y', postureYSkeletons);

% The worm eigen projections.
% Note: the eigen projections are oriented, by their contribution, in rows;
% row 1 accounts for the most variance. Each frame is represented by a
% column.

%eigenProjections;

%% The worm posture.
posture = struct( ...
    'bends', postureBends, ...
    'amplitude', postureAmplitudes, ...
    'wavelength', wavelengths, ...
    'tracklength', trackLength, ...
    'eccentricity', eccentricity, ...
    'kinks', kinks, ...
    'coils', coils, ...
    'directions', postureDirections, ...
    'skeleton', postureSkeletons, ...
    'eigenProjection', eigenProjections);


%% The worm locomotion data.

% % The worm forward motion.
% forwardFrames = struct( ...
%     'start', forwardStartFrames, ...
%     'end', forwardEndFrames, ...
%     'time', forwardTimes, ...
%     'distance', forwardDistances, ...
%     'interTime', forwardInterTimes, ...
%     'interDistance', forwardInterDistances);
% forwardRatios = struct( ...
%     'time', forwardTimeRatio, ...
%     'distance', forwardDistanceRatio);
% forward = struct( ...
%     'frames', forwardFrames, ...
%     'frequency', forwardFrequency, ...
%     'ratio', forwardRatios);

% % The worm backward motion.
% backwardFrames = struct( ...
%     'start', backwardStartFrames, ...
%     'end', backwardEndFrames, ...
%     'time', backwardTimes, ...
%     'distance', backwardDistances, ...
%     'interTime', backwardInterTimes, ...
%     'interDistance', backwardInterDistances);
% backwardRatios = struct( ...
%     'time', backwardTimeRatio, ...
%     'distance', backwardDistanceRatio);
% backward = struct( ...
%     'frames', backwardFrames, ...
%     'frequency', backwardFrequency, ...
%     'ratio', backwardRatios);
%
% % The worm paused motion.
% pausedFrames = struct( ...
%     'start', pausedStartFrames, ...
%     'end', pausedEndFrames, ...
%     'time', pausedTimes, ...
%     'distance', pausedDistances, ...
%     'interTime', pausedInterTimes, ...
%     'interDistance', pausedInterDistances);
% pausedRatios = struct( ...
%     'time', pausedTimeRatio, ...
%     'distance', pausedDistanceRatio);
% paused = struct( ...
%     'frames', pausedFrames, ...
%     'frequency', pausedFrequency, ...
%     'ratio', pausedRatios);

% % The worm motion.
% motion = struct( ...
%     'mode', motionModes, ...
%     'forward', forward, ...
%     'backward', backward, ...
%     'paused', paused);

% % The worm velocity.
% headTipVelocity = struct( ...
%     'speed', headTipSpeed, ...
%     'direction', headTipVelDirection);
% headVelocity = struct( ...
%     'speed', headSpeed, ...
%     'direction', headVelDirection);
% midbodyVelocity = struct( ...
%     'speed', midbodySpeed, ...
%     'direction', midbodyVelDirection);
% tailVelocity = struct( ...
%     'speed', tailSpeed, ...
%     'direction', tailVelDirection);
% tailTipVelocity = struct( ...
%     'speed', tailTipSpeed, ...
%     'direction', tailTipVelDirection);
% velocity = struct( ...
%     'headTip', headTipVelocity, ...
%     'head', headVelocity, ...
%     'midbody', midbodyVelocity, ...
%     'tail', tailVelocity, ...
%     'tailTip', tailTipVelocity);

% % The worm locomotion bends.
% foragingLocBends = struct( ...
%     'amplitude', foragingAmpBends, ...
%     'frequency', foragingFreqBends);
% headLocBends = struct( ...
%     'amplitude', headAmpBends, ...
%     'frequency', headFreqBends);
% midbodyVelocity = struct( ...
%     'amplitude', midbodyAmpBends, ...
%     'frequency', midbodyFreqBends);
% tailLocBends = struct( ...
%     'amplitude', tailAmpBends, ...
%     'frequency', tailFreqBends);
%
% locomotionBends = struct( ...
%     'foraging', headTipVelocity, ...
%     'head', headLocBends, ...
%     'midbody', midbodyLocBends, ...
%     'tail', tailLocBends);

% % The worm omega turns.
% omegaFrames = struct( ...
%     'start', omegaStartFrames, ...
%     'end', omegaEndFrames, ...
%     'time', omegaTimes, ...
%     'interTime', omegaInterTimes, ...
%     'interDistance', omegaInterDistances, ...
%     'isVentral', isOmegaFramesVentral);
%
% omegas = struct( ...
%     'frames', omegaFrames, ...
%     'frequency', omegaFrequency, ...
%     'timeRatio', omegaTimeRatio);

% % The worm upsilon turns.
% upsilonFrames = struct( ...
%     'start', upsilonStartFrames, ...
%     'end', upsilonEndFrames, ...
%     'time', upsilonTimes, ...
%     'interTime', upsilonInterTimes, ...
%     'interDistance', upsilonInterDistances, ...
%     'isVentral', isUpsilonFramesVentral);
% upsilons = struct( ...
%     'frames', upsilonFrames, ...
%     'frequency', upsilonFrequency, ...
%     'timeRatio', upsilonTimeRatio);

% The worm locomotion turns.
locomotionTurns = struct( ...
    'omegas', omegas, ...
    'upsilons', upsilons);

% The worm locomotion path centroid coordinates.
centroidCoordinates = struct( ...
    'x', centroidXCoordinates, ...
    'y', centroidYCoordinates);

%% The worm locomotion.
locomotion = struct( ...
    'motion', motionEvents, ...
    'velocity', velocity, ...
    'bends', locomotionBends, ...
    'turns', locomotionTurns);

%% The worm path data.

% % The worm path duration.
% pathArenaXYMin = struct( ...
%     'x', pathArenaXMin, ...
%     'y', pathArenaYMin);
% pathArenaXYMax = struct( ...
%     'x', pathArenaXMax, ...
%     'y', pathArenaYMax);
% pathArenaSize = struct( ...
%     'height', pathArenaHeight, ...
%     'width', pathArenaWidth, ...
%     'min', pathArenaXYMin, ...
%     'max', pathArenaXYMax);
% wormDuration = struct( ...
%     'indices', wormDurationIndices, ...
%     'times', wormDurationTimes);
% headDuration = struct( ...
%     'indices', headDurationIndices, ...
%     'times', headDurationTimes);
% midbodyDuration = struct( ...
%     'indices', midbodyDurationIndices, ...
%     'times', midbodyDurationTimes);
% tailDuration = struct( ...
%     'indices', tailDurationIndices, ...
%     'times', tailDurationTimes);
% pathDuration = struct( ...
%     'arena', pathArenaSize, ...
%     'worm', wormDuration, ...
%     'head', headDuration, ...
%     'midbody', midbodyDuration, ...
%     'tail', tailDuration);

%% The worm path.
wormPath = struct( ...
    'range', pathRange, ...
    'duration', pathDuration, ...
    'coordinates', centroidCoordinates, ...
    'curvature', pathCurvature);

%% The worm data.
worm = struct(...
    'morphology', morphology, ...
    'posture', posture, ...
    'locomotion', locomotion, ...
    'path', wormPath);  %#ok



%% Finalize worm annotation

frameAnnotations = numFrameLabel;
annotationReference = wormFrameAnnotation();
videoAnnotations = struct( ...
    'frames',       frameAnnotations, ...
    'reference',    annotationReference);

video = struct( ...
    'length',       videoLength, ...
    'resolution',   resolution, ...
    'annotations',  videoAnnotations);

% The overall information
info = struct( ...
    'wt2',      wt2, ...
    'video',    video, ...
    'experiment', experiment, ...
    'files',    expFiles, ...
    'lab',      expLab); %#ok

%% Save the output

%save eval(featuresOutName) info worm;
save(featuresOutName, 'info', 'worm');
%save(featuresOutName, 'info', 'worm', 'featureData');
%%

if handles.preferences.useDB
    newRootDir = 'results-12-06-28';
    % Define the destination directory depending on the table selected
    if strcmpi(analysisTableName, 'segmentationExperimentList')
        nasDir = ['\\nas207-2\Data\',newRootDir,'\'];
        
    elseif strcmpi(analysisTableName, 'victoriaExperimentList')
        nasDir = '\\nas207-2\Data\victoria-run-13-01-2012\features\';
        
	elseif strcmpi(analysisTableName, 'mariosExperimentList')
        nasDir = '\\nas207-2\Data\other-runs\marios-14-05-2012\';
        
    elseif strcmpi(analysisTableName, 'hobertExperimentList')
        nasDir = '\\nas207-2\Data\hobert-run-04-04-2012\';
        
    else
        nasDir = '\\nas207-2\Data\other-runs\features\';
    end
    
    % Get the path dictated by the annotation
    experimentId = getExperimentId(conn, fileInfo.expList.fileName);
    expPath = makeNasDir(conn, experimentId);
    
    dirTempCopy = fullfile(nasDir, expPath);
    
    % Check if nas dir exists
    if ~isdir(dirTempCopy)
            mkdir(dirTempCopy);
    end
    % Formulate new output file path and copy to NAS
    newOutputName = fullfile(dirTempCopy, [fileInfo.expList.fileName,'_features.mat']);
    copyfile(featuresOutName, newOutputName);
    
    % Compute the histograms
    % featuresOutName = the feature file name (the file must already exist since we'll be using it) 
    histFilename = strrep(featuresOutName, 'features.mat', 'hist.mat');
    % make the histogram filename 
    worm2histogram(histFilename, featuresOutName); 
    %worm2histogram(histFilename, newOutputName); 
    
    % this puts the histogram file in the NAS
    
    newHistOutputName = fullfile(dirTempCopy, [fileInfo.expList.fileName,'_hist.mat']);
    newHistOutputName = strrep(newHistOutputName, ...
        ['\\nas207-2\Data\', newRootDir, '\'], ...
        ['\\nas207-2\Data\', newRootDir, '_hist\']);
    
    % Check if the dir exists
    [dir1, ~, ~] = fileparts(newHistOutputName);
    if ~isdir(dir1)
        mkdir(dir1);
    end
    
    copyfile(histFilename, newHistOutputName);

    % Delete the original to save space
    if exist(featuresOutName, 'file') == 2
	   delete(featuresOutName);
    end    
    
     % Delete the original to save space
    if exist(histFilename, 'file') == 2
        delete(histFilename);
    end
    
    
    %-----------------------------
    %     % Copy normalized folder
    %     dirTempCopy = '\\nas207-1\Data\victoriaExperimentList\';
    %     destinationDir = [dirTempCopy, fileInfo.expList.fileName];
    %     if ~isdir(destinationDir)
    %         mkdir(destinationDir);
    %     end
    %     sourceDir = [fileInfo.expList.segDatDir, filesep, 'normalized'];
    %     [ret, errorMsg] = copyfile(sourceDir, destinationDir);
    
    %     % Copy stage motion file as well
    %     destinationStageMotion = fullfile(dirTempCopy, fileInfo.expList.fileName, [fileInfo.expList.fileName,'_stageMotion']);
    %     [ret, errorMsg] = copyfile(fileInfo.expList.stageMotion, destinationStageMotion);
    %
end
%----------------------------------------------------------------------
% record the status file

fileInfo.features.version = mydata.preferences.version;
fileInfo.features.completed = 1;
fileInfo.features.timeStamp = datestr(now);

save(fileInfo.expList.status, 'fileInfo');

mydata.experimentList{mydata.currentFile} = fileInfo.expList;
guidata(hObject,mydata);