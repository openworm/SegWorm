function [ampt, wavelengths, trackLength, ampRatio] = getAmpWavelength(theta, skelCoords, wormLen,...
    axesName, item_selected, verbose, frameNo)
% GETAMPWAVELENGTH This function computes the amplitude and the wavelength
% for the skeleton as described in Cronin et al paper.
% Input:
%       theta - the angle of theh worm
%       skelCoords - x and y coordinates for the skeleton in absolute
%       values
%       wormLen - wormLength
%       axesName - the name of the axes that will be used to draw the
%       resukt
%       verbose - flag to either draw the bounding box or not
%       item_selected - which item is selected in the GUI
%       frameNo - frame number
%Output:
%       ampt - ampliture
%       wavelnth - wavelength
%
% Note: This code was taken directly from matlab code published by Cronin
% et al. in this publication:
% BMC Genetics, 2005
% C.J. Cronin, J.E. Mendel, S. Mukhtar, Young-Mee Kim, R.C. Stirb, J. Bruck,
% P.W. Sternberg
% "An automated system for measuring parameters of nematode
% sinusoidal movement" BMC Genetics 2005, 6:5
%
% It was received from Cronin from personal communication and his agreement
% to use it was received.
% It is therefore not owend or claimed to be owned by creators of the Worm
% Analysis Toolbox at Schafer lab, MRC Laboratory of Molecular Biology
%
% These two features as they are describe in Cronin et al code:
%   - ampt - vector containing the instantaneous wormtrack amplitudes
%               or, more precisely, at each "time" the width of a
%               bounding box aligned with the worm's velocity vector
%               (the direction the rear 2/3 of the worm is traveling
%               at that moment).
%           - TJ: Here, however, we use the angle that is achieved from the
%           best fit ellipse which is much less noisy when compared to the
%           velocity vector. The angle comes as an input to this function.
%
%   - wavelnth - vector contaning the instantaneous wormtrack
%               wavelengths.  Calculated by: at each time snapshot,
%               aligning the worm's velocity vector with the x-axis,
%               performing a spatial (as opposed to temporal) fast
%               Fourier transform (FFT) for the y-coordinates of the
%               worm's posture (yielding cycles/pixel), inverting
%               (to get pixels/cycle), and scaling to the desired units.
%               - TJ: Once again instead of the velocity vector angle we
%               will use an angle obtained from best fit elipse analysis.
%

%Initialize output data structure
%wavelengths = nan(1,2);
% Establish x&y coordinate vectors
%xx = skelCoords(:,2)';
%yy = skelCoords(:,1)';

xx = skelCoords(:,1)';
yy = skelCoords(:,2)';

%----TRACK AMPLITUDE--------------------------------------

% Define the rotation matrix, 
% The direction of vector rotation is counterclockwise if ? is positive 
% (e.g. 90°), and clockwise if ? is negative (e.g. -90°).
B = [cos(-theta)  -sin(-theta)   ;
     sin(-theta)   cos(-theta)   ];
% Rotate the skeleton coordinates
ww = B*[xx;yy];

% Define number of points and intervals in the skeleton
npts = size(ww, 2);
nintervals = npts - 1;

% Parse transformed worm-coordinate matrix 
% x&y coordinate vectors
wwx = ww(1,:);
wwy = ww(2,:);

% Display rotated skeleton and bounding box
if verbose && strcmp(item_selected, 'amplitudeCronin')
    % Establish velocity direction as centerline
    % Reference point at ~middle of worm
    midptx = nanmean(xx);
    midpty = nanmean(yy);

    % 1st CL endpoint
    endptxa = midptx + wormLen*cos(theta);
    endptya = midpty + wormLen*sin(theta);
    % 2nd CL endpoint
    endptxb = midptx - wormLen*cos(theta);
    endptyb = midpty - wormLen*sin(theta);
    
    CLx = [endptxa endptxb];    % x&y coordinate vectors
    CLy = [endptya endptyb];
    CL = [CLx; CLy];    % Matrix of CL x's & y's

    bboxtransformed = ...
        [min(wwx)   max(wwx)   max(wwx)   min(wwx);
        min(wwy)   min(wwy)   max(wwy)   max(wwy)];
    bboxtransformed = [bboxtransformed, bboxtransformed(:,1)];
%     plot(wwx,wwy,'b-')
%     hold on;
%     CLtransformed = [wwx;wwy];
%     plot(CLtransformed(1,:),CLtransformed(2,:), 'r-')
%     plot(bboxtransformed(1,:), bboxtransformed(2,:), 'g-');
%     hold off;
%     axis equal;
    
    % Display the original orientation of the worm with bounding box

    % Un-transform bounding box
    bbox = B \ bboxtransformed;
    bbox = [bbox, bbox(:,1)];       % Close the bounding box loop
    bbox = bbox(1:2,:);             % Trim off bottom row of 1's
    
    % % % %     % Parse matrices
    % % % %     CLx = CL(1,:);
    % % % %     CLy = CL(2,:);
    
    % Plot worm with CL and bounding box
    plot(xx,yy,'b-')
    hold on;
    plot(CLx,CLy, 'r-')
    plot(bbox(1,:), bbox(2,:), 'g-');
    hold off
    axis equal;
