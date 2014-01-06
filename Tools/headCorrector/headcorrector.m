function varargout = headcorrector(varargin)
% HEADCORRECTOR M-file for headcorrector.fig
%      HEADCORRECTOR, by itself, creates a new HEADCORRECTOR or raises the existing
%      singleton*.
%
%      H = HEADCORRECTOR returns the handle to a new HEADCORRECTOR or the handle to
%      the existing singleton*.
%
%      HEADCORRECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEADCORRECTOR.M with the given input arguments.
%
%      HEADCORRECTOR('Property','Value',...) creates a new HEADCORRECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before headcorrector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to headcorrector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help headcorrector
% Last Modified by GUIDE v2.5 27-Sep-2011 18:14:19

% the functions in this file are in the rough order: initialization, seeking, play-pause, opening a video, and actually changing data

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @headcorrector_OpeningFcn, ...
    'gui_OutputFcn',  @headcorrector_OutputFcn, ...
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



% --- Executes just before headcorrector is made visible.
function headcorrector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventfdata  reserved - to be defined in a future version of MATLAB

% varargin   command line arguments to headcorrector (see VARARGIN)


%set(handles.stopButton, 'value', 1.0) %start off paused
set(handles.playButton, 'value', 0.0)

% Choose default command line output for headcorrector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%set up to share with videoSelector
%setappdata(0, 'hMainGui', gcf);
setappdata(0, 'hMainGui', handles);

hMainGui = getappdata(0, 'hMainGui');

setappdata(handles.figure1, 'fhLoadVideo', @loadVideo);
setappdata(hMainGui.figure1, 'threshold', num2str(get(handles.thresholdField, 'value')));

% UIWAIT makes headcorrector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = headcorrector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure



% Get default command line output from handles structure
varargout{1} = handles.output;







%These two functions move to the next of previous chunk when the corresponding button is pressed
function NextChunkButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if isfield(mydata, 'aviHandle') && isfield(mydata, 'chunktimes')
    
    if ~strcmp(get(handles.statusText, 'string'), 'Seeking')
        %find the first chunk whose start frame is after the current one, and seek
        %to it
        for c=1:length(mydata.chunktimes)
            if mydata.currentFrame < mydata.chunktimes(c)
                seekAndUpdate(handles, mydata.chunktimes(c))
                break
            end
        end
    end
    
end

function PrevChunkButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if isfield(mydata, 'aviHandle') && isfield(mydata, 'chunktimes')
    
    if ~strcmp(get(handles.statusText, 'string'), 'Seeking')
        c=1;
        while (mydata.chunktimes(c+1) < mydata.currentFrame) && (c+1 < length(mydata.chunktimes))
            c=c+1;
        end
        
        seekAndUpdate(handles, mydata.chunktimes(c))
    end
    
end


%This callback controls seeking to a particular frame number
function desiredFrame_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if isfield(mydata, 'aviHandle')
    desiredFrame=str2num(get(handles.desiredFrame, 'String'));
    
    if ~strcmp(get(handles.statusText, 'string'), 'Seeking')
        %if the desiredFrame is within the video, seek to it
        %otherwise reset the speed
        if desiredFrame < get(mydata.aviHandle, 'numFrames')
            seekAndUpdate(handles, desiredFrame);
        else
            set(handles.desiredFrame, 'String', '0');
        end
    end
end

function desiredFrame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%skips to the corresponding time in the video when the progress bar is clicked on
function chunkBar_ButtonDownFcn(hObject, eventdata, handles)
mydata = guidata(hObject);
point = get(handles.chunkBar, 'Currentpoint');

%only seek if we've loaded chunk-times, and hence activated the chunkBar
if isfield(mydata, 'chunktimes')
    selectedFrame = round(point(1,1) * get(mydata.aviHandle, 'numFrames') / mydata.chunkBarTotalLength);
    seekAndUpdate(handles, selectedFrame)
end


%skips to the corresponding time in the video when the zoomed progress bar is clicked on
function zoomedChunkBar_ButtonDownFcn(hObject, eventdata, handles)

mydata=guidata(handles.openButton);
point = get(handles.zoomedChunkBar, 'Currentpoint');

