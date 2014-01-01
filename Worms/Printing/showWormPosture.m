function [saveFile pages] = showWormPosture(worm, varargin)
%SHOWWORMPOSTURE Show the worm posture.
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTURE(WORM)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTURE(WORM, FILEPREFIX)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTURE(WORM, FILEPREFIX, PAGE)
%
%   [SAVEFILE PAGES] = SHOWWORMPOSTURE(WORM, FILEPREFIX, PAGE, ISCLOSE)
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

% Show the worm waves.
[figFiles{end + 1} figPages] = showWormPostureWave1(worm, filePrefix, ...
    page + pages, isClose);
pages = pages + figPages;
[figFiles{end + 1} figPages] = showWormPostureWave2(worm, filePrefix, ...
    page + pages, isClose);
pages = pages + figPages;

% Show the worm coils and kinks.
[figFiles{end + 1} figPages] = ...
    showWormPostureCoilsKinks(worm, filePrefix, page + pages, isClose);
pages = pages + figPages;

% Show the worm bends.
[figFiles{end + 1} figPages] = showWormPostureBends1(worm, filePrefix, ...
    page + pages, isClose);
pages = pages + figPages;
[figFiles{end + 1} figPages] = showWormPostureBends2(worm, filePrefix, ...
    page + pages, isClose);
pages = pages + figPages;

% Show the worm orientation.
[figFiles{end + 1} figPages] = showWormPostureOrientation(worm, ...
    filePrefix, page + pages, isClose);
pages = pages + figPages;

% Show the worm eigen projections.
[figFiles{end + 1} figPages] = showWormPostureEigens1(worm, filePrefix, ...
    page + pages, isClose);
pages = pages + figPages;
[figFiles{end + 1} figPages] = showWormPostureEigens2(worm, filePrefix, ...
    page + pages, isClose);
pages = pages + figPages;

% Save the figures to a file.
saveFile = [];
if ~isempty(filePrefix)
    
    % Merge the figure files.
    saveFile = [filePrefix '_posture.pdf'];
    mergePDFs(saveFile, figFiles);
    
    % Delete the individual figure files.
    for i = 1:length(figFiles)
        delete(figFiles{i});
    end
end
end
