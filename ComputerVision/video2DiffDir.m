% Differentiate all the video files in this directory.
files = dir('*.avi');
for i = 1:length(files)
    disp(['Processing file ' num2str(i) '/' num2str(length(files)) ...
        ' : ''' files(i).name '''']);
    
    % Process the video file.
    tic;
    file = strrep(logFile, '.avi', '');
    video2Diff(files(i).name, [file '_videoDiff.mat'], [], []);
    toc;
end
