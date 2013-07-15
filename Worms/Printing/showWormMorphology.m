function [saveFile pages] = showWormMorphology(worm, varargin)
%SHOWWORMMORPHOLOGY Show the worm morphology.
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGY(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGY(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGY(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMMORPHOLOGY(WORM, FILEPREFIX, PAGE, ISCLOSE)
%
%   Inputs:
%       worm        - the worm to show
%       filePrefix  - the file prefix for saving the figure;
%                     if empty, the figure is not saved
%       page        - the page number;
%                     if empty, the page number is not shown
%       isClose     - shoud we close the figure after saving it?
%                     when saving the figure, the default is yes (true)
%                     otherwise, the default is no (false)
%
%   Output:
%       saveFile - the file containing the saved figure;
%                  if empty, the figure was not saved
%       pages    - the number of pages in the figure file
%
%   See WORMORGANIZATION, SHOWWORM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we saving the figures to a file?
figFiles = [];
filePrefix = [];
pages = 0;
page = [];
isClose = false;
if ~isempty(varargin) && ~isempty(varargin{1})
    
    % Set the defaults.
    filePrefix = varargin{1};
    isClose = true;
    
    % Do we have page numbers?
    if length(varargin) > 1 && ~isempty(varargin{2})
        page = varargin{2};
        
        % Are we closing the figure after saving it?
        if length(varargin) > 2 && ~isempty(varargin{3})
            isClose = varargin{3};
        end
    end
end

% Show the worm length and width.
[figFiles{end + 1} figPages] = showWormMorphologyLengthWidth(worm, ...
    filePrefix, page + pages, isClose);
pages = pages + figPages;

% Show the worm area.
[figFiles{end + 1} figPages] = showWormMorphologyArea(worm, filePrefix, ...
    page + pages, isClose);
pages = pages + figPages;

% Save the figures to a file.
saveFile = [];
if ~isempty(filePrefix)
    
    % Merge the figure files.
    saveFile = [filePrefix '_morphology.pdf'];
    mergePDFs(saveFile, figFiles);
    
    % Delete the individual figure files.
    for i = 1:length(figFiles)
        delete(figFiles{i});
    end
end
end
