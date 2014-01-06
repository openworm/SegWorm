function fileInfo = findStageMovementProcess(fileInfo, hObject, eventdata, handles) %#ok<INUSL>
% FINDSTAGEMOVEMENTPROCESS - finds stage movements in a video file
%
% Deals with everything that is related to stage movement for the
% experiment specified in fileInfo.
%
% Figures out the frames in the video corresponding to stage movements and
% saves data. 
%
%   Input:
%       fileInfo - variable containing locations of the experiment files
%       that need to be analyzed.
%       hObject, eventdata, handles - GUI variables
%   Output:
%       fileInfo - updated variable with new files created by the function
%
% Copyright:
% Tadas Jucikas, MRC Laboratory of Molecular Biology, Cambridge, UK
%
%
%   See Also:
%   video2Diff
%   findStageMovement
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

mydata = guidata(hObject);
vidFileName     = fileInfo.expList.avi;
logFileName     = fileInfo.expList.log;
statusFileName  = fileInfo.expList.status;
xmlFileName     = fileInfo.expList.xml;
set(handles.videoName,'String',vidFileName); 

% Lets check if we found the log file
if isempty(fileInfo.expList.log)
    % If we didn't find it - thow an error
    error('findStageMovementProcess:files', ['Log file could not be found for experiment: -',strrep(fileInfo.expList.avi,'\','/')])
end

% Create the diff output file path
diffFileName                 = strrep(fileInfo.expList.log, '.log.csv', '_diff.mat');
stageMotionFileName          = strrep(fileInfo.expList.log, '.log.csv', '_stageMotion.mat');
fileInfo.expList.videoDiff   = diffFileName;
fileInfo.expList.stageMotion = stageMotionFileName;

% Save new file path
str = strcat('Computing video diff for file:',{' '},vidFileName,'. Please wait...');
set(handles.status1,'String',str{1});
% Draw GUI
drawnow;

% Check if video differential was completed previously and don't calculate
% it again unless it was specified in the preferences.

if handles.preferences.redoStageMovDiff || fileInfo.stageMovement.completedDiff == 0 
    % Compute video differential which will allow localization of stage
    % movements.
    video2Diff(vidFileName, diffFileName, [], @simpleProgressUpdate2, handles.status1);
    [msg, msgid] = lastwarn;
    if strcmpi(msgid,'video2Diff:WeirdFPS')
        error('findStageMovementProcess:WeirdFPS', msg);
    end
    % Update video differential location
    mydata.experimentList{mydata.currentFile}.videoDiff = diffFileName;
    % set the flag
    fileInfo.stageMovement.completedDiff = 1;
    save(getRelativePath(statusFileName), 'fileInfo');
else
    % Notify that it was completed previously
    set(handles.status1,'String','Stage motion detection video diff completed previously. Previous data will be used.');
end

% Check if we have completed stage movement detection process previously.
% Don't do it again unless it's specified in the preferences.

if handles.preferences.redoStageMovDet || fileInfo.stageMovement.completed == 0 || fileInfo.stageMovement.version < 2.3
    
    str = strcat('Finding stage movement frames for file:', {' '}, vidFileName, '. Please wait...');
    set(handles.status1, 'String', str{1});
    
    % Compute the stage motion
    axes(handles.widthProfile); %#ok<MAXES>
    %[frames, movesI, locations] = findStageMovement(xmlFileName, logFileName, diffFileName, 1, handles.widthProfile); %#ok<NASGU,ASGLU>
    % Do files exist
    if exist(xmlFileName, 'file') == 2 && exist(logFileName, 'file') == 2 && exist(diffFileName, 'file') == 2
        [frames, movesI, locations] = findStageMovement(getRelativePath(xmlFileName), getRelativePath(logFileName), getRelativePath(diffFileName), 1, handles.widthProfile); %#ok<NASGU,ASGLU>
        % Save the results
        save(getRelativePath(stageMotionFileName), 'frames', 'movesI', 'locations');
        mydata.experimentList{mydata.currentFile}.stageMotion = stageMotionFileName;
    else
        if exist(xmlFileName, 'file') ~= 2 
            missingStr = 'XML file could not be found!';
        elseif exist(logFileName, 'file') ~= 2
            missingStr = 'Log file could not be found!';
        else
            missingStr = 'Diff file could not be found!';
        end
        missingStr = strcat(missingStr,{' '}, 'For experiment:',{' '},fileInfo.expList.fileName, {' '},'Dir:',{' '}, strrep(fileInfo.expList.dir,'\','_'));
        error('findStageMovement:fileNotFound', missingStr{1});
    end
    
    % Update process file
    fileInfo.stageMovement.version = mydata.preferences.version;
    fileInfo.stageMovement.completed = 1;
    fileInfo.stageMovement.timeStamp = datestr(now);
    
    str=strcat('Stage motion detection successfully finished for video file:',{' '}, vidFileName);
    set(handles.status1,'String',str{1});
else
    set(handles.status1,'String','Stage motion detection completed previously!');
end

save(getRelativePath(statusFileName), 'fileInfo');
guidata(hObject, mydata);