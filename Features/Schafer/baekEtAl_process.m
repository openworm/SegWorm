function baekEtAl_process(hObject, eventdata, handles, fileInfo, dataBlock, blockName, myAviInfo)
% BAEKETAL_PROCESS This function calculates features defined in Baek et al
% paper from 2002. Since 01-12-2011 it also includes the amplitude and
% wavelength features as defined in Cronin et al paper in 2005.
%
% Input:
%   hObject, eventdata, handles -
%   fileInfo - experiment information variable
%   dataBlock - the data that will be used for feature extraction
%   blockName - block name of interest
%   myAviInfo - info on the video file
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
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

mydata = guidata(hObject);
schaferOutName = fileInfo.expList.results.schafer;

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
MIDPOINT = 25;

% % Lets load the xml file with the calibration data
% calibrationFile = fileInfo.expList.xml;
% if exist(calibrationFile, 'file') == 2
%     [pixel2MicronScale, ~] = readPixels2Microns(calibrationFile);
%     % Pre-compute values.
%     pixel2MicronArea = sum(pixel2MicronScale .^ 2) / 2;
%     pixel2MicronMagnitude = sqrt(pixel2MicronArea);
% else
%     errorMsg = strcat('Experiment annotation xml file:', {''}, strrep(calibrationFile,'\','/'), {' '}, 'not found!');
%     error('schaferFeatures:fileNotFound', errorMsg{1});
% end

% Calcuate width as defined in the paper
% on page 3 of the paper 1mm is defined as 312.5 pixel beacuse of the
% magnification they used
% Thus, the widths at the middle of the worm and 7px from each end are
% calcualted
% 1000 microns = 312.5px
% 1px = 1000 microns/312.5;
% 1px = 3.2 microns;
%
% 7px = 7*(1000/312.5)microns;
% 7px = 22.4microns;
%
% So their 7px distance from the end is effectivelly 22.4 microns

% We have normalized worms to 49 points. Lets figure out which point on the
% outline is these 22.4 microns closest to.
MICRONSDIST = 22.4;
pixEndOffset = round((NOOFPOINTS * MICRONSDIST)/1000);

% Define data structures to store results
datLen = length(dataBlock{1});
widthsArray = nan(datLen,3);
eccentricityArray = nan(datLen,1);
MERarray = nan(datLen,3);
skelAmplitude = nan(datLen,1);
skelAmpRatio = nan(datLen,1);
angChangeRate = nan(datLen,1);

croninAmplitude = nan(datLen,1);
croninWavelength1 = nan(datLen,1);
croninWavelength2 = nan(datLen,1);

curvature{datLen} = [];
meanCurvaturePoints = nan(datLen, 5);
stdCurvaturePoints = nan(datLen, 5);

img2 = zeros(myAviInfo.height, myAviInfo.width);

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
        outlineCoordsVulvaSide = dataBlock{2}(:,:,j);
        outlineCoordsNonVulvaSide = dataBlock{3}(:,:,j);
        
        % Get the widths
        minWidth1 = dataBlock{8}(1+pixEndOffset, j);
        minWidth2 = dataBlock{8}(NOOFPOINTS-pixEndOffset, j);
        minWidth3 = dataBlock{8}(MIDPOINT, j);
        widthsArray(j,:) = [minWidth1, minWidth2, minWidth3];
        
        % Define the absolute coordinates based ROI
        varB = outlineCoordsNonVulvaSide;
        varA = outlineCoordsVulvaSide;
        var1 = [varA(1:end-1,:); flipud(varB(2:end,:))];
        
        minVal1 = min(min(var1(:,1)));
        dim1 = max(round(var1(:,1) - minVal1));
        
        minVal2 = min(min(var1(:,2)));
        dim2 = max(round(var1(:,2) - minVal2));
        img1 = zeros(dim1, dim2);

        outlineCoordsRec = [var1(:,1) - minVal1, var1(:,2) - minVal2];
        img2 = roipoly(img1, outlineCoordsRec(:, 2), outlineCoordsRec(:,1));
        s = regionprops(img2, 'Orientation', 'Eccentricity', 'Area');
        % In case there is a whip or other artifacts - we
        % choose the biggest connected component
        if length(s) > 1
            [~,ind1] = max([s.Area]);
            s = s(ind1);
        end
    
        % calculate best fit ellipse using least squares method
        % ellipse_t = fit_ellipse(outlineCoords(:,1), outlineCoords(:,2));
        % eccentricity = sqrt(1-(ellipse_t.short_axis/ellipse_t.long_axis)^2);
        % It takes longer on a small video test case, hence commented out
        %
        % Debug
        % figure;plot(outlineCoords(:,2), outlineCoords(:,1));
        % ellipse_t = fit_ellipse(outlineCoords(:,1), outlineCoords(:,2), fig1);
        
        eccentricityArray(j) = s.Eccentricity;
        
        % Get the minimum enclosing rectangle (MER)
        outlineCoords = [outlineCoordsVulvaSide(1:end-1,:); flipud(outlineCoordsNonVulvaSide(2:end,:))];
        rotOutlineCoords = rotLineSegment(outlineCoords, -s.Orientation*(pi/180));
        %rotSkelCoords = rotLineSegment(skCoords, -s.Orientation*(pi/180));
        
        % Here we calculate amplitude and wavelength as defined by Cronin
        % et al.
        guiItem = '';
        wormLen = dataBlock{7}(j);
        [ampt, wavelnths] = getAmpWavelength(-s.Orientation*(pi/180), skCoords, wormLen, mydata.mainImg, guiItem, 0);
        croninAmplitude(j) = ampt;
        croninWavelength1(j) = wavelnths(1);
        croninWavelength2(j) = wavelnths(2);
        
        % Minimal enclosing rectangle as defined by Baek et al.
        yxWidth = max(rotOutlineCoords)-min(rotOutlineCoords);
        % saving the bounding box values, xWidth, yWidth, ratio
        MERarray(j,:) = [yxWidth(2), yxWidth(1), yxWidth(2)/yxWidth(1)];
        
        % Calculating approx amplitude
        % First, lets get the line equation for the end points of
        % the skeleton. A good description on maths regarding this can be found:
        % http://math.ucsd.edu/~wgarner/math4c/derivations/distance/distptline.htm
        
        % Defining the end points of the skeleton
        endPoints = skCoords([1,end],:);
        % Getting line equation
        [~, m, b, lineMode, c] = getLineCoeff(endPoints, 2);
        if lineMode==3
            %normal line
            pepDist = (skCoords(:,1)-m*skCoords(:,2)-b)/sqrt(m^2+1);
        elseif lineMode==1
            %vertical line
            pepDist = skCoords(:,2)-c;
        elseif lineMode==2
            %horizontal line
            pepDist = skCoords(:,1)-c;
        end
        
        % Here we divide the distance from each point on the skeleton to
        % the line into two groups - positive and negative. The points
        % above the line from heat to tail and the points below.
        % Computing the amplitude
        if isempty(pepDist(pepDist>0))
            skelAmp = max(abs(pepDist(pepDist<0)));
        elseif isempty(pepDist(pepDist<0))
            skelAmp = max(abs(pepDist(pepDist>0)));
        else
            skelAmp = max(abs(pepDist(pepDist>0))) + max(abs(pepDist(pepDist<0)));
        end
        % Computing the amplitude ratio
        if max(abs(pepDist(pepDist>0))) == 0
            skelAmpR = 0;
        elseif max(abs(pepDist(pepDist<0))) == 0
            skelAmpR = 0;
        else
            % This case will be called when both parts of the amplitude are
            % not zero
            if isempty(pepDist(pepDist>0))
                skelAmpR = 0;
            elseif isempty(pepDist(pepDist<0))
                skelAmpR = 0;
            else
                skelAmpR = min(max(abs(pepDist(pepDist>0))), max(abs(pepDist(pepDist<0))))/...
                    max(max(abs(pepDist(pepDist>0))), max(abs(pepDist(pepDist<0))));
            end
        end
        
        skelAmplitude(j) = skelAmp;
        skelAmpRatio(j) = skelAmpR;
        
        % Curvature
        curvature{j} = dataBlock{5}(:,j);
        
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
        
        meanCurvaturePoints(j,1) = nanmean(dataBlock{5}(1:HEADSIZEPOINTS, j));
        meanCurvaturePoints(j,2) = nanmean(dataBlock{5}(HEADSIZEPOINTS+1:HEADSIZEPOINTS+NECKSIZEPOINTS, j));
        meanCurvaturePoints(j,3) = nanmean(dataBlock{5}(HEADSIZEPOINTS+NECKSIZEPOINTS+1:end-HIPSIZEPOINTS-TAILSIZEPOINTS, j));
        meanCurvaturePoints(j,4) = nanmean(dataBlock{5}(end-HIPSIZEPOINTS-TAILSIZEPOINTS+1:end-TAILSIZEPOINTS, j));
        meanCurvaturePoints(j,5) = nanmean(dataBlock{5}(end-TAILSIZEPOINTS-1:end, j));
        
        stdCurvaturePoints(j,1) = nanstd(dataBlock{5}(1:HEADSIZEPOINTS, j));
        stdCurvaturePoints(j,2) = nanstd(dataBlock{5}(HEADSIZEPOINTS+1:HEADSIZEPOINTS+NECKSIZEPOINTS, j));
        stdCurvaturePoints(j,3) = nanstd(dataBlock{5}(HEADSIZEPOINTS+NECKSIZEPOINTS+1:end-HIPSIZEPOINTS-TAILSIZEPOINTS, j));
        stdCurvaturePoints(j,4) = nanstd(dataBlock{5}(end-HIPSIZEPOINTS-TAILSIZEPOINTS+1:end-TAILSIZEPOINTS, j));
        stdCurvaturePoints(j,5) = nanstd(dataBlock{5}(end-TAILSIZEPOINTS-1:end, j));
        
    end
end
% update the blockList array
load(schaferOutName,'blockList');
lenBlockList = length(blockList);
blockList{lenBlockList+1} = blockName;
save(schaferOutName,'-append', 'blockList');

% Save the data
dataOut.widthsArray = widthsArray;
dataOut.eccentricityArray = eccentricityArray;
dataOut.MERarray = MERarray;
dataOut.skelAmplitude = skelAmplitude;
dataOut.skelAmpRatio = skelAmpRatio;
dataOut.curvature = curvature;
dataOut.meanCurvaturePoints = meanCurvaturePoints;
dataOut.stdCurvaturePoints = stdCurvaturePoints;

dataOut.croninAmplitude = croninAmplitude;
dataOut.croninWavelength1 = croninWavelength1;
dataOut.croninWavelength2 = croninWavelength2;

eval(strcat(blockName,'= dataOut;'));
clear('dataOut');
execString = strcat('save('' ',schaferOutName,''',''-append'',''',blockName,''');');
eval(execString);
guidata(hObject,mydata);