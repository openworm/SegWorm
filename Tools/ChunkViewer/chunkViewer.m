function varargout = chunkViewer(varargin)
% CHUNKVIEWER MATLAB code for chunkViewer.fig
%      CHUNKVIEWER, by itself, creates a new CHUNKVIEWER or raises the existing
%      singleton*.
%
%      H = CHUNKVIEWER returns the handle to a new CHUNKVIEWER or the handle to
%      the existing singleton*.
%
%      CHUNKVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHUNKVIEWER.M with the given input arguments.
%
%      CHUNKVIEWER('Property','Value',...) creates a new CHUNKVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chunkViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chunkViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help chunkViewer

% Last Modified by GUIDE v2.5 25-Aug-2011 15:20:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @chunkViewer_OpeningFcn, ...
    'gui_OutputFcn',  @chunkViewer_OutputFcn, ...
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


% --- Executes just before chunkViewer is made visible.
function chunkViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chunkViewer (see VARARGIN)

% Choose default command line output for chunkViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chunkViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = chunkViewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in videoLoad.
function videoLoad_Callback(hObject, eventdata, handles)
% hObject    handle to videoLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadChunks.
function loadChunks_Callback(hObject, eventdata, handles)
% hObject    handle to loadChunks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopPlay,'UserData',0);
mydata = guidata(hObject);
[file, path] = uigetfile('.mat');
cd(path);
load(fullfile(path, file));
mydata.filePath = fullfile(path, file);
mydata.blockList = blockList;
mydata.hAndtData = hAndtData;
mydata.myAviInfo = myAviInfo;
mydata.currentChunk = 1;

chunkLen = length(mydata.hAndtData);
totalFrames = myAviInfo.numFrames + myAviInfo.nHiddenFinalFrames;
chunkPositions = ones(chunkLen, 2);
for i=1:chunkLen
    if i==chunkLen
        chunkEnd = totalFrames;
    else
        chunkEnd = mydata.hAndtData{i+1}.globalStartFrame;
    end
    chunkPositions(i,1) = mydata.hAndtData{i}.globalStartFrame;
    chunkPositions(i,2) = chunkEnd;
end

chunkEvaluation = ones(1,chunkLen);
mydata.chunkEvaluation = chunkEvaluation;
mydata.chunkPositions = chunkPositions;

guidata(hObject, mydata);

gotoChunkStart(hObject, eventdata, handles);
displayChunks(hObject, eventdata, handles);
set(handles.stopPlay,'UserData',1);

% --- Executes on button press in playChunk.
function playChunk_Callback(hObject, eventdata, handles)
% hObject    handle to playChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playCurrentChunk(hObject, eventdata, handles);


% --- Executes on button press in nextChunk.
function nextChunk_Callback(hObject, eventdata, handles)
% hObject    handle to nextChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopPlay,'UserData',0);
mydata = guidata(hObject);

chunkLen = length(mydata.hAndtData);

if mydata.currentChunk < chunkLen
    mydata.currentChunk = mydata.currentChunk + 1;
    guidata(hObject, mydata);
    
    %gotoChunkStart(hObject, eventdata, handles);
    set(mydata.chunkNo,'String',strcat('Chunk:', sprintf('%d',mydata.currentChunk)));
    displayChunks(hObject, eventdata, handles);
    set(handles.stopPlay,'UserData',1);
    %playCurrentChunk(hObject, eventdata, handles);
    textStr = strcat('Start:', {' '}, sprintf('%d',mydata.chunkPositions(mydata.currentChunk,1)), {', '},'End:',{' '},sprintf('%d',mydata.chunkPositions(mydata.currentChunk,2)));
    set(handles.text1, 'String', textStr{1});
end

guidata(hObject, mydata);


% --- Executes on button press in prevChunk.
function prevChunk_Callback(hObject, eventdata, handles)
% hObject    handle to prevChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopPlay,'UserData',0);
mydata = guidata(hObject);

