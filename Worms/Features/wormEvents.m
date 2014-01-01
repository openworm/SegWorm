%% Compute the multi-scale worm.
% *** REPLACE THESE CALLS WITH WHAT YOU ALREADY HAVE ***
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
wormSamples = 49;
file = dir('*_features.mat');
if isempty(file)
    error('wormEvents:NoFeatures', 'cannot find the features file');
end
load(file(1).name, 'featureData');
if ~exist('normalized', 'dir')
    return;
end
cd('normalized');
frameCodes = featureData.frameAnnotation;
omegaFrames = featureData.omegaFrames1;
upsilonFrames = featureData.upsilonFrames1;
wormFile = 'segNormInfo.mat';
useSamples = {17:33, 1:49};
type = 'bf';
scales = .75;
isSparse = false;
isAtT1 = true;
isNoisy = false;
htDirMode = 3;
isAbsDir = false;
[diffData, ~, ~, fps, ~] = multiScaleWorm(wormFile, [], [], useSamples, ...
    [], type, scales, isSparse, isAtT1, isNoisy, htDirMode, isAbsDir, ...
    ventralMode);

% *** REPLACE THIS THE COMPUTATION OF MEAN WORM LENGTH ***
meanWormLength = 1000;

% Get the midbody (mid 1/3 of the worm) speed.
midbodySpeed = diffData{7}{1}(1,:);



%% *** COPY STARTS HERE

% *** Make videos of the events.
isEventVideos = false;

% % *** Check the values.
% isSanityCheck = true;

% Offset the speed to match the frame count.
% speed = [];
% speed(1) = NaN;
% speed(2:(length(midbodySpeed) + 1)) = midbodySpeed;
speed = midbodySpeed;
totalFrames = length(speed);
lastFrame = totalFrames - 1;

% Compute the distance. This avoids both segmentation noise and having to
% re-interpolate the distance when frames are missing.
distance = abs(speed / fps);

%% Find the forward motion.
wormSpeedThr = meanWormLength * 0.05; % 5 percent of its length
wormDistanceThr = meanWormLength * 0.05; % 5 percent of its length
wormEventFramesThr = 1.5 * fps;
wormEventMinInterFramesThr = 0.25 * fps;
minForwardSpeed = wormSpeedThr;
minForwardDistance = wormDistanceThr;
forwardFrames = findEvent(speed, minForwardSpeed, [], true, ...
    wormEventFramesThr, [], false, ...
    minForwardDistance, [], true, distance, wormEventMinInterFramesThr);

% % Save this for computing paused frames.
% allForwardFrames = findEvent(speed, minForwardSpeed, [], true, ...
%     [], [], false, ...
%     minForwardDistance, [], true, distance, wormEventMinInterFramesThr);

% Compute the forward statistics.
[forwardEventStats forwardStats] = events2stats(forwardFrames, fps, ...
    distance, 'distance', 'interDistance');

% Reorganize everything for the feature file.
forwardFrames = forwardEventStats;
forwardFrequency = [];
forwardRatios = [];
if ~isempty(forwardStats)
    forwardFrequency = forwardStats.frequency;
    forwardRatios = forwardStats.ratio;
end
forward = struct( ...
    'frames', forwardFrames, ...
    'frequency', forwardFrequency, ...
    'ratio', forwardRatios);



%% Find the backward motion.
maxBackwardSpeed = -wormSpeedThr;
minBackwardDistance = wormDistanceThr;
backwardFrames = findEvent(speed, [], maxBackwardSpeed, true, ...
    wormEventFramesThr, [], false, ...
    minBackwardDistance, [], true, distance, wormEventMinInterFramesThr);

% % Save this for computing paused frames.
% allBackwardFrames = findEvent(speed, [], maxBackwardSpeed, true, ...
%     [], [], false, ...
%     minBackwardDistance, [], true, distance, wormEventMinInterFramesThr);

% Compute the backward statistics.
[backwardEventStats backwardStats] = events2stats(backwardFrames, fps, ...
    distance, 'distance', 'interDistance');

