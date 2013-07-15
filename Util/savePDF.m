function savePDF(figureHandle, filename, varargin)
%SAVEFIGURE Save a figure to a file.
%
%   SAVEFIGURE(FIGUREHANDLE, FILENAME)
%
%   SAVEFIGURE(FIGUREHANDLE, FILENAME, PAGETITLE)
%
%   SAVEFIGURE(FIGUREHANDLE, FILENAME, PAGETITLE, PAGE)
%
%   SAVEFIGURE(FIGUREHANDLE, FILENAME, PAGETITLE, PAGE, ISCLOSE)
%
%   Inputs:
%       figureHandle - the figure handle
%       filename     - the file name in which to save the figure;
%                      if empty, the file is not saved
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

% Determine the title.
pageTitle = [];
if ~isempty(varargin)
    pageTitle = varargin{1};
end

% Determine the page number.
page = [];
if length(varargin) > 1
    page = varargin{2};
end

% Are we closing the figure after saving it?
isClose = false;
if length(varargin) > 2
    isClose = varargin{3};
end

% Add the title.
if ~(isempty(pageTitle) && isempty(page))
    
    % Construct the title.
    if ~isempty(page)
        pageTitle = ['<html><b>Page ' num2str(page) ' &rarr; ' ...
            pageTitle '</b></html>'];
    else
        pageTitle = ['<html><b>' pageTitle '</b></html>'];
    end
    
    % Add the title.
    titlePosition = [0, 0, length(pageTitle), 2];
    uicontrol('units', 'characters', 'String', pageTitle, ...
        'Position', titlePosition);
end

% Adjust the figure size.
set(figureHandle, 'PaperPosition', [0.25 0.25 22.9036 16.048]);
set(figureHandle, 'PaperOrientation', 'landscape');
set(figureHandle, 'PaperType', 'A2');

% Wait for the figure to finish drawing.
drawnow;

% Save the figure to a file.
saveas(figureHandle, filename, 'pdf');

% Close the figure.
if isClose
    close(figureHandle);
end
end