chunkLen = length(mydata.hAndtData);

if mydata.currentChunk > 1
    mydata.currentChunk = mydata.currentChunk - 1;
    guidata(hObject, mydata);
    
    %gotoChunkStart(hObject, eventdata, handles);
    set(mydata.chunkNo,'String',strcat('Chunk:', sprintf('%d',mydata.currentChunk)));
    displayChunks(hObject, eventdata, handles);
    
    textStr = strcat('Start:', {' '}, sprintf('%d',mydata.chunkPositions(mydata.currentChunk,1)), {', '},'End:',{' '},sprintf('%d',mydata.chunkPositions(mydata.currentChunk,2)));
    set(handles.text1, 'String', textStr{1});
end

guidata(hObject, mydata);

% --- Executes on button press in correctChunk.
function correctChunk_Callback(hObject, eventdata, handles)
% hObject    handle to correctChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopPlay,'UserData',0);
mydata = guidata(hObject);
chunkEvaluation = mydata.chunkEvaluation;
chunkEvaluation(mydata.currentChunk) = 1;
mydata.chunkEvaluation = chunkEvaluation;
guidata(hObject, mydata);
%

% --- Executes on button press in wrongChunk.
function wrongChunk_Callback(hObject, eventdata, handles)
% hObject    handle to wrongChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stopPlay,'UserData',0);
mydata = guidata(hObject);
chunkEvaluation = mydata.chunkEvaluation;
chunkEvaluation(mydata.currentChunk) = 0;
mydata.chunkEvaluation = chunkEvaluation;
guidata(hObject, mydata);
%

