function chunkLabelOutput(hAndtData, myAviInfo, chunkLabels, datFileName)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%hAndtData, frames, myAviInfo
totalFrames = myAviInfo.numFrames + myAviInfo.nHiddenFinalFrames;
chunkLen = length(hAndtData);
samples = [1:3 5:7] / 8;

coloConfBased = zeros(1, chunkLen);
orthoConfBased = zeros(1, chunkLen);
paraConfBased = zeros(1, chunkLen);

sizeBased = zeros(1, chunkLen);
%proxBased = zeros(1, chunkLen);
chunkSize = zeros(chunkLen, 2);
chunkPositions = zeros(chunkLen, 2);

for i=1:chunkLen
    
    if i==chunkLen
        chunkEnd = totalFrames;
    else
        chunkEnd = hAndtData{i+1}.globalStartFrame;
    end
    
    chunkPositions(i,1) = hAndtData{i}.globalStartFrame;
    chunkPositions(i,2) = chunkEnd;
    
    if hAndtData{i}.hOrthoConfidence > hAndtData{i}.tOrthoConfidence
        orthoConfBased(i) = 1;
    end
    if hAndtData{i}.hParaConfidence > hAndtData{i}.tParaConfidence
        paraConfBased(i) = 1;
    end
    if hAndtData{i}.hColourConf > hAndtData{i}.tColourConf
        coloConfBased(i) = 1;
    end            
    
    %size based chunk label
    if (hAndtData{i}.chunkValidFrameCounter/myAviInfo.fps) > 3
        sizeBased(i) = 1;
    else
        sizeBased(i) = 0;
    end
    
    %chunk size
    chunkSize(i,1) = diff(chunkPositions(i,:));
    chunkSize(i,2) = hAndtData{i}.chunkValidFrameCounter;
    
end

%how many frames after valid frame till the end of chunk?

%lets create a value in each chunk struct for the last frame of the chunk
for i=1:chunkLen-1
    hAndtData{i}.endFrame = hAndtData{i+1}.startFrame;
end
hAndtData{end}.endFrame = totalFrames;

chunkGap = zeros(1, chunkLen);
isFlipped = nan(1, chunkLen);
chunkProximity = nan(chunkLen, 2);

verbose = 0;

for i=1:chunkLen-1
    firstChunkWorm = getFirstWormFromChunk(datFileName, hAndtData{i+1});
    lastChunkWorm = getLastWormFromChunk(datFileName, hAndtData{i});
    
    [worm, proximityConf, flipProximityConf] = orientWormAtCentroid(lastChunkWorm, firstChunkWorm, samples);
    
    isFlipped(i) = worm.orientation.head.isFlipped~=firstChunkWorm.orientation.head.isFlipped;
    
    chunkProximity(i,1) = proximityConf;
    chunkProximity(i,2) = flipProximityConf;
    
    chunkGap(i) = firstChunkWorm.video.frame - lastChunkWorm.video.frame;
    
    if verbose
        i
        drawImages(firstChunkWorm, lastChunkWorm, myAviInfo);
    end
end

