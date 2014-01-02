function varargout = data_viewer(varargin)
% DATA_VIEWER MATLAB code for data_viewer.fig
%      DATA_VIEWER, by itself, creates a new DATA_VIEWER or raises the existing
%      singleton*.
%
%      H = DATA_VIEWER returns the handle to a new DATA_VIEWER or the handle to
%      the existing singleton*.
%
%      DATA_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_VIEWER.M with the given input arguments.
%
%      DATA_VIEWER('Property','Value',...) creates a new DATA_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help data_viewer

% Last Modified by GUIDE v2.5 29-Aug-2012 13:11:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @data_viewer_OpeningFcn, ...
    'gui_OutputFcn',  @data_viewer_OutputFcn, ...
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


% --- Executes just before data_viewer is made visible.
function data_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_viewer (see VARARGIN)

% Choose default command line output for data_viewer
handles.output = hObject;

% create a placeholder for text data
txt1 = uicontrol('String', '', 'Units', 'normalized', 'Style', 'Edit',...
    'Tag', 'resultText1', 'HorizontalAlignment', 'left', 'Position', [0.15 0.75 .4 .05], 'BackgroundColor',  [.925 .914 .847]);
set(txt1, 'visible', 'off');

%plot(handles.axes1, 1,1);
%plot(handles.axes2, 1,1);
%plot(handles.histAxes, 1,1);
%plot(handles.pathAxes, 1,1);

%set(handles.axes1, 'NextPlot', 'replacechildren');
%set(handles.axes2, 'NextPlot', 'replacechildren');
%set(handles.histAxes, 'NextPlot', 'replacechildren');
%set(handles.pathAxes, 'NextPlot', 'replacechildren');


set(gcf, 'DoubleBuffer', 'on');

