function varargout = progress_verbose(varargin)
% PROGRESS_VERBOSE MATLAB code for progress_verbose.fig
%      PROGRESS_VERBOSE, by itself, creates a new PROGRESS_VERBOSE or raises the existing
%      singleton*.
%
%      H = PROGRESS_VERBOSE returns the handle to a new PROGRESS_VERBOSE or the handle to
%      the existing singleton*.
%
%      PROGRESS_VERBOSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRESS_VERBOSE.M with the given input arguments.
%
%      PROGRESS_VERBOSE('Property','Value',...) creates a new PROGRESS_VERBOSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before progress_verbose_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to progress_verbose_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help progress_verbose

% Last Modified by GUIDE v2.5 11-Aug-2011 18:36:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @progress_verbose_OpeningFcn, ...
    'gui_OutputFcn',  @progress_verbose_OutputFcn, ...
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

% --- Executes just before progress_verbose is made visible.
function progress_verbose_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to progress_verbose (see VARARGIN)

% Choose default command line output for progress_verbose
handles.output = hObject;

%--------------------------------------------------------------------------
% Preferences - here we retrieve them from the input of this GUI
%--------------------------------------------------------------------------
handles.preferences = varargin{1};
handles.warningList = varargin{2};

%--------------------
% Look for a previously saved preferences file and load that
% Save the file to a secure location
preferencesFileName = [ctfroot,filesep,'wormAnalysisToolboxUserData',filesep,'custom_preferences.mat'];
% Load file if exists
if exist(preferencesFileName, 'file') == 2
    data = [];
    load(preferencesFileName);
    handles.preferences = data;
end
%--------------------
global globalQuitFlag;

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

% UIWAIT makes progress_verbose wait for user response (see UIRESUME)
% uiwait(handles.progress1);


% --- Outputs from this function are returned to the command line.
function varargout = progress_verbose_OutputFcn(hObject, eventdata, handles)
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
% GUI
% Show the segmentation image
axes(handles.mainImg);  %#ok<*MAXES>
imshow('axis1.png');

global globalQuitFlag;
global vulvaSideAnnotation;
% Flag signifying _CW_, _CCW_ nomenclature, 0 if its L,R, 1 if its
% _CW_,_CCW_
modeFlag = 0;
%--------------------------------------------------------------------------
% Load new preferences data.
%--------------------------------------------------------------------------
% Look for a previously saved preferences file and load that. 
% Define file name
preferencesFileName = [ctfroot,filesep,'wormAnalysisToolboxUserData',filesep,'custom_preferences.mat'];
% Load file if exists
if exist(preferencesFileName, 'file') == 2
    data = [];
    load(preferencesFileName);
    handles.preferences = data;
end

%--------------------------------------------------------------------------
% Initialize
%--------------------------------------------------------------------------
% Exit or stop flag for the pipeline
set(handles.exitFlag, 'String', num2str(0));
% Number of steps to plot the progress bar:
pLen = 3;
% Number of finished files
finishedFileCounter = 0;

% Establish current computer name
pcIP = char(java.net.InetAddress.getLocalHost.toString);

% Define errorData, for memory pre-allocation we will set the size of error
% data to 100 and will crop it when needed
errorData = struct( ...
    'errorTag', [],...
    'errorStr', [],...
    'errorDescription', [],...
    'dir', [],...
    'fileName', [],...
    'dbID',[]);
errorData(100).errorTag = [];
% Error count
errorIndex = 0;
% Define the db table of interest name
tableName = handles.preferences.experimentCollectionListName;

%--------------------------------------------------------------------------
%   Prepare database connection
%--------------------------------------------------------------------------
conn = 'no connection';
if handles.preferences.useDB
    error('database details missing')
    conn = database;
end

% Initialize pipeline values
completed    = 0;
features     = 0;
overlayVideo = 0;
% Here we will define two forks of the process - standalone and DB based
if handles.preferences.standalone
    experimentsToFinish = 1;
    noOfErrors = 0;
elseif handles.preferences.useDB
    experimentsToFinish = 1;
    noOfErrors = 0;
else
    % No other cases yet
end

