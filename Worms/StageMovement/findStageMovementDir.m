% Print a separator.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
disp('*');
disp('*');
disp('*');

% Open a file for errors.
errorFile = 'errors.rtf';
if exist(errorFile, 'file')
    delete(errorFile);
end
fid = fopen(errorFile, 'w');
fprintf(fid, '***\n');
fprintf(fid, '***\n');
fprintf(fid, '***\n');

% Find the stage movements for all appropriate files in this directory.
files = dir('*.log.csv');
for i = 1:length(files)
    
    % Process the log file.
    logFile = files(i).name;
    file = strrep(logFile, '.log.csv', '');
    disp(['Processing file ' num2str(i) '/' num2str(length(files)) ...
        ' : ''' file '''']);
    
    % Does the info file exist?
    infoFile = [file '.info.xml'];
    if ~exist(infoFile, 'file')
        warning([infoFile ' is missing! Skipping this file ...']);
        continue;
    end
    
    % Does the video diff file exist?
    diffFile = [file '_diff.mat'];
    if ~exist(diffFile, 'file')
        warning([diffFile ' is missing! Building this file ...']);
        video2Diff([file '.avi'], diffFile);
    end
    
    % Find the stage movements.
    fsmError = [];
    diaryFile = [file '.rtf'];
    if exist(diaryFile, 'file')
        delete(diaryFile);
    end
    diary(diaryFile);
    try
        [f m l] = findStageMovement(infoFile, logFile, diffFile, 1, []);
    catch exception
        fsmError = exception;
        warning(exception.identifier, ['error -> ' exception.message]);
    end
    diary off;
    
    % Report the error.
    if ~isempty(fsmError)
        fprintf(fid, '%s\n', [file ': ' fsmError.message]);
        fprintf(fid, '***\n');
        fprintf(fid, '***\n');
        fprintf(fid, '***\n');
    end
    
    % Save the figure.
    figFile = [file '.fig'];
    if exist(figFile, 'file')
        delete(figFile);
    end
    fig = get(0,'CurrentFigure');
    j = 3;
    while isempty(fig) && j > 0
        pause(1);
        fig = get(0,'CurrentFigure');
        j = j - 1;
    end
    saveas(fig, figFile, 'fig');
    close(fig);
    
    % Print a separator.
    disp('*');
    disp('*');
    disp('*');
end

% Clean up.
fclose(fid);
