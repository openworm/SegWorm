% Initialize the control info.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
controlFile = 'N2_stat.mat';
load(controlFile, 'wormInfo');

% Filter out bad experiments.
isUsed = filterWormInfo(wormInfo, standardWormFilter());
wormInfo = wormInfo(isUsed);

% Get the dates.
dates = arrayfun(@(x) datenum(x.experiment.environment.timestamp), ...
    wormInfo);
[year month day] = datevec(dates);
controlDates = datenum(year, month, day);

% Free memory.
clear('wormInfo');

% Go through the strains.
files = rdir('*_stat.mat');
numI = 0;
numWorms = [];
numControls = [];
strains = [];
genotypes = [];
for i = 1:length(files)
    
    % Load the worm information.
    name = files(i).name;
    if strcmp(name, controlFile);
        continue;
    end
    load(name, 'wormInfo');
    
    % Get the dates.
    dates = arrayfun(@(x) datenum(x.experiment.environment.timestamp), ...
        wormInfo);
    [year month day] = datevec(dates);
    dates = datenum(year, month, day);
    dates = unique(dates);
    
    % Get the controls.
    isControl = false(size(controlDates));
    for j = 1:length(dates)
        isControl = isControl | ...
            (controlDates >= dates(j) - 7 & controlDates <= dates(j) + 7);
    end
    controls = controlDates(isControl);
    
    % Compute the number of worms and controls.
    numI = numI + 1;
    numWorms(numI) = length(wormInfo);
    numControls(numI) = length(controls);
    
    % Display the info.
    strains{numI} = wormInfo(1).experiment.worm.strain;
    genotypes{numI} = wormInfo(1).experiment.worm.genotype;
    id = [genotypes{numI} ' ' strains{numI}];
    disp(['"' id '" worms= ' num2str(numWorms(numI)) ...
        ' controls=' num2str(numControls(numI))]);
end
