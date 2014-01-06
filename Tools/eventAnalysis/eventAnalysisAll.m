function eventAnalysisAll()
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

allFiles = dirrec(pwd, '.mat');
allFiles = {allFiles{2:end}};

featureFileName = 'all-omega-timeSeries';
psname = 'all-omega-timeSeries.ps';


jj=1;
for aa=1:length(allFiles)
    
    %strain selector 
    if (~isempty(strfind(allFiles{aa}, 'N2')) && ~isempty(strfind(allFiles{aa}, 'on-food')))|| ...
            ~isempty(strfind(allFiles{aa}, 'osm-6')) || ...
            ~isempty(strfind(allFiles{aa}, 'osm-3')) || ...
            ~isempty(strfind(allFiles{aa}, 'cat-2')) || ...
            ~isempty(strfind(allFiles{aa}, 'flp-1-')) || ...
            ~isempty(strfind(allFiles{aa}, 'goa-1')) || ...
            ~isempty(strfind(allFiles{aa}, 'egl-10')) || ...
            ~isempty(strfind(allFiles{aa}, 'mec-7')) || 1
        
        expName = strrep(allFiles{aa}, pwd, '');
        expName = strrep(expName, filesep, '');
        expName = strrep(expName, 'omega-', '');
        expName = strrep(expName, '-on-food', '');
        expName = strrep(expName, '.mat', '');
        legendVar{jj} = expName;
        
        load(allFiles{aa});
        wormLengthAll(jj,:) = nanmean(wormLength);
        wormWidthHeadAll(jj,:) = nanmean(wormWidthHead);
        
        wormLengthAll(jj,:) = nanmean(wormLength);
        wormWidthHeadAll(jj,:) = nanmean(wormWidthHead);
        wormWidthMidbodyAll(jj,:) = nanmean(wormWidthMidbody);
        wormWidthTailAll(jj,:) = nanmean(wormWidthTail);
        
        widthPerLengthAll(jj,:) = nanmean(widthPerLength);
        wormAreaAll(jj,:) = nanmean(wormArea);
        areaPerLengthAll(jj,:) = nanmean(areaPerLength);
        tracklengthAll(jj,:) = nanmean(tracklength);
        eccentricityAll(jj,:) = nanmean(eccentricity);
        ampMaxAll(jj,:) = nanmean(ampMax);
        ampRatioAll(jj,:) = nanmean(ampRatio);
        
        wavelengthPrimaryAll(jj,:) = nanmean(wavelengthPrimary);
        wavelengthSecondaryAll(jj,:) = nanmean(wavelengthSecondary);
        kinksAll(jj,:) = nanmean(kinks);
        directions1All(jj,:) = nanmean(directions1);
        
        bendsHeadMeanAll(jj,:) = nanmean(bendsHeadMean);
        bendsHeadStdAll(jj,:) = nanmean(bendsHeadStd);
        bendsNeckMeanAll(jj,:) = nanmean(bendsNeckMean);
        bendsNeckStdAll(jj,:) = nanmean(bendsNeckStd);
        
        bendsMidbodyMeanAll(jj,:) = nanmean(bendsMidbodyMean);
        bendsMidbodyStdAll(jj,:) = nanmean(bendsMidbodyStd);
        bendsHipsMeanAll(jj,:) = nanmean(bendsHipsMean);
        bendsHipsStdAll(jj,:) = nanmean(bendsHipsStd);
        
        bendsTailMeanAll(jj,:) = nanmean(bendsTailMean);
        bendsTailStdAll(jj,:) = nanmean(bendsTailStd);
        dirHeadAll(jj,:) = nanmean(dirHead);
        dirTailAll(jj,:) = nanmean(dirTail);
        
        midbodySpeedAll(jj,:) = nanmean(midbodySpeed);
        midbodyDirectionAll(jj,:) = nanmean(midbodyDirection);
        headtipSpeedAll(jj,:) = nanmean(headtipSpeed);
        headtipDirectionAll(jj,:) = nanmean(headtipDirection);
        
        headSpeedAll(jj,:) = nanmean(headSpeed);
        headDirectionAll(jj,:) = nanmean(headDirection);
        tailSpeedAll(jj,:) = nanmean(tailSpeed);
        tailDirectionAll(jj,:) = nanmean(tailDirection);
        
        tailTipSpeedAll(jj,:) = nanmean(tailTipSpeed);
        tailTipDirectionAll(jj,:) = nanmean(tailTipDirection);
        foragingAmpAll(jj,:) = nanmean(foragingAmp);
        foragingAngleSpeedAll(jj,:) = nanmean(foragingAngleSpeed);
        
        headAmpAll(jj,:) = nanmean(headAmp);
        headFreqAll(jj,:) = nanmean(headFreq);
        midbodyAmpAll(jj,:) = nanmean(midbodyAmp);
        midbodyFreqAll(jj,:) = nanmean(midbodyFreq);
        
        tailAmpAll(jj,:) = nanmean(tailAmp);
        tailFreqAll(jj,:) = nanmean(tailFreq);
        
        pathRangeAll(jj,:) = nanmean(pathRange);
        pathCurvatureAll(jj,:) = nanmean(pathCurvature);
        
        jj=jj+1;
    end
