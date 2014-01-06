function eventAnalysis()
% EVENTANALYSIS This function will load feature files, identify/choose
% multiple events and will extract data before/after it will then use PCA
% to analyze that data and understand trends that could be found from
% re-accuring changes in the features before the events.
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%   inName - path to the feature file name that is to be outputted. If
%   the name will be set to an empty string '' file selector gui will be
%   called
%
%   outName - pdf output name, if is 0 then save in the same directory as
%   the feature file, if set to an empty string '' file selector gui will
%   be called
%

% % % Here we are getting directory contents
% % allFiles = dirrec('c:\example\events\raw\','.mat');
% %
% % % Parse the experiment names
% % for i=1:length(allFiles)
% %     ind1 = strfind(allFiles{i},'food');
% %     filePaths{i} = allFiles{i}(1:ind1(1)+4);
% %
% %     %ind2 = strfind(allFiles{i},'Laura Grundy\\');
% %     ind2 = strfind(allFiles{i},'raw\');
% %     %fileNames{i} = filePaths{i}(ind2(1)+14:end);
% %     fileNames{i} = filePaths{i}(ind2(1)+4:end);
% %     fileNames{i} = strrep(fileNames{i},'\','-');
% % end
% %
% %
% % % Parse the path names
% % for i=1:length(filePaths)
% %     %ind2 = strfind(allFiles{i},'Laura Grundy\\');
% %     ind2 = strfind(allFiles{i},'raw\');
% %     %fileNames{i} = filePaths{i}(ind2(1)+14:end-1);
% %     fileNames{i} = filePaths{i}(ind2(1)+4:end-1);
% %     fileNames{i} = strrep(fileNames{i},'\','-');
% %     fileNames{i} = strrep(fileNames{i},'_','-');
% % end
% %
% %


% allFiles = dirrec('');
%
% for i=1:length(allFiles)
%     ind1 = strfind(allFiles{i},'food');
%     filePaths{i} = allFiles{i}(1:ind1(1)+4);
%
%     ind2 = strfind(allFiles{i},'Laura Grundy\\');
%     fileNames{i} = filePaths{i}(ind2(1)+14:end);
%     fileNames{i} = strrep(fileNames{i},'\','-');
% end
%
%
% for i=1:length(filePaths)
%
%     ind2 = strfind(allFiles{i},'Laura Grundy\\');
%     fileNames{i} = filePaths{i}(ind2(1)+14:end-1);
%     fileNames{i} = strrep(fileNames{i},'\','-');
%     fileNames{i} = strrep(fileNames{i},'_','-');
% end

eventName = 'omega';
if ~isdir(eventName)
    mkdir(eventName);
end

filePaths = [];
fileNames = [];
load('allFiles.mat');

% Define event names
eventName = 'omega';
if ~isdir(eventName)
    mkdir(eventName);
end

%filePaths = [];
%fileNames = [];
%load('allFiles.mat');

uniqueFilePaths = unique(filePaths);
uniqueFileNames = unique(fileNames);
% Main loop through all of the discovered strains
for jj=296:length(uniqueFilePaths)
    
    % Strain directory
    dir1 = uniqueFilePaths{jj};
    % run labels
    runName = [eventName,'-', uniqueFileNames{jj}];
    psname = [eventName,'-', uniqueFileNames{jj},'.ps'];
    
    dirContents = dirrec(dir1,'.mat');
    
    
    % Define constatns
    window1 = 240;
    
    % Iter
    eventData = [];
    dataCounter = 0;
    fileCounter = 0;
    expList = cell(1, length(dirContents));
    %for i=1:length(dirContents)
    %dirContents = dirContents(end-17:end);
    for i=1:length(dirContents)
        
        inName = dirContents{i};
        [dirExp, fileExp, ~] = fileparts(inName);
        try
            load(inName);
        catch ME1
            msgString = getReport(ME1);
            msgbox(msgString);
            continue;
        end
        fileCounter = fileCounter + 1;
        
        % Define events
        %----
        if ~isempty(worm.posture.coils.frames)
            allEvents = [worm.posture.coils.frames.start];
        else
            fileCounter = fileCounter-1;
            continue;
        end
        
        earlyEvents = ([worm.posture.coils.frames.start]-window1)<1;
        lateEvents = ([worm.posture.coils.frames.start]+window1)>info.video.length.frames;
        
        events = allEvents(~(earlyEvents|lateEvents));
        if isempty(events)
            continue;
        end
        
        %         % define alternative events
        %         if ~isempty(worm.locomotion.motion.backward.frames)
        %             allEvents = [worm.locomotion.motion.backward.frames.start];
        %         else
        %             fileCounter = fileCounter-1;
        %             continue;
        %         end
        %
        %         earlyEvents = ([worm.locomotion.motion.backward.frames.start]-window1)<1;
        %         lateEvents = ([worm.locomotion.motion.backward.frames.start]+window1)>info.video.length.frames;
        %
        %         events = allEvents(~(earlyEvents|lateEvents));
        %         if isempty(events)
        %             continue;
        %         end
        
        
        %--
        % Lets remove the non-time series elements
        
        worm.posture = rmfield(worm.posture, 'coils');
        worm.posture = rmfield(worm.posture, 'skeleton');
        worm.posture = rmfield(worm.posture, 'eigenProjection');
        
        worm.locomotion = rmfield(worm.locomotion, 'motion');
        worm.locomotion = rmfield(worm.locomotion, 'bends');
        worm.locomotion = rmfield(worm.locomotion, 'turns');
        
        worm = rmfield(worm, 'path');
        
        % Get the data for all of the events
        for j=1:length(events)
            offset1 = events(j)-window1;
            offset2 = events(j)+window1;
            
            wormDec = worm;
            while ~isempty(fields(wormDec))
                [leafName, leafData] = retrieveLeafData(wormDec, '', offset1, offset2);
                if size(leafData,2) ~= 1
                    leafNameNorm = strrep(leafName, '.','_');
                    eventData.(leafNameNorm)(dataCounter+j,:) = leafData;
                end
                % remove recoreded values
                ind1 = strfind(leafName, '.');
                if ~isempty(ind1)
                    parentLeaf = leafName(1:ind1(end)-1);
                    childLeaf = leafName(ind1(end)+1:end);
                    eval(['wormDec.',parentLeaf,'= rmfield(wormDec.',parentLeaf,',''',childLeaf,''');']);
                else
                    if ~isempty(fields(wormDec))
                        try
                            eval(['wormDec = rmfield(wormDec',',','''',leafName,''');']);
                        catch
                            1;
                        end
                    end
                end
            end
            % Here we build a label list of which event belongs to which
            % file
            eventData.expFileList(dataCounter+j) = i;
            % filter feature groups
            %featureGroups = featureGroups(cellfun(@isempty, strfind(featureGroups, 'path')));
        end
        
        % Lets build association to files here, we need to know which
        % trail belongs to which experiment so some stuff like head and
        % tail correcness can be checked.
        expList{i} = strrep(fileExp,'_features','');
        dataCounter = dataCounter+length(events);
        
    end
    
    if ~isempty(eventData)
        % Save the data
        
        save([eventName,filesep,runName,'.mat'],'eventData','expList','fileCounter','dataCounter');
        
        % Define labels
        
        featureFileName = strcat(runName,' files-',num2str(fileCounter),'-events-',num2str(dataCounter));
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
            
            fillPage(h, 'papersize', 'A4');
            if i == 1
                print('-dpsc2', psname, gcf);
            else
                print ('-dpsc2', psname, '-append', gcf);
            end
            close(h);
        end
        
        
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, wormLength, [600, 1400],'morphology.length');
        %     plotTSeriesMatrix(a,b,2, wormWidthHead, [0, 100], 'morphology.width.head');
        %
        %     figure;hold on;
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Morphology 1', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold', 'FontSize', 8);
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print('-dpsc2', psname, gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, wormWidthMidbody, [30,170], 'morphology.width.midbody');
        %     plotTSeriesMatrix(a,b,2, wormWidthTail, [20, 90], 'morphology.width.tail');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Morphology 2', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 3;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, widthPerLength, [0.05, 0.13], 'morphology.widthPerLength');
        %     plotTSeriesMatrix(a,b,2, wormArea, [50000, 130000], 'morphology.area');
        %     plotTSeriesMatrix(a,b,3, areaPerLength, [50, 110], 'morphology.areaPerLength');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Morphology 2', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %     %--
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, tracklength, [-700, 700], 'posture.tracklength');
        %     plotTSeriesMatrix(a,b,2, eccentricity, [0, 1], 'posture.eccentricity');
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Posture 1', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, ampMax, [60, 600],'posture.amplitude.max');
        %     plotTSeriesMatrix(a,b,2, ampRatio, [0, 1], 'posture.amplitude.ratio');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Posture 2', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, wavelengthPrimary, [300, 1300], 'posture.wavelength.primary');
        %     plotTSeriesMatrix(a,b,2, wavelengthSecondary, [200, 700], 'posture.wavelength.secondary');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Posture 3', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, kinks, [0, 6], 'posture.kinks');
        %     directions1 = bsxfun(@minus,directions1, nanmean(directions1(:,200:241)')');
        %     plotTSeriesMatrix(a,b,2, directions1, [-350, 400], 'posture.directions.tail2head');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Posture 4', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, bendsHeadMean, [-95, 95], 'posture.bends.head.mean');
        %     plotTSeriesMatrix(a,b,2, bendsHeadStd, [-40, 60], 'posture.bends.head.stdDev');
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Posture 5', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, bendsNeckMean, [-70, 70],'posture.bends.neck.mean');
        %     plotTSeriesMatrix(a,b,2, bendsNeckStd, [-40, 40], 'posture.bends.neck.stdDev');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Posture 6', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, bendsMidbodyMean, [-50, 50], 'posture.bends.midbody.mean');
        %     plotTSeriesMatrix(a,b,2, bendsMidbodyStd, [-50, 50],'posture.bends.midbody.stdDev');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Posture 7', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, bendsHipsMean, [-90, 90], 'posture.bends.hips.mean');
        %     plotTSeriesMatrix(a,b,2, bendsHipsStd, [-40, 40], 'posture.bends.hips.stdDev');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Posture 8', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, bendsTailMean, [-80, 80],'posture.bends.tail.mean');
        %     plotTSeriesMatrix(a,b,2, bendsTailStd, [-50, 50],'posture.bends.tail.stdDev');
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Posture 9', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, dirHead, [-180, 180], 'posture.directions.head');
        %     plotTSeriesMatrix(a,b,2, dirTail, [-180, 180],'posture.directions.tail');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Posture 10', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, midbodySpeed, [-800, 800],'locomotion.velocity.midbody.speed');
        %     plotTSeriesMatrix(a,b,2, midbodyDirection, [-8,8],'locomotion.velocity.midbody.direction');
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Locomotion 1', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, headtipSpeed, [-1000, 1000],'locomotion.velocity.headTip.speed');
        %     plotTSeriesMatrix(a,b,2, headtipDirection, [-8, 8], 'locomotion.velocity.headTip.direction');
        %
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Locomotion 2', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, headSpeed, [-1000, 1000],'locomotion.velocity.head.speed');
        %     plotTSeriesMatrix(a,b,2, headDirection, [-8 ,8], 'locomotion.velocity.head.direction');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Locomotion 3', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, tailSpeed, [-1000, 1000],'locomotion.velocity.tail.speed');
        %     plotTSeriesMatrix(a,b,2, tailDirection, [-8, 8], 'locomotion.velocity.tail.direction');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Locomotion 4', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, tailTipSpeed, [-1000, 1000],'locomotion.velocity.tailTip.speed');
        %     plotTSeriesMatrix(a,b,2, tailTipDirection, [-8,8], 'locomotion.velocity.tailTip.direction');
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1, {'Locomotion 5', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, foragingAmp, [-100, 100],'locomotion.bends.foraging.amplitude');
        %     plotTSeriesMatrix(a,b,2, foragingAngleSpeed, [-1000, 1000],'locomotion.bends.foraging.angleSpeed');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Locomotion 6', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, headAmp, [-70, 70], 'locomotion.bends.head.amplitude');
        %     plotTSeriesMatrix(a,b,2, headFreq, [-2,2], 'locomotion.bends.head.frequency');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Locomotion 5', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %
        %     plotTSeriesMatrix(a,b,1, midbodyAmp, [-70, 70], 'locomotion.bends.midbody.amplitude');
        %     plotTSeriesMatrix(a,b,2, midbodyFreq, [-2, 2], 'locomotion.bends.midbody.frequency');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Locomotion 6', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        %
        %     h = figure;
        %     orient(h, 'landscape');
        %     a = 2;
        %     b = 1;
        %     plotTSeriesMatrix(a,b,1, tailAmp, [-60, 70], 'locomotion.bends.tail.amplitude');
        %     plotTSeriesMatrix(a,b,2, tailFreq, [-3, 3], 'locomotion.bends.tail.amplitude');
        %
        %     axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %     text(0.2, 1,{'Locomotion 7', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold', 'FontSize', 8);
        %
        %     fillPage(h, 'papersize', 'A4');
        %     print ('-dpsc2', psname, '-append', gcf);
        %     close(h);
        
        %-----------------------------------------------------------------------
        %h = figure;
        %orient(h, 'landscape');
        %a = 4;
        %b = 1;
        %plotTSeriesMatrix(a,b,1, pathRange, 'path.range');
        %plotTSeriesMatrix(a,b,2, pathCurvature, 'path.curvature');
        
        %axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        %text(0.2, 1,{'Path 1', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');
        
        %fillPage(h, 'papersize', 'A4');
        %print ('-dpsc2', psname, '-append', gcf);
        %close(h);
        
        % finalize the PDF
        ps2pdf('psfile', psname, 'pdffile', [strrep(psname,'.ps',''),'.pdf'], 'gspapersize', 'a4', 'deletepsfile', 1);
    end
end



%         % Construct the length label.
%         labelInfo = wormDisplayInfo;
%         yLabel = getLabel(labelInfo, 'locomotion.velocity.midbody.speed');
%
%         orient(h, 'landscape');
%         fillPage(h, 'papersize', 'A4');
%         xlabel('Time (minutes)');
%         ylabel(yLabel);
%
%         titleStr = ({['Average Velocity (Moving Window Average of T = 1s)']; ...
%             ['Treatment=' treatmentLabel{treatmentID}]; ...
%             ['Strain=' strain]; ...
%             ['Gene=' gene]; ...
%             ['Allele=' allele]; ...
%             ['N=' num2str(k)]});
%         title(titleStr);
%         set(gca, 'XTick', 0:2:15);
%         set(gca, 'YTick', 0:30:500);
%         ylim([0, 500]);
%         if strcmp(gene, 'null')
%             legendLabels = {strain};
%         else
%             legendLabels = {gene};
%         end
%         %legend(legendLabels, 'Location','Best');
%
%         print ('-dpsc2', psname, '-append', gcf);
%         close(h);
%
%         ps2pdf('psfile', psname, 'pdffile', [psname,'.pdf'], 'gspapersize', 'a4', 'deletepsfile', 1);
%

% Construct a label from a field.
function [label, name] = getLabel(info, field)
labelInfo =  getStructField(info, field);
label = [labelInfo.name ' (' labelInfo.unit ')'];
name = [labelInfo.name ' (' labelInfo.shortName ')'];

function plotTSeries(ColorSet, j, a,b,c, data, varStr)
subplot(a,b,c)
hold on;
plot(1:length(data), data, 'Color', ColorSet(j,:));
xlim([1, length(data)]);
tmp = 0:round(length(data)/18):length(data);
xTickLabelNum = [1,tmp(2:end),length(data)];
set(gca, 'XTick', xTickLabelNum);
set(gca, 'XTickLabel',sprintf('%4d|',xTickLabelNum))

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

xlabel('Time (frames)', 'FontSize', 8);
ylabel(yLabelStr, 'FontSize', 8);
title(titleStr, 'FontWeight', 'bold', 'FontSize', 8);


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

function [leafName, leafData] = retrieveLeafData(wormStruct, leafName, offset1, offset2)
% RETRIEVELEAFDATA This is a recursive function that will get the struct as
% an input and and will retrieve data at the end of the struct (the far most leaf)
%
% Input:    wormStruct - feature struct data
%           offset1 - data offset around the event
%           offset2 - data offset around the event
%
% Output:   leafName - name of the leaf
%           leafData - data of the leaf

leafNames = fieldnames(wormStruct);

% check if leaf names exist
if ~isempty(leafNames)
    leafName = leafNames{1};
    
    try
        tmp = isstruct(wormStruct.(leafName));
    catch ME1
        1;
    end
    
    if ~isstruct([wormStruct.(leafName)])
        if size(wormStruct.(leafName),2) > offset2
            leafData = wormStruct.(leafName)(offset1:offset2);
        else
            leafData = 0;
        end
        %wormStruct = rmfield(wormStruct, leafName);
    else
        [leafName2, leafData] = retrieveLeafData(wormStruct.(leafName), leafName, offset1, offset2);
        if ~isempty(leafName2)
            leafName = [leafName,'.',leafName2];
        end
    end
    
else
    leafName = '';
    leafData = 0;
end