set(handles.colourContour, 'enable', 'off');
set(handles.toggleROI, 'enable', 'off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes data_viewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = data_viewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadData.
function loadData_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% -------------------------------------------------------------------------
% Here we will load the feature data for display
% -------------------------------------------------------------------------

mydata = guidata(hObject);

% Define constants
mydata.NOOFPOINTS = 49;
blockSize = 500;

% Get the feature file
[featureFile, featureDir] = uigetfile('','Select a _feature.mat file!');
if ~ischar(featureFile) || ~ischar(featureDir)
    % Exit function if pressed cancel
    return;
end

% Combine to full path
featureFileName = fullfile(featureDir, featureFile);
mydata.fname = featureFileName;

[~, expName] = fileparts(featureFileName);
expName = strrep(expName,'_features','');
% Update GUI
set(handles.experimentName, 'String', expName);


segNormInfoFlag = 0;

% if ~exist(segNormInfoFile, 'file')
% %-------------------------- LOAD NORM WORMS THROUGH NETWORK----------------
% try
%     info = [];
%     load(featureFileName, 'info');
%     
%     ind1 = strfind(info.files.computer,'/');
%     computerName = info.files.computer(1:ind1(1)-1);
%     
%     [netDir, netFile] =fileparts(info.files.video);
%     ind2 = strfind(netDir, 'Worm Videos');
%     if isempty(ind2)
%         ind2 = strfind(netDir, 'worm videos');
%     end
%     if isempty(ind2)
%         ind2 = strfind(netDir, 'Worm videos');
%     end
%     if isempty(ind2)
%         ind2 = strfind(netDir, '!worm_videos');
%     end
%     netPath = ['\\',computerName,'\',netDir(ind2(1):end),'\','results','\',netFile,'_features.mat'];
%     featureFileName = netPath;
%     
%     %featureFileName
%     %mydata.fname
%     % % Get experiment video file
%     % if strfind(featureFileName, '_features')
%     %     expName = strrep(featureFile, '_features.mat', '');
%     %     % check if this entry exists in the database table
%     %     sqlString = ['select computerName, avipathpc from segmentationExperimentList where avipathpc like ''%',expName,'%'';'];
%     %     curs = exec(conn, sqlString);
%     %     curs = fetch(curs);
%     %     expLocation = curs.Data;
%     %     close(curs);
%     %     close(conn);
%     %     computerName = expLocation{1};
%     %     localPath = expLocation{2};
%     %
%     %     fId = strfind(computerName, '/');
%     %     if ~isempty(fId)
%     %         computerName = computerName(1:fId(1)-1);
%     %     end
%     %     fId2 = strfind(localPath, 'Worm videos');
%     %     if ~ isempty(fId2)
%     %         localPath = strrep(localPath(fId2(1):end),'/','\');
%     %     end
%     %     if ~isempty(computerName) && ~isempty(localPath)
%     %         expGlobalPath = ['\\',computerName,'\',localPath];
%     %     end
%     %
%     %     % Get normWormInfo file
%     %     [expDirName, expName]=fileparts(expGlobalPath);
%     %     segNormInfoFile = [expDirName, ['\.data\',expName,'_seg', '\normalized\segNormInfo.mat']];
%     %     %segNormInfoFile = fullfile(featureDir, expName, 'segNormInfo.mat');
%     % end
% catch ME1 
%     msgString = getReport(ME1, 'extended','hyperlinks','off');
%     msgbox(msgString);
%     return;
% end
% end
% segNormInfoFlag = 1;


% Load feture data
worm = [];
load(mydata.fname, 'worm');
mydata.skeleton = worm.posture.skeleton;

%--------------------------------------------------------------------------
% This function will clean up worm data, remove values that should not be
% displayed in the viewer etc
%--------------------------------------------------------------------------
pathCoordinates = worm.path.coordinates;
wormFormatted = formatWormData(worm);
worm = wormFormatted; %#ok<NASGU>

% Work on info structure
info = [];
load(mydata.fname, 'info');

infoFormatted = info;
infoFormatted.wt2 = rmfield(infoFormatted.wt2, 'annotations');
infoFormatted.video = rmfield(infoFormatted.video, 'annotations');
infoFormatted.experiment.worm = rmfield(infoFormatted.experiment.worm, 'annotations');
infoFormatted.experiment.environment = rmfield(infoFormatted.experiment.environment, 'annotations');
infoFormatted.lab = rmfield(infoFormatted.lab, 'annotations');

wormFormatted.experimentInfo = infoFormatted;
mydata.featureData = wormFormatted;
mydata.featureInfo = info;

% Define the dimensions of the video frame
myAviInfo.height = info.video.resolution.height;
myAviInfo.width = info.video.resolution.width;
mydata.myAviInfo = myAviInfo;


%listElements = fields(featureData);
%new_list_size = size(listElements);
%new_val = new_list_size(1,1);
%set(handles.listbox1, 'Value', new_val);
%set(handles.listbox1, 'String', listElementsPost);

%--------------------------------------------------------------------------
% Create java uitree
%--------------------------------------------------------------------------
fig = gcbf;

%exploreWormStruct(info, worm, fig);
exploreWormStruct(info, wormFormatted, fig);

%--------------------------------------------------------------------------
% Darw centroid plot
%--------------------------------------------------------------------------
mydata.BLOCKSIZE = blockSize;

mydata.segNormInfoFlag = segNormInfoFlag;
% Get stage movement data

%-------------------- DRAW CENTROID ---------------------------------------

mydata.lenArray = [];
centroids = [pathCoordinates.x; pathCoordinates.y]';
pixel2MicronScale(1,1) = info.video.resolution.micronsPerPixels.x;
pixel2MicronScale(1,2) = info.video.resolution.micronsPerPixels.y;


% rotate and process centroid data
signVal = sign([-pixel2MicronScale(1,1), pixel2MicronScale(1,2)]);
centorids2 = [centroids(:,2) * signVal(1,2), centroids(:,1) * signVal(1,1)];
centroids = centorids2;
mydata.centroids = centroids;
mydata.signVal = signVal;
% Plot it
%set(gca,'NextPlot','replacechildren');

pathPanel = findobj(0, 'Tag','wormPath');
pathAxes = findobj(pathPanel, 'Type','axes');
delete(pathAxes);

pathAxes = axes(...    % Axes for plotting the selected plot
    'Parent', pathPanel, ...
    'Tag', 'pathAxes',...
    'Units', 'normalized', ...
    'HandleVisibility','callback', ...
    'Position',[0.11 0.17 0.80 0.67]);

plot(pathAxes, mydata.centroids(:,2), mydata.centroids(:,1), 'Color', [.8 .8 .8], 'LineWidth', 2);
xlabel(pathAxes, 'X Location (Microns)');
ylabel(pathAxes, 'Y Location (Microns)');
set(pathAxes, 'DataAspectRatio',[1 1 1]);

xLimData = [nanmin(centroids(:,2)), nanmax(centroids(:,2))];
xScaleFactor = abs(diff(xLimData))/5;
yLimData = [nanmin(centroids(:,1)), nanmax(centroids(:,1))];
yScaleFactor = abs(diff(yLimData))/5;
mydata.xLimData = [xLimData(1,1)-xScaleFactor, xLimData(1,2)+xScaleFactor];
mydata.yLimData = [yLimData(1,1)-yScaleFactor, yLimData(1,2)+yScaleFactor];
xlim(pathAxes, mydata.xLimData);
ylim(pathAxes, mydata.yLimData);

validCentroids = [centroids(~isnan(centroids(:,1)),1), centroids(~isnan(centroids(:,2)),2)];
mydata.startCentroids = [validCentroids(1, 2), validCentroids(1, 1)];
mydata.endCentroids = [validCentroids(end, 2), validCentroids(end, 1)];
set(mydata.figure1,'CurrentAxes',pathAxes);
text(mydata.startCentroids(1, 1), mydata.startCentroids(1, 2),'Start', 'Color', [0, 51/255, 102/255]);
text(mydata.endCentroids(1, 1), mydata.endCentroids(1, 2),'End', 'Color', [0, 51/255, 102/255]);
%set(mydata.figure1,'CurrentAxes', mydata.axes1);

% Deal with mydata global GUI data variable
guidata(hObject, mydata);
%hAxes = get(get(event_obj,'Target'),'Parent');
panelAxes = findall(gcf, 'tag', 'timeSeriesPanel');
setappdata(panelAxes,'mydata',mydata);

timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
axesHandles = findobj(timeSeriesPanel, 'Type','axes');
delete(axesHandles);

histPanel = findobj(0, 'Tag','histPanel');
axesHandles = findobj(histPanel, 'Type','axes');
delete(axesHandles);
aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
set(aggregateStatsHandle, 'string', '');


%--------------------------------------------------------------------------
% Matlab java uitree functions
%--------------------------------------------------------------------------

function exploreWormStruct(info, worm, fig)
% This code has been adapted from Matlab Central contribution by Hassan
% Lahili. The original license and the header can be found below.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CRC - ExploreStruct v1.1,
% MatLab Utility for exploring structures and plotting their fields
% Syntax: explorestruct(S), where S is structure, array of strctures or nested structures
%
% Hassan Lahdili (hassan.lahdili@crc.ca)
% Communications Research Centre (CRC) | Advanced Audio Systems (AAS)
% www.crc.ca | www.crc.ca/aas
% Ottawa. Canada
% CRC Advanced Audio Systems - Ottawa © 2004-2005
% 16/02/2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isstruct(worm) || ~isstruct(info)
    msgerror = strcat('Input variable is not a structure! Please check the ',...
        'input of exploreWormStruct funcion.');
    error(msgerror);
end

import javax.swing.*;

structInfo = whos('worm');
name = structInfo.name;
% this creates the initial node
root = uitreenode('v0', name, name, [], false);
% Initialize the tree
tree = uitree('v0', fig, 'Root', root, 'ExpandFcn', @myExpfcn);
drawnow;

% Define other callback functions
xOffset = 0.005;
% Offset for y is from the bottom of the figure
yOffset = 0.09-0.071;
tWidth = 0.125;
tHeight = 0.91;
set(tree, 'Units', 'normalized', 'position', [xOffset yOffset tWidth tHeight])
set(tree, 'NodeWillExpandCallback', @nodeWillExpand);
set(tree, 'NodeSelectedCallback', @nodeSelected);

tmp = tree.FigureComponent;
cell_Data = cell(2,1);
cell_Data{1} = worm;

set(tmp, 'UserData', cell_Data);

% t = tree.Tree;
% set(t, 'MousePressedCallback', @mouse_cb);
%
% function mouse_cb(t, ev)
%         if ev.getModifiers()== ev.META_MASK
%             pUpMenu.show(t, ev.getX, ev.getY);
%             pUpMenu.repaint;
%         end

function cNode = nodeSelected(tree, value)
% This function will be called when the user selects a node in the tree
%
cNode = value.getCurrentNode;
tmp = tree.FigureComponent;
cell_Data = get(tmp, 'UserData');
cell_Data{2} = cNode;
s = cell_Data{1};
val = s;
plotted = cNode.getValue;
selected = plotted;
[val, plotted, cNode, isLeafNodeVal] = getcNodevalue(cNode, val);
%set(txt1, 'string', selected)
%set(txt2, 'string', strcat(num2str(size(val,1)),'x',num2str(size(val,2))) )
%set(txt3, 'string', class(val))
set(tmp, 'UserData', cell_Data);

stopFlagHandle = findobj(0, 'Tag','stopFlag');
timeSeriesPanel = findall(gcf, 'tag', 'timeSeriesPanel');
mydata = getappdata(timeSeriesPanel, 'mydata');
%toggleStopValue = str2double(get(handles.stopFlag, 'String'));
toggleStopValue = str2double(get(mydata.stopFlag, 'string'));
if ~toggleStopValue
    set(stopFlagHandle, 'String', num2str(1));
    set(mydata.stopFlag,'String', num2str(1));
end
setappdata(timeSeriesPanel, 'mydata', mydata);


if strcmpi(plotted, 'locomotion.turns.omegas') || ...
        strcmpi(plotted, 'locomotion.turns.upsilons') || ...
        strcmpi(plotted, 'locomotion.motion.paused') || ...
        strcmpi(plotted, 'locomotion.motion.backward') || ...
        strcmpi(plotted, 'locomotion.motion.forward') || ...
        strcmpi(plotted, 'locomotion.motion.mode') || ...
        strcmpi(plotted, 'posture.coils')
    
    if get(mydata.eventViewToggle, 'Value') || strcmpi(plotted, 'locomotion.motion.mode')
        plotWormEvents(val, plotted);
    else
        plotWormEventsAlternate(val, plotted);
    end
    
    return;
end

if strcmpi(plotted, 'path.duration')
    plotPathDuration(val, plotted);
    return;
end

if isLeafNodeVal
    plotSelectedData(val, plotted);
end

function cNode = nodeWillExpand(tree, value)
cNode = value.getCurrentNode;
tmp = tree.FigureComponent;
cell_Data = get(tmp, 'UserData');
cell_Data{2} = cNode;
set(tmp, 'UserData', cell_Data);


function [val, displayed, cNode, isLeafNodeVal] = getcNodevalue(cNode, s)

isLeafNodeVal = cNode.isLeafNode;

fields = {};
while cNode.getLevel ~= 0
    fields = [fields; cNode.getValue];
    c = findstr(cNode.getValue, '(');
    if ~isempty(c) && cNode.getLevel ~=0
        cNode = cNode.getParent;
    end
    
    if  cNode.getLevel ==0, break; end
    cNode = cNode.getParent;
end
val = s;
if ~isempty(fields)
    L=length(fields);
    displayed = fields{L};
    for j = L-1:-1:1, displayed = strcat(displayed, '.', fields{j}); end
    for i=L:-1:1
        field = fields{i};
        d = findstr(field,'(');
        if ~isempty(d)
            d2 = findstr(field,')');
            idx = str2num(field(d+1:d2-1));
            
            field = field(1:d-1);
            if (strcmp(field, cNode.getValue))
                val = val(idx);
            else
                val = getfield(val, field, {idx});
            end
        else
            val = getfield(val, field);
        end
    end
else
    displayed = cNode.getValue;
    return;
end

function nodes = myExpfcn(tree, value)
% ..
try
    tmp = tree.FigureComponent;
    % Get the data
    S = get(tmp, 'UserData');
    % Access first struct out of structs cell array
    s = S{1};
    cNode = S{2};
    
    [val, ~, cNode,~] = getcNodevalue(cNode, s);
    fnames = fieldnames(val);
    
    L = length(val);
    count = 0;
    if L > 1
        
        for J = 1:L
            count = count + 1;
            cNode = S{2};
            fname = strcat(cNode.getValue, '(', num2str(J),')');
            nodes(count) =  uitreenode('v0', fname, fname, [], 0);
        end
    else
        %
        for i=1:length(fnames)
            count = count + 1;
            x = getfield(val, fnames{i});
            if isstruct(x)
                if length(x) > 1
                    
                else
                    
                end
            elseif isnumeric(x)
                
            elseif iscell(x)
                
            elseif ischar(x)
                
            elseif islogical(x)
                
            elseif isobject(x)
                
            else
                
            end
            nodes(count) = uitreenode('v0', fnames{i}, fnames{i}, [], ~isstruct(x));
        end
    end
    
catch ME1
    error(['The uitree node type is not recognized. ' ...
        ' You may need to define an ExpandFcn for the nodes.']);
end
if (count == 0)
    nodes = [];
end


function plotSelectedData(wormData, item_selected)
% This function will be called to plot the selected tree node data

panelAxes = findall(gcf, 'tag', 'timeSeriesPanel');
mydata = getappdata(panelAxes, 'mydata');

labelInfo = wormDisplayInfo;

listboxHandles = findobj(0, 'Style','listbox');
delete(listboxHandles);

try
    [plotTitle, legendLabels, yAxesLabel, xAxesLabel, valUnit] = ...
    getLabel(labelInfo, item_selected);
    if isempty(wormData)
        wormData = 'not specified';
    end
catch ME1
    plotTitle = [];
    legendLabels = {};
    yAxesLabel = {};
    xAxesLabel ={};
    valUnit = {};
    
    if isempty(wormData)
        wormData = 'not specified';
    end
    
    if strcmpi(item_selected, 'posture.eigenProjections.first')
        annotationData = labelInfo.posture.eigenProjection(1);
        plotTitle = ['Worm ', annotationData.name];
        legendLabels = {annotationData.name};
        yAxesLabel = {[annotationData.name ' (' annotationData.unit ')']};
        xAxesLabel = {'Frames'};        
    elseif strcmpi(item_selected, 'posture.eigenProjections.second')
        annotationData = labelInfo.posture.eigenProjection(2);
        plotTitle = ['Worm ', annotationData.name];
        legendLabels = {annotationData.name};
        yAxesLabel = {[annotationData.name ' (' annotationData.unit ')']};
        xAxesLabel = {'Frames'};        
    elseif strcmpi(item_selected, 'posture.eigenProjections.third')
        annotationData = labelInfo.posture.eigenProjection(3);
        plotTitle = ['Worm ', annotationData.name];
        legendLabels = {annotationData.name};
        yAxesLabel = {[annotationData.name ' (' annotationData.unit ')']};
        xAxesLabel = {'Frames'};
    elseif strcmpi(item_selected, 'posture.eigenProjections.fourth')
        annotationData = labelInfo.posture.eigenProjection(4);
        plotTitle = ['Worm ', annotationData.name];
        legendLabels = {annotationData.name};
        yAxesLabel = {[annotationData.name ' (' annotationData.unit ')']};
        xAxesLabel = {'Frames'};    
    elseif strcmpi(item_selected, 'posture.eigenProjections.fifth')
        annotationData = labelInfo.posture.eigenProjection(5);
        plotTitle = ['Worm ', annotationData.name];
        legendLabels = {annotationData.name};
        yAxesLabel = {[annotationData.name ' (' annotationData.unit ')']};
        xAxesLabel = {'Frames'};        
    elseif strcmpi(item_selected, 'posture.eigenProjections.sixth')
        annotationData = labelInfo.posture.eigenProjection(6);
        plotTitle = ['Worm ', annotationData.name];
        legendLabels = {annotationData.name};
        yAxesLabel = {[annotationData.name ' (' annotationData.unit ')']};
        xAxesLabel = {'Frames'};        
    elseif strcmpi(item_selected, 'experimentInfo.video.length.frames')
        valUnit = {'frames'};   
     elseif strcmpi(item_selected, 'experimentInfo.video.length.time')
        valUnit = {'seconds'};
    elseif strcmpi(item_selected, 'experimentInfo.video.resolution.fps')
        valUnit = {'fps'};
	elseif strcmpi(item_selected, 'experimentInfo.video.resolution.height') ...
            || strcmpi(item_selected, 'experimentInfo.video.resolution.width') 
        valUnit = {'pixel'};
    elseif strcmpi(item_selected, 'experimentInfo.video.resolution.micronsPerPixels.x') ...
            || strcmpi(item_selected, 'experimentInfo.video.resolution.micronsPerPixels.y') 
        valUnit = {'microns'};
    end
end

if ~ischar(wormData)
    frameX = 1:length(wormData);
else
    frameX = 1;
end

% if display value is only one
if isempty(frameX)
	panelHandle = findobj(gcf, 'Tag','timeSeriesPanel');
    axesHandles = findobj(panelHandle, 'Type','axes');
    delete(axesHandles);
    
    visibilityStatus = get(panelHandle, 'visible');
    if strcmpi(visibilityStatus, 'off')
        set(panelHandle, 'visible', 'on');
    end
    
    histPanelHandle = findobj(gcf, 'Tag','histPanel');
    axesHandles = findobj(histPanelHandle, 'Type','axes');
    delete(axesHandles);
    aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
    set(aggregateStatsHandle, 'string', '');

    
    resultText1Handle = findobj(gcf, 'Tag','resultText1');
    set(resultText1Handle, 'visible', 'off');

    imgPanelHandle = findobj(gcf, 'Tag','imgPanel');
    axesHandles = findobj(imgPanelHandle, 'Type','axes');
    delete(axesHandles);
    
elseif length(frameX) == 1
    panelHandle = findobj(gcf, 'Tag','timeSeriesPanel');
    axesHandles = findobj(panelHandle, 'Type','axes');
    delete(axesHandles);
    
    set(panelHandle, 'visible', 'off');
    
    resultText1Handle = findobj(gcf, 'Tag','resultText1');
    set(resultText1Handle, 'visible', 'on');
    
    if ischar(wormData)
        displayString = strcat(item_selected, ':',{' '},wormData, {' '}, valUnit);
    else
        displayString = strcat(item_selected, ':',{' '},num2str(wormData), {' '}, valUnit);
    end
        
    set(resultText1Handle, 'string', displayString);
    
    histPanelHandle = findobj(gcf, 'Tag','histPanel');
    axesHandles = findobj(histPanelHandle, 'Type','axes');
    delete(axesHandles);
    aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
    set(aggregateStatsHandle, 'string', '');
    
    imgPanelHandle = findobj(gcf, 'Tag','imgPanel');
    axesHandles = findobj(imgPanelHandle, 'Type','axes');
    delete(axesHandles);
    
    % Locate the histogram axes handle
    % histAxesHandle = findobj(gcf, 'Tag','histAxes');
else
    
    % Here we will apply several filters for worm data
    if strcmpi(item_selected, 'posture.directions.tail2head')
        % convert from image space to coordinate space

        wormData = mod(wormData*mydata.signVal(2),360);
        
        windowSize = round(mydata.featureInfo.video.resolution.fps);
        newData = nan(1, length(wormData));
        for i=windowSize+1:length(wormData)- windowSize;
            newData(i) = wormData(i+windowSize) - wormData(i-windowSize);
        end
        wormData = newData;
        %wormData = diff(wormData);
        for i=1:length(wormData)
            if wormData(i)>180
                wormData(i) = wormData(i) - 360;
            elseif wormData(i)<-180
                wormData(i) = wormData(i) + 360;
            else
                1;
            end
        end
        
        X = wormData;
        X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)));
        wormData = X;
                

        %wormData(wormData<0) = wormData(wormData<0) + 180;

        %wormData = mod(wormData*-1,360);
%         data = wormData;
%         
%         size2 = length(data);
%         lookup1 = 1:size(data,2);
%         nanLabel = isnan(wormData);
%         
%         dataFiltered1 = wormData(~nanLabel);
%         diffDataFiltered1 = [NaN, diff(dataFiltered1)];
%         
%         dataLabels = lookup1(~nanLabel);
%         
%         newData = nan(1,size2);
%         
%         newData(dataLabels) = diffDataFiltered1;
%         
%         wormData = newData;
        
    end
    timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
    axesHandles = findobj(timeSeriesPanel, 'Type','axes');
    delete(axesHandles);
    
    % check if handle visiblity is off
    visibilityStatus = get(timeSeriesPanel, 'visible');
    if strcmpi(visibilityStatus, 'off')
        set(timeSeriesPanel, 'visible', 'on');
    end
    
    resultText1Handle = findobj(0, 'Tag','resultText1');
    set(resultText1Handle, 'visible', 'off');
    panelHandle = findobj(gcf, 'Tag','uipanel4');
    set(panelHandle, 'visible', 'on');
    
    %plot normal plot
    %plotyy(frameX, wormData);
    %set(gca,'NextPlot','replacechildren');
    if size(wormData,1) < size(wormData,2)
        wormData = wormData';
    end
    hPlotAxes = axes(...    % Axes for plotting the selected plot
        'Parent', timeSeriesPanel, ...
        'Tag', 'axes1',...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'Position',[0.11 0.17 0.80 0.67]);
    
    plotHandle = plot(hPlotAxes, wormData);
    mydata.plotHandle = plotHandle;
    
    % hleg = legend(hPlotAxes, legendLabels, 'Location','Best');
    
    if ~all(isnan(wormData))
        if  nanmin(nanmin(wormData)) < 0
            maxVal = nanmax(nanmax(wormData));
            minVal = nanmin(nanmin(wormData));
            meanVal = nanmean(nanmean(wormData));
            axis([1, length(wormData), minVal - abs(meanVal)/3, maxVal + abs(meanVal)/3]);
        else
            maxVal = nanmax(nanmax(wormData));
            meanVal = nanmean(nanmean(wormData));
            axis([1, length(wormData), 0, maxVal + meanVal/3]);
        end
    end
    %set(hPlotAxes, 'XTick', 0:1000:length(wormData));
    
    xlabel(hPlotAxes, xAxesLabel{1});
    ylabel(hPlotAxes, yAxesLabel{1});
    title(hPlotAxes, plotTitle);
    %zoom(hPlotAxes, 'xon');
    set(hPlotAxes, 'XTick',1:round(length(wormData)/7):length(wormData));
    set(hPlotAxes, 'Tag','axes1');
    % Plot histogram
    %---------------
    if ~all(isnan(wormData))
        histPanel = findobj(0, 'Tag','histPanel');
        axesHandles = findobj(histPanel, 'Type','axes');
        delete(axesHandles);
        aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
        set(aggregateStatsHandle, 'string', '');
        
        DATA = wormData;
        VERBOSE = 0;
        statMode = 2;
        HISTDATA = histogram(DATA, [], [], [], VERBOSE);
        
        histColor = [118/255 106/255 98/255];
        statColor = [0.7 0.2 0.1];
        
        histAxes = axes(...    % Axes for plotting the selected plot
            'Parent', histPanel, ...
            'Tag', 'histAxes',...
            'Units', 'normalized', ... %            'HandleVisibility','callback', ...
            'Position',[0.18 0.43 0.70 0.50]);
        
        %set(gcf,'CurrentAxes', histAxes);
        plotHistogram(HISTDATA, '', 'Value', [], '', ...
            histColor, statColor, 1, statMode);
        
        %Fix the alpha
        patchHandles = findobj(0, 'Type','Patch');
        set(patchHandles(1), 'FaceAlpha', 1);
        
        legendLabel = legendLabels{1};
        % Construct the summary statistics legend.
        if ~isempty(statColor)
            legends{1} = legendLabel;
            legends{2} = ['Data samples N = ' num2str(HISTDATA.data.samples) ','];
            legends{3} = ['Mean = ' num2str(HISTDATA.data.mean.all) ','];
            legends{4} = ['Standard Deviation = ' ...
                num2str(HISTDATA.data.stdDev.all)];
            
            if HISTDATA.isSigned
                legends{4} = [legends{4} ','];
                legends{5} = ['Absolute Mean = ' ...
                    num2str(HISTDATA.data.mean.abs) ','];
                legends{6} = ['Absolute Standard Deviation = ' ...
                    num2str(HISTDATA.data.stdDev.abs) ','];
                
                legends{7} = ['Positive Data Mean = ' ...
                    num2str(HISTDATA.data.mean.pos) ','];
                legends{8} = ['Positive Data Standard Deviation = ' ...
                    num2str(HISTDATA.data.stdDev.pos) ','];
                
                legends{9} = ['Negative Data Mean = ' ...
                    num2str(HISTDATA.data.mean.neg) ','];
                legends{10} = ['Negative Data Standard Deviation = ' ...
                    num2str(HISTDATA.data.stdDev.neg)];                
            end
        end
        
        resultText1Handle = findobj(0, 'Tag','agregateStats');
        set(resultText1Handle, 'string', legends);
        
        % Display the legend.
        %legendHandle = legend(legends, 'Location', 'SouthEastOutside');
        %set(legendHandle, 'LineWidth', 1.5);
        %set(legendHandle, 'LineWidth', 1.5);
        %set(legendHandle, 'FontSize', 8);
        % -------------------------------------------------------------------------
        % Old Histogram
        %         minData = nanmin(wormData);
        %         maxData = nanmax(wormData);
        %         if length(minData)>1
        %             minData = nanmin(minData);
        %         end
        %         if length(maxData)>1
        %             maxData = nanmax(maxData);
        %         end
        %         % Lets check if minData and maxData variables are not the same
        %         if minData == maxData
        %             minData = minData - minData/2;
        %             maxData = maxData + maxData/2;
        %         end
        %         %timeX = 1:length(wormData) / fps;
        %         timeX = 1:length(wormData);
        %         if sign(minData) == sign(maxData)
        %             bins = linspace(minData, maxData, sqrt(length(timeX)));
        %         else % align the bins with 0
        %             binWidth = (maxData - minData) / sqrt(length(timeX));
        %             minBins = binWidth:binWidth:(abs(minData) + binWidth);
        %             maxBins = 0:binWidth:(maxData + binWidth);
        %             bins = [-fliplr(minBins) maxBins];
        %         end
        %         histData = histc(wormData, bins)';
        %         %set(gca,'NextPlot','replacechildren');
        %         plot(bins, histData);
        %         binsFill = [bins(1),bins,bins(end)];
        %         if size(histData,1) > 1
        %             histDataFill = [zeros(size(histData,1),1),histData,zeros(size(histData,1),1)];
        %             hold on;
        %             for j=1:size(histData,1)
        %                 %[104,172,207]/255
        %                 colourVal = rand(1,3);
        %                 fill(binsFill, histDataFill(j,:), colourVal);
        %             end
        %             hold off;
        %         else
        %             histDataFill = [0,histData,0];
        %             fill(binsFill,histDataFill,[104,172,207]/255);
        %         end
        %         %hist(diffData{i}{j}', sqrt(length(timeX)));
        %         xlim([minData maxData]);
        %         xlabel(yAxesLabel{1});
        %         ylabel('Count');
    else
        cla(histAxesHandle);
    end
end
%alpha(1);
% Send information to the figure handle
dcm_obj = datacursormode(gcf);
setappdata(panelAxes, 'mydata', mydata);

%dcm_obj = datacursormode(axes1Handle);
%setappdata(gca,'mydata', mydata);
%setappdata(dcm_obj,'mydata', mydata);
datacursormode on;
set(dcm_obj, 'UpdateFcn', @myupdatefcn);


function plotWormEvents(eventData, eventLabel)
% PLOTWORMEVENTS This function will plot worm events from posture and
% locomotion data
%
% Input:
%   eventData - data for the event, contains subfields - franes, frequency,
%   ratio
%   eventLabel - location of the struct which corresponds with the data
%   above

timeSeriesPanel = findall(gcf, 'tag', 'timeSeriesPanel');
mydata = getappdata(timeSeriesPanel, 'mydata');

% check if handle visiblity is off
visibilityStatus = get(timeSeriesPanel, 'visible');
if strcmpi(visibilityStatus, 'off')
    resultText1Handle = findobj(0, 'Tag','resultText1');
    set(resultText1Handle, 'visible', 'off');
    set(timeSeriesPanel, 'visible', 'on');
end

totalFrames = mydata.featureInfo.video.length.frames;
fps = mydata.featureInfo.video.resolution.fps;

listboxHandles = findobj(0, 'Style','listbox');
delete(listboxHandles);

switch eventLabel
    case 'locomotion.motion.forward'
        forwardFrames = eventData.frames;
        % Display the forward motion.
        % Display the forward motion histogram.
        isForwardFrame = events2array(forwardFrames, totalFrames); % for your GUI
        forwardStats4Plots = removePartialEvents(forwardFrames, totalFrames);
        
        if ~isempty(forwardStats4Plots)
            histData = histogram([forwardStats4Plots.distance]);
            % get the panel ready
            histPanel = findobj(0, 'Tag','histPanel');
            axesHandles = findobj(histPanel, 'Type','axes');
            delete(axesHandles);
            aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
            set(aggregateStatsHandle, 'string', '');
            
            histAxesHandles = axes(...    % Axes for plotting the selected plot
                'Parent', histPanel, ...
                'Tag', 'histAxes',...
                'Units', 'normalized', ... %            'HandleVisibility','callback', ...
                'Position',[0.18 0.43 0.70 0.50]);
            
            if ~isempty(forwardStats4Plots)
                histColor = [118/255 106/255 98/255];
                plotHistogram(histData, 'Forward Motion Events Histogram', ...
                    'Forward Event Distance (microns)', ...
                    'Forward Event Distance', [], histColor);
            end
            
            %set(legendHandle, 'LineWidth', 1.5);
            %set(legendHandle, 'LineWidth', 1.5);
            %set(legendHandle, 'FontSize', 8);
            % Display the forward motion plot.
            
            if ~isempty(forwardStats4Plots)
                
                timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
                axesHandles = findobj(timeSeriesPanel, 'Type','axes');
                delete(axesHandles);
                
                %delete(timeSeriesAxesHandle1)
                timeSeriesAxesHandle1 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.66 0.8 0.2]);

                states(2) = struct( ...
                    'fieldName', 'interDistance', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'distance';
                states(1).isInterEvent = false;
                eventNames = {'Forward Motion', 'Not Forward Motion'};
                [timeAxis1, frameAxis1] = plotEvent(forwardFrames, totalFrames, fps, ...
                    'Forward Motion Distance', 'Forward Distance (microns)', ...
                    eventNames, @event2Box, states, str2colors('gr', -0.1));
                
                % Plot time vs. inter time.
                
                timeSeriesAxesHandle2 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.138 0.8 0.2]);
                
                %axes(timeSeriesAxesHandle2);
                %timeSeriesAxesHandle2 = subplot(2,1,2, 'Parent', timeSeriesPanel);
                
                
                states(2) = struct( ...
                    'fieldName', 'interDistance', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'time';
                states(1).isInterEvent = false;
                eventNames = {'Forward Motion', 'Not Forward Motion'};
                [timeAxis2, frameAxis2] = plotEvent(forwardFrames, totalFrames, fps, ...
                    'Forward Motion Time', 'Forward Time (seconds)', ...
                    eventNames, @event2Box, states, str2colors('gr', -0.1));
                
                % Set the tag property for both axes
                set(timeSeriesAxesHandle1, 'Tag', 'axes1');
                set(timeSeriesAxesHandle2, 'Tag', 'axes2')
                % Set the tick font size
                set(timeAxis1, 'FontSize', 8);
                set(frameAxis1, 'FontSize', 8);
                set(timeAxis2, 'FontSize', 8);
                set(frameAxis2, 'FontSize', 8);
                % Set first Y axes font size
                ax11 = get(timeAxis1);
                set(ax11.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax12 = get(frameAxis1);
                ext1 = get(ax12.YLabel, 'Extent');
                set(ax12.YLabel, 'Position', [ext1(1)+1500, ext1(3)]);
                set(ax12.YLabel, 'FontSize', 8);
                
                % Set first Y axes font size
                ax21 = get(timeAxis2);
                set(ax21.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax22 = get(frameAxis2);
                ext2 = get(ax22.YLabel, 'Extent');
                set(ax22.YLabel, 'Position', [ext2(1)+1500, ext2(3)]);
                set(ax22.YLabel, 'FontSize', 8);
                
                % No data.
            else
                xlabel('Time (seconds)');
                ylabel('Distance (microns)');
                title('Forward Motion Events');
            end
            hold off;
        end
    case 'locomotion.motion.backward'
        backwardFrames = eventData.frames;
        % Display the backward motion.
        % Display the forward motion histogram.
        isBackwardFrame = events2array(backwardFrames, totalFrames); % for your GUI
        backwardStats4Plots = removePartialEvents(backwardFrames, totalFrames);
        
        if ~isempty(backwardStats4Plots)
            histData = histogram([backwardStats4Plots.distance]);
            % Get the panel ready
            histPanel = findobj(0, 'Tag','histPanel');
            axesHandles = findobj(histPanel, 'Type','axes');
            delete(axesHandles);
            aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
            set(aggregateStatsHandle, 'string', '');
            % Create axes
            histAxesHandles = axes(...    % Axes for plotting the selected plot
                'Parent', histPanel, ...
                'Tag', 'histAxes',...
                'Units', 'normalized', ... %            'HandleVisibility','callback', ...
                'Position',[0.18 0.43 0.70 0.50]);
            
            if ~isempty(backwardStats4Plots)
                histColor = [118/255 106/255 98/255];
                plotHistogram(histData, 'Backward Motion Events Histogram', ...
                    'Backward Event Distance (microns)', ...
                    'Backward Event Distance', [], histColor);
            end
            
            % Display the backward motion plot.
            
            if ~isempty(backwardStats4Plots)
                
                timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
                axesHandles = findobj(timeSeriesPanel, 'Type','axes');
                delete(axesHandles);
                
                % create axes 1
                timeSeriesAxesHandle1 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.66 0.8 0.2]);
                
                states(2) = struct( ...
                    'fieldName', 'interDistance', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'distance';
                states(1).isInterEvent = false;
                eventNames = {'Backward Motion', 'Not Backward Motion'};
                [timeAxis1, frameAxis1] = plotEvent(backwardFrames, totalFrames, fps, ...
                    'Backward Motion Distance', 'Backward Distance (microns)', ...
                    eventNames, @event2Box, states, str2colors('gr', -0.1));
                
                % Plot time vs. inter time.
                % Create axes 2
                timeSeriesAxesHandle2 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.138 0.8 0.2]);
                
                states(2) = struct( ...
                    'fieldName', 'interTime', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'time';
                states(1).isInterEvent = false;
                eventNames = {'Backward Motion', 'Not Backward Motion'};
                [timeAxis2, frameAxis2] = plotEvent(backwardFrames, totalFrames, fps, ...
                    'Backward Motion Time', 'Backward Time (seconds)', ...
                    eventNames, @event2Box, states, str2colors('gr', -0.1));
                
                % Set the tag property for both axes
                set(timeSeriesAxesHandle1, 'Tag', 'axes1');
                set(timeSeriesAxesHandle2, 'Tag', 'axes2')
                % Set the tick font size
                set(timeAxis1, 'FontSize', 8);
                set(frameAxis1, 'FontSize', 8);
                set(timeAxis2, 'FontSize', 8);
                set(frameAxis2, 'FontSize', 8);
                % Set first Y axes font size
                ax11 = get(timeAxis1);
                set(ax11.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax12 = get(frameAxis1);
                pos1 = get(ax12.YLabel, 'Position');
                set(ax12.YLabel, 'Position', [pos1(1)+1000, pos1(2)]);
                set(ax12.YLabel, 'FontSize', 8);
                
                % Set first Y axes font size
                ax21 = get(timeAxis2);
                set(ax21.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax22 = get(frameAxis2);
                pos2 = get(ax22.YLabel, 'Position');
                set(ax22.YLabel, 'Position', [pos2(1)+1000, pos2(2)]);
                set(ax22.YLabel, 'FontSize', 8);
                
                % No data.
            else
                xlabel('Time (seconds)');
                ylabel('Distance (microns)');
                title('Backward Motion Events');
            end
            hold off;
        end
        
        
    case 'locomotion.motion.paused'
        pausedFrames = eventData.frames;
        % Display the paused motion.
        % Display the paused motion histogram.
        isPausedFrame = events2array(pausedFrames, totalFrames); % for your GUI
        pausedStats4Plots = removePartialEvents(pausedFrames, totalFrames);
        
        if ~isempty(pausedStats4Plots)
            histData = histogram([pausedStats4Plots.distance]);
            % get the panel ready
            histPanel = findobj(0, 'Tag','histPanel');
            axesHandles = findobj(histPanel, 'Type','axes');
            delete(axesHandles);
            aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
            set(aggregateStatsHandle, 'string', '');
            
            histAxesHandles = axes(...    % Axes for plotting the selected plot
                'Parent', histPanel, ...
                'Tag', 'histAxes',...
                'Units', 'normalized', ... %            'HandleVisibility','callback', ...
                'Position',[0.18 0.43 0.70 0.50]);
            
            if ~isempty(pausedStats4Plots)
                histColor = [118/255 106/255 98/255];
                plotHistogram(histData, 'Paused Motion Events Histogram', ...
                    'Paused Event Distance (microns)', ...
                    'Paused Event Distance', [], histColor);
            end
            
            % Display the paused motion plot.
            if ~isempty(pausedStats4Plots)
                
                % Plot distance vs. inter distance.
                timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
                axesHandles = findobj(timeSeriesPanel, 'Type','axes');
                delete(axesHandles);
                
                %delete(timeSeriesAxesHandle1)
                timeSeriesAxesHandle1 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.66 0.8 0.2]);
                
                
                states(2) = struct( ...
                    'fieldName', 'interDistance', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'distance';
                states(1).isInterEvent = false;
                eventNames = {'Paused Motion', 'Not Paused Motion'};
                [timeAxis1, frameAxis1] = plotEvent(pausedFrames, totalFrames, fps, ...
                    'Paused Motion Distance', 'Paused Distance (microns)', ...
                    eventNames, @event2Box, states, str2colors('gr', -0.1));
                
                % Plot time vs. inter time.
                timeSeriesAxesHandle2 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.138 0.8 0.2]);
                
                states(2) = struct( ...
                    'fieldName', 'interTime', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'time';
                states(1).isInterEvent = false;
                eventNames = {'Paused Motion', 'Not Paused Motion'};
                [timeAxis2, frameAxis2] = plotEvent(pausedFrames, totalFrames, fps, ...
                    'Paused Motion Time', 'Paused Time (seconds)', ...
                    eventNames, @event2Box, states, str2colors('gr', -0.1));
                
                
                % Set the tag propertu for both axes
                set(timeSeriesAxesHandle1, 'Tag', 'axes1');
                set(timeSeriesAxesHandle2, 'Tag', 'axes2')
                % Set the tick font size
                set(timeAxis1, 'FontSize', 8);
                set(frameAxis1, 'FontSize', 8);
                set(timeAxis2, 'FontSize', 8);
                set(frameAxis2, 'FontSize', 8);
                % Set first Y axes font size
                ax11 = get(timeAxis1);
                set(ax11.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax12 = get(frameAxis1);
                pos1 = get(ax12.YLabel, 'Position');
                set(ax12.YLabel, 'Position', [pos1(1)+1000, pos1(2)]);
                set(ax12.YLabel, 'FontSize', 8);
                
                % Set first Y axes font size
                ax21 = get(timeAxis2);
                set(ax21.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax22 = get(frameAxis2);
                pos2 = get(ax22.YLabel, 'Position');
                set(ax22.YLabel, 'Position', [pos2(1)+1000, pos2(2)]);
                set(ax22.YLabel, 'FontSize', 8);
                
                % No data.
            else
                xlabel('Time (seconds)');
                ylabel('Distance (microns)');
                title('Paused Motion Events');
            end
            hold off;
        end
        
        
    case 'locomotion.motion.mode'
        motionModes = eventData;
        
        % Display the motion modes.
        timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
        axesHandles = findobj(timeSeriesPanel, 'Type','axes');
        delete(axesHandles);
        
        hPlotAxes = axes(...    % Axes for plotting the selected plot
            'Parent', timeSeriesPanel, ...
            'Tag', 'axes1',...
            'Units', 'normalized', ...
            'HandleVisibility','callback', ...
            'Position',[0.13 0.17 0.80 0.67]);
        %hold on;
        %forwardMotionFrames = find(motionModes == 1);
        %plot(hPlotAxes, (forwardMotionFrames - 1) / fps, 1, 'r');
        %backwardMotionFrames = find(motionModes == -1);
        %plot(hPlotAxes, (backwardMotionFrames - 1) / fps, -1, 'b');
        %pausedMotionFrames = find(motionModes == 0);
        %plot(hPlotAxes, (pausedMotionFrames - 1) / fps, 0, 'k');
        plot(hPlotAxes, (0:(length(motionModes) - 1)) / fps, motionModes);
        %hold off;
        xlabel('Time (seconds)');
        ylabel('Mode');
        ylim([-2 2]);
        set(gca,'YTick', -1:1)
        set(gca,'YTickLabel',{'Backward','Paused','Forward'})
        title('Motion Events');
        
        set(hPlotAxes, 'Tag', 'axes1');
        
    case 'posture.coils'
        
        coilFrames = eventData.frames;
        
        % Display the coiled postures.
        % Display the coiled posture histogram.
        isCoilFrame = events2array(coilFrames, totalFrames); % for your GUI
        coilStats4Plots = removePartialEvents(coilFrames, totalFrames);
        
        if ~isempty(coilStats4Plots)
            histData = histogram([coilStats4Plots.time]);
            
            % get the panel ready
            histPanel = findobj(0, 'Tag','histPanel');
            axesHandles = findobj(histPanel, 'Type','axes');
            delete(axesHandles);
            aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
            set(aggregateStatsHandle, 'string', '');
            
            histAxesHandles = axes(...    % Axes for plotting the selected plot
                'Parent', histPanel, ...
                'Tag', 'histAxes',...
                'Units', 'normalized', ... %            'HandleVisibility','callback', ...
                'Position',[0.18 0.43 0.70 0.50]);
            
            if ~isempty(coilStats4Plots)
                histColor = [118/255 106/255 98/255];
                
                plotHistogram(histData, 'Coiled Posture Events Histogram', ...
                    'Coil Event Time (seconds)', ...
                    'Coil Event Time', [], histColor);
            end
            
            % Display the coiled motion plot.
            if ~isempty(coilStats4Plots)
                
                timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
                axesHandles = findobj(timeSeriesPanel, 'Type','axes');
                delete(axesHandles);
                
                %delete(timeSeriesAxesHandle1)
                timeSeriesAxesHandle1 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.66 0.8 0.2]);
                
                states = struct( ...
                    'fieldName', 'interDistance', ...
                    'height', [], ...
                    'width', [], ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                
                eventNames = 'Not Coiled';
                [timeAxis1, frameAxis1] = plotEvent(coilFrames, totalFrames, fps, ...
                    'Not Coiled Distance', 'Not Coiled Distance (microns)', ...
                    eventNames, @event2box, states, str2colors('r', -0.1), true);
                
                % Plot time vs. inter time.
                timeSeriesAxesHandle2 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.138 0.8 0.2]);
                
                states(2) = struct( ...
                    'fieldName', 'interTime', ...
                    'height', 1, ...
                    'width', [], ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'time';
                states(1).height = 1;
                states(1).width = [];
                states(1).isInterEvent = false;
                eventNames = {'Coiled', 'Not Coiled'};
                yAxisName = '';
                [timeAxis2, frameAxis2] = plotEvent(coilFrames, totalFrames, fps, ...
                    'Coiled Time', yAxisName, ...
                    eventNames, @event2box, states, str2colors('gr', -0.1));
                
                % Set the tag propertu for both axes
                set(timeSeriesAxesHandle1, 'Tag', 'axes1');
                set(timeSeriesAxesHandle2, 'Tag', 'axes2')
                % Set the tick font size
                set(timeAxis1, 'FontSize', 8);
                set(frameAxis1, 'FontSize', 8);
                set(timeAxis2, 'FontSize', 8);
                set(frameAxis2, 'FontSize', 8);
                % Set first Y axes font size
                ax11 = get(timeAxis1);
                set(ax11.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax12 = get(frameAxis1);
                pos1 = get(ax12.YLabel, 'Position');
                set(ax12.YLabel, 'Position', [pos1(1)+1000, pos1(2)]);
                set(ax12.YLabel, 'FontSize', 8);
                
                % Set first Y axes font size
                ax21 = get(timeAxis2);
                set(ax21.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax22 = get(frameAxis2);
                pos2 = get(ax22.YLabel, 'Position');
                set(ax22.YLabel, 'Position', [pos2(1)+1000, pos2(2)]);
                set(ax22.YLabel, 'FontSize', 8);
                
                % No data.
            else
                xlabel('Time (seconds)');
                ylabel('Time (seconds)');
                title('Coiled Posture Events');
            end
            hold off;
        end
        
    case 'locomotion.turns.omegas'
        omegaFrames = eventData.frames;
        
        % Display the omega turns.
        % Display the omega turns histogram.
        isOmegaFrame = events2array(omegaFrames, totalFrames); % for your GUI
        omegaStats4Plots = removePartialEvents(omegaFrames, totalFrames);
        
        if ~isempty(omegaStats4Plots)
            histData = histogram([omegaStats4Plots.time]);
            
            % get the panel ready
            histPanel = findobj(0, 'Tag','histPanel');
            axesHandles = findobj(histPanel, 'Type','axes');
            delete(axesHandles);
            aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
            set(aggregateStatsHandle, 'string', '');
            
            histAxesHandles = axes(...    % Axes for plotting the selected plot
                'Parent', histPanel, ...
                'Tag', 'histAxes',...
                'Units', 'normalized', ... %            'HandleVisibility','callback', ...
                'Position',[0.18 0.43 0.70 0.50]);
            
            if ~isempty(omegaStats4Plots)
                histColor = [118/255 106/255 98/255];
                
                plotHistogram(histData, 'Omega Turns Histogram', ...
                    'Omega Turns Time (seconds)', ...
                    'Omega Turns Time', [], histColor);
            end
            
            % Display the omega turns plot.
            
            if ~isempty(omegaStats4Plots)
                
                timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
                axesHandles = findobj(timeSeriesPanel, 'Type','axes');
                delete(axesHandles);
                
                %delete(timeSeriesAxesHandle1)
                timeSeriesAxesHandle1 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.66 0.8 0.2]);
                
                states = struct( ...
                    'fieldName', 'interDistance', ...
                    'height', [], ...
                    'width', [], ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                eventNames = 'Not Omega Turn';
                [timeAxis1, frameAxis1] = plotEvent(omegaFrames, totalFrames, fps, ...
                    'Not Omega Turn Distance', 'Not Omega Turn Distance (microns)', ...
                    eventNames, @event2Box, states, str2colors('r', -0.1), true);
                
                % Plot time vs. inter time.
                timeSeriesAxesHandle2 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.138 0.8 0.2]);
                
                states(3) = struct( ...
                    'fieldName', 'interTime', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'time';
                states(1).isInterEvent = false;
                states(1).evalFieldNames = 'isVentral';
                states(1).evalFieldFuncs = @(x) not(x);
                states(2).fieldName = 'time';
                states(2).isInterEvent = false;
                states(2).evalFieldNames = 'isVentral';
                states(2).evalFieldFuncs = @(x) x;
                
                yAxisName = '';
                states(1).height = 1;
                states(1).width = [];
                
                states(2).height = 1;
                states(2).width = [];
                
                states(3).height = 1;
                states(3).width = [];
                
                eventNames = {'Dorsal Omega Turn', 'Ventral Omega Turn', ...
                    'Not Omega Turn'};
                [timeAxis2, frameAxis2] = plotEvent(omegaFrames, totalFrames, fps, ...
                    'Omega Turn Time', yAxisName, ...
                    eventNames, @event2Box, states, str2colors('gbr', -0.1));
                
                % Set the tag propertu for both axes
                set(timeSeriesAxesHandle1, 'Tag', 'axes1');
                set(timeSeriesAxesHandle2, 'Tag', 'axes2')
                % Set the tick font size
                set(timeAxis1, 'FontSize', 8);
                set(frameAxis1, 'FontSize', 8);
                set(timeAxis2, 'FontSize', 8);
                set(frameAxis2, 'FontSize', 8);
                % Set first Y axes font size
                ax11 = get(timeAxis1);
                set(ax11.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax12 = get(frameAxis1);
                pos1 = get(ax12.YLabel, 'Position');
                set(ax12.YLabel, 'Position', [pos1(1)+1000, pos1(2)]);
                set(ax12.YLabel, 'FontSize', 8);
                
                % Set first Y axes font size
                ax21 = get(timeAxis2);
                set(ax21.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax22 = get(frameAxis2);
                pos2 = get(ax22.YLabel, 'Position');
                set(ax22.YLabel, 'Position', [pos2(1)+1000, pos2(2)]);
                set(ax22.YLabel, 'FontSize', 8);
                
                
                % No data.
            else
                xlabel('Time (seconds)');
                ylabel('Time (seconds)');
                title('Omega Turns');
            end
            hold off;
        end
        
    case 'locomotion.turns.upsilons'
        upsilonFrames = eventData.frames;
        % Display the upsilon turns.
        % Display the upsilon turns histogram.
        isUpsilonFrame = events2array(upsilonFrames, totalFrames); % for your GUI
        upsilonStats4Plots = removePartialEvents(upsilonFrames, totalFrames);
        if ~isempty(upsilonStats4Plots)
            histData = histogram([upsilonStats4Plots.time]);
            
            % get the panel ready
            histPanel = findobj(0, 'Tag','histPanel');
            axesHandles = findobj(histPanel, 'Type','axes');
            delete(axesHandles);
            aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
            set(aggregateStatsHandle, 'string', '');
            
            if ~isempty(upsilonStats4Plots)
                histColor = [118/255 106/255 98/255];
                
                plotHistogram(histData, 'Upsilon Turns Histogram', ...
                    'Upsilon Turns Time (seconds)', ...
                    'Upsilon Turns Time', [], histColor);
            end
            
            % Display the upsilon turns plot.
            if ~isempty(upsilonStats4Plots)
                
                timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
                axesHandles = findobj(timeSeriesPanel, 'Type','axes');
                delete(axesHandles);
                
                %delete(timeSeriesAxesHandle1)
                timeSeriesAxesHandle1 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.66 0.8 0.2]);
                
                states = struct( ...
                    'fieldName', 'interDistance', ...
                    'height', [], ...
                    'width', [], ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                eventNames = 'Not Upsilon Turn';
                [timeAxis1, frameAxis1] = plotEvent(upsilonFrames, totalFrames, fps, ...
                    'Not Upsilon Turn Distance', 'Not Upsilon Turn Distance (microns)', ...
                    eventNames, @event2Box, states, str2colors('r', -0.1), true);
                
                % Plot time vs. inter time.
                
                timeSeriesAxesHandle2 = axes(...
                    'Parent', timeSeriesPanel, ...
                    'Tag', 'axes1',...
                    'Units', 'normalized', ... % 'HandleVisibility','callback', ...
                    'Position',[0.1 0.138 0.8 0.2]);
                
                states(3) = struct( ...
                    'fieldName', 'interTime', ...
                    'height', [], ...
                    'width', 1, ...
                    'isInterEvent', true, ...
                    'evalFieldNames', [], ...
                    'evalFieldFuncs', []);
                states(1).fieldName = 'time';
                states(1).isInterEvent = false;
                states(1).evalFieldNames = 'isVentral';
                states(1).evalFieldFuncs = @(x) not(x);
                states(2).fieldName = 'time';
                states(2).isInterEvent = false;
                states(2).evalFieldNames = 'isVentral';
                states(2).evalFieldFuncs = @(x) x;
                
                yAxisName = '';
                states(1).height = 1;
                states(1).width = [];
                
                states(2).height = 1;
                states(2).width = [];
                
                states(3).height = 1;
                states(3).width = [];
                
                eventNames = {'Dorsal Upsilon Turn', 'Ventral Upsilon Turn', ...
                    'Not Upsilon Turn'};
                [timeAxis2, frameAxis2] = plotEvent(upsilonFrames, totalFrames, fps, ...
                    'Upsilon Turn Time', yAxisName, ...
                    eventNames, @event2Box, states, str2colors('gbr', -0.1));
                
                % Set the tag propertu for both axes
                set(timeSeriesAxesHandle1, 'Tag', 'axes1');
                set(timeSeriesAxesHandle2, 'Tag', 'axes2')
                % Set the tick font size
                set(timeAxis1, 'FontSize', 8);
                set(frameAxis1, 'FontSize', 8);
                set(timeAxis2, 'FontSize', 8);
                set(frameAxis2, 'FontSize', 8);
                % Set first Y axes font size
                ax11 = get(timeAxis1);
                set(ax11.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax12 = get(frameAxis1);
                pos1 = get(ax12.YLabel, 'Position');
                set(ax12.YLabel, 'Position', [pos1(1)+1000, pos1(2)]);
                set(ax12.YLabel, 'FontSize', 8);
                
                % Set first Y axes font size
                ax21 = get(timeAxis2);
                set(ax21.YLabel, 'FontSize', 8);
                % Set second Y axes font size and position
                ax22 = get(frameAxis2);
                pos2 = get(ax22.YLabel, 'Position');
                set(ax22.YLabel, 'Position', [pos2(1)+1000, pos2(2)]);
                set(ax22.YLabel, 'FontSize', 8);
                
                % No data.
            else
                xlabel('Time (seconds)');
                ylabel('Time (seconds)');
                title('Upsilon Turns');
            end
            hold off;
        end
        
    case 'path.range'
        % Display the path range.
        
        pathRange = eventData;
        
        % get the panel ready
        histPanel = findobj(0, 'Tag','histPanel');
        axesHandles = findobj(histPanel, 'Type','axes');
        delete(axesHandles);
        aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
        set(aggregateStatsHandle, 'string', '');
        
        histAxesHandles = axes(...    % Axes for plotting the selected plot
            'Parent', histPanel, ...
            'Tag', 'histAxes',...
            'Units', 'normalized', ... %            'HandleVisibility','callback', ...
            'Position',[0.18 0.43 0.70 0.50]);
        
        % compute histogram
        histData = histogram(pathRange);
        % define colours
        histColor = [118/255 106/255 98/255];
        plotHistogram(histData, 'Distance from Path Center', ...
            'Distance (microns)', 'Distance', [], histColor);
        
         timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
         axesHandles = findobj(timeSeriesPanel, 'Type','axes');
         delete(axesHandles);     
    case ''
        
end
patchHandles = findobj(0, 'Type','Patch');
set(patchHandles(1), 'FaceAlpha', 1);
        


function plotWormEventsAlternate(eventData, eventLabel)
%PLOTWORMEVENTSALTERNATE This function will plot worm events in a simple
%time series fashion - there will be a band in red that signifies the start
%and the end of an event

labelInfo = wormDisplayInfo;
eventLabelInfo =  getStructField(labelInfo, eventLabel);
plotTitle = ['Worm ', eventLabelInfo.name];
legendLabels = {eventLabelInfo.name};
yAxesLabel = {''};
xAxesLabel = {'Frames'};

% get the panel ready
histPanel = findobj(0, 'Tag','histPanel');
axesHandles = findobj(histPanel, 'Type','axes');
delete(axesHandles);
aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
set(aggregateStatsHandle, 'string', '');

timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
axesHandles = findobj(timeSeriesPanel, 'Type','axes');
delete(axesHandles);

% check if handle visiblity is off
visibilityStatus = get(timeSeriesPanel, 'visible');
if strcmpi(visibilityStatus, 'off')
    resultText1Handle = findobj(0, 'Tag','resultText1');
    set(resultText1Handle, 'visible', 'off');
    set(timeSeriesPanel, 'visible', 'on');
end

if ~isempty(eventData.frames)
    
    % Check the visibility of time series panel
    visibilityStatus = get(timeSeriesPanel, 'visible');
    if strcmpi(visibilityStatus, 'off')
        resultText1Handle = findobj(0, 'Tag','resultText1');
        set(resultText1Handle, 'visible', 'off');
        set(timeSeriesPanel, 'visible', 'on');
    end
    
    hPlotAxes = axes(...    % Axes for plotting the selected plot
        'Parent', timeSeriesPanel, ...
        'Tag', 'axes1',...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'Position',[0.13 0.17 0.80 0.67]);
    
    % This function will plot omega and upsilon turns
    color_tableRed=[linspace(200,255,100)'./255,ones(100,1)*0.3882,ones(100,1)*0.2784];
    color_tableBlue=[ones(100,1)*0.2784,ones(100,1)*0.3882,linspace(200,255,100)'./255];
    cId1 = 60;
    cId2 = 15;
    
    %modeIntervals = [0,turnData.frames(1).start];
    modeIntervals = [];
    for i=1:length(eventData.frames)
        modeIntervals = [modeIntervals, eventData.frames(i).start, eventData.frames(i).end];
    end
    
    %modeIntervals = [1,frameLookup(abs(diff(wormData)')==2),frameLookup(end)];
    %set(gcf,'CurrentAxes', hPlotAxes);
    
    mydata = getappdata(timeSeriesPanel, 'mydata');
    frameNo = mydata.featureData.experimentInfo.video.length.frames;
    plot(hPlotAxes,1:frameNo, zeros(1,frameNo)+0.5);
    set(hPlotAxes, 'YTick', []);
    hold on;
    for j=1:length(modeIntervals)-1
        xdata = [modeIntervals(j),   modeIntervals(j),    modeIntervals(j+1),  modeIntervals(j+1)];
        ydata = [0,                 1,                  1,             0            ];
        
        if mod(j,2) == 0
            %col1 = color_tableBlue(cId1,:);
            col1 = [1, 1, 1];
        else
            col1 = color_tableRed(cId1,:);
        end
        fill(xdata, ydata, col1, 'FaceAlpha', 0.95);
        
    end
    if ~isempty(modeIntervals)
        %set(gca,'NextPlot','replacechildren');
        %plot(ones(1,modeIntervals(end))/2);
        %hold off;
        xlim([1, frameNo]);
        ylim([0, 1]);
        %cla(handles.histAxes);
    end
    hold off;
    
    xlabel(hPlotAxes, xAxesLabel{1});
    ylabel(hPlotAxes, yAxesLabel{1});
    title(hPlotAxes, plotTitle);
end


%--------------------------------------------------------------------------

function frame_Callback(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame as text
%        str2double(get(hObject,'String')) returns contents of frame as a double
mydata = guidata(hObject);
frameNo = str2double(get(mydata.frame,'String'));
% Draw image
modeFlag = 1;
mydata = drawMain(modeFlag, mydata, frameNo);
panelAxes = findall(gcf, 'tag', 'timeSeriesPanel');
setappdata(panelAxes, 'mydata', mydata);
guidata(hObject, mydata);


%function mydata = drawMain(mydata, frameNo)
function mydata = drawMain(modeFlag, varargin)
% This function will draw the worm
% it first takes mydata with all the variables needed and loads the work
% segmentation results from the file
% it then draws the worm in the gui
%
% The function will store currently loded data in the memory and will not
% re-load it if not needed

if modeFlag ==1
    mydata = varargin{1};
    frameNo = varargin{2};
    %cuurent frame
    frameNoCurrent = str2double(get(mydata.frame,'String'));
    
    if frameNo == frameNoCurrent
        return
    end
    
else
    hObject = varargin{1};
    eventdata = varargin{2};
    handles = varargin{3};
    
    timeSeriesPanel = findall(gcf, 'tag', 'timeSeriesPanel');
    mydata = getappdata(timeSeriesPanel, 'mydata');
    %mydata = guidata(hObject);
    frameNo = str2double(get(mydata.frame,'String'));
end

oldAxes = get(gcf,'CurrentAxes');

%get video file info
myAviInfo = mydata.myAviInfo;
%get the length of the segmentation blocks data

if mydata.segNormInfoFlag
    % get data path
    segNormInfoFile = mydata.segNormInfoFile;
    
    % Load block list
    load(segNormInfoFile, 'normBlockList');
    
    % Compute the Block Number
    %blockNo = floor((frameNo + 1)/mydata.BLOCKSIZE)+1;
    if mod(frameNo, mydata.BLOCKSIZE) == 0
        blockNo = floor((frameNo)/mydata.BLOCKSIZE);
    else
        blockNo = floor((frameNo)/mydata.BLOCKSIZE)+1;
    end
    %here we have to check if a block was previously loaded and stored in
    %memory
    if ~isfield(mydata, 'blockInfoBlockData')
        % if there is no block in memory - load it and populate blockInfo
        % variables
        blockNameStr = normBlockList{blockNo};
        datFileNameBlock = strrep(segNormInfoFile, 'segNormInfo', blockNameStr);
        load(getRelativePath(datFileNameBlock), blockNameStr);
        data = [];
        eval(strcat('data =', blockNameStr,';'));
        mydata.blockInfoBlockData = data;
        
        mydata.blockInfoStart = (blockNo - 1) * mydata.BLOCKSIZE + 1;
        mydata.blockInfoEnd = blockNo * mydata.BLOCKSIZE;
        frameNoBlock = frameNo - mydata.blockInfoStart + 1;
    else
        %if the data block was previously loaded, initialize the variables
        blockNameStr = strcat('normBlock',num2str(blockNo));
        frameNoBlock = frameNo - (blockNo - 1) * mydata.BLOCKSIZE;
    end
    
    %here we check if the frame that we want to draw is in the block that we
    %have in memory
    if frameNo >= mydata.blockInfoStart && frameNo+1 <= mydata.blockInfoEnd
        data = mydata.blockInfoBlockData;
    else
        %if now - lets load the block and save it to mydata
        blockNameStr = normBlockList{blockNo};
        datFileNameBlock = strrep(segNormInfoFile, 'segNormInfo', blockNameStr);
        load(getRelativePath(datFileNameBlock), blockNameStr);
        data = [];
        eval(strcat('data =', blockNameStr,';'));
        mydata.blockInfoBlockData = data;
        
        mydata.blockInfoStart = (blockNo - 1) * mydata.BLOCKSIZE + 1;
        mydata.blockInfoEnd = blockNo * mydata.BLOCKSIZE;
        frameNoBlock = frameNo - mydata.blockInfoStart + 1;
    end
    
    % Record stuff back to the mydata
    mydata.blockInfoBlockID = blockNameStr;
    % Initialize the image
    img = zeros(myAviInfo.height, myAviInfo.width, 3);
    
    colourContourBox = get(mydata.colourContour, 'Value');
    toggleROIBox = get(mydata.toggleROI, 'Value');
    
    % Overlay image
    if data{1}(frameNoBlock) == 's'
        % In case we dont have stage movement file in this selection we will
        % draw the absolute coordinates worm
        if isfield(mydata, 'pixel2MicronScale') && ...
                isfield(mydata, 'rotation') && ...
                isfield(mydata, 'locations') && ...
                isfield(mydata, 'movesI') && ...
                colourContourBox
            
            sImg = getWormImage(img, data, frameNoBlock, mydata.pixel2MicronScale, mydata.rotation, mydata.locations, mydata.movesI, frameNo, toggleROIBox);
            
            imgPanel = findobj(0, 'Tag','imgPanel');
            axesHandles = findobj(imgPanel, 'Type','axes');
            delete(axesHandles);
            
            imgAxes = axes(...    % Axes for showing image
                'Parent', imgPanel, ...
                'Tag', 'imgAxes',...
                'Units', 'normalized', ...
                'HandleVisibility','callback', ...
                'Position',[0 0 1 1]);
            
            imshow(sImg, 'Parent', imgAxes);
            %set(mydata.text1,'String',strcat('FNO:',num2str(frameNo),' BFNO:',num2str(frameNoBlock)));
            set(mydata.text1, 'String', strcat('Frame no:', num2str(frameNo)));
        else
            imgPanel = findobj(0, 'Tag','imgPanel');
            axesHandles = findobj(imgPanel, 'Type','axes');
            delete(axesHandles);
            
            imgAxes = axes(...    % Axes for showing image
                'Parent', imgPanel, ...
                'Tag', 'imgAxes',...
                'Color', 'none', ...
                'Box', 'off', ...
                'Units', 'normalized', ... %                 'HandleVisibility','callback', ...
                'Position',[0.05 0.05 0.9 0.9]);
            set(mydata.figure1,'CurrentAxes', imgAxes);
            %set(mydata.figure1,'CurrentAxes',mydata.axes2);
            skCoords = data{4}(:,:,frameNoBlock);
            outlineCoordsVulvaSide = data{2}(:,:,frameNoBlock);
            outlineCoordsNonVulvaSide = data{3}(:,:,frameNoBlock);
            varB = outlineCoordsNonVulvaSide;
            varA = outlineCoordsVulvaSide;
            var1 = [varA(1:end,:); flipud(varB(1:end,:))];
            
            %%set(gca,'NextPlot','replacechildren');
            %plot(skCoords(:,1) * mydata.signVal(1,1),skCoords(:,2) * mydata.signVal(1,2));
            %hold on;
            %plot(outlineCoordsVulvaSide(:,1) * mydata.signVal(1,1),outlineCoordsVulvaSide(:,2) * mydata.signVal(1,2));
            %plot(outlineCoordsNonVulvaSide(:,1) * mydata.signVal(1,1),outlineCoordsNonVulvaSide(:,2) * mydata.signVal(1,2));
            
            plot(imgAxes, var1(:,1) * mydata.signVal(1,1), var1(:,2) * mydata.signVal(1,2), 'Color', 'k', 'LineWidth', 1);
            hold on;
            % Fill the worm with colour
            colourValue = ([192,192,192]/255);
            fill(var1(:,1) * mydata.signVal(1,1), var1(:,2) * mydata.signVal(1,2), colourValue);
            plot(imgAxes, skCoords(:,1) * mydata.signVal(1,1), skCoords(:,2) * mydata.signVal(1,2), 'Color', 'r', 'LineWidth', 1);
            
            axis equal;
            text(skCoords(1,1) * mydata.signVal(1,1), skCoords(1,2) * mydata.signVal(1,2), 'Head', 'Color', 'r', 'FontSize', 10)
            hold off;
            
            set(imgAxes, 'Color', 'none');
            set(imgAxes, 'Box', 'off');
            set(imgAxes, 'Visible', 'off');
            %set(mydata.text1, 'String', strcat('FNO:', num2str(frameNo), ' BFNO:', num2str(frameNoBlock)));
            set(mydata.text1, 'String', strcat('Frame no:', num2str(frameNo)));
        end
        % Debug
        % FEATURE DRAWER
        
        %index_selected = get(mydata.listbox1, 'Value');
        %listArray = get(mydata.listbox1, 'String');
        %item_selected = listArray{index_selected};
        
        %     if isfield(mydata, 'eventViewToggle')
        %         checkboxStatus = get(mydata.eventViewToggle,'Value');
        %         if checkboxStatus
        %             drawMERtest(data, frameNoBlock, mydata.axes2, item_selected, mydata.signVal, 1);
        %         end
        %     end
    else
        %     img = zeros(myAviInfo.height, myAviInfo.width, 3);
        %     imshow(img,'Parent', mydata.axes2);
        if data{1}(frameNoBlock) == 'd'
            set(mydata.text1,'String', 'Dropped frame');
        elseif  data{1}(frameNoBlock) == 'm'
            set(mydata.text1,'String', 'Stage movement frame');
        elseif  data{1}(frameNoBlock) == 'f'
            set(mydata.text1,'String', 'Segmentation failed frame');
        else
        end
    end
    
    % Plot the absolute path of the worm
    %--------------------------------------------------------------------------
    % Check if new worm is available
    if ~all(isnan(data{4}(:, :, frameNoBlock)))
        % Lets not draw an update if there is no data. In the future we could
        % dim the current plot or smth.
        
        pathPanel = findobj(0, 'Tag','wormPath');
        pathAxes = findobj(pathPanel, 'Type','axes');
        delete(pathAxes);
        
        pathAxes = axes(...    % Axes for plotting the selected plot
            'Parent', pathPanel, ...
            'Tag', 'pathAxes',...
            'Units', 'normalized', ...
            'HandleVisibility','callback', ...
            'Position',[0.11 0.17 0.80 0.67]);
        
        set(mydata.figure1,'CurrentAxes', pathAxes);
        %set(gca,'NextPlot','replacechildren');
        plot(pathAxes, mydata.centroids(:,2), mydata.centroids(:,1), 'Color', [.9 .9 .9], 'LineWidth', 2);
        hold(pathAxes, 'on');
        plot(pathAxes, mydata.centroids(1:frameNo,2), mydata.centroids(1:frameNo,1), 'Color', [.4 .4 .4], 'LineWidth', 1);
        xlim(pathAxes, mydata.xLimData);
        ylim(pathAxes, mydata.yLimData);
        % label the start and end of the path
        text(mydata.startCentroids(1, 1), mydata.startCentroids(1, 2),'Start', 'Color', [0, 51/255, 102/255]);
        text(mydata.endCentroids(1, 1), mydata.endCentroids(1, 2),'End', 'Color', [0, 51/255, 102/255]);
        %text(mydata.centroids(frameNo, 2), mydata.centroids(frameNo, 1),'•', 'Color', [204/255, 0, 0], 'FontSize', 18);
        xlabel(pathAxes, 'X Location (Microns)');
        ylabel(pathAxes, 'Y Location (Microns)');
        set(pathAxes, 'DataAspectRatio',[1 1 1]);
        
        % draw the small worm on the overal outline
        skCoords = data{4}(:, :, frameNoBlock);
        outlineCoordsVulvaSide = data{2}(:, :, frameNoBlock);
        outlineCoordsNonVulvaSide = data{3}(:, :, frameNoBlock);
        varB = outlineCoordsNonVulvaSide;
        varA = outlineCoordsVulvaSide;
        var1 = [varA(1:end,:); flipud(varB(1:end,:))];
        
        plot(pathAxes, var1(:,1) * mydata.signVal(1,1), var1(:,2) * mydata.signVal(1,2), 'Color', 'k', 'LineWidth', 1);
        % Fill the worm with colour
        colourValue = ([192,192,192]/255);
        fill(var1(:,1) * mydata.signVal(1,1), var1(:,2) * mydata.signVal(1,2), colourValue);
        plot(pathAxes, skCoords(:,1) * mydata.signVal(1,1), skCoords(:,2) * mydata.signVal(1,2), 'Color', 'r', 'LineWidth', 1);
        
        hold(pathAxes, 'off');
    end
    
else
    %%-------------------------------------------------------------------
    % here we deal with the situation where we draw only the skeleton of
    % the worm
    
    colourContourBox = get(mydata.colourContour, 'Value');
    toggleROIBox = get(mydata.toggleROI, 'Value');
    
    imgPanel = findobj(0, 'Tag','imgPanel');
    axesHandles = findobj(imgPanel, 'Type','axes');
    delete(axesHandles);
    
    imgAxes = axes(...    % Axes for showing image
        'Parent', imgPanel, ...
        'Tag', 'imgAxes',...
        'Color', 'none', ...
        'Box', 'off', ...
        'Units', 'normalized', ... %                 'HandleVisibility','callback', ...
        'Position',[0.05 0.05 0.9 0.9]);
    
    set(mydata.figure1,'CurrentAxes', imgAxes);
    %set(mydata.figure1,'CurrentAxes',mydata.axes2);
    
    % Get the skeleton data
    var1 = [mydata.skeleton.x(:,frameNo), mydata.skeleton.y(:,frameNo)];
    
    plot(imgAxes, var1(:,1) * mydata.signVal(1,1), var1(:,2) * mydata.signVal(1,2), 'Color', [0/255,191/255,255/255], 'LineWidth', 5, 'LineStyle', '-');
    hold on;

    axis equal;
    text(var1(1,1) * mydata.signVal(1,1), var1(1,2) * mydata.signVal(1,2), 'Head', 'Color', 'r', 'FontSize', 10)
    hold off;
    
    set(imgAxes, 'Color', 'none');
    set(imgAxes, 'Box', 'off');
    set(imgAxes, 'Visible', 'off');
    set(mydata.text1, 'String', strcat('Frame no:', num2str(frameNo)));

    %--------------
    pathPanel = findobj(0, 'Tag','wormPath');
    pathAxes = findobj(pathPanel, 'Type','axes');
    delete(pathAxes);
    
    pathAxes = axes(...    % Axes for plotting the selected plot
        'Parent', pathPanel, ...
        'Tag', 'pathAxes',...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'Position',[0.11 0.17 0.80 0.67]);
    
    set(mydata.figure1,'CurrentAxes', pathAxes);
    %set(gca,'NextPlot','replacechildren');
    plot(pathAxes, mydata.centroids(:,2), mydata.centroids(:,1), 'Color', [.9 .9 .9], 'LineWidth', 2);
    hold(pathAxes, 'on');
    plot(pathAxes, mydata.centroids(1:frameNo,2), mydata.centroids(1:frameNo,1), 'Color', [.4 .4 .4], 'LineWidth', 1);
    xlim(pathAxes, mydata.xLimData);
    ylim(pathAxes, mydata.yLimData);
    % label the start and end of the path
    text(mydata.startCentroids(1, 1), mydata.startCentroids(1, 2),'Start', 'Color', [0, 51/255, 102/255]);
    text(mydata.endCentroids(1, 1), mydata.endCentroids(1, 2),'End', 'Color', [0, 51/255, 102/255]);
    %text(mydata.centroids(frameNo, 2), mydata.centroids(frameNo, 1),'•', 'Color', [204/255, 0, 0], 'FontSize', 18);
    xlabel(pathAxes, 'X Location (Microns)');
    ylabel(pathAxes, 'Y Location (Microns)');
    set(pathAxes, 'DataAspectRatio',[1 1 1]);
    
    % draw the small worm on the overal outline
    plot(pathAxes, var1(:,1) * mydata.signVal(1,1), var1(:,2) * mydata.signVal(1,2), 'Color', [0/255,191/255,255/255], 'LineWidth', 3, 'LineStyle', '-');
    
    axis equal;
    text(var1(1,1) * mydata.signVal(1,1), var1(1,2) * mydata.signVal(1,2), 'H', 'Color', 'r', 'FontSize', 10)
    hold off;
    hold(pathAxes, 'off');
    %%
end
set(gcf,'CurrentAxes', oldAxes);
timeSeriesPanel = findall(gcf, 'tag', 'timeSeriesPanel');
setappdata(timeSeriesPanel, 'mydata', mydata);



% --- Executes during object creation, after setting all properties.
function frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function txt = myupdatefcn(~,event_obj)
% Customizes text of data tips

timeSeriesPanel = findall(gcf, 'tag', 'timeSeriesPanel');
mydata = getappdata(timeSeriesPanel, 'mydata');

pos = get(event_obj, 'Position');
index = pos(1);
txt = {['Frame: ',num2str(pos(1))],...
    ['Value: ',num2str(pos(2))]};

if str2double(get(mydata.stopFlag, 'string')) == 1
    if index && index ~= str2double(get(mydata.frame, 'string'))
        modeFlag = 1;
        mydata = drawMain(modeFlag, mydata, index);
        set(mydata.frame, 'String', num2str(index));
        
        setappdata(timeSeriesPanel, 'mydata', mydata);
    end
end

% --- Executes on selection change in histoList.
function histoList_Callback(hObject, eventdata, handles)
% hObject    handle to histoList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns histoList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from histoList

new_list_size = size(listElements);
new_val = new_list_size(1,1);
set(handles.listbox1,'Value', new_val);
set(handles.listbox1,'String', listElements);

% --- Executes during object creation, after setting all properties.
function histoList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to histoList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in eventViewToggle.
function eventViewToggle_Callback(hObject, eventdata, handles)
% hObject    handle to eventViewToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventViewToggle


% --- Executes on button press in colourContour.
function colourContour_Callback(hObject, eventdata, handles)
% hObject    handle to colourContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colourContour


% --- Executes on button press in toggleROI.
function toggleROI_Callback(hObject, eventdata, handles)
% hObject    handle to toggleROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleROI


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clean up the axes

timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
hPlotAxes = findobj(timeSeriesPanel, 'Type','axes');
hPlotAxes = hPlotAxes(1);

allLinesInAxes = findobj(hPlotAxes, 'Color', [127/255, 255/255, 0/255]);
delete(allLinesInAxes);

%mydata = guidata(hObject);
mydata = getappdata(timeSeriesPanel, 'mydata');
videoLength = length(mydata.featureData.morphology.length);

% Get playback speed
playbackSpeed = str2double(get(mydata.playbackSpeed,'String'));

toggleStopValue = 0;
%set(handles.stopFlag, 'String', num2str(0));
set(mydata.stopFlag, 'String', num2str(0));
setappdata(timeSeriesPanel, 'mydata', mydata);

yAxesLimit = ylim(hPlotAxes);
%frameNo = str2double(get(handles.frame,'String'));
frameNo = str2double(get(mydata.frame,'String'));

axes(hPlotAxes);

xVal = [frameNo, frameNo];
yVal = [yAxesLimit(1), yAxesLimit(2)];
%lineHandle = line(xVal, yVal, 'Color', [66/255 46/255 93/255]);
lineHandle = line(xVal, yVal, 'Color', [127/255, 255/255, 0/255]);

while ~toggleStopValue
    mydata = getappdata(timeSeriesPanel, 'mydata');
    
    drawnow;
    %toggleStopValue = str2double(get(handles.stopFlag, 'String'));
    toggleStopValue = str2double(get(mydata.stopFlag, 'String'));
    
    % Get playback speed
    playbackSpeed = str2double(get(mydata.playbackSpeed,'String'));
    
    if toggleStopValue == 1
        return;
    end
    
    %frameNo = str2double(get(handles.frame,'String'));
    frameNo = str2double(get(mydata.frame,'String'));
    frameNoNew = frameNo + playbackSpeed;
    
    set(mydata.frame, 'String', num2str(frameNoNew));
    setappdata(timeSeriesPanel, 'mydata', mydata);
    
    if frameNoNew + playbackSpeed <= videoLength
        if ishandle(lineHandle)
            %delete(lineHandle);
            set(lineHandle, 'Visible', 'off');
            %set(handles.frame,'String', num2str(frameNoNew));
            set(mydata.frame,'String', num2str(frameNoNew));
            setappdata(timeSeriesPanel, 'mydata', mydata);
        end
        
        %set(gcf, 'CurrentAxes', hPlotAxes);
        % Draw image
        modeFlag = 2;
        drawMain(modeFlag, hObject, eventdata, handles);
        
        % Draw the slider
        xVal = [frameNoNew, frameNoNew];
        yVal = [yAxesLimit(1), yAxesLimit(2)];
        
        %lineHandle = line(xVal, yVal, 'Color', [66/255 46/255 93/255]);
        lineHandle = line(xVal, yVal, 'Color', [127/255, 255/255, 0/255]);
        %set(handles.frame,'String', num2str(frameNoNew));
        set(mydata.frame,'String', num2str(frameNoNew));
        setappdata(timeSeriesPanel, 'mydata', mydata);
    else
        toggleStopValue = 1;
    end
end
%delete(lineHandle);
set(lineHandle, 'Visible', 'off');

delete(lineHandle);
set(mydata.frame,'String', num2str(frameNoNew));
guidata(hObject, mydata);


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

timeSeriesPanel = findall(gcf, 'tag', 'timeSeriesPanel');
mydata = getappdata(timeSeriesPanel, 'mydata');


%toggleStopValue = str2double(get(handles.stopFlag, 'String'));
toggleStopValue = str2double(get(mydata.stopFlag, 'string'));

if ~toggleStopValue
    set(handles.stopFlag, 'String', num2str(1));
    set(mydata.stopFlag,'String', num2str(1));
end
setappdata(timeSeriesPanel, 'mydata', mydata);


% Construct a label from a field.
function [plotTitle, legendLabels, yAxesLabel, xAxesLabel, valUnits] = getLabel(info, field)
labelInfo =  getStructField(info, field);
plotTitle = ['Worm ', labelInfo.name];
legendLabels = {labelInfo.name};

valUnits = labelInfo.unit;
yAxesLabel = {[labelInfo.name ' (' labelInfo.unit ')']};
xAxesLabel = {'Frames'};


function playbackSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to playbackSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playbackSpeed as text
%        str2double(get(hObject,'String')) returns contents of playbackSpeed as a double


% --- Executes during object creation, after setting all properties.
function playbackSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playbackSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function wormFormatted = formatWormData(worm)
% WORMFORMATTED This function will format WormData so that 
wormFormatted = worm;
worm.posture
wormPosture = rmfield(wormFormatted.posture, 'skeleton');
wormFormatted.posture = wormPosture;

wormPath = rmfield(wormFormatted.path, 'coordinates');
wormFormatted.path = wormPath;


wormFormatted.posture.eigenProjections.first = wormFormatted.posture.eigenProjection(1,:);
wormFormatted.posture.eigenProjections.second = wormFormatted.posture.eigenProjection(2,:);
wormFormatted.posture.eigenProjections.third = wormFormatted.posture.eigenProjection(3,:);
wormFormatted.posture.eigenProjections.fourth = wormFormatted.posture.eigenProjection(4,:);
wormFormatted.posture.eigenProjections.fifth = wormFormatted.posture.eigenProjection(5,:);
wormFormatted.posture.eigenProjections.sixth = wormFormatted.posture.eigenProjection(6,:);


wormPosture = rmfield(wormFormatted.posture, 'eigenProjection');
wormFormatted.posture = wormPosture;


function plotPathDuration(eventData, eventLabel)
% PLOTPATHDURATION This function will plot path duration heat map to
% understand where the worm spent the most time in its path
%
% Input:
%   eventData - data for the event, contains subfields - franes, frequency,
%   ratio
%   eventLabel - location of the struct which corresponds with the data
%   above

pathDuration = eventData;

% get the panel ready
histPanel = findobj(0, 'Tag','histPanel');
axesHandles = findobj(histPanel, 'Type','axes');
delete(axesHandles);
aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
set(aggregateStatsHandle, 'string', '');

timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
axesHandles = findobj(timeSeriesPanel, 'Type','axes');
delete(axesHandles);

listboxHandles = findobj(0, 'Style','listbox');
listString = {'Worm duration', 'Head duration', 'Midbody duration', 'Tail duration'};

if isempty(listboxHandles)
    listboxHandles = uicontrol(gcf, ...
        'Parent', timeSeriesPanel, ...
        'Style','listbox', ...
        'String', listString, ...
        'Units', 'normalized', ...
        'Callback', @drawDurationPlotSelection, ...
        'Value',1,'Position', [0.8 0.58 0.19 0.4]);
end

setappdata(listboxHandles, 'eventData', pathDuration);
drawDurationPlotSelection(listboxHandles, [])

function drawDurationPlotSelection(returnHandle, returnValue)
% DRAWDURATIONPLOTSELECTION This function will draw the correct plot for duration
% depending on the user selection

listboxHandles = findobj(0, 'Style','listbox');
timeSeriesPanel = findobj(0, 'Tag','timeSeriesPanel');
axesHandles = findobj(timeSeriesPanel, 'Type','axes');
delete(axesHandles);

% check if handle visiblity is off
visibilityStatus = get(timeSeriesPanel, 'visible');
if strcmpi(visibilityStatus, 'off')
    resultText1Handle = findobj(0, 'Tag', 'resultText1');
    set(resultText1Handle, 'visible', 'off');
    set(timeSeriesPanel, 'visible', 'on');
end

pathDuration = getappdata(listboxHandles, 'eventData');

colormap jet;
plotId = get(listboxHandles, 'Value');

switch plotId
    case 1
        timeSeriesAxesHandle1 = axes(...
            'Parent', timeSeriesPanel, ...
            'Tag', 'axes1',...
            'Units', 'normalized', ... % 'HandleVisibility','callback', ...
            'Position',[0.1 0.15 0.6 0.7]);
        
        plotWormPathTime(pathDuration.arena, pathDuration.worm, ...
            'Worm Duration', 'Location (microns)');
        
        set(timeSeriesAxesHandle1, 'FontSize', 7);
        tsaH = get(timeSeriesAxesHandle1);
        set(tsaH.XLabel, 'FontSize', 7);
        set(tsaH.YLabel, 'FontSize', 7);
        set(tsaH.Title, 'FontSize', 7)
        
        item_selected = 'path.duration.worm';
        wormDurationHistograms(pathDuration.worm.times, item_selected);
        
    case 2
        
        timeSeriesAxesHandle2 = axes(...
            'Parent', timeSeriesPanel, ...
            'Tag', 'axes1',...
            'Units', 'normalized', ... % 'HandleVisibility','callback', ...
            'Position',[0.1 0.15 0.6 0.7]);
        
        plotWormPathTime(pathDuration.arena, pathDuration.head, ...
            'Head Duration', 'Location (microns)');
        
        set(timeSeriesAxesHandle2, 'FontSize', 7);
        tsaH = get(timeSeriesAxesHandle2);
        set(tsaH.XLabel, 'FontSize', 7);
        set(tsaH.YLabel, 'FontSize', 7);
        set(tsaH.Title, 'FontSize', 7)
        
        % Plot histogram
        item_selected = 'path.duration.head';
        wormDurationHistograms(pathDuration.head.times, item_selected);
    case 3
        
        timeSeriesAxesHandle2 = axes(...
            'Parent', timeSeriesPanel, ...
            'Tag', 'axes1',...
            'Units', 'normalized', ... % 'HandleVisibility','callback', ...
            'Position',[0.1 0.15 0.6 0.7]);
        
        plotWormPathTime(pathDuration.arena, pathDuration.midbody, ...
            'Midbody Duration', 'Location (microns)');
        
        set(timeSeriesAxesHandle2, 'FontSize', 7);
        tsaH = get(timeSeriesAxesHandle2);
        set(tsaH.XLabel, 'FontSize', 7);
        set(tsaH.YLabel, 'FontSize', 7);
        set(tsaH.Title, 'FontSize', 7)
        
        % Plot histogram
        item_selected = 'path.duration.midbody';
        wormDurationHistograms(pathDuration.midbody.times, item_selected);
        
    case 4
        
        timeSeriesAxesHandle4 = axes(...
            'Parent', timeSeriesPanel, ...
            'Tag', 'axes1',...
            'Units', 'normalized', ... % 'HandleVisibility','callback', ...
            'Position',[0.1 0.15 0.6 0.7]);
        
        plotWormPathTime(pathDuration.arena, pathDuration.tail, ...
            'Tail Duration', 'Location (microns)');
        
        
        set(timeSeriesAxesHandle4, 'FontSize', 7);
        tsaH = get(timeSeriesAxesHandle4);
        set(tsaH.XLabel, 'FontSize', 7);
        set(tsaH.YLabel, 'FontSize', 7);
        set(tsaH.Title, 'FontSize', 7);
        
        % Plot histograms
        item_selected = 'path.duration.tail';
        wormDurationHistograms(pathDuration.tail.times, item_selected);        
end


function wormDurationHistograms(pathDurationData, item_selected)
% WORMDURATIONHISTOGRAMS This function will draw path duration histograms
% to the GUI

% Draw histogram
histPanel = findobj(0, 'Tag','histPanel');
axesHandles = findobj(histPanel, 'Type','axes');
delete(axesHandles);
aggregateStatsHandle = findobj(0, 'Tag','agregateStats');
set(aggregateStatsHandle, 'string', '');

DATA = pathDurationData;
VERBOSE = 0;
HISTDATA = histogram(DATA, [], [], [], VERBOSE);

histColor = [118/255 106/255 98/255];
statColor = [0.7 0.2 0.1];
statMode = 2;

histAxes = axes(...    % Axes for plotting the selected plot
    'Parent', histPanel, ...
    'Tag', 'histAxes',...
    'Units', 'normalized', ... %            'HandleVisibility','callback', ...
    'Position',[0.18 0.43 0.70 0.50]);

%set(gcf,'CurrentAxes', histAxes);
plotHistogram(HISTDATA, '', 'Value', [], '', ...
    histColor, statColor, 1, statMode);

patchHandles = findobj(0, 'Type','Patch');
set(patchHandles(1), 'FaceAlpha', 1);
        

% Draw legend
labelInfo = wormDisplayInfo;
[~, legendLabels, ~, ~] = ...
    getLabel(labelInfo, item_selected);

% Construct the histogram legend.
legendLabel = legendLabels{1};
% Construct the summary statistics legend.
if ~isempty(statColor)
    legends{1} = legendLabel;
    legends{2} = ['Data samples N = ' num2str(HISTDATA.data.samples) ','];
    legends{3} = ['Mean = ' num2str(HISTDATA.data.mean.all) ','];
    legends{4} = ['Standard Deviation = ' ...
        num2str(HISTDATA.data.stdDev.all)];
    
    if HISTDATA.isSigned
        legends{4} = [legends{4} ','];
        legends{5} = ['Absolute Mean = ' ...
            num2str(HISTDATA.data.mean.abs) ','];
        legends{6} = ['Absolute Standard Deviation = ' ...
            num2str(HISTDATA.data.stdDev.abs) ','];
        
        legends{7} = ['Positive Data Mean = ' ...
            num2str(HISTDATA.data.mean.pos) ','];
        legends{8} = ['Positive Data Standard Deviation = ' ...
            num2str(HISTDATA.data.stdDev.pos) ','];
        
        legends{9} = ['Negative Data Mean = ' ...
            num2str(HISTDATA.data.mean.neg) ','];
        legends{10} = ['Negative Data Standard Deviation = ' ...
            num2str(HISTDATA.data.stdDev.neg)];
    end
end

resultText1Handle = findobj(0, 'Tag','agregateStats');
set(resultText1Handle, 'string', legends);


function agregateStats_Callback(hObject, eventdata, handles)
% hObject    handle to agregateStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of agregateStats as text
%        str2double(get(hObject,'String')) returns contents of agregateStats as a double


% --- Executes during object creation, after setting all properties.
function agregateStats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to agregateStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_outline.
function load_outline_Callback(hObject, eventdata, handles)
% hObject    handle to load_outline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Enable buttons
set(handles.colourContour, 'enable', 'on');
set(handles.toggleROI, 'enable', 'on');

timeSeriesPanel = findall(gcf, 'tag', 'timeSeriesPanel');
mydata = getappdata(timeSeriesPanel, 'mydata');

% Get normWormInfo file
[expDirName, expName] = fileparts(mydata.fname);
expDirName = strrep(expDirName,'\results','');
expName = strrep(expName,'_features','');
segNormInfoFile = [expDirName, ['\.data\', expName,'_seg', '\normalized\segNormInfo.mat']];

% Get worm normInfo manualy
if ~exist(segNormInfoFile, 'file')
    [segNormInfoFile, segNormInfoDir] = uigetfile('','Get the normBlockInfo file');
    segNormInfoFile = fullfile(segNormInfoDir, segNormInfoFile);
    if ~ischar(segNormInfoFile) || ~ischar(segNormInfoDir)
        msgbox('segNormInfo file not found!');
    end
end

mydata.segNormInfoFile = segNormInfoFile;
load(segNormInfoFile,'normBlockList', 'pixel2MicronScale', 'rotation', 'myAviInfo');
mydata.myAviInfo = myAviInfo;
mydata.pixel2MicronScale = pixel2MicronScale;
mydata.rotation = rotation;
mydata.segNormInfoFlag = 1;


% Get stage movement data
% Automaticaly define location of the stage movement file
stageMovDatStr = [expDirName,['\.data\',expName,'_stageMotion.mat']];
% Check if it exists
if ~exist(stageMovDatStr, 'file')
    % If not then ask the user to provide the file.
    [stageMovementFile, stageMovementDir] = uigetfile('','Select a _stageMotion.mat file!');
    if ~ischar(stageMovementFile) || ~ischar(stageMovementDir)
        % Exit function if pressed cancel
        return;
    end
    stageMovDatStr = fullfile(stageMovementDir, stageMovementFile);
end



load(getRelativePath(stageMovDatStr), 'locations', 'movesI');
mydata.locations = locations;
mydata.movesI = movesI;

% Save the variable
guidata(hObject, mydata);
panelAxes = findall(gcf, 'tag', 'timeSeriesPanel');
setappdata(panelAxes,'mydata',mydata);
