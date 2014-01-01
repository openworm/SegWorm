function [strains, reference] = wormStats2Ontology(filenames, varargin)
%WORMSTATS2ONTOLOGY Convert a worm's significant features to ontology.
%
%   WORMSTATS2ONTOLOGY(FILENAME)
%
%   WORMSTATS2ONTOLOGY(FILENAME, USEGENOTYPES, ISSTRICTMATCH, ISTTEST,
%                      FEATUREPALPHA, FEATUREQALPHA,
%                      STRAINPALPHA, STRAINQALPHA, ISVERBOSE)
%
%   Inputs:
%       filenames     - the filenames containing the statistics
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
%       isVerbose     - verbose mode displays the progress;
%                       the default is yes (true)
%
%   Outputs:
%       strains - the strain annotations, a struct with fields:
%
%                 genotype   = the genotype
%                 strain     = the strain
%                 gene       = the gene
%                 allele     = the allele
%                 pValue     = the p-value
%                 qValue     = the q-value
%                 annotation = the annotations:
%
%                              category = the annotation category
%                              terms    = the annotation term
%                              features = the associated feature indices
%                              pValues  = the associated p-values
%                              qValues  = the associated q-values
%                              signs    = the annotation sign:
%
%                                          1 = the feature is > control
%                                          0 = the feature is ~= control
%                                         -1 = the feature is < control
%
%       reference - a reference for the annotations, a struct with fields:
%
%                   category     = the annotation category
%                   term         = the annotation term
%                   indices      = the associated feature indices
%                   alternatives = the alternative reference indices
%
% See also WORMONTOLOGY2STRING, WORM2STATSINFO
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

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 7
    isVerbose = varargin{8};
end

% Fix the data.
if ~iscell(filenames)
    filenames = {filenames};
end
if ~isempty(useGenotypes) && ~iscell(useGenotypes)
    useGenotypes = {useGenotypes};
end
if length(useGenotypes) > length(isStrictMatch)
    isStrictMatch((end + 1):length(useGenotypes)) = isStrictMatch(end);
end

% Initialize the reference of annotations.
reference = [];
refI = 0;
bothSigns = 'b';
unSign = 'u';
noSign = '0';
posSign = '+';
negSign = '-';
absSign = 'a';



%% Morphology.

% Length.
refI = refI + 1;
lengthI = refI;
reference(lengthI).term = 'Length';
reference(lengthI).category = 'Body';
reference(lengthI).indices = 1;
reference(lengthI).alternatives = [];
reference(lengthI).sign = unSign;

% Width.
refI = refI + 1;
widthI = refI;
reference(widthI).term = 'Width';
reference(widthI).category = 'Body';
reference(widthI).indices = 2:4;
reference(widthI).sign = unSign;
reference(widthI).alternatives = [];

% Area.
refI = refI + 1;
areaI = refI;
reference(areaI).term = 'Area';
reference(areaI).category = 'Body';
reference(areaI).indices = 5;
reference(areaI).sign = unSign;
reference(areaI).alternatives = [lengthI widthI];

% Proportion.
refI = refI + 1;
proportionI = refI;
reference(proportionI).term = 'Proportion';
reference(proportionI).category = 'Body';
reference(proportionI).indices = 6:7;
reference(proportionI).sign = noSign;
reference(proportionI).alternatives = [lengthI widthI areaI];



%% Posture.

% Head bends.
refI = refI + 1;
headBendsI = refI;
reference(headBendsI).term = 'Head Bends';
reference(headBendsI).category = 'Posture';
reference(headBendsI).indices = [8, 13];
reference(headBendsI).sign = unSign;
reference(headBendsI).alternatives = [];

% Tail bends.
refI = refI + 1;
tailBendsI = refI;
reference(tailBendsI).term = 'Tail Bends';
reference(tailBendsI).category = 'Posture';
reference(tailBendsI).indices = [12, 17];
reference(tailBendsI).sign = unSign;
reference(tailBendsI).alternatives = [];

% Postural amplitude.
refI = refI + 1;
posAmpI = refI;
reference(posAmpI).term = 'Posture Amplitude';
reference(posAmpI).category = 'Posture';
reference(posAmpI).indices = 18;
reference(posAmpI).sign = unSign;
reference(posAmpI).alternatives = [];

