function fileInfo = updateExperimentPaths(fileInfo, newExperimentPaths)
% UPDATEEXPERIMENTPATHS This function will take the fileInfo variable with
% information about the experiment and try to update the file pahts that
% might have changed by comparing it with newExperimentPahts
%
% Input:
%       fileInfo - fileInfo variable that is saved in the process file
%       newExperimentPaths - paths discovered by the directory search for
%       this experiment
%
% Output:
%       fileInfo - updated fileInfo variable
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

fieldsList = fields(newExperimentPaths);

for i = 1:length(fieldsList)
    if isfield(fileInfo.expList, fieldsList{i}) && isfield(newExperimentPaths, fieldsList{i})
        if ~strcmp(fileInfo.expList.(fieldsList{i}), newExperimentPaths.(fieldsList{i}))
            fileInfo.expList.(fieldsList{i}) = newExperimentPaths.(fieldsList{i});
        end
    end
end