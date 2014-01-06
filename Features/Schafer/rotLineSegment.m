function [newLine] = rotLineSegment(lineToRotate, ang)
% ROTLINESEGMENT This function will rotate a line segment by a specified
% angle.
% Input:
%   lineToRoate - coordinates to rotate
%   ang - angle
% Output:
%   newLine - rotated shape
%  
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
cRot = [lineToRotate(round(length(lineToRotate)/2),:),0];
T1 = makehgtform('translate',cRot);
T_rot = makehgtform('zrotate',ang);
newLine = [0,0];
for j=1:length(lineToRotate)
    NewPointTmp = T1 * T_rot * inv(T1) * [lineToRotate(j,:),0, 1]';
    newLine(j,:) = NewPointTmp(1:2)';
end
%text(newLine(1,2),newLine(1,1),'x','Color','b');
%text(newLine(end,2),newLine(end,1),'x','Color','b');
end