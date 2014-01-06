function [newLine, m, b, lineMode, c] = getLineCoeff(seg1, offset)
% GETLINECOEFF This function will comptue a line equation coefficients 
% and new y for a segment.
% Input:
%   seg1 - line segment
%   offset - how long the line should be
%       1 - the same length as seg1
%       >1 - longer by that much on both ends
% Output:
%   newLine - coords of a new line
%   m - slope
%   b - coefficient 2
%   lineMode - is line vertical, horizontal or other
%       vertical = 1
%       horizontal = 2
%       other = 3
%   c - coefficient 3 in case line is either vertical or horizontal
% explanation on distances: http://www.mathopenref.com/coordpointdistvh.html
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
c=0;
lineMode = 3;
n = length(seg1(:,1));
x = seg1(:,2);
y = seg1(:,1);
m = (n*sum(x.*y)-sum(x)*sum(y))/(n*sum(x.^2)-sum(x)^2);
b = (sum(y)-m*sum(x))/n;
yLine = m.*x+b;

if length(unique(round(x)))==1
    yLine = y;
end
%alternative way:
%p = polyfit(x,y,1); m = p(1); b = p(2);

%x2 = (y-b)/m;
newLine = [yLine,x];
%text(x(1),y2(1),'x','Color','r')
%text(x(end),y2(end),'x','Color','r')

if offset>1
    x1 = x(1);
    x2 = x(end);
    y1 = yLine(1);
    y2 = yLine(end);
    xNew = ((x1+offset):0.3:(x2-offset))';
    if isempty(xNew)
        xNew = ((x1-offset):0.3:(x2+offset))';
    end
    yNew = m.*xNew+b;
    %if the line is vertical
    if length(unique(round(x)))==1
        yNew = ((y1+offset):0.3:(y2-offset))';
        if isempty(yNew)
            yNew = ((y1-offset):0.3:(y2+offset))';
        end
        xNew = (ones(1,length(yNew))*x1)';
        c=x1;
        lineMode = 1;
    end
    %if horizontal
    if length(unique(round(y)))==1
        yNew = (ones(1,length(xNew))*y1)';
        c=y1;
        lineMode = 2;
    end
    newLine = [yNew,xNew];
end

end