% %proximity based
% for i=2:chunkLen-1
%     if i==12
%         1;
%     end
%     if sizeBased(i-1)==0 && sizeBased(i+1)==1 && confBased(i-1) == 1 && confBased(i+1) == 1
%         proxBased(i)=1;
%     elseif sizeBased(i-1)==0 && sizeBased(i+1)==0 && confBased(i-1) == 1 && confBased(i+1) == 1
%         proxBased(i)=2;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==0 && confBased(i-1) == 1 && confBased(i+1) == 1
%         proxBased(i)=3;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==1 && confBased(i-1) == 1 && confBased(i+1) == 1
%         proxBased(i)=4;
%     elseif sizeBased(i-1)==0 && sizeBased(i+1)==1 && confBased(i-1) ~= 1 && confBased(i+1) == 1
%         proxBased(i)=5;
%     elseif sizeBased(i-1)==0 && sizeBased(i+1)==0 && confBased(i-1) ~= 1 && confBased(i+1) == 1
%         proxBased(i)=6;
%     elseif sizeBased(i-1)==0 && sizeBased(i+1)==1 && confBased(i-1) == 1 && confBased(i+1) ~= 1
%         proxBased(i)=7;
%     elseif sizeBased(i-1)==0 && sizeBased(i+1)==0 && confBased(i-1) == 1 && confBased(i+1) ~= 1
%         proxBased(i)=8;
%     elseif sizeBased(i-1)==0 && sizeBased(i+1)==1 && confBased(i-1) ~= 1 && confBased(i+1) ~= 1
%         proxBased(i)=9;
%     elseif sizeBased(i-1)==0 && sizeBased(i+1)==0 && confBased(i-1) ~= 1 && confBased(i+1) ~= 1
%         proxBased(i)=10;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==1 && confBased(i-1) == 1 && confBased(i+1) ~= 1
%         proxBased(i)=11;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==1 && confBased(i-1) ~= 1 && confBased(i+1) == 1
%         proxBased(i)=12;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==1 && confBased(i-1) ~= 1 && confBased(i+1) ~= 1
%         proxBased(i)=13;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==0 && confBased(i-1) ~= 1 && confBased(i+1) == 1
%         proxBased(i)=14;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==0 && confBased(i-1) == 1 && confBased(i+1) ~= 1
%         proxBased(i)=15;
%     elseif sizeBased(i-1)==1 && sizeBased(i+1)==0 && confBased(i-1) ~= 1 && confBased(i+1) ~= 1
%         proxBased(i)=16;
%     end
% end
%allLabels = [chunkLabels;confBased; sizeBased; proxBased];

manualLabel(1:length(chunkLabels)) = {'good'};
manualLabel(~chunkLabels) = {'bad'};

flippedLabel(1:length(isFlipped)) = {'undefined'};
isFlipped(isnan(isFlipped)) = 3;
flippedLabel(isFlipped==0) = {'0'};
flippedLabel(isFlipped==1) = {'1'};


% confidenceLabel(1:length(allLabels(2,:))) = {'agrees'};
% confidenceLabel(allLabels(2,:)==0) = {'undefined'};
% confidenceLabel(allLabels(2,:)==2) = {'colorationDisagrees'};
% confidenceLabel(allLabels(2,:)==3) = {'movementDisagrees'};

sizeLabel(1:length(sizeBased)) = {'big'};
sizeLabel(~sizeBased) = {'small'};

chunkLenLabel(1:length(chunkSize(:,1))) = {'0'};
for i=1:chunkLen
    chunkLenLabel(i) = {sprintf('%d',chunkSize(i,1))};
end

chunkValidLenLabel(1:length(chunkSize(:,2))) = {'0'};
for i=1:chunkLen
    chunkValidLenLabel(i) = {sprintf('%d',chunkSize(i,2))};
end

% neighboursLabel(1:length(allLabels(4,:))) = {'undefined'};
% neighboursLabel(allLabels(4,:)==1) = {'small+_big+'};
% neighboursLabel(allLabels(4,:)==2) = {'small+_small+'};
% neighboursLabel(allLabels(4,:)==3) = {'big+_small+'};
% neighboursLabel(allLabels(4,:)==4) = {'big+_big+'};
% neighboursLabel(allLabels(4,:)==5) = {'small-_big+'};
% neighboursLabel(allLabels(4,:)==6) = {'small-_small+'};
% neighboursLabel(allLabels(4,:)==7) = {'small+_big-'};
% neighboursLabel(allLabels(4,:)==8) = {'small+_small-'};
% neighboursLabel(allLabels(4,:)==9) = {'small-_big-'};
% neighboursLabel(allLabels(4,:)==10) = {'small-_small-'};
% neighboursLabel(allLabels(4,:)==11) = {'big+_big-'};
% neighboursLabel(allLabels(4,:)==12) = {'big-_big+'};
% neighboursLabel(allLabels(4,:)==13) = {'big-_big-'};
% neighboursLabel(allLabels(4,:)==14) = {'big-_small+'};
% neighboursLabel(allLabels(4,:)==15) = {'big+_small-'};
% neighboursLabel(allLabels(4,:)==16) = {'big-_small-'};

chunkNo(1:length(chunkLabels)) = {'1'};
for i=1:length(chunkNo)
    chunkNo{i} = num2str(i);
end

chunkGapLabel(1:length(chunkGap)) = {'0'};
for i=1:length(chunkNo)
    chunkGapLabel{i} = num2str(chunkGap(i));
end