% Postural amplitude ratio.
refI = refI + 1;
posAmpRatioI = refI;
reference(posAmpRatioI).term = 'Posture Amplitude';
reference(posAmpRatioI).category = 'Posture';
reference(posAmpRatioI).indices = 19;
reference(posAmpRatioI).sign = noSign;
reference(posAmpRatioI).alternatives = posAmpI;

% Posture wavelength.
refI = refI + 1;
posWavelengthI = refI;
reference(posWavelengthI).term = 'Posture Wavelength';
reference(posWavelengthI).category = 'Posture';
reference(posWavelengthI).indices = 20:21;
reference(posWavelengthI).sign = unSign;
reference(posWavelengthI).alternatives = [];

% Posture wave.
refI = refI + 1;
posWaveI = refI;
reference(posWaveI).term = 'Posture Wave';
reference(posWaveI).category = 'Posture';
reference(posWaveI).indices = 22;
reference(posWaveI).sign = noSign;
reference(posWaveI).alternatives = [posAmpI posAmpRatioI posWavelengthI];

% Body Bends.
refI = refI + 1;
bodyBendsI = refI;
reference(bodyBendsI).term = 'Body Bends';
reference(bodyBendsI).category = 'Posture';
reference(bodyBendsI).indices = [9:11, 14:16, 23:24];
reference(bodyBendsI).sign = unSign;
reference(bodyBendsI).alternatives = ...
    [posAmpI posAmpRatioI posWavelengthI posWaveI];

% Pose.
refI = refI + 1;
poseI = refI;
reference(poseI).term = 'Pose';
reference(poseI).category = 'Posture';
reference(poseI).indices = 29;
reference(poseI).sign = noSign;
reference(poseI).alternatives = [headBendsI bodyBendsI tailBendsI ...
    posAmpI posAmpRatioI posWavelengthI posWaveI];

% Orientation.
% refI = refI + 1;
% orientationI = refI;
% reference(orientationI).term = 'Orientation';
% reference(orientationI).indices = 26:28;
% reference(orientationI).sign = noSign;
% reference(orientationI).alternatives = [];

% Coils.
refI = refI + 1;
coilsI = refI;
reference(coilsI).term = 'Coils';
reference(coilsI).category = 'Posture';
reference(coilsI).indices = 25;
reference(coilsI).sign = unSign;
reference(coilsI).alternatives = [];



%% Locomotion.

% Foraging
refI = refI + 1;
foragingI = refI;
reference(foragingI).term = 'Foraging';
reference(foragingI).category = 'Motion';
reference(foragingI).indices = [43, 47];
reference(foragingI).sign = unSign;
reference(foragingI).alternatives = [];

% Forward velocity.
refI = refI + 1;
forwardVelI = refI;
reference(forwardVelI).term = 'Forward Velocity';
reference(forwardVelI).category = 'Motion';
reference(forwardVelI).indices = [35 40];
reference(forwardVelI).sign = posSign;
reference(forwardVelI).alternatives = [];

% Backward velocity.
refI = refI + 1;
backwardVelI = refI;
reference(backwardVelI).term = 'Backward Velocity';
reference(backwardVelI).category = 'Motion';
reference(backwardVelI).indices = [35 40];
reference(backwardVelI).sign = negSign;
reference(backwardVelI).alternatives = [];

% Absolute velocity.
refI = refI + 1;
absVelI = refI;
reference(absVelI).term = 'Velocity';
reference(absVelI).category = 'Motion';
reference(absVelI).indices = [35 40];
reference(absVelI).sign = absSign;
reference(absVelI).alternatives = [];

% Head motion.
refI = refI + 1;
headVelI = refI;
reference(headVelI).term = 'Head Motion';
reference(headVelI).category = 'Motion';
reference(headVelI).indices = [33:34 38:39];
reference(headVelI).sign = noSign;
reference(headVelI).alternatives = [foragingI forwardVelI backwardVelI];

% Tail motion.
refI = refI + 1;
tailVelI = refI;
reference(tailVelI).term = 'Tail Motion';
reference(tailVelI).category = 'Motion';
reference(tailVelI).indices = [36:37 41:42];
reference(tailVelI).sign = noSign;
reference(tailVelI).alternatives = [forwardVelI backwardVelI];

% Forward motion.
refI = refI + 1;
forwardI = refI;
reference(forwardI).term = 'Forward Motion';
reference(forwardI).category = 'Motion';
reference(forwardI).indices = 30;
reference(forwardI).sign = unSign;
reference(forwardI).alternatives = [];