end
wormLength = wormLengthAll;
wormWidthHead = wormWidthHeadAll;

wormLength = wormLengthAll;
wormWidthHead = wormWidthHeadAll;
wormWidthMidbody = wormWidthMidbodyAll;
wormWidthTail = wormWidthTailAll;

widthPerLength = widthPerLengthAll;
wormArea = wormAreaAll;
areaPerLength = areaPerLengthAll;
tracklength = tracklengthAll;
eccentricity = eccentricityAll;
ampMax = ampMaxAll;
ampRatio = ampRatioAll;

wavelengthPrimary = wavelengthPrimaryAll;
wavelengthSecondary = wavelengthSecondaryAll;
kinks = kinksAll;
directions1 = directions1All;

bendsHeadMean = bendsHeadMeanAll;
bendsHeadStd = bendsHeadStdAll;
bendsNeckMean = bendsNeckMeanAll;
bendsNeckStd = bendsNeckStdAll;

bendsMidbodyMean = bendsMidbodyMeanAll;
bendsMidbodyStd = bendsMidbodyStdAll;
bendsHipsMean = bendsHipsMeanAll;
bendsHipsStd = bendsHipsStdAll;

bendsTailMean = bendsTailMeanAll;
bendsTailStd = bendsTailStdAll;
dirHead = dirHeadAll;
dirTail = dirTailAll;

midbodySpeed = midbodySpeedAll;
midbodyDirection = midbodyDirectionAll;
headtipSpeed = headtipSpeedAll;
headtipDirection = headtipDirectionAll;

headSpeed = headSpeedAll;
headDirection = headDirectionAll;
tailSpeed = tailSpeedAll;
tailDirection = tailDirectionAll;

tailTipSpeed = tailTipSpeedAll;
tailTipDirection = tailTipDirectionAll;
foragingAmp = foragingAmpAll;
foragingAngleSpeed = foragingAngleSpeedAll;

headAmp = headAmpAll;
headFreq = headFreqAll;
midbodyAmp = midbodyAmpAll;
midbodyFreq = midbodyFreqAll;

tailAmp = tailAmpAll;
tailFreq = tailFreqAll;

pathRange = pathRangeAll;
pathCurvature = pathCurvatureAll;

    
h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, wormLength, [600, 1400],'morphology.length', legendVar);
plotTSeriesMatrix(a,b,2, wormWidthHead, [0, 100], 'morphology.width.head', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Morphology 1', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold', 'FontSize', 8);

