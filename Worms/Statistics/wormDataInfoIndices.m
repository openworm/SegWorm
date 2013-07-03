function [morphologyI postureI locomotionI pathI] = wormDataInfoIndices()
%WORMDATAINFOINDICES Separate the worm data information into morphology,
%posture, locomotion, and path features.
%
%   [MORPHOLOGYI POSTUREI LOCOMOTIONI PATHI] = WORMDATAINFOINDICES()
%
%   Outputs:
%       morphologyI - the indices for the morphology features
%       postureI    - the indices for the posture features
%       locomotionI - the indices for the locomotion features
%       pathI       - the indices for the path features
%
% See also WORMDATAINFO

% Separate the worm data fields into their feature categories.
info = wormDataInfo();
morphologyI = ...
    find(arrayfun(@(x) ~isempty(strfind(x.field, 'morphology.')), info));
postureI = ...
    find(arrayfun(@(x) ~isempty(strfind(x.field, 'posture.')), info));
locomotionI = ...
    find(arrayfun(@(x) ~isempty(strfind(x.field, 'locomotion.')), info));
pathI = ...
    find(arrayfun(@(x) ~isempty(strfind(x.field, 'path.')), info));
end