%only seek if we've loaded chunk-times, and hence activated the chunkBar
if isfield(mydata, 'chunktimes')
    
    %work out what the centerChunk is
    centerChunk = mydata.currentChunk;
    
    if centerChunk == 1
        centerChunk = 2;
    elseif centerChunk == length(mydata.chunktimes)
        centerChunk = centerChunk - 2;
    elseif centerChunk == length(mydata.chunktimes)-1
        centerChunk = centerChunk - 1;
    end
    
    
    %the total number of frames represented by the bar
    numFrames = (mydata.chunktimes(centerChunk + 2) -  mydata.chunktimes(centerChunk - 1));
    
    selectedFrame = round(point(1,1) * numFrames / mydata.zoomedChunkBarTotalLength) + mydata.chunktimes(centerChunk-1);
    seekAndUpdate(handles, selectedFrame);
end





% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
mydata = guidata(hObject);
rate=str2num(get(handles.playbackSpeed, 'String'));
currentFrame = mydata.currentFrame;

%without this if-statement, hitting a key too fast would cause a crash
if ~strcmp(get(handles.statusText, 'string'), 'Seeking')
    
    %identify the key pressed; calculate which frame to move to
    keypressed=strcat(eventdata.Key);
    if strcmp(keypressed, 'leftarrow')
        targetframe = currentFrame - 1*rate;
        seekAndUpdate(handles, targetframe);
    elseif strcmp(keypressed,'rightarrow')
        targetframe = currentFrame + 1*rate;
        seekAndUpdate(handles, targetframe);
    elseif strcmp(keypressed,'downarrow')
        targetframe = currentFrame - 5*rate;
        seekAndUpdate(handles, targetframe);
    elseif strcmp(keypressed, 'uparrow')
        targetframe = currentFrame + 5*rate;
        seekAndUpdate(handles, targetframe);
        
        %if the space-bar were pressed, simulate pressing Play/Pause
        %by flipping its 'value' and calling its callback
    elseif strcmp(keypressed, 'space')
        
        if get(handles.playButton, 'value') == 0.0
            set(handles.playButton, 'value', 1.0)
        else
            set(handles.playButton, 'value', 0.0)
        end
        
        playButton_Callback(handles.playButton, 0, handles)
        
    end
    
end

%This function seeks to a particular frame, the updates the display, frame-count and chunkBar
function seekAndUpdate(handles, targetFrame)
mydata = guidata(handles.figure1);

currentFrame=mydata.currentFrame;

%temporarily pause the video if it was playing
%wasPlaying=0;
%if get(mydata.playButton, 'value') == 1
%    playButton_Callback(handles.playButton, 0, handles);
%    wasPlaying = 1;
%end


