function plotStrainEventData(strainName, pdfOutFlag)
% PLOTSTRAINEVENTDATA This function will plot strain event data
% 
% Input: 
%   strainName - path to the file that contains strain data
%   pdfOutFlag - if set to 0 will not output a pdf file
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
if pdfOutFlag
    % finalize the PDF
    pdfName = strrep(strainName, '.m', '.ps');
    pdfName = fullfile(pwd, pdfName);
end
strainName = fullfile('\\nas207-1\otherdata\omega_data\pdf', strainName);

load(strainName);

featureFileName = strcat(strainName,' files-',num2str(fileCounter),'-events-',num2str(dataCounter));
dataFields = fieldnames(eventData);

for i = 1:length(dataFields)-1
    h = figure;
    orient(h, 'landscape');
    try
        plotTSeriesMatrix(eventData.(dataFields{i}), strrep(dataFields{i},'_','.'), eventData.expFileList, expList);
    catch ME1
        1;
    end
    
    axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.2, 1, featureFileName, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold', 'FontSize', 8);
    
    if pdfOutFlag
        fillPage(h, 'papersize', 'A4');
        if i == 1
            print('-dpsc2', pdfName, gcf);
        else
            print ('-dpsc2', pdfName, '-append', gcf);
        end
        close(h);
    end
end
if pdfOutFlag
% finalize the PDF
ps2pdf('psfile', pdfName, 'pdffile', [strrep(pdfName,'.ps',''),'.pdf'], 'gspapersize', 'a4', 'deletepsfile', 1);
end


function plotTSeriesMatrix(data, varStr, expLabels, expList)
% PLOTTSERIESMATRIX This function will plot the time series data
% Input
% Output
%


