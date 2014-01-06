function outputVideoFile = exportVideo(datFileName, expInfo, vImg, fps, handles, wormSideFlag, modeFlag)
% EXPORTVIDEO This function will export overlay video files for a
% given experiment
%
% Input:
%   datNameInfo - path to the segmentation info file
%   expInfo - experiment information cell array
%   vImg - vignette image
%   fps - frames per second
%   hangles - GUI handles
%   wormSideFlag - flag indicating vulva side of the worm
%   modeFlag - flag indicating _CW_, _CCW_ or L, R nomenclature (1, and 0 respectively)
%
% Output:
%   outputVideoFile - output video file
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%--------------------------------------------------------------------------
% define draw data
%--------------------------------------------------------------------------
% Construct a pattern to identify the head.
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

% Construct the video file.
draw.anglesVideoFile = strrep(expInfo.avi, '.avi', '_seg.avi');
%avw = videoWriter(draw.anglesVideoFile, 'fps', fps, 'plugin', 'DirectShow');
try
    %avw = videoWriter(draw.anglesVideoFile, 'fps', fps, 'plugin', 'DirectShow', 'codec','xvid');
    %avw = videoWriter(draw.anglesVideoFile, 'fps', fps, 'plugin', 'DirectShow', 'fourcc', 'xvid');
    avw = videoWriter(draw.anglesVideoFile, 'fps', fps, 'plugin', 'DirectShow', 'codec','ffds');
catch ME1
    try
        msgString = getReport(ME1, 'extended','hyperlinks','off');
        warning('exportVideo:codecError',msgString);
        avw = videoWriter(draw.anglesVideoFile, 'fps', fps, 'plugin', 'DirectShow', 'codec','xvid');
    catch ME1
        msgString = getReport(ME1, 'extended','hyperlinks','off');
        warning('exportVideo:codecError',msgString);
        avw = videoWriter(draw.anglesVideoFile, 'fps', fps, 'plugin', 'DirectShow', 'fourcc','xvid');
    end
end
% Set up clean-up procedure
obj1 = onCleanup(@()cleanupFun(avw));

%avw = videoWriter(draw.anglesVideoFile, 'fps', fps, 'plugin', 'DirectShow', 'codec','wmv3');
vrBackground = videoReader(expInfo.avi, 'plugin', 'DirectShow');
% Set up clean-up procedure
obj2 = onCleanup(@()cleanupFun(vrBackground));

%--------------------------------------------------------------------------

isGray = false;
isVideoFrame = next(vrBackground);
if isVideoFrame
    img = getframe(vrBackground);
    if max(max(abs(img(:,:,1) - img(:,:,2)))) == 0
        isGray = true;
    end
end

globalFrameCounter = 0;
   
if isGray
    img = getframe(vrBackground);
    img = img(:,:,1);
else
    img = rgb2gray(getframe(vrBackground));
end

% Correct the vignette.
if ~isempty(vImg)
    img = uint8(single(img) - single(vImg));
end

load(datFileName,'blockList');

%---------------- check status for vulva side flip
vulvaFlipFlag = 0;
if wormSideFlag == 1
	vulvaFlipFlag = 1;
end

for i=1:length(blockList) %#ok<USENS>
    %load block and label it currentBlock
    blockNameStr = blockList{i};
    datFileNameBlock = strrep(datFileName, 'segInfo', blockNameStr);
    load(datFileNameBlock, blockNameStr);
    eval(['currentBlock=', blockNameStr,';']);
    execString = strcat('clear(''',blockNameStr,''');');
    eval(execString);
    
    for j=1:length(currentBlock) %#ok<USENS>
        globalFrameCounter = globalFrameCounter + 1;

        str1 = strcat('Exporting frame number:',{' '},sprintf('%d',globalFrameCounter),{' '},'.');
        set(handles.status1,'String',str1{1});
        drawnow;

        %disp(strcat('Exporting frame number:',{' '},sprintf('%d', globalFrameCounter),{' '},'.'))
        
        if iscell(currentBlock{j})
            wormStruct = cell2worm(currentBlock{j});
            if vulvaFlipFlag
                wormData = flipWormVulva(wormStruct);           
            else
                wormData = wormStruct;
            end
            
            sImg = overlayWormAngles(img, wormData, draw.acRGB, ...
                draw.asRGB, draw.asRGBNaN, draw.ahPattern, draw.ahRGB, draw.isAHOpaque, ...
                draw.avPattern, draw.avRGB, draw.isAVOpaque);
        else
            %if the frame was empty we label this image with
            if currentBlock{j}==1
                sImg = overlayBadWorm(img, 'f');
            elseif currentBlock{j}==2
                sImg = overlayBadWorm(img, 'm');
            else
                sImg = overlayBadWorm(img, 'd');
            end
        end
        
        % write to output video
        addframe(avw, sImg);
        if ~isempty(currentBlock{j})
            next(vrBackground);
            % we acquire the current frame for the output video only if
            % there is a new frame
            if isGray
                img = getframe(vrBackground);
                img = img(:,:,1);
            else
                img = rgb2gray(getframe(vrBackground));
            end
            % Correct the vignette.
            if ~isempty(vImg)
                img = uint8(single(img) - single(vImg));
            end
        end
    end
    clear('currentBlock');
end
% close the video 
close(avw);
close(vrBackground);

outputVideoFile = draw.anglesVideoFile;

function cleanupFun(videoHandle)
% This function will make sure video resources are released in case the
% function ends prematurely
try
    % Lets check if the variable is a valid handle if not - do nothing
    close(videoHandle);
catch ME1
end

