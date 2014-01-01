function plotWormStatsMatrix(wormFile, varargin)
%PLOTWORMSTATSMATRIX Plot a features x worms matrix.
%
%   PLOTWORMSTATSMATRIX(WORMFILES, ISSCALE, SHOWTYPE, ISSHOWMAIN,
%                       ISSHOWABS, ISSHOWPOS, ISSHOWNEG, ISHOWNSIGN,
%                       ISSHOWMOTION, ISSHOWEVENT, SHOWI)
%
%   Inputs:
%       wormFile - the features x worms matrix file
%
%                  stats    = the features x worms matrix
%                  gene     = the worm gene
%                  allele   = the worm allele
%                  strain   = the worm strain
%                  genotype = the worm genotype
%                  sex      = the worm sex
%                  food     = the worm food
%                  name     = the feature names
%                  type     = the feature type per row:
%
%                             m = morphology
%                             s = posture (shape)
%                             l = locomotion
%                             p = path
%
%                  isMain   = for each row, is it a main feature?
%                  isAbs    = for each row, is it an absolute feature?
%                  isPos    = for each row, is it a positive feature?
%                  isNeg    = for each row, is it a negative feature?
%                  isMotion = for each row, is it a motion feature subset?
%                  isEvent  = for each row, is it an event feature subset?
%
%       isScale      - are we scaling feature colors to the maximum range?
%                      the default is no (false)
%       showType     - which feature types are we showing?
%                      if empty, all feature types are shown
%                      the default is all ([])
%
%                      m = morphology
%                      s = posture (shape)
%                      l = locomotion
%                      p = path
%
%       isShowMain   - are we showing the main features?
%                      the default is yes (true)
%       isShowAbs    - are we showing the absolute features?
%                      the default is yes (true)
%       isShowPos    - are we showing the positive features?
%                      the default is yes (true)
%       isShowNeg    - are we showing the negative features?
%                      the default is yes (true)
%       isShowSign   - are we showing the signed features?
%                      the default is yes (true)
%       isShowMotion - are we showing the motion feature subsets?
%                      the default is yes (true)
%       isShowEvent  - are we showing the event feature subsets?
%                      the default is yes (true)
%       showI        - the indices of the features to show
%                      if empty, all features are shown
%                      the default is all ([])
%
% See also WORM2STATSMATRIX
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Are we scaling all feature colors to the maximum range?
isScale = false;
if ~isempty(varargin)
    isScale = varargin{1};
end

% Which feature types are we showing?
showType = [];
if length(varargin) > 1
    showType = varargin{2};
end

% Are we showing the main features?
isShowMain = true;
if length(varargin) > 2
    isShowMain = varargin{3};
end

% Are we showing the absolute features?
isShowAbs = false;
if length(varargin) > 3
    isShowAbs = varargin{4};
end

% Are we showing the positive features?
isShowPos = false;
if length(varargin) > 4
    isShowPos = varargin{5};
end

% Are we showing the negative features?
isShowNeg = false;
if length(varargin) > 5
    isShowNeg = varargin{6};
end

% Are we showing the signed features?
isShowSign = true;
if length(varargin) > 6
    isShowSign = varargin{7};
end

% Are we showing the motion features?
isShowMotion = true;
if length(varargin) > 7
    isShowMotion = varargin{8};
end

% Are we showing the event features?
isShowEvent = true;
if length(varargin) > 8
    isShowEvent = varargin{9};
end

% Determine the indices of the features to show.
showI = [];
if length(varargin) > 9
    showI = varargin{10};
end

% Load the matrix.
worms = load(wormFile);
stats = worms.stats;

% Remove unwanted features.
isShow = true(size(worms.stats, 1), 1);
if ~isempty(showType)
    unShow = arrayfun(@(x) ~any(x == showType), worms.type);
    isShow(unShow) = false;
end
if ~isShowMain
    isShow(logical(worms.isMain)) = false;
end
if ~isShowAbs
    isShow(logical(worms.isAbs)) = false;
end
if ~isShowPos
    isShow(logical(worms.isPos)) = false;
end
if ~isShowNeg
    isShow(logical(worms.isNeg)) = false;
end
if ~isShowSign
    isShow(logical(worms.isSign)) = false;
end
if ~isShowMotion
    isShow(logical(worms.isMotion)) = false;
end
if ~isShowEvent
    isShow(logical(worms.isEvent)) = false;
end
if ~isempty(showI)
    unShowI = setDiff(1:size(stats, 1), showI);
    isShow(unShowI) = false;
end

% Compute the z scores.
featureMeans = nanmean(stats, 2);
featureStds = nanstd(stats, 0, 2);
zstats = nan(size(stats));
for i = 1:size(stats, 2)
    zstats(:,i) = (stats(:,i) - featureMeans) ./ featureStds;
end

% Construct the worm names.
N2I = [];
wormnames = cell(length(worms.genotype), 1);
for i = 1:length(wormnames)
    if strcmp(worms.strain{i}, 'N2')
        N2I(end + 1) = i;
        if ~isempty(strfind(worms.food{i}, 'OP50'))
            food = 'on food';
        else
            food = 'off food';
        end
        wormnames{i} = ['Lab Reference N2 ' worms.sex{i} ' ' food];
    elseif ~isempty(strfind(lower(worms.strain{i}), 'aq2947'))
        wormnames{i} = ['CGC Reference N2 ' worms.strain{i}];
    elseif ~isempty(strfind(lower(worms.strain{i}), 'ps312'))
        wormnames{i} = ['Pristionchus ' worms.strain{i}];
    elseif ~isempty(strfind(lower(worms.genotype{i}), 'isolate'))
        wormnames{i} = [worms.genotype{i} ' ' worms.strain{i}];
    elseif isempty(worms.genotype{i})
        wormnames{i} = worms.strain{i};
    else
        wormnames{i} = worms.genotype{i};
    end
