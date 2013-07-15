function plotWormStats(wormFile, worm2num, state, titleName, varargin)
%PLOTWORMSTATS Plot the worm statistics.
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT,
%                 ISSETS)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT,
%                 ISSETS, ISNORM)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT,
%                 ISSETS, ISNORM, ISSEM)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT,
%                 ISSETS, ISNORM, ISSEM, ISLINES)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT,
%                 ISSETS, ISNORM, ISSEM, ISLINES, ISVAR)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT,
%                 ISSETS, ISNORM, ISSEM, ISLINES, ISVAR, ISLEGEND)
%
%   PLOTWORMSTATS(WORMFILE, WORM2NUM, STATE, TITLENAME, ISTIMESERIES,
%                 SHOWFEATUREI, ISSHOWSIGN, ISSHOWMOTION, ISSHOWEVENT,
%                 ISSETS, ISNORM, ISSEM, ISLINES, ISVAR, ISLEGEND, ...
%                 ISVERBOSE)
%
%   Inputs:
%       wormFile     - the worm histogram or normalized time series file
%       worm2num     - the function to convert worm information to
%                      numerical data:
%
%                      [isUsed wormX tickX nameX labelX] =
%                      worm2num(info, state)
%
%                      Inputs:
%                      info   = the worm information (from wormFile)
%                      state  = the function state
%
%                      Outputs:
%                      isUsed = for each worm, are we using the data?
%                      wormX  = for a time series, the frames/seconds;
%                               otherwise, the x-axis numerical data
%                      tickX  = the x-axis ticks; if length(tickX) is 1,
%                               the tick is used to space the x-axis ticks;
%                               if empty, Matlab decides
%                      nameX  = the x-axis tick names; if length(tickX) is
%                               1, the name is prepended to the ticks;
%                               if empty, Matlab decides
%                      labelX = the label for the x-axis
%                      state  = the function state
%
%       titleName    - the title for the figure
%       isTimeSeries - are we plotting a time series?
%                      the default is yes (true)
%       showFeatureI - the indices of the features to show
%                      (see wormDisplayInfo)
%                      if empty, all feature are shown
%                      the default is all features (empty)
%       isShowSign   - are we plotting the signed data sub features?
%                      the default is no (false)
%       isShowMotion - are we plotting the motion data sub features?
%                      the default is no (false)
%       isShowEvent  - are we plotting the event data sub features?
%                      the default is no (false)
%       isSets       - are we plotting the data as individual sets?
%                      the default is no (false)
%       isNorm       - are we normalizing the data to [-1,1]?
%                      the default is yes (true)
%       isSEM        - are we plotting the standard error of the mean?
%                      if false, we plot the standard error
%                      if empty, we plot neither
%                      the default is yes (true)
%       isLines      - are we connecting the plots with lines?
%                      the default is no (false)
%       isVar        - are we plotting the intra vs. inter group variance?
%                      if false, we plot the data values
%                      the default is no (false)
%       isLegend     - are we showing a figure legend?
%                      the default is yes (true)
%       isVerbose    - verbose mode displays the progress;
%                      the default is yes (true)
%
% See also WORM2HISTOGRAM, ADDWORMHISTOGRAMS, WORM2NORMTIMES
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we plotting a time series?
isTimeSeries = false;
if ~isempty(varargin)
    isTimeSeries = varargin{1};
end

% Initialize the worm data information.
histInfo = wormDisplayInfo();
dataInfo = wormDataInfo();

% Which features are we showing?
showFeatureI = [];
if length(varargin) > 1
    showFeatureI = varargin{2};
end
if isempty(showFeatureI)
    isShow = true(length(dataInfo),1);
else
    isShow = false(length(dataInfo),1);
    isShow(showFeatureI) = true;
end

% Are we plotting the signed data sub features?
isShowSign = false;
if length(varargin) > 2
    isShowSign = varargin{3};
end

% Are we plotting the motion data sub features?
isShowMotion = false;
if length(varargin) > 3
    isShowMotion = varargin{4};
end

% Are we plotting the event data sub features?
isShowEvent = false;
if length(varargin) > 4
    isShowEvent = varargin{5};
