function varargout = progress(varargin)
% PROGRESS M-file for progress.fig
%      PROGRESS, by itself, creates a new PROGRESS or raises the existing
%      singleton*.
%
%      H = PROGRESS returns the handle to a new PROGRESS or the handle to
%      the existing singleton*.
%
%      PROGRESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRESS.M with the given input arguments.
%
%      PROGRESS('Property','Value',...) creates a new PROGRESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before progress_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to progress_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help progress

% Last Modified by GUIDE v2.5 02-Feb-2010 18:06:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @progress_OpeningFcn, ...
                   'gui_OutputFcn',  @progress_OutputFcn, ...
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


% --- Executes just before progress is made visible.
function progress_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to progress (see VARARGIN)

% Choose default command line output for progress
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes progress wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = progress_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

str1 = strcat('Segmentation file');
set(handles.status1,'String',str1);
set(handles.axes1,'ytick',[])
set(handles.axes1,'xtick',[])


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