% Reorganize everything for the feature file.
backwardFrames = backwardEventStats;
backwardFrequency = [];
backwardRatios = [];
if ~isempty(backwardStats)
    backwardFrequency = backwardStats.frequency;
    backwardRatios = backwardStats.ratio;
end
backward = struct( ...
    'frames', backwardFrames, ...
    'frequency', backwardFrequency, ...
    'ratio', backwardRatios);



%% Find the paused motion.
wormPauseThr = meanWormLength * 0.025; % 2.5 percent of its length
minPausedSpeed = -wormPauseThr;
maxPausedSpeed = wormPauseThr;
pausedFrames = findEvent(speed, minPausedSpeed, maxPausedSpeed, true, ...
    wormEventFramesThr, [], false, ...
    [], [], true, distance, wormEventMinInterFramesThr);

% Compute the paused statistics.
[pausedEventStats pausedStats] = events2stats(pausedFrames, fps, ...
    distance, 'distance', 'interDistance');

% Reorganize everything for the feature file.
pausedFrames = pausedEventStats;
pausedFrequency = [];
pausedRatios = [];
if ~isempty(pausedStats)
    pausedFrequency = pausedStats.frequency;
    pausedRatios = pausedStats.ratio;
end
paused = struct( ...
    'frames', pausedFrames, ...
    'frequency', pausedFrequency, ...
    'ratio', pausedRatios);

% % Combine all the forward and backward motion.
% motionStartFrames = ...
%     cat(2, [forwardFrames.start], [backwardFrames.start]);
% motionEndFrames = ...
%     cat(2, [forwardFrames.end], [backwardFrames.end]);
% [motionStartFrames orderI] = sort(motionStartFrames);
% motionEndFrames = motionEndFrames(orderI);
% 
% % The paused motion is anything that's neither forward nor backward motion.
% pausedFrames = struct( ...
%     'start', [], ...
%     'end',  []);
% j = 0;
% for i = 1:(length(motionStartFrames) - 1)
%     
%     % Are there any frames between the forward and backward motion?
%     startFrame = motionEndFrames(i) + 1;
%     endFrame = motionStartFrames(i + 1) - 1;
%     if endFrame >= startFrame
%         j = j + 1;
%         pausedFrames(j).start = startFrame;
%         pausedFrames(j).end = endFrame;
%     end
% end
% 
% % Add the first and last pauses, if they exist.
% if motionStartFrames ~= 0
%     pausedFrames(2:(end + 1)) = pausedFrames;
%     pausedFrames(1).start = 0;
%     pausedFrames(1).end = motionStartFrames(1) - 1;
% end
% if motionEndFrames ~= lastFrame
%     pausedFrames(end + 1).start = motionEndFrames(end) + 1;
%     pausedFrames(end).end = lastFrame;
% end
% 
% % % Unify small time gaps.
% % if isSanityCheck
% %     allPausedFrames = pausedFrames; % *** save this for the sanity check
% % end
% i = 1;
% while i < length(pausedFrames)
%     
%     % Swallow the gaps.
%     while i < length(pausedFrames) && ...
%             pausedFrames(i + 1).start - pausedFrames(i).end - 1 < ...
%             wormEventMinInterFramesThr
%         pausedFrames(i).end = pausedFrames(i + 1).end;
%         pausedFrames(i + 1) = [];
%     end
%     
%     % Advance.
%     i = i + 1;
% end
% 
% % Remove short paused events.
% pausedNumFrames = [pausedFrames.end] - [pausedFrames.start] + 1;
% pausedFrames(pausedNumFrames < wormEventFramesThr) = [];
% if isempty(pausedFrames(1).start)
%     pausedFrames = [];
% end
% 
% % Compute the paused statistics.
% [pausedEventStats pausedStats] = events2stats(pausedFrames, fps, ...
%     distance, 'distance', 'interDistance');
% 
% % Reorganize everything for the feature file.
% pausedFrames = pausedEventStats;
% pausedFrequency = [];
% pausedRatios = [];
% if ~isempty(pausedStats)
%     pausedFrequency = pausedStats.frequency;
%     pausedRatios = pausedStats.ratio;
% end
% paused = struct( ...
%     'frames', pausedFrames, ...
%     'frequency', pausedFrequency, ...
%     'ratio', pausedRatios);



