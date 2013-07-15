function plotHistogram(data, titleName, xAxisName, yAxisPrefix, ...
    dataNames, histColors, varargin)
%PLOTHISTOGRAM Plot a histogram(s) of data.
%
%   PLOTHISTOGRAM(DATA, TITLENAME, XAXISNAME, YAXISPREFIX, DATANAMES,
%                 HISTCOLORS)
%
%   PLOTHISTOGRAM(DATA, TITLENAME, XAXISNAME, YAXISPREFIX, DATANAMES,
%                 HISTCOLORS, STATCOLORS, HISTMODE, STATMODE, MEANMODE,
%                 SEMMODE, LOGMODE, DOWNSAMPLE)
%
%   Inputs:
%       data         - the data vector (see HISTOGRAM) for the histogram(s)
%       titleName    - the title for the figure
%       xAxisName    - the name to label the x axis
%       yAxisPrefix  - the pefix for the y-axis label
%       dataNames    - the name(s) to label the data value(s)
%       histColors   - the color(s) for the histogram(s)
%       statColors   - the color(s) for the summary statistics;
%                      if empty, the summary statistics are not shown
%       histMode     - the histogram(s) display mode:
%
%                      1 = display the histogram(s) as a filled polygon(s);
%                          the default mode is 1
%                      2 = display the histogram(s) as a line(s)
%                      3 = display the histogram(s) as a series of bars
%
%       statMode     - the summary statistics display mode:
%
%                      0 = don't display the statistics in the legend
%                      1 = display the statistics in the legend;
%                          the default mode is 1 when statColors is empty
%                      2 = display the N in the legend
%                          the default mode is 2 when statColors is defined
%                      3 = display the mean and SEM in the legend
%
%       meanMode     - the mean value histogram(s) display mode:
%
%                      0 = display the standard histogram(s);
%                          the default mode is 0
%                      1 = display the positive and negative value
%                          statistics over the standard histogram(s)
%                      2 = display the absolute value
%                          statistics over the standard histogram(s)
%                      3 = display the absolute value histogram(s)
%
%       semMode     - the SEM value histogram(s) display mode:
%
%                      0 = display the SEM for the data sets if possible;
%                          if only one data set exists, show its SEM;
%                          the default mode is 0
%                      1 = display the SEM for the data sets
%                      2 = display the SEM for all the data
%                      3 = display the SD for the data sets
%                      4 = display the SD for all the data
%
%       logMode      - how are we plotting the log of the histogram(s)?
%                      the default is not to plot the log (empty)
%
%       downSample   - how are we downsampling the histogram(s)?
%                      the default is not to downsample (empty)
%
% See also HISTOGRAM, LOGHISTOGRAM, DOWNSAMPLEHISTOGRAM
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are any of the histograms empty?
empty = true;
if ~isempty(data)
    empty = arrayfun(@(x) (isempty(x.bins) || isnan(x.bins(1))), data);
end

% Is there any data?
if all(empty)
    
    % There is no data to plot.
    warning('plotHistogram:NoData', 'There is no data to plot');
    
    % Label the figure.
    title(titleName);
    xlabel(xAxisName);
    ylabel([yAxisPrefix 'Probability (\SigmaP(x) = 1)']);
    set(gca, 'XTick', []);
    set(gca, 'XTickLabel', []);
    set(gca, 'YTick', []);
    set(gca, 'YTickLabel', []);
    set(gca, 'Box', 'on');
    set(zoom(gcf), 'Motion', 'horizontal', 'Enable', 'on');

    % Done.
    return;
end

% Determine the color(s) for the summary statistics.
statColors = [];
if ~isempty(varargin)
    statColors = varargin{1};
end

% How are we displaying the histogram(s)?
histMode = 1;
if length(varargin) > 1
    histMode = varargin{2};
end

% How are we displaying the summary statistics?
if isempty(statColors)
    statMode = 1;
else
    statMode = 2;
end
if length(varargin) > 2
    statMode = varargin{3};
end

% How are we displaying the mean statistics?
meanMode = 0;
if length(varargin) > 3
    meanMode = varargin{4};
end

% How are we displaying the SEM statistics?
semMode = 0;
if length(varargin) > 4
    semMode = varargin{5};
end

% Are we plotting the log of the histogram(s)?
logMode = [];
if length(varargin) > 5
    logMode = varargin{6};
end

% Are we downsampling the histogram(s)?
downsample = [];
if length(varargin) > 6
    downsample = varargin{7};
end

% Convert the histogram(s) to the absolute value.
realData = data;
if meanMode > 2
    data = absHistogram(data);
end