end

% Are we plotting the data as individual sets?
isSets = false;
if length(varargin) > 5
    isSets = varargin{6};
end

% Are we normalizing the data to [-1,1]?
isNorm = true;
if length(varargin) > 6
    isNorm = varargin{7};
end

% Are we plotting the standard error of the mean?
isSEM = true;
if length(varargin) > 7
    isSEM = varargin{8};
end

% Are we connecting the plots with lines?
isLines = false;
if length(varargin) > 8
    isLines = varargin{9};
end

% Are we plotting the intra vs. inter group variance?
isVar = false;
if length(varargin) > 9
    isVar = varargin{10};
end

% Are we showing a figure legend?
isLegend = true;
if length(varargin) > 10
    isLegend = varargin{11};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 12
    isVerbose = varargin{13};
end

% Get the worm information.
wormInfo = [];
worm = [];
load(wormFile, 'wormInfo', 'worm');

% Convert the worm info to numerical data.
[isUsed wormX tickX nameX labelX] = worm2num(wormInfo, state);

% Initialize the locomotion modes.
motionNames = { ...
    'forward', ...
    'paused', ...
    'backward'};

% How many features do we have?
morphologyTotal = 0;
postureTotal = 0;
locomotionTotal = 0;
pathTotal = 0;
morphologyNum = [];
postureNum = [];
locomotionNum = [];
pathNum = [];
for i = 1:length(dataInfo)
    
    % Are we showing this feature?
    if ~isShow(i)
        continue;
    end
    
    % Is the data a time series?
    if isTimeSeries && ~dataInfo(i).isTimeSeries
        continue;
    end
    
    % Count the features.
    numFeatures = 0;
    field = dataInfo(i).field;
    isSigned = false;
    switch dataInfo(i).type
        
        % Count the simple features.
        case 's'
            if isShowSign
                isSigned = getStructField(histInfo, [field '.isSigned']);
            end
            if isSigned
                numFeatures = 4;
            else
                numFeatures = 1;
            end
            
        % Count the motion features.
        case 'm'
            if isShowSign
                isSigned = getStructField(histInfo, [field '.isSigned']);
            end
            if isShowMotion
                numFeatures = length(motionNames) + 1;
            else
                numFeatures = 1;
            end
            if isSigned
                numFeatures = numFeatures * 4;
            end
            
        % Count the event features.
        case 'e'
            
            % Count the event summary features.
            if isTimeSeries
                numFeatures = 2;
                if isShowSign && ~isempty(dataInfo(i).subFields.sign)
                    numFeatures = numFeatures + 2;
                end
            else
                numFeatures = length(dataInfo(i).subFields.summary);
            end
            
            % Count the event data features.
            subFields = dataInfo(i).subFields.data;
            for j = 1:length(subFields)
                if isShowSign
                    isSigned = getStructField(histInfo, ...
                        [field '.' subFields{j} '.isSigned']);
                end
                if isSigned
                    numFeatures = numFeatures + 4;
                else
                    numFeatures = numFeatures + 1;
                end
            end
    end
    
    % Categorize the features.
    switch dataInfo(i).category
        case 'm'
            morphologyTotal = morphologyTotal + numFeatures;
            morphologyNum{end + 1,1} = numFeatures;
        case 's'
            postureTotal = postureTotal + numFeatures;
            postureNum{end + 1,1} = numFeatures;
        case 'l'
            locomotionTotal = locomotionTotal + numFeatures;
            locomotionNum{end + 1,1} = numFeatures;
        case 'p'
            pathTotal = pathTotal + numFeatures;
            pathNum{end + 1,1} = numFeatures;
    end
end

% Initialize all the colors.
if ~isempty(showFeatureI)
    allColors = lines(morphologyTotal + postureTotal + ...
        locomotionTotal + pathTotal);
    allColorsI = 0;
end

% Initialize the morphology colors;
minShade = -0.5;
maxShade = 0.5;
if isempty(showFeatureI)
    morphologyAllColors = ...
        str2colors('g', linspace(minShade, maxShade, morphologyTotal));
