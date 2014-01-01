function bends = testBendFunc(verbose)
%TESTBENDFUNC Test worm2func as well as the values used in wormBends.
%
%   This function serves as an example and a test.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

state = [];
data = worm2func(@bendFunc, state, 'segNormInfo.mat', [], [], 0, 0, false);

bendData = [];
for i = 1:length(data)
    bendData = cat(1, bendData, data{i});
end

bends = struct( ...
    'nose', [bendData.noseBends], ...
    'head', [bendData.headBends], ...
    'middle', [bendData.midBends], ...
    'tail', [bendData.tailBends]);

if (verbose)
    figure;
    hold on;
    plot(bends.nose, 'k');
    figure;
    hold on;
    plot(bends.head, 'r');
    plot(bends.middle, 'g');
    plot(bends.tail, 'b');
end
end

% Compute the bend angles at the nose, head, midbody, and tail.
function [bends state] = bendFunc(dataInfo, state)

% Empirically I've found the following values achieve good signal.
noseSkeletonPoints = fliplr(1:4);
headSkeletonPoints = fliplr(5:8);
headBendPoints = 6:10;
midBendPoints = 23:27;
tailBendPoints = 40:44;

% Only use the data we need.
data = dataInfo.data;
noseSkeletons = data{4}(noseSkeletonPoints,:,:);
headSkeletons = data{4}(headSkeletonPoints,:,:);
headBends = mean(data{5}(headBendPoints,:), 1);
midBends = mean(data{5}(midBendPoints,:), 1);
tailBends = mean(data{5}(tailBendPoints,:), 1);

% Interpolate the missing data.
%interpType = 'cubic';
%interpType = 'spline';
interpType = 'linear';
isData = data{1} == 's';
dataI = find(isData);
interpI = find(~isData);
if ~isempty(interpI) && length(dataI) > 1
    for i = 1:length(noseSkeletonPoints)
        noseSkeletons(i,1,interpI) = ...
            interp1(dataI, squeeze(noseSkeletons(i,1,dataI)), interpI, ...
            interpType, NaN);
        noseSkeletons(i,2,interpI) = ...
            interp1(dataI, squeeze(noseSkeletons(i,2,dataI)), interpI, ...
            interpType, NaN);
    end
    for i = 1:length(headSkeletonPoints)
        headSkeletons(i,1,interpI) = ...
            interp1(dataI, squeeze(headSkeletons(i,1,dataI)), interpI, ...
            interpType, NaN);
        headSkeletons(i,2,interpI) = ...
            interp1(dataI, squeeze(headSkeletons(i,2,dataI)), interpI, ...
            interpType, NaN);
    end
    headBends(interpI) = ...
        interp1(dataI, headBends(dataI), interpI, interpType, NaN);
    midBends(interpI) = ...
        interp1(dataI, midBends(dataI), interpI, interpType, NaN);
    tailBends(interpI) = ...
        interp1(dataI, tailBends(dataI), interpI, interpType, NaN);
end

% Compute the nose bend angles.
noseDiffs = diff(noseSkeletons, 1, 1);
if size(noseDiffs, 1) > 1
    noseDiffs = mean(noseDiffs, 1);
end
noseAngles = squeeze(atan2(noseDiffs(:,2,:), noseDiffs(:,1,:)));
headDiffs = diff(headSkeletons, 1, 1);
if size(headDiffs, 1) > 1
    headDiffs = mean(headDiffs, 1);
end
headAngles = squeeze(atan2(headDiffs(:,2,:), headDiffs(:,1,:)));
noseBends = (noseAngles - headAngles)';
wrap = noseBends > pi;
noseBends(wrap) = noseBends(wrap) - 2 * pi;
wrap = noseBends < -pi;
noseBends(wrap) = noseBends(wrap) + 2 * pi;
noseBends = noseBends * 180 / pi;

% Show the data.
if 0
for i = 1:50:size(data{4},3)
    figure;
    hold on;
    plot(squeeze(data{4}(:,1,i)), squeeze(data{4}(:,2,i)), 'k.');
    plot(squeeze(noseSkeletons(:,1,i)), squeeze(noseSkeletons(:,2,i)), ...
        'r.');
    plot(squeeze(headSkeletons(:,1,i)), squeeze(headSkeletons(:,2,i)), ...
        'g.');
    axis image;
end
end

% Organize the data.
bends = struct( ...
    'noseBends', noseBends, ...
    'headBends', headBends, ...
    'midBends', midBends, ...
    'tailBends', tailBends);
end
