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

% Display a simple progress update.
percent = round((double(frame + 1) / double(frames)) * 100.0);
disp([num2str(percent) '%: At frame ' num2str(frame) ...
    ' the variance is ' num2str(variance) '.']);
end

