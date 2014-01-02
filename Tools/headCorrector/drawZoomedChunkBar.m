function drawZoomedChunkBar(handles)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
mydata=guidata(handles.openButton);

%select the correct axis, and get their length
axes(handles.zoomedChunkBar);
axis_position=get(handles.zoomedChunkBar, 'Position');
height=axis_position(4);
total_length=axis_position(3);


%the autumn colormap is a nice red to yellow scale
cmap = [1.0000, 0, 0; 1.0000, 0.0159, 0; 1.0000, 0.0317, 0; 1.0000, 0.0476, 0; 1.0000, 0.0635, 0; 1.0000, 0.0794, 0; 1.0000, 0.0952, 0; 1.0000, 0.1111, 0; 1.0000, 0.1270, 0; 1.0000, 0.1429, 0; 1.0000, 0.1587, 0; 1.0000, 0.1746, 0; 1.0000, 0.1905, 0; 1.0000, 0.2063, 0; 1.0000, 0.2222, 0; 1.0000, 0.2381, 0; 1.0000, 0.2540, 0; 1.0000, 0.2698, 0; 1.0000, 0.2857, 0; 1.0000, 0.3016, 0; 1.0000, 0.3175, 0; 1.0000, 0.3333, 0; 1.0000, 0.3492, 0; 1.0000, 0.3651, 0; 1.0000, 0.3810, 0; 1.0000, 0.3968, 0; 1.0000, 0.4127, 0; 1.0000, 0.4286, 0; 1.0000, 0.4444, 0; 1.0000, 0.4603, 0; 1.0000, 0.4762, 0; 1.0000, 0.4921, 0; 1.0000, 0.5079, 0; 1.0000, 0.5238, 0; 1.0000, 0.5397, 0; 1.0000, 0.5556, 0; 1.0000, 0.5714, 0; 1.0000, 0.5873, 0; 1.0000, 0.6032, 0; 1.0000, 0.6190, 0; 1.0000, 0.6349, 0; 1.0000, 0.6508, 0; 1.0000, 0.6667, 0; 1.0000, 0.6825, 0; 1.0000, 0.6984, 0; 1.0000, 0.7143, 0; 1.0000, 0.7302, 0; 1.0000, 0.7460, 0; 1.0000, 0.7619, 0; 1.0000, 0.7778, 0; 1.0000, 0.7937, 0; 1.0000, 0.8095, 0; 1.0000, 0.8254, 0; 1.0000, 0.8413, 0; 1.0000, 0.8571, 0; 1.0000, 0.8730, 0; 1.0000, 0.8889, 0; 1.0000, 0.9048, 0; 1.0000, 0.9206, 0; 1.0000, 0.9365, 0; 1.0000, 0.9524, 0; 1.0000, 0.9683, 0; 1.0000, 0.9841, 0; 1.0000, 1.0000, 0];


%work out which chunk to center the display on, and how many frames will be
%represented
centerChunk = mydata.currentChunk;

if centerChunk == 1
    centerChunk = 2;
elseif centerChunk > length(mydata.chunktimes)-1
    centerChunk = centerChunk - 1;
end

chunkStartTimes=mydata.chunktimes - mydata.chunktimes(centerChunk-1);


if centerChunk  >= length(mydata.chunktimes)-1
    numFrames = get(mydata.aviHandle, 'numFrames') -  chunkStartTimes(centerChunk - 1);
else
    numFrames = (chunkStartTimes(centerChunk + 2) -  chunkStartTimes(centerChunk - 1));
end  

    
%normalise reliabilities
%reliabilities = (5+mydata.reliabilities) / max(mydata.reliabilities);
reliabilities = (mydata.reliabilities);
reliabilities(isnan(reliabilities))=0; %replace NaN with 0
reliabilities(isinf(reliabilities))=0; %replace NaN with 0

for c=(centerChunk-1):(centerChunk + 1)
    
    %find the x coordinate of the LHS of the rectangle
    x = chunkStartTimes(c) * total_length / numFrames
    
    %find the length of the rectangle
    if c == (centerChunk + 1)
        rect_length = total_length - x
    else
        rect_length = (chunkStartTimes(c+1) - chunkStartTimes(c)) * total_length / numFrames
    end
    
    %draw the rectangle
    %color=cmap(round(reliabilities(c)*(length(cmap)-1))+1, :);
    if reliabilities(c) <= str2num(get(handles.thresholdField, 'String'))
        color=[1, 0, 0];
    else
        color=[0.5, 0.5, 0.5];
    end
    
    rectangle('Position', [x, 0, rect_length, height], 'EdgeColor','k', 'FaceColor', color, 'HitTest', 'off');
    
end

%save the dimensions, so that they can be accessed by updateZoomedProgress(handles); 
mydata.zoomedChunkBarTotalLength = total_length;
mydata.zoomedChunkBarLength = total_length/300;
mydata.zoomedChunkBarHeight = height;

%if the position marker exists, move it;
%if it does not exist, create it
if isfield(mydata, 'zoomedPositionMarker')
    uistack(mydata.zoomedPositionMarker, 'top') 
    set(mydata.positionMarker, 'Position', [0, 0, mydata.chunkBarLength, mydata.chunkBarHeight]);
else
    mydata.zoomedPositionMarker = rectangle('Position', [0, 0, mydata.zoomedChunkBarLength, mydata.zoomedChunkBarHeight], 'FaceColor', 'b'); %[x,y,w,h]
end

guidata(handles.openButton, mydata);