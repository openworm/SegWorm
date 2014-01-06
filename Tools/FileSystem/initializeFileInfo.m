%this function will initialize fileInfo structure. It will hold the current
%status of the file
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function [fileInfo] = initializeFileInfo(mydata, expListCurrent)

fileInfo.expList = expListCurrent;
fileInfo.timeStamp = datestr(now);

fileInfo.stageMovement.version = mydata.preferences.version;
fileInfo.stageMovement.completed = 0;
fileInfo.stageMovement.completedDiff = 0;
fileInfo.stageMovement.timeStamp = '';

fileInfo.segmentation.version = mydata.preferences.version;
fileInfo.segmentation.timeStamp = '';
fileInfo.segmentation.completed = 0;

fileInfo.sternberg.version = mydata.preferences.version;
fileInfo.sternberg.completed = 0;
fileInfo.sternberg.timeStamp = '';

fileInfo.morphology.version = mydata.preferences.version;
fileInfo.morphology.completed = 0;
fileInfo.morphology.timeStamp = '';

fileInfo.schafer.version = mydata.preferences.version;
fileInfo.schafer.completed = 0;
fileInfo.schafer.timeStamp = '';
fileInfo.schafer.pathMomentsCompleted = 0;

fileInfo.omegaTurns.version = mydata.preferences.version;
fileInfo.omegaTurns.completed = 0 ;
fileInfo.omegaTurns.timeStamp = '';

fileInfo.otherFeatures.version = mydata.preferences.version;
fileInfo.otherFeatures.completed = 0 ;
fileInfo.otherFeatures.timeStamp = '';


fileInfo.copyToNAS.videoDiff = 0;
fileInfo.copyToNAS.videoDiffDS = '';

fileInfo.copyToNAS.stageMotion = 0;
fileInfo.copyToNAS.stageMotionDS = '';

fileInfo.copyToNAS.failedFramesFile = 0;
fileInfo.copyToNAS.failedFramesFileDS = '';

fileInfo.copyToNAS.segDat = 0;
fileInfo.copyToNAS.segDatDS = '';

fileInfo.copyToNAS.overlayAvi = 0;
fileInfo.copyToNAS.overlayAviDS = '';
