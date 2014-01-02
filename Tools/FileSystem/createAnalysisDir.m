function createAnalysisDir(hObject, eventdata, handles)
% Function to load a directory and sort the contents to start analysis
% root dir
%   .avi
%   _seg.avi
%
%   .data
%       _seg.dat
%       _diff.mat
%       _status.mat
%       .log
%       vignette.dat
%       .xml
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
mydata = guidata(hObject);
expList = mydata.experimentList;

for i=1:length(expList)
    
    cd(expList{i}.dir);
    if ~isdir('.data')
        mkdir('.data');
    end
    if ~isdir('results')
        mkdir('results');
    end
    fieldNames = fieldnames(expList{i});
    for j=1:length(fieldNames)
        if ~isempty(expList{i}.(fieldNames{j})) && sum(strcmp(fieldNames(j),{'xml','vignette','log','status'}))
            if isempty(strfind(expList{i}.(fieldNames{j}), '.data'))
                %retrieve file name without dir
                stringSepId = strfind(expList{i}.(fieldNames{j}), filesep);
                fileName = expList{i}.(fieldNames{j})((stringSepId(end)+1):end);
                %create destination path
                fileDest = fullfile(expList{i}.dir,'.data', fileName);
                %try moving the file, if fails, just copy
                try
                    movefile(expList{i}.(fieldNames{j}), fileDest,'f');
                catch ME1
                    copyfile(expList{i}.(fieldNames{j}), fileDest);
                end
                expList{i}.(fieldNames{j}) = fileDest;
            end
        end
    end
    
    
    %cleanup
    if isdir(fullfile(pwd,'module1'))
        rmdir('module1','s');
    end
    if isdir(fullfile(pwd,'module2'))
        rmdir('module2','s');
    end
    if isdir(fullfile(pwd,'.process'))
        rmdir('.process','s');
    end
    
    if isdir(fullfile(pwd,'.process'))
        rmdir('.process','s');
    end
    if exist(fullfile(pwd,'module1.log'),'file')
        delete('module1.log')
    end
    if exist(fullfile(pwd,'module2.log'),'file')
        delete('module2.log')
    end
end
mydata.experimentList = expList;
guidata(hObject,mydata);
end