% Downsample the histogram(s).
if ~isempty(downsample)
    data = downSampleHistogram(data, downsample);
end

% Convert the histogram(s) to log scale.
yStr = [yAxisPrefix 'Probability (\SigmaP(x) = 1)'];
if ~isempty(logMode)
    if logMode ~= 2
        yStr = [yAxisPrefix 'Log Probability (log_{10}\SigmaP(x) = 0)'];
    end
    data = logHistogram(data, logMode);
end

% Compute the histogram bounds.
maxProbability = nan(length(data),1);
for i = 1:length(data)
    if ~empty(i)
        maxProbability(i) = max(data(i).PDF);
    end
end

% How many means are we showing?
numMeans = 1;
if meanMode == 1
    numMeans = 2;
end

% How are we displaying the SEM?
switch semMode
    
    % Do we have enough samples to display the set statistics?
    case 0
        dataField = 'allData';
        if max(arrayfun(@(x) x.sets.samples, data)) > 1
            dataField = 'sets';
        end
        
    % Display the set statistics.
    case {1, 3}
        dataField = 'sets';
        
    % Display the aggregate data statistics.
    case {2, 4}
        dataField = 'allData';
end

% Determine the summary statistics.
samples(:,1) = nan(length(data), 1);
realMeans = nan(length(data), numMeans);
means = nan(length(data), numMeans);
realSEMs = nan(length(data), numMeans);
SEMs = nan(length(data), numMeans);
for i = 1:length(data)
    
    % Is the histogram empty?
    if empty(i)
        continue;
    end
    
    % Set the samples to the number of sets.
    samples(i) = data(i).(dataField).samples;
    
    % Determine the summary statistics for the legend.
    if meanMode > 1 && realData(i).isSigned
        realMeans(i) = realData(i).(dataField).mean.abs;
        realSEMs(i) = realData(i).(dataField).stdDev.abs;
    elseif meanMode == 1 && realData(i).isSigned
        realMeans(i,1) = realData(i).(dataField).mean.pos;
        realMeans(i,2) = realData(i).(dataField).mean.neg;
        realSEMs(i,1) = realData(i).(dataField).stdDev.pos;
        realSEMs(i,2) = realData(i).(dataField).stdDev.neg;
    else
        realMeans(i) = realData(i).(dataField).mean.all;
        realSEMs(i) = realData(i).(dataField).stdDev.all;
    end
    
    % Determine the summary statistics for the plot.
    if meanMode > 1 && data(i).isSigned
        means(i) = data(i).(dataField).mean.abs;
        SEMs(i) = data(i).(dataField).stdDev.abs;
    elseif meanMode == 1 && data(i).isSigned
        means(i,1) = data(i).(dataField).mean.pos;
        means(i,2) = data(i).(dataField).mean.neg;
        SEMs(i,1) = data(i).(dataField).stdDev.pos;
        SEMs(i,2) = data(i).(dataField).stdDev.neg;
    else
        means(i) = data(i).(dataField).mean.all;
        SEMs(i) = data(i).(dataField).stdDev.all;
    end
    
    % Compute the SEM.
    if semMode < 3
        realSEMs(i,:) = realSEMs(i,:) ./ sqrt(data(i).(dataField).samples);
        SEMs(i,:) = SEMs(i,:) ./ sqrt(data(i).(dataField).samples);
    end
end

% Compute the summary statistics lines.
maxAllProbability = max(maxProbability);
minAllLines = maxAllProbability;
maxAllLines = maxAllProbability;
if ~isempty(statColors)
    
    % Compute the range.
    minAllProbability = min(maxProbability);
    maxRange = maxAllProbability - minAllProbability;
    
    % Compute the offset.
    offset = 0.05;
    minAllLines = maxAllProbability + offset * maxAllProbability;
    
    % Compute the scale.
    scale = 0.1 * maxAllProbability;
    maxAllLines = scale + minAllLines;
    
    % Initialize the summary statistics style.
    meanLineStyle = '-';
    semLineStyle = ':';
    if meanMode == 1
        negMeanLineStyle = '--';
        negSEMLineStyle = '-.';
    end
    
    % Compute the summary statistics lines.
    meanLineX = nan(length(data), 2);
    lowerLineX = nan(length(data), 2);
    upperLineX = nan(length(data), 2);
    lineY = nan(length(data), 2);
    if meanMode == 1
        negMeanLineX = nan(length(data), 2);
        negLowerLineX = nan(length(data), 2);
        negUpperLineX = nan(length(data), 2);
    end
    for i = 1:length(data)

        % Is the histogram empty?
        if empty(i)
            continue;
        end
        
        % Compute the line height.
        range = maxProbability(i) - minAllProbability;
        height = scale * (range / maxRange) + minAllLines;
        
        % Compute the summary statistics lines.
        meanLineX(i,1:2) = means(i,1);
        lowerLineX(i,:) = meanLineX(i,:) - SEMs(i,1);
        upperLineX(i,:) = meanLineX(i,:) + SEMs(i,1);
        lineY(i,1:2) = [0, height];
        
        % Compute the summary statistics lines.
        if meanMode == 1 && data(i).isSigned
            negMeanLineX(i,1:2) = means(i,2);
            negLowerLineX(i,:) = negMeanLineX(i,:) - SEMs(i,2);
            negUpperLineX(i,:) = negMeanLineX(i,:) + SEMs(i,2);
        end
    end
