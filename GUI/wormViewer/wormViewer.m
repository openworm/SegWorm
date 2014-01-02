function varargout = wormViewer(varargin)
% WORMVIEWER M-file for wormViewer.fig
%      WORMVIEWER, by itself, creates a new WORMVIEWER or raises the existing
%      singleton*.
%
%      H = WORMVIEWER returns the handle to a new WORMVIEWER or the handle to
%      the existing singleton*.
%
%      WORMVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORMVIEWER.M with the given input arguments.
%
%      WORMVIEWER('Property','Value',...) creates a new WORMVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wormViewer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wormViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help wormViewer

% Last Modified by GUIDE v2.5 04-Jul-2009 16:22:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @wormViewer_OpeningFcn, ...
    'gui_OutputFcn',  @wormViewer_OutputFcn, ...
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


% --- Executes just before wormViewer is made visible.
function wormViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wormViewer (see VARARGIN)

% Choose default command line output for wormViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wormViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wormViewer_OutputFcn(hObject, eventdata, handles)
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

stopButtonMode = str2double(get(handles.stopButton,'String'));

if stopButtonMode
    
    vidNameIn = get(handles.vidPath,'String');
    
    lastFrame = get(handles.totalFrames,'String');
    lastFrameNum = str2double(lastFrame);
    cFrame = get(handles.currentFrame,'String');
    cFrameNum = str2double(cFrame);
    mydata = guidata(hObject);
    aviHandle = mydata.aviHandle;
    
    if ~isempty(vidNameIn) && next(aviHandle)
        %if next(aviHandle);
        set(handles.currentFrame,'String',num2str(cFrameNum+1));
        mydata = guidata(hObject);
        aviHandle = mydata.aviHandle;
        aviInfo = mydata.aviInfo;
        
        %imOrig = get_Frame(aviHandle, aviInfo, cFrameNum2);
        %seek(aviHandle,cFrameNum2);
        imOrig = rgb2gray(getframe(aviHandle));
        
        %imOrig = rgb2gray(getframe(aviHandle));
        %   mov = aviread(vidNameIn,cFrameNum2);
        %   imOrig=mov(1).cdata;
        
        axes(handles.mainImg);
        imshow(imOrig);
        skelButtonVal = logical(get(handles.skelRadio,'Value'));
        if skelButtonVal;
            %draw skeleton
            drawSkel(hObject, eventdata, handles);
            set(handles.status,'String','Attemting to plot skeleton.');
        else
            set(handles.status,'String','Please tick one of the radial buttons!');
        end
    end
end


% --- Executes on button press in prevButton.
function prevButton_Callback(hObject, eventdata, handles)
% hObject    handle to prevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopButtonMode = str2double(get(handles.stopButton,'String'));
if stopButtonMode
    vidNameIn = get(handles.vidPath,'String');
    lastFrame = get(handles.totalFrames,'String');
    cFrame = get(handles.currentFrame,'String');
    cFrameNum = str2double(cFrame);
    cFrameNum = mydata.segCounter;
    mydata = guidata(hObject);
    aviHandle = mydata.aviHandle;
    lastFrameNum = str2double(lastFrame);
    cFrameNum2 = cFrameNum-1;
    if cFrameNum2>0
        %if ~isempty(vidNameIn) && step(aviHandle,-1)
        if ~isempty(vidNameIn) && seek(aviHandle,cFrameNum-1)
            set(handles.currentFrame,'String', num2str(cFrameNum2));
            %if step(aviHandle,-1)
            %mov = aviread(vidNameIn,cFrameNum2);
            %imOrig=mov(1).cdata;
            mydata = guidata(hObject);
            aviHandle = mydata.aviHandle;
            aviInfo = mydata.aviInfo;
            
            %old
            %imOrig = get_Frame(aviHandle, aviInfo, cFrameNum2);
            imOrig = getframe(aviHandle);
            if isempty(imOrig)
                fprintf('Dropped frame! %d/n',cFrameNum2);
            end
            imOrig = rgb2gray(imOrig);
            
            axes(handles.mainImg);
            imshow(imOrig);
            
            skelButtonVal = logical(get(handles.skelRadio,'Value'));
            if skelButtonVal;
                %draw skeleton
                drawSkel(hObject, eventdata, handles);
            else
                set(handles.status,'String','Please tick one of the radial buttons!');
            end
        end
    end
end


function gotoFrameX_Callback(hObject, eventdata, handles)
% hObject    handle to gotoFrameX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gotoFrameX as text
%        str2double(get(hObject,'String')) returns contents of gotoFrameX as a double
stopButtonMode = str2double(get(handles.stopButton,'String'));