% While we have unfinished experiments, start the analysis
while experimentsToFinish > noOfErrors
    % Initialize dummy values
    unfinishedExpID    = 1;
    randomExperiment   = '';
    vulvasideCorrected = NaN;
    
    % If the database flag is enabled select a random experiment from the
    % experiment list table in the database. Also return the experiment id
    % and the total number of experiments to finish for this computer
    if handles.preferences.useDB
        try
            % Retrieve the data
            [unfinishedExpID, randomExperiment, experimentsToFinish] = updateRandomExperimentListTable(conn, handles);
            % Check if its valid
            
            % Check if randomExperiment is empty if it is then move on to
            % the next iteration. If its not empty then check if such file
            % exists. Throw an error if it doesn't and move on to the next
            % iteration
            if ~isempty(randomExperiment)
                if ~exist(randomExperiment,'file')
                    error('experimentList:fileNotFound',...
                        ['Moving to the next file out of:',...
                        num2str(experimentsToFinish),...
                        '. Experiment could not be located:',...
                        randomExperiment,'Database id = ',...
                        num2str(unfinishedExpID)]);
                end
            else
                % Move to the next iteration
                noOfErrors = noOfErrors + 1;
                continue;
            end
        catch ME1
            str1 = strcat('Error while updating experiment list table:',tableName);
            set(handles.status1,'String', str1{1});
            
            msgString = getReport(ME1, 'extended','hyperlinks','off');
            
            % Define error information
            errorStr = msgString;
            errorDescription = ['This error occurs when the pipeline ',...
                'is unable to update the experiment process table. Please ',...
                'check the error message to troubleshoot.'];
            errorTag = 'pipeline_dbupdate';
            
            errorIndex = errorIndex + 1;
            errorData(errorIndex).errorTag = errorTag;
            errorData(errorIndex).errorStr = errorStr;
            errorData(errorIndex).errorDescription = errorDescription;
            errorData(errorIndex).dir = [];
            errorData(errorIndex).fileName = [];
            if ~handles.preferences.standalone && handles.preferences.useDB
                errorData(errorIndex).dbID = unfinishedExpID;
            else
                errorData(errorIndex).dbID = [];
            end
            % Call error viewer
            errorViewer(errorData(1:errorIndex));
        end
        
        % Get the number of experiments that can't be finished
        % noOfErrors = getNumberOfErrorExperimentsForPC(conn, pcIP, handles);
        
        % if there are no experimentsToFinish then exit while
        if experimentsToFinish == 0
            break;
        end
    end
    
    % Update the database with the space remaining on this computer
    if handles.preferences.useDB
        updateRemainingSpace(conn, pcIP);
    end
    
    %----------------------------------------------------------------------
    % Start the pipeline
    %---------------------
    try
        % Update the GUI
        set(handles.fileList, 'String', fullfile(randomExperiment));
        
        %--------------------------------------------------------------------------
        % Located files to analyze
        %--------------------------------------------------------------------------
        % Get file list to analyze from the GUI
        fileListTxt = get(handles.fileList,'String');
        % If the experiment was selected get all of the files associated
        % with it.
        if ~isempty(fileListTxt)
            % Parse the file list and return all of the experiment data
            expList = parseExperimentList(fileListTxt, hObject, eventdata, handles);
            % Retrieve the avi files for display
            fileListFinal = {expList{:}.avi};
        else
            % This case will happen if no file has been selected. It means
            % we are in the standalone case. Print a message.
            str1 = strcat('No valid directories found!');
            set(handles.status1,'String',str1);
            
            % Get the directory of interest manualy
            dirPath = uigetdir('*.*','Enter worm video directory.');
            if ~dirPath
                % Stop the function if user pressed cancel
                return;
            end
            
            % Get all avi files in directory specified
            dirContents = dirrec(dirPath,'.avi');
            
            % Check if the contents of directory is not empty
            if ~isempty(dirContents)
                % Get experiment files
                expList = parseExperimentList(dirContents, hObject, eventdata, handles);
                if ~isempty(expList)
                    expListStruct = [expList{:}];
                    fileListFinal = {expListStruct.avi};
                    
                    % Update the number of experiments that need to be
                    % completed
                    experimentsToFinish = length(expList);
                    
                    vulvaSideAnnotation = zeros(1, experimentsToFinish);
                    % Select vulvaside
                    modeFlag = vulvaSideSelector(fileListFinal);
                    
                else
                    % Define error information
                    errorStr = ['No experiments found in the directory: -',strrep(dirPath,'\','/')];
                    errorDescription = ['This error occurs when the ',...
                        'directory that has been passed to the toolbox ',...
                        'contains no valid c.elegans experiments'];
                    errorTag = 'pipeline_files';
                    
                    errorIndex = errorIndex + 1;
                    errorData(errorIndex).errorTag = errorTag;
                    errorData(errorIndex).errorStr = errorStr;
                    errorData(errorIndex).errorDescription = errorDescription;
                    errorData(errorIndex).dir = dirPath;
                    errorData(errorIndex).fileName = [];
                    if ~handles.preferences.standalone && handles.preferences.useDB
                        errorData(errorIndex).dbID = unfinishedExpID;
                    else
                        errorData(errorIndex).dbID = [];
                    end
                    % Call error viewer
                    errorViewer(errorData(1:errorIndex));
                    % Throw error
                    error('pipeline:files', errorStr);
                end
            else
                str1 = strcat('Directory selected is empty!');
                set(handles.status1,'String',str1);
                return;
            end
        end
        
        % Display
        set(handles.fileList, 'String', fileListFinal);
        str1 = strcat('File search completed!');
        set(handles.status1, 'String', str1);
        
        %--------------------------------------------------------------------------
        %   Prepare dir for analysis
        %--------------------------------------------------------------------------
        createAnalysisDir(hObject, eventdata, handles);
        % Here we update the paths of the experiment files
        %parseExperimentList(fileListTxt, hObject, eventdata, handles);
        mydata = guidata(hObject);
        mydata.conn = conn;
        
        numberOfExpSelected = length(mydata.experimentList);
        
        %--------------------------------------------------------------------------
        % Main loop through specified experiments
        %--------------------------------------------------------------------------
        for i = 1 : numberOfExpSelected
            % For each iteration set the variables to initial values
            completed    = 0;
            features     = 0;
            overlayVideo = 0;
            % This flag will signify is segmentation was ran in this
            % iteration of the loop. It is later used to know if the
            % database update is necessary
            segmentationRunFlag = 0;
            
            % CD to the directory of interest
            dirAvi = mydata.experimentList{i}.dir;
            cd(dirAvi);
            
            % Display video name
            set(handles.videoName, 'String', mydata.experimentList{i}.avi);
            
            mydata.dirAvi = dirAvi;
            mydata.currentFile = i;
            set(handles.vidDir,'String', dirAvi);
            if i > 1
                set(handles.fileList,'String', fileListFinal(i:end));
            end
            
            lenAvi = numberOfExpSelected;
            mydata.lenAvi = lenAvi;
            
            set(handles.idMax, 'String', num2str(lenAvi));
            set(handles.idMin, 'String', num2str(i));
            set(handles.status1,'String','Video successfully loaded.');
            
            
            %             % If useDB is set get expId
            %             if handles.preferences.useDB
            %                 experimentId = getExperimentId(conn, mydata.experimentList{i}.fileName);
            %                 unfinishedExpID = experimentId;
            %             end
            
            %----------------------------------------------------------------------
            % Generating log files
            %----------------------------------------------------------------------
            % Open an error dump file
            errorLogFile = fullfile(dirAvi, '.data',[mydata.experimentList{i}.fileName,'_process','.txt']);
            % Append to the existing process file
            fclose('all');
            processFid = fopen(errorLogFile, 'a+');
            fprintf(processFid, '%s\n', strcat('Starting error dump file :', datestr(now)));
            % Open warnings dump file
            diaryFilePath = fullfile(dirAvi, '.data', strcat(mydata.experimentList{i}.fileName, '_warnings', '.txt'));
            handles.diaryFileName = diaryFilePath;
            % Replace old diary file
            if exist(diaryFilePath,'file') == 2
                delete(diaryFilePath);
            end
            diary(diaryFilePath);
            % Open stage movement warnings dump file
            diaryFilePathForStageMotion = fullfile(dirAvi, '.data', strcat(mydata.experimentList{i}.fileName, '_warningsStageMotion', '.txt'));
            handles.diaryFileNameForStageMotion = diaryFilePathForStageMotion;
            if exist(diaryFilePathForStageMotion,'file') == 2
                delete(diaryFilePathForStageMotion);
            end
            % Open segmentation warnings dump file
            diaryFilePathForSegmentation = fullfile(dirAvi, '.data', strcat(mydata.experimentList{i}.fileName, '_warningsSegmentation', '.txt'));
            handles.diaryFileName = diaryFilePathForSegmentation;
            if exist(diaryFilePathForSegmentation,'file') == 2
                delete(diaryFilePathForSegmentation);
            end
            
            %----------------------------------------------------------------------
            % Check to clean up the directory
            %----------------------------------------------------------------------
            str1 = strcat('Progress bar: 0 out of', {' '}, num2str(pLen), {' '},'| Cleaning the directory');
            set(handles.status2,'String',str1{1});
            
                       
            %----------------------------------------------------------------------
            % Status check
            %----------------------------------------------------------------------
            % Here we look for file status log fileInfo variable - if it
            % doesnt exist - we create a new one.
            
            if isempty(mydata.experimentList{i}.status)
                mydata.experimentList{i}.status = fullfile(mydata.experimentList{i}.dir,'.data',strcat(mydata.experimentList{i}.fileName,'_status.mat'));
                mydata.experimentList = mydata.experimentList;
                fileInfo = initializeFileInfo(mydata, mydata.experimentList{i});
                save(mydata.experimentList{i}.status, 'fileInfo');
            else
                % Status file exist, but it might be corrupted and needs to
                % be initiated again
                try
                    load(mydata.experimentList{i}.status);
                catch ME1 %#ok<NASGU>
                    mydata.experimentList{i}.status = fullfile(mydata.experimentList{i}.dir,'.data',strcat(mydata.experimentList{i}.fileName,'_status.mat'));
                    mydata.experimentList = mydata.experimentList;
                    fileInfo = initializeFileInfo(mydata, mydata.experimentList{i});
                    save(mydata.experimentList{i}.status, 'fileInfo');
                end
                %record new timestamp upon access
                fileInfo.timeStamp = datestr(now);
                %here we update the paths to all the experiment files
                fileInfo = updateExperimentPaths(fileInfo, mydata.experimentList{mydata.currentFile});
                
                % This check is for backwards compatibility to make sure
                % older fileInfo variables when loaded have these values
                if ~isfield(fileInfo, 'copyToNAS')
                    fileInfo.copyToNAS.videoDiff = 0;
                    fileInfo.copyToNAS.videoDiffDS = '';
                    
                    fileInfo.copyToNAS.stageMotion = 0;
                    fileInfo.copyToNAS.stageMotionDS = '';
                    
                    fileInfo.copyToNAS.failedFramesFile = 0;
                    fileInfo.copyToNAS.failedFramesFileDS = '';
                    
                    fileInfo.copyToNAS.segDat = 0;
                    fileInfo.copyToNAS.segDatDS = '';
                    
                    fileInfo.copyToNAS.overlayAvi = 0;
                    fileInfo.copyToNAS.overlayAviDS = '';
                end
                % Check if fileInfo does not have
                % fileInfo.stageMotion.completedDiff flag, add it here as 1
                % if fileInfo.stageMotion.completed is 1, 0 if otherwise
                if ~isfield(fileInfo.stageMovement, 'completedDiff')
                    if fileInfo.stageMovement.completed
                        fileInfo.stageMovement.completedDiff = 1;
                    else
                        fileInfo.stageMovement.completedDiff = 0;
                    end
                end
                
                save(mydata.experimentList{i}.status, 'fileInfo');
            end
            
            % Update GUI data
            guidata(hObject, mydata);
            
            %----------------------------------------------------------------------
            %% Stage motion detection
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
            set(handles.pauseButton, 'enable', 'off');
            set(handles.bottomPanel, 'Title', 'Stage movement:');
            
            set(handles.exitFlag,'String',num2str(0));
            %close general diary
            diary off;
            %check if stage motion for this file is completed
            %----------------------------------------------------------------------
            diary(diaryFilePathForStageMotion);
            
            try
                % Collect elapsed time data
                tic;
                % Run stage motion detection
                fileInfo = findStageMovementProcess(fileInfo, hObject, eventdata, handles);
                set(handles.status1,'String', 'Stage motion detection successfully finished!');
                % Record time
                timer1 = toc;
                fprintf(processFid,'%s\n',['Stage motion detection:',mydata.experimentList{mydata.currentFile}.fileName]);
                fprintf(processFid,'%s\n',['Time elapsed: ',num2str(timer1/60),'s']);
            catch ME1
                
                if globalQuitFlag
                    globalQuitFlag = 0;
                    return;
                end
                
                % Check if DB connection is still open
                if handles.preferences.useDB
                    try
                        ping(conn);
                    catch ME1
                        msgString = getReport(ME1, 'extended','hyperlinks','off');
                        error('database details missing')

                        conn = database;
                        
                        % Define error information
                        errorStr = msgString;
                        errorDescription = ['This error means that the database connection has ',...
                            ' timed out and the connection cant be established again.'];
                        errorTag = 'pipeline_db_connection_lost';
                        % Assign to error variable
                        errorIndex = errorIndex + 1;
                        errorData(errorIndex).errorTag = errorTag;
                        errorData(errorIndex).errorStr = errorStr;
                        errorData(errorIndex).errorDescription = errorDescription;
                        errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                        errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                        if ~handles.preferences.standalone && handles.preferences.useDB
                            errorData(errorIndex).dbID = unfinishedExpID;
                        else
                            errorData(errorIndex).dbID = [];
                        end
                        % Call error viewer
                        errorViewer(errorData(1:errorIndex));
                    end
                end
                
                msgString = getReport(ME1, 'extended','hyperlinks','off');
                str1 = strcat('Stage motion detection for file',{' '},mydata.experimentList{mydata.currentFile}.fileName,{' '},'failed!',{' '},msgString);
                set(handles.status1,'String',str1{1});
                % write errorDrump
                fprintf(processFid,'%s\n',mydata.experimentList{mydata.currentFile}.fileName);
                fprintf(processFid,'%s\n',msgString);
                
                if handles.preferences.useDB
                    updateErrorTable(conn, unfinishedExpID, ['Stage motion detection failed!',msgString]);
                end
                
                % Since we dont want to deal with stage motion failure
                % experiments and experiments that can't be opened all the
                % time again and again we will put them in their separate
                % class - unsegmentable for now.
                if ~handles.preferences.standalone && handles.preferences.useDB
                    unsegmentable = 1;
                    colnames = {'unsegmentable'};
                    exdata = {unsegmentable};
                    whereClause = ['where id = ',num2str(unfinishedExpID)];
                    update(conn, tableName, colnames, exdata, whereClause);
                end
                
                % Define error information
                errorStr = msgString;
                errorDescription = ['This error means that one of the major pipeline steps ',...
                    'stage movement detection failed. This can be to several reasons: '...
                    'corrupt video file, malformed log file and most commonly ',...
                    'inability to match stage movements observed in the video ',...
                    'with stage movements recorded in the log file. For the firs ',...
                    'two issues the experiment will have to be done again ',...
                    'or the file reconstructed with video editing software such as ',...
                    'virtualdub. This last issue doesn''t have a solution yet ',...
                    'but in the future releases will be able to be repaired ',...
                    'and re-aligned manually.'];
                errorTag = 'stage_movement_detection_error';
                % Assign to error variable
                errorIndex = errorIndex + 1;
                errorData(errorIndex).errorTag = errorTag;
                errorData(errorIndex).errorStr = errorStr;
                errorData(errorIndex).errorDescription = errorDescription;
                errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                if ~handles.preferences.standalone && handles.preferences.useDB
                    errorData(errorIndex).dbID = unfinishedExpID;
                else
                    errorData(errorIndex).dbID = [];
                end
                % Call error viewer
                errorViewer(errorData(1:errorIndex));
                
                noOfErrors = noOfErrors + 1;
                continue;
            end
            % Close stage motion diary
            diary off;
            if handles.preferences.nas
                copyToNAS(diaryFilePathForStageMotion, fileInfo, handles.preferences.version, conn);
            end
            % Check GUI exit
            ret1 = str2double(get(handles.exitFlag,'String'));
            if ret1
                return;
            end
            
            
            %%
            %--------------------------------------------------------------
            % Segmentation
            %--------------------------------------------------------------
            str1 = strcat('Progress bar: 2 out of', {' '}, num2str(pLen), {' '}, '| Video segmentation');
            set(handles.status2, 'String', str1{1});
            axes(handles.progressBar1);
            progressBarDat = (0:round((2/pLen)*100));
            color1 = [0, 51/255, 102/255];
            fill([progressBarDat, progressBarDat(end),0], [ones(1,length(progressBarDat)), 0, 0], color1, 'FaceAlpha', 0.95);
            xlim(handles.progressBar1, [1,100]);
            set(gca, 'YTick', []);
            set(gca, 'XTick', []);
            
            set(handles.showButton, 'enable', 'on');
            set(handles.show1, 'enable', 'on');
            set(handles.pauseButton, 'enable', 'on');
            
            set(handles.exitFlag, 'String', num2str(0));
            
            % If we terminated the segmentation we need to re-do it, here
            % we will check for that
            doSegFlag = 0;
            if fileInfo.segmentation.version < 2.4
                doSegFlag = 1;
            else
                % Check if segInfo file exists, if not - redo seg
                segFileDir  = fullfile(fileInfo.expList.dir,'.data', strcat(fileInfo.expList.fileName,'_seg'));
                datFileName = fullfile(segFileDir, 'segInfo.mat');
                if exist(datFileName, 'file') ~= 2
                    doSegFlag = 1;
                end
            end
            
            if fileInfo.segmentation.version == 2.4
                doSegFlag = 1;
            end
            
            if handles.preferences.redoSeg || fileInfo.segmentation.completed == 0 || doSegFlag
                %----------------------------------------------------------------------
                %start diary for segmentation
                diary(diaryFilePathForSegmentation);
                tic;
                try
                    if handles.preferences.useDB
                        % Check if DB connection is still open
                        try
                            ping(conn);
                        catch ME1
                            msgString = getReport(ME1, 'extended','hyperlinks','off');
                            error('database details missing')

                            conn = database;
                            
                            % Define error information
                            errorStr = msgString;
                            errorDescription = ['This error means that the database connection has ',...
                                ' timed out and the connection cant be established again.'];
                            errorTag = 'pipeline_db_connection_lost';
                            % Assign to error variable
                            errorIndex = errorIndex + 1;
                            errorData(errorIndex).errorTag = errorTag;
                            errorData(errorIndex).errorStr = errorStr;
                            errorData(errorIndex).errorDescription = errorDescription;
                            errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                            errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                            if ~handles.preferences.standalone && handles.preferences.useDB
                                errorData(errorIndex).dbID = unfinishedExpID;
                            else
                                errorData(errorIndex).dbID = [];
                            end
                            % Call error viewer
                            errorViewer(errorData(1:errorIndex));
                        end
                    end
                    fileInfo = segmentationMain(hObject, eventdata, handles, fileInfo);
                    str1 = strcat('Segmentation for file', {' '}, mydata.experimentList{i}.avi, {' '}, 'finished.');
                    set(handles.status1, 'String', str1{1});
                    
                    % This flag will signify that the segmentation was
                    % executed in this iteration and it wasnt skipped
                    % because of previous completion
                    segmentationRunFlag = 1;
                    
                catch ME1
                    
                    if globalQuitFlag
                        globalQuitFlag = 0;
                        return;
                    end                
                    
                    msgString = getReport(ME1, 'extended','hyperlinks','off');
                    str1 = strcat('Segmentation for file', {' '}, mydata.experimentList{mydata.currentFile}.fileName, {' '}, 'failed!', {' '}, msgString);
                    set(handles.status1, 'String', str1{1});
                    %write errorDrump
                    fprintf(processFid, '%s\n', mydata.experimentList{mydata.currentFile}.fileName);
                    fprintf(processFid, '%s\n', msgString);
                    
                    if handles.preferences.useDB
                        updateErrorTable(conn, unfinishedExpID, ['Segmentation failed!',msgString]);
                        msgString = [msgString, 'DBid:',num2str(unfinishedExpID)]; %#ok<AGROW>
                    end
                    
                    % Define error information
                    errorStr = msgString;
                    errorDescription = ['This error means that one of the major pipeline steps - ',...
                        'video segmentation has failed. This should happen very rarely. ',...
                        'Please refer to the error signature to identify the problem.'];
                    errorTag = 'segmentation_error';
                    % Assign to error variable
                    errorIndex = errorIndex + 1;
                    errorData(errorIndex).errorTag = errorTag;
                    errorData(errorIndex).errorStr = errorStr;
                    errorData(errorIndex).errorDescription = errorDescription;
                    errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                    errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                    if ~handles.preferences.standalone && handles.preferences.useDB
                        errorData(errorIndex).dbID = unfinishedExpID;
                    else
                        errorData(errorIndex).dbID = [];
                    end
                    % Call error viewer
                    errorViewer(errorData(1:errorIndex));
                    % We call continue to exit or advance the for loop and
                    % increase the number of errors.
                    noOfErrors = noOfErrors + 1;
                    continue;
                end
                timer1 = toc;
                fprintf(processFid, '%s\n', ['Segmenting: ', mydata.experimentList{mydata.currentFile}.fileName]);
                fprintf(processFid, '%s\n\n', ['Time elapsed: ', num2str(timer1)]);
                diary off;
                if handles.preferences.nas
                    copyToNAS(diaryFilePathForSegmentation, fileInfo, handles.preferences.version, conn);
                end
            end
            
            %----------------------------------------------------------------------
            % Here we run automatic head and tail detection
            %----------------------------------------------------------------------
            if segmentationRunFlag || handles.preferences.redo_ht
                % Lets calculate Head and Tail and Head an Tail chunk reliability statistics
                datFileName = fileInfo.expList.segDat;
                load(datFileName, 'blockSize', 'lastBlockSize', 'globalFrameCounter');
                headTail(datFileName, fileInfo, blockSize, lastBlockSize, globalFrameCounter, handles.preferences);
            end
            
            %----------------------------------------------------------------------
            % Here we calculate the normalized worm
            %----------------------------------------------------------------------
            if segmentationRunFlag || handles.preferences.normalize || handles.preferences.redo_ht
                try
                    % We will normalize the worms differently if we also need to
                    % flip the vulva side. Lets check which side the vulva is on
                    vulvaSideAnnotationLocal = vulvaSideAnnotation(i);
                    fileInfo.vulvaSideAnnotation = vulvaSideAnnotationLocal;
                    wormSideFlag = getVulvaSide(fileInfo, conn, hObject, eventdata, handles);
                    
                    % There are two possible protocols for labelign worm side
                    % schafer lab one where sides are labelled L or R or 
                    % standalone one where sides are labelled _CW_ or _CCW_
                    
                    % we will check here if we are using schafer lab
                    % protocol, in this case we label the side by looking
                    % thourgh the microscope not the tracker window,
                    % therefore the side needs to be corrected. If we are
                    % standalone we have already asked the users to input
                    % side as it is seen in the video. No flipping will be
                    % necessary.
                    % modeFlag is a flag that is = 1 when _CW_ and _CCW_
                    % nomenclature is used, it is 0 when L and R are used
                    if wormSideFlag == 1
                        % Normalize normally and flip vulva side
                        %----------------------------------------------------------------------
                        % Here we perform a vulva side correction step. Depending on
                        % the label provided while collecting the experiment the vulva
                        % side will be labelled to match the real vulva side on the
                        % worm
                        %----------------------------------------------------------------------
                        [fileInfo, vulvasideCorrected] = correctVulvalSide(fileInfo, conn, hObject, eventdata, handles);
                    else
                        vulvasideCorrected = 0;
                        % Normalize normally and move on
                        normWormProcess(fileInfo, handles);
                    end
                catch ME1
                    
                    if globalQuitFlag
                        globalQuitFlag = 0;
                        return;
                    end
                
                    
                    msgString = getReport(ME1, 'extended','hyperlinks','off');
                    str1 = strcat('Normalized worm extraction for file', {' '}, mydata.experimentList{mydata.currentFile}.fileName, {' '}, 'failed!', {' '}, msgString);
                    set(handles.status1, 'String', str1{1});
                    %write errorDrump
                    fprintf(processFid, '%s\n', mydata.experimentList{mydata.currentFile}.fileName);
                    fprintf(processFid, '%s\n', msgString);
                    if handles.preferences.useDB
                        updateErrorTable(conn, unfinishedExpID, ['Normalized worm extraction failed!',msgString]);
                        msgString = [msgString,'DBid:',num2str(unfinishedExpID)]; %#ok<AGROW>
                    end
                    
                    % Define error information
                    errorStr = msgString;
                    errorDescription = ['This error means that one of the major pipeline steps - ',...
                        'worm normaliziation has failed. This should happen very rarely. ',...
                        'Please refer to the error signature to identify the problem.'];
                    errorTag = 'normalize_worm_data_error';
                    % Assign to error variable
                    errorIndex = errorIndex + 1;
                    errorData(errorIndex).errorTag = errorTag;
                    errorData(errorIndex).errorStr = errorStr;
                    errorData(errorIndex).errorDescription = errorDescription;
                    errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                    errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                    if ~handles.preferences.standalone && handles.preferences.useDB
                        errorData(errorIndex).dbID = unfinishedExpID;
                    else
                        errorData(errorIndex).dbID = [];
                    end
                    % Call error viewer
                    errorViewer(errorData(1:errorIndex));
                    % We call continue to exit or advance for loop and we
                    % also increase the number of errors
                    noOfErrors = noOfErrors + 1;
                    continue;
                    
                end
            end
            
            %----------------------------------------------------------------------
            % Make video overlay output file
            %----------------------------------------------------------------------
            % Here we will always redo the overlay video. Perhaps it would
            % be a good idea to add an overlay video overwrite flag. It
            % would check if the file exists and if it does do the overlay
            % only if the overwrite flag is raised.
            
            if handles.preferences.videoOut
                % This is temporary code, a bug initialized .overlayAvi to
                % an empty string, its been fixed now. I decided to leave
                % it just in case its been propagated in saved fileInfo
                % file.
                if ischar(fileInfo.copyToNAS.overlayAvi)
                    fileInfo.copyToNAS.overlayAvi = 0;
                end
                % Retrieve data is needed for exportVideo()
                datFileName = fileInfo.expList.segDat;
                load(datFileName, 'vImg', 'fps');
                
                % If we are using db
                if handles.preferences.useDB
                    analysisTableName = tableName;
                    % initialize output file
                    outputVideoFile = '';
                    overlayVideo = 0;
                    % define the directory in the nas
                    if strcmpi(analysisTableName, 'segmentationExperimentList')
                        nasDir = '\\nas207-1\Data\videoOverlay_corrected\';
                        %nasDir = '\\nas207-2\Data\results-12-05-21\';
                    elseif strcmpi(analysisTableName, 'victoriaExperimentList')
                        nasDir = '\\nas207-2\Data\other-runs\victoriaOverlay\';
                    elseif strcmpi(analysisTableName, 'mariosExperimentList')
                        nasDir = '\\nas207-2\Data\other-runs\mariosOverlay\';
                    else
                        nasDir = '\\nas207-2\Data\other-runs\unknwonOverlay\';
                    end
                    
                    % get the destination directory in the nas
                    expPath = makeNasDir(conn, unfinishedExpID);
                    % compbine the two
                    dirTempCopy = fullfile(nasDir, expPath);
                    
                    % Check if the file does not exist by any chance in the NAS
                    
                    % Get the file name
                    [~, expName, ~] = fileparts(fileInfo.expList.avi);
                    % Forumalte a full destination string
                    newOutputName = fullfile(dirTempCopy, [expName,'_seg.avi']);
                    
                    nasDir = '\\nas207-2\Data\results-12-05-21\';
                    % compbine the two
                    dirTempCopy2 = fullfile(nasDir, expPath);
                    % Get the file name
                    % Forumalte a full destination string
                    newOutputName2 = fullfile(dirTempCopy2, [expName,'_seg.avi']);
                    
                    outputVideoFile = [expName,'_seg.avi'];
                    
                    % Lets check if it exists on the NAS1, if not:
                    if ~(exist(newOutputName, 'file') == 2 || exist(newOutputName2, 'file') == 2)
                        
                        % Lets check if it exists on the PC
                        [~, expName, ~] = fileparts(fileInfo.expList.avi);
                        % Forumalte a full destination string
                        outputVideoFile = [expName,'_seg.avi'];
                    
                        if exist(outputVideoFile, 'file') == 2
                            % Save the output location
                            fileInfo.expList.overlayAvi = outputVideoFile;
                            % Check if nas dir exists
                            if ~isdir(dirTempCopy)
                                % Make dir if doesnt exist
                                mkdir(dirTempCopy);
                            end
                            
                            % Copy the file (source, destination)
                            copyfile(outputVideoFile, newOutputName);
                            % Here we will raise a flag that overlayVideo has
                            % successfully completed
                            overlayVideo = 1;
                            
                        else
                            % Here we will check if the records show that
                            % the video was exported correctly, if not it
                            % will be re-computed
                            
                            % Run exportVideo()
                            wormSideFlag = getVulvaSide(fileInfo, conn, hObject, eventdata, handles);
                            outputVideoFile = exportVideo(datFileName, fileInfo.expList, vImg, fps, handles, wormSideFlag, modeFlag);
                            
                            
                            
                            % Save the output location
                            fileInfo.expList.overlayAvi = outputVideoFile;
                            % Check if nas dir exists
                            if ~isdir(dirTempCopy)
                                % Make dir if doesnt exist
                                mkdir(dirTempCopy);
                            end
                            
                            % Copy the file (source, destination)
                            copyfile(outputVideoFile, newOutputName);
                            % Here we will raise a flag that overlayVideo has
                            % successfully completed
                            overlayVideo = 1;
                        end
                    else
                        overlayVideo = 1;
                    end
                else
                    wormSideFlag = getVulvaSide(fileInfo, conn, hObject, eventdata, handles);
                    outputVideoFile = exportVideo(datFileName, fileInfo.expList, vImg, fps, handles, wormSideFlag, modeFlag);
                    
                    overlayVideo = 1;
                end
                
                % We will delete the video file if we copied it over to the NAS
                if handles.preferences.deleteVideo
                    if (exist(outputVideoFile, 'file') == 2) && overlayVideo
                        delete(outputVideoFile);
                    end
                end

                % Save stuff in fileInfo
                fileInfo.copyToNAS.overlayAvi = overlayVideo;
                fileInfo.copyToNAS.overlayAviDS = datestr(now);
                save(fileInfo.expList.status, 'fileInfo');
            end
            %----------------------------------------------------------------------
            % Copy the results to the nas and update the database
            %----------------------------------------------------------------------
            if handles.preferences.useDB || handles.preferences.dbupdate
                try
                    % Check if DB connection is still open
                    %----------------
                    try
                        ping(conn);
                    catch ME1
                        msgString = getReport(ME1, 'extended','hyperlinks','off');
                        error('database details missing')

                        conn = database;
                        
                        % Define error information
                        errorStr = msgString;
                        errorDescription = ['This error means that the database connection has ',...
                            'timed out and the connection cant be established again.'];
                        errorTag = 'pipeline_db_connection_lost';
                        % Assign to error variable
                        errorIndex = errorIndex + 1;
                        errorData(errorIndex).errorTag = errorTag;
                        errorData(errorIndex).errorStr = errorStr;
                        errorData(errorIndex).errorDescription = errorDescription;
                        errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                        errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                        if ~handles.preferences.standalone && handles.preferences.useDB
                            errorData(errorIndex).dbID = unfinishedExpID;
                        else
                            errorData(errorIndex).dbID = [];
                        end
                        % Call error viewer
                        errorViewer(errorData(1:errorIndex));
                    end
                    %----------------
                    
                    % This section updates the database with the
                    % segmentation results. The update will happen only if
                    % the segmentation has been run in this cycle or if the
                    % user selected preferences.dbupdate flag
                    
                    % This update will not be run if the segmentation has
                    % not been executed in this run.
                    
                    if segmentationRunFlag || handles.preferences.dbupdate 
                        str1 = strcat('Update database for', {' '}, mydata.experimentList{i}.avi, {' '}, 'started...');
                        set(handles.status1, 'String', str1{1});
                        
                        % FILE DEFINITIONS
                        % ----------------
                        datFileName = fileInfo.expList.segDat;
                        segFileDir = fileInfo.expList.segDatDir;
                        failedFramesFile = fileInfo.expList.failedFramesFile;
                        diffFileName = fileInfo.expList.videoDiff;
                        stageMotionFileName = fileInfo.expList.stageMotion;
                        
%                         if handles.preferences.videoOut
%                             outputVideoFile = fileInfo.expList.overlayAvi;
%                         end
                        % LOAD SECTION
                        % ------------
                        % Load hAndtData
                        load(getRelativePath(datFileName),'hAndtData');
                        % Load failedFrames record
                        load(getRelativePath(failedFramesFile), 'failedFrames');
                        
                        % DB update failed frames
                        %updateDatabase_failedFrames(fileInfo, failedFrames, conn);
                        % After 4446966 entries and only ~ 2000 files analyzed
                        % i realized that the delays will be too long to have
                        % information about each frame. The failedFrames file
                        % is in the logs of each of the experiment in the NAS.
                        % The database info that I will update is a count of
                        % how many times a particular error signature happend.
                        % This information is stored in
                        % frame_warning_labels_summary. Table
                        % frame_warning_labels_signatures has error signature
                        % for each of these cases.
                        if handles.preferences.useDB
                            updateDatabaseFailedFramesSummary(fileInfo, failedFrames, conn);
                            % Update database with segmentation results
                            updateDatabase(fileInfo, 'segmentation', conn);
                            % Update database with it
                            updateDatabaseHandT(fileInfo, hAndtData, conn);
                            
                            sqlString = strcat('select id from version where id =',...
                                num2str(unfinishedExpID), ';');
                            curs = exec(conn, sqlString);
                            curs = fetch(curs);
                            versionID = curs.Data;
                            close(curs);
                            
                            if ~iscell(versionID)
                                %
                            elseif strcmpi(versionID, 'No Data')
                                % update version
                                colnames = {'id', 'segmentation'};
                                exdata = {unfinishedExpID, fileInfo.segmentation.version};                            
                                fastinsert(conn, 'version', colnames, exdata);
                            else
                                % update version
                                colnames = {'segmentation'};
                                exdata = {fileInfo.segmentation.version};                            
                                whereClause = ['where id = ',num2str(unfinishedExpID)];
                                update(conn, 'version', colnames, exdata, whereClause);
                            end
                            %----------------------------------------------
                        end
                        
                        % COPY SECTION
                        %-------------
                        % Copy stage motion diff to the NAS
                        if handles.preferences.nas
                            %&& ~fileInfo.copyToNAS.videoDiff
                            copyToNAS(diffFileName, fileInfo, handles.preferences.version, mydata.conn);
                            
                            fileInfo.copyToNAS.videoDiff = 1;
                            fileInfo.copyToNAS.videoDiffDS = datestr(now);
                            save(getRelativePath(fileInfo.expList.status), 'fileInfo');
                        end
                        % Copy stage motion annotation to the NAS
                        if handles.preferences.nas
                            % && ~fileInfo.copyToNAS.stageMotion
                            copyToNAS(stageMotionFileName, fileInfo, handles.preferences.version, mydata.conn);
                            
                            fileInfo.copyToNAS.stageMotion = 1;
                            fileInfo.copyToNAS.stageMotionDS = datestr(now);
                            save(getRelativePath(fileInfo.expList.status), 'fileInfo');
                        end
                        % Copy failed frames to the NAS
                        if handles.preferences.nas
                            % && ~fileInfo.copyToNAS.failedFramesFile
                            copyToNAS(failedFramesFile, fileInfo, handles.preferences.version, conn);
                            
                            fileInfo.copyToNAS.failedFramesFile = 1;
                            fileInfo.copyToNAS.failedFramesFileDS = datestr(now);
                            save(getRelativePath(fileInfo.expList.status), 'fileInfo');
                        end
                        
                        if handles.preferences.nas
                            % && ~fileInfo.copyToNAS.segDat
                            % Copy segmentation results to the NAS
                            copyToNAS(segFileDir, fileInfo, handles.preferences.version, conn);
                            
                            fileInfo.copyToNAS.segDat = 1;
                            fileInfo.copyToNAS.segDatDS = datestr(now);
                            save(getRelativePath(fileInfo.expList.status), 'fileInfo');
                        end
                        
%                         % Copy overlay video to NAS
%                         if handles.preferences.videoOut
%                             if handles.preferences.nas
%                                 if ischar(fileInfo.copyToNAS.overlayAvi)
%                                     fileInfo.copyToNAS.overlayAvi = 0;
%                                 end
%                                 
%                                 [nasDestinationDir] = copyToNAS(outputVideoFile, fileInfo, handles.preferences.version, conn);
%                                 
%                                 %                              % Temporary seg overlay copy for easy checking
%                                 %                              if strcmp(tableName, 'victoriaExperimentList')
%                                 %                                  dirTempCopy = '\\nas207-1\Data\victoriaExperimentList\';
%                                 %                              else
%                                 %                                  dirTempCopy = '\\nas207-1\Data\1400_test\';
%                                 %                              end
%                                 %                              [~, ~] = copyfile(outputVideoFile, dirTempCopy);
%                                 
%                                 fileInfo.copyToNAS.overlayAvi = 1;
%                                 fileInfo.copyToNAS.overlayAviDS = datestr(now);
%                                 save(getRelativePath(fileInfo.expList.status), 'fileInfo');
%                             end
%                         end
%                         
%                         % We will delete the video file if we copied it over to the NAS
%                         if handles.preferences.deleteVideo
%                             if exist(outputVideoFile, 'file') == 2
%                                 delete(outputVideoFile);
%                             end
%                         end
%                         % Here we will raise a flag that overlayVideo has
%                         % successfully completed
%                         
%                         overlayVideo = 1;
                        
                        %                      % Temporary head and tail assignment stats copy for
                        %                      % easy checking
                        %                      if strcmp(tableName, 'victoriaExperimentList')
                        %                          dirTempCopy = '\\nas207-1\Data\victoriaExperimentList\';
                        %                      else
                        %                          dirTempCopy = '\\nas207-1\Data\1400_test\';
                        %                      end
                        %                      outputName = fullfile(fileInfo.expList.segDatDir, 'chunk_labels_new.csv');
                        %                      newOutputName = [dirTempCopy, fileInfo.expList.fileName,'_chunk_labels_new.csv'];
                        %                      copyfile(outputName, newOutputName);
                        
                    end
                catch ME1
                    
                    if globalQuitFlag
                        globalQuitFlag = 0;
                        return;
                    end                    
                    
                    msgString = getReport(ME1, 'extended','hyperlinks','off');
                    str1 = strcat('Database update for file',{' '},mydata.experimentList{mydata.currentFile}.fileName,{' '},'failed!',{' '},msgString);
                    set(handles.status1,'String',str1{1});
                    %write errorDrump
                    fprintf(processFid,'%s\n',mydata.experimentList{mydata.currentFile}.fileName);
                    fprintf(processFid,'%s\n',msgString);
                    
                    if handles.preferences.useDB
                        updateErrorTable(conn, unfinishedExpID, ['Database update failed!',msgString]);
                    end
                    
                    % Define error information
                    errorStr = msgString;
                    errorDescription = ['This error means that the major dadtabase update ',...
                        'step has not completed successfully. Please refer to the error signature ',...
                        'to get more information.'];
                    errorTag = 'main_database_update_error';
                    % Assign to error variable
                    errorIndex = errorIndex + 1;
                    errorData(errorIndex).errorTag = errorTag;
                    errorData(errorIndex).errorStr = errorStr;
                    errorData(errorIndex).errorDescription = errorDescription;
                    errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                    errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                    if ~handles.preferences.standalone && handles.preferences.useDB
                        errorData(errorIndex).dbID = unfinishedExpID;
                    else
                        errorData(errorIndex).dbID = [];
                    end
                    % Call error viewer
                    errorViewer(errorData(1:errorIndex));
                    % we call continue to exit the for loop and increase the
                    % number of errors
                    noOfErrors = noOfErrors + 1;
                    continue;
                end
            end
            %----------------------------------------------------------------------
            % start main diary again
            diary(diaryFilePath);
            
            %--------------------------------------------------------------------------
            % Feature extraction
            %--------------------------------------------------------------------------
            
            str1 = strcat('Progress bar: 3 out of', {' '}, num2str(pLen), {' '},'| Extracting features.');
            set(handles.status2,'String',str1{1});
            axes(handles.progressBar1);
            progressBarDat = (0:round((3/pLen)*100));
            color1=[0,51/255,102/255];
            fill([progressBarDat,progressBarDat(end),0],[ones(1,length(progressBarDat)),0,0],color1, 'FaceAlpha',0.95);
            xlim(handles.progressBar1,[1,100]);
            set(gca,'YTick',[]);
            set(gca,'XTick',[]);
            
            if handles.preferences.featureSet
                try
                    str1 = strcat('Feature extraction for file', {' '},...
                        mydata.experimentList{mydata.currentFile}.fileName,...
                        {' '}, 'started!', {' '});
                    set(handles.status1, 'String', str1{1});
                    drawnow;
                    fileInfo = featureProcess(hObject, eventdata, handles, fileInfo, tableName, conn);
                    features = 1;
                catch ME1
                    
                    if globalQuitFlag
                        globalQuitFlag = 0;
                        return;
                    end                    
                    
                    msgString = getReport(ME1, 'extended','hyperlinks','off');
                    str1 = strcat('Feature extraction for file', {' '}, mydata.experimentList{mydata.currentFile}.fileName, {' '}, 'failed!', {' '}, msgString);
                    set(handles.status1, 'String', str1{1});
                    %write errorDrump
                    fprintf(processFid, '%s\n', mydata.experimentList{mydata.currentFile}.fileName);
                    fprintf(processFid, '%s\n', msgString);
                    
                    if handles.preferences.useDB
                        updateErrorTable(conn, unfinishedExpID, ['Feature extraction failed!',msgString]);
                        msgString = [msgString,'DBid:',num2str(unfinishedExpID)]; %#ok<AGROW>
                    end
                    
                    % Define error information
                    errorStr = msgString;
                    errorDescription = ['This error means that the major pipeline ',...
                        'step - feature extraction - has not completed successfully. ',...
                        'Please refer to the error signature to get more information.'];
                    errorTag = 'feature_extraction_error';
                    % Assign to error variable
                    errorIndex = errorIndex + 1;
                    errorData(errorIndex).errorTag = errorTag;
                    errorData(errorIndex).errorStr = errorStr;
                    errorData(errorIndex).errorDescription = errorDescription;
                    errorData(errorIndex).dir = mydata.experimentList{i}.dir;
                    errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
                    if ~handles.preferences.standalone && handles.preferences.useDB
                        errorData(errorIndex).dbID = unfinishedExpID;
                    else
                        errorData(errorIndex).dbID = [];
                    end
                    % Call error viewer
                    errorViewer(errorData(1:errorIndex));
                    
                    features = 0;
                    % We call continue to exit the for loop and go to the
                    % cleanup step. We increase the number of errors
                    noOfErrors = noOfErrors + 1;
                    continue;
                end
            else
                str1 = strcat('Feature calculation was disabled in preferences!');
                set(handles.status1,'String',str1);
            end
            
            % Close error log file
            fclose(processFid);
            if handles.preferences.nas
                copyToNAS(errorLogFile, fileInfo, handles.preferences.version, conn);
            end
            % Close diary file
            diary off;
            if handles.preferences.nas
                copyToNAS(diaryFilePath, fileInfo, handles.preferences.version, conn);
            end
            % Finished file counter increase
            finishedFileCounter = finishedFileCounter + 1;
            
            % Label experiment as completed
            completed = 1;
            % Update error table
            if handles.preferences.useDB && completed
                sqlString = strcat('DELETE from errors where id = ', num2str(unfinishedExpID), ';');
                curs = exec(conn, sqlString);
                curs = fetch(curs);
                close(curs);
            end
            
            % Reduce the number of experiments to finish
            if handles.preferences.standalone
                experimentsToFinish = experimentsToFinish - 1;
            end
        end
        %         % if we are running standalone analysis then we need to terminate while
        %         % loop when it finished what was selected
        %         if handles.preferences.standalone
        %             experimentsToFinish = 0;
        %         end
    catch ME1
        % Here experiment analysis failed somewhere between the main
        % functions in the pipeline
        
        if globalQuitFlag
            globalQuitFlag = 0;
            return;
        end        
        
        msgString = getReport(ME1, 'extended','hyperlinks','off');
        
        if handles.preferences.useDB
            updateErrorTable(conn, unfinishedExpID, ['Pipeline failed!',msgString]);
        end
        
        % Define error information
        errorStr = msgString;
        errorDescription = ['This error means that the pipeline ',...
            'encoutnered an issue and failed for this experiment. ',...
            'It will attempt to continue with other experiments that ',...
            'were specified in this run. Please refer to the error signature to get more information.'];
        errorTag = 'pipeline_error';
        % Assign to error variable
        errorIndex = errorIndex + 1;
        errorData(errorIndex).errorTag = errorTag;
        errorData(errorIndex).errorStr = errorStr;
        errorData(errorIndex).errorDescription = errorDescription;
        if exist('mydata','var')
            errorData(errorIndex).dir = mydata.experimentList{i}.dir;
            errorData(errorIndex).fileName = mydata.experimentList{i}.fileName;
        end
        if ~handles.preferences.standalone && handles.preferences.useDB
            errorData(errorIndex).dbID = unfinishedExpID;
        else
            errorData(errorIndex).dbID = [];
        end
        % Call error viewer
        errorViewer(errorData(1:errorIndex));
        % continue will not need to be called here because the code below
        % will be the next to be executed
        noOfErrors = noOfErrors + 1;
    end
    
    % Here we update database - if experiment didnt fail, say that its
    % completed. if not completed, return taken back to 0.
    if handles.preferences.useDB
        taken = 0;
        
        colnames = {'taken','completed'};
        exdata = {taken, completed};
        
        if handles.preferences.featureSet
            % If prefernece to extract features was selected
            colnames = {'taken','features'};
            exdata = {taken, features};
        elseif handles.preferences.normalize
            % If prefernece to normalize was selected
            colnames{end+1} = 'vulvasideCorrected'; %#ok<AGROW>
            exdata{end+1} = vulvasideCorrected; %#ok<AGROW>
        elseif handles.preferences.featureSet &&  handles.preferences.normalize
            % If both preferneces - features and normalize were selected
                colnames{end+1} = 'completed'; %#ok<AGROW>
                exdata{end+1} = completed; %#ok<AGROW>
        elseif handles.preferences.runOnCompleted
            % If prefernece to run only on completed was selected
            if handles.preferences.videoOut
                colnames = {'taken','overlayVideo'};
                exdata = {taken, overlayVideo};
            end
        else
            %
        end
        
        whereClause = ['where id = ',num2str(unfinishedExpID)];
        update(conn, tableName, colnames, exdata, whereClause);
    end
end

% Close all open file handles
fclose('all');

if handles.preferences.useDB
    % Close database connection
    close(conn);
end

str1 = '';
set(handles.fileList, 'String', str1);
% Output completion string
str1 = strcat('Analysis for', {' '}, num2str(finishedFileCounter), {' '},'files has been completed.');
set(handles.status1,'String',str1{1});

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
[dirListFileName,    dirListPath] = uigetfile;
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
% Custom Functions
%--------------------------------------------------------------------------

%here we will close the GUI correctly
function closeGUI(hObject, evntdata)
% Src is the handle of the object generating the callback (the source of the event)
% Evnt is the The event data structure (can be empty for some callbacks)

global globalQuitFlag;

mydata = guidata(hObject);
selection = questdlg('Do you want to close worm analysis toolbox progress window?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection
    case 'Yes',
        
        globalQuitFlag = 1;
        if ~isfield(mydata, 'aviHandle')
            %flag1 = str2double(get(mydata.exitFlag,'String'));
            %if flag1
            %else
            %    errordlg('Please stop the analysis first!','Analysis status');
            %end
        end
        delete(hObject);
        sprintf('progress:terminatedByUser, User has terminated analysis loop.');
    case 'No'
        return;
end

function expList = parseExperimentList(fileListTxt, hObject, eventdata, handles)
% This function gets file list as an input. It can be a dat file list or avi
% file list. The output of this function is a cell object that as elements
% contains the tracking experiments.Variable expList will contain locations
% of key experiment files and they will be used throughout the pipeline.

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
