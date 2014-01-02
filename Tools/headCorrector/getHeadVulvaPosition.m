function getHeadVulvaPosition ( handles )
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%load the normalized data
mydata=guidata(handles.openButton);


%first, display a status message in the main GUI
set(handles.statusText, 'String', 'Attempting to get positions for the head and vulva');
refresh(headcorrector)



if mydata.useDB == 0
    
    %if the user has identified the necessary files, get the head/vulva
    %position
    
    if (mydata.headTailReady == 1)
        
        %get rotation and pixel2MicronScale from the segNormInfo file
        load(mydata.segNormInfoPath);
        mydata.rotation = rotation;
        mydata.pixel2MicronScale = pixel2MicronScale;
        
        load(mydata.stageMotionPath, 'movesI', 'locations');
        
        
        origins(:, 1) = movesI(1:length(locations),1);    %frame movement starts on
        origins(:, 2) = movesI(1:length(locations),2);    %frame movement ends on
        origins(:, 3) = locations(:, 1); %x-position after move
        origins(:, 4) = locations(:, 2); %y-position after move
        
        
        %load each of the block files; save the blocks in mydata
        for c=1:mydata.numBlocks
            %load([dataPath filesep name '_normBlock' num2str(c) '.mat']);
            bName = [mydata.dataPath 'normBlock' num2str(c) '.mat'];
            if exist(bName, 'file') ~= 2
                bName = strrep(bName, 'segNormInfo', '');
            end
            load(bName);
            eval(['mydata.normBlock' num2str(c) '=normBlock' num2str(c)] );
        end
        
        %save the blockLength
        mydata.blockLength = length(normBlock1{1});
        
        
        %the vulvaContour is blockN{2}
        %the head is blockN{2}(1, :, framenumber)
        %the vulva is blockN{2}(25, :, framenumber)
        
        %extract the head and vulval positions for each block
        numFrames = get(mydata.aviHandle, 'numFrames') + get(mydata.aviHandle, 'nHiddenFinalFrames');
        
        % Get the length of the video from normWorms
        numFrames = 0;
        for N=1:mydata.numBlocks
            numFrames = numFrames + eval(['length(mydata.normBlock' num2str(N) '{1})']);
        end
            
        
        vulvaPos = zeros(numFrames, 2);
        headPos = zeros(numFrames, 2);
        previous = 1;
        next = length(eval(['mydata.normBlock1{2}(1, :, :)']));
        
        for N=1:mydata.numBlocks
            
            headPos(previous:next,:) =  permute(eval(['mydata.normBlock' num2str(N) '{2}(1, :, :)']), [3 2 1]);
            vulvaPos (previous:next,:) =  permute(eval(['mydata.normBlock' num2str(N) '{2}(25, :, :)']), [3 2 1]);
            %headPos = cat(1, headPos, eval(['mydata.normBlock' num2str(N) '{2}(1, :, :)']));
            %vulvaPos = cat(1, vulvaPos, eval(['mydata.normBlock' num2str(N) '{2}(25, :, :)']));
            previous = next;
            
            if N < mydata.numBlocks
                next = previous + length(eval(['mydata.normBlock' num2str(N+1) '{2}(1, :, :)']))-1;
            end
        end
        
        
        
        
    else

        experiment_id = mydata.experiment_id;
        
        %get the pixel2MicronScale and rotation
        query = ['SELECT * FROM calibration WHERE id=' num2str(experiment_id)];
        curs = exec(mydata.conn, query);
        setdbprefs('DataReturnFormat','cellarray');
        curs = fetch(curs);
        
        if ~strcmp(curs.data(1), 'No Data')
            rotation = [curs.data{1,4}, curs.data{1,5}; curs.data{1,6}, curs.data{1,7}];
            pixel2MicronScale = [curs.data{1,2}, curs.data{1,3}];
            mydata.rotation = rotation;
            mydata.pixel2MicronScale = pixel2MicronScale;
            
            
            %get the origins
            query = ['SELECT start_stage_movement_frame, end_stage_movement_frame, stage_position_x, stage_position_y FROM main.stagemotion WHERE id = ''' num2str(experiment_id) ''''];
            curs = exec(mydata.conn, query);
            setdbprefs('DataReturnFormat','numeric');
            curs = fetch(curs);
            
            if ~strcmp(curs.data(1), 'No Data')
                
                origins = curs.data;
                
                %get the points half-way along the vulval side
                query = ['SELECT x25, y25 FROM main.vulvacontours WHERE id = ''' num2str(experiment_id) ''''];
                curs = exec(mydata.conn, query);
                setdbprefs('DataReturnFormat','numeric');
                curs = fetch(curs);
                
                if ~strcmp(curs.data(1), 'No Data')
                    
                    vulvaPos = curs.data;
                    
                    %get the points at the head
                    query = ['SELECT x1, y1 FROM main.vulvacontours WHERE id = ''' num2str(experiment_id) ''''];
                    curs = exec(mydata.conn, query);
                    setdbprefs('DataReturnFormat','numeric');
                    curs = fetch(curs);
                    headPos = curs.data;
                end
            end
        end
    end
    
    
    
    if exist('vulvaPos', 'var')
        %for speed, initialize the arrays of converted positions
        vulvaPositions = zeros(length(vulvaPos(:, 1)), 2);
        headPositions = zeros(length(vulvaPos(:, 1)), 2);
        mydata.origin = zeros(length(vulvaPos(:, 1)), 2);
        
        
        %loop through the origins, converting the corresponding points
        originNumber=1;
        origin = [origins(originNumber, 3) origins(originNumber, 4)];
        
        for o=1:length(origins)-1
            
            %between moves, convert using the origin set by the previous move
            vulvaPositions(origins(o, 2)+1:origins(o+1, 1)-1, :) = round(microns2Pixels([origins(o, 3) origins(o, 4)], vulvaPos(origins(o, 2)+1:origins(o+1, 1)-1, :),...
                pixel2MicronScale, rotation));
            
            headPositions(origins(o, 2)+1:origins(o+1, 1)-1, :) = round(microns2Pixels([origins(o, 3) origins(o, 4)], headPos(origins(o, 2)+1:origins(o+1, 1)-1, :),...
                pixel2MicronScale, rotation));  %from the end of this move to the start of the next we use its origin
            
            %save the origins, so they can be used to reconstruct worms in autoFlipByProximity
            mydata.origin(origins(o, 2)+1:origins(o+1, 1)-1, 1) = origins(o, 3);
            mydata.origin(origins(o, 2)+1:origins(o+1, 1)-1, 2) = origins(o, 4);
            
            %if we're moving, the origin is undefined
            if origins(o, 1) > 0
                vulvaPositions(origins(o, 1):origins(o, 2), 1) = NaN;
                headPositions(origins(o, 1):origins(o, 2), 2) = NaN;
            end
            
        end
        
        %save the converted positions to mydata.vulvaPosition and mydata.headPosition
        %%mydata=guidata(handles.openButton);
        mydata.vulvaPosition = vulvaPositions;
        mydata.headPosition = headPositions;
        guidata(handles.openButton, mydata);
    end
    
    
    %if desired, get the whole worm
    %this code is here, as we need the full array of saved origins.
    if (mydata.plotWholeWorm == 1) && (mydata.useDB == 0) && (mydata.headTailReady == 1)
        
        %for block=1:mydata.numBlocks
        for block=mydata.numBlocks:-1:1
            %for relativeFrame=1:eval(['length(mydata.normBlock' num2str(block) '{1})'])
            for relativeFrame=eval(['length(mydata.normBlock' num2str(block) '{1})']):-1:1
                                
                %get the details for the old worm
                eval( ['vulvaContour = mydata.normBlock' num2str(block) '{2}(:,:,' num2str(relativeFrame) ');' ]);
                eval( ['nonVulvaContour = mydata.normBlock' num2str(block) '{3}(:,:,' num2str(relativeFrame) ');' ]);
                eval( ['skeleton = mydata.normBlock' num2str(block) '{4}(:,:,' num2str(relativeFrame) ');' ]);
                eval( ['skeletonAngles = mydata.normBlock' num2str(block) '{5}(:,' num2str(relativeFrame) ');' ]);
                eval( ['inOutTouch = mydata.normBlock' num2str(block) '{6}(:,' num2str(relativeFrame) ');' ]);
                eval( ['skeletonLength = mydata.normBlock' num2str(block) '{7}(:,' num2str(relativeFrame) ');' ]);
                eval( ['widths = mydata.normBlock' num2str(block) '{8}(:,' num2str(relativeFrame) ');' ]);
                eval( ['headArea = mydata.normBlock' num2str(block) '{9}(:,' num2str(relativeFrame) ');' ]);
                eval( ['tailArea = mydata.normBlock' num2str(block) '{10}(:,' num2str(relativeFrame) ');' ]);
                eval( ['vulvaArea = mydata.normBlock' num2str(block) '{11}(:,' num2str(relativeFrame) ');' ]);
                eval( ['nonVulvaArea = mydata.normBlock' num2str(block) '{12}(:,' num2str(relativeFrame) ');' ]);
                
                %construct the old worm, if the positions are not NaN
                if any(any(vulvaContour))
                    absoluteFrame = mydata.blockLength * (block-1) + relativeFrame;
                    mydata.worm(absoluteFrame) = norm2Worm(absoluteFrame, vulvaContour, nonVulvaContour, ...
                        skeleton, skeletonAngles, inOutTouch, skeletonLength, widths, ...
                        headArea, tailArea, vulvaArea, nonVulvaArea, ...
                        mydata.origin(absoluteFrame, :), mydata.pixel2MicronScale, mydata.rotation, []);
                    
                    segmented(absoluteFrame)=1;
                end
            end
        end
    end
    guidata(handles.openButton, mydata);
    
    
end


%clear the status message
set(handles.statusText, 'String', '');
