function [block] = correctWormBlockData(mainFlag, block, startIndex, endIndex)

%correctWormBlockData will run thgourh a block and correct the head and
%tail data
%
% [block] = correctWormBlockData(mainFlag, block, startIndex, endIndex)
%
%   Inputs:
%       mainFlag - flag to decide which action will be taken - flip flags
%       with 1 adjusted or flip flags with 0
%       block - block is a cell array that contains all of the worm data
%       startIndex - start index is set to know where to start editing the
%       block data
%       endIndex - end index is set to know where to end editing the block
%       data
%       
%
%   Outputs:
%       block - corrected worm data inside a block
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% we loop from start index to end index over a specified block
for i=startIndex:endIndex

    % we check is the block element (worm at this frame) is empty, if not
    % we work on the data
    try
        tmp = block{i};
    catch ME1
        1;
    end
    if iscell(block{i})
        worm = block{i};
        % flag here is a switch between two major actions of the function
        % if the mainFlag is 1 then we are turning all of the flipFlags
        % that are equal to 1 to 0
        if mainFlag
            %if flip flag is raised it means that what is considered
            %head is actually tail. Make the head have tail value and be
            %real head.
            if isWormCellHeadFlipped(worm)
                % flip all the data
                worm = flipWormCellData(worm);
                worm = flipWormCellVulva(worm);
                %ok, this is a tricky bit. Its due to the confusions of the
                %flip functions. Our data now is in bad orientation and has
                %flipFlag=1, and confidences for head and tail. Function
                %flipWormCellData will flip the orientation of the
                %coordinates and will make flipFlag=0, however it will not
                %flip the confidences. We cant call flipWormHead here which
                %would flip the confidences because because it will set the
                %flipFlag=1 again, so we call a function that Tadas wrote
                %to correct the confidences without fliping the flipFlag.
                
                % We could call flip worm head here and get the same
                % result, however the flipFlag woud become 1 again. It is
                % set to 0 here by flipWormCellData. So if we call
                % flipWormHead we get the confidences to align well, but
                % flipFlag bad again. Therefore we will call this funcion.
                worm = flipWormCellConfidenceData(worm);
                % record in open block
                block{i}=worm;
            end
        else
            %this part of the mainFlag switch is in case we want to turn
            %all of the flipFlags that are 0 to one
            if ~isWormCellHeadFlipped(worm)
                % flip all the data
                worm = flipWormCellData(worm);
                worm = flipWormCellVulva(worm);
            end
            %since all of the filpFlags are now 1 and all of the heads are
            %heads and tails are tails we need to call this data normal and
            %set all the flip flags to 0
            worm = flipWormCellHead(worm);
            worm = flipWormCellVulva(worm);
            %save the result
            block{i}=worm;
        end
    else
        %leave as is
    end
end