else
    morphologyAllColors = ...
        allColors((allColorsI + 1):(allColorsI + morphologyTotal),:);
    allColorsI = allColorsI + morphologyTotal;
end
morphologyColors = cell(length(morphologyNum),1);
startI = 1;
for i = 1:length(morphologyColors)
    endI = startI + morphologyNum{i} - 1;
    morphologyColors{i} = morphologyAllColors(startI:endI,:);
    startI = endI + 1;
end

% Initialize the posture colors;
if isempty(showFeatureI)
    postureAllColors = ...
        str2colors('r', linspace(minShade, maxShade, postureTotal));
else
    postureAllColors = ...
        allColors((allColorsI + 1):(allColorsI + postureTotal),:);
    allColorsI = allColorsI + postureTotal;
end
postureColors = cell(length(postureNum),1);
startI = 1;
for i = 1:length(postureColors)
    endI = startI + postureNum{i} - 1;
    postureColors{i} = postureAllColors(startI:endI,:);
    startI = endI + 1;
end

% Initialize the locomotion colors;
if isempty(showFeatureI)
    locomotionAllColors = ...
        str2colors('b', linspace(minShade, maxShade, locomotionTotal));
else
    locomotionAllColors = ...
        allColors((allColorsI + 1):(allColorsI + locomotionTotal),:);
    allColorsI = allColorsI + locomotionTotal;
end
locomotionColors = cell(length(locomotionNum),1);
startI = 1;
for i = 1:length(locomotionColors)
    endI = startI + locomotionNum{i} - 1;
    locomotionColors{i} = locomotionAllColors(startI:endI,:);
    startI = endI + 1;
end

% Initialize the path colors;
if isempty(showFeatureI)
    pathAllColors = ...
        str2colors('k', linspace(minShade, maxShade, pathTotal));
else
    pathAllColors = ...
        allColors((allColorsI + 1):(allColorsI + pathTotal),:);
    allColorsI = allColorsI + pathTotal;
end
pathColors = cell(length(pathNum),1);
startI = 1;
for i = 1:length(pathColors)
    endI = startI + pathNum{i} - 1;
    pathColors{i} = pathAllColors(startI:endI,:);
    startI = endI + 1;
end

% Plot the data.
legends = {};
morphologyI = 1;
postureI = 1;
locomotionI = 1;
pathI = 1;
figure;
hold on;
for i = 1:length(dataInfo)
    
    % Are we using the data?
    if ~isShow(i)
        continue;
    end
    
    % Is the data a time series?
    if isTimeSeries && ~dataInfo(i).isTimeSeries
        continue;
    end
    
    % Get the data information.
    field = dataInfo(i).field;
    
    % Set the colors.
    colors = [];
    switch dataInfo(i).category
        case 'm'
            colors = morphologyColors{morphologyI};
            morphologyI = morphologyI + 1;
        case 's'
            colors = postureColors{postureI};
            postureI = postureI + 1;
        case 'l'
            colors = locomotionColors{locomotionI};
            locomotionI = locomotionI + 1;
        case 'p'
            colors = pathColors{pathI};
            pathI = pathI + 1;
    end
    
    % Plot the data.
    if isVerbose
        disp(['Plotting "' field '" ...']);
    end
    isSigned = false;
    switch dataInfo(i).type
        
        % Plot the simple features.
        case 's'
            if isShowSign
                isSigned = getStructField(histInfo, [field '.isSigned']);
            end
            newLegends = plotWormData(isUsed, wormX, worm, field, [], ...
                histInfo, isTimeSeries, isSigned, isSets, isNorm, ...
                isSEM, isLines, isVar, colors);
            legends((end + 1):(end + length(newLegends))) = newLegends;
            
        % Plot the motion features.
        case 'm'
            
            % Plot the simple feature.
            if isShowSign
                isSigned = getStructField(histInfo, [field '.isSigned']);
            end
            subField = [];
            if isTimeSeries
                subField = 'all';
            end
            newLegends = plotWormData(isUsed, wormX, worm, field, ...
                subField, histInfo, isTimeSeries, isSigned, isSets, ...
                isNorm, isSEM, isLines, isVar, colors);
            legends((end + 1):(end + length(newLegends))) = newLegends;
            
            % Plot the motion features.
            if isShowMotion
                for j = 1:length(motionNames)
                    colors = colors((length(newLegends) + 1):end,:);
                    newLegends = plotWormData(isUsed, wormX, worm, ...
                        field, motionNames{j}, histInfo, isTimeSeries, ...
                        isSigned, isSets, isNorm, isSEM, isLines, ...
                        isVar, colors);
                    legends((end + 1):(end + length(newLegends))) = ...
                        newLegends;
                end
            end
            
        % Plot the event features.
        case 'e'
          newLegends = plotEventData(isUsed, wormX, worm, dataInfo(i), ...
              histInfo, isTimeSeries, isShowSign, isShowEvent, isSets, ...
              isNorm, isSEM, isLines, isVar, colors);
          legends((end + 1):(end + length(newLegends))) = newLegends;
    end
