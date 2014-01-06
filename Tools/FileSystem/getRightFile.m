%this function will select a right file from the dir contents array
%
% Input: 
% dirContents - list of files in the directory
% nameStr - the file class that we are looking for
% 
% Output:
% rightFileName - 
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function [rightFileName] = getRightFile(dirContents, nameStr)
rightFileName = [];

if strfind(nameStr,'segInfo.mat')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, nameStr)));
    % there can be the case where an old analysis file expName_segInfo.mat
    % can be present in the directory. It should be removed, nonetheless
    % here it should not be selected as legitimate segInfo.mat file.
    if length(fileList)>1
        % getting rid of a file with a substring _segInfo
        fileList = fileList(cellfun(@isempty, strfind(fileList, '_segInfo')));
    end
    if ~isempty(fileList)
        rightFileName = [fileList{~cellfun(@isempty, strfind(fileList, '.data'))}];
    else
        rightFileName = [];
    end
elseif strfind(nameStr,'info.xml')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, nameStr)));
    if ~isempty(fileList)
        fileList2 = fileList(cellfun(@isempty, strfind(fileList, 'vignette.dat')));
        if ~isempty(fileList2)
            rightFileName = fileList2{1};
        else
            rightFileName = [];
        end
    else
        rightFileName = [];
    end    
elseif strfind(nameStr,'vignette.dat')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, 'info.xml.vignette.dat')));
     if ~isempty(fileList)
        rightFileName = fileList{1};
    else
        rightFileName = [];
    end
elseif strfind(nameStr,'log.csv')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, 'log.csv')));
     if ~isempty(fileList)
        rightFileName = fileList{1};
    else
        rightFileName = [];
    end
elseif strfind(nameStr,'diff.mat')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, nameStr)));    
    if ~isempty(fileList)
        rightFileName = [fileList{~cellfun(@isempty, strfind(fileList, '.data'))}];
    else
        rightFileName = [];
    end
elseif strfind(nameStr,'stageMotion.mat')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, nameStr)));    
    if ~isempty(fileList)
        rightFileName = [fileList{~cellfun(@isempty, strfind(fileList, '.data'))}];
    else
        rightFileName = [];
    end
elseif strfind(nameStr,'status.mat')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, 'status.mat')));
    if ~isempty(fileList)
        rightFileName = fileList{1};
    else
        rightFileName = [];
    end
elseif strfind(nameStr,'.avi')
    if strcmp(nameStr, '_seg.avi')
        fileList = dirContents(~cellfun(@isempty, strfind(dirContents, '_seg.avi')));
        if ~isempty(fileList)
            rightFileName = fileList{1};
        else
            rightFileName = [];
        end
    else
        % Here lets remove _seg.avi from the list
        dirContents2 = dirContents(cellfun(@isempty, strfind(dirContents, '_seg.avi')));
        fileList = dirContents(~cellfun(@isempty, strfind(dirContents2, '.avi')));
        if ~isempty(fileList)
            rightFileName = fileList{1};
        else
            rightFileName = [];
        end
    end
elseif strfind(nameStr,'failedFrames.mat')
    fileList = dirContents(~cellfun(@isempty, strfind(dirContents, 'failedFrames.mat')));
    if ~isempty(fileList)
        rightFileName = fileList{1};
    else
        rightFileName = [];
    end
end
