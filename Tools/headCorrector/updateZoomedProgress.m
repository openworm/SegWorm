function updateZoomedProgress(handles)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
mydata=guidata(handles.openButton);

%select the correct axes
axes(handles.zoomedChunkBar);


%unless the current chunk is the first, last, or second to last,
%center display on the current frame
centerChunk = mydata.currentChunk;

if centerChunk == 1
    centerChunk = 2;
elseif centerChunk == length(mydata.chunktimes)
    centerChunk = centerChunk - 2;
elseif centerChunk == length(mydata.chunktimes)-1
    centerChunk = centerChunk - 1;
end
    

%the total number of frames represented by the bar
numFrames = (mydata.chunktimes(centerChunk + 2) -  mydata.chunktimes(centerChunk - 1));

x = (mydata.currentFrame - mydata.chunktimes(centerChunk-1)) * mydata.zoomedChunkBarTotalLength / numFrames;
set(mydata.zoomedPositionMarker, 'position', [x, 0, mydata.zoomedChunkBarLength, mydata.zoomedChunkBarHeight], 'FaceColor', 'b')
guidata(handles.openButton, mydata);