end

% Label the axes for variability.
if isVar
    
    % Determine the group name.
    groupName = 'Group';
    if ~isempty(labelX)
        groupName = labelX;
    end
    
    % Label the y axis.
    if isTimeSeries
        ylabel(['Inter/Intra ' groupName ' Deviation']);
    else
        ylabel(['Inter/Intra ' groupName ' Deviation ' ...
            '(Deviation(Group Means)/Mean(Group Deviations)) ']);
    end
    
    % Remove the x-axis ticks.
    set(gca, 'XTick', []);
    set(gca, 'XTickLabel', []);
    
% Label the axes and ticks for data.
else
    
    % Set the x-axis ticks.
    if length(tickX) == 1
        ticks = get(gca, 'XTick');
        tickX = ticks(1):tickX:ticks(end);
        set(gca, 'XTick', tickX);
    end
    if ~isempty(tickX)
        set(gca, 'XTick', tickX);
    end
    
    % Label the x-axis ticks.
    if length(nameX) == 1
        ticks = get(gca, 'XTick', tickX);
        if iscell(nameX)
            nameX = nameX{1};
        end
        nameX = arrayfun(@(X) [nameX num2str(x)], ticks, 'UniformOutput', ...
            false);
        set(gca, 'XTick', tickX);
    end
    if ~isempty(nameX)
        set(gca, 'XTickLabel', nameX);
    end
    
    % Label the x-axis.
    if isempty(labelX)
        rotateticklabel(gca);
    else
        xlabel(labelX);
    end

    % Label the y-axis.
    if isNorm
        ylabel('Normalized Feature Values (no units)');
    else
        ylabel('Feature Values');
    end
end

% Label the figure.
title([titleName ' (N = ' num2str(sum(isUsed)) ')']);
if isLegend && ~isSets
    legend(legends, 'Location', 'BestOutside');
end
end



%% Plot event summary data.
function legends = plotEventData(isUsed, wormX, worm, dataInfo, ...
    histInfo, isTimeSeries, isShowSign, isShowEvent, isSets, isNorm, ...
    isSEM, isLines, isVar, colors)

% Get the data information.
field = dataInfo.field;
subFields = dataInfo.subFields;
legends = {};

% Plot the event time series summary features.
if isTimeSeries
    isSigned = isShowSign && ~isempty(subFields.sign);
    newLegends = plotWormData(isUsed, wormX, worm, field, 'start', ...
        histInfo, isTimeSeries, isSigned, isSets, isNorm, isSEM, ...
        isLines, isVar, colors, false);
    legends((end + 1):(end + length(newLegends))) = newLegends;
    colors = colors((length(newLegends) + 1):end,:);
    
% Plot the event statistics summary features.
else
    summaryFields = subFields.summary;
    for j = 1:length(summaryFields)
        summaryField = [field '.' summaryFields{j}];
        data = getStructField(worm, [summaryField '.data']);
        plotData(wormX, data, isTimeSeries, 1, isSets, isNorm, ...
            isSEM, isLines, isVar, colors);
        newLegends = {getStructField(histInfo, [summaryField '.name'])};
        legends((end + 1):(end + length(newLegends))) = newLegends;
        colors = colors((length(newLegends) + 1):end,:);
    end
