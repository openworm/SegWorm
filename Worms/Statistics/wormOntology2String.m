function strings = wormOntology2String(annotations)
%WORMONTOLOGY2STRING Convert worm phenotype ontology to strings.
%
%   WORMONTOLOGY2STRING(ANNOTATIONS)
%
%   Input:
%       annotations - the annotations, a struct with fields:
%                     categories = a cell array of categories
%                     terms      = a cell array of terms
%                     signs      = an array of signs
%                                   1 = the feature is > control
%                                   0 = the feature is ~= control
%                                  -1 = the feature is < control
%
%   Output:
%       strings - the ontology strings

% Fix the annotations.
if ~iscell(annotations)
    annotations = {annotations};
end

% Convert the annotations to strings.
strings = cell(length(annotations), 1);
for i = 1:length(annotations)
    for j = 1:length(annotations{i})
        annotation = annotations{i}(j);
        
        % Determine the sign.
        if annotation.sign < 0
            signStr = '-';
        elseif annotation.sign > 0
            signStr = '+';
        else
            signStr = '!';
        end
        
        % Construct the string.
        strings{i} = [strings{i} annotation.category ': ' ...
            signStr annotation.term 10];
    end
end
end

