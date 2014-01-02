function result = isDroppedFrame(val)

%ISDROPPEDFRAME Tells you if input value has a dropped frame label
%
%   Input:
%       val - value from a cell array
%
%   Output:
%       result - otput value 0 or 1
%
%
% See also: isStageMovementFrame, isSegFailFrame
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

result = false;

if ~iscell(val)
    if isempty(val)
        result = true;
    else
        result = false;
    end
end