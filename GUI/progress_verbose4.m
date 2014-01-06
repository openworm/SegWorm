function varargout = progress_verbose4(varargin)
% PROGRESS_VERBOSE4 MATLAB code for progress_verbose4.fig
%      PROGRESS_VERBOSE4, by itself, creates a new PROGRESS_VERBOSE4 or raises the existing
%      singleton*.
%
%      H = PROGRESS_VERBOSE4 returns the handle to a new PROGRESS_VERBOSE4 or the handle to
%      the existing singleton*.
%
%      PROGRESS_VERBOSE4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRESS_VERBOSE4.M with the given input arguments.
%
%      PROGRESS_VERBOSE4('Property','Value',...) creates a new PROGRESS_VERBOSE4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before progress_verbose4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to progress_verbose4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help progress_verbose4

% Last Modified by GUIDE v2.5 11-Aug-2011 18:28:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @progress_verbose4_OpeningFcn, ...
                   'gui_OutputFcn',  @progress_verbose4_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%
% Axes create functions should have these
%set(gca,'YTick',[]);
%set(gca,'XTick',[]);
%
%


% --- Executes just before progress_verbose4 is made visible.
function progress_verbose4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to progress_verbose4 (see VARARGIN)

% Choose default command line output for progress_verbose
handles.output = hObject;

%--------------------------------------------------------------------------
% Preferences - here we retrieve them from the input of this GUI
%--------------------------------------------------------------------------
handles.preferences = varargin{1};

% Update handles structure
guidata(hObject, handles);
%here we specify that when the GUI is closed this function must be called
set(handles.progress1,'CloseRequestFcn',@closeGUI);

%--------------------------------------------------------------------------
% Batch - here we will check if we have a batch call
%--------------------------------------------------------------------------
% if yes - call startAnalysis_Callback automatically
if handles.preferences.batch
    %load fileListFinal from a file that is passed with a batch call
    load(handles.preferences.batchPath);
    set(handles.fileList,'String', fileListFinal);
    
    startAnalysis_Callback(hObject, eventdata, handles)
end

% UIWAIT makes progress_verbose4 wait for user response (see UIRESUME)
% uiwait(handles.progress1);


% --- Outputs from this function are returned to the command line.
function varargout = progress_verbose4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%--MAIN BUTTON ------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Executes on button press in startAnalysis.
function startAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to startAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------
% Here we start the main analysis function
%
% A rough outline of the function is:
% - get input
%   check if empty, if yes - request an input dir
% - for length of input
%   *
%
%
%
%

%--------------------------------------------------------------------------
% Initialize
%--------------------------------------------------------------------------
set(handles.exitFlag,'String',num2str(0));

% here we define the number of steps to plot the progress bar:
pLen = 3;

axes(handles.mainImg);  %#ok<*MAXES>
imshow('axis1.png');

%--------------------------------------------------------------------------
% Get files to analyze
%--------------------------------------------------------------------------
% get file list
fileListTxt = get(handles.fileList,'String');
if ~isempty(fileListTxt)
    %parse the list and return all of the experiment data
    expList = parseExperimentList(fileListTxt, hObject, eventdata, handles);
    %get only the avi files
    fileListFinal = {expList{:}.avi};
else
    str1 = strcat('No valid directories found!');
    set(handles.status1,'String',str1);
    %get experiments manualy
    dirPath = uigetdir('*.*','Enter worm video directory.');
    if ~dirPath
        return;
    end
    %get all avi files in dir
    dirContents = dirrec(dirPath,'.avi');
    
    if ~isempty(dirContents)
        %get experiment files
        expList = parseExperimentList(dirContents, hObject, eventdata, handles);
        expListStruct = [expList{:}];
        fileListFinal = {expListStruct.avi};
    else
        return;
    end
end

% display
set(handles.fileList,'String',fileListFinal);
str1 = strcat('File search completed!');
set(handles.status1,'String',str1);

%--------------------------------------------------------------------------
%   prepare dir for analysis
%--------------------------------------------------------------------------