if (targetFrame < get(mydata.aviHandle, 'numFrames')) && (targetFrame>0)
    
    %seek
    while (targetFrame >= 0)
        seek(mydata.aviHandle, targetFrame-1);
        set(handles.statusText, 'string', '');
        
        %get the approxFrameNumber
        if ispc
            timestamp = get(mydata.aviHandle, 'timeStamp');
            fps = get(mydata.aviHandle, 'fps');
            curFrame2 = round(timestamp * fps);
        else
            curFrame2 = get(mydata.aviHandle, 'approxFrameNum')+1;
        end
        
        if (curFrame2>=currentFrame) && (targetFrame < currentFrame)
            targetFrame = targetFrame - 1; %if we ended up where we were, try seeking back further
        else
            break
        end
        
    end
    
    
    %get the new frame number
    if ispc
        timestamp = get(mydata.aviHandle, 'timeStamp');
        fps = get(mydata.aviHandle, 'fps');
        currentFrame = round(timestamp * fps);
    else
        currentFrame = get(mydata.aviHandle, 'approxFrameNum')+1;
    end
    
    mydata.currentFrame = currentFrame;
    
    %get the current chunk number
    if isfield(mydata, 'chunktimes')
        
        for chunk=1:length(mydata.chunktimes)
            if chunk==length(mydata.chunktimes)-1
                break
            elseif currentFrame < mydata.chunktimes(chunk+1)
                break
            end
        end
        
        if chunk ~= mydata.currentChunk
            %save the new currentChunk and redraw the zoomed chunk bar
            mydata.currentChunk = chunk;
            guidata(handles.figure1, mydata);
            
            drawZoomedChunkBar(handles);
        end
        
        %update the progress bar
        set(mydata.positionMarker, 'Position', [currentFrame * mydata.chunkBarTotalLength / get(mydata.aviHandle, 'numFrames'), 0, mydata.chunkBarLength, mydata.chunkBarHeight]);
        updateZoomedProgress(handles);
        
        
    end
    
    
    %make sure the new frame number is saved
    guidata(handles.figure1, mydata);
    
    
    mydata = guidata(handles.figure1);
    
    %update frame number
    set(handles.frameText, 'string', ['Frame ' num2str(currentFrame) '/' num2str(mydata.aviInfo.numFrames)]);
    
    %display the frame
    imOrig=rgb2gray(getframe(mydata.aviHandle));
    
    %overlay the worm struct
    if isfield(mydata, 'worm')
        if ~isempty(mydata.worm(currentFrame).contour)
            imOrig = overlayWormAnglesSimple(imOrig, mydata.worm(currentFrame));
        end
    end
    
    
    axes(handles.axes1)
    imshow(imOrig);
    
    %superimpose the markers for the head and vulva
    if isfield(mydata, 'headPosition')
        hold on;
        plot(mydata.headPosition(currentFrame, 1), mydata.headPosition(currentFrame, 2), 'sg')
        plot(mydata.vulvaPosition(currentFrame, 1), mydata.vulvaPosition(currentFrame, 2), 'sr')
        hold off;
    end
    
    %update the progress bars
    %if isfield(handles, 'chunktimes')
    %    set(mydata.positionMarker, 'Position', [get(mydata.aviHandle, 'approxFrameNum') * mydata.chunkBarTotalLength / get(mydata.aviHandle, 'numFrames'), 0, mydata.chunkBarLength, mydata.chunkBarHeight]);
    %    updateZoomedProgress(handles);
    %end
    
    %if wasPlaying == 1
    %playButton_Callback(handles.playButton, 0, handles);
    %end    


    
    guidata(handles.figure1, mydata);
end







%The playback-speed callback doens't do anything, as the speed is polled from the main play loop
function playbackSpeed_Callback(hObject, eventdata, handles)

function playbackSpeed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







%These functions make the play and pause buttons work

function playButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if isfield(mydata, 'aviHandle') %check a video file has been loaded
    
    %Toggle the label and indentation on the Play/Pause switch
    if get(handles.playButton, 'value') == 0.0
        set(handles.playButton, 'String', 'Play')
    else
        set(handles.playButton, 'value', 1.0)
        set(handles.playButton, 'String', 'Pause')
    end
    
    %default rate is 1
    rate = 1;
   
    
    %get the approxFrameNumber
    if ispc
        %get current and last frame number
        numFrames = get(mydata.aviHandle, 'numFrames') +  double(get(mydata.aviHandle, 'nHiddenFinalFrames')); 
       
        timestamp = get(mydata.aviHandle, 'timeStamp');
        fps = get(mydata.aviHandle, 'fps');
        approxFrameNum = round(timestamp * fps);
    else
        %get current and last frame number
        numFrames = get(mydata.aviHandle, 'numFrames');
        approxFrameNum = get(mydata.aviHandle, 'approxFrameNum')+1;
    end
    
    %until pause is pressed, keeping putting up new frames
    while (get(handles.playButton, 'value') == 1.0) && (approxFrameNum < numFrames)
        if next(mydata.aviHandle)
            
            rate=str2num(get(handles.playbackSpeed, 'String'));
            
            %skip forward by (rate-1) frames, since we've already advanced one
            %if this would throw us past the end of the video, slow down and
            %display frames one at a time
            targetframe=approxFrameNum+rate-1;
            
            if targetframe < get(mydata.aviHandle, 'numFrames')
                seek(mydata.aviHandle, targetframe);
            else
                set(handles.playbackSpeed, 'String', '1'); %show that we've slowed down to one frame at a time
            end
            
            
            %get the approxFrameNumber
            if ispc
                timestamp = get(mydata.aviHandle, 'timeStamp');
                fps = get(mydata.aviHandle, 'fps');
                approxFrameNum = round(timestamp * fps);
            else
                %get new frame number
                approxFrameNum = get(mydata.aviHandle, 'approxFrameNum')+1;
            end
            
            %display new frame number
            set(handles.frameText, 'String', ['Frame ' num2str(approxFrameNum) '/' num2str(numFrames)]);
            
            %store updated currentFrame
            mydata.currentFrame=approxFrameNum;
            guidata(hObject, mydata);
            
            %if we've entered a new chunk, save the new currentChunk, and
            %redraw the zoomed chunk bar
            if isfield(mydata, 'chunktimes')
                if mydata.currentChunk < length(mydata.chunktimes)
                    if approxFrameNum >= mydata.chunktimes(mydata.currentChunk+1)
                        
                        mydata = guidata(hObject);
                        mydata.currentChunk = mydata.currentChunk + 1;
                        guidata(hObject, mydata);
                        
                        if isfield(mydata, 'chunktimes')
                            drawZoomedChunkBar(handles);
                        end
                        
                    end
                end
            end
            
            mydata = guidata(hObject);
            
            
            %get the frame
            imOrig = rgb2gray(getframe(mydata.aviHandle));
            
            %superimpose the worm struct
            if isfield(mydata, 'worm')
                if ~isempty(mydata.worm(approxFrameNum).contour)
                    imOrig = overlayWormAnglesSimple(imOrig, mydata.worm(approxFrameNum));
                end
            end
            
            %plot the frame
            axes(handles.axes1)
            imshow(imOrig)
            
            
            %superimpose the markers for the head and vulva
            if isfield(mydata, 'vulvaPosition')
                hold on;
                plot(mydata.vulvaPosition(approxFrameNum, 1), mydata.vulvaPosition(approxFrameNum, 2), 'sr')
                plot(mydata.headPosition(approxFrameNum, 1), mydata.headPosition(approxFrameNum, 2), 'sg')
                hold off;
            end
            
            %update progress bars
            if isfield(handles, 'chunktimes')
                
                set(mydata.positionMarker, 'Position', [approxFrameNum * mydata.chunkBarTotalLength / numFrames, 0, mydata.chunkBarLength, mydata.chunkBarHeight]);
                updateZoomedProgress(handles);
            end
        else
            set(handles.playButton, 'value', 0.0);
            break;
        end
    end
