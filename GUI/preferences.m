function varargout = preferences(varargin)
% PREFERENCES M-file for preferences.fig
%      PREFERENCES, by itself, creates a new PREFERENCES or raises the existing
%      singleton*.
%
%      H = PREFERENCES returns the handle to a new PREFERENCES or the handle to
%      the existing singleton*.
%
%      PREFERENCES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREFERENCES.M with the given input arguments.
%
%      PREFERENCES('Property','Value',...) creates a new PREFERENCES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preferences_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preferences_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help preferences

% Last Modified by GUIDE v2.5 02-Apr-2013 00:27:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preferences_OpeningFcn, ...
                   'gui_OutputFcn',  @preferences_OutputFcn, ...
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


% --- Executes just before preferences is made visible.
function preferences_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to preferences (see VARARGIN)
handles.guifig = gcf;
guidata(handles.guifig,handles);
% Choose default command line output for preferences
handles.output = hObject;
if ~isempty(varargin)
    handles.preferences = varargin{1};
    fields1 = fieldnames(handles.preferences);
    
    %lets remove some fields from the preferences
    fields1 = fields1(~strcmp(fields1, 'batch'));
    fields1 = fields1(~strcmp(fields1, 'batchPath'));
        
    for i=1:length(fields1)
        if strcmp(fields1{i}, 'experimentCollectionListName')
            set(handles.experimentCollectionList,'String', handles.preferences.(fields1{i}));
            set(handles.experimentCollectionList,'Value', 1);
            set(handles.(fields1{i}),'String',handles.preferences.(fields1{i}));
        else
            set(handles.(fields1{i}),'Value',handles.preferences.(fields1{i}));
        end
    end
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes preferences wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = preferences_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.guifig,'WindowStyle','Modal');

uiwait; %wait till the figure is destroyed  or asked to resume

try %this statement is necessary if figure is destroyed , then output argument will be empty by default
    handles = guidata(handles.guifig);
    varargout{1} = handles.selection;
    %closereq; % close the gui if OK is pressed
    %set(gcf,'CloseRequestFcn',@figure1_CloseRequestFcn)
    figure1_CloseRequestFcn(hObject, eventdata, handles);
catch
    varargout{1} = [];
end


% --- Executes on button press in pathMoments.
function pathMoments_Callback(hObject, eventdata, handles)
% hObject    handle to pathMoments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pathMoments


% --- Executes on button press in featureSet.
function featureSet_Callback(hObject, eventdata, handles)
% hObject    handle to featureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of featureSet


