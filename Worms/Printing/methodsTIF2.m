function [filename pages] = methodsTIF(filename, varargin)
%METHODSTIF Save worm details to a TIF.
%
%   [FILENAME PAGES] = METHODSTIF(FILENAME)
%
%   [FILENAME PAGES] = METHODSTIF(FILENAME, ISSHOW, PAGE, SAVEQUALITY,
%                                 ISCLOSE, ISVERBOSE)
%
%   Inputs:
%       filename    - the TIF filename
%       isShow      - are we showing the figures onscreen?
%                     Note: hiding the figures is faster.
%       page        - the page number;
%                     if empty, the page number is not shown
%       saveQuality - the quality (magnification) for saving the figures;
%                     if empty, the figures are not saved
%                     the default is none (empty)
%       isClose     - shoud we close the figures after saving them?
%                     when saving the figure, the default is yes (true)
%                     otherwise, the default is no (false)
%       isVerbose   - verbose mode displays the progress;
%                     the default is yes (true)
%   Output:
%       filename - the TIF file containing the saved figures;
%                  if empty, the figures were not saved
%       pages    - the number of pages in the figure file
%
% See also FILTERWORMINFO, FILTERWORMHIST, WORM2HISTOGRAM, WORM2STATSINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we showing the figures onscreen?
% Note: hiding the figures is faster.
isShow = true;
if ~isempty(varargin)
    isShow = varargin{1};
end

% Determine the page number.
pages = 0;
page = 0;
if length(varargin) > 1
    page = varargin{2};
    pages = page;
end

% Determine the quality (magnification) for saving the figures.
saveQuality = []; % don't save the figures
if length(varargin) > 2
    saveQuality = varargin{3};
end

% Are we closing the figures after saving them?
if saveQuality > 0
    isClose = true;
else
    isClose = false;
end
if length(varargin) > 3
    isClose = varargin{4};
end
if ~isShow
    isClose = true;
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 4
    isVerbose = varargin{5};
end



%% Draw the methods.

% Initialize the page information.

% Initialize the texts.
texts = {
    WT2OverviewText()
    WormSegmentationText()
    VentralHeadAnnotationText()
    AbsoluteCoordinatesText()
    FeatureOverviewText()
    MorphologyFeaturesText()
    PostureFeaturesText()
    MotionFeaturesText()
    PathFeaturesText()
    PhenotypicOntologyText()
    FeatureFileOverviewText()
    PDFFilesText()
    CSVFilesText()
    MATFilesText()
    SignificanceMATFilesText()
    AcknowledgementsText()
    ReferencesText()};

% Initialize the titles and remove them from the text.
titleLines = 2;
titles = cell(length(texts), 1);
for i = 1:length(texts)
    titles{i} = [' ' texts{i}{1} ' '];
    texts{i} = texts{i}((titleLines + 1):end);
end

% Initialize the text pages.
linesPerPage = 35;
textPageOff = page + 2;
textPages = nan(length(texts), 1);
for i = 1:length(texts)
    textPages(i) = floor(textPageOff);
    numPages = ceil(length(texts{i}) / linesPerPage);
    textPageOff = textPageOff + numPages * 0.5;
end

% Display the progress.
if isVerbose
    disp('Printing the methods table of contents ...');
end

% Create a figure.
page = page + 1;
h = figure;
visStr = 'off';
if isShow
    visStr = 'on';
end
set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
    'PaperType', 'A2', 'Visible', visStr);
hold on;

% Initialize the drawing information.
fontSize1 = 32;
fontSize2 = 24;
tocTitleColor = str2colors('k');
tocSectionNumColor = str2colors('k', 0.5);
tocSectionColor = str2colors('k', 0.25);
tocPageColor = str2colors('k');
yStart = 0.9;
xOff1 = 0;
xOff2 = 0.02;
xOff3 = 0.1;
xOff4 = 0.98;
yOff = 0.05;

% Draw the methods.
position1 = [0, 0, 0.5, 1];
axis1 = axes('units', 'normalized', 'Position', position1, ...
    'XTick', [], 'YTick', [], 'Parent', h);
