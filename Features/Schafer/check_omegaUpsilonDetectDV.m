function check_omegaUpsilonDetectDV()
% This function will go through a specified directory and compute
% omega bends using the old algorithm
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

dirPath = 'H:\home\omega_detection_data\N2';
dirContents = dirrec(dirPath,'.avi');

if ~isempty(dirContents)
    % Get experiment files
    %expList = parseExperimentList(dirContents, hObject, eventdata, handles);
    
    fileListTxt = dirContents;
    if isempty(fileListTxt)
        expList=[];
        return;
    end
    
    if iscell(fileListTxt)
        lenExp = length(fileListTxt);
        j=1;
        expList = cell(1,lenExp);
        for i =1:lenExp
            experiment1 = getExperimentInfo(fileListTxt{i});
            if ~isempty(experiment1)
                expList{j}=experiment1;
                j=j+1;
            end
        end
    else
        [lenExp, ~] = size(fileListTxt);
        j=1;
        expList = cell(1,lenExp);
        for i=1:lenExp
            experiment1 = getExperimentInfo(fileListTxt(i,:));
            if ~isempty(experiment1)
                expList{j}=experiment1;
                j=j+1;
            end
        end
    end
    
    expList(cellfun(@isempty,expList)) = [];
end

for ii = 1: length(expList)
    fileInfo.expList = expList{ii};
    % Define norm worm size
    NOOFPOINTS = 49;
    
    % Define location for normalized worms
    datNameIn = strrep(fileInfo.expList.segDat,'segInfo',['normalized\', 'segNormInfo']);
    
    % Check if the file exists, throw an error if it doesn't
    if exist(datNameIn, 'file') ~= 2
        errorMsg = strcat('Experiment normalized segmentation file:', {''}, strrep(datNameIn,'\','/'), {' '}, 'not found!');
        error('featureProcess:fileNotFound', errorMsg{1});
    end
    
    %     if isempty(strfind(datNameIn, 'N2 on food R_2010_10_15__15_00_01__8'))
    %         continue;
    %     end
    
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
    %disp(str1{1});
    
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
    postureXSkeletons = nan(globalFrameCounter, NOOFPOINTS);
    postureYSkeletons = nan(globalFrameCounter, NOOFPOINTS);
    
    tailToHeadDirection = nan(1,globalFrameCounter);
    headDirection = nan(1,globalFrameCounter);
    tailDirection = nan(1,globalFrameCounter);
    
    load(datNameIn, 'blockSize');
    
    frameLabels = [];
    
    for i=1:length(normBlockList)
        blockNo = i;
        blockNameStr = strcat('normBlock', num2str(blockNo));
        datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
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
                headCentroid = mean(skCoords(1:round(1/6*NOOFPOINTS),:));
                tailCentroid = mean(skCoords(round(5/6*NOOFPOINTS)+1:NOOFPOINTS,:));
                
                % Compute tail direction
                tailToHeadDirectionFrame = atan2(headCentroid(1, 2) - tailCentroid(1,2), headCentroid(1,1) - tailCentroid(1,1));
                tailToHeadDirection(frame) = tailToHeadDirectionFrame * 180/pi;
                % Compute head and tail direction
                headEnd = 1:round(1/18*NOOFPOINTS);
                headBegin = round(1/6*NOOFPOINTS)+1 - headEnd;
                headBegin = fliplr(headBegin);
                headEndCentroid = mean(skCoords(headEnd,:));
                headBeginCentroid = mean(skCoords(headBegin,:));
                % Tail
                tailEnd= round(17/18*NOOFPOINTS) + 1:NOOFPOINTS;
                tailBegin = round(5/6*NOOFPOINTS) + 1:round(16/18*NOOFPOINTS);
                tailEndCentroid = mean(skCoords(tailEnd,:));
                tailBeginCentroid = mean(skCoords(tailBegin,:));
                % Direction for head
                headDirectionFrame = atan2(headEndCentroid(2) - headBeginCentroid(2), headEndCentroid(1) - headBeginCentroid(1));
                headDirection(frame) = headDirectionFrame * 180/pi;
                % Direction for tail
                tailDirectionFrame = atan2(tailEndCentroid(2) - tailBeginCentroid(2), tailEndCentroid(1) - tailBeginCentroid(1));
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
    featureData.headDirection = headDirection;
    featureData.tailDirection = tailDirection;
    
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
        featureData.area = [featureData.area, wormAreaBlock];
        featureData.wormLength = [featureData.wormLength, wormLenBlock];
        featureData.width = [featureData.width, wormWidthBlock];
        featureData.thickness = [featureData.thickness, wormThicknessBlock];
        featureData.fatness = [featureData.fatness, wormFatnessBlock];
        
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
        
        featureData.widthsAtTips = [featureData.widthsAtTips, widthsArrayBlock];
        featureData.eccentricity = [featureData.eccentricity, eccentricityArrayBlock];
        featureData.trackLength = [featureData.trackLength, trackLengthBlock];
        featureData.amplitudeRatio = [featureData.amplitudeRatio, amplitudeRatioBlock];
        featureData.meanBendAngles = [featureData.meanBendAngles, meanOfBendAnglesBlock];
        featureData.stdBendAngles = [featureData.stdBendAngles, stdOfBendAnglesBlock];
        featureData.amplitudeCronin = [featureData.amplitudeCronin, croninAmplitudeBlock];
        featureData.wavelength1 = [featureData.wavelength1, croninWavelength1Block];
        featureData.wavelength2 = [featureData.wavelength2, croninWavelength2Block];
        featureData.numberOfKinks = [featureData.numberOfKinks, numKinksBlock];
        featureData.skeletonAngles = [featureData.skeletonAngles, skeletonAnglesBlock];
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
            featureData.omegaFrames = [featureData.omegaFrames, omegaFramesBlock];
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
    
    % save data
    featureData.outlineCentroid = outlineCentroid';
    
    featureData.tailToHeadDirection = tailToHeadDirection;
    featureData.headDirection = headDirection;
    featureData.tailDirection = tailDirection;
    
end