% Pausing.
refI = refI + 1;
pausedI = refI;
reference(pausedI).term = 'Pausing';
reference(pausedI).category = 'Motion';
reference(pausedI).indices = 31;
reference(pausedI).sign = unSign;
reference(pausedI).alternatives = [];

% Backward motion.
refI = refI + 1;
backwardI = refI;
reference(backwardI).term = 'Backward Motion';
reference(backwardI).category = 'Motion';
reference(backwardI).indices = 32;
reference(backwardI).sign = unSign;
reference(backwardI).alternatives = [];

% Crawling amplitude.
refI = refI + 1;
crawlAmpI = refI;
reference(crawlAmpI).term = 'Crawling Amplitude';
reference(crawlAmpI).category = 'Motion';
reference(crawlAmpI).indices = 44:46;
reference(crawlAmpI).sign = unSign;
reference(crawlAmpI).alternatives = [];

% Crawling frequency.
refI = refI + 1;
crawlFreqI = refI;
reference(crawlFreqI).term = 'Crawling Frequency';
reference(crawlFreqI).category = 'Motion';
reference(crawlFreqI).indices = 48:50;
reference(crawlFreqI).sign = unSign;
reference(crawlFreqI).alternatives = [];

% Turns.
refI = refI + 1;
turnsI = refI;
reference(turnsI).term = 'Turns';
reference(turnsI).category = 'Motion';
reference(turnsI).indices = 51:52;
reference(turnsI).sign = unSign;
reference(turnsI).alternatives = [];



%% Path.

% Range.
refI = refI + 1;
rangeI = refI;
reference(rangeI).term = 'Path Range';
reference(rangeI).category = 'Path';
reference(rangeI).indices = 53;
reference(rangeI).sign = unSign;
reference(rangeI).alternatives = [];

% Path curvature.
refI = refI + 1;
pathCurveI = refI;
reference(pathCurveI).term = 'Path Curvature';
reference(pathCurveI).category = 'Path';
reference(pathCurveI).indices = 58;
reference(pathCurveI).sign = unSign;
reference(pathCurveI).alternatives = [];

% Dwelling.
refI = refI + 1;
dwellI = refI;
reference(dwellI).term = 'Dwelling';
reference(dwellI).category = 'Path';
reference(dwellI).indices = 54:57;
reference(dwellI).sign = unSign;
reference(dwellI).alternatives = pausedI;



%% Annotation.

% Initialize the annotations.
numStrains = 0;
strains.genotype = [];
strains.strain = [];
strains.gene = [];
strains.allele = [];
strains.annotation = [];

% Annotate the files.
info = wormStatsInfo();
for i = 1:length(filenames)

    % Load the statistics.
    significance = [];
    wormData = [];
    wormInfo = [];
    worm = [];
    if ~isempty(whos('-FILE', filenames{i}, 'worm'))
        load(filenames{i}, 'worm');
    elseif ~isempty(whos('-FILE', filenames{i}, 'significance'))
        load(filenames{i}, 'significance', 'wormData', 'wormInfo');
    else
        warning('wormStats2Ontology:BadFile', ...
            [filenames{i} ' has an unrecognized format']);
        numStrains = {};
        continue;
    end

    % Annotate the file.
    if isempty(worm)
        
        % Are we annotating this genotype?
        genotype = worm2GenotypeLabel(wormInfo);
        if ~isempty(useGenotypes)
            isFound = false;
            for j = 1:length(useGenotypes)
                if isStrictMatch(j)
                    isFound = strcmp(useGenotypes{j}, genotype);
                else
                    isFound = ~isempty(strfind(useGenotypes{j}, genotype));
                end
            end
            if ~isFound
                continue;
            end
        end
        
        % Show the progress.
        if isVerbose
            disp(['Annotating ' num2str(i) '/' num2str(length(filenames)) ...
                ' "' worm2GenotypeLabel(wormInfo) '" ...']);
        end
        
        % Find the significant features.
        sigI = [];
        sigWorm = significance.worm;
        if sigWorm.pValue <= strainPAlpha && sigWorm.qValue <= strainQAlpha

            % Find the feature significance.
            sigFeat = significance.features;
            if isTTest
                pValues = [sigFeat.pTValue];
                qValues = [sigFeat.qTValue];
            else
                pValues = [sigFeat.pWValue];
                qValues = [sigFeat.qWValue];
            end