if stopButtonMode
    vidNameIn = get(handles.vidPath,'String');
    lastFrame = get(handles.totalFrames,'String');
    %cFrame = get(handles.currentFrame,'String');
    cFrame = num2str(mydata.segCounter);
    gotoFrame = get(handles.gotoFrameX,'String');
    
    cFrameNum = str2double(cFrame);
    lastFrameNum = str2double(lastFrame);
    gotoFrameNum = str2double(gotoFrame);
    
    mydata = guidata(hObject);
    aviHandle = mydata.aviHandle;
    
    %if ~isempty(vidNameIn) && gotoFrameNum > 0 && gotoFrameNum <= lastFrameNum
    if ~isempty(vidNameIn) && seek(aviHandle,gotoFrameNum);
        set(handles.currentFrame,'String',num2str(gotoFrameNum));
        %mov = aviread(vidNameIn,gotoFrameNum);
        %imOrig=mov(1).cdata;
        mydata = guidata(hObject);
        aviHandle = mydata.aviHandle;
        aviInfo = mydata.aviInfo;
        
        %old
        %imOrig = get_Frame(aviHandle, aviInfo, gotoFrameNum);
        
        %seek(aviHandle,gotoFrameNum);
        imOrig = rgb2gray(getframe(aviHandle));
        
        axes(handles.mainImg);
        imshow(imOrig);
        
        skelButtonVal = logical(get(handles.skelRadio,'Value'));
        if skelButtonVal;
            %draw skeleton
            drawSkel(hObject, eventdata, handles);
        else
            set(handles.status,'String','Please tick one of the radial buttons!');
        end
    end
end


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

% --- Executes on button press in vidPathButton.
function vidPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to vidPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% [fname, pname] = uigetfile('*.*','Enter video file.');
% if (fname ~= 0)
%     fileName = fullfile(pname,fname);
%     set(handles.vidPath,'String',fileName);
% end


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
% clearVideoIO;
try
    [fname, pname] = uigetfile('*.*','Enter video file.');
    mydata = guidata(hObject);
    if isfield(mydata, 'aviHandle')
        aviHandle = mydata.aviHandle;
        if ~isfield(aviHandle,'status')
            close(aviHandle);
        end
    end
    
    if (fname ~= 0)
        fileName = fullfile(pname,fname);
        set(handles.vidPath,'String',fileName);
        cd(pname);
    end
    
    vidNameIn = get(handles.vidPath,'String');
    if ~isempty(vidNameIn)
        %[aviHandle, aviInfo] = getVideoIn(vidNameIn);
        
        vr = videoReader(vidNameIn, 'DirectShow', 'preciseFrames',-1);
        
        aviInfo = get(vr);
        aviInfo.Width = aviInfo.width;
        aviInfo.Height = aviInfo.height;
        aviInfo.NumFrames = aviInfo.numFrames;
        
        %aviInfo = aviinfo(vidNameIn);
        numFrames = num2str(aviInfo.NumFrames);
        set(handles.totalFrames,'String',numFrames);
        cFrame = num2str(1);
        set(handles.currentFrame,'String',cFrame);
        
        
        
        %first segmentation result value is for frame number 1, not frame 0.
        %Therefore we call next twice here.
        next(vr);
        next(vr);
        imOrig = rgb2gray(getframe(vr));
        
        aviInfo = get(vr);
        mydata.aviInfo = aviInfo;
        mydata.previousTimeStamp = aviInfo.timeStamp;
        mydata.segCounter  = 0;
        
        axes(handles.mainImg);
        imshow(imOrig);
        set(handles.loadTagVid,'String','Video successfully loaded.');
        %this will set the exit button to call closeGUI function
        set(handles.figure1,'CloseRequestFcn',@closeGUI);
        
        mydata.aviHandle = vr;
        
        %stop button initialization
        set(handles.stopButton,'String',num2str(1));
        
        guidata(hObject,mydata);
    end
catch ME1
    str1 = strcat('Loading failed!',{' '},ME1.stack(1).file,{' '},ME1.stack(1).name,{' '},num2str(ME1.stack(1).line));
    set(handles.status,'String',str1{1});
end

function skelPath_Callback(hObject, eventdata, handles)
% hObject    handle to skelPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skelPath as text
%        str2double(get(hObject,'String')) returns contents of skelPath as a double


% --- Executes during object creation, after setting all properties.
function skelPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skelPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openSkel.
function openSkel_Callback(hObject, eventdata, handles)
% hObject    handle to openSkel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname, pname] = uigetfile('*.*','Enter skel. coordinate *.dat file.');
if (fname ~= 0)
    fileName = fullfile(pname,fname);
    set(handles.skelPath,'String',fileName);
end

set(handles.status,'String','Loading skeleton coordinate data. This may take a few minutes!');
drawnow;

