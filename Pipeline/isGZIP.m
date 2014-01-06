%this function will check if a file is in gzip format
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function [ret] = isGZIP(gzipFilename)
ret = 0;
fileInStream = [];
try
   fileInStream = java.io.FileInputStream(java.io.File(gzipFilename));
catch exception
   % Unable to access the gzipped file.
   if ~isempty(fileInStream)
     fileInStream.close;
   end
   %msg = sprintf('MATLAB:%s:javaOpenError',mfilename);
   ret = 0;
   return;
end

% Create a Java GZPIP input stream from the file input stream.
try
   gzipInStream = java.util.zip.GZIPInputStream(fileInStream);
catch exception
   % The file is not in gzip format.
   if ~isempty(fileInStream)
     fileInStream.close;
   end
   %msg = sprintf('MATLAB:%s:notGzipFormat',mfilename);
   ret = 0;
   return;
end

gzipInStream.close;
fileInStream.close;
ret = 1;

% function cleanup(filename, varargin)
% % Close the Java streams in varargin and delete the filename.
% 
% % Close the Java streams.
% for k=1:numel(varargin)
%    if ~isempty(varargin{k})
%       varargin{k}.close;
%    end
% end
% 
% % Delete the filename if it exists.
% w = warning;
% warning('off','MATLAB:DELETE:FileNotFound');
% delete(filename);
% warning(w);