%             powers = [sigFeat.power];
            
            % Find the significant features.
            sigI = qValues <= featureQAlpha & ...
                pValues <= featurePAlpha;
%                 powers >= featurePower;
            sigI = find(sigI);
        end
        
        % Translate the significant features to signed annotations.
        numStrains = numStrains + 1;
        strains(numStrains).genotype = genotype;
        strains(numStrains).strain = worm2StrainLabel(wormInfo);
        strains(numStrains).gene = worm2GeneLabel(wormInfo);
        strains(numStrains).allele = worm2AlleleLabel(wormInfo);
        strains(numStrains).pValue = sigWorm.pValue;
        strains(numStrains).qValue = sigWorm.qValue;
        strains(numStrains).annotation = [];
        if ~isempty(sigI)
            strains(numStrains).annotation = annotate(sigI, ...
                pValues(sigI), qValues(sigI), ... %powers(sigI), ...
                [wormData(sigI).zScore], reference, info);
        end
    
    % Annotate the matrix.
    else
        
        % Compute the thresholds.
        qAlpha = min(featureQAlpha, strainQAlpha);
        pAlpha = min(featurePAlpha, strainPAlpha);
        
        % Annotate the matrix.
        for j = 1:length(worm.info.genotype)
            
            % Are we annotating this genotype?
            genotype = worm.info.genotype{j};
            if ~isempty(useGenotypes)
                isFound = false;
                for k = 1:length(useGenotypes)
                    if isStrictMatch(k)
                        isFound = strcmp(useGenotypes{k}, genotype);
                    else
                        isFound = ...
                            ~isempty(strfind(useGenotypes{k}, genotype));
                    end
                end
                if ~isFound
                    continue;
                end
            end
            
            % Show the progress.
            if isVerbose
                disp(['Annotating ' ...
                    num2str(i) '/' num2str(length(filenames)) ' : ' ...
                    num2str(j) '/' num2str(length(worm.info.genotype)) ...
                    ' "' worm.info.genotype{j} '" ...']);
            end

            % Find the feature significance.
            if isTTest
                pValues = worm.sig.pTValue(j,:);
                qValues = worm.sig.qTValue.all(j,:);
            else
                pValues = worm.sig.pWValue(j,:);
                qValues = worm.sig.qWValue.all(j,:);
            end
%             powers = worm.sig.power(j,:);
            
            % Find the significant features.
            sigI = pValues <= pAlpha & qValues <= qAlpha;
%                  powers >= featurePower;
            sigI = find(sigI);
            
            % Annotate the strain.
            numStrains = numStrains + 1;
            strains(numStrains).genotype = genotype;
            strains(numStrains).strain = worm.info.strain{j};
            strains(numStrains).gene = worm.info.gene{j};
            strains(numStrains).allele = worm.info.allele{j};
            strains(numStrains).pValue = min(pValues);
            strains(numStrains).qValue = min(qValues);
            strains(numStrains).annotation = [];
            if ~isempty(sigI)
                strains(numStrains).annotation = annotate(sigI, ...
                    pValues(sigI), qValues(sigI), ... %powers(sigI), ...
                    worm.stats.zScore(j,sigI), reference, info);
            end
        end
    end
end

% Clean up the reference.
reference = rmfield(reference, 'sign');
end



%% Annotate the features.
function annotation = annotate(features, pValues, qValues, ... %powers, ...
    zScores, reference, info)

% Determine the main features.
[mainI, ~, subI] = unique([info(features).title1I]);
featureI = cell(length(mainI), 1);
sigI = cell(length(mainI), 1);
pValueI = cell(length(mainI), 1);
qValueI = cell(length(mainI), 1);
% powerI = cell(length(mainI), 1);
zScoreI = cell(length(mainI), 1);
for i = 1:length(mainI)
    featureI{i} = features(i == subI);
    sigI{i} = features(i == subI);
    pValueI{i} = pValues(i == subI);
    qValueI{i} = qValues(i == subI);
%     powerI{i} = powers(i == subI);
    zScoreI{i} = zScores(i == subI);
end

