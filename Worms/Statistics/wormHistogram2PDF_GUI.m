function errorMSG = wormHistogram2PDF_GUI(pdfFile, expHistFile, ...
    controlHistFile, progFunc, funcState)
%WORMHISTOGRAM2PDF_GUI A wrapper to convert an experiment (and optional
%control) histogram to a visual PDF file.
%
%   ERRORMSG = WORMHISTOGRAM2PDF_GUI(CSVFILE, EXPHISTFILE, CONTROLHISTFILE,
%                                    PROGFUNC, FUNCSTATE)
%
%   Inputs:
%       pdfFile         - the name for the PDF file
%       expHistFile     - the experiment histogram file
%       controlHistFile - the control histogram file
%       progFunc        - a function to update on the progress
%       progState       - a state for the progress function
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
%   Output:
%       errorMSG - an error message if an error occurred;
%                  if empty, the PDF file was created successfully
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

errorMSG = [];
end