end

% --- Executes on button press in openButton.
function openButton_Callback(hObject, eventdata, handles)
mydata = guidata(handles.figure1);

%set mydata.useDB to store whether we were in offline mode *when the video
%loaded*
if get(handles.dataDBCheckbox, 'Value') == 1
    mydata.useDB = 1;
    error('database details missing')

    mydata.conn = database;
else
    mydata.useDB = 0;
end

%set mydata.plotWholeWorm
if get(handles.minimalPlotCheckbox, 'Value') == 1
    mydata.plotWholeWorm = 0;
else
    mydata.plotWholeWorm = 1;
end

guidata(handles.figure1, mydata);

%use the oter checkox to determine whether to open a uigetfile dialog or
%the videoSelector database interface
if get(handles.searchDBCheckbox, 'Value') == 0
    
    %get the full path to a manually selected file
    [file, path] = uigetfile('.avi');
    
    if ~(isequal(file,0) || isequal(path,0) )
        
        mydata.videoPath = [path, file];
        
        %keep track of whether we failed to load files needed to superimpose
        %points or present chunks
        mydata.headTailReady = 1;
        mydata.chunkReady = 1;
        
        %guess the other paths
        [pathstr, name, ext] = fileparts(mydata.videoPath);
        mydata.dataPath = [regexprep(pathstr, 'experiment$', ['segmentation' filesep 'normalized']) filesep name] ;
        mydata.segNormInfoPath = [mydata.dataPath '_segNormInfo.mat'];
        mydata.stageMotionPath = [ strrep(mydata.dataPath, ['segmentation' filesep 'normalized'], 'experiment') '_stageMotion.mat'];
        
        %check them
        if ~exist(mydata.segNormInfoPath, 'file')
            
            [file path] = uigetfile('.mat', 'Select the _segNormInfo.mat file (the block files must be in the same directory):');
            if ~(isequal(file,0) || isequal(path,0) )
                mydata.segNormInfoPath = [path file];
            else
                mydata.headTailReady = 0;
                mydata.chunkReady = 0;
            end
            
            %we also set dataPath, so it still points ot the block files
            [path, name, ext ] = fileparts(mydata.segNormInfoPath);
            if ~(isequal(file,0) || isequal(path,0) )
                name = strrep(name, '_segNormInfo', '');
                mydata.dataPath = [path filesep name];
            end
        end
        
        if ~exist(mydata.stageMotionPath, 'file')
            [file path] = uigetfile('.mat', 'Select the _stageMotion.mat file:');
            if ~(isequal(file,0) || isequal(path,0) )
                mydata.stageMotionPath = [path file];
            else
                mydata.headTailReady = 0;
            end
        end
        
        %save these paths
        guidata(handles.figure1, mydata);
        
        %open the video, unless 'Cancel' was pressed, and uigetfile = 0
        %todo: allow playback of jsut the video, without overlaid points
        %if any(mydata.videoPath)  && any(mydata.segNormInfoPath) && any(mydata.stageMotionPath)
        
        loadVideo(handles);
        %end
    end
    
