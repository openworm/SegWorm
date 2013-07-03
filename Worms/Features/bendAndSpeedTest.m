% Initialize our variables.
isMakingVideos = true;
wormFile = 'segNormInfo.mat';
useSamples = {1:8,9:41,42:49};
type = 'bf';
scales = .75;
isSparse = false;
offMode = 1;
isNoisy = false;
htDirMode = 3;
isAbsDir = false;

% Find the test directories.
testDir = dir('test *');

% Go through the test directories.
for i = fliplr(1:length(testDir))
    
    %% Go into the test directory.
    if ~testDir(i).isdir
        continue;
    end
    disp(['Entering "' testDir(i).name '" ...']);
    cd(testDir(i).name);
    

    
    %% Compute the mean worm length.
    meanWormLength = 1000;
    features = dir('*_features.mat');
    if isempty(features)
        warning('bendAndSpeedTest:NoFeatureFile', ...
            'cannot find the features file');
    else
        featureData = [];
        load(features(1).name, 'featureData');
        if isempty(featureData)
            warning('bendAndSpeedTest:NoFeatures', ...
                'the features file has an unknown format');
        else
            meanWormLength = nanmean(featureData.wormLength);
            clear('featureData');
        end
    end
    
    
    
    %% Go into the data directory.
    if ~exist('normalized', 'dir')
        cd('..');
        continue;
    end
    cd('normalized');
    
    
    
    %% Compute the speed.
    disp('Computing the speed ...');
    tic;
    [diffData, ~, ~, fps, ~] = multiScaleWorm(wormFile, [], [], ...
        useSamples, [], type, scales, isSparse, offMode, isNoisy, ...
        htDirMode, isAbsDir);
    toc;
    speeds = struct(...
        'head', diffData{7}{1}(1,:), ...
        'midbody', diffData{7}{1}(2,:),...
        'tail', diffData{7}{1}(3,:));
    

    % Initialize the requisite data.
    speed = speeds.midbody;
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

    % Compute the forward statistics.
    [forwardFrames forwardStats] = events2stats(forwardFrames, fps, ...
        distance, 'distance', 'interDistance');
%     
%     % Reorganize everything for the feature file.
%     forwardFrames = forwardEventStats;
%     forwardFrequency = [];
%     forwardRatios = [];
%     if ~isempty(forwardStats)
%         forwardFrequency = forwardStats.frequency;
%         forwardRatios = forwardStats.ratio;
%     end
%     forward = struct( ...
%         'frames', forwardFrames, ...
%         'frequency', forwardFrequency, ...
%         'ratio', forwardRatios);
    
    
    
    %% Find the backward motion.
    maxBackwardSpeed = -wormSpeedThr;
    minBackwardDistance = wormDistanceThr;
    backwardFrames = findEvent(speed, [], maxBackwardSpeed, true, ...
        wormEventFramesThr, [], false, ...
        minBackwardDistance, [], true, distance, wormEventMinInterFramesThr);
    
    % Compute the backward statistics.
    [backwardFrames backwardStats] = events2stats(backwardFrames, fps, ...
        distance, 'distance', 'interDistance');
%     
%     % Reorganize everything for the feature file.
%     backwardFrames = backwardEventStats;
%     backwardFrequency = [];
%     backwardRatios = [];
%     if ~isempty(backwardStats)
%         backwardFrequency = backwardStats.frequency;
%         backwardRatios = backwardStats.ratio;
%     end
%     backward = struct( ...
%         'frames', backwardFrames, ...
%         'frequency', backwardFrequency, ...
%         'ratio', backwardRatios);
    
    
    
    %% Find the paused motion.
    wormPauseThr = meanWormLength * 0.025; % 2.5 percent of its length
    minPausedSpeed = -wormPauseThr;
    maxPausedSpeed = wormPauseThr;
    pausedFrames = findEvent(speed, minPausedSpeed, maxPausedSpeed, true, ...
        wormEventFramesThr, [], false, ...
        [], [], true, distance, wormEventMinInterFramesThr);
    
    % Compute the paused statistics.
    [pausedFrames pausedStats] = events2stats(pausedFrames, fps, ...
        distance, 'distance', 'interDistance');
%     
%     % Reorganize everything for the feature file.
%     pausedFrames = pausedEventStats;
%     pausedFrequency = [];
%     pausedRatios = [];
%     if ~isempty(pausedStats)
%         pausedFrequency = pausedStats.frequency;
%         pausedRatios = pausedStats.ratio;
%     end
%     paused = struct( ...
%         'frames', pausedFrames, ...
%         'frequency', pausedFrequency, ...
%         'ratio', pausedRatios);



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
    disp('Computing the bends ...');
    tic;
    bends = wormBends(wormFile, motionModes);
    toc;
    

    
    %% Find the foraging events.
    disp('Computing the events ...');