% Check if angle normalization needed
if ~isempty(strfind(varStr,'directions.tail2head'))
    % Here we will find mean of the angle for 6 frames for each of the
    % events
    size1 = size(data,1);
    size2 = size(data,2);
    eventMean = NaN(size1, 6);
    for i = 1:size1
        counter1 = 1;
        eventAngleData = NaN(1,6);
        
        for j = round((size2/2)):-1:1
            if counter1 > 6
                break;
            end
            if ~isnan(data(i,j))
                eventAngleData(counter1) = data(i,j);
                counter1 = counter1 + 1;
            end
        end
        
        eventMean(i,:) = eventAngleData;
    end
    eventMeanAll = nanmean(eventMean');
    for j = 1:size1
        data2(j,:) = data(j,:)-eventMeanAll(j);
    end
    
    data = data2;
end
%--------------------------------------------------------------------------

subplot(2,1,1)
hold on;
y = data;
x = 1:size(data, 2);
H(1) = shadedErrorBar(x, y, {@nanmean, @(x) 2*nanstd(x)  }, '-r', 0);
%H(2) = shadedErrorBar(x, y, {@nanmean, @(x) 1*nanstd(x)  }, '-m', 0);
H(2) = shadedErrorBar(x, y, {@nanmean, @(x) 0.5*nanstd(x)}, {'-b', 'LineWidth', 2}, 0);

legend([H(2).mainLine, H.patch], '\mu', '2\sigma', '\sigma', '0.5\sigma', ...
    'Location', 'Northwest');

ax1 = gca;
set(ax1,'XColor','k','YColor','k')
ax2 = axes('Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
xlim(ax1, [1, size(data, 2)]);
xlim(ax2, [1, size(data, 2)]);

bound1 = [nanmin(get(H(1).edge(1), 'ydata')), nanmax(get(H(1).edge(2), 'ydata'))];
if ~all(isnan(bound1)) && ~all((bound1)==0)
    ylim(ax1, bound1);
    ylim(ax2, bound1);
end

tmp = 0:round(size(data, 2)/18):size(data, 2);
xTickLabelNum = [1,tmp(2:end),size(data, 2)];
set(ax1, 'XTick', xTickLabelNum);
set(ax1, 'XTickLabel',sprintf('%4d|', xTickLabelNum))

tmp =  0:60:size(data, 2);
xTickLabelNum2 = [1,tmp(2:end)];
xTickLabelNum3 = round(xTickLabelNum2/60);
set(ax2, 'XTick', xTickLabelNum2);
set(ax2, 'XTickLabel',sprintf('%4d|', xTickLabelNum3))
%set(ax2,'YTick',[]);

labelInfo = wormDisplayInfo;
[yLabel, titleStr] = getLabel(labelInfo, varStr);

% work on yLabel
if length(yLabel) > 26
    spaceLocations = strfind(yLabel, ' ');
    yLabelStr = {yLabel(1:spaceLocations(end)),yLabel(spaceLocations(end)+1:end)};
    if length(yLabelStr{1}) > 26
        spaceLocations2 = strfind(yLabelStr{1}, ' (');
        yLabelStr2 = {yLabelStr{1}(1:spaceLocations2(end)),yLabelStr{1}(spaceLocations2(end)+1:end)};
        yLabelStr3 = yLabelStr;
        yLabelStr = [yLabelStr2, yLabelStr3{end}];
    end
else
    yLabelStr = yLabel;
end

xlabel(ax1, 'Time (frames)', 'FontSize', 8);
xlabel(ax2, 'Time (seconds)', 'FontSize', 8);
ylabel(ax1, yLabelStr, 'FontSize', 8);
title(titleStr, 'FontWeight', 'bold');

%---------------
% Lets draw individual events
subplot(2,1,2);
hold on;
% Lets define the colours to distinguish individual experiments
col1 = varycolor(length(expList));
col2 = cell(length(expLabels),3);
for j=1:length(expLabels)
    col2{j} = col1(expLabels(j), :);
end
% Draw the lines
hl1 = line([1:size(data, 2)], data);
% find the lines and set their color
linecolors = findobj(hl1 , 'Type' , 'Line');
for color_id = 1 : numel (linecolors)
    set (linecolors(color_id) , 'Color', col2{color_id});
end
% Define unique experiments in the event list
uniqueExp = logical(diff(expLabels));
% Include the first experiment
uniqueExp(1) = 1;

% If there are not too many experiments show the legend
if sum(~cellfun(@isempty, expList)) <= 30
    leg1 = legend(hl1(uniqueExp), expList(~cellfun(@isempty, expList)), 'Location', 'BestOutside','Fontsize',7);
end

% % Color legend
% hKids = get(leg1,'Children');
% hText = hKids(strcmp(get(hKids,'Type'),'text'));
%
% col3 = col1(:,~cellfun(@isempty, expList));
% for i=1:size(col3,1)
%     col4{i} = col3(i,:);
% end
%
% set(hText,{'Color'},col4');

posAx2 = get(ax1, 'Position');
set(gca, 'Position', [posAx2(1), posAx2(2)-0.4739, posAx2(3)-0.15, posAx2(4)]);

ax1 = gca;
set(ax1,'XColor','k','YColor','k')
ax2 = axes('Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');

%hl2 = line(1:size(data, 2), nanmean(data),'Color','Red', 'LineWidth', 2,'Parent',ax2);
hl2 = patchline(1:size(data, 2), nanmean(data),'edgecolor',[0.85, 0.85, 0.85],...
    'LineWidth', 7, 'edgealpha',0.5);
hl2 = line(1:size(data, 2), nanmean(data),'Color','k', 'LineWidth', 0.5,'Parent',ax2);

leg2 = legend(hl2, 'Mean');

xlim(ax1, [1, size(data, 2)]);
xlim(ax2, [1, size(data, 2)]);

bound1 = [nanmin(get(H(1).edge(1), 'ydata')), nanmax(get(H(1).edge(2), 'ydata'))];
if ~all(isnan(bound1)) && ~all((bound1)==0)
    ylim(ax1, bound1);
    ylim(ax2, bound1);
end

tmp = 0:round(size(data, 2)/18):size(data, 2);
xTickLabelNum = [1,tmp(2:end),size(data, 2)];
set(ax1, 'XTick', xTickLabelNum);
set(ax1, 'XTickLabel',sprintf('%4d|', xTickLabelNum))

tmp =  0:60:size(data, 2);
xTickLabelNum2 = [1,tmp(2:end)];
xTickLabelNum3 = round(xTickLabelNum2/60);
set(ax2, 'XTick', xTickLabelNum2);
set(ax2, 'XTickLabel',sprintf('%4d|', xTickLabelNum3))
set(ax2,'YTick',[]);

labelInfo = wormDisplayInfo;
[yLabel, titleStr] = getLabel(labelInfo, varStr);

% work on yLabel
if length(yLabel) > 26
    spaceLocations = strfind(yLabel, ' ');
    yLabelStr = {yLabel(1:spaceLocations(end)),yLabel(spaceLocations(end)+1:end)};
    if length(yLabelStr{1}) > 26
        spaceLocations2 = strfind(yLabelStr{1}, ' (');
        yLabelStr2 = {yLabelStr{1}(1:spaceLocations2(end)),yLabelStr{1}(spaceLocations2(end)+1:end)};
        yLabelStr3 = yLabelStr;
        yLabelStr = [yLabelStr2, yLabelStr3{end}];
    end
else
    yLabelStr = yLabel;
end

xlabel(ax1, 'Time (frames)', 'FontSize', 8);
xlabel(ax2, 'Time (seconds)', 'FontSize', 8);
ylabel(ax1, yLabelStr, 'FontSize', 8);
title(titleStr, 'FontWeight', 'bold');


function [label, name] = getLabel(info, field)
labelInfo =  getStructField(info, field);
label = [labelInfo.name ' (' labelInfo.unit ')'];
name = [labelInfo.name ' (' labelInfo.shortName ')'];