else
    videoSelector(); %open GUI; loadVideo will be called when a selection is made
end


function loadVideo(handles)
hMainGui = getappdata(0, 'hMainGui');

%save the experiment id
mydata=guidata(handles.openButton);
mydata.experiment_id=getappdata(hMainGui.figure1, 'experiment');
guidata(handles.openButton, mydata);

mydata=guidata(handles.openButton);

% since a video has been selected, we can delete the old chunk/head/vulva dataand any old positionMarker . . .
if isfield(mydata, 'chunktimes')
    mydata=rmfield(mydata, 'chunktimes');
end

if isfield(mydata, 'vulvaPosition')
    mydata=rmfield(mydata, 'vulvaPosition');
end

if isfield(mydata, 'worm')
    mydata=rmfield(mydata, 'worm');
end

if isfield(mydata, 'headPosition')
    mydata=rmfield(mydata, 'headPosition');
end

if isfield(mydata, 'zoomedPositionMarker')
    mydata=rmfield(mydata, 'zoomedPositionMarker');
end


if mydata.useDB == 0
    
    %don't need to do anthing - paths set in openButton_Callback
    
else
    %for debugging, hard-code these values
    mydata.videoDir='/Users/jsb/Desktop/testing/';
    
    %mydata.videoPath = '/Users/jamesscott-brown/Desktop/4_James/test1/mod-1 (ok103)
    %on food R_2009_12_14__15_26_10___2___12.avi';
    guidata(handles.openButton, mydata);
    mydata = guidata(handles.openButton);
    
    %download the video, but first update the statusText to say so
    set(handles.statusText, 'String', 'Attempting to get video');
    refresh(headcorrector)
    
    %mydata.videoPath = downloadVideo(mydata.experiment_id, mydata.videoDir);
    mydata.videoPath = '/Users/jsb/Desktop/testing/ser-4 (ok512) on food R_2009_12_14__11_23_43___2___5.avi'
    set(handles.statusText, 'String', '');
    
    %video 4135:
    %mydata.videoPath = '/Volumes/data/experiments/ser-4/no strain/ok512/on_food/R/2009_12_14-11-23-43/.data/experiment/ser-4 (ok512) on food R_2009_12_14__11_23_43___2___5.avi'
    
    %video 9988
    %mydata.videoPath = '/Users/jamesscott-brown/Desktop/mec-4 (u253) off food x_2010_04_21__17_19_20__1.avi'
    
    %testing normalized chunks
    %mydata.videoPath = '/Volumes/data/experiments/trp-4/no strain/sy695/on_food/R/2010_04_23-11-21-52/.data/experiment/trp-4 (sy695) on food R_2010_04_23__11_21_52__5.avi';
    %mydata.experiment_id = '7470';
    
    %mydata.videoPath = '/Users/jsb/Desktop/2010_04_23-11-21-52/.data/experiment/trp-4 (sy695) on food R_2010_04_23__11_21_52__5.avi';
    %mydata.experiment_id = '7470';
    
end




