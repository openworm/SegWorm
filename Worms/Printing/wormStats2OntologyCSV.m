function wormStats2OntologyCSV(filename, wormFiles, varargin)
%WORMSTATS2ONTOLOGYCSV Convert a worm's significant features to an ontology
%CSV file.
%
%   WORMSTATS2ONTOLOGYCSV(FILENAME, WORMFILES)
%
%   WORMSTATS2ONTOLOGYCSV(FILENAME, WORMFILES, USEGENOTYPES, ISSTRICTMATCH,
%                         ISTTEST, FEATUREPALPHA, FEATUREQALPHA,
%                         STRAINPALPHA, STRAINQALPHA, ISCATEGORIZED,
%                         SEPARATOR, ISVERBOSE)
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
%       isCategorized - are we grouping the terms by category
%                       the default is no (false)
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
if length(varargin) > 5
    strainPAlpha = varargin{6};
end

% What is the threshold for worm (strain) q significance?
strainQAlpha = 1;
if length(varargin) > 6
    strainQAlpha = varargin{7};
end

% Are we grouping the terms by category?
isCategorized = false;
if length(varargin) > 7
    isCategorized = varargin{8};
end

% What string should we use as the separator?
sepStr = ',';
if length(varargin) > 8
    sepStr = varargin{9};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 9
    isVerbose = varargin{10};
end

% Fix the worm files.
if ~iscell(wormFiles)
    wormFiles = {wormFiles};
end

% Initialize the categories.
categories = {
    'Body'
    'Posture'
    'Motion'
    'Path'
    };

% Convert the worms to annotations.
strains = wormStats2Ontology(wormFiles, useGenotypes, isStrictMatch, ...
    isTTest, featurePAlpha, featureQAlpha, ... %featurePower, ...
    strainPAlpha, strainQAlpha, isVerbose);

% Sort the annotations.
[~, sortI] = sort_nat(lower({strains.genotype}));
strains = strains(sortI);

% Open the file.
file = fopen(filename, 'w');

% Write the header.
if isCategorized
    fprintf(file, ['Genotype' sepStr sepStr 'Strain' sepStr sepStr ...
        'P-Value' sepStr 'Q-Value' sepStr]);
    for i = 1:length(categories)
        fprintf(file, [sepStr categories{i}]);
    end
    fprintf(file, '\n');
else
    fprintf(file, ['Genotype' sepStr sepStr 'Strain' sepStr sepStr ...
        'P-Value' sepStr 'Q-Value' sepStr sepStr ...
        'Category' sepStr 'Terms\n']);
end

% Write the annotations.
for i = 1:length(strains)
    
    % Show the progress.
    if isVerbose
        disp(['Printing ' num2str(i) '/' num2str(length(strains)) ...
            ' "' strains(i).genotype '" ...']);
    end
    
    % Convert annotation terms to category and term strings.
    [categoryStr termStr] = ...
        annotation2str(strains(i).annotation, categories);
    
    % Write the categorized annotation.
    if isCategorized
        
        % Print the genotype and significance.
        fprintf(file, '"%s"%s%s"%s"%s%s%d%s%d%s', ...
            strains(i).genotype, sepStr, sepStr, ...
            strains(i).strain, sepStr, sepStr, ...
            strains(i).pValue, sepStr, ...
            strains(i).qValue, sepStr);
        
        % Print the terms per category.
        for j = 1:length(termStr)
            fprintf(file, '%s', sepStr);
            if ~isempty(termStr{j})
                fprintf(file, '"%s"', termStr{j});
            end
        end
        fprintf(file, '\n');
        
    % Write the uncategorized annotation.
    else
        
        % Combine the term strings.
        str = [];
        for j = 1:length(termStr)
            if ~isempty(termStr{j})
                if isempty(str)
                    str = [str termStr{j}];
                else
                    str = [str sepStr termStr{j}];
                end
            end
        end
        termStr = str;
        
        % Print the genotype and significance.
        fprintf(file, '"%s"%s%s"%s"%s%s%d%s%d%s%s', ...
            strains(i).genotype, sepStr, sepStr, ...
            strains(i).strain, sepStr, sepStr, ...
            strains(i).pValue, sepStr, ...
            strains(i).qValue, sepStr, sepStr);

        % Print the categories.
        if ~isempty(categoryStr)
            fprintf(file, '"%s"', categoryStr);
        end
        fprintf(file, '%s', sepStr);
        
        % Print the terms.
        if ~isempty(termStr)
            fprintf(file, '"%s"', termStr);
        end
        fprintf(file, '\n');
    end
end

% Close the file.
fclose(file);
end



%% Convert annotation terms to category and term strings.
function [categoryStr termStr] = annotation2str(annotation, categories)

% Do we have any annotations?
categoryStr = {};
termStr = cell(length(categories), 1);
if isempty(annotation)
    return;
end

% Initialize the separator string.
sepStr = ',';

% Organize the annotations by category.
for i = 1:length(categories)
    for j = 1:length(annotation)
        if strncmp(categories{i}, annotation(j).category, 2)
            categoryStr{i} = categories{i};
            termStr{i}{end + 1} = [sign2str(annotation(j).sign) ...
                annotation(j).term ...
                ' (' p2stars(min(annotation(j).qValues)) ')'];
        end
    end
end

% Create the category string.
str = [];
for i = 1:length(categoryStr)
    if ~isempty(categoryStr{i})
        if isempty(str)
            str = [str categoryStr{i}];
        else
            str = [str sepStr categoryStr{i}];
        end
    end
end
categoryStr = str;

% Create the categorical annotation strings.
for i = 1:length(termStr)
    str = termStr{i};
    if ~isempty(str)
        termStr{i} = str{1};
        for j = 2:length(str)
            termStr{i} = [termStr{i} sepStr str{j}];
        end
    end
end
end



%% Convert the sign to a string.
function signStr = sign2str(s)
if s < 0
    signStr = '-';
elseif s > 0
    signStr = '+';
else
    signStr = '?'; %char(177);
end 
end
