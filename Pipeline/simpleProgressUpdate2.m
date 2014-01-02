function simpleProgressUpdate2(state, framesNo, frame, image, diffImage, variance)
%SIMPLEPROGRESSUPDATE Display a simple progress update.
%
%   SIMPLEPROGRESSUPDATE(FRAME, ~, ~, VARIANCE)
%
%   Inputs:
%       state     - persistent state data for function
%       frame     - the frame number
%       image     - the video image
%       diffImage - the frame-difference image
%       variance  - the frame-difference variance
%
%   See also VIDEO2DIFF
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% Display a simple progress update.
str1 = strcat('Analyzing', {' '}, num2str(frame), {' '}, 'out of', {' '}, num2str(framesNo));
set(state,'String',str1{1});
drawnow;

end

