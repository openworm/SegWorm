function currentDir = getCurrentExeDir
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
if isdeployed % Stand-alone mode.
    [status, result] = system('path');
    currentDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
else % MATLAB mode.
    currentDir = matlabroot;
end