end

% Plot the data.
% Note: this is done twice to display the legend and layers correctly.
hold on;
transparency = .5;
edgeColorScale = .5;
lineWidth = 2;
barWidth = 0.9;
barWidthScale = 2/3;
plotHandle = [];
minBin = nan;
maxBin = nan;
for i = 1:length(data)
    
    % Is the histogram empty?
    if empty(i)
        continue;
    end
    
    % Plot the histogram.
    bins = data(i).bins;
    pdfs = data(i).PDF;
    switch histMode
        
        % Plot the histogram as a polygon.
        case 1
            
            % Construct the density.
            if isempty(logMode)
                halfResolution = data(i).resolution / 2;
                if data(i).isZeroBin && ~data(i).isSigned
                    startBin = bins(1);
                else
                    startBin = bins(1) - halfResolution;
                end
                bins = [startBin, startBin, bins];
                endBin = bins(end) + halfResolution;
                bins = [bins, endBin, endBin];
                pdfs = [0, pdfs(1), pdfs, pdfs(end), 0];
                
            % Construct the log-scale density.
            else
                bins = [bins(1), bins, bins(end)];
                pdfs = [0, pdfs, 0];
            end
            
            % Plot the histogram.
            histHandle = fill(bins, pdfs, histColors(i,:), ...
                'EdgeColor',  histColors(i,:) * edgeColorScale, ...
                'LineWidth',  lineWidth, 'FaceAlpha', transparency);
            
        % Plot the histogram as a line.
        case 2
            
            % Construct the density.
            if isempty(logMode)
                halfResolution = data(i).resolution / 2;
                if data(i).isZeroBin && ~data(i).isSigned
                    startBin = bins(1);
                else
                    startBin = bins(1) - halfResolution;
                end
                bins = [startBin, startBin, bins];
                endBin = bins(end) + halfResolution;
                bins = [bins, endBin, endBin];
                pdfs = [0, pdfs(1), pdfs, pdfs(end), 0];
                
            % Construct the log-scale density.
            else
                bins = [bins(1), bins, bins(end)];
                pdfs = [0, pdfs, 0];
            end
            
            % Plot the histogram.
            histHandle = plot([bins(1), bins, bins(end)], ...
                [0, pdfs, 0], 'Color', histColors(i,:), ...
                'LineWidth', lineWidth);
            
        % Plot the histogram as a series of bars.
        otherwise
            histHandle = bar(bins, pdfs, barWidth, ...
                'FaceColor', histColors(i,:));
            barWidth = barWidth * barWidthScale;
    end
    plotHandle = get(histHandle, 'Parent');
    
    % Compute the histogram bounds.
    minBin = min(minBin, min(bins));
    maxBin = max(maxBin, max(bins));
    
    % Plot the summary statisitics.
    if ~isempty(statColors) && statMode > 0
        line(meanLineX(i,end), lineY(i,end), 'Marker', 'o', ...
            'MarkerFaceColor', statColors(i,:), ...
            'MarkerEdgeColor', statColors(i,:), ...
            'Color', statColors(i,:), ...
            'Linestyle', meanLineStyle);
        line(lowerLineX(i,end), lineY(i,end), 'Marker', '>', ...
            'MarkerFaceColor', statColors(i,:), ...
            'MarkerEdgeColor', statColors(i,:), ...
            'Color', statColors(i,:), ...
            'Linestyle', semLineStyle);
        if meanMode == 1 && data(i).isSigned
            line(negMeanLineX(i,end), lineY(i,end), 'Marker', 'o', ...
                'MarkerFaceColor', statColors(i,:), ...
                'MarkerEdgeColor', statColors(i,:), ...
                'Color', statColors(i,:), ...
                'Linestyle', negMeanLineStyle);
            line(negLowerLineX(i,end), lineY(i,end), 'Marker', '>', ...
                'MarkerFaceColor', statColors(i,:), ...
                'MarkerEdgeColor', statColors(i,:), ...
                'Color', statColors(i,:), ...
                'Linestyle', negSEMLineStyle);
        end
    end
