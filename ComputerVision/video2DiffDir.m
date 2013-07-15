% Differentiate all the video files in this directory.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
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