% Match the main features to the reference.
numRefs = 0;
refI = [];
mainIs = [];
featureIs = [];
sigIs = [];
pValueIs = [];
qValueIs = [];
% powerIs = [];
zScoreIs = [];
for i = 1:length(reference)
    [refFeatures, ~, refFeatureI] = intersect(reference(i).indices, mainI);
    if ~isempty(refFeatures)
        numRefs = numRefs + 1;
        refI(numRefs) = i;
        mainIs{numRefs} = refFeatures;
        featureIs{numRefs} = cat(2, featureI{refFeatureI});
        sigIs{numRefs} = cat(2, sigI{refFeatureI});
        pValueIs{numRefs} = cat(2, pValueI{refFeatureI});
        qValueIs{numRefs} = cat(2, qValueI{refFeatureI});
%         powerIs{numRefs} = cat(2, powerI{refFeatureI});
        zScoreIs{numRefs} = cat(2, zScoreI{refFeatureI});
    end
end

% Compute redundant references.
alternateI = cell(length(refI), 1);
keep = false(length(refI), 1);
for i = 1:length(refI)
    
    % Are there any alternatives?
    [~, ~, alternateI{i}] = ...
        intersect(reference(refI(i)).alternatives, refI);
    
    % Remove the redundant reference.
    if isempty(alternateI{i})
        keep(i) = true;
        
    % Route my alternatives to the new alternative.
    else
        for j = 1:(i - 1)
            iI = find(alternateI{j} == i);
            if ~isempty(iI)
                alternateI{j}(iI) = [];
                alternateI{j} = cat(2, alternateI{j}, alternateI{i});
            end
        end
    end
end

% Assign significance to the alternatives
% for i = find(~keep)'
%     for j = alternateI{i}
%         sigIs{j} = cat(2, sigIs{j}, sigIs{i});
%         pValueIs{j} = cat(2, pValueIs{j}, pValueIs{i});
%         qValueIs{j} = cat(2, qValueIs{j}, qValueIs{i});
%         powerIs{j} = cat(2, powerIs{j}, powerIs{i});
%     end
% end

% Remove redundant references.
if 0
refI = refI(keep);
mainIs = mainIs(keep);
featureIs = featureIs(keep);
sigIs = sigIs(keep);
pValueIs = pValueIs(keep);
qValueIs = qValueIs(keep);
% powerIs = powerIs(keep);
zScoreIs = zScoreIs(keep);
end

% Annotate the features.
bothSigns = 'b';
unSign = 'u';
noSign = '0';
posSign = '+';
negSign = '-';
absSign = 'a';
annotationI = 0;
annotation = [];
for i = 1:length(refI)
    switch reference(refI(i)).sign
        
        % Add the term and determine the sign.
        case unSign
            
            % Add the term.
            annotationI = annotationI + 1;
            annotation(annotationI).term = reference(refI(i)).term;
            annotation(annotationI).category = reference(refI(i)).category;
            annotation(annotationI).features = sigIs{i};
            annotation(annotationI).pValues = pValueIs{i};
            annotation(annotationI).qValues = qValueIs{i};
%             annotation(annotationI).powers = powerIs{i};
            
            % Determine the potential signs.
            features = featureIs{i};
            zScores = zScoreIs{i};
            potentialSigns = nan(length(features), 1);
            for j = 1:length(features)
                
                % Ignore the sign for signed symmetry.
                if info(features(j)).sign == 's'
                    potentialSigns(j) = 0;
                    
                % Invert the sign for inter events.
                elseif info(features(j)).type == 'i'
                    if info(features(j)).sign == 'n'
                        potentialSigns(j) = sign(zScores(j));
                    else
                        potentialSigns(j) = -sign(zScores(j));
                    end
                    
                % Invert the sign for negative data.
                elseif info(features(j)).sign == 'n'
                    potentialSigns(j) = -sign(zScores(j));
                    
                % Use the sign for unsigned, absolute, and positive data.
                else
                    potentialSigns(j) = sign(zScores(j));
                end
            end
            
            % Determine the sign.
            uniqueSigns = unique(potentialSigns);
            if length(uniqueSigns) > 1
                annotation(annotationI).sign = 0;
            else
                annotation(annotationI).sign = uniqueSigns;
            end
        
        % Add the term.
        case noSign
            annotationI = annotationI + 1;
            annotation(annotationI).term = reference(refI(i)).term;
            annotation(annotationI).category = reference(refI(i)).category;
            annotation(annotationI).features = sigIs{i};
            annotation(annotationI).pValues = pValueIs{i};
            annotation(annotationI).qValues = qValueIs{i};