proximityLabel(1:length(chunkProximity)) = {'0'};
flipProximityLabel(1:length(chunkProximity)) = {'0'};
for i=1:length(chunkNo)
    proximityLabel{i} = num2str(chunkProximity(i,1));
    flipProximityLabel{i} = num2str(chunkProximity(i,2));
end

colourConfidenceLabel(1:length(coloConfBased)) = {'0'};
for i=1:length(chunkNo)
    colourConfidenceLabel{i} = num2str(coloConfBased(i));
end

orthoConfidenceLabel(1:length(orthoConfBased)) = {'0'};
for i=1:length(chunkNo)
    orthoConfidenceLabel{i} = num2str(orthoConfBased(i));
end

paraConfidenceLabel(1:length(paraConfBased)) = {'0'};
for i=1:length(chunkNo)
    paraConfidenceLabel{i} = num2str(paraConfBased(i));
end


allChunkConfidenceLabels = [chunkNo;manualLabel;colourConfidenceLabel;orthoConfidenceLabel;paraConfidenceLabel;sizeLabel; chunkLenLabel;chunkValidLenLabel;chunkGapLabel;proximityLabel;flipProximityLabel;flippedLabel]';

outputName = strrep(datFileName,'segInfo.mat','chunk_labels.csv');

fid = fopen(outputName,'wt');
[~, fileName]= fileparts(outputName);
fprintf(fid, '%s\n', strrep(fileName,'_chunk_labels.csv','.'));
headerlabels = {'Chunk no', 'Manual Check', 'Texture', 'Ortho move', 'Para move', 'Size check', 'Frame no', 'Valid Frames', 'Chunk gap', 'Proximity conf', 'Flip prox conf', 'Was flipped';};
fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s \n', headerlabels{1,:});
for i=1:size(allChunkConfidenceLabels,1)
    fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', allChunkConfidenceLabels{i,:});
end
fclose(fid);

%%%%
    function drawImages(firstChunkWorm, lastChunkWorm, myAviInfo)
        draw.ahImg = [1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1];
        [draw.ahPattern(:,1) draw.ahPattern(:,2)] = find(draw.ahImg == 1);
        draw.ahPattern(:,1) = draw.ahPattern(:,1) - ceil(size(draw.ahImg, 1) / 2);
        draw.ahPattern(:,2) = draw.ahPattern(:,2) - ceil(size(draw.ahImg, 2) / 2);
        
        % Construct a pattern to identify the vulva.
        draw.avImg = [1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1; ...
            1 1 1 1 1];
        [draw.avPattern(:,1) draw.avPattern(:,2)] = find(draw.avImg == 1);
        draw.avPattern(:,1) = draw.avPattern(:,1) - ceil(size(draw.avImg, 1) / 2);
        draw.avPattern(:,2) = draw.avPattern(:,2) - ceil(size(draw.avImg, 2) / 2);
        
        % Choose the color scheme.
        draw.blue = zeros(360, 3);
        draw.blue(:,3) = 255;
        draw.red = zeros(360, 3);
        draw.red(:,1) = 255;
        draw.acRGB = [draw.blue(1:90,:); jet(181) * 255; draw.red(1:90,:)]; % thermal
        draw.asRGB = draw.acRGB;
        %asRGB = [blue(1:90,:); jet(181) * 255; red(1:90,:)]; % thermal
        draw.asRGBNaN = [255 0 0]; % red
        draw.ahRGB = [0 255 0]; % green
        draw.isAHOpaque = 1;
        draw.avRGB = [255 0 0]; % red
        draw.isAVOpaque = 1;
        
        
        img = zeros(myAviInfo.height, myAviInfo.width);
        sImg2 = overlayWormAngles(img, firstChunkWorm, draw.acRGB,draw.asRGB, draw.asRGBNaN, draw.ahPattern, draw.ahRGB, draw.isAHOpaque, draw.avPattern, draw.avRGB, draw.isAVOpaque);
        sImg1 = overlayWormAngles(img, lastChunkWorm, draw.acRGB,draw.asRGB, draw.asRGBNaN, draw.ahPattern, draw.ahRGB, draw.isAHOpaque, draw.avPattern, draw.avRGB, draw.isAVOpaque);
        figure;
        subplot(1,2,1), imshow(sImg1);
        subplot(1,2,2), imshow(sImg2);
    end
end