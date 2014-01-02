function omegaBendDetector_old()
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

output = [];
% Here we loop thtough all of the discovered experiments
for ii = 1: length(expList)
    
    fileInfo.expList = expList{ii};
    
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

    % Load normalized block list
    % Load all norm block names
    normBlockList = [];
    load(datNameIn, 'normBlockList');
    % Show a warning if any wormBlockList entries are empty
    if sum(cellfun(@isempty, normBlockList))~=0
        warning('featureProcess:normBlockList', [datNameIn ' has empty ', ...
            ' block list values. Some blocks are corrputed.']);
    end
    % Initialize ----------------------------------------------------------
    omegaFrames = [];
    upsilonFrames = [];
    %----------------------------------------------------------------------
    % Load first block
    blockNameStr = normBlockList{1};
    % Get norm block data
    datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
    % Load norm blocks
    load(datFileNameBlock, blockNameStr);
    
    
    frontBlock = [];
    eval(strcat('frontBlock =', blockNameStr,';'));
    eval(strcat('clear(''',blockNameStr,''');'));

    % Here we loop through all of the norm blocks
    for blockNo = 2 : length(normBlockList)-1
        % Printing the info
        str1 = strcat('Block', {' '}, num2str(blockNo), {' '}, 'out of',...
            {' '}, num2str(length(normBlockList)),...
            {' '},'| Extracting features.');
       % disp(str1{1});

        % Load middle block -----------------------------------------------
        blockNameStr = normBlockList{blockNo};
        % Get norm block data
        datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
        % Load norm blocks
        load(datFileNameBlock, blockNameStr);
        midBlock = [];
        eval(strcat('midBlock =', blockNameStr,';'));
        eval(strcat('clear(''',blockNameStr,''');'));
       
        % Load end block --------------------------------------------------
        % Get current block
        blockNameStr = normBlockList{blockNo+1};
        % Get norm block data
        datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
        % Load norm blocks
        load(datFileNameBlock, blockNameStr);
        endBlock = [];
        eval(strcat('endBlock =', blockNameStr,';'));
        eval(strcat('clear(''',blockNameStr,''');'));
        %------------------------------------------------------------------
        % We need to compute x, y for the skeleton, length for
        % normalization and frame class for omega bend detection
        
        % Getting length
        % wormLen = NaN(1,datLen);
        lenArray = [frontBlock{7}, midBlock{7}, endBlock{7}];
        % Get frame class
        frameClass = [frontBlock{1}, midBlock{1}, endBlock{1}];
        % Get skeleton coordinates
        x = [squeeze(frontBlock{4}(:,1,:)), squeeze(midBlock{4}(:,1,:)), squeeze(endBlock{4}(:,1,:))]';
        y = [squeeze(frontBlock{4}(:,2,:)), squeeze(midBlock{4}(:,2,:)), squeeze(endBlock{4}(:,2,:))]';
        
        % Compute omega bends
        [omegaFramesBlock, upsilonFramesBlock] = omegaUpsilonDetectDV_testing(x, y, lenArray, frameClass);
        
        % crop the region to save
        omegaFramesBlock = omegaFramesBlock(length(frontBlock{1})+1:end-length(endBlock{1}))';
        upsilonFramesBlock = upsilonFramesBlock(length(frontBlock{1})+1:end-length(endBlock{1}))';
        omegaFrames = [omegaFrames; omegaFramesBlock];
        upsilonFrames = [upsilonFrames; upsilonFramesBlock];
            
        clear('omegaFramesBlock', 'upsilonFramesBlock');
        
        % change the names
        frontBlock = midBlock;
    end
   
    % Deal with the first block
    % -------------------------
    % Load first block 
    blockNameStr = normBlockList{1};
    % Get norm block data
    datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
    % Load norm blocks
    load(datFileNameBlock, blockNameStr);
    frontBlock = [];
    eval(strcat('frontBlock =', blockNameStr,';'));
    eval(strcat('clear(''',blockNameStr,''');'));
    
    % Load second block 
    blockNameStr = normBlockList{2};
    % Get norm block data
    datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
    % Load norm blocks
    load(datFileNameBlock, blockNameStr);
    secondBlock = [];
    eval(strcat('secondBlock =', blockNameStr,';'));
    eval(strcat('clear(''',blockNameStr,''');'));
    % Getting length
    % wormLen = NaN(1,datLen);
    lenArray = [frontBlock{7}, secondBlock{7}];
    % Get frame class
    frameClass = [frontBlock{1}, secondBlock{1}];
    % Get skeleton coordinates
    x = [squeeze(frontBlock{4}(:,1,:)), squeeze(secondBlock{4}(:,1,:))]';
    y = [squeeze(frontBlock{4}(:,2,:)), squeeze(secondBlock{4}(:,2,:))]';

    % Compute omega bends
    [omegaFramesBlock, upsilonFramesBlock] = omegaUpsilonDetectDV_testing(x, y, lenArray, frameClass);
    
    % crop the region to save
    omegaFramesBlock = omegaFramesBlock(1:end-length(secondBlock{1}))';
    upsilonFramesBlock = upsilonFramesBlock(1:end-length(secondBlock{1}))';
    omegaFrames = [omegaFramesBlock; omegaFrames];
    upsilonFrames = [upsilonFramesBlock; upsilonFrames];
    % -------------------------
  
    % Deal with the last block
    % -------------------------
        % Load first block 
    blockNameStr = normBlockList{end-1};
    % Get norm block data
    datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
    % Load norm blocks
    load(datFileNameBlock, blockNameStr);
    beforeLastBlock = [];
    eval(strcat('beforeLastBlock =', blockNameStr,';'));
    eval(strcat('clear(''',blockNameStr,''');'));
    
    % Load last block 
    blockNameStr = normBlockList{2};
    % Get norm block data
    datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
    % Load norm blocks
    load(datFileNameBlock, blockNameStr);
    lastBlock = [];
    eval(strcat('lastBlock =', blockNameStr,';'));
    eval(strcat('clear(''',blockNameStr,''');'));
    % Getting length
    lenArray = [beforeLastBlock{7}, lastBlock{7}];
    % Get frame class
    frameClass = [beforeLastBlock{1}, lastBlock{1}];
    % Get skeleton coordinates
    x = [squeeze(beforeLastBlock{4}(:,1,:)), squeeze(lastBlock{4}(:,1,:))]';
    y = [squeeze(beforeLastBlock{4}(:,2,:)), squeeze(lastBlock{4}(:,2,:))]';

    % Compute omega bends
    [omegaFramesBlock, upsilonFramesBlock] = omegaUpsilonDetectDV_testing(x, y, lenArray, frameClass);
    
    % crop the region to save
    omegaFramesBlock = omegaFramesBlock(length(lastBlock{1})+1:end)';
    upsilonFramesBlock = upsilonFramesBlock(length(lastBlock{1})+1:end)';
    omegaFrames = [omegaFrames; omegaFramesBlock];
    upsilonFrames = [upsilonFrames; upsilonFramesBlock];
    % -------------------------
    n = omegaFrames ~= 0;
    [start1, end1] = regexp(char(n'+'A'), strcat('B{1,}'), 'start', 'end' );
    output{ii}.name = fileInfo.expList.avi;
    output{ii}.fps = fps;
    output{ii}.start = start1;
    output{ii}.end = end1;
    output{ii}.data = omegaFrames;
    fileInfo.expList.avi
    [start1;end1]
    
end
output_tmp = output;
save('n2_data_old.mat', 'output_tmp');
