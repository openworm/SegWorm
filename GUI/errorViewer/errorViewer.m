function varargout = errorViewer(varargin)
% ERRORVIEWER MATLAB code for errorViewer.fig
%      ERRORVIEWER, by itself, creates a new ERRORVIEWER or raises the existing
%      singleton*.
%
%      H = ERRORVIEWER returns the handle to a new ERRORVIEWER or the handle to
%      the existing singleton*.
%
%      ERRORVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ERRORVIEWER.M with the given input arguments.
%
%      ERRORVIEWER('Property','Value',...) creates a new ERRORVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before errorViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to errorViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help errorViewer

% Last Modified by GUIDE v2.5 27-Feb-2012 13:23:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @errorViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @errorViewer_OutputFcn, ...
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


% --- Executes just before errorViewer is made visible.
function errorViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to errorViewer (see VARARGIN)

% Choose default command line output for errorViewer
handles.output = hObject;

% -------------------------------------------------------------------------
% Here we retrieve the error structure
handles.errorData = varargin{1};


fieldNames = {handles.errorData.errorTag};
set(handles.events, 'String', fieldNames);

index_selected = length(handles.errorData);
set(handles.events, 'Value', index_selected);

set(handles.errorSignature,'String',handles.errorData(index_selected).errorStr);

errorExplanationString = sprintf('%s \n\n',...
    handles.errorData(index_selected).errorDescription,...
    ['Directory: ', handles.errorData(index_selected).dir],...
    ['File name: ', handles.errorData(index_selected).fileName],...
    ['DB id: ', handles.errorData(index_selected).dbID]);

set(handles.errorExplanation,'String', errorExplanationString);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes errorViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = errorViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in events.
function events_Callback(hObject, eventdata, handles)
% hObject    handle to events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns events contents as cell array
%        contents{get(hObject,'Value')} returns selected item from events

%--------------------------------------------------------------------------
% Here we will examine the errors, allow users to select them and display
% their descriptions
mydata = guidata(hObject);

index_selected = get(hObject,'Value');
%list = get(hObject,'String');

set(handles.errorSignature,'String',mydata.errorData(index_selected).errorStr);

errorExplanationString = sprintf('%s \n\n',...
    mydata.errorData(index_selected).errorDescription,...
    ['Directory: ', mydata.errorData(index_selected).dir],...
    ['File name: ', mydata.errorData(index_selected).fileName],...
    ['DB id: ', num2str(mydata.errorData(index_selected).dbID)]);

set(handles.errorExplanation,'String', errorExplanationString);



% --- Executes during object creation, after setting all properties.
function events_CreateFcn(hObject, eventdata, handles)
% hObject    handle to events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function errorSignature_Callback(hObject, eventdata, handles)
% hObject    handle to errorSignature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of errorSignature as text
%        str2double(get(hObject,'String')) returns contents of errorSignature as a double


% --- Executes during object creation, after setting all properties.
function errorSignature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to errorSignature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function errorExplanation_Callback(hObject, eventdata, handles)
% hObject    handle to errorExplanation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of errorExplanation as text
%        str2double(get(hObject,'String')) returns contents of errorExplanation as a double


% --- Executes during object creation, after setting all properties.
function errorExplanation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to errorExplanation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