%% Compute the motion mode.

% Translate the events to logical arrays.
isForwardFrame = events2array(forwardFrames, totalFrames);
isBackwardFrame = events2array(backwardFrames, totalFrames);
isPausedFrame = events2array(pausedFrames, totalFrames);

% Set forward = 1, backward = -1, paused = 0, and unknown = NaN.
motionModes = nan(1,totalFrames);
motionModes(isForwardFrame) = 1;
motionModes(isBackwardFrame) = -1;
motionModes(isPausedFrame) = 0;



%% Compute the bends.
locomotionBends = wormBends(wormFile, motionModes, ventralMode);



%% Compute the coiled shapes.

% Compute the coiled frames.
coilFrames = wormTouchFrames(frameCodes, fps);

% Compute the coiled statistics.
[coilEventStats coiledStats] = events2stats(coilFrames, fps, ...
    distance, [], 'interDistance');

% Reorganize everything for the feature file.
coilFrames = coilEventStats;
coilFrequency = [];
coilTimeRatio = [];
if ~isempty(coiledStats)
    coilFrequency = coiledStats.frequency;
    coilTimeRatio = coiledStats.ratio.time;
end
coils = struct( ...
    'frames', coilFrames, ...
    'frequency', coilFrequency, ...
    'timeRatio', coilTimeRatio);



%% Compute the omega turns.

% Compute the omega frames.
omegaFramesDorsal = findEvent(omegaFrames, 1, [], true);
omegaFramesVentral = findEvent(omegaFrames, [], -1, true);

% Unify the ventral and dorsal turns.
omegaFrames = cat(2, omegaFramesVentral, omegaFramesDorsal);
isOmegaVentral = [true(1, length(omegaFramesVentral)), ...
    false(1, length(omegaFramesDorsal))];
if ~isempty(omegaFramesVentral) && ~isempty(omegaFramesDorsal)
    [~, orderI] = sort([omegaFrames.start]);
    omegaFrames = omegaFrames(orderI);
    isOmegaVentral = isOmegaVentral(orderI);
end

% Compute the omega statistics.
[omegaEventStats omegaStats] = events2stats(omegaFrames, fps, ...
    distance, [], 'interDistance');

% Add the turns ventral/dorsal side.
omegaFrames = omegaEventStats;
if ~isempty(omegaFrames)
    omegaCells = squeeze(struct2cell(omegaFrames));
    omegaCells{end+1,1} = [];
    for i = 1:size(omegaCells, 2)
        omegaCells{end, i} = isOmegaVentral(i);
    end
    omegaFieldNames = fieldnames(omegaFrames);
    omegaFieldNames{end + 1} = 'isVentral';
    omegaFrames = cell2struct(omegaCells, omegaFieldNames, 1);
end

% Reorganize everything for the feature file.
omegaFrequency = [];
omegaTimeRatio = [];
if ~isempty(omegaStats)
    omegaFrequency = omegaStats.frequency;
    omegaTimeRatio = omegaStats.ratio.time;
end
omegas = struct( ...
    'frames', omegaFrames, ...
    'frequency', omegaFrequency, ...
    'timeRatio', omegaTimeRatio);



%% Compute the upsilon turns.

% Compute the upsilon frames.
upsilonFramesDorsal = findEvent(upsilonFrames, 1, [], true);
upsilonFramesVentral = findEvent(upsilonFrames, [], -1, true);

% Unify the ventral and dorsal turns.
upsilonFrames = cat(2, upsilonFramesVentral, upsilonFramesDorsal);
isUpsilonVentral = [true(1, length(upsilonFramesVentral)), ...
    false(1, length(upsilonFramesDorsal))];
if ~isempty(upsilonFramesVentral) && ~isempty(upsilonFramesDorsal)
    [~, orderI] = sort([upsilonFrames.start]);
    upsilonFrames = upsilonFrames(orderI);
    isUpsilonVentral = isUpsilonVentral(orderI);
end

% Compute the upsilon statistics.
[upsilonEventStats upsilonStats] = events2stats(upsilonFrames, fps, ...
    distance, [], 'interDistance');

