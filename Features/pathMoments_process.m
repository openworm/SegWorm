%this function will extract path moment feature
%Last edited: 17 Dec 2010
%By Tadas Jucikas
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

function pathMoments_process(hObject, eventdata, handles, myAviInfo)

mydata = guidata(hObject);
expInfo = mydata.experimentList(mydata.currentFile);

maxOrderOfMoments = 2;

fnameIn = expInfo.log;
fnameOut = fullfile(expInfo.dir,'results',strcat(expInfo.fileName,'_pathMoments.mat'));

pathMomentsArray = pathMoments(fnameIn, fnameOut, maxOrderOfMoments);

if handles.preferences.nas
    %copy to server
    [msg] = copyToNAS(fnameOut, handles.preferences.version);
    set(handles.status1,'String',msg);
end
%         try
%             %lets get the calibration data gain
%             xmlFile = strcat(fileName{1}(1:end-8),'.info.xml');
%             micronsppix = loadXMLdata(fullfile(rootDir, xmlFile));
%             aviInfo.micronsppix = micronsppix;
%         catch ME1
%             aviInfo.micronsppix = aviInfo.micronsppix1;
%         end
str1 = strcat('Path Moments features successfuly extracted for file: ',{' '},expInfo.segDat,{' '},'. Data saved in *.mat file.');
set(handles.status1,'String',str1{1});

load(expInfo.status);
fileInfo.pathMoments.version = mydata.preferences.version;
fileInfo.pathMoments.completed = 1;
fileInfo.pathMoments.timeStamp = datestr(now);
save(expInfo.status, 'fileInfo');
guidata(hObject,mydata);