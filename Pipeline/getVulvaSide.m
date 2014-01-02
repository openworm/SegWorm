function wormSideFlag = getVulvaSide(fileInfo, conn, hObject, eventdata, handles)
% GETVULVASIDE This function will extract the vulvaside information and
% return the side.
%
% Input:
%   fileInfo - file information varialbe that store the locations of all
%   experiment related files
%   conn - database connection varialbe. Its a database class varialbe or
%   an empty varialbe if the database is not used
%   hObject, eventdata, handles - gui varialbes
%
% Output:
%   wormSideFlag - this flag will indicate which side was annotated as
%   ventral side.
%       1 - the side is Left
%       2 - the side is Right
%       3 - the side is Unknown
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

wormSideFlag = [];
if handles.preferences.useDB
    % Get experiment ID
    [experimentId, ~] = getExperimentId(conn, fileInfo.expList.fileName);
    % Connect to info table and retrieve the vulva side of the experiment
    %sqlString = strcat('SELECT vulvaside from info where id = ''', num2str(experimentId),{''';'});
    sqlString = strcat('select VS.ventralSideName from ventralSide VS join exp_annotation EA on VS.ventralSideID = EA.ventralSideID where EA.id = ''', num2str(experimentId),{''';'});
    
    curs = exec(conn, sqlString);
    curs = fetch(curs);
    vulvaSide = curs.Data;
    close(curs);
    
    if ~iscell(vulvaSide)
        errorMsg = strcat('MYSQL query failed!', sqlString);
        error('correctVulvaSide:DatabaseConnectionFailed', errorMsg);
    elseif strcmp(vulvaSide,'No Data')
        % No information about the vulva side
        wormSideFlag = 3;
    else
        if strcmpi(vulvaSide, 'clockwise')
            wormSideFlag = 1;
        elseif strcmpi(vulvaSide, 'anticlockwise')
            wormSideFlag = 2;
        else
            wormSideFlag = 3;
        end
    end
    
else
    % This case will be executed in the standalone version
    
    % Here we will check if we can find vulva side in the file name
    
    if fileInfo.vulvaSideAnnotation == 1
        % _CW_     L_
        wormSideFlag = 1;
   elseif fileInfo.vulvaSideAnnotation == 0
        % _CCW_     R_
        wormSideFlag = 2;
    else
        wormSideFlag = 3;
    end
    
    
%     try
%         wormInfo = parseWormFilename([fileInfo.expList.fileName,'.avi']);
%         if strcmpi(wormInfo.side, 'L')
%             wormSideFlag = 1;
%         elseif strcmpi(wormInfo.side, 'R')
%             wormSideFlag = 2;
%         else
%             wormSideFlag = 3;
%         end
%     catch ME1
%         % If the parsing of the file name failed lets look for an actual
%         % string that should indicate the side
%         wormSideFlag = 3;
%         findFlag1 = strfind(fileInfo.expList.fileName, ' L_20');
%         findFlag2 = strfind(fileInfo.expList.fileName, ' l_20');
%         if ~isempty(findFlag1) || ~isempty(findFlag2)
%             wormSideFlag = 1;
%         end
%   
%         findFlag1 = strfind(fileInfo.expList.fileName, ' R_20');
%         findFlag2 = strfind(fileInfo.expList.fileName, ' r_20');
%         if ~isempty(findFlag1) || ~isempty(findFlag2)
%             wormSideFlag = 2;
%         end
%     end
end