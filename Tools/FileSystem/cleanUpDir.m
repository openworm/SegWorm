function cleanUpDir(hObject, eventdata, handles)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%retrieving GUI data
mydata = guidata(hObject);
%checking if the directory is passed to this function
if ~isfield(mydata, 'dirAvi')
    set(handles.status1,'String','Please load the directory first.');
    return;
end
dataDir = mydata.dirAvi;

if isempty(dataDir)
    dataDir = uigetdir('*.*','Enter worm video directory.');
end
if dataDir == 0
    return;
end

dataFiles = dirrec(dataDir,'.dat');
%here we inspect the dataDir and look for data files. We will also
%clean up the directory in case we have some unfinsihed pre-cursor files
%these files usually have _old.dat appended to them

segOldListFlag = ~cellfun(@isempty, strfind(dataFiles, '_old.dat'));
segOldList = dataFiles(segOldListFlag);

for i=1:length(segOldList)
    segName = strcat(segOldList{i}(1:end-8),'.dat');
    if exist(segName,'file')==2
        delete(segName);
    end
    movefile(segOldList{i},segName);
end

%this part of the code will look for dat files that appear to be
%uncompressed. It will compress them.

segListFlag = ~cellfun(@isempty, strfind(dataFiles, '_seg.dat'));
segList = dataFiles(segListFlag);
unzippedList = segList(~cellfun(@isGZIP, segList));

for i=1:length(unzippedList)
    gzip(unzippedList{i});
    movefile(strcat(unzippedList{i},'.gz'), unzippedList{i});
end

% here we will look for old _block _normBlock or _segInfo files
matFiles = dirrec(dataDir,'.mat');
for i = 1:length(mydata.experimentList)
    matOldFileFlag = ~cellfun(@isempty, strfind(matFiles, [mydata.experimentList{i}.fileName,'_block']));
    matOldFileList = matFiles(matOldFileFlag);
    
    matNormOldFileFlag = ~cellfun(@isempty, strfind(matFiles, [mydata.experimentList{i}.fileName,'_normBlock']));
    matNormOldFileList = matFiles(matNormOldFileFlag);
    
    segInfoOldFileFlag = ~cellfun(@isempty, strfind(matFiles, [mydata.experimentList{i}.fileName,'_segInfo.mat']));
    segInfoOldFileList = matFiles(segInfoOldFileFlag);
    
    filesToDelete = [matOldFileList, matNormOldFileList, segInfoOldFileList];
    for j=1:length(filesToDelete)
        fileName = filesToDelete{j};
        if exist(fileName, 'file') == 2
            delete(fileName);
        end
    end
end