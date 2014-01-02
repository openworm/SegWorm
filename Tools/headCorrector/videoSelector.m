function varargout = videoSelector(varargin)
% VIDEOSELECTOR M-file for videoSelector.fig
%      VIDEOSELECTOR, by itself, creates a new VIDEOSELECTOR or raises the existing
%      singleton*.
%
%      H = VIDEOSELECTOR returns the handle to a new VIDEOSELECTOR or the handle to
%      the existing singleton*.
%
%      VIDEOSELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEOSELECTOR.M with the given input arguments.
%
%      VIDEOSELECTOR('Property','Value',...) creates a new VIDEOSELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before videoSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to videoSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Edit the above text to modify the response to help videoSelector

% Last Modified by GUIDE v2.5 05-Sep-2011 16:43:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @videoSelector_OpeningFcn, ...
    'gui_OutputFcn',  @videoSelector_OutputFcn, ...
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


% --- Executes just before videoSelector is made visible.
function videoSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for videoSelector
handles.output = hObject;

% connect to database
error('database details missing')
handles.conn = database;


%populate the lists & totals for strains/chromosomes/names/alleles
update_all(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes videoSelector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = videoSelector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure% Get default command line output from handles structure
varargout{1} = handles.output;




% When the "Select Experiment" button is pressed, pass the experiment ID to the
% main GUI, and close the videoSelector GUI
function experimentSelect_Callback(hObject, eventdata, handles)
%get the number of the selected experiment
%contents = cellstr(get(handles.experimentList,'String'));
%experiment = contents{get(handles.experimentList,'Value')};

%find the selected experiment's id
experimentIDs = updateExperimentList(handles, handles.conn)
experiment = experimentIDs{get(handles.experimentList,'Value')};

%share it with the main GUI
hMainGui=getappdata(0, 'hMainGui')
setappdata(hMainGui.figure1, 'experiment', experiment)
fhLoadVideo = getappdata(hMainGui.figure1, 'fhLoadVideo');
feval(fhLoadVideo, getappdata(0, 'hMainGui'));

%close this GUI
delete(videoSelector)





% When the copyPath button is pressed, copy the path of the currently selected video
% to the clipboard
function copyPath_Callback(hObject, eventdata, handles)

%get the selected experiment ID
experimentIDs = updateExperimentList(handles, handles.conn)
%id = num2str(experimentIDs{get(handles.experimentList,'Value')})
paths = ''

ids = get(handles.experimentList,'Value');
for c=1:length(ids)
    id = num2str(experimentIDs{ids(c)});
    query = ['SELECT * FROM locationnas WHERE id=''' id  ''' ']
    curs = exec(handles.conn, query);
    setdbprefs('DataReturnFormat','cellarray');
    curs = fetch(curs, 1);
    if isempty(paths)
        paths = curs.data{3}
    else
        %paths = [paths '\n' curs.data{3}]
        paths=sprintf('%s\n%s', paths, curs.data{3});
    end
    
end
clipboard('copy', paths)



% These functions control the display lists
% When something is selected, they populate the 'Filter' textbox
% and call its callback
%the _CreateFcn functions are called during object creation, after setting all properties
% and set the background of the boxes white

function chromosomeList_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
set(handles.chromosomeFilter, 'String',  contents{get(hObject,'Value')});
chromosomeFilter_Callback(handles.chromosomeFilter, 0, handles)

function chromosomeList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strainList_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
set(handles.strainFilter, 'String',  contents{get(hObject,'Value')});
strainFilter_Callback(handles.strainFilter, 0, handles)

function strainList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nameList_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
set(handles.nameFilter, 'String',  contents{get(hObject,'Value')});
nameFilter_Callback(handles.nameFilter, 0, handles)

function nameList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function alleleList_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
set(handles.alleleFilter, 'String',  contents{get(hObject,'Value')});
alleleFilter_Callback(handles.alleleFilter, 0, handles)

function alleleList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% experimentList is slightly different
% rather than changing the filtering, we select the corresponding name/allele/chromosome
% in their respective Lists
function experimentList_Callback(hObject, eventdata, handles)

%get the selected experiment ID
%contents = cellstr(get(hObject,'String'));
%id = contents{get(hObject,'Value')};

%mydata=guidata(handles.figure1)
%id = num2str(handles.experimentIDs{get(hObject,'Value')});
%guidata(handles.figure1, mydata);
subqueries = [orTerms(handles,'chromosome', {get(handles.chromosomeFilter,'String')}) orTerms(handles,'name', {get(handles.nameFilter,'String')}) orTerms(handles,'allele', {get(handles.alleleFilter,'String')}) orTerms(handles,'id', {get(handles.experimentFilter,'String')}) orTerms(handles,'strain', {get(handles.strainFilter,'String')}) dateQuery(handles) foodquery(handles)  vulvaquery(handles)];
query = ['SELECT DISTINCT id, datestamp FROM info ' andTerms(subqueries) ' ORDER BY id']

curs = exec(handles.conn, query);
setdbprefs('DataReturnFormat','cellarray');
curs = fetch(curs, 1000);

if strcmp(curs.data{:,1}, 'No Data')
    set(handles.nameList, 'value', 1)
    set(handles.chromosomeList, 'value', 1)
    set(handles.alleleList, 'value', 1)
    set(handles.experimentPath, 'String', '')
else
    experimentIDs = curs.data(:,1)
    
    
    if isscalar(get(hObject,'Value'))
        id = num2str(experimentIDs{get(hObject,'Value')})
        
        %query the DB to find the corresponding Name, Chromosome, Allele, Strain
        query = ['SELECT * FROM info WHERE id=''' id  ''' ']
        curs = exec(handles.conn, query);
        setdbprefs('DataReturnFormat','cellarray');
        curs = fetch(curs, 1);
        
        %highlight the appropriate Name
        contents = cellstr(get(handles.nameList,'String'));
        for c=1:length(contents)
            if strcmp(contents{c}, curs.data{2})
                set(handles.nameList, 'value', c)
                break
            end
        end
        
        %highlight the appropriate Chromosome
        contents = cellstr(get(handles.chromosomeList,'String'));
        for c=1:length(contents)
            if strcmp(contents{c}, curs.data{5})
                set(handles.chromosomeList, 'value', c)
                break
            end
        end
        
        %highlight the appropriate Allele
        contents = cellstr(get(handles.alleleList,'String'));
        for c=1:length(contents)
            if strcmp(contents{c}, curs.data{6})
                set(handles.alleleList, 'value', c)
                break
            end
        end
        
        %highlight the appropriate Strain
        contents = cellstr(get(handles.strainList,'String'));
        for c=1:length(contents)
            if strcmp(contents{c}, curs.data{8})
                set(handles.strainList, 'value', c)
                break
            end
        end
        
        
        %query the DB to find the path
        query = ['SELECT * FROM locationpc WHERE id=''' id  ''' ']
        curs = exec(handles.conn, query);
        setdbprefs('DataReturnFormat','cellarray');
        curs = fetch(curs, 1);
        
        %display the computer-name and filename parts only (not the full path)
        [mat tok] = regexp(curs.data{3}, '.*\/(.*)', 'match', 'tokens');
        label = sprintf('%s \t %s', curs.data{2}, tok{:}{1})
        set(handles.experimentPath, 'String', label)
        
    end
end

function experimentList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% These are the filter callbacks, which update the ListBoxes
%the _CreateFcn functions are called during object creation, after setting all properties
% and set the background of the boxes white

function strainFilter_Callback(hObject, eventdata, handles)
update_all(handles)

function strainFilter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function chromosomeFilter_Callback(hObject, eventdata, handles)
update_all(handles)

function chromosomeFilter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nameFilter_Callback(hObject, eventdata, handles)
update_all(handles)

function nameFilter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function alleleFilter_Callback(hObject, eventdata, handles)
update_all(handles)

function alleleFilter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function experimentFilter_Callback(hObject, eventdata, handles)
update_all(handles)

function experimentFilter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% These callbacks handle the date/time -entry fields
% when a date/time is changed, just refresh the listboxes
function yearFrom_Callback(hObject, eventdata, handles)
update_all(handles)

function yearFrom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function yearTo_Callback(hObject, eventdata, handles)
update_all(handles)

function yearTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function monthFrom_Callback(hObject, eventdata, handles)
update_all(handles)

function monthFrom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dayFrom_Callback(hObject, eventdata, handles)
update_all(handles)

function dayFrom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function monthTo_Callback(hObject, eventdata, handles)
update_all(handles)

function monthTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dayTo_Callback(hObject, eventdata, handles)
update_all(handles)

function dayTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dateFrom_Callback(hObject, eventdata, handles)
update_all(handles)

function dateFrom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dateTo_Callback(hObject, eventdata, handles)
update_all(handles);

function dateTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeFrom_Callback(hObject, eventdata, handles)
update_all(handles)

function timeFrom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeTo_Callback(hObject, eventdata, handles)
update_all(handles)

function timeTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% When one of the food radio buttons is pressed
% unselect the other options, and refresh the lists
function foodYes_Callback(hObject, eventdata, handles)
set(handles.foodNo, 'value', 0.0);
set(handles.foodEither, 'value', 0.0);

update_all(handles)

function foodNo_Callback(hObject, eventdata, handles)
set(handles.foodYes, 'value', 0.0);
set(handles.foodEither, 'value', 0.0);

update_all(handles)

function foodEither_Callback(hObject, eventdata, handles)
set(handles.foodYes, 'value', 0.0);
set(handles.foodNo, 'value', 0.0);

update_all(handles)





% When one of the vulval-side radio buttons is pressed
% unselect the other options, and refresh the lists
function vulvaLeft_Callback(hObject, eventdata, handles)
set(handles.vulvaRight, 'value', 0.0);
set(handles.vulvaUnspecified, 'value', 0.0);
set(handles.vulvaEither, 'value', 0.0);

update_all(handles)


function vulvaRight_Callback(hObject, eventdata, handles)
set(handles.vulvaLeft, 'value', 0.0);
set(handles.vulvaUnspecified, 'value', 0.0);
set(handles.vulvaEither, 'value', 0.0);

update_all(handles)


function vulvaUnspecified_Callback(hObject, eventdata, handles)
set(handles.vulvaLeft, 'value', 0.0);
set(handles.vulvaRight, 'value', 0.0);
set(handles.vulvaEither, 'value', 0.0);

update_all(handles)


function vulvaEither_Callback(hObject, eventdata, handles)
set(handles.vulvaLeft, 'value', 0.0);
set(handles.vulvaRight, 'value', 0.0);
set(handles.vulvaUnspecified, 'value', 0.0);

update_all(handles)



%when one of the experiment-ordering buttons is pressed,
%unselect the other and refresh the experiment list
function dateOrderButton_Callback(hObject, eventdata, handles)
set(handles.uncertaintyOrderButton, 'value', 0);
updateExperimentList(handles, handles.conn);

function uncertaintyOrderButton_Callback(hObject, eventdata, handles)
set(handles.dateOrderButton, 'value', 0);
updateExperimentList(handles, handles.conn);




%These are all helper functions that construct SQL subqueries, or join subqueries
function orderQuery=orderquery(handles)
if get(handles.uncertaintyOrderButton, 'value')==1.0
    orderQuery = 'ORDER BY uncertaintyScore(id)';
else
    orderQuery = 'ORDER BY datestamp';
end



function foodQuery=foodquery(handles)
if get(handles.foodYes, 'value')==1.0
    foodQuery = 'food = ''1''';
elseif get(handles.foodNo, 'value')==1.0
    foodQuery = 'food = ''0''';
else
    foodQuery='';
end



function vulvaQuery=vulvaquery(handles)
if get(handles.vulvaLeft, 'value')==1.0
    vulvaQuery = 'vulvaside = ''L''';
elseif get(handles.vulvaRight, 'value')==1.0
    vulvaQuery = 'vulvaside = ''R''';
elseif get(handles.vulvaUnspecified, 'value')==1.0
    vulvaQuery = 'vulvaside = ''X'' OR vulvaside = ''unknown''';
else
    vulvaQuery='';
end



function dateQuery=dateQuery(handles)
dateQuery{1}='';

%bound the time
if ~isempty(get(handles.timeFrom, 'String'))
    dateQuery{end+1} = ['TIME(datestamp) > ''' get(handles.timeFrom, 'String') '''']
end
if ~isempty(get(handles.timeTo, 'String'))
    dateQuery{end+1} = ['TIME(datestamp) < ''' get(handles.timeTo, 'String') '''']
end

%bound the overall date range
if ~isempty(get(handles.dateFrom, 'String'))
    dateQuery{end+1} = ['DATE(datestamp) >= ''' get(handles.dateFrom, 'String') '''']
end
if ~isempty(get(handles.dateTo, 'String'))
    dateQuery{end+1} = ['DATE(datestamp) <= ''' get(handles.dateTo, 'String') '''']
end

%we use the day & month values several times, so copy them
%into variable with shorter names
monthFrom = get(handles.monthFrom, 'String');
dayFrom = get(handles.dayFrom, 'String');
monthTo = get(handles.monthTo, 'String');
dayTo = get(handles.dayTo, 'String');

%bound the day-of-year month-day
if ~isempty(monthFrom) && ~isempty(dayFrom)
    dateQuery{end+1} = ['DAYOFYEAR(CONCAT(''2012'', DATE_FORMAT(datestamp, ''-%c-%d'') )) >= DAYOFYEAR(''2012-' monthFrom '-' dayFrom  ''')' ]
end
if ~isempty(monthTo) && ~isempty(dayTo)
    dateQuery{end+1} = ['DAYOFYEAR(CONCAT(''2012'', DATE_FORMAT(datestamp, ''-%c-%d'') )) <= DAYOFYEAR(''2012-' monthTo '-' dayTo  ''')' ]
end


%accepts a cell-array of strings, prefixes them with 'WHERE' and joins them with 'AND'
function andQuery=andTerms(values)
andQuery = '';

if ~isempty(values)
    
    first=1;
    
    for c=1:length(values)
        
        if ~isempty(values{c})
            if first == 1
                first = 0;
                andQuery = ['WHERE ' values{c}];
            else
                andQuery = [andQuery ' AND ' values{c}];
            end
        end
    end
    
end


%accepts a cell-array of fields and value
%constructs sub-queries like (allele LIKE '%a%' OR allele LIKE '%b%')
function orQuery=orTerms(handles,field, values)
orQuery = '';

if strcmp(field, 'strain') || strcmp(field, 'allele') || strcmp(field, 'name') || strcmp(field, 'chromosome')
    exact = eval(['get(handles.' field 'Exact, ''value'')']);
else
    exact = 0;
end

if ~isempty(values)
    first=1;
    
    for c=1:length(values)
        
        if ~isempty(values{c})
            if first == 1
                first = 0;
                
                if exact
                    orQuery = [field ' = ''' values{c} ''''];
                else
                    orQuery = [field ' LIKE ''%' values{c} '%'''];
                end
            else
                if exact
                    orQuery = [orQuery ' OR ' field ' IS ' values{c} ];
                else
                    orQuery = [orQuery ' OR ' field ' LIKE ''%' values{c} '%'''];
                end
            end
        end
    end
    
    if ~isempty(orQuery)
        orQuery = ['(' orQuery ')']
    end
    
end






%These functions actually update the lists
%by querying the database
function updateStrainList(handles, dbHandle)
subqueries = [orTerms(handles,'chromosome', {get(handles.chromosomeFilter,'String')}) orTerms(handles,'name', {get(handles.nameFilter,'String')}) orTerms(handles,'allele', {get(handles.alleleFilter,'String')}) orTerms(handles,'id', {get(handles.experimentFilter,'String')}) orTerms(handles,'strain', {get(handles.strainFilter,'String')}) dateQuery(handles) foodquery(handles)  vulvaquery(handles)];

query = ['SELECT DISTINCT strain FROM info ' andTerms(subqueries) ' ORDER BY strain']

curs = exec(dbHandle, query);
setdbprefs('DataReturnFormat','cellarray');
curs = fetch(curs, 1000);

set(handles.strainList, 'String', curs.data(:,1))
set(handles.strainList, 'Value', 1)
set(handles.strainCount, 'String', rows(curs));



function updateChromosomeList(handles, dbHandle)
subqueries = [orTerms(handles,'chromosome', {get(handles.chromosomeFilter,'String')}) orTerms(handles,'name', {get(handles.nameFilter,'String')}) orTerms(handles,'allele', {get(handles.alleleFilter,'String')}) orTerms(handles,'id', {get(handles.experimentFilter,'String')}) orTerms(handles,'strain', {get(handles.strainFilter,'String')}) dateQuery(handles) foodquery(handles)  vulvaquery(handles)];

query = ['SELECT DISTINCT chromosome FROM info ' andTerms(subqueries) ' ORDER BY chromosome']

curs = exec(dbHandle, query);
setdbprefs('DataReturnFormat','cellarray');
curs = fetch(curs, 1000);
set(handles.chromosomeList, 'String', curs.data(:,1))
set(handles.chromosomeList, 'Value', 1)
set(handles.chromosomeCount, 'String', rows(curs));



function updateNameList(handles, dbHandle)
subqueries = [orTerms(handles,'chromosome', {get(handles.chromosomeFilter,'String')}) orTerms(handles,'name', {get(handles.nameFilter,'String')}) orTerms(handles,'allele', {get(handles.alleleFilter,'String')}) orTerms(handles,'id', {get(handles.experimentFilter,'String')}) orTerms(handles,'strain', {get(handles.strainFilter,'String')})  dateQuery(handles) foodquery(handles)  vulvaquery(handles)];

if ~isempty(get(handles.alleleFilter,'String'))
    subqueries = [orTerms(handles,'chromosome', {get(handles.chromosomeFilter,'String')}) orTerms(handles,'name', {get(handles.nameFilter,'String')}) orTerms(handles,'allele', {get(handles.alleleFilter,'String')}) dateQuery(handles) foodquery(handles)  vulvaquery(handles)]
end

query = ['SELECT DISTINCT name FROM info ' andTerms(subqueries) ' ORDER BY name']

curs = exec(dbHandle, query);
setdbprefs('DataReturnFormat','cellarray');
curs = fetch(curs, 1000);
set(handles.nameList, 'String', curs.data(:,1));
set(handles.nameList, 'Value', 1);
set(handles.nameCount, 'String', rows(curs));



function updateAlleleList(handles, dbHandle)
subqueries = [orTerms(handles,'chromosome', {get(handles.chromosomeFilter,'String')}) orTerms(handles,'name', {get(handles.nameFilter,'String')}) orTerms(handles,'allele', {get(handles.alleleFilter,'String')}) orTerms(handles,'id', {get(handles.experimentFilter,'String')}) orTerms(handles,'strain', {get(handles.strainFilter,'String')}) dateQuery(handles) foodquery(handles)  vulvaquery(handles)];
query = ['SELECT DISTINCT allele FROM info ' andTerms(subqueries) ' ORDER BY allele']

curs = exec(dbHandle, query);
setdbprefs('DataReturnFormat','cellarray');
curs = fetch(curs, 1000);
set(handles.alleleList, 'String', curs.data(:,1));
set(handles.alleleList, 'Value', 1);
set(handles.alleleCount, 'String', rows(curs));



function experimentIDs=updateExperimentList(handles, dbHandle)
subqueries = [orTerms(handles,'chromosome', {get(handles.chromosomeFilter,'String')}) orTerms(handles,'name', {get(handles.nameFilter,'String')}) orTerms(handles,'allele', {get(handles.alleleFilter,'String')}) orTerms(handles,'id', {get(handles.experimentFilter,'String')}) orTerms(handles,'strain', {get(handles.strainFilter,'String')}) dateQuery(handles) foodquery(handles)  vulvaquery(handles)];
query = ['SELECT DISTINCT id, datestamp FROM info ' andTerms(subqueries) ' ' orderquery(handles)]

curs = exec(dbHandle, query);
setdbprefs('DataReturnFormat','cellarray');
curs = fetch(curs, 1000);

experimentIDs = curs.data(:,1);

%set(handles.experimentList, 'String', curs.data(:,1));
if strcmp(curs.data{:,1}, 'No Data')
    set(handles.experimentList, 'String', curs.data(:,1));%will display 'No Data'
else
    
    if get(handles.uncertaintyOrderButton, 'value')==1
        
        %get the threshold for whether a chunk is bad
        hMainGui=getappdata(0, 'hMainGui')
        getappdata(hMainGui.figure1, 'threshold')


        %cont the 'bad' chunks for each experiment
        for i=1:length(experimentIDs)
            query = ['SELECT COUNT(id) FROM main.wormmorphology WHERE experiment_id = ' num2str(experimentIDs(i)) ' AND reliability <= ' num2str(threshold)];
            curs = exec(dbHandle, query);
            setdbprefs('DataReturnFormat','cellarray');
            curs = fetch(curs, 1);
            badChunks(i,1)=experimentIDs(i);
            badChunks(i,2)=curs.data(1,1);
        end
                
        %re-sort the experimentIs based on this count
        badChunks=sortrows(badChunks, -2);
        experimentIDs = badchunks(:,1);
    end
    
    set(handles.experimentList, 'String', curs.data(:,2));%display the dates
end

l=length(experimentIDs);

%if the previously-selected experiemnt has been filtered out, select the experiment at the top of the list
if get(handles.experimentList, 'Value') > length(experimentIDs)
    set(handles.experimentList, 'Value', 1);
end

experimentList_Callback(handles.experimentList, 0, handles)
set(handles.experimentCount, 'String', rows(curs));


function update_all(handles)
updateChromosomeList(handles, handles.conn);
updateNameList(handles, handles.conn);
updateAlleleList(handles, handles.conn);
updateExperimentList(handles, handles.conn);
updateStrainList(handles, handles.conn);
updateNameList(handles, handles.conn);




% --- When the Exact buttons are pressed, repopulate all the ListBoxes
function strainExact_Callback(hObject, eventdata, handles)
update_all(handles);

function alleleExact_Callback(hObject, eventdata, handles)
update_all(handles);

function nameExact_Callback(hObject, eventdata, handles)
update_all(handles);

function chromosomeExact_Callback(hObject, eventdata, handles)
update_all(handles);
