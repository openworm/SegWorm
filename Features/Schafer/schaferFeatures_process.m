function [widthsArray, eccentricityArray, trackLength, amplitudeRatio,...
    meanOfBendAngles,  stdOfBendAngles,...
    croninAmplitude, croninWavelength1, croninWavelength2, numKinks,...
    eigenAngles, eigenMeanAngles, projectedAmps] = schaferFeatures_process(hObject,...
    eventdata, handles, fileInfo, dataBlock, eigenWorms)
%
% SCHAFERFEATURES_PROCESS This function calculates features defined in Baek et al
% paper from 2002 and Cronin et al paper from 2005
%
% Input:
%   hObject, eventdata, handles -
%   fileInfo - experiment information variable
%   dataBlock - the data that will be used for feature extraction
%   eigenWorms - eigen worms master data
%
% Output:
% -
%
% The methods implemented here are discussed in:
% Journal of neuroscience features 2002
% Baek J-H, Cosman P, Feng Z, Silver J, Schafer WR (2002)
% "Using machine vision system to analyze and classify of C. elegans
% behavioral phenotypes quantitatively" J. Neurosci Meth. 118: 9-21.
% http://www.mrc-lmb.cam.ac.uk/wormtracker/pdf/Baek2002.pdf
%
% BMC Genetics, 2005
% C.J. Cronin, J.E. Mendel, S. Mukhtar, Young-Mee Kim, R.C. Stirb, J. Bruck,
% P.W. Sternberg
% "An automated system for measuring parameters of nematode
% sinusoidal movement" BMC Genetics 2005, 6:5
%
% This function also calculates worm kinks. The code for that was written
% by Ev Yemini in December 2011 at MRC LMB
% This function also calculates eigenWorms. The code for that was written
% by Andre Brown in November 2011 at MRC LMB. Andre contributed
% significantly for the eccentricity code as well.
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

mydata = guidata(hObject);
%schaferOutName = fileInfo.expList.results.schafer;

% The worm is roughly divided into 24 segments of musculature (i.e., hinges
% that represent degrees of freedom) on each side. Therefore, 48 segments
% around a 2-D contour.
% Note: "In C. elegans the 95 rhomboid-shaped body wall muscle cells are
% arranged as staggered pairs in four longitudinal bundles located in four
% quadrants. Three of these bundles (DL, DR, VR) contain 24 cells each,
% whereas VL bundle contains 23 cells." - www.wormatlas.org
% Thus - we have normalized worm in 49 segments
% Given that we have 48 segmentas and 49 points, our mid point is at point 25. This might
% change in the future. For now its defined as a constant.
NOOFSEGMENTS = 48;
NOOFPOINTS = 49;