try
    %load the video
    
    if ispc()
        vr = videoReader(mydata.videoPath, 'plugin', 'DirectShow'); %on windows, use Direct Show
    else
        vr = videoReader(mydata.videoPath, 'plugin', 'ffmpegDirect'); %on mac/linux, use ffmpegDirect
    end
    
    aviInfo = get(vr);
    mydata.aviInfo = aviInfo;
    
    %????
    aviInfo.Width = aviInfo.width;
    aviInfo.Height = aviInfo.height;
    aviInfo.NumFrames = aviInfo.numFrames;
    %
    
    numFrames = num2str(aviInfo.numFrames);
    cFrame = num2str(1);
    
    
    set(handles.frameText, 'String', ['Frame ' cFrame '/' numFrames]);
    
    
    %skip to second frame
    next(vr);
    next(vr);
    
    %vr is not accessible from other functons, so we
    aviInfo = get(vr);
    mydata.aviInfo = aviInfo;
    mydata.previousTimeStamp = aviInfo.timeStamp;
    
    mydata.aviHandle = vr;
    mydata.currentChunk = 1;
    mydata.currentFrame = 1; %TODO - think abou whether this is correct
    
    guidata(handles.openButton,mydata);
    
    %convert frame to greyscale
    imOrig = rgb2gray(getframe(mydata.aviHandle));
    
    %and display it
    axes(handles.axes1)
    imshow(imOrig)
    
    %display name of clip
    [path, name, exts] = FILEPARTS(mydata.videoPath)
    set(handles.clipNameField, 'String', name);
    
    if mydata.useDB == 0 && mydata.headTailReady == 1
        load(mydata.segNormInfoPath);
        
        %save the previous flip-status, or initialize cell arrays
        if exist('headFlips', 'var')
            mydata.headFlips = headFlips;
        else
            mydata.headFlips = cell(length(hAndtData), 1);
        end
        
        if exist('vulvaFlips', 'var')
            mydata.vulvaFlips = vulvaFlips;
        else
            mydata.vulvaFlips = cell(length(hAndtData), 1);
        end
        
        %save the number of blocks
        mydata.numBlocks = length(normBlockList);
    end
    
    
    %save this data
    guidata(handles.openButton, mydata);
    
    %get the start time for each chunk
    getChunkTimes(handles.openButton);
    
    %clear the two chunkBars
    cla(handles.chunkBar);
    cla(handles.zoomedChunkBar);
    
    mydata=guidata(handles.openButton);
    if isfield(mydata, 'chunktimes')
        %draw them
        drawChunkBar(handles);
        drawZoomedChunkBar(handles);
        
        %enable the chunk-related buttons
        set(handles.chunkViewedButton, 'enable', 'on');
        set(handles.videoViewedButton, 'enable', 'on');
        set(handles.mostUnreliableChunkButton, 'enable', 'on');
        set(handles.unreliableChunkButton, 'enable', 'on');
        set(handles.PrevChunkButton, 'enable', 'on');
        set(handles.NextChunkButton, 'enable', 'on');
        set(handles.splitChunkButton, 'enable', 'on');
        
    else
        %disable the chunk-related buttons
        set(handles.chunkViewedButton, 'enable', 'off');
        set(handles.videoViewedButton, 'enable', 'off');
        set(handles.mostUnreliableChunkButton, 'enable', 'off');
        set(handles.unreliableChunkButton, 'enable', 'off');
        set(handles.PrevChunkButton, 'enable', 'off');
        set(handles.NextChunkButton, 'enable', 'off');
        set(handles.splitChunkButton, 'enable', 'off');
        
        msgbox('Chunk data could not be loaded.');
    end
    
    
    
    %get the  head and vulva position vectors
    getHeadVulvaPosition(handles);
    
    mydata=guidata(handles.openButton);
    if isfield(mydata, 'vulvaPosition')
        %draw them
        drawChunkBar(handles);
        drawZoomedChunkBar(handles);
        
        %enable the head/vulva-related buttons
        set(handles.flipHead, 'enable', 'on');
        set(handles.flipVulva, 'enable', 'on');
        set(handles.proximityButton, 'enable', 'on');
        
    else
        %disable the head/vulva-related buttons
        set(handles.flipHead, 'enable', 'off');
        set(handles.flipVulva, 'enable', 'off');
        set(handles.proximityButton, 'enable', 'off');
        msgbox('Head/vulva positions could not be loaded.');
        
    end
    
    
    
    
    
    %mydata.chunkTimes='4135'; %TESTing
    
    mydata=guidata(handles.openButton);
    
    
    %reset the play button
    set(handles.playButton, 'value', 0.0);
    set(handles.playButton, 'string', 'Play');
    
