function varargout = analysisStatus(varargin)
% ANALYSISSTATUS M-file for analysisStatus.fig
%      ANALYSISSTATUS, by itself, creates a new ANALYSISSTATUS or raises the existing
%      singleton*.
%
%      H = ANALYSISSTATUS returns the handle to a new ANALYSISSTATUS or the handle to
%      the existing singleton*.
%
%      ANALYSISSTATUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSISSTATUS.M with the given input arguments.
%
%      ANALYSISSTATUS('Property','Value',...) creates a new ANALYSISSTATUS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analysisStatus_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to analysisStatus_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help analysisStatus

% Last Modified by GUIDE v2.5 26-Jan-2010 14:25:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @analysisStatus_OpeningFcn, ...
    'gui_OutputFcn',  @analysisStatus_OutputFcn, ...
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


% --- Executes just before analysisStatus is made visible.
function analysisStatus_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to analysisStatus (see VARARGIN)

% Choose default command line output for analysisStatus
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes analysisStatus wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = analysisStatus_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dirAvi = uigetdir('*.*','Enter worm video directory to display status.');
if ~dirAvi
    return;
end

cd(dirAvi);
mydata = guidata(hObject);
mydata.dirAvi = dirAvi;
wormDirName = dirAvi;
set(handles.status1,'String',wormDirName);
try
    [filesAvi, filesLog2] = getDirStructure(dirAvi);
catch ME1
    try
        [filesAvi, filesLog2] = getDirStructure2(dirAvi);
    catch ME2
        str1 = strcat('Function getDirStructure is not able to match up video file names with log file names correctly. Please make sure you are using recent version of Worm Tracker.');
        set(handles.status1,'String',str1);
    end
end

set(handles.popupmenu2,'String',filesAvi);

lenAvi = length(filesAvi);
mydata.lenAvi = lenAvi;
mydata.filesAvi = filesAvi;
mydata.filesLog2 = filesLog2;


%this section loads process files
%--------------------------------------------------------------------------
try
    %stage movement
    [flag1, filesAvi, filesLog, onlyNewFilesAvi, filesAviUnfinished, onlyNewFilesLog, filesLogUnfinished] = wormProcessReadM1Status(dirAvi);
    str1(1) = strcat('Directory:', {' '}, dirAvi, {'.'});
    str1(2) = strcat('----------',{''},'Stage',{' '},'movement','----------');
    str1(3) = strcat('Video files:',{' '},num2str(length(filesAvi)-length(filesAviUnfinished)),{' '},' out of',{' '}, num2str(length(filesAvi)),{' '},'analyzed.');
    str1(4) = strcat('Log files:',{' '}, num2str(length(filesLog)-length(filesLogUnfinished)),{' '},'out of',{' '}, num2str(length(filesLog)),{' '},'used.');
    %segmentation
    [flag1, newFilesAvi, filesAviFinished] = wormProcessReadStatus(dirAvi);
    str1(5) = strcat('----------',{''},'Segmented',{' '},'files','----------');
    str1(6) = strcat('Video files:',{' '},num2str(length(filesAviFinished)),{' '},' out of',{' '}, num2str(length(filesAvi)),{' '},'analyzed.');
    set(handles.info1,'String',str1);   
catch ME1
	str1 = strcat('Process file could not be lodaed for directory:',{' '},dirAvi,{' '},ME1.message);
    set(handles.status1,'String',str1{1});   
end
guidata(hObject,mydata);


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

mydata = guidata(hObject);

vidNames = get(handles.popupmenu2,'String');
id1 = get(handles.popupmenu2,'Value');
vidName = vidNames{id1};

%str1 = strcat('Opening stage movement data for video file: ',{' '},vidNames{id1});
%set(handles.status1,'String', str1{1});

%----------------------------------------------------------------------
%this section loads the stage movement data
%----------------------------------------------------------------------
try
    stageMovementFile = strcat(vidName(1:(end-4)),'_diff.dat');
    if exist(fullfile(mydata.dirAvi, 'module1', stageMovementFile),'file') == 2
        str1 = strcat('Status report is reading stage movement data file',{' '},stageMovementFile,{'.'});
        set(handles.status1,'String',str1{1});
        drawnow;
        try
            [movementFrames, diffData, aviInfo2] = wormDataReadM1(stageMovementFile);
            
            drawnow;
            axes(handles.axes1);
            plot(1:length(diffData),diffData/max(diffData));
            xlim(handles.axes1,[1,length(diffData)]);
            line(1:length(movementFrames),movementFrames, 'Color','r');
            
            xlabel(handles.axes1,'Frames','fontsize',10);
            ylabel(handles.axes1,'Pixel difference sum','fontsize',10);
            drawnow;

        catch ME1
            str1 = strcat('Status report can not open stage movement data file. Please run module1 first for the video file:',{' '},vidName,{' '},'at',{' '}, datestr(now));
            set(handles.status1,'String',str1{1});
        end
    else
        str1 = strcat('Status report can not open stage movement data file. Please run module1 first for the video file:',{' '},vidName,{' '},'at',{' '}, datestr(now));
        set(handles.status1,'String',str1{1});
    end
