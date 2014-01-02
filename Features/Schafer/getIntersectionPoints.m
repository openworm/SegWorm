%this function will find the two intersection points on the outline by the perpendicular
%line
%IN
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function [widthWorm, p1, p2, idx] = getIntersectionPoints(outlineCoords, pLine, offset)

%lets calculate how far we are going to search from the origin of the perpendicular line. 
%We divide the known length of the worm by its known width from WormBase. 
%The ratio is ~ 0.055. we take twice that ammount just to be sure
offset2 = offset*2;

%lets get longer lines to make sure they intersect with outline
[lNewLine1, m3, b3, lineMode, c] = getLineCoeff(pLine,offset2);

if isempty(lNewLine1)
    1;
end
x2 = outlineCoords(1:end-1,2);
y2 = outlineCoords(1:end-1,1);
xOrigin = lNewLine1(round(length(lNewLine1)/2),2);
yOrigin = lNewLine1(round(length(lNewLine1)/2),1);
%lets calculate the distance
switch lineMode
   case 1
      dist1 = c-x2;
   case 2
      dist1 = c-y2;
   case 3
      dist1 = (m3.*x2+b3)-y2;
end

%[minVal1,minIdx1]=sort(abs(dist1));
%lets sort a distance to the line and a distance to origin point
distToLine = abs(dist1);
xd = x2-xOrigin;
yd = y2-yOrigin;
distToOrigin = sqrt(xd.*xd + yd.*yd);
A = [distToLine,distToOrigin];
%first sort agains distance to origin
[minVal1, minIdx1] = sortrows(A,2);
%chop off the far points
vecOffset = sum(distToOrigin<offset2);
%in case the offset2 is smaller than the distance to the origin we get
%vecOffset equal to 0. This can be because the worm is in an unusual fat
%shape and we will try to clip the vector again with higher offset
if vecOffset==0
	vecOffset = sum(distToOrigin<minVal1(1,2)*2);
end
minVal1small = minVal1(1:vecOffset,:);
minIdx1small = minIdx1(1:vecOffset);
%now sort agains distance to the line
[minVal2, minIdx2] = sortrows(minVal1small,1);
%select only the ones close enough to the origin and most closest to the
%line
minIdxFinal = minIdx1small(minIdx2(1:vecOffset));
%make sure to take a further distance
lookuopList = 1:length(minIdxFinal);
res1 = lookuopList(abs(minIdxFinal'-minIdxFinal(1))>1);
%select the correct anchor points
p1 = outlineCoords(minIdxFinal(1),:);
p2 = outlineCoords(minIdxFinal(res1(1)),:);
idx = [minIdxFinal(1),minIdxFinal(res1(1))];
%debug
%text(p1(1,2),p1(1,1),'x','Color','r');
%text(p2(1,2),p2(1,1),'x','Color','r');

x1 = p1(1,2);
y1 = p1(1,1);
x2 = p2(1,2);
y2 = p2(1,1);

xd = x2-x1;
yd = y2-y1;
widthWorm = sqrt(xd*xd + yd*yd);

% % %debug
%  for k=1:length(lNewLine1)
%      %text(round(lNewLine1(k,2)),round(lNewLine1(k,1)),'x','Color','m');
%      text(round(lNewLine1(k,2)),round(lNewLine1(k,1)),num2str(round(distB(k))),'Color','m');
%      %text(ceil(lNewLine1(k,2)),ceil(lNewLine1(k,1)),num2str(round(distB(k))),'Color','m');
%  end
end