catch ME1
    str1 = strcat('Loading failed!',{' '},ME1.stack(1).file,{' '},ME1.stack(1).name,{' '},num2str(ME1.stack(1).line));
    msgbox(str1{1});
end

%These functions control the actual toggling of the head-tail and vulval side buttons
function flipHead_Callback(hObject, eventdata, handles)
mydata=guidata(handles.openButton);

if isfield(mydata, 'aviHandle') && isfield(mydata, 'vulvaPosition')
    flipHead(handles, '');
end

function flipVulva_Callback(hObject, eventdata, handles)
mydata=guidata(handles.openButton);

if isfield(mydata, 'aviHandle') && isfield(mydata, 'headPosition')
    flipVulva(handles);
end








% This function splits a chunk
function splitChunkButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if isfield(mydata, 'aviHandle') && isfield(mydata, 'chunktimes')
    splitChunk(handles);
end





% --- Executes on button press in proximityButton.
function proximityButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

referenceFrame = mydata.currentFrame;
button_pressed=get(handles.playButton, 'Value');


%let the user know we're fliping; refresh also acts like a pause
set(handles.statusText, 'string', 'Flipping other frames to match this one')
refresh(headcorrector)

%actually do the flipping
autoFlipByProxmity(handles, referenceFrame);




%seek back to where we were
seek(mydata.aviHandle, referenceFrame);

%clear the statusText
set(handles.statusText, 'string', '')


%if the video was playing, start playing again
if button_pressed == 1.0
    set(handles.playButton, 'Value', 1.0)
    playButton_Callback(handles.playButton, 0, handles)
end


function dataDBCheckbox_Callback(hObject, eventdata, handles)
%do nothing - the change will take effect on next loading a video


% --- Executes on button press in unreliableChunkButton.
function unreliableChunkButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

%sort array of chunk numbers and reliability by reliability
order(:,1)=mydata.reliabilities;
order(:,2)=1:length(mydata.reliabilities);
sorted = sortrows(order);

%set chunk to the number of the current chunk
chunk = mydata.currentChunk;

%loop throgh the sorted array
%stop when we reach an equally unreliable chunk that comes later
%or any more reliable chunk
for c=1:length(sorted)
    if ( (sorted(c,1) == mydata.reliabilities(chunk)) && (mydata.chunktimes(sorted(c,2)) > mydata.chunktimes(chunk)) ) || (sorted(c,1) > mydata.reliabilities(chunk))
        seekAndUpdate(handles, mydata.chunktimes(sorted(c,2)) )
        break
    end
end


% --- Executes on button press in mostUnreliableChunkButton.
function mostUnreliableChunkButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

%sort array of chunk numbers and reliability by reliability
order(:,1)=mydata.reliabilities;
order(:,2)=1:length(mydata.reliabilities);
sorted = sortrows(order);

%seek to the start of the least reliable chunk
seekAndUpdate(handles, mydata.chunktimes(sorted(1,2)) )


% --- Executes on button press in chunkViewedButton.
function chunkViewedButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if mydata.useDB == 0
    
    %load hAndtData
    load(mydata.segNormInfoPath);
    
    
    %save its current state to allow undo
    if ~isfield(hAndtData{1}, 'viewed')
        for c=1:length(hAndtData)
            mydata.oldViewed(c)=0;
            hAndtData{c}.viewed=0; %thus all structs in the array will have field viewed
        end
    else
        for c=1:length(hAndtData)
            mydata.oldViewed(c)=hAndtData{c}.viewed;
        end
    end
    guidata(hObject, mydata);
    
    
    %update
    hAndtData{mydata.currentChunk}.viewed = 1;
    save(mydata.segNormInfoPath, 'hAndtData', '-append');
    
else
    
    %save current viewed state to allow undo
    query = ['SELECT viewed FROM main.wormmorphology WHERE experiment_id = ' num2str(mydata.experiment_id) ' ORDER BY start']
    curs = exec(mydata.conn, query);
    setdbprefs('DataReturnFormat','numeric');
    curs = fetch(curs, 100);
    
    if ~strcmp(curs.data(1), 'No Data')
        mydata.oldViewed = curs.data(:,1);
        mydata.oldViewed(isnan(mydata.oldViewed))=0; %replace NaN with 0
    end
    guidata(hObject, mydata);
    
    %do the update
    query = ['UPDATE main.wormmorphology SET viewed = 1 WHERE experiment_id = ' num2str(mydata.experiment_id) ' AND start = ' num2str(mydata.chunktimes(mydata.currentChunk))];
    curs = exec(mydata.conn, query);
    
