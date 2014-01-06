function drawXonWorm(lNewLine1, flag1)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
for k=1:length(lNewLine1)
    if flag1 == 1
        text(lNewLine1(k,2),lNewLine1(k,1),'x','Color','b');
    elseif flag1 == 2
        text(lNewLine1(k,2),lNewLine1(k,1),'x','Color','r');
    elseif flag1 == 3
        text(lNewLine1(k,2),lNewLine1(k,1),'x','Color','m');
    else
        text(lNewLine1(k,2),lNewLine1(k,1),'x','Color','y');
    end
end