%     wormEventMinFramesThr = .5 * fps;
%     foragingAmp = bends.foraging.amplitude;
%     noForagingFrames = findEvent(foragingAmp, [], 5, false, ...
%         wormEventMinFramesThr, [], false);
%     foragingFrames = findEvent(foragingAmp, 5, [], true, ...
%         [], [], false, [], [], false, [], wormEventMinFramesThr, [], false);
% 
%     % Compute the foraging statistics.
%     [foragingFrames foragingStats] = events2stats(foragingFrames, fps, ...
%         distance, 'distance', 'interDistance');
%     [noForagingFrames noForagingStats] = events2stats(noForagingFrames, fps, ...
%         distance, 'distance', 'interDistance');

    

    %% Find the bending events.
    wormEventMinFramesThr = .75 * fps;
    noBends = isnan(bends.midbody.frequency) & motionModes == 0;
    absBends = abs(bends.midbody.frequency);
    meanBend = nanmean(absBends);
    bendsFrames = findEvent(~noBends, 0, [], false, ...
        wormEventMinFramesThr, [], false);
    noBendsFrames = findEvent(noBends, 0, [], false, ...
        wormEventMinFramesThr, [], false);
    slowBendsFrames = findEvent(absBends, 0, meanBend, false, ...
        [], [], false, [], [], false, [], wormEventMinFramesThr, [], false);
    fastBendsFrames = findEvent(absBends, meanBend, [], true, ...
        [], [], false, [], [], false, [], wormEventMinFramesThr, [], false);
    
    % Compute the bending statistics.
    [bendsFrames bendsStats] = events2stats(bendsFrames, fps, ...
        distance, 'distance', 'interDistance');
    [noBendsFrames noBendsStats] = events2stats(noBendsFrames, fps, ...
        distance, 'distance', 'interDistance');
    [slowBendsFrames smallBendsStats] = events2stats(slowBendsFrames, fps, ...
        distance, 'distance', 'interDistance');
    [fastBendsFrames bigBendsStats] = events2stats(fastBendsFrames, fps, ...
        distance, 'distance', 'interDistance');


    
    %% Go back to the video directory.
    cd('..');
    
    
    
    %% Save the data.
    save('bendSpeedEventData.mat', ...
        'bends', ...
        'speeds', ...
        'motionModes', ...
        ... %'foragingFrames', ...
        ... %'foragingStats', ...
        ... %'noForagingFrames', ...
        'bendsFrames', ...
        'bendsStats', ...
        'fastBendsFrames', ...
        'slowBendsFrames', ...
        'noBendsFrames', ...
        'forwardFrames', ...
        'forwardStats', ...
        'backwardFrames', ...
        'backwardStats', ...
        'pausedFrames', ...
        'pausedStats');
    
    % Make the event videos.
    if isMakingVideos
        
        % Construct the video file names.
        file = dir('*_video.avi');
        if isempty(file)
            warning('bendAndSpeedTest:NoFeatureFile', ...
                'cannot find the video file');
            continue;
        end
        video = file(1).name;
        forwardVideo = strrep(video, '_video.avi', '_forward.avi');
        backwardVideo = strrep(video, '_video.avi', '_backward.avi');
        pausedVideo = strrep(video, '_video.avi', '_paused.avi');
        foragingVideo = strrep(video, '_video.avi', '_foraging.avi');
        noForagingVideo = strrep(video, '_video.avi', '_noForaging.avi');
        bigBendsVideo = strrep(video, '_video.avi', '_fastBends.avi');
        smallBendsVideo = strrep(video, '_video.avi', '_slowBends.avi');
        noBendsVideo = strrep(video, '_video.avi', '_noBends.avi');
        
        % Make the event videos.
        if ~isempty(backwardFrames)
            disp('Creating backward video ...');
            [~, orderI] = sort([backwardFrames.time], 'descend');
            tic;events2video(backwardFrames(orderI), video, backwardVideo, true); toc;
        end
        if ~isempty(pausedFrames)
            disp('Creating paused video ...');
            [~, orderI] = sort([pausedFrames.time], 'descend');
            tic; events2video(pausedFrames(orderI), video, pausedVideo, true); toc;
        end
        if ~isempty(forwardFrames)
            disp('Creating forward video ...');
            [~, orderI] = sort([forwardFrames.time], 'descend');
            tic; events2video(forwardFrames(orderI), video, forwardVideo, true); toc;
        end
%         if ~isempty(foragingFrames)
%             disp('Creating foraging video ...');
%             [~, orderI] = sort([foragingFrames.time], 'descend');
%             tic; events2video(foragingFrames(orderI), video, foragingVideo, true); toc;
%         end
%         if ~isempty(noForagingFrames)
%             disp('Creating no foraging video ...');
%             [~, orderI] = sort([noForagingFrames.time], 'descend');
%             tic; events2video(noForagingFrames(orderI), video, noForagingVideo, true); toc;
%         end
        if ~isempty(fastBendsFrames)
            disp('Creating big bends video ...');
            [~, orderI] = sort([fastBendsFrames.time], 'descend');
            tic; events2video(fastBendsFrames(orderI), video, bigBendsVideo, true); toc;
        end
        if ~isempty(slowBendsFrames)
            disp('Creating small bends video ...');
            [~, orderI] = sort([slowBendsFrames.time], 'descend');
            tic; events2video(slowBendsFrames(orderI), video, smallBendsVideo, true); toc;
        end
        if ~isempty(noBendsFrames)
            disp('Creating no bends video ...');
            [~, orderI] = sort([noBendsFrames.time], 'descend');
            tic; events2video(noBendsFrames(orderI), video, noBendsVideo, true); toc;
        end
            disp('All videos done!');
    end
    
    % Go back to the top level directory.
    cd('..');
end
