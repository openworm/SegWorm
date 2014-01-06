function varargout = wormDiagnostics(varargin)
%WORMDIAGNOSTICS M-file for wormDiagnostics.fig
%      WORMDIAGNOSTICS, by itself, creates a new WORMDIAGNOSTICS or raises the existing
%      singleton*.
%
%      H = WORMDIAGNOSTICS returns the handle to a new WORMDIAGNOSTICS or the handle to
%      the existing singleton*.
%
%      WORMDIAGNOSTICS('Property','Value',...) creates a new WORMDIAGNOSTICS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wormDiagnostics_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WORMDIAGNOSTICS('CALLBACK') and WORMDIAGNOSTICS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WORMDIAGNOSTICS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Edit the above text to modify the response to help wormDiagnostics

% Last Modified by GUIDE v2.5 29-May-2012 00:34:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wormDiagnostics_OpeningFcn, ...
                   'gui_OutputFcn',  @wormDiagnostics_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before wormDiagnostics is made visible.
function wormDiagnostics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for wormDiagnostics
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wormDiagnostics wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = wormDiagnostics_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vidNameIn = get(handles.vidPath,'String');
lastFrame = get(handles.totalFrames,'String');
lastFrameNum = str2double(lastFrame);

cFrame = get(handles.currentFrame,'String');
cFrameNum = str2double(cFrame);

if ~isempty(vidNameIn) && cFrameNum <= lastFrameNum

    cFrameNum2 = cFrameNum+1;
    cFrame2 = num2str(cFrameNum2);
    set(handles.currentFrame,'String',cFrame2);
    [res] = showImg(hObject, eventdata, handles);
end
%end nextButton -------------------------------

% --- Executes on button press in prevButton.
function prevButton_Callback(hObject, eventdata, handles)
% hObject    handle to prevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vidNameIn = get(handles.vidPath,'String');

cFrame = get(handles.currentFrame,'String');
cFrameNum = str2double(cFrame);

if ~isempty(vidNameIn) && cFrameNum >= 2

    cFrameNum2 = cFrameNum-1;
    cFrame2 = num2str(cFrameNum2);
    set(handles.currentFrame,'String',cFrame2);
    [res] = showImg(hObject, eventdata, handles);
end
%end prevButton ------------------------------


function gotoFrameX_Callback(hObject, eventdata, handles)
% hObject    handle to gotoFrameX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gotoFrameX as text
%        str2double(get(hObject,'String')) returns contents of gotoFrameX as a double
vidNameIn = get(handles.vidPath,'String');
lastFrame = get(handles.totalFrames,'String');
gotoFrame = get(handles.gotoFrameX,'String');

lastFrameNum = str2double(lastFrame);
gotoFrameNum = str2double(gotoFrame);

if ~isempty(vidNameIn) && gotoFrameNum >= 1 && gotoFrameNum <= lastFrameNum
    cFrameNum = gotoFrameNum;
    cFrameStr = num2str(cFrameNum);
    set(handles.currentFrame,'String',cFrameStr);
    [res] = showImg(hObject, eventdata, handles);
end
%end gotoFrameX --------------------

% --- Executes during object creation, after setting all properties.
function gotoFrameX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gotoFrameX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function vidPath_Callback(hObject, eventdata, handles)
% hObject    handle to vidPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vidPath as text
%        str2double(get(hObject,'String')) returns contents of vidPath as a double


% --- Executes during object creation, after setting all properties.
function vidPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vidPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in openVid.
function openVid_Callback(hObject, eventdata, handles)
% hObject    handle to openVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
if isfield(mydata, 'aviHandle')
    close(mydata.aviHandle);
end


[fname, pname] = uigetfile('*.*','Enter video file.');
if (fname ~= 0)
    vidNameIn = fullfile(pname,fname);
    set(handles.vidPath,'String', vidNameIn);
end

set(handles.playButton, 'Value', 0);

if ~isempty(vidNameIn)

try
    vr = videoReader(vidNameIn, 'plugin', 'DirectShow');
catch ME1
    msgString = getReport(ME1, 'extended','hyperlinks','off');
    str1 = strcat('Video cant be opened.',{' '},vidNameIn,{' '},'Error message:',msgString ,{' '},'Please restart.');
    set(handles.status1,'String',str1{1});
end

% get the vignette
[fname, pname] = uigetfile('*.*','Enter vignette file.');
if ischar(fname) && ischar(pname)
    vFile = fullfile(pname,fname);
else
    vFile = '';
end

% This section will load vignette
%--------------------------------------------------------------------------
vignetteFile = vFile;
vImg = [];
try
    if exist(vignetteFile, 'file')
        fid = fopen(vignetteFile, 'r');
        vImg = fread(fid, [640 480],'int32=>int8', 0, 'b')';
        fclose(fid);
        
    end
catch ME12
    msgString = getReport(ME12, 'extended','hyperlinks','off');
    str1 = strcat('Module2 can not open vignette data file.',{' '},vignetteFile,{' '},'Error message:',msgString ,{' '},'Not applying vignette correction.');
    set(handles.status1,'String',str1{1});