% Add the turns ventral/dorsal side.
upsilonFrames = upsilonEventStats;
if ~isempty(upsilonFrames)
    upsilonCells = squeeze(struct2cell(upsilonFrames));
    upsilonCells{end+1,1} = [];
    for i = 1:size(upsilonCells, 2)
        upsilonCells{end, i} = isUpsilonVentral(i);
    end
    upsilonFieldNames = fieldnames(upsilonFrames);
    upsilonFieldNames{end + 1} = 'isVentral';
    upsilonFrames = cell2struct(upsilonCells, upsilonFieldNames, 1);
end

% Reorganize everything for the feature file.
upsilonFrequency = [];
upsilonTimeRatio = [];
if ~isempty(upsilonStats)
    upsilonFrequency = upsilonStats.frequency;
    upsilonTimeRatio = upsilonStats.ratio.time;
end
upsilons = struct( ...
    'frames', upsilonFrames, ...
    'frequency', upsilonFrequency, ...
    'timeRatio', upsilonTimeRatio);



%% Compute the path range.
pathRange = wormPathRange(centroidPathX, centroidPathY);



%% Compute the path duration.

% Compute the path scale.
headWidth = nanmean(headWidths);
midWidth = nanmean(midbodyWidths);
tailWidth = nanmean(tailWidths);
meanWidth = (headWidth + midWidth + tailWidth) / 3;
pathScale = sqrt(2) / meanWidth;

% Compute the worm segments.
headI = 1;
tailI = wormSamples;
wormSegSize = round(tailI / 6);
headIs = headI:(headI + wormSegSize - 1);
midbodyIs = (headI + wormSegSize):(tailI - wormSegSize);
tailIs = (tailI - wormSegSize + 1):tailI;

% Compute the skeleton points.
points = { ...
    headI:tailI, ...
    headIs, ...
    midbodyIs, ...
    tailIs};

% Compute the path duration and organize everything for the feature file.
[arena durations] = wormPathTime(postureXSkeletons, postureYSkeletons, ...
    points, pathScale, fps);
pathDuration = struct( ...
    'arena', arena, ...
    'worm', durations(1), ...
    'head', durations(2), ...
    'midbody', durations(3), ...
    'tail', durations(4));



%% *** SANITY CHECK
% The forward, backward, and paused frames should account for all frames,
% time, and distance with no overlap.
% if isSanityCheck
%     [allForwardFrames, ~] = events2stats(allForwardFrames, fps, ...
%         distance, 'distance', 'interDistance');
%     [allBackwardFrames, ~] = events2stats(allBackwardFrames, fps, ...
%         distance, 'distance', 'interDistance');
%     [allPausedFrames, ~] = events2stats(allPausedFrames, fps, ...
%         distance, 'distance', 'interDistance');
%     allFrames = [];
%     totalTime = 0;
%     totalDistance = 0;
%     for i = 1:length(allForwardFrames)
%         allFrames((end + 1): ...
%             (end + allForwardFrames(i).end - allForwardFrames(i).start + 1)) = ...
%             allForwardFrames(i).start:allForwardFrames(i).end;
%         totalTime = totalTime + allForwardFrames(i).time;
%         totalDistance = totalDistance + allForwardFrames(i).distance;
%     end
%     for i = 1:length(allBackwardFrames)
%         allFrames((end + 1): ...
%             (end + allBackwardFrames(i).end - allBackwardFrames(i).start + 1)) = ...
%             allBackwardFrames(i).start:allBackwardFrames(i).end;
%         totalTime = totalTime + allBackwardFrames(i).time;
%         totalDistance = totalDistance + allBackwardFrames(i).distance;
%     end
%     for i = 1:length(allPausedFrames)
%         allFrames((end + 1): ...
%             (end + allPausedFrames(i).end - allPausedFrames(i).start + 1)) = ...
%             allPausedFrames(i).start:allPausedFrames(i).end;
%         totalTime = totalTime + allPausedFrames(i).time;
%         totalDistance = totalDistance + allPausedFrames(i).distance;
%     end
%     
%     % Check the frames.
%     if length(allFrames) ~= totalFrames || ...
%             length(unique(allFrames)) ~= totalFrames
%         error('wormEvents:ForwardBackwardPausedFrames', ...
%             'the sum of the forward, backward, and paused frames do not add up!')
%     end
%     
%     % Check the time (IEEE floating point errors will lead to imprecision).
%     totalRealTime = totalFrames / fps;
%     disp(['Total time (seconds): ' num2str(totalRealTime)]);
%     disp(['Summed time (seconds): ' num2str(totalTime)]);
%     disp(['Time difference (seconds): ' num2str(totalRealTime - totalTime)]);
%     
%     % Check the distance (IEEE floating point errors will lead to imprecision).
%     totalRealDistance = nansum(distance);
%     disp(['Total distance (microns): ' num2str(totalRealDistance)]);
%     disp(['Summed distance (microns): ' num2str(totalDistance)]);
%     disp(['Distance difference (microns): ' ...
%         num2str(totalRealDistance - totalDistance)]);
% end


