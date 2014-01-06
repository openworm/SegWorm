function clusterTimeSeries()
% This function will load all of the strain data and will cluster their
% time series
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% The algorithm is:
% 1. Calculate the distances between the means for all or some of the features
%   a. extract the mean
%   b. do all kinds of filtering/post-processing
%   c. compute the distance
% 2. calculate linkage
% 3. Draw dendogram and time series  
%

% constants
fps = 30;
% cluster window around the event - 3s
clustWindow = 3*fps;
clustWindow1 = 6*fps;
% post event offset to remove the noisy signal after the event
postEventOffset = 1*fps;
load('n2data_mean.mat');
nasPath = '\\nas207-1\otherdata\omega_data\pdf';
%nasPath = 'c:\example\event_analysis';

allFiles = dirrec(nasPath,'.mat');

for i=1:length(allFiles)
%for i=1:10
    strainName = allFiles{i};
    if isempty(strfind(strainName, 'omega-gene-NA-allele-NA-N2-on-food.mat'))
        [dirPart, filePart, extPart] = fileparts(strainName);
        filePart = strrep(filePart, 'omega-', '');
        allLabels{i}=filePart;
        
        load(strainName);
        if ~exist('eventData','var')
            continue;
        end
        if isempty(eventData)
           continue;
        end
        % Features
        dataFields = fieldnames(eventData);
        
        for j = 1:length(dataFields)-1
            if strcmp(dataFields{j}, 'locomotion_velocity_midbody_speed')
                data = eventData.(dataFields{j});
                midDataPoint = round(size(data, 2)/2);
                croppedData1 = data(:,midDataPoint-clustWindow1:midDataPoint)';
                croppedData2 = data(:,midDataPoint+postEventOffset:midDataPoint+clustWindow)';
                timeSeriesCrop1 =[croppedData1;  croppedData2];
                allData{i,1} = timeSeriesCrop1;
                %figure;
                %hl2 = line(1:size(data, 2), nanmean(data),'Color','k', 'LineWidth', 0.5);
            end
            if strcmp(dataFields{j}, 'posture_tracklength')
                data = eventData.(dataFields{j});
                midDataPoint = round(size(data, 2)/2);
                croppedData1 = data(:,midDataPoint-clustWindow1:midDataPoint)';
                croppedData2 = data(:,midDataPoint+postEventOffset:midDataPoint+clustWindow)';
                timeSeriesCrop1 =[croppedData1;  croppedData2];
                allData{i,2} = timeSeriesCrop1;
                %figure;
                %hl2 = line(1:size(data, 2), nanmean(data),'Color','k', 'LineWidth', 0.5);
            end
            if strcmp(dataFields{j}, 'locomotion_velocity_headTip_speed')
                data = eventData.(dataFields{j});
                midDataPoint = round(size(data, 2)/2);
                croppedData1 = data(:,midDataPoint-clustWindow1:midDataPoint)';
                croppedData2 = data(:,midDataPoint+postEventOffset:midDataPoint+clustWindow)';
                timeSeriesCrop1 =[croppedData1;  croppedData2];
                allData{i,3} = timeSeriesCrop1;
                %figure;
                %hl2 = line(1:size(data, 2), nanmean(data),'Color','k', 'LineWidth', 0.5);
            end
        end
    end
end

diffMatrix = zeros(1,size(allData,2));

for i=1:size(allData,2)
    %diffMatrix(i) = nansum(abs(nanmean(allData{i}')- n2data_mean));
    diffMatrix(i) = sqrt(nansum(nanmean(allData{i,1}')- n2data_mean).^2);
    %Euclidean distance
    %diffMatrix(i,j) = sqrt(nansum(abs(nanmean(allData{i}')- nanmean(allData{j}')).^2));

end
1;

% lets compute pairwise distance
m = size(allData,2);
pairDist = zeros(1,(m*(m-1)/2));
k=1;
for i=1:m
    for j=i+1:m
    pairDist(k,1) = sqrt(nansum(nanmean(allData{i,1}')- nanmean(allData{j,1}')).^2);
    pairDist(k,2) = sqrt(nansum(nanmean(allData{i,1}')- nanmean(allData{j,1}')).^2);
    k=k+1;
    end
end


Z2 = linkage(pairDist, 'average')
T = cluster(Z2,'cutoff',1.2)

save('results_run1', 'diffMatrix', 'allData', 'allLabels');
%Z = linkage(diffMatrix, 'ward','euclidean');
%H = dendrogram(Z, 'labels', allLabels', 'orientation', 'right')

[B,IX] = sort(diffMatrix);
tmpData = allData(IX(1:10))';
xx=60;
tmpDataEnd = allData(IX(end-11-xx:end-0-xx))';
figure
hold on
for i=1:10
    if ~isempty(tmpData{i})
        plot(nanmean(tmpData{i}'))
    end
end

for i=1:10
    if ~isempty(tmpDataEnd{i})
        plot(nanmean(tmpDataEnd{i}'), 'color', 'm')
    end
end

plot(n2data_mean, 'LineWidth', 2, 'color', 'k')
