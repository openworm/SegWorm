function exps = ...
    wormExps(dirPath, gene, allele, strain, isFood, side, tracker)
%WORMEXPS Find worm experiments matching the given criteria.
%
%   WORMEXPS(DIRPATH, GENE, ALLELE, STRAIN, ISFOOD, SIDE, TRACKER)
%
%   Inputs:
%       dirPath - the directory for experiments
%       gene    - the worm's gene;
%                 use [] for 'gene NA'
%                 use '*' for all genes
%       allele  - the worm's allele
%                 use [] for 'allele NA'
%                 use '*' for all alleles
%       strain  - the worm's strain
%                 use [] for 'strain NA'
%                 use '*' for all strains
%       isFood  - is the worm on food?
%                 use [] for 'food NA'
%                 use '*' for all food types
%       side    - the left/right location of the worm's ventral side
%                 use 'L' for left
%                 use 'R' for right
%                 use [] for 'vulvaside NA'
%                 use '*' for all sides
%       tracker - the tracker number
%                 use [] for 'tracker NA'
%                 use '*' for all trackers
%
%   Output:
%       exps - a list of worm experiments matching the given criteria
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Fix the directory.
wormPath = dirPath;
fSep = filesep();
if ~isempty(wormPath) && wormPath(end) ~= fSep
    wormPath(end + 1) = fSep;
end

% Fix the gene, allele, and strain.
if isempty(gene)
    gene = 'gene NA';
end
if isempty(allele)
    allele = 'allele NA';
end
if isempty(gene)
    strain = 'strain NA';
end

% Construct the strain path.
wormPath = [wormPath gene fSep allele fSep strain];

% Construct the food path.
if isempty(isFood)
    wormPath = [wormPath fSep 'food NA'];
elseif ischar(isFood) && isFood == '*'
    wormPath = [wormPath fSep '*'];
elseif isFood
    wormPath = [wormPath fSep 'on food'];
else
    wormPath = [wormPath fSep 'off food'];
end

% Use all dates.
wormPath = [wormPath fSep '*'];

% Construct the ventral side path.
if isempty(side)
    wormPath = [wormPath fSep 'vulvaside NA'];
else
    wormPath = [wormPath fSep upper(side)];
end

% Construct the tracker path.
if isempty(tracker)
    wormPath = [wormPath fSep 'tracker NA'];
elseif ischar(tracker) && tracker == '*'
    wormPath = [wormPath fSep '*'];
else
    wormPath = [wormPath fSep num2str(tracker)];
end

% Get the experiments.
try
    expStr = ls(wormPath);
catch exception
    expStr = [];
end
if isempty(expStr)
    error('wormStats:NoExperiments', ['No experiments were found in ' ...
        'the directory "' wormPath '"!']);
end

% Parse the experiments.
if isempty(strfind(expStr, ':'))
    [~, expDir] = unix(['cd ' strrep(wormPath, ' ', '\ ') '; pwd']);
    expStrs = strread(expStr, '%s', 'delimiter', '\n');
    exps(length(expStrs)) = struct( ...
        'path', [], ...
        'dir', [], ...
        'file', [], ...
        'gene', [], ...
        'allele', [], ...
        'strain', [], ...
        'date', [], ...
        'food', [], ...
        'side', [], ...
        'tracker', []);
%         'info', []);
    for i = 1:length(expStrs)
        exps(i).dir = expDir;
        exps(i).file = expStrs{i};
        exps(i).path = [exps(i).dir fSep exps(i).file];
    end
    
% Parse the recursive experiments.
else
    expStrs = strread(expStr, '%s', 'delimiter', ':');
    numExps = length(expStrs) / 2;
    exps(numExps) = struct( ...
        'path', [], ...
        'dir', [], ...
        'file', [], ...
        'gene', [], ...
        'allele', [], ...
        'strain', [], ...
        'date', [], ...
        'food', [], ...
        'side', [], ...
        'tracker', []);
    %     'info', []);
    for i = 1:2:(length(expStrs) - 1)
        j = (i + 1) / 2;
        exps(j).dir = expStrs{i};
        exps(j).file = expStrs{i + 1};
        exps(j).path = [exps(j).dir fSep exps(j).file];
    end
end

% Parse the experiments information.
minSeps = 7;
geneI = 6;
alleleI = 5;
strainI = 4;
foodI = 3;
dateI = 2;
sideI = 1;
trackerI = 0;
dateFormat = 'yyyy-mm-dd   HH_MM_SS';
for i = 1:length(exps)
    
    % Parse the directory name.
    expDir = exps(i).dir;
    sepIs = findstr(expDir, fSep);
    
    % Parse the gene.
    if length(sepIs) < minSeps
        geneStr = ...
            expDir(1:(sepIs(end - geneI + 1) - 1));
    else
        geneStr = ...
            expDir((sepIs(end - geneI) + 1):(sepIs(end - geneI + 1) - 1));
    end
    if strcmp(geneStr, 'gene NA')
        geneStr = [];
    end
    exps(i).gene = geneStr;

    % Parse the allele.
    alleleStr = ...
        expDir((sepIs(end - alleleI) + 1):(sepIs(end - alleleI + 1) - 1));
    if strcmp(alleleStr, 'allele NA')
        alleleStr = [];
    end
    exps(i).allele = alleleStr;

    % Parse the strain.
    strainStr = ...
        expDir((sepIs(end - strainI) + 1):(sepIs(end - strainI + 1) - 1));
    if strcmp(strainStr, 'strain NA')
        strainStr = [];
    end
    exps(i).strain = strainStr;

    % Parse the date.
    dateStr = ...
        expDir((sepIs(end - dateI) + 1):(sepIs(end - dateI + 1) - 1));
    exps(i).date = datenum(dateStr, dateFormat);
    
    % Parse the food.
    foodStr = ...
        expDir((sepIs(end - foodI) + 1):(sepIs(end - foodI + 1) - 1));
    switch foodStr
        case 'off food'
            exps(i).food = false;
        case 'on food'
            exps(i).food = true;
        otherwise
            exps(i).food = NaN;
    end
    
    % Parse the side.
    sideStr = ...
        expDir((sepIs(end - sideI) + 1):(sepIs(end - sideI + 1) - 1));
    if strcmp(sideStr, 'L') && strcmp(sideStr,'R')
        sideStr = 'X';
    end
    exps(i).side = sideStr;
    
    % Parse the tracker.
    trackerStr = expDir((sepIs(end - trackerI) + 1):end);
    if strcmp(trackerStr, 'tracker NA')
        exps(i).tracker = NaN;
    else
        exps(i).tracker = str2double(trackerStr(end));
    end
    
%     % Load the data.
%     exps(i).info = load(exps(i).path, 'featureData', 'myAviInfo');
%     if isempty(exps(i).info)
%         error('wormStats:NoFeatures', ['"' file ...
%             '" does not contain feature data!' ]);
%     end
end
end
