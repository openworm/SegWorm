function worm2Histogram_GUI(histFile, featFiles, progFunc, funcState)
%WORM2HISTOGRAM_GUI A wrapper to convert a collection of experiments
%(feature files) to histograms.
%
%   WORM2HISTOGRAMGUI(HISTFILE, FEATFILES, PROGFUNC, FUNCSTATE)
%
%   Inputs:
%       histFile  - the name for the histogram file
%                   (the extension is ".hist.mat")
%       featFiles - the feature files to collect into a histogram
%       progFunc  - a function to update on the progress
%       progState - a state for the progress function
%
%       Note: the progress function signature should be
%
%       FUNCSTATE = PROGFUNC(PERCENT, MSG, FUNCSTATE)
%
%       Arguments:
%          funcState = a progress function state
%          percent   = the progress percent (0 to 100%)
%          msg       = a message on our progress (to display)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

worm2histogram(histFile, featFiles, [], [], 0, progFunc, funcState);
end
