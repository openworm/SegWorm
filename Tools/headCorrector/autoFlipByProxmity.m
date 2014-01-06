function autoFlipByProxmity(handles, referenceFrame)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
mydata=guidata(handles.openButton);

%make one long array of frame statuses, from the first field of the normBlocks
numFrames = get(mydata.aviHandle, 'numFrames');
frameStatus=zeros(numFrames, 1);

for b=1:mydata.numBlocks-1
    blockStart = 1 + mydata.blockLength*(b-1);
    blockEnd = mydata.blockLength*b;
    eval(['frameStatus(blockStart:blockEnd) = mydata.normBlock' num2str(b) '{1};' ]);
end

blockStart = blockStart + mydata.blockLength;
blockEnd = clockmod(numFrames, mydata.blockLength);
eval(['frameStatus(blockStart:blockEnd) = mydata.normBlock' num2str(b+1) '{1};' ]);


%now, use this to find the first segmented frame of each chunk
for c=1:length(mydata.chunktimes)
    
    for f=mydata.chunktimes{c}:mydata.chunktimes{c+1}
        
        if strcmp(frameStatus(f), 's')
            firstSegmentedFrame(c) = f;
            break;
        end
    end
    
end


%and the last . . .
for c=1:length(mydata.chunktimes)
    
    for f=mydata.chunktimes{c+1}:-1:mydata.chunktimes{c}
        
        if strcmp(frameStatus(f), 's')
            lastSegmentedFrame(c) = f;
            break;
        end
    end
    
end



%step over each chunk boundary, comparing chunk c with the one after it
for c=1:length(mydata.chunktimes)-1
    
    % ignore chunks that end before the referenceFrame. For the others
    % compare the last segmented frame of chunk c, and the first segmented frame of chunk (c+1)

    if mydata.chunktimes{c+1} >= referenceFrame
        
        
        
        oldFrame = lastSegmentedFrame(c)
        oldBlockNumber = ceil(oldFrame/mydata.blockLength);
        relativeFrame = num2str(clockmod(oldFrame, mydata.blockLength));
        
        %get the details for the old worm
        eval( ['vulvaContour = mydata.normBlock' num2str(oldBlockNumber) '{2}(:,:,' relativeFrame ');' ]);
        eval( ['nonVulvaContour = mydata.normBlock' num2str(oldBlockNumber) '{3}(:,:,' relativeFrame ');' ]);
        eval( ['skeleton = mydata.normBlock' num2str(oldBlockNumber) '{4}(:,:,' relativeFrame ');' ]);
        eval( ['skeletonAngles = mydata.normBlock' num2str(oldBlockNumber) '{5}(:,' relativeFrame ');' ]);
        eval( ['inOutTouch = mydata.normBlock' num2str(oldBlockNumber) '{6}(:,' relativeFrame ');' ]);
        eval( ['skeletonLength = mydata.normBlock' num2str(oldBlockNumber) '{7}(:,' relativeFrame ');' ]);
        eval( ['widths = mydata.normBlock' num2str(oldBlockNumber) '{8}(:,' relativeFrame ');' ]);
        eval( ['headArea = mydata.normBlock' num2str(oldBlockNumber) '{9}(:,' relativeFrame ');' ]);
        eval( ['tailArea = mydata.normBlock' num2str(oldBlockNumber) '{10}(:,' relativeFrame ');' ]);
        eval( ['vulvaArea = mydata.normBlock' num2str(oldBlockNumber) '{11}(:,' relativeFrame ');' ]);
        eval( ['nonVulvaArea = mydata.normBlock' num2str(oldBlockNumber) '{12}(:,' relativeFrame ');' ]);
        
        
        %construct the old worm
        oldWorm = norm2Worm(oldFrame, vulvaContour, nonVulvaContour, ...
            skeleton, skeletonAngles, inOutTouch, skeletonLength, widths, ...
            headArea, tailArea, vulvaArea, nonVulvaArea, ...
            mydata.origin(oldFrame, :), mydata.pixel2MicronScale, mydata.rotation, [])
        
        
        %get the details for the old worm
        newFrame = firstSegmentedFrame(c+1);
        newBlockNumber = floor(newFrame/mydata.blockLength)+1;
        relativeFrame = num2str(clockmod(newFrame, mydata.blockLength));
        
        eval( ['vulvaContour = mydata.normBlock' num2str(newBlockNumber) '{2}(:,:,' relativeFrame ');' ]);
        eval( ['nonVulvaContour = mydata.normBlock' num2str(newBlockNumber) '{3}(:,:,' relativeFrame ');' ]);
        eval( ['skeleton = mydata.normBlock' num2str(newBlockNumber) '{4}(:,:,' relativeFrame ');' ]);
        eval( ['skeletonAngles = mydata.normBlock' num2str(newBlockNumber) '{5}(:,' relativeFrame ');' ]);
        eval( ['inOutTouch = mydata.normBlock' num2str(newBlockNumber) '{6}(:,' relativeFrame ');' ]);
        eval( ['skeletonLength = mydata.normBlock' num2str(newBlockNumber) '{7}(:,' relativeFrame ');' ]);
        eval( ['widths = mydata.normBlock' num2str(newBlockNumber) '{8}(:,' relativeFrame ');' ]);
        eval( ['headArea = mydata.normBlock' num2str(newBlockNumber) '{9}(:,' relativeFrame ');' ]);
        eval( ['tailArea = mydata.normBlock' num2str(newBlockNumber) '{10}(:,' relativeFrame ');' ]);
        eval( ['vulvaArea = mydata.normBlock' num2str(newBlockNumber) '{11}(:,' relativeFrame ');' ]);
        eval( ['nonVulvaArea = mydata.normBlock' num2str(newBlockNumber) '{12}(:,' relativeFrame ');' ]);
        
        
        %construct the next worm
        newWorm = norm2Worm(newFrame, vulvaContour, nonVulvaContour, ...
            skeleton, skeletonAngles, inOutTouch, skeletonLength, widths, ...
            headArea, tailArea, vulvaArea, nonVulvaArea, ...
            mydata.origin(newFrame), mydata.pixel2MicronScale, mydata.rotation, [])
        
        %check if the worm has been flipped
        [worm2 confidence flippedConfidence] = orientWormAtCentroid(oldWorm, newWorm, 1);
        
        %if it has, flip the frame
        if worm2.orientation.head.isFlipped ~= newWorm.orientation.head.isFlipped
            flipHead(handles, c+1);
        end
        
        
        
    end
    
    
end