skelNameIn = get(handles.skelPath,'String');
if ~isempty(skelNameIn)
    set(handles.skelRadio,'Value',1);
    %load data
    %data = load(skelNameIn);
    %skelNameIn = 'C:\home\matlab\!seg-shrp\short-tests\test\module2\hen-1 (tm501) off food x_2009_08_05__19_17_37__1_seg.dat';
    [skelData, colorationData, touching, ht, aviInfo, finFlag, predictionFlag, flipFlag] = wormDataRead(skelNameIn, 1);
    if max(predictionFlag)==0
        set(handles.status,'String','Assigning correct head and tail assignment! This may take a few mintures...');
        drawnow;
        [flipFlag, colorationData, skelData, ht, predictionFlag] = headAndTailMain(skelData, colorationData, touching, ht, aviInfo, finFlag, flipFlag);
    end
    
    %get the length of the struct
    skelLen = length(skelData);
    %send it to the handle
    set(handles.totalSkel,'String',num2str(skelLen));
    set(handles.currentFrame,'String',num2str(1));
    set(handles.gotoFrameX,'String',num2str(1));
    set(handles.loadTagSkel,'String','Skeleton coordinates successfully loaded.');
    mydata = guidata(hObject);
    mydata.skelCoords = skelData;
    mydata.touching = touching;
    mydata.colorationData = colorationData;
    mydata.ht = ht;
    mydata.flipFlag = flipFlag;
    mydata.predictionFlag = predictionFlag;
    mydata.skelFieldName = 'coords';
    guidata(hObject,mydata);
end
drawSkel(hObject, eventdata, handles);



% draw coordinates
function drawSkel(hObject, eventdata, handles)
mydata = guidata(hObject);
%cFrame = get(handles.currentFrame,'String');
%cFrameNum = str2double(cFrame);

aviInfo = get(mydata.aviHandle);

currentTimeStamp = aviInfo.timeStamp;
timeStampVal = (currentTimeStamp-mydata.previousTimeStamp)/mydata.aviInfo.timeStamp;
mydata.previousTimeStamp = currentTimeStamp;

if timeStampVal>1.0001
    mydata.segCounter = mydata.segCounter+round(timeStampVal);
else
    mydata.segCounter = mydata.segCounter+1;
end

cFrameNum = mydata.segCounter;
guidata(hObject,mydata);
try
    %axes(handles.mainImg);
    %coordinates. here mydata.coords is the struct with coords data,
    %cFrameNum is the desirable frame number .(mydata.coordsFieldName)
    %is a way to reference correct handle in the struct which is loaded
    %from the file.
    coords = mydata.skelCoords{cFrameNum}.(mydata.skelFieldName);
    %plot_Skel(coords, 0.5, 10);
    plot_Skel(coords, 1, 8, 10,1);
    
    %here we will define other stuff to be printed on the image
    %touching
    
    if mydata.touching(cFrameNum)
        fList = {'touching','crashed','movement','no data','dropped'};
        text(15,15,strcat('Frame mode:',fList{mydata.touching(cFrameNum)}),'Color','w');
    else
        text(15,15,strcat('Frame mode:normal'),'Color','w');
    end
    
    if mydata.flipFlag(cFrameNum)
        fList = {'flipped'};
        text(15,35,strcat('Flip mode:',fList{mydata.flipFlag(cFrameNum)}),'Color','w');
        text(15,55,strcat('Head pred. coef:',num2str(mydata.predictionFlag(cFrameNum)),'%'),'Color','w');
    else
        text(15,35,strcat('Flip mode:normal'),'Color','w');
        text(15,55,strcat('Head pred. coef:',num2str(mydata.predictionFlag(cFrameNum)),'%'),'Color','w');
    end
    
    text(mydata.colorationData{cFrameNum}.end1(2,1)-20,mydata.colorationData{cFrameNum}.end1(1,1)-20,strcat('HEAD','(',num2str(mydata.ht{cFrameNum}.endsDist(1)),')(',num2str(mydata.ht{cFrameNum}.endsDist(2)),')'));
    text(mydata.colorationData{cFrameNum}.end1(2,1)-20,mydata.colorationData{cFrameNum}.end1(1,1)-40,strcat('median',':',num2str(mydata.colorationData{cFrameNum}.coloration(1,1))));
    text(mydata.colorationData{cFrameNum}.end1(2,1)-20,mydata.colorationData{cFrameNum}.end1(1,1)-60,strcat('mean',':',num2str(mydata.colorationData{cFrameNum}.coloration(1,2))));
    text(mydata.colorationData{cFrameNum}.end1(2,1)-20,mydata.colorationData{cFrameNum}.end1(1,1)-80,strcat('variance',':',num2str(mydata.colorationData{cFrameNum}.coloration(1,4))));
    
    text(mydata.colorationData{cFrameNum}.end2(2,1)-20,mydata.colorationData{cFrameNum}.end2(1,1)-40,strcat('median',':',num2str(mydata.colorationData{cFrameNum}.coloration(2,1))));
    text(mydata.colorationData{cFrameNum}.end2(2,1)-20,mydata.colorationData{cFrameNum}.end2(1,1)-60,strcat('mean',':',num2str(mydata.colorationData{cFrameNum}.coloration(2,2))));
    text(mydata.colorationData{cFrameNum}.end2(2,1)-20,mydata.colorationData{cFrameNum}.end2(1,1)-80,strcat('variance',':',num2str(mydata.colorationData{cFrameNum}.coloration(2,4))));
