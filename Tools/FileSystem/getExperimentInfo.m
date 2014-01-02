% get experiment info
%
% This function finds all the experiment files
%
% Input: 
%   file1 - experiment avi or seg file
%
% Output:
%   exp1 - cell with all the info that was found
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function [exp1] = getExperimentInfo (file1)
exp1 = '';

%remove trailing spaces
file1 = strcat(file1);

%lets check that the input is a file or a directory
if ~(exist(file1,'file')==2) 
	return;
end

%retrieve crucial information from the input file
if strfind(file1,'segInfo.mat')
    %if segmentation file is provided
    id1 = strfind(file1,'module2');
    mainDir = file1(1:id1-2);
    id2 = strfind(file1,filesep);
    id3 = strfind(file1,'segInfo.mat');
    fileName = file1(id2(end)+1:id3-1);
elseif strcmp(file1(end-3:end),'.avi') && ~strcmp(file1(end-6:end-4),'seg')
    %if video file is provided    
    id1 = strfind(file1,filesep);
    mainDir = file1(1:id1(end)-1);
    id2 = strfind(file1,'.avi');
    fileName = file1(id1(end)+1:id2-1);
    
    %lets check if the file name is a part of the dir path, if that is the
    %case, we will not be able to parse it
    if strfind(file1(1:id1(end)),fileName)
        return;
    end
else
    return;
end

dirContents = dirrec(mainDir);
fileTraceFlag = ~cellfun(@isempty, strfind(dirContents, fileName));
dirContents = dirContents(fileTraceFlag);
exp1.dir = mainDir;
exp1.segDatDir = fullfile(mainDir, '.data',[fileName,'_seg']);
exp1.fileName = fileName;
exp1.segDat = getRightFile(dirContents, 'segInfo.mat');
exp1.avi = getRightFile(dirContents, '.avi');
exp1.xml = getRightFile(dirContents, 'info.xml');
exp1.vignette = getRightFile(dirContents, 'vignette.dat');
exp1.log = getRightFile(dirContents, 'log.csv');
exp1.videoDiff = getRightFile(dirContents, 'diff.mat');
exp1.status = getRightFile(dirContents, 'status.mat');
exp1.stageMotion = getRightFile(dirContents, 'stageMotion.mat');
exp1.failedFramesFile = getRightFile(dirContents, 'failedFrames.mat');
exp1.overlayAvi = getRightFile(dirContents, '_seg.avi');

exp1.results.sternberg = [];
exp1.results.morphology = [];
exp1.results.schafer = [];
exp1.results.omegaTurns = [];
exp1.results.otherFeatures = [];

%if video file or log file for video file could not be found - lets skip
%this entry
if isempty(exp1.avi) || isempty(exp1.log)
    return;
end
end