catch ME3
    %Cleanup
    %print to GUI
    str1 = strcat('Status report crashed while opening stage movement file',{' '}, vidName,{' '},'at', {' '}, datestr(now),'.','{ }', ME3.message);
    set(handles.status1,'String',str1{1});
end

%----------------------------------------------------------------------
%this section loads the head and tail data
%----------------------------------------------------------------------
try
    outputFileName = strcat(vidName(1:(end-4)),'_seg.dat');
    str1 = strcat('Loading video segmentation data file',{' '}, outputFileName,{' '},'this may take a few minutes...');
    set(handles.status1,'String',str1{1});
    
    %locate the file
    datFiles = dirrec(fullfile(mydata.dirAvi,'module2'),'.dat');
    for i =1:length(datFiles)
        if sum(strfind(datFiles{i},outputFileName))
            file1 = datFiles{i};
        end
    end
   
    [skelData, colorationData, touching, ht, aviInfo, finFlag, predictionFlag, flipFlag] = wormDataRead(file1, 1);
    
    str1 = strcat('Loading of file',{' '}, outputFileName,{' '},'finished.');
    set(handles.status1,'String',str1{1});
    
    if max(predictionFlag)==0
        set(handles.status1,'String','Assigning correct head and tail assignment! This may take a few mintures...');
        [flipFlag, colorationData, skelData, ht, predictionFlag] = headAndTailMain(skelData, colorationData, touching, ht, aviInfo, finFlag);
    end
    
    axes(handles.axes2);
    %plot(flipFlag, 'Color',[0.5 0.1 1])
    %hold on;
    %plot(predictionFlag,'Color',[1,0.1,0.5])
    cla(handles.axes2);
    %hold off;
    flipFlag2(1)=0;
    flipFlag2(2:length(flipFlag)+1) =flipFlag; 
    
    flipDiff = diff(flipFlag2);
    ind1 = 1:length(flipFlag);
    starts1 = ind1(flipDiff>0);
    ends1 = ind1(flipDiff<0)-1;
    
    i1 = sort(unique([1,starts1,ends1,length(flipFlag)]));
    
%   figure;
    hold on;
    color_tableRed=[linspace(200,255,100)'./255,ones(100,1)*0.3882,ones(100,1)*0.2784];
    color_tableBlue=[ones(100,1)*0.2784,ones(100,1)*0.3882,linspace(200,255,100)'./255];
    
    for i=1:length(i1)-1
        s1 = i1(i); s2 = i1(i+1);
        e1 = 0;     e2 = 0;
        inter1 = i1(i):i1(i+1);
        dat1 = naninterp(predictionFlag(inter1));
        if sum(flipFlag(inter1))==length(inter1)
            cID1 = randsample(100,1);
            col1 = color_tableRed(cID1,:);
        else
            cID1 = randsample(100,1);
            col1 = color_tableBlue(cID1,:);
        end
        
        fill([inter1,s2,s1],[dat1,e1,e2],col1, 'FaceAlpha',0.95);
    end
    if length(predictionFlag)~=1
        xlim(handles.axes2,[1,length(predictionFlag)]);
        xlabel(handles.axes2,'Frames','fontsize',10);
        ylabel(handles.axes2,'Confidence','fontsize',10);
        ylim(handles.axes2,[0,100]);
        line([0,length(predictionFlag)],[50, 50],'Color','k','LineStyle','-','LineWidth',1.5);
        drawnow;
    else
        str1 = strcat('Segmentation file',{' '}, outputFileName,{' '},'not found.');
        set(handles.status1,'String',str1{1});
    end
    
%     %test
%     x=rand(100,1);
%     y=rand(100,1);
%     scatter(x,y,20,color_tableRed(1:length(x),:));
    hold off;
catch ME1
    str1 = strcat('Status report could not open stage movement file',{' '}, vidName,{' '},'at', {' '}, datestr(now),'.','{ }', ME1.message);
    set(handles.status1,'String',str1{1});
end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
