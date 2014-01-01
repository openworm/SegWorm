function simpleProgressUpdate(state, frames, frame, image, diffImage, ...
    variance)
%SIMPLEPROGRESSUPDATE Display a simple progress update.
%
%   SIMPLEPROGRESSUPDATE(FRAME, ~, ~, VARIANCE)
%
%   Inputs:
%       state     - persistent state data for function
%       frames    - the total number of frames
%       frame     - the frame number
%       image     - the video image
%       diffImage - the frame-difference image
%       variance  - the frame-difference variance
%
%   See also VIDEO2DIFF
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Display a simple progress update.
percent = round((double(frame + 1) / double(frames)) * 100.0);
disp([num2str(percent) '%: At frame ' num2str(frame) ...
    ' the variance is ' num2str(variance) '.']);
end