end

% Plot the event data features.
if isShowEvent
    dataFields = subFields.data;
    for j = 1:length(dataFields)
        dataField = [field '.' dataFields{j}];
        if isShowSign
            isSigned = getStructField(histInfo, [dataField '.isSigned']);
        end
        newLegends = plotWormData(isUsed, wormX, worm, dataField, [], ...
            histInfo, isTimeSeries, isSigned, isSets, isNorm, isSEM, ...
            isLines, isVar, colors);
        legends((end + 1):(end + length(newLegends))) = newLegends;
        colors = colors((length(newLegends) + 1):end,:);
    end
end
end



%% Plot worm data.
% varargin = isAbs
function legends = plotWormData(isUsed, wormX, worm, field, subField, ...
    info, isTimeSeries, isSigned, isSets, isNorm, isSEM, isLines, ...
    isVar, colors, varargin)

% If signed, are we plotting the absolute value?
isAbs = true;
if ~isempty(varargin)
    isAbs = varargin{1};
end

% Get the data.
if isTimeSeries
    data = getStructField(worm, [field '.' subField]);
else
    if isempty(subField)
        data = getStructField(worm, [field '.histogram.data.mean']);
    else
        data = getStructField(worm, ...
            [field '.' subField '.histogram.data.mean']);
    end
end
info = getStructField(info, field);

% Plot data.
xData = wormX;
legends = {};
for i = 1:length(data)
    
    % Compute the time series data.
    minLength = 1;
    if isTimeSeries
        minLength = min(cellfun(@(x) length(x), data(i).all(isUsed)));
        timeX = wormX;
        if ~isSets
            timeX = nanmean(timeX,1);
        end
        xData = nan(size(timeX, 1), minLength);
        for j = 1:size(xData, 1)
            xData(j,:) = linspace(0, (minLength - 1) * timeX(j), minLength);
        end
    end
    
    % Plot the signed data.
    if isSigned
        if isAbs
            legends((end + 1):(end + 4)) = {
                info(i).name
                ['Absolute ' info(i).name]
                ['Positive ' info(i).name]
                ['Negative ' info(i).name]};
        else
            legends((end + 1):(end + 3)) = {
                info(i).name
                ['Positive ' info(i).name]
                ['Negative ' info(i).name]};
        end
        plotSignedData(isUsed, xData, data(i), isTimeSeries, minLength, ...
            isSets, isNorm, isSEM, isLines, isVar, colors, isAbs);
        
    % Plot the data.
    else
        legends(end + 1) = {info(i).name};
        plotData(xData, data(i).all(isUsed), isTimeSeries, minLength, ...
            isSets, isNorm, isSEM, isLines, isVar, colors);
    end
end
end



%% Plot signed data.
% varargin = isAbs
function plotSignedData(isUsed, xData, data, isTimeSeries, normLength, ...
    isSets, isNorm, isSEM, isLines, isVar, colors, varargin)

% Are we plotting the absolute value?
isAbs = true;
if ~isempty(varargin)
    isAbs = varargin{1};
end

% Plot the data.
colorI = 1;
plotData(xData, data.all(isUsed), isTimeSeries, normLength, isSets, ...
    isNorm, isSEM, isLines, isVar, colors(colorI,:));
colorI = colorI + 1;
if isAbs
    plotData(xData, data.abs(isUsed), isTimeSeries, normLength, isSets, ...
        isNorm, isSEM, isLines, isVar, colors(colorI,:));
    colorI = colorI + 1;
end
plotData(xData, data.pos(isUsed), isTimeSeries, normLength, isSets, ...
    isNorm, isSEM, isLines, isVar, colors(colorI,:));
colorI = colorI + 1;
plotData(xData, data.neg(isUsed), isTimeSeries, normLength, isSets, ...
    isNorm, isSEM, isLines, isVar, colors(colorI,:));
end



%% Plot data.
function plotData(xData, data, isTimeSeries, normLength, isSets, ...
    isNorm, isSEM, isLines, isVar, color)

% Organize the time series data.
yData = nan(length(data), normLength);
if isTimeSeries
    for i = 1:size(yData, 1)
        yData(i,:) = data{i}(1:normLength);
    end
    