% % Lets load the xml file with the calibration data
% calibrationFile = fileInfo.expList.xml;
% if exist(calibrationFile, 'file') == 2
%     [pixel2MicronScale, ~] = readPixels2Microns(calibrationFile);
%     % Pre-compute values.
%     %pixel2MicronArea = sum(pixel2MicronScale .^ 2) / 2;
%     %pixel2MicronMagnitude = sqrt(pixel2MicronArea);
% else
%     errorMsg = strcat('Experiment annotation xml file:', {''}, strrep(calibrationFile,'\','/'), {' '}, 'not found!');
%     error('schaferFeatures:fileNotFound', errorMsg{1});
% end

% Define data structures to store results
datLen = length(dataBlock{1});
widthsArray = nan(2,datLen);
eccentricityArray = nan(1,datLen);
trackLength = nan(1,datLen);
amplitudeRatio = nan(1,datLen);

croninAmplitude = nan(1,datLen);
croninWavelength1 = nan(1,datLen);
croninWavelength2 = nan(1,datLen);

bendAngle{datLen} = [];
meanOfBendAngles = nan(5, datLen);
stdOfBendAngles = nan(5,datLen);

% Main loop
for j = 1 : datLen
    % Update the GUI
    %str1 = strcat('Extracting Baek et al features for frame',{' '},sprintf('%d',j),{' '}, 'out of',{' '},num2str(datLen));
    %set(handles.status1,'String',str1{1});
    drawnow;
    % If data exists
    if dataBlock{1}(j) == 's'
        % Get the outline and skeleton coordinates
        skCoords = dataBlock{4}(:,:,j);
        
        % Get the widths
        tipWidthHead = mean(dataBlock{8}(1:round(1/6*NOOFPOINTS), j));
        tipWidthTail = mean(dataBlock{8}(round(5/6*NOOFPOINTS)+1:end, j));
        widthsArray(:,j) = [tipWidthHead, tipWidthTail];
        
        % get eccentricity and angle
        % here we are retrieving the coordinate values for x and y from
        % norm worms struct
        % The first and last values overlap so we will go from end-1
        % bacwards to 2 for one of the sides
        x = [dataBlock{2}(:,1,j); dataBlock{3}(end-1:-1:2,1,j)];
        y = [dataBlock{2}(:,2,j); dataBlock{3}(end-1:-1:2,2,j)];
        
        % Lets check if all of the data is not NaN by any chance. This can
        % happen when the segmentation occured but during normWorm the
        % segmented result was discarded
        if all(~isnan(x)) || all(~isnan(y))
            % 50 here is the length of the grid size to be used to fill in
            % the region of interest.  50 gives reasonable values quickly for our data.
            [eccentricityVal, thetaVal] = getEccentricity(x, y, 50);
            
            try
                eccentricityArray(j) = eccentricityVal;
            catch ME1
                msgString = getReport(ME1, 'extended','hyperlinks','off');
                msgbox(msgString);
                eccentricityVal = NaN;
                eccentricityArray(j) = eccentricityVal;
            end
            
            % Here we calculate amplitude and wavelength as defined by Cronin
            % et al.
            guiItem = '';
            wormLen = dataBlock{7}(j);
            
            try
                % We convert thetaVal to radians
                thetaValRad = thetaVal * (pi/180);
            catch ME1
                msgString = getReport(ME1, 'extended','hyperlinks','off');
                msgbox(msgString);
                thetaVal = NaN;
                thetaValRad = thetaVal * (pi/180);
            end
            
            try
                [ampt, wavelnths, trackLen, ampRatio] = getAmpWavelength(thetaValRad, skCoords, wormLen, mydata.mainImg, guiItem, 0, 0);
            catch ME1
                msgString = getReport(ME1, 'extended','hyperlinks','off');
                msgbox(msgString);
                ampt = NaN;
                wavelnths(1) = NaN;
                wavelnths(2) = NaN;
                trackLen = NaN;
                ampRatio = NaN;
            end
            croninAmplitude(j) = ampt;
            croninWavelength1(j) = wavelnths(1);
            croninWavelength2(j) = wavelnths(2);
            trackLength(j) = trackLen;
            amplitudeRatio(j) = ampRatio;
            
            % bendAngle
            bendAngle{j} = dataBlock{5}(:,j);
            
            % We will take 5 areas along the skeleton of the worm and call them:
            % head, neck, mid body, hips and tail.
            % "The 16 head muscle cells are the most anterior and receive
            % input from neurons in the head and nerve ring. The 16 neck
            % muscles accept mixed innervation from both head and ventral
            % cord motor neurons. The remaining 63 body muscles synapse
            % exclusively with VNC motor neurons." The Neurobiology of C.
            % Elegans By Eric Aamodt. Page 128.
            % We have 95 muscles and we have 16 belonging to head and 16
            % belonging to neck. There are 4 quadrants in the worm so the
            % number of muscles in the head and neck are:
            HEADSIZE = (95/4)/4;
            NECKSIZE = (95/4)/4;
            
            % Divide by 4 quadrants:
            % 95/4 = 23.75 is the number of muscles
            % 16/4 = 4 is the number of muscles that belong to the head
            % It is also a 1/6th of the worm
            
            % Sometimes we deal with head and tail without knowing which
            % one is which therefore to data mine the variation of
            % curvature in the tail we assume simmilar division for hips
            % and tail:
            HIPSIZE = (95/4)/4;
            TAILSIZE = (95/4)/4;
            % Another possible motivation here could be aboc and pboc
            % related locations. Defacation muscles around the tail could
            % be a hint of where the variation can be found in the tail.
            
            % We have NOOFSEGMENTS and determine the size of head and neck
            % according to the number of points that we have.
            
            HEADSIZEPOINTS = round(NOOFSEGMENTS/HEADSIZE);
            NECKSIZEPOINTS = round(NOOFSEGMENTS/NECKSIZE);
            HIPSIZEPOINTS = round(NOOFSEGMENTS/HIPSIZE);
            TAILSIZEPOINTS = round(NOOFSEGMENTS/TAILSIZE);
            
%             meanOfBendAngles(1,j) = nanmean(bendAngle{j}(1:HEADSIZEPOINTS));
%             meanOfBendAngles(2,j) = nanmean(bendAngle{j}(HEADSIZEPOINTS+1:HEADSIZEPOINTS+NECKSIZEPOINTS));
%             meanOfBendAngles(3,j) = nanmean(bendAngle{j}(HEADSIZEPOINTS+NECKSIZEPOINTS+1:end-HIPSIZEPOINTS-TAILSIZEPOINTS));
%             meanOfBendAngles(4,j) = nanmean(bendAngle{j}(end-HIPSIZEPOINTS-TAILSIZEPOINTS+1:end-TAILSIZEPOINTS));
%             meanOfBendAngles(5,j) = nanmean(bendAngle{j}(end-TAILSIZEPOINTS-1:end));
%             
%             stdOfBendAngles(1,j) = nanstd(bendAngle{j}(1:HEADSIZEPOINTS));
%             stdOfBendAngles(2,j) = nanstd(bendAngle{j}(HEADSIZEPOINTS+1:HEADSIZEPOINTS+NECKSIZEPOINTS));
%             stdOfBendAngles(3,j) = nanstd(bendAngle{j}(HEADSIZEPOINTS+NECKSIZEPOINTS+1:end-HIPSIZEPOINTS-TAILSIZEPOINTS));
%             stdOfBendAngles(4,j) = nanstd(bendAngle{j}(end-HIPSIZEPOINTS-TAILSIZEPOINTS+1:end-TAILSIZEPOINTS));
%             stdOfBendAngles(5,j) = nanstd(bendAngle{j}(end-TAILSIZEPOINTS-1:end));

            meanOfBendAngles(1,j) = nanmean(bendAngle{j}(1:HEADSIZEPOINTS+1));
            meanOfBendAngles(2,j) = nanmean(bendAngle{j}(HEADSIZEPOINTS+1:HEADSIZEPOINTS+NECKSIZEPOINTS+1));
            meanOfBendAngles(3,j) = nanmean(bendAngle{j}(HEADSIZEPOINTS+NECKSIZEPOINTS+1:end-HIPSIZEPOINTS-TAILSIZEPOINTS));
            meanOfBendAngles(4,j) = nanmean(bendAngle{j}(end-HIPSIZEPOINTS-TAILSIZEPOINTS-1:end-TAILSIZEPOINTS-1));
            meanOfBendAngles(5,j) = nanmean(bendAngle{j}(end-TAILSIZEPOINTS-1:end));
            
            stdOfBendAngles(1,j) = nanstd(bendAngle{j}(1:HEADSIZEPOINTS+1));
            stdOfBendAngles(2,j) = nanstd(bendAngle{j}(HEADSIZEPOINTS+1:HEADSIZEPOINTS+NECKSIZEPOINTS+1));
            stdOfBendAngles(3,j) = nanstd(bendAngle{j}(HEADSIZEPOINTS+NECKSIZEPOINTS+1:end-HIPSIZEPOINTS-TAILSIZEPOINTS-1));
            stdOfBendAngles(4,j) = nanstd(bendAngle{j}(end-HIPSIZEPOINTS-TAILSIZEPOINTS-1:end-TAILSIZEPOINTS-1));
            stdOfBendAngles(5,j) = nanstd(bendAngle{j}(end-TAILSIZEPOINTS-1:end));
        end
    end
end

% Calcualte kinks
% use a window of 6 points for finding maxima/minima
% spatialScale = 6;
% Measure the transitions (crossovers) between peaks
% isPeaks = 0;
% The crossover threshold (ideally the angle should be 0 but, due to sampling, we'll settle for < 15)
% crossThr = 15;
%[numKinks, ~] = wormKinks(dataBlock{4}, spatialScale, isPeaks, crossThr);

[numKinks, ~, ~] = wormKinks(dataBlock{5});

% If you want to plot the kinks (bends) onto the worm in the worm path GUI
% (when viewing the kinks feature). Use this:

% blockIndex is current frame's index in the block.
% [numKinks, ~, kinkIndices] = wormKinks(normBlock?{5});
% get the skeleton point indices for the kinks
% wormSkeleton = squeeze(normBlock?{4}(:,:,blockIndex));
% get the worm skeleton
% hold on;
% plot over the skeleton you already have
% plot(wormSkeleton(kinkIndices{i},1),wormSkeleton(kinkIndices{i},2),'g.');
% plot the kink points as green dots

% Calculate eigenWorms
% Make the tangent angle array
[eigenAngles, eigenMeanAngles] = makeAngleArray(dataBlock{4}(:,1,:), dataBlock{4}(:,2,:));
% project the angle array onto eigenWorms
numEigWorms = 6;
interpNaN = 0;
[projectedAmps, ~] = eigenWormProject(eigenWorms, eigenAngles, numEigWorms, interpNaN);

eigenAngles = eigenAngles';
eigenMeanAngles = eigenMeanAngles';
projectedAmps = projectedAmps';
guidata(hObject,mydata);