catch ME1
    %the coordinate data for this frame doesnt exsist
    set(handles.status,'String','Skeleton coordinate data for this frame can not be found!');
end
%guidata(hObject, handles);

% --- Executes on button press in skelRadio.
function skelRadio_Callback(hObject, eventdata, handles)
% hObject    handle to skelRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skelRadio

%here we will close the GUI correctly
function closeGUI(hObject, evnt)
%src is the handle of the object generating the callback (the source of the event)
%evnt is the The event data structure (can be empty for some callbacks)
selection = questdlg('Do you want to close the GUI?     ',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        mydata = guidata(hObject);
        close(mydata.aviHandle);
        %        getVideoOut(aviHandle);
        delete(gcf);
    case 'No'
        return
end


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%turning the stop mode off (0)
set(handles.stopButton,'String',num2str(0));
mydata = guidata(hObject);
aviHandle = mydata.aviHandle;

stopButtonMode = str2double(get(handles.stopButton,'String'));

while ~stopButtonMode
    
    stopButtonMode = str2double(get(handles.stopButton,'String'));
    
    if next(aviHandle)
%         cFrame = get(handles.currentFrame,'String');
%         cFrame2 = num2str(str2double(cFrame)+1);
%         cFrameNum = cFrame2;
        aviInfo = get(mydata.aviHandle);

        currentTimeStamp = aviInfo.timeStamp;
        timeStampVal = (currentTimeStamp-mydata.previousTimeStamp)/mydata.aviInfo.timeStamp;
        mydata.previousTimeStamp = currentTimeStamp;

        if timeStampVal>1.0001
            mydata.segCounter = mydata.segCounter+round(timeStampVal);
        else
            mydata.segCounter = mydata.segCounter+1;
        end
        cFrameNum = mydata.segCounter;
        cFrame = num2str(cFrameNum);
        set(handles.currentFrame,'String',num2str(cFrameNum));
        
        if mydata.touching(cFrameNum)==5
            while mydata.touching(cFrameNum) ~= 5
                cFrameNum = cFrameNum+1;
            end
        end
        set(handles.currentFrame,'String', num2str(cFrameNum));
    
        imOrig = rgb2gray(getframe(aviHandle));
        %imOrig = rgb2gray(imOrig);
        
        %axes(handles.mainImg);
        
        imgOutline = zeros(size(imOrig));
        imgSkel = zeros(size(imOrig));
        %check if the data is loaded
        skelButtonVal = logical(get(handles.skelRadio,'Value'));
        if skelButtonVal;
            data=mydata.skelCoords{str2double(cFrame)};
            if length(data.outlineCoords)>2
                for n=1:length(data.outlineCoords)
                    imgOutline(data.outlineCoords(n,1),data.outlineCoords(n,2))=255;
                end
                
                for n=1:length(data.skCoords)
                    imgSkel(data.skCoords(n,1),data.skCoords(n,2))=255;
                end
            end
            imOrig2 = imoverlay(imOrig, bwperim(imgOutline),[0,0.2,0.9]);
            imOrig2 = imoverlay(imOrig2, bwperim(imgSkel),[0.9,0.1,0.3]);
            imshow(imOrig2);
        else
            imshow(imOrig);
        end
        
        skelButtonVal = logical(get(handles.skelRadio,'Value'));
        if skelButtonVal;
            %draw skeleton
            drawSkel(hObject, eventdata, handles);
            set(handles.status,'String','Attemting to plot skeleton.');
        else
            set(handles.status,'String','Please tick one of the radial buttons!');
        end
        drawnow;
        %pause(1/aviInfo.fps);
        %pause(1/160);
    else
        set(handles.stopButton,'String',num2str(1));
        break;
    end
end
mydata.aviHandle = aviHandle;
guidata(hObject,mydata);

% --- Executes on button press in stopButton1.
function stopButton1_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%stop button initialization

%turning the stop mode on (1)
set(handles.stopButton,'String',num2str(1));
