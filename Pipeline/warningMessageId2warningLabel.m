function warningLabel = warningMessageId2warningLabel(warningList, messageId)
%WARNINGMESSAGEID2WARNINGLABEL Give a label value for a particular warning message
%
%   warningLabel = WARNINGMESSAGEID2WARNINGLABEL(WARNINGLIST, WARNING)
%
%   Input:
%       warningList - a list of all known warnings. Its a cell array of
%       messageId and warning message.
%       messageId - warning message id string
%
%   Output:
%       warningLabel - a number describing which warning was issues
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

messageIdArray = warningList(:,1);
ids = strcmp(messageIdArray,  messageId);

labelArray = 1:length(warningList);

warningLabel = labelArray(ids);



