function varargout = module3control(varargin)
%MODULE3CONTROL M-file for module3control.fig
%      MODULE3CONTROL, by itself, creates a new MODULE3CONTROL or raises the existing
%      singleton*.
%
%      H = MODULE3CONTROL returns the handle to a new MODULE3CONTROL or the handle to
%      the existing singleton*.
%
%      MODULE3CONTROL('Property','Value',...) creates a new MODULE3CONTROL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to module3control_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MODULE3CONTROL('CALLBACK') and MODULE3CONTROL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MODULE3CONTROL.M with the given input
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
% Edit the above text to modify the response to help module3control

% Last Modified by GUIDE v2.5 28-Dec-2010 11:49:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @module3control_OpeningFcn, ...
                   'gui_OutputFcn',  @module3control_OutputFcn, ...
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


% --- Executes just before module3control is made visible.
function module3control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for module3control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes module3control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = module3control_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in createDirStructure.
function createDirStructure_Callback(hObject, eventdata, handles)
% hObject    handle to createDirStructure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%currentDir = cd;
dirWorm = uigetdir;
if dirWorm
    ret=1;
    cd(dirWorm);
else
    ret=0;
    return;
end

try
    str1 = 'Starting worm data directory creation.';
    set(handles.status1,'String',str1);
    createWormDir(hObject, eventdata, handles, dirWorm);
    str1 = 'Worm data directory creation and copying finished successfully!';
    set(handles.status1,'String',str1);
catch ME1
    str1 = strcat('Worm data directory creation and copying failed!',{' '},ME1.message);
    set(handles.status1,'String',str1{1});
end 


% --- Executes on button press in morphologyColoration.
function morphologyColoration_Callback(hObject, eventdata, handles)
% hObject    handle to morphologyColoration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    module3morphology();
catch
    str1 = ('Module3 morphological & coloration feature extraction could not be started!\n');
    set(handles.status1,'String',str1);

end 

% --- Executes on button press in sternberg1.
function sternberg1_Callback(hObject, eventdata, handles)
% hObject    handle to sternberg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    module3
catch
    str1 = ('Module3 Sternberg lab feature extraction could not be started!\n');
    set(handles.status1,'String',str1);

end 


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in headAndTail.
function headAndTail_Callback(hObject, eventdata, handles)
% hObject    handle to headAndTail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    headAndTail();
catch
    error('Head and Tail detector could not be started!\n');
end


% --- Executes on button press in findDataFiles.
function findDataFiles_Callback(hObject, eventdata, handles)
% hObject    handle to findDataFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    database_gui();
catch ME1
    msgString = getReport(ME1);
    msgbox(msgString);
end


% --- Executes on button press in caImaging.
function caImaging_Callback(hObject, eventdata, handles)
% hObject    handle to caImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%alignmentGUI;


% --- Executes on button press in droppedFramesCorrect.
function droppedFramesCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to droppedFramesCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

droppedFramesGui();