position2 = [0.5, 0, 0.5, 1];
axis2 = axes('units', 'normalized', 'Position', position2, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the methods table of contents header.
text(xOff1, 1, ...
    [' \bf' upper('Methods Table of Contents') ' '], ...
    'Color', tocTitleColor, ...
    'FontSize', fontSize1, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'Parent', axis1);

% Draw the methods table of contents.
for i = 1:length(titles)
    
    % Draw the section number.
    text(xOff2, yStart - yOff * (i - 1), ...
        ['   ' num2str(i) '. '], ...
        'Color', tocSectionNumColor, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top', ...
        'Parent', axis1);
    
    % Draw the section title.
    text(xOff3, yStart - yOff * (i - 1), ...
        [' \bf' upper(titles{i}) ' '], ...
        'Color', tocSectionColor, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top', ...
        'Parent', axis1);
    
    % Draw the section page number.
    text(xOff4, yStart - yOff * (i - 1), ...
        [' \it' num2str(textPages(i)) ' '], ...
        'Color', tocPageColor, ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'Parent', axis1);
end



%% Draw the contact information.

% Initialize the drawing information.
headColorStr = color2TeX(str2colors('k', 0.5));
infoColorStr = color2TeX(str2colors('k'));
fontSize1 = 20;
fontSize2 = 16;
contactWidth = 0.5;
contactHeight = 0.2;
xStart = 0.5;
xOff = 0.01;
yOff = 0.15;
emailYOff = .95;
paperYOff = 0.05;

% Initialize the contact information.
emailStr = {[headColorStr 'For questions, please contact ' infoColorStr ...
    '\bfEviatar Yemini\rm' headColorStr ' at ' infoColorStr ...
    '\it\bfEv.Yemini.WT2@gmail.com']};
paperStr = {[headColorStr '\itPlease cite our publication: ' infoColorStr]
    '\bfYemini EI, Grundy LJ, Jucikas T, Brown AEX, Schafer WR'
    '\bfTitle ???'
    '\bfJournal ???'};

% Prepare the contact information.
contactPosition = [xStart, 1 - contactHeight, contactWidth, contactHeight];
contactAxis = axes('units', 'normalized', 'Position', contactPosition, ...
    'XTick', [], 'YTick', [], 'Parent', h);

% Draw the contact information.
for i = 1:length(emailStr)
    text(xOff, emailYOff - (i - 1) * yOff, ...
        [' ' emailStr{i} ' '], ...
        'FontSize', fontSize1, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top', ...
        'Parent', contactAxis);
end

% Draw the paper information.
for i = 1:length(paperStr)
    text(xOff, paperYOff + (i - 1) * yOff, ...
        [' ' paperStr{length(paperStr) - i + 1} ' '], ...
        'FontSize', fontSize2, ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'bottom', ...
        'Parent', contactAxis);
end



%% Draw the methods texts.

% Initialize the drawing information.
sepStr = '   ¤   ';
fontSize = 16;
textColor = str2colors('k');
yStart1 = 0.98;
yStart2 = 0.94;
xOff = 0.03;
yOff = 0.025;

% Draw the methods texts.
textAxis = axis2;
for i = 1:length(texts)
    
    % Display the progress.
    if isVerbose
        disp(['Printing methods ' num2str(i) '/' num2str(length(texts)) ...
            ' ...']);
    end
    
    % Draw the methods text.
    for j = 1:length(texts{i})
        
        % Are we starting a new page?
        textOff = mod(j - 1, linesPerPage);
        if textOff == 0
            
            % Switch to the other half of the page.
            if textAxis == axis1
                textAxis = axis2;
            
            % Create a new page.
            else
                
                % Construct the title for table of contents.
                titleStr = [];
                if i == 1 && j == 1
                    titleStr = 'Methods Table of Contents';
                    
                % Construct the title for the previous figure.
                else
                    
                    % Use the previous title(s).
                    if j - 1 <= linesPerPage
                        if i > 2 && j == 1 && ...
                                length(texts{i - 1}) <= linesPerPage
                            titleStr = [titles{i - 2} sepStr];
                        end
                        titleStr = [titleStr titles{i - 1}];
                    end
                    
                    % Use the current title.
                    if j > 1
                        if ~isempty(titleStr)
                            titleStr = [titleStr sepStr];
                        end
                        titleStr = [titleStr titles{i}];
                    end
                end
                
                % Save the previous figure.
                if saveQuality > 0
                    saveTIF(h, filename, saveQuality, true, ...
                        titleStr, page, isClose);
                    
                % Close the figure.
                elseif ~isShow || isClose
                    close(h);
                end
                
                % Create a new figure.
                page = page + 1;
                h = figure;
                visStr = 'off';
                if isShow
                    visStr = 'on';
                end
                set(h, 'units', 'normalized', 'position', [0 0 1 1], ...
                    'PaperType', 'A2', 'Visible', visStr);
                hold on;
                
                % Draw the methods.
                axis1 = axes('units', 'normalized', ...
                    'Position', position1, ...
                    'XTick', [], 'YTick', [], 'Parent', h);
                axis2 = axes('units', 'normalized', ...
                    'Position', position2, ...
                    'XTick', [], 'YTick', [], 'Parent', h);
                textAxis = axis1;
            end
        end
            
        % Draw the title.
        if j == 1
            text(xOff, yStart1, ...
                ['\bf' titles{i}], ...
                'Color', textColor, ...
                'FontSize', fontSize, ...
                'FontName', 'Courier', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'top', ...
                'Parent', textAxis);
        end
        
        % Draw the line of text.
        text(xOff, yStart2 - yOff * textOff, ...
            [' ' formatTextStr(texts{i}{j}) ' '], ...
            'Color', textColor, ...
            'FontSize', fontSize, ...
            'FontName', 'Courier', ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', ...
            'Parent', textAxis);
    end
end

% Save the last figure.
if saveQuality > 0
    saveTIF(h, filename, saveQuality, true, titles{end}, page, isClose);
    
% Close the figure.
elseif ~isShow || isClose
    close(h);
end

% Compute the pages.
pages = page - pages;
end



%% Format a text string.
function str = formatTextStr(str)

% Initialize the formatting information.
textColor = str2colors('k');
textColorStr = color2TeX(textColor);
httpColor = str2colors('b');
httpColorStr = color2TeX(httpColor);

% Format hyperlinks.
httpStr = 'http://';
httpI = strfind(str, httpStr);
httpIOff = 0;
for i = 1:length(httpI)
    
    % Color the text after the hyperlink.
    j = httpI(i) + length(httpStr) + httpIOff;
    while j < length(str) && str(j + 1) ~= ' ' && str(j + 1) ~= ')'
        j = j + 1;
    end
    str = [str(1:j) textColorStr str((j + 1):end)];
    
    % Color the hyperlink.
    j = httpI(i) + httpIOff;
    str = [str(1:(j - 1)) httpColorStr str(j:end)];
    
    % Advance.
    httpIOff = httpIOff + length(httpColorStr) + length(textColorStr);
end
end



%% Construct the "WT2 Overview" text.
function strs = WT2OverviewText()
strs = {
'WT2 Overview'
''
'The Worm Tracker 2.0 (WT2) hardware guide and free software are available at:'
''
'http://www.mrc-lmb.cam.ac.uk/wormtracker/'
''
'In summary, a camera, illumination, and motorized stage are combined to follow a'
'single worm, navigating a thin bacterial food lawn, on an agar petri dish. The'
'software uses a closed loop wherein live video is used to guide the stage and'
'keep the worm centered within the camera''s field of view (FOV). The petri dish'
'housing the worm is immobile, while the camera, stage, and illumination move as'
'one. Therefore, the worm is isolated from external forces such as stage'
'movement.'
''
'The camera is a DinoLite AM413T with zoom magnification. We use 640x480'
'resolution, 30fps, with a magnification that results in 3.5-4.5 microns/pixels'
'and an FOV of roughly 2.5x2mm at a focal distance of nearly 1cm. Older videos'
'have a frame rate of 20-30fps. New videos maintain 30fps. The illumination is a'
'red, Philips Lumileds, side-emitting, Luxeon III Star (LXHL-FD3C). An opal'
'diffuser provides roughly uniform lighting over the FOV. The wavelength is 627nm'
'to avoid exciting a short-wavelength avoidance response through the C. elegans'
'LITE-1 receptor. Finally, the motorized stage uses Zaber T-NA0850 linear'
'actuators. The stage travels 5cm at up to 8mm/s in orthogonal x and y axes with'
'a resolution of just under 0.05\mum.'
''
'Worms were maintained as previously described in "Preparation of samples for'
'single-worm tracking" (Yemini et al. 2011).  The protocol is also available'
'online:'
''
'http://www.mrc-lmb.cam.ac.uk/wormtracker/webcontent/trackingProtocol.pdf'
''
'Briefly, worms are maintained at room temperature, approximately 22\circC. All'
'plates are fresh, having been poured within 1 week of use and kept at 4\circC'
'until roughly 24 hours before use. Strains are maintained on standard NGM plates'
'(Brenner 1974) seeded with 3 drops of OP50. 6 worms per plate are used to'
'maintain stocks. At least two generations are passaged, in these conditions,'
'prior to tracking. The evening before tracking, at roughly 5pm, L4'
'hermaphrodites are picked to a fresh plate, 10 worms per plate. The next'
'morning, 3.5cm low-peptone NGM plates are seeded with 20\mul of OP50, in the'
'center of the plate, and allowed to dry. This 20\mul drop of OP50 is nearly'
'circular and roughly 8mm in diameter. The L4 worms from the evening before, now'
'young adults, are then transferred to the center of the food on the 3.5cm'
'plates, 1 worm to a plate. The worms are given 30 minutes to habituate, and are'
'then tracked for 15 minutes. A wild-type N2 is always tracked, at the same time,'
'on one of the 8 nearby trackers, serving as a control. Strains are tracked'
'between 8am and 6pm, across several hours and days, and randomly assigned to any'
'of 8 available trackers. In total approximately 25 worms are tracked, per'
'experimental strain, controlled by 65 N2s tracked within the 1 week of the'
'experiments.'
};
end



%% Construct the "Worm Segmentation" text.
function strs = WormSegmentationText()
strs = {
'Worm Segmentation'
''
'Video frames are extracted using the Matlab videoIO toolbox by Gerald Dalley.'
'There is a sharp contrast between the worm and background in our video images.'
'Worm pixels are segmented from the background using the Otsu method (Otsu 1975)'
'to find a threshold. The largest 8-connected component in the thresholded image'
'is assumed to be the worm. Frames in which the worm touches the image'
'boundaries, is too small, lacks a clear head and tail, or has unrealistic body'
'proportions are not analyzed further.  Frames containing stage movement are also'
'removed to eliminate bad segmentations wherein the worm image may be blurred'
'(see the section titled "Absolute Coordinates"). Given our desire for accurate'
'and precise measures as well as the large data volume (due to a high video frame'
'rate), we err on the side of caution and attempt to reject ambiguous'
'segmentations rather than include them.'
''
'Once the worm has been thresholded, its contour is extracted by tracing the'
'worm''s perimeter. The head and tail are located as sharp, convex angles on'
'either side of the contour. The skeleton is extracted by tracing the midline of'
'the contour from head to tail. During this process, widths and angles are'
'measured at each skeleton point to be used later for feature computation. At'
'each skeleton point, the width is measured as the distance between opposing'
'contour points that determine the skeleton midline.  Similarly, each skeleton'
'point serves as a vertex to a bend and is assigned the supplementary angle to'
'this bend. The supplementary angle can also be expressed as the difference in'
'tangent angles at the skeleton point. This angle provides an intuitive'
'measurement. Straight, unbent worms have an angle of 0\circ. Right angles are'
'90\circ. And the largest angle theoretically possible, a worm bending back on'
'itself, would measure 180\circ. The angle is signed to provide the bend''s'
'dorsal-ventral orientation. When the worm has its ventral side internal to the'
'bend (i.e., the vectors forming the angle point towards the ventral side), the'
'bending angle is signed negatively.'
''
'Pixel count is a poor measure of skeleton and contour lengths. For this reason,'
'we use chain-code lengths (Freeman 1961). Each laterally-connected pixel is'
'counted as 1. Each diagonally-connected pixel is counted as \surd2. The'
'supplementary angle is determined, per skeleton point, using edges 1/12 the'
'skeleton''s chain-code length, in opposing directions, along the skeleton. When'
'insufficient skeleton points are present, the angle remains undefined (i.e., the'
'first and last 1/12 of the skeleton have no bending angle defined). 1/12 of the'
'skeleton has been shown to effectively measure worm bending in previous trackers'
'and likely reflects constraints of the bodywall muscles, their innervation, and'
'cuticular rigidity (Cronin et al. 2005).'
};
end



%% Construct the "Ventral Side Annotation and Head Detection" text.
function strs = VentralHeadAnnotationText()
strs = {
'Ventral Side Annotation and Head Detection'
''
'Our worm features necessitate dorsal-ventral and head-tail distinctions.  The'
'worm''s ventral side was annotated for each video by eye. We did not profile'
'rolling mutants and therefore expected worms to maintain their dorsal-ventral'
'orientation. Nevertheless, 126 random videos were examined and the worms therein'
'found never to flip sides. Head-tail orientation was annotated automatically by'
'software. We examined 133 random videos (roughly 1% of our data, 2.25 million'
'segmented frames), a collection of 100 from a quality-filtered set and 33'
'rejected by this filter (see the section titled "Feature File Overview"),'
'representing a broad range of mutants (including several nearly motionless'
'UNCs). Many of these include early videos which suffered multiple dropped frames'
'and poor imaging conditions that were later improved. We found that the head was'
'correctly labeled with a mean and standard deviation of 94.39 \pm 17.54% across'
'individual videos and 95.6% of the frames collectively.'
''
'Before assigning the head and tail, videos are split into chunks in which worm'
'skeletons can be confidently oriented with respect to each other. Chunk'
'boundaries are set whenever there is a gap in skeletonized frames of 0.25'
'seconds or more.  During these gaps, worm motion could make skeleton orientation'
'unreliable. The skeletons within each chunk are aligned by determining which of'
'the 2 possible head-tail orientations minimizes the distance between'
'corresponding skeleton points in subsequent frames. When possible, we unify'
'chunks and heal up to 1/2 second interruptions by determining whether the worm'
'was bent enough to achieve an omega turn and flip its orientation. If so, we'
'trace the worm''s path through its large bend to determine the new orientation.'
'If the path cannot be confidently traced, we avoid healing and maintain separate'
'chunks.'
''
'The head is detected in each chunk of oriented frames. The head and neck perform'
'more lateral motion (e.g., foraging) even in uncoordinated mutants. Therefore,'
'we measure lateral motion at both worm endpoints, across each chunk - unless the'
'chunk is shorter than 1/6 of a second which is too short to reliably measure'
'such motion. In our setup, the head is lighter than the tail. Therefore, we also'
'measure the grayscale intensity at both worm endpoints, across each chunk.'
'Linear discriminant analysis (LDA) was used on a combination of lateral motion'
'and intensity at the worm endpoints for a training set of 68 randomly-chosen'
'videos. This classifier was then used for the entire data set to automatically'
'detect and label the worm''s head.'
};
end



%% Construct the "Absolute Coordinates" text.
function strs = AbsoluteCoordinatesText()
strs = {
'Absolute Coordinates'
''
'Many features require plate (or absolute) coordinates rather than pixel'
'coordinates defined with respect to the camera field of view. Prior to'
'recording, all trackers are regularly calibrated to determine the conversion'
'from pixels to absolute coordinates. When recording is complete, stage movements'
'are matched to their video signature in order to convert segmented worms to'
'absolute coordinates (offset by the stage''s location).'
''
'During recording, every stage movement is logged. When recording has completed,'
'the video is scanned to locate motion frames. Because re-centering the worm'
'causes an abrupt change in both the image background and the worm''s location,'
'these changes are simply measured as the pixel variance in the difference'
'between subsequent frames. The Otsu method is used to find an appropriate'
'threshold for delineating stage-movement frames.  The number of stage movements'
'and the intervals between them are matched against the log of software-issued'
'stage movement commands. If the match fails (an infrequent event usually caused'
'by worms reaching the boundary of their plate or external factors damaging the'
'recording), the worm and its video are discarded and not used. In our data set,'
'roughly 4% of the videos were discarded due to stage-movement failures.'
''
'With the stage movements matched to their video signature, the Otsu threshold is'
'employed once again to compute a local threshold that delineates a more accurate'
'start and end for each individual stage movement. The same algorithm is also'
'employed for the interval at the start of the video until the first stage'
'movement and, similarly, from the last stage movement until the end of the'
'video. With this in place, stage movement frames are discarded and each interval'
'between stage movements is assigned a stage location. Thereafter, each segmented'
'worm is converted to its absolute coordinates on the plate.'
};
end



%% Construct the "Feature Overview" text.
function strs = FeatureOverviewText()
strs = {
'Feature Overview'
''
'All feature formulas are computed from the worm''s segmented contour and'
'skeleton. The skeleton and each side of the contour are scaled down to 49 points'
'for feature computation. Wild-type worms have 4 quadrants of longitudinal,'
'staggered bodywall muscles (Sulston & Horvitz 1977). Each quadrant contains 24'
'such muscles with the exception of the ventral-left quadrant, which has 23. With'
'a sampling of 49 points, the skeleton and contour sides have a well-defined'
'midpoint. Moreover, since the worm is confined to 2 dimensions, its bodywall'
'muscles present roughly 24 degrees of freedom (although in practice it seems to'
'be far less (Stephens et al. 2008)). With 49 points we have 2 samples per degree'
'of freedom and, therefore, expect to be sampling above the Nyquist rate for '
'worm posture.'
''
'A common notation is used to define the body parts. The head is controlled by'
'the first 4 bodywall muscles, per quadrant -- approximately 1/6 the length of'
'the worm (White et al. 1986). Similarly, the neck is controlled by the next 4'
'bodywall muscles, per quadrant -- also approximately 1/6 the length of the worm.'
'For this reason, we define the head as the first 1/6 of the worm and the neck as'
'the next 1/6 of the worm (skeleton points 1-8 and 9-16, respectively). For'
'symmetry, we define the tail and "hips", in a similar manner, on the opposite'
'end of the worm. The tail is the last 1/6 of the worm and the hips are defined'
'as the next 1/6 (skeleton points 42-49 and 34-41, respectively). The midbody is'
'defined as the remaining middle 1/3 of the worm (skeleton points 17-33). For'
'some features, the head and tail are further subdivided to extract their tips,'
'the first and last 1/12 of the worm (skeleton points 1-4 and 46-49),'
'respectively.'
''
'Frame-by-frame features are represented by top-level histograms and statistics'
'as well as subdivisions exploring their values during forward, backward, and'
'paused states. This is to measure behaviors that depend on the state of motion'
'such as foraging amplitude, which is reduced during reversals in wild-type worms'
'(Alkema et al. 2005). Many features are signed to reflect dorsal-ventral'
'orientation, forward-backward trajectory, and other special cases (e.g.,'
'eigenworm projection) to capture any asymmetry. Finally, event-style features'
'(coiling, turning, and motion states) are summarized using global and local'
'measures. Gobal measures include the event frequency, the ratio of time spent'
'within the event to the total experiment time, and a similar measure for the'
'ratio of the distance covered within the event to the total distance traveled by'
'the worm (when available). Local measures include the time spent in every'
'individual event, the distance covered in each event (when available), and both'
'the time and distance covered between each pair of successive events.'
};
end



%% Construct the "Morphology Features" text.
function strs = MorphologyFeaturesText()
strs = {
'Morphology Features'
''
'1. Length. Worm length is computed from the segmented skeleton by converting the'
'chain-code pixel length to microns.'
''
'2. Widths. Worm width is computed from the segmented skeleton. The head,'
'midbody, and tail widths are measured as the mean of the widths associated with'
'the skeleton points covering their respective sections. These widths are'
'converted to microns.'
''
'3. Area. The worm area is computed from the number of pixels within the'
'segmented contour. The sum of the pixels is converted to microns^{2}.'
''
'4. Area/Length.'
''
'5. Midbody Width/Length.'
};
end



%% Construct the "Posture Features" text.
function strs = PostureFeaturesText()
strs = {
'Posture Features'
''
'1. Bends. Worm bending is measured using the supplementary angles to the bends'
'formed along the skeleton, with each skeleton point serving as the vertex to its'
'respective bend. The supplementary angle can also be expressed as the difference'
'in tangent angles at the skeleton point. The supplementary angle provides an'
'intuitive measurement. Straight, unbent worms have an angle of 0\circ. Right'
'angles are 90\circ. And the largest angle theoretically possible, a worm bending'
'back on itself, would measure 180\circ. The supplementary angle is determined,'
'per skeleton point, using edges 1/12 the skeleton''s chain-code length, in'
'opposing directions, along the skeleton. When insufficient skeleton points are'
'present, the angle remains undefined (i.e., the first and last 1/12 of the'
'skeleton have no bending angle defined). The mean and standard deviation are'
'measured for each body segment. The angle is signed to provide the bend''s'
'dorsal-ventral orientation. When the worm has its ventral side internal to the'
'bend, the bending angle is signed negatively.'
''
'2. Bend Count. The bend count is a rough measure of the number of bends along'
'the worm. The supplementary skeleton angles are measured during segmentation and'
'signed to reflect their dorsal-ventral orientation. These angles are convolved'
'with a Gaussian filter, 1/12 the length of the skeleton, with a width defined by'
'the Matlab "gausswin" function''s default \alpha of 2.5 and normalized such that'
'the filter integrates to 1, to smooth out any high-frequency changes. The angles'
'are then sequentially checked from head to tail. Every time the angle changes'
'sign or hits 0\circ, the end of a bend has been found and the count is'
'incremented. Bends found at the start and end of the worm must reflect a segment'
'at least 1/12 the skeleton length in order to be counted. This ignores small'
'bends at the tip of the head and tail.'
''
'3. Eccentricity. The eccentricity of the worm''s posture is measured using the'
'eccentricity of an equivalent ellipse to the worm''s filled contour. The'
'orientation of the major axis for the equivalent ellipse is used in computing'
'the amplitude, wavelength, and track length (described below).'
''
'4. Amplitude. Worm amplitude is expressed in two forms: a) the maximum amplitude'
'found along the worm body and, b) the ratio of the maximum amplitudes found on'
'opposing sides of the worm body (wherein the smaller of these two amplitudes is'
'used as the numerator). The formula and code originate from the publication "An'
'automated system for measuring parameters of nematode sinusoidal movement"'
'(Cronin et al. 2005).'
''
'The worm skeleton is rotated to the horizontal axis using the orientation of the'
'equivalent ellipse and the skeleton''s centroid is positioned at the origin. The'
'maximum amplitude is defined as maximum y coordinate minus the minimum y'
'coordinate. The amplitude ratio is defined as the maximum positive y coordinate'
'divided by the absolute value of the minimum negative y coordinate. If the'
'amplitude ratio is greater than 1, we use its reciprocal.'
''
'5. Wavelength. The worm''s primary and secondary wavelength are computed by'
'treating the worm''s skeleton as a periodic signal. The formula and code'
'originate from the publication "An automated system for measuring parameters of'
'nematode sinusoidal movement" (Cronin et al. 2005).'
''
'The worm''s skeleton is rotated as described above for the amplitude. If there'
'are any overlapping skeleton points (the skeleton''s x coordinates are not'
'monotonically increasing or decreasing in sequence -- e.g., the worm is in an S'
'shape) then the shape is rejected, otherwise the Fourier transform computed. The'
'primary wavelength is the wavelength associated with the largest peak in the'
'transformed data. The secondary wavelength is computed as the wavelength'
'associated with the second largest amplitude (as long as it exceeds half the'
'amplitude of the primary wavelength). The wavelength is capped at twice the'
'value of the worm''s length. In other words, a worm can never achieve a'
'wavelength more than double its size.'
''
'6. Track Length. The worm''s track length is the range of the skeleton''s'
'horizontal projection (as opposed to the skeleton''s arc length) after rotating'
'the worm to align it with the horizontal axis. The formula and code originate'
'from the publication "An automated system for measuring parameters of nematode'
'sinusoidal movement" (Cronin et al. 2005).'
''
'7. Coils. Worm coiling (touching) events are found by scanning the video frame'
'annotations. During segmentation, every frame that cannot be segmented is'
'annotated with a cause for failure. Two of these annotations reflect coiling'
'events. First, if we find fewer than 2 sharp ends on the contour (reflecting the'
'head and tail) then the head and/or tail are obscured in a coiling event.'
'Second, if the length between the head and tail on one side of the contour is'
'more than double that of the other side, the worm has either assumed an omega'
'bend or is crossed like a wreath. Empirically, less than 1/5 of a second is a'
'very fast touch and not usually reflective of coiling. Therefore, when a period'
'of unsegmented video frames exceeds 1/5 of a second, and either of the coiling'
'annotations are found, we label the event coiling.'
''
'8. Eigen Projections. The eigenworm amplitudes are a measure of worm posture.'
'They are the projections onto the first six eigenworms which together account'
'for 97% of the variance in posture. The eigenworms were computed from 15 N2'
'videos (roughly 3 hours of video, 1/3 of a million frames) as previously'
'described (Stephens et al. 2008).'
''
'Briefly, 48 tangent angles are calculated along the skeleton and rotated to have'
'a mean angle of zero. Principal components analysis is performed on the pooled'
'angle data and we keep the 6 principal components (or eigenworms) that capture'
'the most variance. The first eigenworm roughly corresponds to body curvature.'
'The next two eigenworms are akin to sine and cosine waves encoding the'
'travelling wave during crawling. The fourth eigenworm captures most of the'
'remaining variance at the head and tail. Projected amplitudes are calculated'
'from the posture in each frame. Even for the mutants, the data is always'
'projected onto the N2-derived eigenworms.'
''
'9. Orientation. The worm''s orientation is measured overall (from tail to head)'
'as well as for the head and tail individually. The overall orientation is'
'measured as the angular direction from the tail to the head centroid. The head'
'and tail centroids are computed as the mean of their respective skeleton points.'
''
'The head and tail direction are computed by splitting these regions in two, then'
'computing the centroid of each half. The head direction is measured as the'
'angular direction from the its second half (the centroid of points 5-8) to its'
'first half (the centroid of points 1-4). The tail direction is measured as the'
'angular direction from the its second half (the centroid of points 42-45) to its'
'first half (the centroid of points 46-49).'
};
end



%% Construct the "Motion Features" text.
function strs = MotionFeaturesText()
strs = {
'Motion Features'
''
'1. Velocity. The worm''s velocity is measured at the tip of the head and tail, at'
'the head and tail themselves, and at the midbody. The velocity is composed of'
'two parts, speed and direction (expressed as an angular speed). The velocity is'
'signed negatively whenever the respective body part moves towards the tail (as'
'opposed to the head).'
''
'The head and tail tips'' instantaneous velocity is measured at each frame using a'
'1/4 second up to a 1/2 second window. For each frame, we search for a start'
'frame 1/4 of a second before and an end frame 1/4 second after to delineate the'
'worm''s instantaneous path. If the worm''s location is not known within either the'
'start or end frame, we extend the search for a known location up to 1/2 second'
'in either direction. If the worm''s location is still missing at either the start'
'or end, the velocity is marked unknown at this point. The speed is defined as'
'the distance between the centroids of the start and end frames (for the'
'respective body parts) divided by the time between both frames. The direction is'
'defined as the angle (between centroids) from the start to the end frame,'
'relative to the worm''s overall body angle, divided by the time between both'
'frames. The worm''s overall body angle is defined as the mean orientation of the'
'angles, in the tail-to-head direction, between subsequent midbody skeleton'
'points. The body angle is used to sign the velocity. If the head or tail tip''s'
'start-to-end angle exceeds 90\circ, clockwise or anti-clockwise, relative to the'
'overall worm body angle, the motion is towards the tail. In this case both the'
'speed and direction are negatively signed. The head, midbody, and tail velocity'
'are computed identically except they use a 1/2 second up to a 1 second window'
'for choosing their start and end frames.'
''
'2. Motion States. The worm''s forward, backward, and paused motion states attempt'
'to differentiate these event states unambiguously. Therefore, ambiguous motion'
'has no associated state.'
''
'The motion states are computed from the worm''s velocity and length (described in'
'the section on "Morphology"). Missing lengths are linearly interpolated between'
'segmented frames. The following filtering criteria were chosen based on human'
'labeling of events within a variety of N2 and mutant videos. The worm is defined'
'in a state of forward motion when a period, more than half a second long, is'
'observed wherein: a) the worm travels at least 5% of its mean length over the'
'entire period; and, b) the worm''s speed is at least 5% of its length, per'
'second, in each frame. The worm must maintain this speed almost continuously'
'with permissible interruptions of, at most, a quarter second (this permits quick'
'contradictory movements such as head withdrawal, body contractions, and'
'segmentation noise). The criteria for backward motion is identical except the'
'worm must be moving backwards (the midbody speed must be negatively signed). The'
'worm is defined in a paused state when a period, more than half a second long,'
'is observed wherein the worm''s forward and backward speed do not exceed 2.5% of'
'its length, per second, in each frame. The worm must observe these speed limits'
'almost continuously with permissible interruptions of, at most, a quarter second'
'(once again, this permits quick contradictory movements).'
''
'3. Crawling. Worm crawling is expressed as both an amplitude and frequency. We'
'measure these features instantaneously at the head, midbody, and tail. The'
'amplitude and frequency are signed negatively whenever the worm''s ventral side'
'is contained within the concave portion of its instantaneous bend.'
''
'Crawling is only measured during forward and backward motion states. The worm'
'bend mean angles (described in the section on "Posture") show a roughly periodic'
'signal as the crawling wave travels along the worm''s body. This wave can be'
'asymmetric due to differences in dorsal-ventral flexibility or simply because'
'the worm is executing a turn. Moreover the wave dynamics can change abruptly to'
'speed up or slow down. Therefore, the signal is only roughly periodic and we'
'measure its instantaneous properties.'
''
'Worm bends are linearly interpolated across unsegmented frames. The motion'
'states criteria (described earlier in this section) guarantee that interpolation'
'is no more than 1/4 of a second long. For each frame, we search both backwards'
'and forwards for a zero crossing in the bend angle mean - the location where the'
'measured body part (head, midbody, or tail) must have hit a flat posture (a'
'supplementary bend angle of 0\circ). This guarantees that we are observing half'
'a cycle for the waveform. Crawling is bounded between 1/30Hz (a very slow wave'
'that would not resemble crawling) and 1Hz (an impossibly fast wave on agar). If'
'the window between zero crossings is too small, the nearest zero crossing is'
'assumed to be noise and we search for the next available zero crossing in its'
'respective direction. If the window is too big, crawling is marked undefined at'
'the frame. Once an appropriate window has been found, the window is extended in'
'order to center the frame and measure instantaneous crawling by ensuring that'
'the distance on either side to respective zero crossings is identical. If the'
'distances are not identical, the distance of the larger side is used in place of'
'the zero-crossing distance of the smaller side in order to expand the small side'
'and achieve a symmetric window, centered at the frame of interest.'
''
'We use a Fourier transform to measure the amplitude and frequency within the'
'window described above. The largest peak within the transform is chosen for the'
'crawling amplitude and frequency. If the troughs on either side of the peak'
'exceed 1/2 its height, the peak is rejected for being unclear and crawling is'
'marked as undefined at the frame. Similarly, if the integral between the troughs'
'is less than half the total integral, the peak is rejected for being weak.'
''
'4. Foraging. Worm foraging is expressed as both an amplitude and an angular'
'speed. Foraging is signed negatively whenever it is oriented towards the ventral'
'side. In other words, if the nose is bent ventrally, the amplitude is signed'
'negatively. Similarly, if the nose is moving ventrally, the angular speed is'
'signed negatively. As a result, the amplitude and angular speed share the same'
'sign roughly only half the time. Foraging is an ambiguous term in previous'
'literature, encompassing both fine movements of the nose as well as larger'
'swings associated with the head. Empirically we have observed that the nose'
'movements are aperiodic while the head swings have periodicity. Therefore, we'
'measure the aperiodic nose movements and term these foraging whereas the head'
'swings are referred to as measures of head crawling (described earlier in this'
'section).'
''
'Foraging movements can exceed 6Hz (Huang et al. 2008) and, at 20-30fps, our'
'video frame rates are just high enough to resolve the fastest movements. By'
'contrast, the slowest foraging movements are simply a continuation of the'
'crawling wave and present similar bounds on their dynamics. Therefore, we bound'
'foraging between 1/30Hz (the lower bound used for crawling) and 10Hz.'
''
'To measure foraging, we split the head in two (skeleton points 1-4 and 5-8) and'
'measure the angle between these sections. To do so, we measure the mean of the'
'angle between subsequent skeleton points along each section, in the tail-to-head'
'direction. The foraging angle is the difference between the mean of the angles'
'of both sections. In other words, the foraging angle is simply the bend at the'
'head. Missing frames are linearly interpolated, per each skeleton point, for'
'fragments up to 0.2 seconds long (4-6 frames at 20-30fps -- twice the upper'
'foraging bound). When larger fragments are missing, foraging is marked'
'undefined. Segmentation of the head at very small time scales can be noisy.'
'Therefore, we smooth the foraging angles by convolving with a Gaussian filter'
'1/5 of a second long (for similar reasons to those mentioned in frame'
'interpolation), with a width defined by the Matlab "gausswin" function''s default'
'\alpha of 2.5 and normalized such that the filter integrates to 1.'
''
'The foraging amplitude is defined as the largest foraging angle measured, prior'
'to crossing 0\circ. In other words, the largest nose bend prior to returning to'
'a straight, unbent position. Therefore, the foraging amplitude time series'
'follows a discrete, stair-step pattern. The amplitude is signed negatively'
'whenever the nose points towards the worm''s ventral side. The foraging angular'
'speed is measured as the foraging angle difference between subsequent frames'
'divided by the time between these frames. To center the foraging angular speed'
'at the frame of interest and eliminate noise, each frame is assigned the mean of'
'the angular speed computed between the previous frame and itself and between'
'itself and the next frame. The angular speed is signed negatively whenever its'
'vector points towards the worm''s ventral side.'
''
'5. Turns. Omega and upsilon turn events are computed similarly to a previously'
'described method (Huang et al. 2006) but using skeleton bends instead of a'
'single head-midbody-tail angle. Omega and upsilon turns are signed negatively'
'whenever the worm''s ventral side is sheltered within the concavity of its'
'midbody bend.'
''
'The worm bends (described in the section on "Posture") are used to find a'
'contiguous sequence of frames (interruptible by coiling and other segmentation'
'failures) wherein a large bend travels from the worm''s head, through its'
'midbody, to its tail. The worm''s body is separated into 3 equal parts from its'
'head to its tail. The mean supplementary angle is measured along each 3rd. For'
'omega turns, this angle must initially exceed 30\circ at the first but not the'
'last 3rd of the body (the head but not the tail). The middle 3rd must then'
'exceed 30\circ. And finally, the last but not the first 3rd of the body must'
'exceed 30\circ (the tail but not the head). This sequence of a 30\circ mean'
'supplementary angle, passing continuously along the worm from head to tail, is'
'labeled an omega turn event. Upsilon turns are computed nearly identically but'
'they capture all events that escaped being labeled omega turns, wherein the mean'
'supplementary angle exceeded 15\circ on one side of the worm (the first or last'
'3rd of the body) while not exceeding 30\circ on the opposite end.'
};
end



%% Construct the "Path Features" text.
function strs = PathFeaturesText()
strs = {
'Path Features'
''
'1. Range. The centroid of the worm''s entire path is computed. The range is'
'defined as the distance of the worm''s midbody from this overall centroid, in'
'each frame.'
''
'2. Dwelling. The worm dwelling is computed for the head, midbody, tail, and the'
'entire worm. The worm''s width is assumed to be the mean of its head, midbody,'
'and tail widths across all frames. The skeleton''s minimum and maximum location,'
'for the x and y axes, is used to create a rectangular boundary. This boundary is'
'subdivided into a grid wherein each grid square has a diagonal the same length'
'as the worm''s width. When skeleton points are present on a grid square, their'
'corresponding body part is computed as dwelling within that square. The dwelling'
'for each grid square is integrated to define the dwelling distribution for each'
'body part. For each body part, untouched grid squares are ignored.'
''
'3. Curvature. The path curvature is defined as the angle, in radians, of the'
'worm''s path divided by the distance it traveled in microns. The curvature is'
'signed to provide the path''s dorsal-ventral orientation. When the worm''s path'
'curves in the direction of its ventral side, the curvature is signed negatively.'
''
'The worm''s location is defined as the centroid of its body, with the head and'
'tail removed (points 9-41). We remove the head and tail because their movement'
'can cause large displacements in the worm''s centroid. For each frame wherein the'
'worm''s location is known, we search for a start frame 1/4 of a second before and'
'an end frame 1/4 second after to delineate the worm''s instantaneous path. If the'
'worm''s location is not known within either the start or end frame, we extend the'
'search for a known location up to 1/2 second in either direction. If the worm''s'
'location is still missing at either the start or end, the path curvature is'
'marked unknown at this point.'
''
'With 3 usable frames, we have an approximation of the start, middle, and end for'
'the worm''s instantaneous path curvature. We use the difference in tangent angles'
'between the middle to the end and between the start to the middle. The distance'
'is measured as the integral of the distance traveled, per frame, between the'
'start and end frames. When a frame is missing, the distance is interpolated'
'using the next available segmented frame. The instantaneous path curvature is'
'then computed as the angle divided by the distance. This path curvature is'
'signed negatively if the angle curves in the direction of the worm''s ventral'
'side.'
};
end



%% Construct the "Phenotypic Ontology" text.
function strs = PhenotypicOntologyText()
strs = {
'Phenotypic Ontology'
''
'The phenotypic ontology attempts to find significant features and reduce our'
'large set of statistical measures to several simple terms. Each ontological term'
'has a prefix indicating whether all significant features agree that the measure'
'is greater (+), less (-), or different (\Delta) than the control. A feature is'
'said to be different than its control whenever the magnitude has no direct'
'meaning (e.g., asymmetry does not translate to a clear description of the'
'feature being less nor greater than the control) or its measures do not express'
'a simple magnitude (e.g., the strain pauses with greater frequency but spends'
'less time in each paused event). Each term also has a suffix indicating the'
'minimum q value (significance) found for the term''s defining features (* when'
'q \leq 0.05; ** when q \leq 0.01; *** when q \leq 0.001; and, **** when q \leq 0.0001).'
'The q-value is a p-value replacement that corrects for multiple testing'
'(Storey 2002). The ontology terms are as follows:'
''
'1. Length. The worm''s length.'
''
'2. Width. The worm''s head, midbody, and/or tail width.'
''
'3. Area. The worm''s area if neither the "Length" nor "Width" were found'
'significant.'
''
'4. Proportion. The worm''s area/length and/or width/length if neither the'
'"Length", "Width", nor "Area" were found significant.'
''
'5. Head Bends. The worm''s head bend mean and/or standard deviation.'
''
'6. Tail Bends. The worm''s tail bend mean and/or standard deviation.'
''
'7. Posture Amplitude. The worm''s maximum amplitude and/or amplitude ratio.'
''
'8. Posture Wavelength. The worm''s primary and/or secondary wavelength.'
''
'9. Posture Wave. The worm''s track length if neither the "Posture Amplitude" nor'
'the "Posture Wavelength" were found significant.'
''
'10. Body Bends. The worm''s eccentricity, its number of bends, and/or its'
'neck/midbody/hips bend mean and/or standard deviation; only if neither the'
'"Posture Amplitude", "Posture Wavelength", nor "Posture Wave" were found'
'significant.'
''
'11. Pose. The worm''s eigenworm projections if neither the "Head Bends", "Body'
'Bends", "Tail Bends", "Posture Amplitude", "Posture Wavelength", nor "Posture'
'Wave" were found significant.'
''
'12. Coils. The worm''s coiling event details.'
''
'13. Foraging. The worm''s foraging amplitude and/or angular speed.'
''
'14. Forward Velocity. The worm''s forward (positive) velocity vector.'
''
'15. Backward Velocity. The worm''s backward (negative) velocity vector.'
''
'16. Velocity. The worm''s velocity vector magnitude and/or asymmetry if neither'
'the "Forward Velocity" nor "Backward Velocity" were found significant.'
''
'17. Head Motion. The worm''s head-tip and/or head velocity vectors if neither the'
'"Foraging", "Forward Velocity", nor "Backward Velocity" were found significant.'
''
'18. Tail Motion. The worm''s tail-tip and/or tail velocity vectors if neither the'
'"Forward Velocity" nor "Backward Velocity" were found significant.'
''
'19. Forward Motion. The worm''s forward motion event details.'
''
'20. Pausing. The worm''s pausing event details.'
''
'21. Backward Motion. The worm''s backward motion event details.'
''
'22. Crawling Amplitude. The worm''s crawling amplitude.'
''
'23. Crawling Frequency. The worm''s crawling frequency.'
'24. Turns. The worm''s omega and/or upsilon event details.'
''
'25. Path Range. The worm''s path range.'
''
'26. Path Curvature. The worm''s path curvature.'
''
'27. Dwelling. The worm''s dwelling if its "Pausing" was not found significant.'
};
end



%% Construct the "Feature File Overview" text.
function strs = FeatureFileOverviewText()
strs = {
'Feature File Overview'
''
'The features are presented within 4 types of files available online at:'
''
'http://wormbehavior.mrc-lmb.cam.ac.uk/'
''
'PDF files provide a visual summary of the data, per strain. CSV files provide a'
'spreadsheet of the data, per strain. And, 3 types of MAT files are provided to'
'access the strain data and statistics as well as the skeleton, contour, and'
'feature data for each individual experiment, per frame.'
''
'The MAT files, per worm, are available for every experiment. To ensure'
'high-quality experimental data, strain collections of experiments and controls'
'were filtered and only include worm videos of at least 20fps, 14-15 minutes'
'long, wherein at least 20% of the frames were segmented. We only include data'
'collected Monday through Saturday, from 8am to 6pm. This resulted in a mean of'
'25 worms per strain with a minimum of 12 worms. Controls were chosen from the'
'filtered N2 data collection by matching the strain collections to controls'
'performed within the same week. This resulted in a mean of 63 controls, per'
'strain collection, with a minimum of 18 worms. We examined 100 videos (roughly 2'
'million frames) from our filtered collection and found that the head was'
'correctly labeled with a mean and standard deviation of 95.17 \pm 17.5% across'
'individual videos and 95.69% of the frames collectively.'
''
'Outliers can compress visual details in their corresponding histograms. For this'
'reason, the strain collections underwent one more filtering step prior to'
'inclusion in the PDF files. Experiments were discarded wherein any of the worm'
'data exceeded reasonable bounds of 250 to 2000 microns for length, 25 to 250'
'microns for width, and/or -1000 to 1000 microns/seconds for the midbody speed.'
'Outliers were seldom found. Overall, 49 non-control worms were lost from a'
'collection of 7,529 experiments. No strain collection lost more than 2 worms.'
'The N2 collection of controls lost 5 worms from its total of 1,218 experiments.'
'The CSV files and MAT statistical-significance files are available for both the'
'primary quality-filtered data sets and the secondary, outlier-filtered data'
'sets.'
''
'Shapiro-Wilk testing (performed using the "swtest" function by Ahmed Ben Saïda)'
'of each feature (with corrections for multiple comparisons) showed a maximum q'
'value of 0.0095 over our collective N2 data set, indicating that, in aggregate,'
'none of the features are normally distributed. Further testing across all strain'
'collections (which have far lower sampling than the N2 collective) and their'
'controls, indicated a roughly 2:1 ratio of normal to non-normal feature'
'distributions, rejecting the null hypothesis of normality at a q value of 0.05.'
'Therefore, we chose to test strain features against their controls by using the'
'non-parametric Wilcoxon rank-sum test (with the null hypothesis that both sets'
'of mean values were drawn from the same distribution). Some features were'
'measured for all worms of the experimental strain and never in their controls,'
'or vice versa (e.g., some strains never perform reversals). When this occurred,'
'we simply set the feature''s p value to 0. Occasionally, features had'
'insufficient values for testing due to low sampling (e.g., omega-turn events),'
'these features were ignored and their p value marked as undefined. In total, our'
'702 features were measured for 305 strains in addition to collections of our N2'
'worms by hour (9am-4pm, with 8am and 5pm discarded due to very low sampling),'
'weekday (Tuesday-Friday, with Monday and Saturday discarded due to very low'
'sampling), and month (January-December). We used False-Discovery Rate (FDR) to'
'correct for nearly 702 features by 329 groups and transform the p values to'
'their q-value equivalents (Storey 2002).'
''
'Our unfiltered histograms, presented within individual MAT files, were'
'constructed by choosing standard bin resolutions (widths and centers) that'
'resulted in roughly 103 bins, per feature, for our N2 data. When plotting'
'histograms, we use a common formula to downsample the bins. We measure the'
'square root of the total number of data samples contributing to the collective'
'histogram. If this value is less than the number of bins available, the'
'histogram is downsampled to reduce the number of bins to the nearest integer at'
'or below the computed square root. When multiple histograms are plotted'
'together, the smallest common bin size is used to downsample all the histograms'
'to the same bin width and centers.'
};
end



%% Construct the "PDF Files" text.
function strs = PDFFilesText()
strs = {
'PDF Files'
''
'The PDF (portable document format) files include 5 sections: a) a table of'
'contents and overview of the results, b) a short summary of the most important'
'features, c) the details for every feature, d) traces of the worm paths, and e)'
'a reference with the experimental methods. Each page uses a color scheme to'
'provide quick visual summaries of its results. All pages display tabs, on the'
'right side, that explain their color scheme. The initial summary page of'
'histograms (page 2) displays an example histogram that acts as a guide to'
'understanding histogram plots and the statistics displayed in their titles. The'
'page formats are as follows:'
''
'1. The table of contents details the layout of the PDF file. All features are'
'shown alongside their minimum q-value significance and a page number for'
'details. The table of contents page also shows an overview with the experiment'
'annotation and its phenotypic ontology (see the section titled "Phenotypic'
'Ontology").'
''
'2. There are 3 summary pages. These pages show important feature histograms,'
'with the collective experiments in color and their controls in gray. The'
'background color, for the histogram plots, indicates the minimum q-value'
'significance for the plotted feature. The title of each plot provides several'
'statistical measures for the experiment and control collections. An example'
'histogram, at the beginning of the first summary page, provides a reference to'
'interpret the aforementioned statistical measures. Significant measures, with q'
'\leq 0.05, are marked in bold font within the plot title.'
''
'The crawling frequency, worm velocity, foraging speed, all event features, path'
'range, and dwelling are shown on a pseudo log-value scale to improve readability'
'within their small summary histograms. This pseudo log-value scale is achieved'
'by taking the magnitude of the data values (to avoid complex numbers resulting'
'from the logarithms of any negative numbers), translating the magnitude by 1 (to'
'avoid the logarithms of any values less than 1, which would invert the sign of'
'the data), taking the logarithm, then re-signing the formerly negative data'
'values.'
''
'3. The detail pages present a detailed view of the histograms for every feature.'
'They follow a similar format to the summary pages except that they never use a'
'log scale for feature values. The title of each plot provides a large set of'
'statistical measures. The control values are shown between square brackets.  The'
'statistical values include: a) the number of worms providing measurements'
'("WORMS"); b) the number of measurements sampled for the collection of worms'
'("SAMPLES") ; c) the mean of the data ("ALL") alongside the SEM and, when the'
'data is signed, the means for the absolute data values (ABS), positive data'
'values only ("POS"), and negative data values only ("NEG") alongside their SEMs'
'as well; d) the p-value results using Wilcoxon rank-sum testing, q-value results'
'using False Discovery Rate correction (for multiple tests across 329 strain'
'collections by 702 features), and the \beta (a measure associated with'
'statistical power), each labeled accordingly (respectively "p", "q", and'
'"\beta"); e) event features also display their mean frequency ("FREQ"), the mean'
'percentage of time spent in the event relative to the total experiment time'
'("TIME"), and, when available, the mean percentage of distance traveled during'
'the event relative to the total distance covered during the experiment ("DIST").'
''
'Features that have motion-state subdivisions are shown with an additional view'
'wherein all motion-state histograms, and their integral histogram, are shown on'
'the same plot. This allows one to quickly distinguish behaviors dependent on the'
'motion state. Event features have an additional view wherein event and'
'inter-event measures are plotted on a log-probability scale to make outlying'
'events more visible.'
''
'4. The path trace pages display the paths for the worms'' head, midbody, and tail'
'and heatmaps for the midbody speed and foraging amplitude. Pages with the head,'
'midbody, and tail include a tab, on the right side, to interpret the color'
'associated with each body part. Pages with heatmaps include a tab, on the right'
'side, to interpret the color gradient. On the path trace plots, the start and'
'end of each path is denoted by a gray and black worm, respectively. Moreover, on'
'each plot, the locations for coiling events are marked by a "+" and those for'
'omega turns are marked by an "x". Body part plots use transparency to roughly'
'indicate dwelling through color opacity.'
''
'The first page of each path trace shows a collection of up to 24 worms (when'
'available) overlayed for both the experiment and control collections, at the'
'same scale. These overlays provide a quick view of features such as relative'
'path sizes, food leaving behaviors, and the relative locations for coiling'
'events and omega turns. When more than 24 worms are available we sort the worms'
'by date, then choose 24 from the first to the last experiment at regular'
'intervals. The paths are rotated to align their longest axis vertically, and'
'then centered using the minimum and maximum x and y path values, per worm.'
''
'The next page of the path traces shows each collection of 24 paths on the same'
'plot, ordered roughly from largest to smallest, spaced out to avoid any overlay.'
'The experiments and their controls use independent scales. This ordered plot'
'provides a quick view to distinguish salient characteristics of experiment'
'versus control paths (e.g., bordering at the edge of the food lawn).'
''
'The subsequent pages for each path trace show the 24 individual worm paths, for'
'the experiments and their controls, without rotation, sorted by date.'
''
'5. The method pages provide a reference for the details of our methodology.'
};
end



%% Construct the "CSV Files" text.
function strs = CSVFilesText()
strs = {
'CSV Files'
''
'The CSV (comma separated value) files are compatible with popular spreadsheet'
'programs (e.g., Microsoft Excel, Apple iWork Numbers, OpenOffice, etc.). Each'
'experimental collection is accompanied by 4 CSV files presenting the data and'
'statistics for all morphology (<filename>.morphology.csv), posture'
'(<filename>.posture.csv), motion (<filename>.motion.csv), and path features'
'(<filename>.path.csv). The CSV files present the strain, genotype, and date for'
'the experimental strain and control worms. The mean and standard deviation are'
'presented for each feature, per worm and for the collection of experiments and'
'controls. The p and q values are presented for the strain as a whole (the null'
'hypothesis is that experiment and control worms are drawn from the same'
'distribution) and for each feature individually. These p and q values are shown'
'for both the non-parametric Wilcoxon rank-sum test and the normal-distribution'
'Student''s t-test (unpaired samples with unequal variance). The statistical power'
'is shown for each feature. Moreover, the Shapiro-Wilk test for normality (with'
'associated p and q values) is also shown for each feature. Correction for'
'multiple testing (the q values) was performed over our entire set of 329 groups'
'of strain collections by 702 features. For the Shapiro-Wilk normality test,'
'correction for multiple comparisons included an additional 329 group-specific'
'controls by 702 features.'
};
end



%% Construct the "MAT Files" text.
function strs = MATFilesText()
strs = {
'MAT Files'
''
'Each experiment is represented in a MAT, HDF5-formatted file (Hierarchical Data'
'Format Version 5 - an open, portable, file format with significant software'
'support). HDF5 files are supported by most popular programming languages'
'including Matlab, Octave (a free alternative to Matlab), R, Java, C/C++, Python,'
'and many other environments. These experiment files contain the time-series'
'feature data for an individual worm. Additionally, each strain collection of'
'experiments and their collection of controls are also represented in a single'
'HDF5, MAT file. These strain files contain histogram representations and summary'
'statistics (but not significance) for the collective experiments. Finally, the'
'statistical significance, for our entire collection of mutants, is presented in'
'a single HDF5, MAT file.'
''
'The first 2 MAT file types, individual experiments and strain collections, share'
'a similar format. The individual experiment files present the feature data as a'
'time series. They also include the full skeleton and the centroid of the'
'contour, per frame, permitting novel feature computations. The strain'
'collections present the data in summary and in histograms. The format for both'
'file types is 2 top-level structs, "info" ("wormInfo" for the strain'
'collections) and "worm", which contain the experimental annotation and data,'
'respectively.'
''
'The "info" struct contains the experimental annotation. For the strain'
'collections, the "info" from each experiment is collected into an array of'
'structs called "wormInfo". Both variables share the same format with the'
'following subfields:'
''
'1. wt2. The Worm Tracker 2.0 version information.'
''
' video. The video information. The video "length" is presented as both "frames"'
'and "time". The video "resolution" is in "fps" (frames/seconds), pixel "height"'
'and "width", the ratio of "micronsPerPixel", and the codec''s "fourcc"'
'identifier. The video frame "annotations" are presented for all "frames" with a'
'"reference" specifying the annotation''s numerical "id", the "function" it'
'originated from, and a "message" describing the meaning of the annotation.'
''
'2. experiment. The experiment information. The "worm" information is presented'
'for its "genotype", "gene", "allele", "strain", "chromosome", "sex", "age", the'
'"habituation" time prior to recording, the location of its "ventralSide" in the'
'video (clockwise or anti-clockwise from the head), the "agarSide" of its body'
'(the body side touching the agar), and any other worm "annotations". The'
'"environment" information is presented for the experiment conditions including'
'the "timestamp" when the experiment was performed, the "arena" used to contain'
'the worm (always a low-peptone NGM plate for the data presented here), the'
'"food" used (e.g., OP50 E. coli), the "temperature", the peak wavelength of the'
'"illumination", any "chemicals" used, the "tracker" on which the experiment was'
'performed (a numerical ID from 1 to 8), and any other environmental'
'"annotations".'
''
'3. files. The name and location for the analyzed files. Each experiment is'
'represented in a "video" file, "vignette" file (a correction for video'
'vignetting), "info" file (with tracking information, e.g., the microns/pixels),'
'a file with the log of "stage" movements, and the "computer" and "directory"'
'where these files can be found.'
''
'4. lab. The lab information where the experiment was performed. The lab is'
'represented by its "name", the "address" of the lab, the "experimenter" who'
'performed the experiment, and any other lab-related "annotations".'
''
'The "worm" struct contains experimental data. The individual experiments contain'
'the full time series of data along with the worm''s skeleton and the centroid of'
'its contour, per frame. The strain collections contain summary data and'
'histograms in place of the time-series data. Both files share a similar initial'
'format with the following subfields:'
''
'1. morphology. The morphology features. The morphology is represented by the'
'worm''s "length", its "width" at various body locations, the "area" within its'
'contour, the "widthPerLength", and the "areaPerLength".'
''
'2. posture. The posture features. The worm''s posture is represented by its bend'
'count in "kinks", measures of the "bends" at various body locations (computed as'
'both a "mean" and standard deviation, "stdDev"), its "max" "amplitude" and its'
'"ratio" on either side, its "primary" and "secondary" "wavelength", its'
'"trackLength", its "eccentricity", its "coils", the orientation "directions" of'
'various body parts, and its 6 "eigenProjections". Individual experiment files'
'also contain the "skeleton" "x" and "y" coordinates, per frame.'
''
'3. locomotion. The motion features. Worm motion states are represented by'
'"forward", "backward", and "paused" events, the "speed" and angular "direction"'
'of the "velocity" for various body parts, the "amplitude" and "frequency" of the'
'crawling "bends" for various body parts, as well as the "foraging" "bends" which'
'are measured in an "amplitude" and "angleSpeed", and the "turns" associated with'
'"omega" and "upsilon" events. Individual experiment files also contain a'
'"motion" state "mode" with values distinguishing forward (1), backward (-1), and'
'paused (0) states, per frame.'
''
'4. path. The path features. The path is represented by its "range", "curvature",'
'and the dwelling "duration" for various body parts. Individual experiment files'
'also contain the "x" and "y" "coordinates" of the contour''s centroid. Moreover,'
'the individual experiment files present the "duration" as an "arena" with a'
'"height", "width", and the "min" and "max" values for the "x" and "y" axes of'
'the arena. The arena can be transformed to a matrix using the given height and'
'width. The duration of the worm and body parts are represented as an array of'
'"times" spent at the "indices" of the arena matrix.'
''
'All events are represented by their "frequency" and either their "timeRatio"'
'(the ratio of time in the event type to the total experiment time) or, if the'
'worm can travel during the event, the "ratio.time" (equivalent to "timeRatio")'
'and "ratio.distance" (the ratio of the distance covered in the event type to the'
'total distance traveled during the experiment). The individual experiment files'
'represent each event as "frames" with a "start" frame, "end" frame, the "time"'
'spent in this event instance, the "distance" traveled during this event instance'
'(when available), the "interTime" till the next event, and the "interDistance"'
'traveled till the next event. The strain collection files summarize these'
'fields, excluding the individual "frames" and their "start" and "end".'
''
'The strain collection files present the data for each feature within a'
'"histogram" (as opposed to the individual experiment files which simply use a'
'time-series array of values). Furthermore, when a feature can be subdivided by'
'motion state, sub histograms are included for the "forward", "backward", and'
'"paused" states. All histograms contain the "PDF" (probability distribution'
'function) for each of their "bins" (centered at the associated feature''s'
'values). All histograms also contain the "resolution" (width) of their bins,'
'whether or not there "isZeroBin" (would one of the bins be centered at 0?), and'
'whether or not the feature "isSigned" (can the feature values be negative?).'
''
'Finally, the strain collection files present their data in 3 types of fields: a)'
'individually as the "data" per experiment, b) summarized over the "sets" of'
'experiments and, c) aggregated in "allData" as if we ran one giant experiment'
'instead of our sets. In other words, "sets" weights each experiment identically'
'whereas "allData" weights every frame, across all experiments, identically. The'
'data is always represented as both a "mean" and "stdDev" (standard deviation).'
'The mean and standard deviation are always computed for "all" the data. When the'
'data is signed, the mean and standard deviation are also computed for the data''s'
'"abs" (absolute value), "pos" (only the positive values), and "neg" (only the'
'negative values). The format for the 3 types of data is as follows:'
''
'1. data. The individual data for every experiment is presented in arrays (in the'
'same order as the "wormInfo" experiment annotations). The array data presents'
'each experiment''s individual "mean", "stdDev", the number of "samples" measured,'
'and the experiment''s data "counts" for each one of the histogram''s "bins".'
''
'2. sets. The data for the set of experiments is presented as the "mean",'
'"stdDev", and "samples" (the number of experiments) of the collected set.'
''
'3. allData. The aggregate of all data measurements, as if the collection of'
'videos were instead one long, giant video, is presented as a "mean", "stdDev",'
'the total "samples" (the total number of frames wherein the data was measured),'
'and the aggregate of "counts" for each one of the histogram''s bins.'
};
end



%% Construct the "Statistical Significance MAT Files" text.
function strs = SignificanceMATFilesText()
strs = {
'Statistical Significance MAT File'
''
'The statistical significance for all strains is collected into a single MAT'
'file. This file contains 3 top-level structs with information for both the'
'"worm" and "control" collections as well as the "dataInfo" necessary to'
'interpret the included matrices of data. The matrices are organized as rows of'
'strains and columns of features. The "worm" struct has the following subfields:'
''
'1. info. The worm information for each strain collection presented as their'
'"strain", "genotype", "gene", and "allele".'
''
'2. stats. The statistics for each strain collection presented, for every'
'feature, as their "mean", "stdDev" (standard deviation), "samples" (the number'
'of worms providing a measurement for the feature - e.g., not all worms execute'
'omega turns), and "zScore" relative to the control (note that the collection of'
'N2 controls has no zScore). Furthermore, we include Shapiro-Wilk tests of data'
'normality, per feature, in "pNormal" and correction for multiple testing, using'
'their False-Discovery rate q value replacements, in "qNormal". The q values are'
'computed across all features per "strain" and their associated controls (roughly'
'1404 tests) and across "all" strain and control features collectively (roughly'
'329 by 1404 tests).'
''
'3. sig. The statistical significance for each strain collection is presented,'
'for every feature, as their "pTValue" (Student''s t-test p value, unpaired'
'samples with unequal variance), "pWValue" (Wilcoxon rank-sum test p value), and'
'"power". The "qTValue" and "qWValue" represent the False-Discovery rate q value'
'replacements for the "pTValue" and "pWValue" respectively. The q values are'
'computed across all features per "strain" (roughly 702 tests) and across "all"'
'strains and features collectively (roughly 329 by 702 tests). The collection of'
'N2s has no associated significance.'
''
'The "control" struct contains the control "stats" in an identical format to the'
'"worm" struct "stats", but without the "zScores".'
''
'The "dataInfo" provides information for each column of the feature matrices used'
'in the "worm" and "control" structs. Each feature has a "name", a "unit" of'
'measurement, titles for 3 possible subdivisions ("title1", "title2", and'
'"title3" - the title of the feature itself, its motion state, and its signed'
'subdivision), helpful indexed offsets for these titles ("title1I", "title2I",'
'and "title3I"), an associated struct "field" to locate the feature in our other'
'MAT files, the corresponding "index" for the struct field (e.g., the 6 eigenworm'
'projections are represented in a field, as a 6-element array), "isMain" (is this'
'the main feature as opposed to a subdivision of a main feature?), the feature'
'"category" (morphology "m", posture "s", motion "l", path "p"), the feature'
'"type" (simple data "s", motion data "m", event summary data "d", event data'
'"e", inter-event data "i"), the feature "subtype" (none "n", forward motion'
'state "f", backward motion state "b", paused state "p", event-time data "t",'
'event-distance data "d", event-frequency data "h"), and information regarding'
'the feature''s "sign" (the feature is signed "s", unsigned "u", is the absolute'
'value of the data "a", contains only positive data values "p", contains only'
'negative data values "n").'
};
end



%% Construct the "Acknowledgements" text.
function strs = AcknowledgementsText()
strs = {
'Acknowledgements'
''
'WT2 employs Java for the tracking software and Matlab for the analysis software.'
'Standard Matlab functions are used along with the Image Processing, Statistics,'
'and Bioinformatics toolboxes. Special thanks and acknowledgements are due to'
'Christopher J. Cronin and Paul W. Sternberg for supplying the Matlab code from'
'their publication "An automated system for measuring parameters of nematode'
'sinusoidal movement" (Cronin et al. 2005). Joan Lasenby and Nick Kingsbury where'
'an invaluable resource for computer vision questions. Andrew Deonarine, Madan'
'Babu, Richard Samworth, Sarah Teichmann, and Sreenivas Chavali provided a wealth'
'of help and information for the bioinformatic clustering and statistics.'
'Finally, thanks and acknowledgements are due for the following freely available'
'code at the Matlab Central File Exchange'
'(http://www.mathworks.com/matlabcentral/fileexchange/): the videoIO toolbox by'
'Gerald Dalley, export\_fig function by Oliver Woodford, swtest function by'
'Ahmed Ben Saïda, and rdir function by Gus Brown.'
};
end



%% Construct the "References" text.
function strs = ReferencesText()
strs = {
'References'
''
'Alkema, M.J. et al., 2005. Tyramine Functions Independently of Octopamine in the'
'Caenorhabditis elegans Nervous System. Neuron, 46(2), pp.247-260.'
''
'Brenner, S., 1974. The genetics of Caenorhabditis elegans. Genetics, 77(1),'
'pp.71-94.'
''
'Cronin, C.J. et al., 2005. An automated system for measuring parameters of'
'nematode sinusoidal movement. BMC genetics, 6, p.5.'
''
'Freeman, H., 1961. On the encoding of arbitrary geometric configurations.'
'Electronic Computers, IRE Transactions on, (2), pp.260-268.'
''
'Huang, K.-M., Cosman, P. & Schafer, W.R., 2006. Machine vision based detection'
'of omega bends and reversals in C. elegans. Journal of Neuroscience Methods,'
'158(2), pp.323-336.'
''
'Huang, K.-M., Cosman, P. & Schafer, W.R., 2008. Automated detection and analysis'
'of foraging behavior in Caenorhabditis elegans. Journal of Neuroscience Methods,'
'171(1), pp.153-164.'
''
'Otsu, N., 1975. A threshold selection method from gray-level histograms.'
'Automatica, 11(285-296), pp.23-27.'
''
'Stephens, G.J. et al., 2008. Dimensionality and Dynamics in the Behavior of C.'
'elegans O. Sporns, ed. PLoS Computational Biology, 4(4), p.e1000028.'
''
'Storey, J.D., 2002. A direct approach to false discovery rates. Journal of the'
'Royal Statistical Society: Series B (Statistical Methodology), 64(3),'
'pp.479-498.'
''
'Sulston, J.E. & Horvitz, H.R., 1977. Post-embryonic cell lineages of the'
'nematode, Caenorhabditis elegans. Developmental Biology, 56(1), pp.110-156.'
''
''
''
'White, J.G. et al., 1986. The structure of the nervous system of the nematode'
'Caenorhabditis elegans. Philosophical transactions of the Royal Society of'
'London. Series B, Biological sciences, 314(1165), pp.1-340.'
''
'Yemini, E., Kerr, R.A. & Schafer, W.R., 2011. Preparation of samples for'
'single-worm tracking. Cold Spring Harbor protocols, 2011(12), pp.1475-1479.'
};
end
