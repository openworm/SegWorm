function [wormArea, wormLen, wormWidth, wormThickness, wormFatness] = ...
    morphology_process(hObject, eventdata, handles, fileInfo, dataBlock)
% MORPHOLOGY_PROCESS This function computes worm morphology values
%
% Input: 
%   hObject, eventdata, handles - GUI info
%   fileInfo - experiment location info file
%   dataBlock - data for which the feature will be extracted
% Output:
%   wormArea - array of area
%   wormLen - array of length
%   wormWidth - array of worm widths
%   wormThickness - array of worm thickness
%   wormFatness - array of worm fatness
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% The worm is roughly divided into 24 segments of musculature (i.e., hinges
% that represent degrees of freedom) on each side. Therefore, we have 48
% segments around a 2-D contour.
% Note: "In C. elegans the 95 rhomboid-shaped body wall muscle cells are
% arranged as staggered pairs in four longitudinal bundles located in four
% quadrants. Three of these bundles (DL, DR, VR) contain 24 cells each,
% whereas VL bundle contains 23 cells." - www.wormatlas.org
% Thus - we have normalized worm in 49 segments

% Given that we have 49 points, our mid point is at point 25. This might
% change in the future. For now its defined as a constant here.
NOOFPOINTS = 49;

% Initialize data containers
datLen = length(dataBlock{1});
wormLen = NaN(1,datLen);
wormArea = NaN(1,datLen);
wormWidth = NaN(1,datLen);
wormThickness = NaN(1,datLen);
wormFatness = NaN(1,datLen);

% Main loop
for j = 1 : datLen
    % Check if frame is segmented
    if dataBlock{1}(j) == 's'
        % Length
        wormLen(j) = dataBlock{7}(j);
        
        % Calculate area. This value is an approximation. I use area
        % returned from the segmentation that exculdes a line of pixels
        % dividing the head and body, the tail and body the ventral and
        % dorsal sides. The lines that are not part of this value looks
        % approximatelly like this: |------| 
        
        wormArea(j) = dataBlock{9}(j)+dataBlock{10}(j)+dataBlock{11}(j)+dataBlock{12}(j);
        
        % Worm width - width at a midpoint of the skeleton
        %------------------------------------------------------------------
        % We divide a worm in 5 segments:
        % <-head ---- neck ---- midBody ---- hips ---- tail->
        % 0......1/6......2/6............4/6......5/6......6/6
        % We use a definition of 1/6th as per schafer feature in curvature
        % We take a mean of the widths within the midBody to obtain the
        % width value
        wormWidth(j) = mean(dataBlock{8}(round((2/6*NOOFPOINTS))+1:round((4/6*NOOFPOINTS)),j));
       
        % Worm thickness
        wormThickness(j) = (wormWidth(j)./wormLen(j));
        % Worm fatness
        wormFatness(j) = (wormArea(j)./wormLen(j));
    end
end