end

% Here they figure out which skeleton is curved and can't be represented as
% a function

% Check whether the worm is correctly oriented along the x-axis.
% That is, X should be monotonically increasing or decreasing, 
% and never have two points directly above each other
dwwx = diff(wwx);
% Initialize flag.
badWormOrient=0;
% Check if first two points are directly above each other.
if (dwwx(1,1)~=0)
    ndwwx=dwwx/dwwx(1,1);
    if any(ndwwx<=0)
        % If not, normalize against first interval.
        % Any negatives here indicate a worm in an
        % S-shape, violating the monotonically
        % increasing or decreasing requirement,
        % so... Set flag.
        badWormOrient = 1;
    end
else
     % Set flag for first two points sharing an X value.
    badWormOrient = 1;
end

% We have rotated the coordinates around the origin at the axes, not at the
% centroid of the worm. Now center at the origin by subtracting the
% centroid coordinates
midptxRot = nanmean(wwx);
midptyRot = nanmean(wwy);

wwx = wwx - midptxRot; 
wwy = wwy - midptyRot; 
% Calculate track amplitude 
ampt = nanmax(wwy) - nanmin(wwy);

% Calculate track length
trackLength = nanmax(wwx)-nanmin(wwx);
amp1 = max(wwy(wwy>0));
amp2 = max(abs(wwy(wwy<0)));
ampRatio = min(amp1,amp2)/max(amp1,amp2);

% Wavelength
if (badWormOrient>0)
    wavelengths = [nan, nan];
else
    % for non-curled worms, can measure wavelength
    % Interpolate signal to position vertices equally
    %   distributed along X-axis...
    % (NOTE: Using signal as a factor of X-position, NOT TIME!
    %   Hence, references of "frequency" are "spatial frequency,"
    %   not temporal frequency)
    
    % Reference vector of equally distributed X-positions
    iwwx = [wwx(1) : (wwx(end)-wwx(1))/nintervals : wwx(end)];
    % Signal interpolated to reference vector
    try
        iwwy = interp1(wwx, wwy, iwwx);
    catch ME1
        msgString = getReport(ME1, 'extended','hyperlinks','off');
        msgbox(msgString);
    end
    % Calculate spatial frequency of signal (cycles/PIXEL)
    % TJ: 512 - number of sampling points
    iY = fft(iwwy, 512);
    % Power of constitutive "frequency" components (From Matlab online
    % documentation for _fft [1]_)
    iPyy = iY.* conj(iY) / 512;
    % Worm length (pixels) of the bounding box
    
    xlength = max(iwwx) - min(iwwx);
    
    
    % Vector of "frequencies" (cycles/pixel), from 0 (steady state factor)
    % to Nyquist frequency (i.e. 0.5*sampling frequency).
    % (In our case sampling frequency is typically 12 samples per worm).
    % (Nyquist frequency is the theoretical highest frequency that can be
    % accurately detected for a given sampling frequency.)
    f = (nintervals/xlength) * (0:256)/512;
    
    % Define search distance
    distance = 5; % round(257/48); -- we can try 10 if this gives poor
    % Peak discrimination
    % MaxPeaksDist is a function written by Ev Yemini to find peaks
    [peaks indx] = maxPeaksDist(iPyy(1:257), distance);
    
    % We will filter the peaks that are smaller than 1/2 of the maximum
    % peak value
    indxFilt = indx(peaks>max(peaks)/2);
    
    wavelnthArray = 1./f(indxFilt);
    
    wavelnth2 = NaN;
    
    wavelnth1 = wavelnthArray(1);
    if length(indxFilt) > 1
        wavelnth2 = wavelnthArray(2);
    end
    % We will cap the value of wavelength to be at most 2x the length of
    % the worm
    if wavelnth1 > 2*wormLen
        wavelnth1 = 2*wormLen;
    end
    if wavelnth2 > wormLen
        wavelnth2 = 2*wormLen;
    end
	% Save wavelength
    wavelengths = [wavelnth1, wavelnth2];
    
    % Display
    if verbose && (strcmp(item_selected, 'wavelength1') || strcmp(item_selected, 'wavelength2')) 
        peaksFilt = peaks(peaks>max(peaks)/2);
        plot(iPyy(1:256));
        text(indxFilt, peaksFilt, 'X', 'Color', 'r')
        text(200,max(iPyy)/2, ['Frame:',num2str(frameNo)])
        text(200,max(iPyy)/2.5, ['Wavelength1  :',num2str(wavelnth1)])
        text(200,max(iPyy)/3, ['Wavelength2  :',num2str(wavelnth2)])
    end
    
end
