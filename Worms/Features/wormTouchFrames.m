function touchFrames = wormTouchFrames(frameCodes, fps)
%WORMTOUCHFRAMES Find the frames where the worm touches itself (i.e., coils).
%
%   TOUCHFRAMES = WORMTOUCHFRAMES(FRAMECODES, FPS)
%
%   Input:
%       frameCodes - the frame codes annotating the worm segmentation per
%                    video frame
%       fps        - the video's frames/second
%
%   Output:
%       touchFrames - a struct containing the frames where the worm
%                     touches itself; the fields are:
%
%                     start = the starting frame wherein the worm
%                             initiates the touch
%                     end   = the ending frame wherein the worm
%                             terminates the touch
%
% See also SEGWORM, WORMFRAMEANNOTATION
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Initialize the frame codes.
codes = wormFrameAnnotation();
segCode = codes(1).id;
dropCode = codes(2).id;
stageCode = codes(3).id;
%noWormCode = codes(4).id;
%boundaryCode = codes(5).id;
%smallWormCode = codes(6).id;
tooFewEndsCode = codes(8).id;
doubleLengthSideCode = codes(9).id;

% Compute the touch duration threshold.
touchThr = round(1/5 * fps);

% Find the touch frames.
touchFrames = struct( ...
    'start', [], ...
    'end', []);
touchFramesI = 0;
numTouches = 0;
numVideoErrs = 0;
numOtherErrs = 0;
for i = 1:length(frameCodes)
    
    switch frameCodes(i)
        
        % Do we have a potential touch frame?
        case {tooFewEndsCode, doubleLengthSideCode}

            % Absorb any intervening frames.
            numTouches = numTouches + numVideoErrs + numOtherErrs;
            numVideoErrs = 0;
            numOtherErrs = 0;
            numTouches = numTouches + 1;
            
        % Do we have an intervening video issue?
        case {dropCode, stageCode}
            if numTouches > 0
                numVideoErrs = numVideoErrs + 1;
            end
            
        % Do we have a potential non-touch frame?
        case segCode %, noWormCode, boundaryCode, smallWormCode}
            
            % Do we have enough potential touch frames?
            if numTouches + numVideoErrs + numOtherErrs >= touchThr
                numFrames = numTouches + numVideoErrs + numOtherErrs;
                numTouches = numTouches + numOtherErrs;
                touchFramesI = touchFramesI + 1;
                touchFrames(touchFramesI).start = i - numFrames - 1;
                touchFrames(touchFramesI).end = ...
                    touchFrames(touchFramesI).start + numTouches - 1;
            end
            
            % Intialize the frame counts.
            numTouches = 0;
            numVideoErrs = 0;
            numOtherErrs = 0;
            
        % Do we have an intervening segmentation error?
        otherwise
            
            % Absorb any video issues.
            if numTouches > 0
                numOtherErrs = numOtherErrs + numVideoErrs;
                numVideoErrs = 0;
                numOtherErrs = numOtherErrs + 1;
            end
    end
end

% At the end of the video, do we have enough potential touch frames?
if numTouches + numVideoErrs + numOtherErrs >= touchThr
    numFrames = numTouches + numVideoErrs + numOtherErrs;
    numTouches = numTouches + numOtherErrs;
    touchFramesI = touchFramesI + 1;
    touchFrames(touchFramesI).start = i - numFrames - 1;
    touchFrames(touchFramesI).end = ...
        touchFrames(touchFramesI).start + numTouches - 1;
end

% Did we find any touch frames?
if isempty(touchFrames(1).start)
    touchFrames = [];
end
end