fillPage(h, 'papersize', 'A4');
print('-dpsc2', psname, gcf);
close(h);

    

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, wormWidthMidbody, [30,170], 'morphology.width.midbody', legendVar);
plotTSeriesMatrix(a,b,2, wormWidthTail, [20, 90], 'morphology.width.tail', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Morphology 2', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 3;
b = 1;
plotTSeriesMatrix(a,b,1, widthPerLength, [0.05, 0.13], 'morphology.widthPerLength', legendVar);
plotTSeriesMatrix(a,b,2, wormArea, [50000, 130000], 'morphology.area', legendVar);
plotTSeriesMatrix(a,b,3, areaPerLength, [50, 110], 'morphology.areaPerLength', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Morphology 2', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);
%--

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, tracklength, [-700, 700], 'posture.tracklength', legendVar);
plotTSeriesMatrix(a,b,2, eccentricity, [0, 1], 'posture.eccentricity', legendVar);
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Posture 1', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, ampMax, [60, 600],'posture.amplitude.max', legendVar);
plotTSeriesMatrix(a,b,2, ampRatio, [0, 1], 'posture.amplitude.ratio', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Posture 2', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, wavelengthPrimary, [300, 1300], 'posture.wavelength.primary', legendVar);
plotTSeriesMatrix(a,b,2, wavelengthSecondary, [200, 700], 'posture.wavelength.secondary', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Posture 3', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, kinks, [0, 6], 'posture.kinks', legendVar);
plotTSeriesMatrix(a,b,2, directions1, [-250, 250], 'posture.directions.tail2head', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Posture 4', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, bendsHeadMean, [-95, 95], 'posture.bends.head.mean', legendVar);
plotTSeriesMatrix(a,b,2, bendsHeadStd, [-40, 60], 'posture.bends.head.stdDev', legendVar);
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Posture 5', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, bendsNeckMean, [-70, 70],'posture.bends.neck.mean', legendVar);
plotTSeriesMatrix(a,b,2, bendsNeckStd, [-40, 40], 'posture.bends.neck.stdDev', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Posture 6', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, bendsMidbodyMean, [-50, 50], 'posture.bends.midbody.mean', legendVar);
plotTSeriesMatrix(a,b,2, bendsMidbodyStd, [-50, 50],'posture.bends.midbody.stdDev', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Posture 7', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, bendsHipsMean, [-90, 90], 'posture.bends.hips.mean', legendVar);
plotTSeriesMatrix(a,b,2, bendsHipsStd, [-40, 40], 'posture.bends.hips.stdDev', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Posture 8', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, bendsTailMean, [-80, 80],'posture.bends.tail.mean', legendVar);
plotTSeriesMatrix(a,b,2, bendsTailStd, [-50, 50],'posture.bends.tail.stdDev', legendVar);
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Posture 9', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, dirHead, [-180, 180], 'posture.directions.head', legendVar);
plotTSeriesMatrix(a,b,2, dirTail, [-180, 180],'posture.directions.tail', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Posture 10', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, midbodySpeed, [-800, 800],'locomotion.velocity.midbody.speed', legendVar);
plotTSeriesMatrix(a,b,2, midbodyDirection, [-8,8],'locomotion.velocity.midbody.direction', legendVar);
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Locomotion 1', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, headtipSpeed, [-1000, 1000],'locomotion.velocity.headTip.speed', legendVar);
plotTSeriesMatrix(a,b,2, headtipDirection, [-8, 8], 'locomotion.velocity.headTip.direction', legendVar);


axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Locomotion 2', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);
h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, headSpeed, [-1000, 1000],'locomotion.velocity.head.speed', legendVar);
plotTSeriesMatrix(a,b,2, headDirection, [-8 ,8], 'locomotion.velocity.head.direction', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Locomotion 3', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, tailSpeed, [-1000, 1000],'locomotion.velocity.tail.speed', legendVar);
plotTSeriesMatrix(a,b,2, tailDirection, [-8, 8], 'locomotion.velocity.tail.direction', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Locomotion 4', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);


h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, tailTipSpeed, [-1000, 1000],'locomotion.velocity.tailTip.speed', legendVar);
plotTSeriesMatrix(a,b,2, tailTipDirection, [-8,8], 'locomotion.velocity.tailTip.direction', legendVar);
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1, {'Locomotion 5', featureFileName}, 'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, foragingAmp, [-100, 100],'locomotion.bends.foraging.amplitude', legendVar);
plotTSeriesMatrix(a,b,2, foragingAngleSpeed, [-1000, 1000],'locomotion.bends.foraging.angleSpeed', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Locomotion 6', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, headAmp, [-70, 70], 'locomotion.bends.head.amplitude', legendVar);
plotTSeriesMatrix(a,b,2, headFreq, [-2,2], 'locomotion.bends.head.frequency', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Locomotion 5', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');


fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;

plotTSeriesMatrix(a,b,1, midbodyAmp, [-70, 70], 'locomotion.bends.midbody.amplitude', legendVar);
plotTSeriesMatrix(a,b,2, midbodyFreq, [-2, 2], 'locomotion.bends.midbody.frequency', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Locomotion 6', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold');

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

h = figure;
orient(h, 'landscape');
a = 2;
b = 1;
plotTSeriesMatrix(a,b,1, tailAmp, [-60, 70], 'locomotion.bends.tail.amplitude', legendVar);
plotTSeriesMatrix(a,b,2, tailFreq, [-3, 3], 'locomotion.bends.tail.amplitude', legendVar);

axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.2, 1,{'Locomotion 7', featureFileName},'HorizontalAlignment','center','VerticalAlignment', 'top', 'FontWeight', 'bold', 'FontSize', 8);

fillPage(h, 'papersize', 'A4');
print ('-dpsc2', psname, '-append', gcf);
close(h);

    
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

function plotTSeries(ColorSet, j, a,b,c, data, varStr, legendVar)
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


function plotTSeriesMatrix(a, b, c, data, ylimdata, varStr, legendVar)
subplot(a,b,c)
hold on;
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
ax2 = axes('Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
hl2 = line(1:size(data, 2), data, 'LineWidth', 0.5,'Parent',ax2);
xlim(ax1, [1, size(data, 2)]);
xlim(ax2, [1, size(data, 2)]);

ylim(ax1, ylimdata);
ylim(ax2, ylimdata);

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

%legend
hleg = legend(ax2, legendVar);
% Make the text of the legend italic and color it brown
%set(hleg,'FontAngle','italic','TextColor',[.3,.2,.1], 'Location', 'Best')
set(hleg, 'FontSize', 7, 'Location', 'SouthEast');