createAnalysisDir(hObject, eventdata, handles);

mydata = guidata(hObject);
lenExp = length(mydata.experimentList);

finishedFileCounter = 0;

%--------------------------------------------------------------------------
%   prepare database connection
%--------------------------------------------------------------------------

conn = 'no connection';
if handles.preferences.nas
    error('database details missing')
    conn = database;
end
mydata.conn = conn;

%generate warning log file

%--------------------------------------------------------------------------
% Main loop through specified experiments
%--------------------------------------------------------------------------
for i=1:lenExp
    %debug
    %root dir
    dirAvi = mydata.experimentList{i}.dir;
    cd(dirAvi);
    set(handles.videoName,'String', mydata.experimentList{i}.avi);
    
    %generating log files
    %------------------------------------------------------------------
    %open an error dump file
    errorLogFile = fullfile(dirAvi, '.data',[mydata.experimentList{i}.fileName,'_process','.txt']);
    processFid = fopen(errorLogFile, 'wt');
    fprintf(processFid,'%s\n',strcat('Starting error dump file :', datestr(now)));
    
    diaryFilePath = fullfile(dirAvi, '.data', strcat(mydata.experimentList{i}.fileName, '_warnings', '.txt'));
    handles.diaryFileName = diaryFilePath;
    if exist(diaryFilePath,'file') == 2
        delete(diaryFilePath);
    end
    diary(diaryFilePath);
    
    diaryFilePathForStageMotion = fullfile(dirAvi, '.data', strcat(mydata.experimentList{i}.fileName, '_warningsStageMotion', '.txt'));
    handles.diaryFileNameForStageMotion = diaryFilePathForStageMotion;
    if exist(diaryFilePathForStageMotion,'file') == 2
        delete(diaryFilePathForStageMotion);
    end
    
    diaryFilePathForSegmentation = fullfile(dirAvi, '.data', strcat(mydata.experimentList{i}.fileName, '_warningsSegmentation', '.txt'));
    handles.diaryFileName = diaryFilePathForSegmentation;
    if exist(diaryFilePathForSegmentation,'file') == 2
        delete(diaryFilePathForSegmentation);
    end
    
    %------------------------------------------------------------------
    
    mydata.dirAvi = dirAvi;
    mydata.currentFile = i;
    set(handles.vidDir,'String', dirAvi);
    if i>1
        set(handles.fileList,'String', fileListFinal(i:end));
    end
    
    lenAvi = lenExp;
    mydata.lenAvi = lenAvi;
    
    set(handles.idMax,'String', num2str(lenAvi));
    set(handles.idMin,'String', num2str(i));
    
    set(handles.status1,'String','Video successfully loaded.');
    
    %----------------------------------------------------------------------
    % Check to clean up the directory
    %----------------------------------------------------------------------
    str1 = strcat('Progress bar: 0 out of', {' '}, num2str(pLen), {' '},'| Cleaning the directory');
    set(handles.status2,'String',str1{1});
    
    try
        cleanUpDir(hObject, eventdata, handles)
    catch ME1
        str1 = strcat('Error in:',dirAvi, {', '}, ME1.message);
        set(handles.status1,'String', str1{1});
        %write exception
        msgString = getReport(ME1, 'extended','hyperlinks','off');
        msgString = strcat('Dir:',{' '}, dirAvi,{' '},msgString);
        fprintf(processFid,'%s\n',msgString{1});
        msgbox(msgString); 
    end
    
    %----------------------------------------------------------------------
    % Can the file be parsed?
    %----------------------------------------------------------------------
    try
        %lets check if the file can be parsed
        [~] = parseWormFilename(strcat(mydata.experimentList{i}.fileName,'.avi'));
    catch ME1
        msgString = getReport(ME1, 'extended','hyperlinks','off');
        str1 = strcat('The file name couild not be parsed for file:',{' '}, mydata.experimentList{i}.fileName, {' '}, {' '},msgString);
        set(handles.status1,'String',str1{1});
        %write errorDrump
        fprintf(processFid,'%s\n',mydata.experimentList{i}.fileName);
        fprintf(processFid,'%s\n',msgString);
        msgbox(msgString);
        continue;
    end
    
    %----------------------------------------------------------------------
    % Status check
    %----------------------------------------------------------------------
    %here we look for file status log - if it doesnt exist - we create a
    %new one
    
    if isempty(mydata.experimentList{i}.status)
        mydata.experimentList{i}.status = fullfile(mydata.experimentList{i}.dir,'.data',strcat(mydata.experimentList{i}.fileName,'_status.mat'));
        mydata.experimentList = mydata.experimentList;
        fileInfo = initializeFileInfo(mydata, mydata.experimentList{i});
        save(mydata.experimentList{i}.status, 'fileInfo');
    else
        load(mydata.experimentList{i}.status);
    end
    
    %update GUI data
    guidata(hObject, mydata);
    
    %----------------------------------------------------------------------
    % Stage motion detection
    %----------------------------------------------------------------------
    str1 = strcat('Progress bar: 1 out of', {' '}, num2str(pLen), {' '},'| Stage movement detection');
    set(handles.status2,'String',str1{1});
    axes(handles.progressBar1);  %#ok<*LAXES>
    progressBarDat = (0:round((1/pLen)*100));
    color1=[0,1/255,102/255];
    fill([progressBarDat,progressBarDat(end),0],[ones(1,length(progressBarDat)),0,0],color1, 'FaceAlpha',0.95);
    xlim(handles.progressBar1,[1,100]);
    set(gca,'YTick',[]);
    set(gca,'XTick',[]);
    
    %enable new buttons
    set(handles.showButton, 'enable', 'off');
    set(handles.show1, 'enable', 'off');
    set(handles.vignette1, 'enable', 'off');
    set(handles.pauseButton, 'enable', 'off');
    set(handles.uipanel4, 'Title', 'Stage movement:');
    
    set(handles.exitFlag,'String',num2str(0));
    %close general diary
    diary off;
    %check if stage motion for this file is completed
    if handles.preferences.stageMovAndSeg || fileInfo.stageMovement.completed==0
        %----------------------------------------------------------------------
        diary(diaryFilePathForStageMotion);

        try
            tic;
            %Run stage motion detection
            findStageMovementProcess(hObject, eventdata, handles);
            set(handles.status1,'String', 'Stage motion detection successfully finished!');
            timer1 = toc;
            fprintf(processFid,'%s\n',['Stage motion detection:',mydata.experimentList{mydata.currentFile}.fileName]);
            fprintf(processFid,'%s\n',['Time elapsed: ',num2str(timer1/60),'s']);
        catch ME1
            msgString = getReport(ME1, 'extended','hyperlinks','off');
            str1 = strcat('Stage motion detection for file',{' '},mydata.experimentList{mydata.currentFile}.fileName,{' '},'failed!',{' '},msgString);
            set(handles.status1,'String',str1{1});
            %write errorDrump
            fprintf(processFid,'%s\n',mydata.experimentList{mydata.currentFile}.fileName);
            fprintf(processFid,'%s\n',msgString);
            msgbox(msgString);
            continue;
        end
        %close stage motion diary
        diary off;
        copyToNAS(diaryFilePathForStageMotion, fileInfo, handles.preferences.version, conn);
    else
        set(handles.status1,'String','Stage motion detection completed previously!');
    end
    
    %check GUI exit
    ret1 = str2double(get(handles.exitFlag,'String'));
    if ret1
        return;
    end
    
    %----------------------------------------------------------------------
    % Segmentation
    %----------------------------------------------------------------------
    str1 = strcat('Progress bar: 2 out of', {' '}, num2str(pLen), {' '},'| Video segmentation');
    set(handles.status2,'String',str1{1});
    axes(handles.progressBar1);
    progressBarDat = (0:round((2/pLen)*100));
    color1=[0,51/255,102/255];
    fill([progressBarDat,progressBarDat(end),0],[ones(1,length(progressBarDat)),0,0],color1, 'FaceAlpha',0.95);
    xlim(handles.progressBar1,[1,100]);
    set(gca,'YTick',[]);
    set(gca,'XTick',[]);
    
    set(handles.showButton, 'enable', 'on');
    set(handles.show1, 'enable', 'on');
    set(handles.vignette1, 'enable', 'on');
    set(handles.pauseButton, 'enable', 'on');
    set(handles.uipanel4, 'Title', 'Width profile:');
    
    set(handles.exitFlag,'String',num2str(0));
    
    if handles.preferences.stageMovAndSeg || fileInfo.segmentation.completed==0
        %----------------------------------------------------------------------
        %start diary for segmentation
        diary(diaryFilePathForSegmentation);
        tic;
        try
            %module2Segmentation(hObject, eventdata, handles);
            segmentationMain(hObject, eventdata, handles);
            str1 = strcat('Segmentation for file', {' '}, mydata.experimentList{i}.avi, {' '},'finished.');
            set(handles.status1,'String',str1{1});
        catch ME1
            msgString = getReport(ME1, 'extended','hyperlinks','off');
            str1 = strcat('Segmentation for file',{' '},mydata.experimentList{mydata.currentFile}.fileName,{' '},'failed!',{' '},msgString);
            set(handles.status1,'String',str1{1});
            %write errorDrump
            fprintf(processFid,'%s\n',mydata.experimentList{mydata.currentFile}.fileName);
            fprintf(processFid,'%s\n',msgString);
            msgbox(msgString);
            continue;
        end
        timer1 = toc;
        fprintf(processFid,'%s\n',['Segmenting: ',mydata.experimentList{mydata.currentFile}.fileName]);
        fprintf(processFid,'%s\n',['Time elapsed: ',num2str(timer1)]);
        diary off;
        copyToNAS(diaryFilePathForSegmentation, fileInfo, handles.preferences.version, conn);
    end
    
    %----------------------------------------------------------------------
    %start main diary again
    diary(diaryFilePath);
    
    
    %         flag2 = str2double(get(handles.exitFlag,'String'));
    %         if flag2
    %             str1 = strcat('Analysis terminated by the user at:',{' '},datestr(now));
    %             set(handles.status1,'String',str1{1});
    %             return;
    %         end
    
    %--------------------------------------------------------------------------
    % Feature extraction
    %--------------------------------------------------------------------------
    
    %debug
   
    str1 = strcat('Progress bar: 3 out of', {' '}, num2str(pLen), {' '},'| Extracting features.');
    set(handles.status2,'String',str1{1});
    axes(handles.progressBar1);
    progressBarDat = (0:round((3/pLen)*100));
    color1=[0,51/255,102/255];
    fill([progressBarDat,progressBarDat(end),0],[ones(1,length(progressBarDat)),0,0],color1, 'FaceAlpha',0.95);
    xlim(handles.progressBar1,[1,100]);
    set(gca,'YTick',[]);
    set(gca,'XTick',[]);
    
    load(mydata.experimentList{mydata.currentFile}.status);
    
    if handles.preferences.featureSet
        
        mydata = guidata(hObject);
        datNameIn = mydata.experimentList{mydata.currentFile}.segDat;
        %debug
        %datNameIn = 'C:\Documents and Settings\Tadas Jucikas\My Documents\MATLAB\.data\ocr-3 (a1537) on food L_2010_04_23__12_18_35___1___8_seg.mat'
        load(datNameIn,'myAviInfo');
        
        expInfo = mydata.experimentList{mydata.currentFile};
        
        metricsOutName = fullfile(expInfo.dir,'results', strcat(expInfo.fileName,'_sternberg.mat'));
        morphOutName = fullfile(expInfo.dir,'results', strcat(expInfo.fileName,'_morphology.mat'));
        schaferOutName = fullfile(expInfo.dir,'results',strcat(expInfo.fileName,'_schafer.mat'));
        omegaOutName = fullfile(expInfo.dir,'results',strcat(expInfo.fileName,'_omegaTurns.mat'));
        
        %here we add to the experimentInfo struct
        %to add more one must also change initial definition in getExperimentInfo
        if ~fileInfo.sternberg.completed
            expInfo.results.sternberg = metricsOutName;
            fileInfo.expList.results.sternberg = metricsOutName;
        end
        if ~fileInfo.morphology.completed
            expInfo.results.morphology = morphOutName;
            fileInfo.expList.results.morphology = morphOutName;
        end
        if ~fileInfo.schafer.completed
            expInfo.results.schafer = schaferOutName;
            fileInfo.expList.results.schafer = schaferOutName;
        end
        if ~fileInfo.omegaTurns.completed
            expInfo.results.omegaTurns = omegaOutName;
            fileInfo.expList.results.omegaTurns = schaferOutName;
        end
        
        mydata.experimentList{mydata.currentFile} = expInfo;
        guidata(hObject,mydata);
        
        %initialize output files
        blockList = [];
        timeStamp = datestr(now); %#ok<NASGU>
        if ~fileInfo.sternberg.completed
            save(metricsOutName,'myAviInfo','blockList', 'expInfo','timeStamp');
        end
        if ~fileInfo.morphology.completed
            save(morphOutName,'myAviInfo','blockList', 'expInfo','timeStamp');
        end
        if ~fileInfo.schafer.completed
            save(schaferOutName,'myAviInfo','blockList', 'expInfo','timeStamp');
        end
        if ~fileInfo.omegaTurns.completed
            save(omegaOutName,'myAviInfo','blockList', 'expInfo','timeStamp');
        end
        
        %extract path moments feature
        if ~fileInfo.schafer.pathMomentsCompleted
            pathMomentsArray = pathMoments(expInfo.log, 3); %#ok<NASGU>
            save(schaferOutName, '-append', 'pathMomentsArray');
        end
        %--------------------------------------------------------------------------
        %if one of the feature sets is not completed
        if ~fileInfo.sternberg.completed || ~fileInfo.morphology.completed || ~fileInfo.schafer.completed || ~fileInfo.omegaTurns.completed
            %here we load all the block names
            load(datNameIn, 'blockList');
            blockList = blockList(~cellfun(@isempty, blockList));
            
            %here we load block1
            blockName = blockList{1};
            blockNameCurrent = blockName;
            load(datNameIn, blockName);
            eval(strcat('frontBlock =', blockName,';'));
            eval(strcat('clear(''',blockName,''');'));
            
            str1 = strcat('Block 1 out of', {' '}, num2str(length(blockList)), {' '},'| Extracting morphology & Schafer features.');
            set(handles.status1,'String',str1{1});
            % convert to array of structs
            frontBlock = cellBlock2wormBlock(frontBlock);
            
            if ~fileInfo.morphology.completed
                %morphology feature set for block1
                morphology_process(hObject, eventdata, handles, frontBlock, blockName);
            end
            if ~fileInfo.schafer.completed
                %schafer feature set for block1
                baekEtAl_process(hObject, eventdata, handles, frontBlock, blockName, myAviInfo, processFid);
            end
            
            %here we load block2
            blockName = blockList{2};
            load(datNameIn, blockName);
            eval(strcat('midBlock =', blockName,';'));
            eval(strcat('clear(''',blockName,''');'));
            
            str1 = strcat('Block 2 out of', {' '}, num2str(length(blockList)), {' '},'| Extracting morphology & Schafer features.');
            set(handles.status1,'String',str1{1});
            
            % convert to array of structs
            midBlock = cellBlock2wormBlock(midBlock);
            if ~fileInfo.morphology.completed
                %morphology feature set for block2
                morphology_process(hObject, eventdata, handles, midBlock, blockName);
            end
            if ~fileInfo.schafer.completed
                %schafer feature set for block2
                baekEtAl_process(hObject, eventdata, handles, midBlock, blockName, myAviInfo, processFid);
            end
            
            %first iteration for sternberg feature set
            mainBlock = [frontBlock, midBlock];
            %get the 13 skel points
            skelData = get_13points(mainBlock);
            %define the data
            dataSize = [1,length(frontBlock)];
            
            if ~fileInfo.sternberg.completed
                %sternberg feature set
                module3_process(hObject, eventdata, handles, myAviInfo, skelData, blockNameCurrent, dataSize);
            end
            if ~fileInfo.omegaTurns.completed
                %omega bends
                omegaUpsilonDetectDV(hObject, eventdata, handles, mainBlock, blockNameCurrent, processFid, dataSize)
            end
            
            blockNameCurrent = blockName;
            sternbergWindow = 250;
            
            for m=3:length(blockList)
                    if m==12
                        1;
                    end
                    str1 = strcat('Block', {' '}, sprintf('%d',m), {' '},'out of', {' '}, sprintf('%d',length(blockList)), {' '},'| Extracting Sternberg, morphology & Schafer features.');
                    set(handles.status1,'String',str1{1});
                    
                    blockName = blockList{m};
                    load(datNameIn, blockName);
                    eval(strcat('endBlock =', blockName,';'));
                    eval(strcat('clear(''',blockName,''');'));
                    
                    % convert to array of structs
                    endBlock = cellBlock2wormBlock(endBlock);
                    
                    %sternberg feature set
                    %----------------------------------------------------------------------
                    %define the block of data
                    mainBlock = [frontBlock, midBlock, endBlock];
                    
                    lenFront = length(frontBlock);
                    lenMid = length(midBlock);
                    lenEnd = length(endBlock);
                    
                    if sternbergWindow > lenEnd
                        sternbergWindowEnd = lenEnd;
                    else
                        sternbergWindowEnd = sternbergWindow;
                    end
                    
                    %crop the block of data
                    %mainBlock = mainBlock(blockSize-sternbergWindow:blockSize*2+sternbergWindow);
                    mainBlock = mainBlock(lenFront-sternbergWindow+1:lenFront+lenMid+sternbergWindowEnd);
                    
                    %get 13 point skeletons from all the elements in the block
                    skelData = get_13points(mainBlock);
                    %define the part of mainBlock to be saved in the result file
                    dataSize = [sternbergWindow+1, length(mainBlock)-sternbergWindowEnd];
                    %calculate the features
                    if ~fileInfo.sternberg.completed
                        module3_process(hObject, eventdata, handles, myAviInfo, skelData, blockNameCurrent, dataSize);
                    end
                    if ~fileInfo.omegaTurns.completed
                        %calculate omega bends
                        omegaUpsilonDetectDV(hObject, eventdata, handles, mainBlock, blockNameCurrent, processFid, dataSize);
                    end
                    if ~fileInfo.morphology.completed
                        %morphology feature set
                        morphology_process(hObject, eventdata, handles, endBlock, blockName);
                    end
                    if ~fileInfo.schafer.completed
                        %schafer lab feature set
                        baekEtAl_process(hObject, eventdata, handles, endBlock, blockName, myAviInfo, processFid);
                    end
                    
                    %clean up
                    clear('frontBlock');
                    frontBlock = midBlock;
                    clear('midBlock');
                    midBlock = endBlock;
                    clear('endBlock');
                    blockNameCurrent = blockName;
            end
            
            %deal with the last block
            
            m = length(blockList);
            
            str1 = strcat('Block', {' '}, sprintf('%d',m), {' '},'out of', {' '}, sprintf('%d',length(blockList)), {' '},'| Extracting Sternberg, morphology & Schafer features.');
            set(handles.status1,'String',str1{1});
            
            blockName = blockList{m};
            
            %sternberg feature set
            %----------------------------------------------------------------------
            %define the block of data
            mainBlock = [frontBlock, midBlock];
            
            lenMid = length(frontBlock);
            
            %crop the block of data
            mainBlock = mainBlock(lenMid-sternbergWindow+1:end);
            
            %get 13 point skeletons from all the elements in the block
            skelData = get_13points(mainBlock);
            %define the part of mainBlock to be saved in the result file
            dataSize = [sternbergWindow+1, length(mainBlock)-1];
            %calculate the features
            if ~fileInfo.sternberg.completed
                module3_process(hObject, eventdata, handles, myAviInfo, skelData, blockName, dataSize);
            end
            
            %clean up
            clear('mainBlock');
            clear('midBlock');
            clear('endBlock');
            
            % record the status file
            
            if ~fileInfo.sternberg.completed
                fileInfo.sternberg.version = mydata.preferences.version;
                fileInfo.sternberg.completed = 1;
                fileInfo.sternberg.timeStamp = datestr(now);
            end
            if ~fileInfo.morphology.completed
                fileInfo.morphology.version = mydata.preferences.version;
                fileInfo.morphology.completed = 1;
                fileInfo.morphology.timeStamp = datestr(now);
            end
            if ~fileInfo.schafer.completed
                fileInfo.schafer.version = mydata.preferences.version;
                fileInfo.schafer.completed = 1;
                fileInfo.schafer.timeStamp = datestr(now);
            end
            if ~fileInfo.omegaTurns.completed
                fileInfo.omegaTurns.version = mydata.preferences.version;
                fileInfo.omegaTurns.completed = 1;
                fileInfo.omegaTurns.timeStamp = datestr(now);
            end
            
            %copy into NAS
            if handles.preferences.nas
                %copy to server
                [msg1] = copyToNAS(metricsOutName, fileInfo, handles.preferences.version, conn);
                [msg2] = copyToNAS(morphOutName, fileInfo, handles.preferences.version, conn);
                [msg3] = copyToNAS(schaferOutName, fileInfo, handles.preferences.version, conn);
                [msg4] = copyToNAS(omegaOutName, fileInfo, handles.preferences.version, conn);
                set(handles.status1,'String',['Copying to NAS and updating database finished',msg1, msg2, msg3, msg4]);
            end
            save(expInfo.status, 'fileInfo');
        end
        %if this is running again and the feature calculation is skipped we
        %might still want to copy over the results to NAS and overwrite old
        %files.
        if fileInfo.sternberg.completed || fileInfo.morphology.completed || fileInfo.schafer.completed || fileInfo.omegaTurns.completed
            if handles.preferences.nasOverwrite
                [msg1] = copyToNAS(metricsOutName, fileInfo, handles.preferences.version, conn);
                [msg2] = copyToNAS(morphOutName, fileInfo, handles.preferences.version, conn);
                [msg3] = copyToNAS(schaferOutName, fileInfo, handles.preferences.version, conn);
                [msg4] = copyToNAS(omegaOutName, fileInfo, handles.preferences.version, conn);
                set(handles.status1,'String',['Copying to NAS and updating database finished',msg1, msg2, msg3, msg4]);
            end
        end
        
    else
        str1 = strcat('Feature calculation was disabled in preferences!');
        set(handles.status1,'String',str1);
    end
    
    %close error log file
    fclose(processFid);
    copyToNAS(errorLogFile, fileInfo, handles.preferences.version, conn);
    %close diary file
    diary off;
    copyToNAS(diaryFilePath, fileInfo, handles.preferences.version, conn);
    %finished file counter increase
    finishedFileCounter = finishedFileCounter + 1;
end

fclose('all');

if ~ischar(conn)
    %close database connection
    close(conn);
end

str1 = strcat('Analysis for', {' '}, num2str(finishedFileCounter), {' '},'files has been completed.');
set(handles.status1,'String',str1{1});


% --- Executes on button press in vignette1.
function vignette1_Callback(hObject, eventdata, handles)
% hObject    handle to vignette1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vignette1

function show1_Callback(hObject, eventdata, handles)
% hObject    handle to show1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of show1 as text
%        str2double(get(hObject,'String')) returns contents of show1 as a double


% --- Executes during object creation, after setting all properties.
function show1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to show1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showButton.
function showButton_Callback(hObject, eventdata, handles)
% hObject    handle to showButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str1 = get(handles.show1,'String');
set(handles.show1,'String', str1);

% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str1 = get(handles.pauseFlag,'String');

if strcmp(str1, 'Pause on');
    set(handles.pauseFlag,'String','Pause off');
    set(handles.pauseButton,'String','Pause off');
elseif strcmp(str1, 'Pause off');
    set(handles.pauseFlag,'String','Pause on');
    set(handles.pauseButton,'String','Pause on');
else
end

% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.exitFlag,'String',num2str(1));

function filter1_Callback(hObject, eventdata, handles)
% hObject    handle to filter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter1 as text
%        str2double(get(hObject,'String')) returns contents of filter1 as a double


% --- Executes during object creation, after setting all properties.
function filter1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getListFromMYSQL.
function getListFromMYSQL_Callback(hObject, eventdata, handles)
% hObject    handle to getListFromMYSQL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    fileListFinal = getFileListfromMYSQL(hObject, eventdata, handles);
    
    set(handles.fileList,'String',fileListFinal);
    
    mydata = guidata(hObject);
    mydata.fileListFinal = fileListFinal;
    guidata(hObject,mydata);
catch ME1
    str1{1} = strcat('Worm directory retrieval from the database failed!',{' '},'Error:',{' '}, ME1.message);
    str1{2} = strcat(ME1.stack(1).file,{'    '}, ME1.stack(1).name,{'   '}, num2str(ME1.stack(1).line));
    set(handles.status1,'String',[str1{:}]);
end


function fileList_Callback(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileList as text
%        str2double(get(hObject,'String')) returns contents of fileList as a double


% --- Executes during object creation, after setting all properties.
function fileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveList.
function saveList_Callback(hObject, eventdata, handles)
% hObject    handle to saveList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileListTxt = get(handles.fileList,'String');
fileListFinal = parseExperimentList(fileListTxt, hObject, eventdata, handles);
[dirListFileName, dirListPath] = uiputfile;
save(fullfile(dirListPath,dirListFileName),'fileListFinal','fileListFinal');
mydata = guidata(hObject);
mydata.fileListFinal = fileListFinal;
guidata(hObject,mydata);


% --- Executes on button press in loadList.
function loadList_Callback(hObject, eventdata, handles)
% hObject    handle to loadList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[dirListFileName, dirListPath] = uigetfile;
load(fullfile(dirListPath,dirListFileName));

set(handles.fileList,'String',fileListFinal);

mydata = guidata(hObject);
mydata.fileListFinal = fileListFinal;
guidata(hObject,mydata);


function vidDir_Callback(hObject, eventdata, handles)
% hObject    handle to vidDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vidDir as text
%        str2double(get(hObject,'String')) returns contents of vidDir as a double


% --- Executes during object creation, after setting all properties.
function vidDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vidDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--Custom Functions--------------------------------------------------------
%--------------------------------------------------------------------------

%here we will close the GUI correctly
function closeGUI(hObject, evntdata)
%src is the handle of the object generating the callback (the source of the event)
%evnt is the The event data structure (can be empty for some callbacks)
mydata = guidata(hObject);
selection = questdlg('Do you want to close worm analysis toolbox progress window?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection
    case 'Yes',
        if ~isfield(mydata, 'aviHandle')
            %flag1 = str2double(get(mydata.exitFlag,'String'));
            %if flag1
            delete(gcf);
            %else
            %    errordlg('Please stop the analysis first!','Analysis status');
            %end
        end
    case 'No'
        return
end

function expList = parseExperimentList(fileListTxt, hObject, eventdata, handles)
%this function gets file list as an input. It can be a dat file list or avi
%file list. The output of this function is a cell object that as elements
%contains the tracking experiments

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

mydata = guidata(hObject);
mydata.experimentList = expList;
guidata(hObject,mydata);
