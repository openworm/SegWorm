function [omegaFrames, upsilonFrames] = omegaUpsilonDetectDV(hObject, eventdata, handles, fileInfo, x, y, lenArray, frameClass)
% OMEGAUPSILONDETECTDV This function determines which frames of the input
% skelData file contain part of an omega turn, as defined in Huang et al.
% (2006) Journal of Neuroscience Methods 158:323?336.
% It also adds detection of "upsilon" bends which are similar to omega 
% bends but have a shallower bend (angle between 45 and 100 degrees 
% instead of less than 45 degrees).
%
% Input:
%   hObject, eventdata, handles - GUI info
%   fileInfo - experiment information
%   x - x coordinates of the skeleton
%   y - y coordinates of the skeleton
%   lenArray - array of worm length
%   dataSize - vector indicating which section of the block should be saved
%   frameClass - array of flags showing frame status (segmented, dropped,
%   stage motion, segmentaiton error)
%
% Output:
% -
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
dataDims = size(lenArray);

%initialize data arrays for export
omegaFrames = zeros(dataDims);
upsilonFrames = zeros(dataDims);

%initialize data arrays for internal use
distHMArray = NaN(dataDims);
distTMArray = NaN(dataDims);
angleArray = NaN(dataDims);
arcLengthArray = NaN(dataDims);

datLen = length(lenArray);

for frame = 1:datLen
    %only calculate for "good" frames
    if frameClass(frame) == 's'
            fullSkel = [x(frame, :); y(frame, :)]';
            %Compute arclength of skeleton
            arcLengthArray(frame) = lenArray(frame);
            
            %find head, tail, and middle coordinates
            head = fullSkel(1,:);
            tail = fullSkel(end,:);
            middle = fullSkel(round(length(fullSkel)/2),:);
            
            %calculate head-middle and tail-middle distances
            distHMArray(frame) = sqrt((head(1)-middle(1)).^2 + (head(2)-middle(2)).^2);
            distTMArray(frame) = sqrt((tail(1)-middle(1)).^2 + (tail(2)-middle(2)).^2);
            
            %define head-middle and tail-middle vectors
            HMVec = (head - middle);
            TMVec = (tail - middle);
            
            %calculate angles.  atan2 uses angles from -pi to pi instead of atan which
            %uses the range -pi/2 to pi/2.
            angleDiff = atan2(HMVec(2),HMVec(1)) - atan2(TMVec(2),TMVec(1));
            
            %we always take the smallest angle so transform angle
            %differences greater than pi to their smaller negative
            %equivalent and values less than -pi to their smaller positive
            %equivalent
            if angleDiff > pi
                angleDiff = angleDiff - 2*pi;
            end
            if angleDiff < -pi
                angleDiff = angleDiff + 2*pi;
            end
            
%             %flip angle sign if worm is on right side.  With this
%             %convention, a dorsal bend is negative and ventral is positive
%             if dataBlock{frame}.orientation.vulva.isClockwiseFromHead
%                 angleDiff = -angleDiff;
%             end

            angleArray(frame) = angleDiff;
%             plot(x(frame,:), y(frame,:));axis equal
%             text(head(1),head(2),'x', 'color', 'r')
%             line([tail(1), middle(1)],[tail(2), middle(2)], 'Color', 'r')
%             line([head(1), middle(1)],[head(2), middle(2)], 'Color', 'g')
    end
end

%interpolate arrays over NaN values (where there were stage
%movements, touching, or some other segmentation problem)
%***This is of course only an approximate solution to the problem of
%not segmenting coiled shapes***
if sum(~isnan(angleArray)) > 1
    angleArray(isnan(angleArray)) = interp1(find(~isnan(angleArray)),...
        angleArray(~isnan(angleArray)), find(isnan(angleArray)),'linear');
    distHMArray(isnan(distHMArray)) = interp1(find(~isnan(distHMArray)),...
        distHMArray(~isnan(distHMArray)), find(isnan(distHMArray)),'linear');
    distTMArray(isnan(distTMArray)) = interp1(find(~isnan(distTMArray)),...
        distTMArray(~isnan(distTMArray)), find(isnan(distTMArray)),'linear');
end
%********************** Find Omegas ***********************************

%find frames that satisfy conditions for omega bend start
startCond = distHMArray < (distTMArray - 0.05*arcLengthArray)...
    & abs(angleArray) < 45*pi/180;
startInds = find(diff(startCond)==1) + 1; %add one to compensate for shift due to diff

%find frames that satisfy conditions for middle of omega bend
midCond = abs(angleArray) < 45*pi/180;

%find frames that satisfy conditions for omega bend end
endCond = distTMArray < (distHMArray - 0.05*arcLengthArray);
endInds = find(diff(endCond)==1) + 1; %add one to compensate for shift due to diff

for j = 1:length(startInds)
    %find the next end index that is greater than the current startInd
    possibleEnd = find(endInds > startInds(j), 1);
    %check that frames between start and possible end are valid
    %middle omega frames
    if sum(midCond(startInds(j):endInds(possibleEnd)))...
            == endInds(possibleEnd) - startInds(j) + 1
        %if it is an omega bend, multiply by the sign of the bend angle
        %to determine if it's ventral (positive) or dorsal (negative)
        omegaFrames(startInds(j):endInds(possibleEnd)) = ...
            ones(endInds(possibleEnd) - startInds(j) + 1,1)...
            *sign(mean(angleArray(startInds(j):endInds(possibleEnd))));
    end
end

%********************** Find Upsilons ********************************

%find frames that satisfy conditions for upsilon bend start
startCond = distHMArray < (distTMArray - 0.03*arcLengthArray)...
    & abs(angleArray) < 100*pi/180 & abs(angleArray) > 45*pi/180;
startInds = find(diff(startCond)==1) + 1; %add one to compensate for shift due to diff

%find frames that satisfy conditions for middle of upsilon bend
midCond = abs(angleArray) < 100*pi/180 & abs(angleArray) > 45*pi/180;

%find frames that satisfy conditions for upsilon bend end
endCond = distTMArray < (distHMArray - 0.03*arcLengthArray);
endInds = find(diff(endCond)==1) + 1; %add one to compensate for shift due to diff

for j = 1:length(startInds)
    %find the next end index that is greater than the current startInd
    possibleEnd = find(endInds > startInds(j), 1);
    %check that frames between start and possible end are valid
    %middle upsilon frames
    if sum(midCond(startInds(j):endInds(possibleEnd)))...
            == endInds(possibleEnd) - startInds(j) + 1
        %if it is an upsilon bend, multiply by the sign of the bend angle
        %to determine if it's ventral (positive) or dorsal (negative)
        upsilonFrames(startInds(j):endInds(possibleEnd)) = ...
            ones(endInds(possibleEnd) - startInds(j) + 1,1)...
            *sign(mean(angleArray(startInds(j):endInds(possibleEnd))));
    end
end
