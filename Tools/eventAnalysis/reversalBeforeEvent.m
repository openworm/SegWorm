function [reversalFlag] = reversalBeforeEvent(data1)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
len1 = length(data1);

preOmega = data1(round(len1/2)-20:round(len1/2));

if nanmean(preOmega) < 0
    
    plot(data1);
    ylim([-400,400]);
    hold on;
    plot(1:len1,zeros(1,len1), 'Color', 'r');
    plot(len1/2,-400:400, 'Color', 'b')
    
    
    pause(0.5);
    hold off;
end
