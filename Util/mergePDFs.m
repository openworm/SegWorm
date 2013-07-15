%MERGEPDFS Merge PDF files.
%
%   MERGEPDFS(MERGEFILE, FILES)
%
%   MERGEPDFS(MERGEFILE, FILES, ISDELETE)
%
%   Inputs:
%       mergeFile - the file name for the merged PDF files
%       files     - a cell array of the names for the PDF files to merge
%       isDelete  - should we delete the separate PDFs after merging them?
%                   the default is no (false)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
function mergePDFs(mergeFile, files, varargin)

% Should we delete the separate PDFs after merging them?
isDelete = false;
if ~isempty(varargin)
    isDelete = varargin{1};
end

% Organize the files.
if ~iscell(files)
    files = {files};
end

% Do we only have one file?
if length(files) == 1
    [status, msg, ~] = movefile(files{1}, mergeFile);
    
    % Report the error.
    if ~status
        error('mergePDFs:Move', [files{1} ' cannot be moved to "' ...
            mergeFile '": ' msg]);
    end
    
    % Done.
    return;
end

% Construct a string with the merging files.
fileStr = [];
for i = 1:length(files)
    fileStr = [fileStr ' "' files{i} '"'];
end

% % Use Ghostscript to merge.
% gsPath = '/usr/local/bin/gs';
% command = [gsPath ' -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite ' ...
%     '-dAutoRotatePages=/None -c "<</Orientation 3>> setpagedevice" ' ...
%     '-sOutputFile=' '''' mergeFile '''' fileStr ];

% Use Pdftk to merge.
pdftkPath = '/usr/local/bin/pdftk';
tmpMergeFile = [mergeFile '.tmp'];
command = [pdftkPath ' ' fileStr ' cat output "' tmpMergeFile '"; ' ...
    pdftkPath ' "' tmpMergeFile '" cat 1-endE output "' mergeFile '"; ' ...
    'rm "' tmpMergeFile '"'];

% Merge the PDFs.
[status, result] = system(command);
if status ~= 0
    
    % Construct a string with the merging files.
    fileStr = [];
    for i = 1:length(files)
        fileStr = [fileStr ', "' files{i} '"'];
    end
    
    % Report the error.
    error('mergePDFs:Merge', [fileStr ' cannot be merged into "' ...
        mergeFile '": ' result]);
end

% Delete the separate PDFs.
if isDelete
    for i = 1:length(files)
        delete(files{i});
    end
end
end
