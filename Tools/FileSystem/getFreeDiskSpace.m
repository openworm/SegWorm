function freeSpaceGB = getFreeDiskSpace()
% GETFREEDISKSPACE This function will get the free disk space on the
% computer in GB.
% It was adapted from suggestions on the mathworks forum:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/66633
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
[~,ret1] = dos('dir');
[~,ret2] = size(ret1);
f = strrep(ret1((ret2-27):(ret2-11)),',','');
freeSpaceGB = str2double(f)/(1024*1024*1024);
