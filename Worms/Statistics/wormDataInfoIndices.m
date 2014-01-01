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
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

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

