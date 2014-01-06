%this script starts wormDiagnostics GUI
%
%   This seems to just wrap main_GUI_automatic
%   in a try catch for the compiled version so that the error
%   is displayed in a message box
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function start_main_GUI(varargin)
try
    main_GUI_automatic(varargin);
catch ME1
    msgString = getReport(ME1);
    msgbox(msgString);
    error('Main worm GUI could not be started!\n');
end
end