% --- Executes on button press in morphology.
function morphology_Callback(hObject, eventdata, handles)
% hObject    handle to morphology (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of morphology


% --- Executes on button press in droppedFramesFlag.
function droppedFramesFlag_Callback(hObject, eventdata, handles)
% hObject    handle to droppedFramesFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of droppedFramesFlag


% --- Executes on button press in deleteVideo.
function deleteVideo_Callback(hObject, eventdata, handles)
% hObject    handle to deleteVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of deleteVideo


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fields1 = fieldnames(handles.preferences);
%lets remove some fields from the preferences
fields1 = fields1(~strcmp(fields1, 'batch'));
fields1 = fields1(~strcmp(fields1, 'batchPath'));

for i=1:length(fields1)
    if strcmp(fields1{i}, 'experimentCollectionListName')
        data.(fields1{i}) = get(handles.(fields1{i}),'String');
    else
        data.(fields1{i}) = get(handles.(fields1{i}),'Value');
    end
end
data.batch = handles.preferences.batch;
if isfield(handles.preferences, 'batchPath')
    data.batchPath = handles.preferences.batchPath;
end

%data.deleteVideo = get(handles.deleteVideo,'Value');
%data.featureSet = get(handles.featureSet,'Value');
%data.morphology = get(handles.morphology,'Value');

%lets remove some fields from the preferences

handles.data1 = data;

if isfield(handles,'data1');%if there is no selection of radio button and OK is pressed then the selection is Radio Button1 by default
    handles.selection = handles.data1;
end

% Save the file to a secure location
outFileName = [ctfroot,filesep,'wormAnalysisToolboxUserData',filesep,'custom_preferences.mat'];
% Check/create directories
[dirName, ~, ~] = fileparts(outFileName);
if ~isdir(dirName)
    mkdir(dirName);
end
save(outFileName, 'data');

guidata(hObject, handles);
guidata(handles.guifig, handles);

uiresume;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in excel.
function excel_Callback(hObject, eventdata, handles)
% hObject    handle to excel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of excel


% --- Executes on button press in ht2.
function ht2_Callback(hObject, eventdata, handles)
% hObject    handle to ht2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ht2


% --- Executes on button press in baekEtAl.
function baekEtAl_Callback(hObject, eventdata, handles)
% hObject    handle to baekEtAl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of baekEtAl


% --- Executes on button press in skeldisable.
function skeldisable_Callback(hObject, eventdata, handles)
% hObject    handle to skeldisable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skeldisable


% --- Executes on button press in caImaging.
function caImaging_Callback(hObject, eventdata, handles)
% hObject    handle to caImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of caImaging


% --- Executes on button press in nas.
function nas_Callback(hObject, eventdata, handles)
% hObject    handle to nas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nas


% --- Executes on button press in redoStageMovDiff.
function redoStageMovDiff_Callback(hObject, eventdata, handles)
% hObject    handle to redoStageMovDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redoStageMovDiff


% --- Executes on button press in nasOverwrite.
function nasOverwrite_Callback(hObject, eventdata, handles)
% hObject    handle to nasOverwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nasOverwrite


% --- Executes on button press in videoOut.
function videoOut_Callback(hObject, eventdata, handles)
% hObject    handle to videoOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of videoOut


% --- Executes on button press in redoSeg.
function redoSeg_Callback(hObject, eventdata, handles)
% hObject    handle to redoSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redoSeg


% --- Executes on button press in redo_ht.
function redo_ht_Callback(hObject, eventdata, handles)
% hObject    handle to redo_ht (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redo_ht


% --- Executes on button press in redoStageMovDet.
function redoStageMovDet_Callback(hObject, eventdata, handles)
% hObject    handle to redoStageMovDet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redoStageMovDet


% --- Executes on button press in standalone.
function standalone_Callback(hObject, eventdata, handles)
% hObject    handle to standalone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of standalone


% --- Executes on selection change in experimentCollectionList.
function experimentCollectionList_Callback(hObject, eventdata, handles)
% hObject    handle to experimentCollectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns experimentCollectionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from experimentCollectionList

% Here we will catch the selection and save it to
% experimentCollectionListName 

selectionVal = get(handles.experimentCollectionList,'Value');
listVal = get(handles.experimentCollectionList,'String');
if iscell(listVal)
    set(handles.experimentCollectionListName,'String', listVal{selectionVal});
else
    set(handles.experimentCollectionListName,'String', listVal);
end

% --- Executes during object creation, after setting all properties.
function experimentCollectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimentCollectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadExperimentCollectionList.
function loadExperimentCollectionList_Callback(hObject, eventdata, handles)
% hObject    handle to loadExperimentCollectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Here we will try to connect to the database and select a list to analyze
% in the main process window

try
    error('database details missing')

    conn = database;
    
    sqlString3 = 'show tables;';
    curs = exec(conn, sqlString3);
    curs = fetch(curs);
    tableList = curs.Data;
    close(curs);
    tmp =strfind(tableList, 'experimentlist');
    tmpInd = ~cellfun(@isempty, tmp);
    experimentCollectionList = tableList(tmpInd);
    
    set(handles.experimentCollectionList,'Value', 1);
    set(handles.experimentCollectionList,'String', experimentCollectionList);
    
    close(conn);
    
catch ME1
    msgString = getReport(ME1, 'extended','hyperlinks','off');
    msgbox(msgString);
end


% --- Executes on button press in useDB.
function useDB_Callback(hObject, eventdata, handles)
% hObject    handle to useDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useDB


% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)
% hObject    handle to normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normalize


% --- Executes on button press in runOnCompleted.
function runOnCompleted_Callback(hObject, eventdata, handles)
% hObject    handle to runOnCompleted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of runOnCompleted


% --- Executes on button press in dbupdate.
function dbupdate_Callback(hObject, eventdata, handles)
% hObject    handle to dbupdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dbupdate


% --- Executes on button press in calibrated_ht.
function calibrated_ht_Callback(hObject, eventdata, handles)
% hObject    handle to calibrated_ht (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calibrated_ht


% --- Executes on button press in getCalibration.
function getCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to getCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function will load the handt data directory and will extract
% relevant information. It will then save the custom calibration data to a
% safe location for further use. The function will also set the
% calibrated_ht checkbox to true.

% Get the directory of interest manualy
dirPath = uigetdir('*.*','Enter calibration file collection directory.');
%dirPath = 'C:\!worm_videos\copied from pc207-12\Andre\03-03-11';
if ~dirPath
% Stop the function if user pressed cancel
    return;
end

% Get all csv files in directory specified
dirContents = dirrec(dirPath,'.csv');

% Initialize data 
trainingDataCustom = zeros(0,9);
% Loop through all of the files
for i=1:length(dirContents)
    % Load coloration and motion data from csv files
    raw_data = csvread(dirContents{i},1,0);
    % Concatanate the data to form trainingData matrix
    trainingDataCustom = [trainingDataCustom; raw_data(:,2:10)]; %#ok<AGROW>
end

% Save the file to a secure location
outFileName = [ctfroot,filesep,'wormAnalysisToolboxUserData',filesep,'trainingDataCustom.mat'];

% Check/create directories
[dirName, ~, ~] = fileparts(outFileName);
if ~isdir(dirName)
    mkdir(dirName);
end
save(outFileName, 'trainingDataCustom');

% Flip the "use local head and tail calibration" on
set(handles.calibrated_ht,'Value', 1);

% --- Executes on button press in getCalibration_help.
function getCalibration_help_Callback(hObject, eventdata, handles)
% hObject    handle to getCalibration_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

outFileName = [ctfroot,filesep,'wormAnalysisToolboxUserData',filesep,'trainingDataCustom.mat'];
msgbox(['This function allows you to define your own head and tail ', ...
    'detection training set that will be used for automatic classification. ',...
    'Please refer to the user guide for more information. The file will be saved in: ',outFileName])


% --- Executes on button press in disableWarnings_ht.
function disableWarnings_ht_Callback(hObject, eventdata, handles)
% hObject    handle to disableWarnings_ht (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disableWarnings_ht


% --- Executes on button press in bgsubtract.
function bgsubtract_Callback(hObject, eventdata, handles)
% hObject    handle to bgsubtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bgsubtract