%% *** COPY ENDS HERE

%% *** WHEN DISPLAYING THE EVENTS IN THE FEATURE VIEWER USE THE FOLLOWING.



%% Display the forward motion.
% Display the forward motion histogram.
isForwardFrame = events2array(forwardFrames, totalFrames); % for your GUI
forwardStats4Plots = removePartialEvents(forwardEventStats, totalFrames);
if ~isempty(forwardStats4Plots)
    histData = histogram([forwardStats4Plots.distance]);
    figure;
    if ~isempty(forwardStats4Plots)
        plotHistogram(histData, 'Forward Motion Events Histogram', ...
            'Forward Event Distance (microns)', ...
            'Forward Event Distance', str2colors('k'));
    end
    
    % Display the forward motion plot.
    figure;
    if ~isempty(forwardStats4Plots)
        
        % Plot distance vs. inter distance.
        hold on;
        subplot(1,2,1);
        states(2) = struct( ...
            'fieldName', 'interDistance', ...
            'height', [], ...
            'width', 1, ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'distance';
        states(1).isInterEvent = false;
        eventNames = {'Forward Motion', 'Not Forward Motion'};
        plotEvent(forwardEventStats, totalFrames, fps, ...
            'Forward Motion Distance', 'Forward Distance (microns)', ...
            eventNames, @event2box, states, str2colors('gr', -0.1));
        
        % Plot time vs. inter time.
        subplot(1,2,2);
        states(2) = struct( ...
            'fieldName', 'interDistance', ...
            'height', [], ...
            'width', 1, ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'time';
        states(1).isInterEvent = false;
        eventNames = {'Forward Motion', 'Not Forward Motion'};
        plotEvent(forwardEventStats, totalFrames, fps, ...
            'Forward Motion Time', 'Forward Time (seconds)', ...
            eventNames, @event2box, states, str2colors('gr', -0.1));
        
    % No data.
    else
        xlabel('Time (seconds)');
        ylabel('Distance (microns)');
        title('Forward Motion Events');
    end
end



%% Display the backward motion.
% Display the forward motion histogram.
isBackwardFrame = events2array(backwardFrames, totalFrames); % for your GUI
backwardStats4Plots = removePartialEvents(backwardEventStats, totalFrames);
if ~isempty(backwardStats4Plots)
    histData = histogram([backwardStats4Plots.distance]);
    figure;
    if ~isempty(backwardStats4Plots)
        plotHistogram(histData, 'Backward Motion Events Histogram', ...
            'Backward Event Distance (microns)', ...
            'Backward Event Distance', str2colors('k'));
    end
    
    % Display the backward motion plot.
    figure;
    if ~isempty(forwardStats4Plots)
        
        % Plot distance vs. inter distance.
        hold on;
        subplot(1,2,1);
        states(2) = struct( ...
            'fieldName', 'interDistance', ...
            'height', [], ...
            'width', 1, ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'distance';
        states(1).isInterEvent = false;
        eventNames = {'Backward Motion', 'Not Backward Motion'};
        plotEvent(backwardEventStats, totalFrames, fps, ...
            'Backward Motion Distance', 'Backward Distance (microns)', ...
            eventNames, @event2box, states, str2colors('gr', -0.1));
        
        % Plot time vs. inter time.
        subplot(1,2,2);
        states(2) = struct( ...
            'fieldName', 'interTime', ...
            'height', [], ...
            'width', 1, ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'time';
        states(1).isInterEvent = false;
        eventNames = {'Backward Motion', 'Not Backward Motion'};
        plotEvent(backwardEventStats, totalFrames, fps, ...
            'Backward Motion Time', 'Backward Time (seconds)', ...
            eventNames, @event2box, states, str2colors('gr', -0.1));
        
    % No data.
    else
        xlabel('Time (seconds)');
        ylabel('Distance (microns)');
        title('Backward Motion Events');
    end
end



%% Display the paused motion.
% Display the paused motion histogram.
isPausedFrame = events2array(pausedFrames, totalFrames); % for your GUI
pausedStats4Plots = removePartialEvents(pausedEventStats, totalFrames);
if ~isempty(pausedStats4Plots)
    histData = histogram([pausedStats4Plots.distance]);
    figure;
    if ~isempty(pausedStats4Plots)
        plotHistogram(histData, 'Paused Motion Events Histogram', ...
            'Paused Event Distance (microns)', ...
            'Paused Event Distance', str2colors('k'));
    end
    
    % Display the paused motion plot.
    figure;
    hold on;
    if ~isempty(pausedStats4Plots)
        
        % Plot distance vs. inter distance.
        hold on;
        subplot(1,2,1);
        states(2) = struct( ...
            'fieldName', 'interDistance', ...
            'height', [], ...
            'width', 1, ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'distance';
        states(1).isInterEvent = false;
        eventNames = {'Paused Motion', 'Not Paused Motion'};
        plotEvent(pausedEventStats, totalFrames, fps, ...
            'Paused Motion Distance', 'Paused Distance (microns)', ...
            eventNames, @event2box, states, str2colors('gr', -0.1));
        
        % Plot time vs. inter time.
        subplot(1,2,2);
        states(2) = struct( ...
            'fieldName', 'interTime', ...
            'height', [], ...
            'width', 1, ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'time';
        states(1).isInterEvent = false;
        eventNames = {'Paused Motion', 'Not Paused Motion'};
        plotEvent(pausedEventStats, totalFrames, fps, ...
            'Paused Motion Time', 'Paused Time (seconds)', ...
            eventNames, @event2box, states, str2colors('gr', -0.1));
        
    % No data.
    else
        xlabel('Time (seconds)');
        ylabel('Distance (microns)');
        title('Paused Motion Events');
    end
end



%% Display the motion modes.
figure;
% hold on;
% forwardMotionFrames = find(motionModes == 1);
% plot((forwardMotionFrames - 1) / fps, 1, 'r');
% backwardMotionFrames = find(motionModes == -1);
% plot((backwardMotionFrames - 1) / fps, -1, 'b');
% pausedMotionFrames = find(motionModes == 0);
% plot((pausedMotionFrames - 1) / fps, 0, 'k');
plot((0:(length(motionModes) - 1)) / fps, motionModes);
xlabel('Time (seconds)');
ylabel('Mode');
ylim([-2 2]);
set(gca,'YTick', -1:1)
set(gca,'YTickLabel',{'Backward','Paused','Forward'})
title('Motion Events');



%% Display the coiled postures.
% Display the coiled posture histogram.
isCoilFrame = events2array(coilFrames, totalFrames); % for your GUI
coilStats4Plots = removePartialEvents(coilEventStats, totalFrames);
if ~isempty(coilStats4Plots)
    histData = histogram([coilStats4Plots.time]);
    figure;
    if ~isempty(coilStats4Plots)
        plotHistogram(histData, 'Coiled Posture Events Histogram', ...
            'Coil Event Time (seconds)', ...
            'Coil Event Time', str2colors('k'));
    end
    
    % Display the coiled motion plot.
    figure;
    hold on;
    if ~isempty(coilStats4Plots)
        
        % Plot inter distance.
        hold on;
        subplot(1,2,1);
        states = struct( ...
            'fieldName', 'interDistance', ...
            'height', [], ...
            'width', [], ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        eventNames = 'Not Coiled';
        plotEvent(coilEventStats, totalFrames, fps, ...
            'Not Coiled Distance', 'Not Coiled Distance (microns)', ...
            eventNames, @event2box, states, str2colors('r', -0.1), true);
        
        % Plot time vs. inter time.
        subplot(1,2,2);
        states(2) = struct( ...
            'fieldName', 'interTime', ...
            'height', [], ...
            'width', [], ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'time';
        states(1).isInterEvent = false;
        states(1).height = 1;
        states(2).height = 1;
        eventNames = {'Coiled', 'Not Coiled'};
        plotEvent(coilEventStats, totalFrames, fps, ...
            'Coiled Time', '', ...
            ... %'Coiled Time', 'Coiled Time (seconds)', ...
            eventNames, @event2box, states, str2colors('gr', -0.1));
        
    % No data.
    else
        xlabel('Time (seconds)');
        ylabel('Time (seconds)');
        title('Coiled Posture Events');
    end
end



%% Display the omega turns.
% Display the omega turns histogram.
isOmegaFrame = events2array(omegaFrames, totalFrames); % for your GUI
omegaStats4Plots = removePartialEvents(omegaFrames, totalFrames);
if ~isempty(omegaStats4Plots)
    histData = histogram([omegaStats4Plots.time]);
    figure;
    if ~isempty(omegaStats4Plots)
        plotHistogram(histData, 'Omega Turns Histogram', ...
            'Omega Turns Time (seconds)', ...
            'Omega Turns Time', str2colors('k'));
    end
    
    % Display the omega turns plot.
    figure;
    hold on;
    if ~isempty(omegaStats4Plots)
        
        % Plot inter distance.
        hold on;
        subplot(1,2,1);
        states = struct( ...
            'fieldName', 'interDistance', ...
            'height', [], ...
            'width', [], ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        eventNames = 'Not Omega Turn';
        plotEvent(omegaFrames, totalFrames, fps, ...
            'Not Omega Turn Distance', 'Not Omega Turn Distance (microns)', ...
            eventNames, @event2box, states, str2colors('r', -0.1), true);
        
        % Plot time vs. inter time.
        subplot(1,2,2);
        states(3) = struct( ...
            'fieldName', 'interTime', ...
            'height', [], ...
            'width', [], ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'time';
        states(1).isInterEvent = false;
        states(1).evalFieldNames = 'isVentral';
        states(1).evalFieldFuncs = @(x) not(x);
        states(2).fieldName = 'time';
        states(2).isInterEvent = false;
        states(2).evalFieldNames = 'isVentral';
        states(2).evalFieldFuncs = @(x) x;
        states(1).height = 1;
        states(2).height = 1;
        eventNames = {'Dorsal Omega Turn', 'Ventral Omega Turn', ...
            'Not Omega Turn'};
        plotEvent(omegaFrames, totalFrames, fps, ...
            'Omega Turn Time', 'Omega Turn Time (seconds)', ...
            eventNames, @event2box, states, str2colors('gbr', -0.1));
        
    % No data.
    else
        xlabel('Time (seconds)');
        ylabel('Time (seconds)');
        title('Omega Turns');
    end
end



%% Display the upsilon turns.
% Display the upsilon turns histogram.
isUpsilonFrame = events2array(upsilonFrames, totalFrames); % for your GUI
upsilonStats4Plots = removePartialEvents(upsilonFrames, totalFrames);
if ~isempty(upsilonStats4Plots)
    histData = histogram([upsilonStats4Plots.time]);
    figure;
    if ~isempty(upsilonStats4Plots)
        plotHistogram(histData, 'Upsilon Turns Histogram', ...
            'Upsilon Turns Time (seconds)', ...
            'Upsilon Turns Time', str2colors('k'));
    end
    
    % Display the upsilon turns plot.
    figure;
    hold on;
    if ~isempty(upsilonStats4Plots)
        
        % Plot inter distance.
        hold on;
        subplot(1,2,1);
        states = struct( ...
            'fieldName', 'interDistance', ...
            'height', [], ...
            'width', [], ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        eventNames = 'Not Upsilon Turn';
        plotEvent(upsilonFrames, totalFrames, fps, ...
            'Not Upsilon Turn Distance', 'Not Upsilon Turn Distance (microns)', ...
            eventNames, @event2box, states, str2colors('r', -0.1), true);
        
        % Plot time vs. inter time.
        subplot(1,2,2);
        states(3) = struct( ...
            'fieldName', 'interTime', ...
            'height', [], ...
            'width', [], ...
            'isInterEvent', true, ...
            'evalFieldNames', [], ...
            'evalFieldFuncs', []);
        states(1).fieldName = 'time';
        states(1).isInterEvent = false;
        states(1).evalFieldNames = 'isVentral';
        states(1).evalFieldFuncs = @(x) not(x);
        states(2).fieldName = 'time';
        states(2).isInterEvent = false;
        states(2).evalFieldNames = 'isVentral';
        states(2).evalFieldFuncs = @(x) x;
        states(1).height = 1;
        states(2).height = 1;
        eventNames = {'Dorsal Upsilon Turn', 'Ventral Upsilon Turn', ...
            'Not Upsilon Turn'};
        plotEvent(upsilonFrames, totalFrames, fps, ...
            'Upsilon Turn Time', 'Upsilon Turn Time (seconds)', ...
            eventNames, @event2box, states, str2colors('gbr', -0.1));
        
    % No data.
    else
        xlabel('Time (seconds)');
        ylabel('Time (seconds)');
        title('Upsilon Turns');
    end
end



%% Display the path range.
figure;
histData = histogram(pathRange);
plotHistogram(histData, 'Distance from Path Center', ...
    'Distance (microns)', 'Distance', str2colors('k'));



%% Display the path duration.
h = figure;
set(h, 'units', 'normalized', 'position', [0 0 1 1]);
hold on;
subplot(2,2,1);
plotWormPathTime(pathDuration.arena, pathDuration.worm, ...
    'Worm Duration', 'Location (microns)');
subplot(2,2,2);
plotWormPathTime(pathDuration.arena, pathDuration.head, ...
    'Head Duration', 'Location (microns)');
subplot(2,2,3);
plotWormPathTime(pathDuration.arena, pathDuration.midbody, ...
    'Midbody Duration', 'Location (microns)');
subplot(2,2,4);
plotWormPathTime(pathDuration.arena, pathDuration.tail, ...
    'Tail Duration', 'Location (microns)');



%% Make videos of the events.
% Go back to the original directory.
cd('..');

% Make the videos.
if isEventVideos
    
    % Construct the video file names.
    video = strrep(file.name, '_features.mat', '.avi');
    forwardVideo = strrep(file.name, '_features.mat', '_forward.avi');
    backwardVideo = strrep(file.name, '_features.mat', '_backward.avi');
    pausedVideo = strrep(file.name, '_features.mat', '_paused.avi');
    coilVideo = strrep(file.name, '_features.mat', '_coil.avi');
    omegaVideo = strrep(file.name, '_features.mat', '_omega.avi');
    upsilonVideo = strrep(file.name, '_features.mat', '_upsilon.avi');
    
    % Make the event videos.
    disp('Creating omega video ...');
    tic; events2video(omegaFrames, video, omegaVideo); toc;
    disp('Creating upsilon video ...');
    tic; events2video(upsilonFrames, video, upsilonVideo); toc;
    disp('Creating coil video ...');
    tic; events2video(coilFrames, video, coilVideo); toc;
    disp('Creating backward video ...');
    [~, orderI] = sort([backwardFrames.time]);
    tic; events2video(backwardFrames(orderI), video, backwardVideo); toc;
    disp('Creating paused video ...');
    [~, orderI] = sort([pausedFrames.time]);
    tic; events2video(pausedFrames(orderI), video, pausedVideo); toc;
    disp('Creating forward video ...');
    [~, orderI] = sort([forwardFrames.time]);
    tic; events2video(forwardFrames(orderI), video, forwardVideo); toc;
    disp('All videos done!');
end
