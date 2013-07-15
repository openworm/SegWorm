function wormStats2OntologyNetCSV(filename, wormFiles, varargin)
%WORMSTATS2ONTOLOGYNETCSV Convert a worm's significant features to an
%ontology network CSV file.
%
%   WORMSTATS2ONTOLOGYNETCSV(FILENAME, WORMFILES)
%
%   WORMSTATS2ONTOLOGYNETCSV(FILENAME, WORMFILES,
%                            USEGENOTYPES, ISSTRICTMATCH,
%                            ISTTEST, FEATUREPALPHA, FEATUREQALPHA,
%                            STRAINPALPHA, STRAINQALPHA,
%                            ISCATEGORIZED, SEPARATOR, ISVERBOSE)
%
%   Inputs:
%       filename      - the CSV filename
%       wormFiles     - the filenames containing the worm statistics
%       useGenotypes  - the genotype(s) to annotate;
%                       if empty, all genotypes are used
%                       the default is all (empty)
%       isStrictMatch - for each of the genotype(s) to annotate, are we
%                       searching for an identical match (as opposed to
%                       searching for a matching substring)?
%                       if empty, we search for an identical match
%                       the default is an identical match (true)
%       isTTest       - are we using the t-test (normally distributed) or
%                       Wilcoxon rank-sum (non parametric) statistics;
%                       the default is non-parametric statistics (false)
%       featurePAlpha - the threshold for feature p-value significance
%                       the default is < 1
%       featureQAlpha - the threshold for feature q-value significance
%                       the default is < 0.05
%       strainPAlpha  - the threshold for strain p-value significance
%                       the default is < 1
%       strainQAlpha  - the threshold for strain q-value significance
%                       the default is < 1
%       separator     - the separator string to use
%                       the default is ','
%       isVerbose     - verbose mode displays the progress;
%                       the default is yes (true)
%
% See also WORMSTATS2ONTOLOGY, WORM2STATSINFO
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Which genotypes should we use?
useGenotypes = [];
if ~isempty(varargin)
    useGenotypes = varargin{1};
end

% Are we searching for an identical genotype match?
isStrictMatch = [];
if length(varargin) > 1
    isStrictMatch = varargin{2};
end
if isempty(isStrictMatch)
    isStrictMatch = true;
end

% Are we using a t-test or Wilcoxon rank-sum?
isTTest = false;
if length(varargin) > 2
    isTTest = varargin{3};
end

% What is the threshold for feature p signficance?
featurePAlpha = 1;
if length(varargin) > 3
    featurePAlpha = varargin{4};
end

% What is the threshold for feature q signficance?
featureQAlpha = 0.05;
if length(varargin) > 4
    featureQAlpha = varargin{5};
end

% % What is the threshold for feature power?
% featurePower = 0;
% if length(varargin) > 5
%     featurePower = varargin{6};
% end

% What is the threshold for worm (strain) p significance?
strainPAlpha = 1;
if length(varargin) > 6
    strainPAlpha = varargin{7};
end

% What is the threshold for worm (strain) q significance?
strainQAlpha = 1;
if length(varargin) > 7
    strainQAlpha = varargin{8};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 8
    isVerbose = varargin{9};
end

% Convert the worms to annotations.
strains = wormStats2Ontology(wormFiles, useGenotypes, isStrictMatch, ...
    isTTest, featurePAlpha, featureQAlpha, ... %featurePower, ...
    strainPAlpha, strainQAlpha, isVerbose);

% Open the file.
file = fopen(filename, 'w');

% Write the header.
fprintf(file, ['Strain' sepStr 'Genotype' sepStr 'Gene' sepStr ...
    'Category' sepStr 'Term' sepStr 'Sign' sepStr ...
    'Min P-value' sepStr 'Min Q-Value\n']); %sepStr 'Max Power\n']);

% Write the annotations.
for i = 1:length(strains)
    
    % Show the progress.
    if isVerbose
        disp(['Printing ' num2str(i) '/' num2str(length(strains)) ...
            ' "' strains(i).genotype '" ...']);
    end
    
    % Write the annotation.
    annotation = strains(i).annotation;
    for j = 1:length(annotation)
        fprintf(file, '"%s"%s"%s"%s"%s"%s"%s"%s"%s"%s%d%s%d%s%d\n', ...
            strains(i).strain, sepStr, ...
            strains(i).genotype, sepStr, ...
            strains(i).gene, sepStr, ...
            annotation(j).category, sepStr, ...
            annotation(j).term, sepStr, ...
            annotation(j).sign, sepStr, ...
            min(annotation(j).pValues), sepStr, ...
            min(annotation(j).qValues));
%             max(annotation(j).powers));
    end
end

% Close the file.
fclose(file);
end
