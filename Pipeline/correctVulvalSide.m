function [fileInfo, vulvasideCorrected] = correctVulvalSide(fileInfo, conn, hObject, eventdata, handles)
% CORRECTVULVALSIDE This function will log in to the database, get the
% vulva side orientation and will adjust the norm worms accordingly
% so that their vulva side is correct. It will also record in a table for
% which experiments the adjustment was made in the fileInfo variable and
% also in the database.
%
% L or R will now signify the side of the worm is crawling on the agar ( on
% left side or on right side).
%
% The way that Laura has labeled worms in the experiment file name and
% subsequently our database is R for clock-wise, L for counter-clockwise
% from the head of the worm.
% Since she views the worm from above using a microscope and the camera
% views the worm from below (and the image is not being flipped by the
% software) when she sees the vulva on the right side, the camera will see
% it on the left.
%
% The default Ev built in segmentation puts the vulva on the left.
%
% Therefore, to place the vulva correctly in the image, whenever Laura's
% has an L (left) tag, the vulval side must be flipped (as it will be on
% the right side in the video).
%
% This will mean 2 further things:
%
% 1. The skeleton bends are signed according to the vulval side. So a
% positive bend means the skeleton is bending away from the vulva or,
% alternatively, the vulval side is bent convexly.
%
% 2. The worm is crawling on the opposite side of the L/R tag Laura has placed.
%
%
% Input:
%   fileInfo - file information varialbe that store the locations of all
%   experiment related files
%   conn - database connection varialbe. Its a database class varialbe or
%   an empty varialbe if the database is not used
%   hObject, eventdata, handles - gui varialbes
%
% Output:
%   fileInfo - updated file information variable
%
% The function assumes that normalized worm is in the following format:
%       blockN{1}  = status:
%                    s = segmented
%                    f = segmentation failed
%                    m = stage movement
%                    d = dropped frame
%       blockN{2}  = vulvaContours
%       blockN{3}  = nonVulvaContours
%       blockN{4}  = skeletons
%       blockN{5}  = angles
%       blockN{6}  = inOutTouches
%       blockN{7}  = lengths
%       blockN{8}  = widths
%       blockN{9}  = headAreas
%       blockN{10} = tailAreas
%       blockN{11} = vulvaAreas
%       blockN{12} = nonVulvaAreas
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.


%1.a. Check the file info or b. check the database
%2. if action needs to be taken - load the normWormInfo
%3. loop through and update normWorms
%4. save them
%5.a. update file info or b. update database

% GUI update
str1 = strcat('Correcting vulva side for experiment: ',{' '},fileInfo.expList.fileName,{'.'});
set(handles.status1,'String',str1{1});

% Run the norm worms
normWormProcess(fileInfo, handles);

%--------------------------------------------------------------------------
datNameIn = strrep(fileInfo.expList.segDat,'segInfo',['normalized\', 'segNormInfo']);
normBlockList = [];
load(datNameIn, 'normBlockList');

% Flip the norm blocks
for i = 1:length(normBlockList)
    drawnow;
    blockNo = i;
    blockNameStr = strcat('normBlock', num2str(blockNo));
    datFileNameBlock = strrep(datNameIn, 'segNormInfo', blockNameStr);
    load(datFileNameBlock, blockNameStr);
    data = [];
    eval(strcat('data =', blockNameStr,';'));
    eval(strcat('clear(''',blockNameStr,''');'));
    % Retrieving the mean coordinates of the skeleton
    %             normBlock{1} = framesStatus;
    %             normBlock{2} = vulvaContours;
    %             normBlock{3} = nonVulvaContours;
    %             normBlock{4} = skeletons;
    %             normBlock{5} = angles;
    %             normBlock{6} = inOutTouches;
    %             normBlock{7} = lengths;
    %             normBlock{8} = widths;
    %             normBlock{9} = headAreas;
    %             normBlock{10} = tailAreas;
    %             normBlock{11} = vulvaAreas;
    %             normBlock{12} = nonVulvaAreas;
    
    vulvaContours = data{2};
    nonVulvaContours = data{3};
    angles = data{5};
    vulvaAreas = data{11};
    nonVulvaAreas = data{12};
    
    [vulvaContours2 nonVulvaContours2 angles2 vulvaAreas2 nonVulvaAreas2] = ...
        flipNormWormVulvas(vulvaContours, nonVulvaContours, angles, ...
        vulvaAreas, nonVulvaAreas);
    
    data{2} = vulvaContours2;
    data{3} = nonVulvaContours2;
    data{5} = angles2;
    data{11} = vulvaAreas2;
    data{12} = nonVulvaAreas2;
    clear('vulvaContours', 'nonVulvaContours', 'angles', 'vulvaAreas',...
        'nonVulvaAreas');
    clear('vulvaContours2', 'nonVulvaContours2', 'angles2', 'vulvaAreas2',...
        'nonVulvaAreas2');
    % Save
    eval(strcat(blockNameStr,'= data;'));
    eval(strcat('clear(''data'');'));
    execString = strcat('save('' ', datFileNameBlock, ''',''', blockNameStr, ''');');
    eval(execString);
end

fileInfo.normWorms.correctedVulvaSide = 1;
fileInfo.normWorms.datestamp = datestr(now,31);
% Set the flag to 1 - vulvaside was corrected
vulvasideCorrected = 1;


% Output results for checking

%         % Here we will output worm videos to check if our flip was correct
%         if handles.preferences.useDB || handles.preferences.nas
%             if strcmpi(handles.preferences.experimentCollectionListName, 'segmentationExperimentList')
%                 dirTempCopy = '\\nas207-2\Data\vulva-side-tests\';
%             elseif strcmpi(handles.preferences.experimentCollectionListName, 'victoriaExperimentList')
%                 dirTempCopy = '\\nas207-2\Data\victoria-run-13-01-2012\video-vulva-flip\';
%             end
%             expPath = makeNasDir(conn, experimentId);
%             dirTempCopy = fullfile(dirTempCopy, expPath);
%             % Check if nas dir exists
%             if ~isdir(dirTempCopy)
%                 mkdir(dirTempCopy);
%             end
%             % Produce shot overlay video of 25 frames
%             outputVideoFile = exportVideoFrames(datNameIn, fileInfo.expList, handles, 25);
%
%             [~, ~] = copyfile(outputVideoFile, dirTempCopy);
%             if exist(outputVideoFile, 'file') == 2
%                 delete(outputVideoFile);
%             end
%         end