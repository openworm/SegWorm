function pathMomentsArray = pathMoments(centroids, maxOrderOfMoments)
% PATHMOMENTS This function computes path moments for the path of the worm.
% It analyses worm path using centroid coordinates to generate central
% moments of the path coordinates. Note that the 3rd moment can be
% normalized by the standard deviation to get a scale-invariant "skewness"
% given by moment3/moment2.^(3/2)
%
% Input:
%   centroids - centroid x and y coordinates
%   maxOrderOfMoments - number of moments
% Ouput:
%   pathMomentsArray - path moments
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Regarding path moments. I think we should use standard deviation rather
% than variance, just so it's easy to check the value by eye. It just means
% adding a sqrt() to the 2nd moment so should take about 1 second.


momentsArray = NaN(1,maxOrderOfMoments-1); %first central moment is always zero so don't calculate

stageX = centroids(:,1);
stageY = centroids(:,2);

%calculate centroid
centroidX = nanmean(centroids(:,1));
centroidY = nanmean(centroids(:,2));

distance = sqrt((stageX - centroidX).^2 + (stageY - centroidY).^2);
for j = 2:maxOrderOfMoments
    % Taking sqrt rather than variance 
    % Std is a normalized moment 
     momentsArray(j-1) = nanstd(distance);
     % skewness of the distance
end
momentsArray(3)/momentsArray(2).^(3/2)


pathMomentsArray = momentsArray;

%----

% fid = fopen(inputFilename);
% logFile = textscan(fid, '%s', 'delimiter', ',');
% fclose(fid);
% 
% if (length(logFile{1})-1)/8-1 > 1 %ignore empty log files
%     stageX = NaN((length(logFile{1})-1)/8-1,1);
%     stageY = NaN((length(logFile{1})-1)/8-1,1);
%     
%     k = 1; %index for counting through stage vectors
%     for j = 11:8:length(logFile{1})
%         stageX(k) = str2double(logFile{1}{j+2});
%         stageY(k) = str2double(logFile{1}{j+3});
%         k = k + 1;
%     end
%     
%     %sometimes first line of log file has a data entry _before_ the header
%     %which will lead to a NaN for the first entry of stageX and Y.  If
%     %present, remove first entry
%     if isnan(stageX(1)) && isnan(stageY(1)) %if only one entry isnan then this is due to a different problem
%         stageX(1) = [];
%         stageY(1) = [];
%     end
%     
%     %calculate centroid
%     centroidX = mean(stageX);
%     centroidY = mean(stageY);
%     
%     for j = 2:maxOrderOfMoments
%         distance = sqrt((stageX - centroidX).^2 + (stageY - centroidY).^2);
%         momentsArray(j-1) = mean(distance.^j);
%     end
% end
% pathMomentsArray = momentsArray;
% %save(outputFilename, 'momentsArray');
