function saveTIF(figureHandle, filename, varargin)
%SAVETIF Save a figure to a TIF file.
%
%   SAVETIF(FIGUREHANDLE, FILENAME)
%
%   SAVETIF(FIGUREHANDLE, FILENAME, QUALITY, ISAPPEND, PAGETITLE, PAGE,
%           ISCLOSE)
%
%   Inputs:
%       figureHandle - the figure handle
%       filename     - the file name in which to save the figure;
%                      if empty, the file is not saved
%       quality      - the quality (magnification) of the figure
%                      the default is 1
%       isAppend     - are we appending the figure?
%                      the default is no (false)
%       pageTitle    - the title;
%                      if empty, the title is not shown
%       page         - the page number;
%                      if empty, the page number is not shown
%       isClose      - shoud we close the figure after saving it?
%                      the default is no (false)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Is the filename empty?
if isempty(filename)
    return;
end

% Determine the quality.
quality = 1;
if ~isempty(varargin)
    quality = varargin{1};
end

% Are we appending the figure?
isAppend = false;
if length(varargin) > 1
    isAppend = varargin{2};
end

% Determine the title.
pageTitle = [];
if length(varargin) > 2
    pageTitle = varargin{3};
end

% Determine the page number.
page = [];
if length(varargin) > 3
    page = varargin{4};
end

% Are we closing the figure after saving it?
isClose = false;
if length(varargin) > 4
    isClose = varargin{5};
end

% Add the title.
if ~(isempty(pageTitle) && isempty(page))
    
    % Construct the page.
%     if ~isempty(page)
%         pageTitle = ['<html><b>Page ' num2str(page) ' &rarr; ' ...
%             pageTitle '</b></html>'];
%     else
%         pageTitle = ['<html><b>' pageTitle '</b></html>'];
%     end
    if ~isempty(page)
        pageTitleStr = ['\fontsize{14}\bfPage ' num2str(page)];
    end
    
    % Add the title.
    if isempty(pageTitle)
        pageTitleStr = [pageTitleStr ' '];
    else
        pageTitleStr = [pageTitleStr '\rm   \rightarrow   ' pageTitle];
    end
    
    % Add the title.
%     uicontrol(figureHandle, 'units', 'characters', 'String', pageTitle, ...
%         'Position', titlePosition, 'Visible', 'on');
    titlePosition = [0, 0, length(pageTitleStr), 2];
    titleAxis = axes('units', 'characters', 'Position', titlePosition, ...
        'XTick', [], 'YTick', [], 'Parent', figureHandle);
    text(0.5, 0.5, pageTitleStr, 'HorizontalAlignment','center', ...
        'Parent', titleAxis);
end

% % Adjust the figure size.
% set(figureHandle, 'PaperPosition', [0.25 0.25 22.9036 16.048]);
% set(figureHandle, 'PaperOrientation', 'landscape');
% set(figureHandle, 'PaperType', 'A2');

% Wait for the figure to finish drawing.
drawnow;

% Save the figure to a file.
if isAppend
    export_fig(figureHandle, filename, ['-m' num2str(quality)], ...
        '-nocrop', '-append');
else
    export_fig(figureHandle, filename, ['-m' num2str(quality)], ...
        '-nocrop');
end

% Close the figure.
if isClose
    close(figureHandle);
end
end