end

% Re-plot the summary statistics.
% Note: this is done twice to display the legend and layers correctly.
if ~isempty(statColors)
    for i = 1:length(data)
        
        % Is the histogram empty?
        if empty(i)
            continue;
        end
        
        % Re-plot the statistics markers.
        line(meanLineX(i,end), lineY(i,end), 'Marker', 'o', ...
            'MarkerFaceColor', statColors(i,:), ...
            'MarkerEdgeColor', statColors(i,:), ...
            'Color', statColors(i,:), ...
            'Linestyle', meanLineStyle);
        line(lowerLineX(i,end), lineY(i,end), 'Marker', '>', ...
            'MarkerFaceColor', statColors(i,:), ...
            'MarkerEdgeColor', statColors(i,:), ...
            'Color', statColors(i,:), ...
            'Linestyle', semLineStyle);
        line(upperLineX(i,end), lineY(i,end), 'Marker', '<', ...
            'MarkerFaceColor', statColors(i,:), ...
            'MarkerEdgeColor', statColors(i,:), ...
            'Color', statColors(i,:), ...
            'Linestyle', semLineStyle);

        % Re-plot the statistics lines.
        line(upperLineX(i,:), lineY(i,:), 'LineStyle', semLineStyle, ...
            'Color', statColors(i,:));
        line(meanLineX(i,:), lineY(i,:), 'LineStyle', meanLineStyle, ...
            'Color', statColors(i,:));
        line(lowerLineX(i,:), lineY(i,:), 'LineStyle', semLineStyle, ...
            'Color', statColors(i,:));

        % Re-plot the negative value statistics.
        if meanMode == 1 && data(i).isSigned
            
            % Re-plot the statistics markers.
            line(negMeanLineX(i,end), lineY(i,end), 'Marker', 'o', ...
                'MarkerFaceColor', statColors(i,:), ...
                'MarkerEdgeColor', statColors(i,:), ...
                'Color', statColors(i,:), ...
                'Linestyle', negMeanLineStyle);
            line(negLowerLineX(i,end), lineY(i,end), 'Marker', '>', ...
                'MarkerFaceColor', statColors(i,:), ...
                'MarkerEdgeColor', statColors(i,:), ...
                'Color', statColors(i,:), ...
                'Linestyle', negSEMLineStyle);
            line(negUpperLineX(i,end), lineY(i,end), 'Marker', '<', ...
                'MarkerFaceColor', statColors(i,:), ...
                'MarkerEdgeColor', statColors(i,:), ...
                'Color', statColors(i,:), ...
                'Linestyle', negSEMLineStyle);
            
            % Re-plot the statistics lines.
            line(negLowerLineX(i,:), lineY(i,:), 'LineStyle', ...
                negSEMLineStyle, 'Color', statColors(i,:));
            line(negUpperLineX(i,:), lineY(i,:), 'LineStyle', ...
                negSEMLineStyle, 'Color', statColors(i,:));
            line(negMeanLineX(i,:), lineY(i,:), 'LineStyle', ...
                negMeanLineStyle, 'Color', statColors(i,:));
        end
    end
end

% Fix the data names.
if ~isempty(dataNames) && ~iscell(dataNames)
    dataNames = {dataNames};
end

% Label the figure.
title(titleName);
xlabel(xAxisName);
ylabel(yStr);
set(gca, 'YTick', []);
set(gca, 'YTickLabel', []);
set(gca, 'Box', 'on');
set(zoom(gcf), 'Motion', 'horizontal', 'Enable', 'on');

% Minimize the y axis.
if isempty(dataNames)
    ylim([0, maxAllLines]);
    
