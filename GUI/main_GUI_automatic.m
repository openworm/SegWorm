function varargout = main_GUI_automatic(varargin)
% main_GUI_automatic M-file for main_GUI_automatic.fig
%      main_GUI_automatic, by itself, creates a new main_GUI_automatic or raises the existing
%      singleton*.
%
%      H = main_GUI_automatic returns the handle to a new main_GUI_automatic or the handle to
%      the existing singleton*.
%
%      main_GUI_automatic('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in main_GUI_automatic.M with the given input arguments.
%
%      main_GUI_automatic('Property','Value',...) creates a new main_GUI_automatic or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_GUI_automatic_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_GUI_automatic_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help main_GUI_automatic

% Last Modified by GUIDE v2.5 10-Aug-2011 18:50:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_GUI_automatic_OpeningFcn, ...
                   'gui_OutputFcn',  @main_GUI_automatic_OutputFcn, ...
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


% --- Executes just before main_GUI_automatic is made visible.
function main_GUI_automatic_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_GUI_automatic (see VARARGIN)

% Choose default command line output for main_GUI_automatic
%global batchExit;
%batchExit = 0;
%start dump
handles.output = hObject;

%default preferences
prefData.redoStageMovDiff = 0;
prefData.redoStageMovDet = 0;
prefData.redoSeg = 0;
prefData.deleteVideo = 0;
prefData.videoOut = 1;
prefData.redo_ht = 0;
prefData.normalize = 0;
prefData.featureSet = 1;

prefData.standalone = 1;

prefData.calibrated_ht = 0;
prefData.disableWarnings_ht = 0;

prefData.runOnCompleted = 0;

% prefData.newVignette = 0;

prefData.bgsubtract = 0;
prefData.skeldisable = 0;
prefData.excel = 0;
prefData.caImaging = 0;

prefData.useDB = 0;
prefData.dbupdate = 0;
prefData.nas = 0;
prefData.nasOverwrite = 0;
prefData.experimentCollectionList = 1;
%prefData.experimentCollectionListName = 'victoriaExperimentList';
prefData.experimentCollectionListName = 'segmentationExperimentList';

prefData.version = 1;

%here we check the varargin variable
prefData.batch = 0;

%if ~isempty(varargin)
%    if length(varargin{:})>1 && strcmp('-b',varargin{:}{1})
%        prefData.batch = 1;
%        prefData.batchPath = varargin{:}{2};
%    end
%end

%--------------------
% Look for a previously saved preferences file and load that
% Save the file to a secure location
try 
    preferencesFileName = [ctfroot, filesep, 'wormAnalysisToolboxUserData', ...
        filesep, 'custom_preferences.mat'];
    % Load file if exists
    if exist(preferencesFileName, 'file') == 2
        data = [];
        load(preferencesFileName);
        prefData = data;

%         if ~isfield(prefData, 'newVignette')
%         prefData.newVignette = 0;
%         end
    end
catch ME1
    %msgString = getReport(ME1);
    warning('ToolboxInitialization:loadingPreferences',...
            'There was an issue locating and loading default preference file.');
    
end
%--------------------

handles.prefData = prefData;

%warning list
warningList = ...
{   'segWorm:NoWormFound', 'No worm was found';...
    'segWorm:ContourTouchesBoundary', 'The worm contour touches the image boundary'; ...
    'segWorm:ContourTooSmall', 'The worm contour is too small';...
    'segWorm:TooManyEnds', 'The worm has 3 or more low-frequency sampled convexities sharper than 90 degrees (possible head/tail points)';...
    'segWorm:TooFewEnds', 'The worm contour has less than 2 high-frequency sampled convexities sharper than 60 degrees (the head and tail). Therefore, the worm is coiled and cannot be segmented';...
    'segWorm:DoubleLengthSide', 'The worm length, from head to tail, is more than twice as large on one side than it is on the other. Therefore the worm is coiled and cannot be segmented';...
    'segWorm:DoubleHeadWidth', 'The worm more than doubles its width from end of its head. Therefore, the worm is coiled, laid an egg, and/or is significantly obscured and cannot be segmented';...
    'segWorm:DoubleTailWidth', 'The worm more than doubles its width from end of its tail. Therefore, the worm is coiled, laid an egg, and/or is significantly obscured and cannot be segmented';...
    'segWorm:SmallTail', 'The worm tail is less than half the size of its head. Therefore, the worm is significantly obscured and cannot be segmented';...
    'segWorm:SmallHead', 'The worm head is less than half the size of its tail. Therefore, the worm is significantly obscured and cannot be segmented';...
    'segWorm:SmallHeadTail', 'The worm head and tail are less than 1/4 the size of its remaining body. Therefore, the worm is significantly obscured and cannot be segmented';...
    'segWorm:CannotSegment', 'The worm cannot be segmented';...
    'segWorm:IdenticalContours', 'The inner and outer contour cannot be distinguished from each other';...
    };
    
handles.warningList = warningList;

%str1 = strcat('MRC Laboratory of Molecular Biology.', {' '}, '21-Aug-2012 17:25:40', {' '}, 'Schafer group');
str1 = strcat('MRC Laboratory of Molecular Biology.', {' '}, datestr(now), {' '}, 'Schafer group');

%datestr(now)
set(handles.disclaimerTxt,'String',str1{1});

%version check
set(handles.versiontxt,'String','1.3');

handles.newVersion = 0;





% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main_GUI_automatic wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_GUI_automatic_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%set close request function
set(handles.figure1,'CloseRequestFcn',@closeGUI);
%close if decided to download new version
if handles.newVersion
    delete(gcf);
	close all;
end

% --- Executes on button press in preferences.
function preferences_Callback(hObject, eventdata, handles)
% hObject    handle to preferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
try
    %preferences();
    
    % Filters for obsolete preference data
%     if isfield(handles.prefData, 'bgsubtract')
%         handles.prefData = rmfield(handles.prefData, 'bgsubtract');
%     end
    
    prefData = preferences(handles.prefData);
    handles.prefData = prefData;
    guidata(hObject, handles);
catch ME1
    error(strcat('Preferences could not be started!',ME1.message));
end

% --- Executes on button press in featureHelperTools.
function featureHelperTools_Callback(hObject, eventdata, handles)
% hObject    handle to featureHelperTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%this script starts featureHelperTools worm feature extraction GUI
try
    module3control();
catch ME1
    msgString = getReport(ME1);
    msgbox(msgString);
    error('Module3 worm feature extraction could not be started!\n');
end

% --- Executes on button press in wormDiag.
function wormDiag_Callback(hObject, eventdata, handles)
% hObject    handle to wormDiag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%this script starts wormDiagnostics GUI

try
    wormDiagnostics();
catch ME1
    msgString = getReport(ME1);
    msgbox(msgString);
    error('WormDiagnostics could not be started!\n');
end

% --- Executes on button press in wormViewer.
function wormViewer_Callback(hObject, eventdata, handles)
% hObject    handle to wormViewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    data_viewer();
catch ME1
    msgString = getReport(ME1, 'extended','hyperlinks','off');
    set(handles.disclaimerTxt,'String',msgString);
    error(strcat('WormViewer could not be started!',msgString));
end


% --- Executes on button press in statusReport.
function statusReport_Callback(hObject, eventdata, handles)
% hObject    handle to statusReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    analysisStatus();
catch ME1
    msgString = getReport(ME1);
    msgbox(msgString);
    error('Status report window could not be started!\n');
end

%here we will close the GUI correctly
function closeGUI(hObject, eventdata)
%src is the handle of the object generating the callback (the source of the event)
%evnt is the The event data structure (can be empty for some callbacks)

selection = questdlg('Do you want to close main window?     ',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes'
        set(0,'ShowHiddenHandles','on');
        delete(get(0,'Children'));
        close all;
    case 'No'
        return;
end
%end closeGUI --------------------------


% --- Executes on button press in about.
function about_Callback(hObject, eventdata, handles)
% hObject    handle to about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
about();

% --- Executes on button press in startAnalysis.
function startAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to startAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    progress_verbose(handles.prefData, handles.warningList);  
catch ME1
    msgString = getReport(ME1);
    msgbox(msgString);
    error('Analysis could not be started!\n');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
