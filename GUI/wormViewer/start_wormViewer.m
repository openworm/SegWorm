%this script starts wormViewer GUI

try
    wormViewer();
    % © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
catch
    error('WormViewer could not be started!\n');
end