function relativePath = getRelativePath(fullPath)
% GETRELATIVEPATH This function will take a full path of a file and
% depending on the current path will truncate it.
%
%   Input:
%           fullPath - full path in the file system
%
%   Output:
%           relativePath - relative path in the file system    
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

currentPath = [pwd,'\'];
relativePath = strrep(fullPath, currentPath, '');

end