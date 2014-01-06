function [headTipVelocity, headVelocity, midbodyVelocity, tailVelocity,...
    tailTipVelocity, pathCurvature] = multiScaleWormProcess(segDatDir, NOOFPOINTS, ventralMode)

% MULTISCALEWORMPROCESS This function will run multiScaleWorm function as a
% part of the Worm Analysis Toolbox.  MultiScaleWorm calculates worm
% velocity for different time scales.
%
% multiScaleWorm was written by Eviatar Yemini at MRC Laboratory of
% Molecular Biology
%
% Input:
%   segDatDir - segmentation data directory, the location of other files
%   will be determined from this path
%   NOOFPOINTS - a constant signifying how many sample points were chosen
%   for the worm
%   ventralMode - a flag indicating ventralSide: 
%                   unknown = 0, anticlockwise = 1, clockwise = 2
%
% Output:
%   velocityBody - velocity of the body of the worm (from 1/3rd to the end)
%   velocityHead - velocity for the head of the worm (tip of the head to 1/3 of the worm)
%   headMoveDirection - directiom angle for the head
%   bodyMoveDirection - direction angle for the body
%   movementMode - mode of the worm, -1 for moving backward, 0 for pausing and 1
%   for moving forward
%   -
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Define segmentation file locations
segWormInfo = fullfile(segDatDir, 'segInfo.mat');
normWormInfo = fullfile(segDatDir, 'normalized', 'segNormInfo.mat');
% Example of segmentation file locations
% segWormInfo = 'c:\example\db_test\.data\mec-4 (u253) off food x_2010_04_21__17_19_20__1_seg\segInfo.mat';
% normWormInfo = 'c:\example\db_test\.data\mec-4 (u253) off food x_2010_04_21__17_19_20__1_seg\normalized\segNormInfo.mat';

% Load experiment segmentation info
fps = [];
globalFrameCounter = 0;
load(segWormInfo);
load(normWormInfo);
% Define constants
if exist('SAMPLES', 'var')
    samples = SAMPLES;
end

pathCurvatureData = nan(1,globalFrameCounter);
headSpeed = nan(1,globalFrameCounter);
tailSpeed = nan(1,globalFrameCounter);
midbodySpeed = nan(1,globalFrameCounter);
headVelDirection = nan(1,globalFrameCounter);
tailVelDirection = nan(1,globalFrameCounter);
midbodyVelDirection = nan(1,globalFrameCounter);

% foraging velocity
headTipSpeed = nan(1,globalFrameCounter);
tailTipSpeed = nan(1,globalFrameCounter);
headTipVelDirection = nan(1,globalFrameCounter);
tailTipVelDirection = nan(1,globalFrameCounter);

% Define numer of samples, its in curly brackets means it will return mean
% velocity value.
noOfSamples = {1:round(1/6*NOOFPOINTS),...
    round(1/6*NOOFPOINTS)+1:round(5/6*NOOFPOINTS),...
    round(5/6*NOOFPOINTS)+1:NOOFPOINTS,...
    1:4,...
    46:49};

% Check is the experiment is not shorter than the time scale of interest
if globalFrameCounter > 3/4*fps
    % Calculate the multiScaleWorm data
    wormFile = normWormInfo;
    startFrame = [];
    endFrame = [];
    useFrames = [];
    type = 'bf';
    scales = [1/4, 3/4];
    isSparse = 0;
    isAtT1 = 1;
    isNoisy = 0;
    htDirMode = 4;
    isAbsDir = 0;
    
    [multiScaleData, ~, ~, ~, ~] = multiScaleWorm(wormFile, startFrame, ...
        endFrame, noOfSamples, useFrames, type, scales, isSparse, ...
        isAtT1, isNoisy, htDirMode, isAbsDir, ventralMode);
    
    headSpeed           = multiScaleData{7}{2}(1,:);
    tailSpeed           = multiScaleData{7}{2}(3,:);
    midbodySpeed        = multiScaleData{7}{2}(2,:);
    headVelDirection    = multiScaleData{8}{2}(1,:);
    tailVelDirection    = multiScaleData{8}{2}(3,:);
    midbodyVelDirection = multiScaleData{8}{2}(2,:);
    
    % foraging velocity
    headTipSpeed        = multiScaleData{7}{1}(4,:);
    tailTipSpeed        = multiScaleData{7}{1}(5,:);
    headTipVelDirection = multiScaleData{8}{1}(4,:);
    tailTipVelDirection = multiScaleData{8}{1}(5,:);
end

% Calculate direction and path curvature
if globalFrameCounter > 0.5*fps
    % Compute worm direction and its path curvature
    useSamples = {1:NOOFPOINTS};
    %[direction, pathCurvature] = wormDirection(normWormInfo, useSamples, 'i', 0.5);
    %[~, pathCurvature] = wormDirection(normWormInfo, useSamples, 'i', 0.5);
    pathCurvature = wormPathCurvature(normWormInfo, useSamples, 'i', 0.5, ventralMode);
    
    pathCurvatureData = pathCurvature{1};
end

% The worm velocity.
headTipVelocity = struct( ...
    'speed', headTipSpeed, ...
    'direction', headTipVelDirection);
headVelocity = struct( ...
    'speed', headSpeed, ...
    'direction', headVelDirection);
midbodyVelocity = struct( ...
    'speed', midbodySpeed, ...
    'direction', midbodyVelDirection);
tailVelocity = struct( ...
    'speed', tailSpeed, ...
    'direction', tailVelDirection);
tailTipVelocity = struct( ...
    'speed', tailTipSpeed, ...
    'direction', tailTipVelDirection);

pathCurvature = pathCurvatureData;