%             annotation(annotationI).powers = powerIs{i};
            annotation(annotationI).sign = 0;
            
        % Add the term if the changes are positively signed.
        case posSign
            
            % Determine the potential signs.
            features = featureIs{i};
            zScores = zScoreIs{i};
            potentialSigns = [];
            for j = 1:length(features)
                if info(features(j)).sign == 'p'
                    potentialSigns(end + 1) = sign(zScores(j));
                end
            end
            
            % Add the term and determine the sign.
            uniqueSigns = unique(potentialSigns);
            if ~isempty(uniqueSigns)
                annotationI = annotationI + 1;
                annotation(annotationI).term = reference(refI(i)).term;
                annotation(annotationI).category = ...
                    reference(refI(i)).category;
                
                % Filter the significance.
                keep = [info(sigIs{i}).sign] == 'p';
                annotation(annotationI).features = sigIs{i}(keep);
                annotation(annotationI).pValues = pValueIs{i}(keep);
                annotation(annotationI).qValues = qValueIs{i}(keep);
%                 annotation(annotationI).powers = powerIs{i}(keep);
                
                % Determine the sign.
                if length(uniqueSigns) > 1
                    annotation(annotationI).sign = 0;
                else
                    annotation(annotationI).sign = uniqueSigns;
                end
            end
            
        % Add the term if the changes are negatively signed.
        case negSign
            
            % Determine the potential signs.
            features = featureIs{i};
            zScores = zScoreIs{i};
            potentialSigns = [];
            for j = 1:length(features)
                if info(features(j)).sign == 'n'
                    potentialSigns(end + 1) = -sign(zScores(j));
                end
            end
            
            % Add the term and determine the sign.
            uniqueSigns = unique(potentialSigns);
            if ~isempty(uniqueSigns)
                annotationI = annotationI + 1;
                annotation(annotationI).term = reference(refI(i)).term;
                annotation(annotationI).category = ...
                    reference(refI(i)).category;
                
                % Filter the significance.
                keep = [info(sigIs{i}).sign] == 'n';
                annotation(annotationI).features = sigIs{i}(keep);
                annotation(annotationI).pValues = pValueIs{i}(keep);
                annotation(annotationI).qValues = qValueIs{i}(keep);
%                 annotation(annotationI).powers = powerIs{i}(keep);
                
                
                % Determine the sign.
                if length(uniqueSigns) > 1
                    annotation(annotationI).sign = 0;
                else
                    annotation(annotationI).sign = uniqueSigns;
                end
            end
            
        % Add the term if the changes are absolutely signed.
        case absSign
            
            % Determine the potential signs.
            features = featureIs{i};
            zScores = zScoreIs{i};
            isAbs = [];
            potentialSigns = [];
            for j = 1:length(features)
                
                % We found an absolute feature.
                if (info(features(j)).sign == 'a' || ...
                        info(features(j)).sign == 'u') && ...
                        (isempty(isAbs) || isAbs)
                    isAbs = true;
                    potentialSigns(end + 1) = sign(zScores(j));
                    
                % We found a symmetry feature.
                elseif info(features(j)).sign == 's' && ...
                        (isempty(isAbs) || isAbs)
                    isAbs = true;
                    potentialSigns(end + 1) = 0;
                    
                % We found postive and/or negative features.
                elseif info(features(j)).sign == 'p' || ...
                        info(features(j)).sign == 'n'
                    isAbs = false;
                    potentialSigns = [];
                end
            end
            
            % Add the term and determine the sign.
            uniqueSigns = unique(potentialSigns);
            if ~isempty(uniqueSigns)
                annotationI = annotationI + 1;
                annotation(annotationI).term = reference(refI(i)).term;
                annotation(annotationI).category = ...
                    reference(refI(i)).category;
                annotation(annotationI).features = sigIs{i};
                annotation(annotationI).pValues = pValueIs{i};
                annotation(annotationI).qValues = qValueIs{i};
%                 annotation(annotationI).powers = powerIs{i};
                
                % Determine the sign.
                if length(uniqueSigns) > 1
                    annotation(annotationI).sign = 0;
                else
                    annotation(annotationI).sign = uniqueSigns;
                end
            end
    end
end
end