end

vrBackground = 0;
isDebugVideo = 1;
fps = get(vr, 'fps');
myAviInfo = get(vr);
spf = 1 / fps;
totalFrames = get(vr, 'numFrames') + get(vr, 'nHiddenFinalFrames');

isGray = false;
isVideoFrame = next(vr);
if isVideoFrame
    img = getframe(vr);
    if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
        isGray = true;
    end
end

if isGray
    img = getframe(vr);
    img = img(:,:,1);
else
    img = rgb2gray(getframe(vr));
end

% Correct the vignette.
if ~isempty(vImg)
    img = uint8(single(img) - single(vImg));
end

    %this will set the exit button to call closeGUI function
    set(handles.figure1, 'CloseRequestFcn', @closeGUI);

    
    
    set(handles.totalFrames, 'String', num2str(totalFrames));
    cFrame = num2str(1);
    set(handles.currentFrame, 'String', cFrame);
    
    mydata = guidata(hObject);
    mydata.aviHandle = vr;
    mydata.myAviInfo = myAviInfo;
    mydata.isGray = isGray;
    mydata.fps = fps;
    mydata.vImg = vImg;
    mydata.displayHandle = [];
    mydata.originalHandles = findall(0,'type','figure');
    guidata(hObject,mydata); 
    
    [res] = showImg(hObject, eventdata, handles);
    set(handles.loadTagVid,'String','Video successfully loaded.');
end
% end openVid_Callback ----------------------------------------

function [res] = showImg(hObject, eventdata, handles)
% hObject    handle to openVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    cFrame = get(handles.currentFrame,'String');
    cFrameNum = str2double(cFrame);
    
    mydata = guidata(hObject);
    fps = mydata.fps;
    myAviInfo = mydata.myAviInfo;
    isGray = mydata.isGray;
            
    set(handles.status,'String','Loading original image.');
    
    % go to correct frame
    
    timestamp = get(mydata.aviHandle, 'timeStamp');
    % Current frame number
    videoFrame = round(timestamp * fps);
    
    if videoFrame < cFrameNum
        while videoFrame <= cFrameNum
            next(mydata.aviHandle);
            timestamp = get(mydata.aviHandle, 'timeStamp');
            % Current frame number
            videoFrame = round(timestamp * fps);
        end
    elseif videoFrame > cFrameNum
        bf1 = cFrameNum-cFrameNum*0.2;
        if bf1>=0
            %mydata.aviHandle = seek(mydata.aviHandle, cFrameNum-cFrameNum*0.2);
        end
        while videoFrame <= cFrameNum
            next(mydata.aviHandle);
            timestamp = get(mydata.aviHandle, 'timeStamp');
            % Current frame number
            videoFrame = round(timestamp * fps);
        end
    else
        % do nothing its the correct frame
    end
    
    if isGray
        img = getframe(mydata.aviHandle);
        img = img(:,:,1);
    else
        img = rgb2gray(getframe(mydata.aviHandle));
    end
    
    % Correct the vignette.
    if ~isempty(mydata.vImg)
        img = uint8(single(img) - single(mydata.vImg));
    end

    
    vrBackground = 0;
    isDebugVideo = 1;
    spf = 1 / fps;
    
    currentHandles2 = findall(0,'type','figure');
    newFigHandle = setdiff(currentHandles2, mydata.originalHandles);
    
    res = 1;
    mydata.displayHandle = newFigHandle;
    
    if ~isempty(mydata.displayHandle)
        close(mydata.displayHandle);
    end
    
    worm = segWorm(img, cFrameNum, 1, isDebugVideo);
    
    set(handles.status, 'String', ['Showing frame:',num2str(get(mydata.aviHandle, 'timeStamp'))]);
    guidata(hObject,mydata);
%end showImg ----------------------------

%here we will close the GUI correctly
function closeGUI(hObject, eventdata)
%src is the handle of the object generating the callback (the source of the event)
%evnt is the The event data structure (can be empty for some callbacks)
selection = questdlg('Do you want to close the GUI?     ',...
                     'Close Request Function',...
                     'Yes','No','Yes');
switch selection,
    case 'Yes',
        mydata = guidata(hObject);
        vr = mydata.aviHandle;
        close(vr);
        delete(gcf);
	case 'No'
	return
end
%end closeGUI --------------------------


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val1 = get(handles.playButton, 'String');

if strcmpi(val1, 'Play')
    mydata = guidata(hObject);
    vr = mydata.aviHandle;
    totalFrames = get(vr, 'numFrames') + get(vr, 'nHiddenFinalFrames');
    
    cFrame = get(handles.currentFrame,'String');
    cFrameNum = str2double(cFrame);
    
    set(handles.playButton, 'String', 'Stop');
    
    while cFrameNum <= totalFrames && strcmpi(get(handles.playButton, 'String'), 'Stop')
        cFrameNum = cFrameNum+1;
        set(handles.currentFrame,'String', num2str(cFrameNum));
        [res] = showImg(hObject, eventdata, handles);
        pause(1);
    end
else
    set(handles.playButton, 'String', 'Play');
end

