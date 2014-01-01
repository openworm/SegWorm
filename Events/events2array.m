function isEvent = events2array(frames, totalFrames)
%EVENTS2ARRAY Convert a set of events into a logical array.
%
%   ISEVENT = EVENTS2ARRAY(EVENTS, TOTALFRAMES)
%
%   Inputs:
%       frames      - the frames at which the even took place (see findEvent);
%                     a structure array with fields:
%
%                     start = the start frame
%                     end   = the end frame
%
%       totalFrames - the total number of frames in the video
%
%   Output:
%       isEvent - a logical array of whether the event occured, per frame
%
% See also FINDEVENT
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Convert the event frames to an array of where the events take place.
isEvent = false(totalFrames,1);
for i = 1:length(frames)
    
  % The frames are video indexed, convert them to Matlab indexing.
  isEvent((frames(i).start + 1):(frames(i).end + 1)) = true;
end
end