% Organize the data.
else
    yData = data;
end

% Compute the variability, mean, and/or error of the sets.
yError = [];
if isVar || ~isSets
    
    % Compute the intra vs. inter group variability of the time series.
    if isTimeSeries
        if isVar
            
            % Compute the inter (y) and intra (x) group variability.
            if isSEM
                xData = nanmean(nanstd(yData, 0, 2)) / sqrt(size(yData, 2));
                yData = nanmean(nanstd(yData, 0, 1)) / sqrt(size(yData, 1));
            else
                xData = nanmean(nanstd(yData, 0, 2));
                yData = nanmean(nanstd(yData, 0, 1));
            end
            
            % Compute the inter (y) vs. intra (x) group variability.
            yData = yData ./ xData;
            xData = 1;
            
        % Compute the mean and error of the time series.
        else
            
            % Compute the error of the time series.
            if ~isempty(isSEM)
                if size(yData, 1) > 1
                    yError = nanstd(yData);
                    if isSEM
                        yError = yError / sqrt(size(yData, 1));
                    end
                end
            end
            
            % Compute the mean of the time series.
            yData = nanmean(yData, 1);
        end
        
    % Compute the variability, mean, and/or error of the data.
    else
        
        % Compute the intra vs. inter group variability of the data.
        [values, ~, dataI] = unique(xData);
        xData = [];
        xData(1,:) = values;
        newYData = nan(1, length(xData));
        yError = [];
        if isVar
            
            % Compute the inter (y) and intra (x) group variability.
            for i = 1:length(newYData)
                newData = yData(dataI == i);
                if isSEM
                    xData(1,i) = nanstd(newData) / sqrt(length(newData));
                else
                    xData(1,i) = nanstd(newData);
                end
                newYData(1,i) = nanmean(newData);
            end
            xData = nanmean(xData);
            if isSEM
                newYData = nanstd(newYData) / sqrt(size(newYData, 2));
            else
                newYData = nanstd(newYData);
            end
            
            % Compute the inter (y) vs. intra (x) group variability.
            newYData = newYData ./ xData;
            xData = 1;
            
        % Compute the mean and error of the data.
        elseif isempty(isSEM)
            for i = 1:length(newYData)
                newYData(1,i) = nanmean(yData(dataI == i));
            end
            
        % Compute the mean and error of the data.
        else
            yError = nan(1, length(xData));
            if isSEM
                for i = 1:length(newYData)
                    newData = yData(dataI == i);
                    newYData(1,i) = nanmean(newData);
                    yError(1,i) = nanstd(newData) / sqrt(length(newData));
                end
            else
                for i = 1:length(newYData)
                    newData = yData(dataI == i);
                    newYData(1,i) = nanmean(newData);
                    yError(1,i) = nanstd(newData);
                end
            end
        end
        yData = newYData;
    end
end

% Normalize the data.
if isNorm
    if isVar
        if 0
        [xData yData] = normalizeVar(xData, yData);
        end
    else
        [yData yError] = normalize(yData, yError);
    end
end

% Plot the data.
color = color(1,:);
if isempty(yError)
    if isLines
        plot(xData', yData', 'Color', color, 'Marker', '.');
    else
        plot(xData', yData', 'Color', color, 'Marker', '.', ...
            'LineStyle', 'none');
    end
    
% Plot the data with error bars.
else
    if isLines
        errorbar(xData', yData', yError', 'Color', color, 'Marker', '.');
    else
        errorbar(xData', yData', yError', 'Color', color, ...
            'Marker', '.', 'LineStyle', 'none');
    end
end
end



%% Normalize data to [-1,1].
function [data dataError] = normalize(data, dataError)

% Center the data at 0.
dataSign = sign(data);
minData = min(abs(data(:)));
dataCenter = zeros(size(data));
dataCenter(:,:) = minData;
dataCenter = dataSign .* dataCenter;
data = data - dataCenter;

% Scale the data to 1.
maxData = max(abs(data(:)));
data = data ./ maxData;

% Scale the error to the data.
dataError = dataError ./ maxData;
end