% Display the legend.
else
    
    % Determine the SEM string.
    semStr = 'SEM';
    if semMode > 2
        semStr = 'S.D.';
    end
    
    % Construct the legend.
    numData = sum(~empty);
    if isempty(statColors) || statMode < 1
        legends = cell(numData, 1);
    elseif meanMode == 1
        legends = cell(5 * numData, 1);
    else
        legends = cell(3 * numData, 1);
    end
    for i = 1:length(data)
        
        % Is the histogram empty?
        if empty(i)
            continue;
        end
        
        % Construct the summary statistics legend.
        legendI = sum(~empty(1:i));
        if ~isempty(statColors) && statMode > 0
            
            % Show the postive/negative mean and standard deviation.
            if meanMode == 1
                legendI = 5 * i - 2;
                legends{5 * i - 3} = ['Mean(+) ' dataNames{i} ' = ' ...
                    num2str(realMeans(i,1))];
                legends{5 * i - 2} = [semStr '(+) ' dataNames{i} ' = ' ...
                    num2str(realSEMs(i,1))];
                legends{5 * i - 1} = ['Mean(-)' dataNames{i} ' = ' ...
                    num2str(realMeans(i,2))];
                legends{5 * i} = [semStr '(-)' dataNames{i} ' = ' ...
                    num2str(realSEMs(i,2))];
                
            % Show the mean and standard deviation.
            else
                legendI = 3 * i - 2;
                legends{3 * i - 1} = ['Mean' dataNames{i} ' = ' ...
                    num2str(realMeans(i,1))];
                legends{3 * i} = [semStr dataNames{i} ' = ' ...
                    num2str(realSEMs(i,1))];
            end
        end
        
        % Construct the histogram legend.
        legends{legendI} = dataNames{i};
        switch statMode
            
            % Display the statistics in their own legend.
            case 1
                
                % Display the postive and negative statististics. 
                if meanMode == 1
                    legends{legendI} = [legends{legendI} ...
                        ' (N = ' num2str(samples(i)) ...
                        ', Mean(+) = ' num2str(realMeans(i,1)) ...
                        ' ' semStr '(+) = ' num2str(realSEMs(i,1)), ...
                        ', Mean(-) = ' num2str(realMeans(i,2)) ...
                        ' ' semStr '(-) = ' num2str(realSEMs(i,2)) ')'];
                    
                % Display the statististics. 
                else
                    legends{legendI} = [legends{legendI} ...
                        ' (N = ' num2str(samples(i)) ...
                        ', Mean = ' num2str(realMeans(i,1)) ...
                        ' ' semStr ' = ' num2str(realSEMs(i,1)) ')'];
                end
                
            % Display the N in its own legend.
            case 2
                legends{legendI} = [legends{legendI} ...
                    ' (N = ' num2str(samples(i)) ')'];
                
            % Display the mean and SEM in their own legend.
            case 3
                % Display the postive and negative statististics. 
                if meanMode == 1
                    legends{legendI} = [legends{legendI} ...
                        ' (Mean(+) = ' num2str(realMeans(i,1)) ...
                        ' ' semStr '(+) = ' num2str(realSEMs(i,1)), ...
                        ', Mean(-) = ' num2str(realMeans(i,2)) ...
                        ' ' semStr '(-) = ' num2str(realSEMs(i,2)) ')'];
                    
                % Display the statististics. 
                else
                    legends{legendI} = [legends{legendI} ...
                        ' (Mean = ' num2str(realMeans(i,1)) ...
                        ' ' semStr ' = ' num2str(realSEMs(i,1)) ')'];
                end
        end
    end
    
    % Display the legend.
    legendHandle = legend(legends, 'Location', 'NorthEast');
    set(legendHandle, 'LineWidth', 1.5);
    
    % Resize the plots to fit the legend.
    plotPosition = get(plotHandle, 'Position');
    legendPosition = get(legendHandle, 'Position');
    histScale = 0.95 * (legendPosition(2) - ...
        plotPosition(2)) / plotPosition(4);
    ylim([0, (2 * maxAllLines - minAllLines) / histScale]);
end

% Minimize the x axis.
if minBin ~= maxBin
    
    % Compute the x-axis bounds.
    if any([data.isZeroBin])
        maxResolution = max([data.resolution]);
        minX = minBin - maxResolution / 2;
        maxX = maxBin + maxResolution / 2;
    else
        minX = minBin;
        maxX = maxBin;
    end
    
    % Minimize the x axis.
    if ~isempty(statColors)
        maxX = max([maxX, upperLineX(:,1)']);
    end
%     limPad = (maxX - minX) * 0.01;
%     xlim([minX - limPad, maxX + limPad]);
    xlim([minX, maxX]);
    
    % Set the first and last tick.
    xTicks = get(gca, 'XTick');
    tickThreshold = 0;
    if length(xTicks) > 1
        tickThreshold = (xTicks(2) - xTicks(1)) * (2 / 3);
    end
    if xTicks(1) - minX < tickThreshold
        xTicks(1) = minX;
    else
        xTicks = cat(2, minX, xTicks);
    end
    if maxX - xTicks(end) < tickThreshold
        xTicks(end) = maxX;
    else
        xTicks = cat(2, xTicks, maxX);
    end
    set(gca, 'XTick', xTicks);
end
end