end

%enable the undo button

set(handles.undoButton, 'Enable', 'on');



% --- Executes on button press in videoViewedButton.
function videoViewedButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if mydata.useDB == 0
    
    %load hAndtData
    load(mydata.segNormInfoPath);
    
    
    %save its current state to allow undo
    if ~isfield(hAndtData{1}, 'viewed')
        for c=1:length(hAndtData)
            mydata.oldViewed(c)=0;
            hAndtData{c}.viewed=0; %thus all structs in the array will have field viewed
        end
    else
        for c=1:length(hAndtData)
            mydata.oldViewed(c)=hAndtData{c}.viewed;
        end
    end
    guidata(hObject, mydata);
    
    
    %update
    for c=1:length(hAndtData)
        hAndtData{c}.viewed = 1;
    end
    
    save(mydata.segNormInfoPath, 'hAndtData', '-append');
    
else
    
    %save current viewed state to allow undo
    query = ['SELECT viewed FROM main.wormmorphology WHERE experiment_id = ' num2str(mydata.experiment_id) ' ORDER BY start']
    curs = exec(mydata.conn, query);
    setdbprefs('DataReturnFormat','numeric');
    curs = fetch(curs, 100);
    
    if ~strcmp(curs.data(1), 'No Data')
        mydata.oldViewed = curs.data(:,1);
        mydata.oldViewed(isnan(mydata.oldViewed))=0; %replace NaN with 0
    end
    guidata(hObject, mydata);
    
    
    %do the update
    query = ['UPDATE main.wormmorphology SET viewed = 1 WHERE experiment_id = ' num2str(mydata.experiment_id) ];
    curs = exec(mydata.conn, query);
    
end

%enable the undo button
set(handles.undoButton, 'Enable', 'on');


% --- Executes on button press in undoButton.
function undoButton_Callback(hObject, eventdata, handles)
mydata = guidata(hObject);

if mydata.useDB == 0
    
    load(mydata.segNormInfoPath);
    
    %revert to the previously saved hAndtData
    for c=1:length(mydata.oldViewed)
        hAndtData{c}.viewed = mydata.oldViewed(c);
    end
    save(mydata.segNormInfoPath, 'hAndtData', '-append');
    
else
    
    % get list of chunk IDs
    query = ['SELECT entryid FROM main.wormmorphology WHERE experiment_id = ' num2str(mydata.experiment_id) ' ORDER BY start'];
    curs = exec(mydata.conn, query);
    setdbprefs('DataReturnFormat','numeric');
    curs = fetch(curs, 100);
    
    
    if ~strcmp(curs.data(1), 'No Data')
        
        ids = curs.data(:);
        
        %for each chunk id, set viewed back how it was
        for c=1:length(mydata.oldViewed)
            hAndtData(c).viewed = mydata.oldViewed(c);
            query = ['UPDATE main.wormmorphology SET viewed = ' num2str(mydata.oldViewed(c)) ' WHERE entryid = ' num2str(ids(c))]
            curs = exec(mydata.conn, query);
        end
        
    end
    
end

%disable the undo button
set(handles.undoButton, 'Enable', 'off');


% Do nothing - changing searchDBCheckbox takes effect only on the next
% video load
function searchDBCheckbox_Callback(hObject, eventdata, handles)

% Do nothing - changing minimalPlotCheckbox takes effect only on the next
% video load
function minimalPlotCheckbox_Callback(hObject, eventdata, handles)



function thresholdField_Callback(hObject, eventdata, handles)
%re-color the two chunkBars
drawChunkBar(handles);
drawZoomedChunkBar(handles);

%save the vale so it is accessible to videoSelector
hMainGui=getappdata(0, 'hMainGui');
setappdata(hMainGui.figure1, 'threshold', num2str(get(handles.thresholdField, 'value')));

% --- Executes during object creation, after setting all properties.
function thresholdField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function returnVal = getValue(aviHandle, field)
    returnVal = double(get(aviHandle, field));
%
