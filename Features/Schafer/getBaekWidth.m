%this function gets width of the animal. It is a part of Baek et al feature
%set
%
%IN:
%seg1 - segment on the skeleton
%outlineCoords - outline coordinates
%
%OUT:
%minWidth - min width of seg1 rotated by 85,90,95 degrees
%intersectionPoints - coordinates of points where the minWidth was found
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function [minWidth, intersectionPoints, idxFinal] = getBaekWidth(seg1, outlineCoords)

%lets calculate the offset. We divide the known length of the worm by its
%known width from WormBase. The ratio is ~ 0.055. we take twice that
%ammount
offset = round(length(outlineCoords)*0.055/2);

%fit the line to the segments
[lineToRotate1, m1, b1, lineMode, c] = getLineCoeff2(seg1,1);

%Rotating the line segment by 90degrees
[newLine1] = rotLineSegment(lineToRotate1, pi/2);
%here we need to justify 10 - lets use a fraction of length
%getting the intersection of the rotated line with the outline
[width90Seg1, p1, p2, idx1] = getIntersectionPoints(outlineCoords, newLine1, offset);
endPoints{2}={p1,p2};
idxAll{2} = idx1;
%Rotating by +5deg =  95deg
[newLine1] = rotLineSegment(lineToRotate1, 95*(pi/180));
%getting the intersection of the rotated line with the outline
[width95Seg1, p1, p2, idx1] = getIntersectionPoints(outlineCoords, newLine1, offset);
endPoints{3}={p1,p2};
idxAll{3} = idx1;
%Rotating by -5deg = 85deg
[newLine1] = rotLineSegment(lineToRotate1, 85*(pi/180));
%getting the intersection of the rotated line with the outline
[width85Seg1,p1, p2, idx1] = getIntersectionPoints(outlineCoords, newLine1, offset);
endPoints{1}={p1,p2};
idxAll{1} = idx1;
[minWidth, minIdx] = min([width85Seg1,width90Seg1,width95Seg1]);
intersectionPoints = endPoints{minIdx};
idxFinal = idxAll{minIdx};
%         %debug
%         img1 = zeros(480,640);
%         skCoords = skelData{1}.skCoords;
%         for j=1:length(skCoords)
%             img1(skCoords(j,1),skCoords(j,2))=1;
%         end

%         outlineCoords = skelData{1}.outlineCoords;
%         for j=1:length(outlineCoords)
%             img1(outlineCoords(j,1),outlineCoords(j,2))=1;
%         end
%         figure;imshow(img1);
end