function gotoChunkStart(hObject, eventdata, handles)
% hObject    handle to wrongChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
blockNameStr = mydata.hAndtData{mydata.currentChunk}.startBlock;
blockPath = strrep(mydata.filePath, 'segInfo', blockNameStr);
load(blockPath);
eval(['currentBlock=', blockNameStr,';']);
execString = strcat('clear(''',blockNameStr,''');');
eval(execString);
mydata.currentBlock = currentBlock;
guidata(hObject, mydata);

chunkStartFrame = mydata.hAndtData{mydata.currentChunk}.startFrame;
img = zeros(mydata.myAviInfo.height, mydata.myAviInfo.width);
worm = currentBlock{chunkStartFrame};

frameLabel = {'Not segmented','Stage movement'};

if iscell(worm)
    worm = cell2worm(worm);
    sImg = drawWorm(img, worm);
    imshow(sImg,'Parent',mydata.axes1);
    set(mydata.text1,'String',strcat('Frame no:',num2str(worm.video.frame+1)));
else
    img = zeros(mydata.myAviInfo.height, mydata.myAviInfo.width,3);
    imshow(img,'Parent',mydata.axes1);
    if ~isempty(worm)
        set(mydata.text1,'String', frameLabel{worm});
    else
        set(mydata.text1,'String', 'Dropped frame');
    end
end

set(mydata.chunkNo,'String',strcat('Chunk:', sprintf('%d',mydata.currentChunk)));
%guidata(hObject, mydata);
%


function displayChunks(hObject, eventdata, handles);
% hObject    handle to wrongChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
cla(handles.axes2);
axes(mydata.axes2);
hold on;

chunkLen = length(mydata.hAndtData);

colArray = [...
    0, 191/255, 255/255;
    0, 222/255, 209/255;
    0, 250/255, 154/255];

if mydata.currentChunk == 1
    if length(mydata.chunkPositions)>3
    xlim(handles.axes2, [1,mydata.chunkPositions(3,2)]);
    xlim(handles.axes3, [1,mydata.chunkPositions(3,2)]);
    end
    for i=1:3
        startChunk = mydata.chunkPositions(i,1);
        endChunk = mydata.chunkPositions(i,2);
        
        x1 = [startChunk, endChunk, endChunk, startChunk];
        y1 = [0, 0,   10, 10];
        fill(x1,y1, colArray(i,:), 'FaceAlpha',0.95);
        text(endChunk-(endChunk-startChunk)/1.5,5,sprintf('chunk %d',i));
    end
elseif mydata.currentChunk == length(mydata.hAndtData)
    %last chunk
    xlim(handles.axes2, [mydata.chunkPositions(end-2,1),mydata.chunkPositions(end,2)]);
    xlim(handles.axes3, [mydata.chunkPositions(end-2,1),mydata.chunkPositions(end,2)]);
    colourArrayIndex = 1;
    for i=chunkLen-2:chunkLen
        startChunk = mydata.chunkPositions(i,1);
        endChunk = mydata.chunkPositions(i,2);
  
        x1 = [startChunk, endChunk, endChunk, startChunk];
        y1 = [0, 0,   10, 10];
        fill(x1,y1, colArray(colourArrayIndex,:), 'FaceAlpha',0.95);
        text(endChunk-(endChunk-startChunk)/1.5,5,sprintf('chunk %d',i));
        colourArrayIndex = colourArrayIndex + 1;
    end
else
    %middle chunks
    currentChunk = mydata.currentChunk;
    xlim(handles.axes2, [mydata.chunkPositions(currentChunk-1,1),mydata.chunkPositions(currentChunk+1,2)]);
    xlim(handles.axes3, [mydata.chunkPositions(currentChunk-1,1),mydata.chunkPositions(currentChunk+1,2)]);
    colourArrayIndex = 1;
    for i=currentChunk-1:currentChunk+1
        startChunk = mydata.chunkPositions(i,1);
        endChunk = mydata.chunkPositions(i,2);
  
        x1 = [startChunk, endChunk, endChunk, startChunk];
        y1 = [0, 0,   10, 10];
        fill(x1,y1, colArray(colourArrayIndex,:), 'FaceAlpha',0.95);
        text(endChunk-(endChunk-startChunk)/1.5,5,sprintf('chunk %d',i));
        colourArrayIndex = colourArrayIndex + 1;
    end
end
hold off;
guidata(hObject, mydata);
%

% --- Executes on button press in wrongChunk.
function playCurrentChunk(hObject, eventdata, handles)
% hObject    handle to wrongChunk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
blockNameStr = mydata.hAndtData{mydata.currentChunk}.startBlock;
blockPath = strrep(mydata.filePath, 'segInfo', blockNameStr);
load(blockPath);
eval(['currentBlock=', blockNameStr,';']);
execString = strcat('clear(''',blockNameStr,''');');
eval(execString);
mydata.currentBlock = currentBlock;
guidata(hObject, mydata);

if isfield(mydata, 'currentBlock')
    chunkStartFrame = mydata.hAndtData{mydata.currentChunk}.startFrame;
    globalStartFrame = mydata.hAndtData{mydata.currentChunk}.globalStartFrame;
    if (chunkStartFrame + (mydata.chunkPositions(mydata.currentChunk, 2) - mydata.chunkPositions(mydata.currentChunk, 1))) < length(mydata.currentBlock)
        chunkLastFrame = chunkStartFrame + (mydata.chunkPositions(mydata.currentChunk, 2) - mydata.chunkPositions(mydata.currentChunk, 1));
    else
        chunkLastFrame = length(mydata.currentBlock);
    end
    
    img = zeros(mydata.myAviInfo.height, mydata.myAviInfo.width);
    frameLabel = {'Not segmented','Stage movement'};
    for i = chunkStartFrame:1:chunkLastFrame
        cla(handles.axes3);
        axes(mydata.axes3);
        hold on;
        x1 = [globalStartFrame-2, globalStartFrame+2, globalStartFrame+2, globalStartFrame-2];
        y1 = [0, 0,   5, 5];
        fill(x1,y1, [0.5,0.5,0.5], 'FaceAlpha',0.95);

        worm = mydata.currentBlock{i};
        if iscell(worm)
            worm = cell2worm(worm);
            sImg = drawWorm(img, worm);
            imshow(sImg,'Parent',mydata.axes1);
            set(mydata.text1,'String',strcat('Frame no:',num2str(worm.video.frame+1)));
        else
            %img = zeros(mydata.myAviInfo.height, mydata.myAviInfo.width,3);
            %imshow(img,'Parent',mydata.axes1);
            if ~isempty(worm)
                set(mydata.text1,'String', frameLabel{worm});
            else
                set(mydata.text1,'String', 'Dropped frame');
            end
        end
        drawnow;
        %pause(0.001);
        
        %check stop
        if ~get(handles.stopPlay,'UserData')
            set(handles.stopPlay,'UserData',1);
            return;
        end
        globalStartFrame = globalStartFrame +1;
    end
    hold on;
end
%


function sImg = drawWorm(img, worm)

% Construct a pattern to identify the head.
draw.ahImg = [1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1];
[draw.ahPattern(:,1) draw.ahPattern(:,2)] = find(draw.ahImg == 1);
draw.ahPattern(:,1) = draw.ahPattern(:,1) - ceil(size(draw.ahImg, 1) / 2);
draw.ahPattern(:,2) = draw.ahPattern(:,2) - ceil(size(draw.ahImg, 2) / 2);

% Construct a pattern to identify the vulva.
draw.avImg = [1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1; ...
    1 1 1 1 1];
[draw.avPattern(:,1) draw.avPattern(:,2)] = find(draw.avImg == 1);
draw.avPattern(:,1) = draw.avPattern(:,1) - ceil(size(draw.avImg, 1) / 2);
draw.avPattern(:,2) = draw.avPattern(:,2) - ceil(size(draw.avImg, 2) / 2);

% Choose the color scheme.
draw.blue = zeros(360, 3);
draw.blue(:,3) = 255;
draw.red = zeros(360, 3);
draw.red(:,1) = 255;
draw.acRGB = [draw.blue(1:90,:); jet(181) * 255; draw.red(1:90,:)]; % thermal
draw.asRGB = draw.acRGB;
%asRGB = [blue(1:90,:); jet(181) * 255; red(1:90,:)]; % thermal
draw.asRGBNaN = [255 0 0]; % red
draw.ahRGB = [0 255 0]; % green
draw.isAHOpaque = 1;
draw.avRGB = [255 0 0]; % red
draw.isAVOpaque = 1;


sImg = overlayWormAngles(img, worm, draw.acRGB, ...
    draw.asRGB, draw.asRGBNaN, draw.ahPattern, draw.ahRGB, draw.isAHOpaque, ...
    draw.avPattern, draw.avRGB, draw.isAVOpaque);


% --- Executes on button press in stopPlay.
function stopPlay_Callback(hObject, eventdata, handles)
% hObject    handle to stopPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'UserData',0);


% --- Executes on button press in saveResult.
function saveResult_Callback(hObject, eventdata, handles)
% hObject    handle to saveResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
chunkLabels = mydata.chunkEvaluation;
resultFile = strrep(mydata.filePath,'segInfo','chunkLabels');
save(resultFile,'chunkLabels');
mydata.resultFile = resultFile;
mydata.chunkLabels = chunkLabels;
guidata(hObject, mydata);


% --- Executes on button press in chunkLabelsOutput.
function chunkLabelsOutput_Callback(hObject, eventdata, handles)
% hObject    handle to chunkLabelsOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
load(mydata.filePath,'hAndtData', 'myAviInfo');
resultFile = strrep(mydata.filePath, 'segInfo', 'chunkLabels');
load(resultFile,'chunkLabels');
[warningLevels] = chunkWarningLevels(hAndtData, myAviInfo, mydata.filePath, 0);
guidata(hObject, mydata);