function warningMessage = warningLabel2warningMessage(warningList, warningLabel)
%WARNINGLABEL2WARNINGMESSAGE Give a label value for a particular warning message
%
%   warningMessage = WARNINGLABEL2WARNINGMESSAGE(WARNINGLIST, WARNING)
%
%   Input:
%       warningList - a list of all known warnings. Its a cell array of
%       messageId and warning message.
%       warningLabel - warning label
%
%   Output:
%       warningMessage - a string describing the warning
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

warningMessage = warningList(warningLabel,2);