end

% Always show the N2.
noN2 = setdiff(1:length(wormnames), N2I);

% Cluster the worms.
showI = logical(worms.isMain) | logical(worms.isAbs) | ...
    logical(worms.isMotion);
%showI = true(size(worms.isMain));
zstats = zstats(showI,:);
% wormI = 1:length(wormnames);
% zstats(isnan(zstats)) = 0;
% cgo = clustergram(zstats(:,wormI), 'Linkage', 'average', ...
%     'ColumnPDist', 'euclidean', 'RowPDist', 'euclidean', ...
%     'Standardize', 'row', 'Dendrogram', 0, 'Colormap', redbluecmap);
% set(cgo, 'RowLabels', worms.name(showI));
% set(cgo, 'ColumnLabels', wormnames(wormI));
maxNum = 300;
if 1
wormI = [noN2(1:(maxNum - length(N2I))) N2I];
zstats(isnan(zstats)) = 0;
cgo = clustergram(zstats(:,wormI), 'Linkage', 'average', ...
    'ColumnPDist', 'euclidean', 'RowPDist', 'euclidean', ...
    'Standardize', 'row', 'Dendrogram', 0, 'Colormap', redbluecmap);
set(cgo, 'RowLabels', worms.name(showI));
set(cgo, 'ColumnLabels', wormnames(wormI));
end
if 0
maxHalf = floor((length(noN2) - maxNum) / 2);
wormI = [noN2((maxHalf + 2):(length(noN2) - maxHalf - length(N2I))) N2I];
zstats(isnan(zstats)) = 0;
cgo = clustergram(zstats(:,wormI), 'Linkage', 'average', ...
    'ColumnPDist', 'euclidean', 'RowPDist', 'euclidean', ...
    'Standardize', 'row', 'Dendrogram', 0, 'Colormap', redbluecmap);
set(cgo, 'RowLabels', worms.name(showI));
set(cgo, 'ColumnLabels', wormnames(wormI));
end
if 0
wormI = [noN2((length(noN2) - maxNum + 1 + length(N2I)):length(noN2)) N2I];
zstats(isnan(zstats)) = 0;
cgo = clustergram(zstats(:,wormI), 'Linkage', 'average', ...
    'ColumnPDist', 'euclidean', 'RowPDist', 'euclidean', ...
    'Standardize', 'row', 'Dendrogram', 0, 'Colormap', redbluecmap);
set(cgo, 'RowLabels', worms.name(showI));
set(cgo, 'ColumnLabels', wormnames(wormI));
end
% cgo = clustergram(zstats', 'Linkage', 'average', ...
%     'ColumnPDist', 'euclidean', 'RowPDist', 'euclidean', ...
%     'Standardize', 'column', 'Dendrogram', 0, 'Colormap', redbluecmap);
% set(cgo, 'RowLabels', wormnames);
% set(cgo, 'ColumnLabels', worms.name(logical(worms.isMain)));

%clustergram(zstats','RowLabels', name(isShow), 'ColumnLabels', strain);

% % Initialize the colors.
% minShade = -0.75;
% maxShade = 0.75;
% shadeScale = 2^12;
% mColors = str2colors('g', linspace(minShade, maxShade, shadeScale));
% sColors = str2colors('r', linspace(minShade, maxShade, shadeScale));
% lColors = str2colors('b', linspace(minShade, maxShade, shadeScale));
% pColors = str2colors('o', linspace(minShade, maxShade, shadeScale));
% 
% % Convert the z scores to an image.
% types = worms.type(isShow);
% rgbImg = nan(size(zstats,1), size(zstats,2), 3);
% for i = 1:size(stats, 1)
%     data = zstats(i,:);
%     data = data - min(data);
%     maxData = max(data);
%     if maxData ~= 0
%         data = data / max(data);
%     end
%     colorI = round(data * (shadeScale - 1)) + 1;
%     colors = [];
%     switch types(i)
%         case 'm'
%             colors = mColors;
%         case 's'
%             colors = sColors;
%         case 'l'
%             colors = lColors;
%         case 'p'
%             colors = pColors;
%     end
%     for j = 1:length(colorI)
%         if ~isnan(colorI(j))
%             rgbImg(i,j,:) = colors(colorI(j),:);
%         end
%     end
% end
% %imshow(rgbImg);
% imagesc(zstats');
% genes = cell(1, length(worms.gene));
% for i = 1:length(worms.gene)
%     if isempty(worms.gene{i})
%         genes{i} = 'WTI';
%     else
%         genes{i} = worms.gene{i}(1:3);
%     end
% end
% [genes, ~, indices] = unique(genes);
% ticks = nan(1, length(genes));
% % set(gca, 'XTick', 1:length(worms.gene));
% % set(gca, 'XTickLabel', worms.gene);
% set(gca, 'XTick', ticks);
% set(gca, 'XTickLabel', genes);
% xticklabel_rotate();
end
