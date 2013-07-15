function info = wormDisplayInfo()
%WORMDISPLAYINFO Get information for displaying the worm data.
%
%   INFO = WORMDISPLAYINFO()
%
%   Output:
%       info - information for displaying the worm data; a structure
%              mirroring the worm features, where each heading has the
%              following subfields:
%
%              name       = a descriptive name
%              shortName  = a shortened name
%
%              And each feature has the following subfields:
%
%              resolution = the resolution for the histogram
%              isZeroBin  = is the histogram centered at zero?
%              isSigned   = is the data signed (+/-)?
%              name       = a descriptive feature name (for titles)
%              shortName  = a shortened feature name (for legends)
%              unit       = the feature's measurement unit (for labels)
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.



%% Organize the worm morphology display information.

% Organize the morphology information.
info.morphology.name = 'Morphology Features';
info.morphology.shortName = 'Morphology';

% Organize the length information.
info.morphology.length.resolution = 1;
info.morphology.length.isZeroBin = false;
info.morphology.length.isSigned = false;
info.morphology.length.name = 'Length';
info.morphology.length.shortName = 'Length';
info.morphology.length.unit = 'Microns';

% Organize the width information.
info.morphology.width.name = 'Width';
info.morphology.width.shortName = 'Width';
fields = { ...
    'Head', ...
    'Midbody', ...
    'Tail'};
for i = 1:length(fields)
    field = lower(fields{i});
    info.morphology.width.(field).resolution = 1;
    info.morphology.width.(field).isZeroBin = false;
    info.morphology.width.(field).isSigned = false;
    info.morphology.width.(field).name = [fields{i} ' Width'];
    info.morphology.width.(field).shortName = fields{i};
    info.morphology.width.(field).unit = 'Microns';
end

% Organize the area information.
info.morphology.area.resolution = 100;
info.morphology.area.isZeroBin = false;
info.morphology.area.isSigned = false;
info.morphology.area.name = 'Area';
info.morphology.area.shortName = 'Area';
info.morphology.area.unit = 'Microns²';

% Organize the area/length information.
info.morphology.areaPerLength.resolution = 0.1;
info.morphology.areaPerLength.isZeroBin = false;
info.morphology.areaPerLength.isSigned = false;
info.morphology.areaPerLength.name = 'Area/Length';
info.morphology.areaPerLength.shortName = 'Area/Length';
info.morphology.areaPerLength.unit = 'Microns';

% Organize the width/length information.
info.morphology.widthPerLength.resolution = 0.0001;
info.morphology.widthPerLength.isZeroBin = false;
info.morphology.widthPerLength.isSigned = false;
info.morphology.widthPerLength.name = 'Width/Length';
info.morphology.widthPerLength.shortName = 'Width/Length';
info.morphology.widthPerLength.unit = 'No Units';



%% Organize the worm posture display information.

% Organize the posture information.
info.posture.name = 'Posture Features';
info.posture.shortName = 'Posture';

% Organize the bend mean information.
info.posture.bends.name = 'Bending Posture';
info.posture.bends.shortName = 'Bends';
fields = { ...
    'Head', ...
    'Neck', ...
    'Midbody', ...
    'Hips', ...
    'Tail'};
for i = 1:length(fields)
    
    % Organize the bend information.
    field = lower(fields{i});
    info.posture.bends.(field).name = ...
        [fields{i} ' ' info.posture.bends.name];
    info.posture.bends.(field).shortName = ...
        [fields{i} ' ' info.posture.bends.shortName];
    
    % Organize the bend mean information.
    info.posture.bends.(field).mean.resolution = 1;
    info.posture.bends.(field).mean.isZeroBin = true;
    info.posture.bends.(field).mean.isSigned = true;
    info.posture.bends.(field).mean.name = ...
        [fields{i} ' Bend Mean (+/- = D/V Inside)'];
    info.posture.bends.(field).mean.shortName = fields{i};
    info.posture.bends.(field).mean.unit = 'Degrees';

    % Organize the bend standard deviation information.
    info.posture.bends.(field).stdDev.resolution = 0.5;
    info.posture.bends.(field).stdDev.isZeroBin = true;
    info.posture.bends.(field).stdDev.isSigned = true;
    info.posture.bends.(field).stdDev.name = ...
        [fields{i} ' Bend S.D. (+/- = D/V Inside)'];
    info.posture.bends.(field).stdDev.shortName = fields{i};
    info.posture.bends.(field).stdDev.unit = 'Degrees';
end

% Organize the amplitude information.
info.posture.amplitude.name = 'Amplitude of the Posture';
info.posture.amplitude.shortName = 'Amplitude';
info.posture.amplitude.max.resolution = 1;
info.posture.amplitude.max.isZeroBin = false;
info.posture.amplitude.max.isSigned = false;
info.posture.amplitude.max.name = 'Max Amplitude';
info.posture.amplitude.max.shortName = 'Amplitude';
info.posture.amplitude.max.unit = 'Microns';
info.posture.amplitude.ratio.resolution = 0.01;
info.posture.amplitude.ratio.isZeroBin = false;
info.posture.amplitude.ratio.isSigned = false;
info.posture.amplitude.ratio.name = 'Amplitude Ratio';
info.posture.amplitude.ratio.shortName = 'Ratio';
info.posture.amplitude.ratio.unit = 'No Units';
    
% Organize the wavelength information.
info.posture.wavelength.name = 'Wavelength of the Posture';
info.posture.wavelength.shortName = 'Wavelength';
info.posture.wavelength.primary.resolution = 1;
info.posture.wavelength.primary.isZeroBin = false;
info.posture.wavelength.primary.isSigned = false;
info.posture.wavelength.primary.name = 'Primary Wavelength';
info.posture.wavelength.primary.shortName = 'Primary';
info.posture.wavelength.primary.unit = 'Microns';
info.posture.wavelength.secondary.resolution = 1;
info.posture.wavelength.secondary.isZeroBin = false;
info.posture.wavelength.secondary.isSigned = false;
info.posture.wavelength.secondary.name = 'Secondary Wavelength';
info.posture.wavelength.secondary.shortName = 'Secondary';
info.posture.wavelength.secondary.unit = 'Microns';

% Organize the track length information.
info.posture.tracklength.resolution = 1;
info.posture.tracklength.isZeroBin = false;
info.posture.tracklength.isSigned = false;
info.posture.tracklength.name = 'Track Length';
info.posture.tracklength.shortName = 'Track';
info.posture.tracklength.unit = 'Microns';

% Organize the eccentricity information.
info.posture.eccentricity.resolution = 0.01;
info.posture.eccentricity.isZeroBin = false;
info.posture.eccentricity.isSigned = false;
info.posture.eccentricity.name = 'Eccentricity';
info.posture.eccentricity.shortName = 'Eccentricity';
info.posture.eccentricity.unit = 'No Units';

% Organize the kink information.
info.posture.kinks.resolution = 1;
info.posture.kinks.isZeroBin = true;
info.posture.kinks.isSigned = false;
info.posture.kinks.name = 'Bend Count';
info.posture.kinks.shortName = 'Bends';
info.posture.kinks.unit = 'Counts';

% Organize the coil information.
info.posture.coils.name = 'Coiling Events';
info.posture.coils.shortName = 'Coils';
fields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
names = { ...
    'Coil Time', ...
    'Inter Coil Time', ...
    'Inter Coil Distance'};
shortNames = { ...
    'Time', ...
    'Inter Time', ...
    'Inter Distance'};
units = { ...
    'Seconds', ...
    'Seconds', ...
    'Microns'};
resolutions = { ...
    0.1, ...
    5, ...
    100};
for i = 1:length(fields)
    info.posture.coils.(fields{i}).resolution = resolutions{i};
    info.posture.coils.(fields{i}).isZeroBin = false;
    info.posture.coils.(fields{i}).isSigned = false;
    info.posture.coils.(fields{i}).name = names{i};
    info.posture.coils.(fields{i}).shortName = shortNames{i};
    info.posture.coils.(fields{i}).unit = units{i};
end
statFields = { ...
    'frequency', ...
    'timeRatio'};
statNames = { ...
    'Frequency', ...
    'Time Ratio'};
statUnits = { ...
    'Hz', ...
    'No Units'};
for i = 1:length(statFields)
    info.posture.coils.(statFields{i}).resolution = 0.001;
    info.posture.coils.(statFields{i}).isZeroBin = false;
    info.posture.coils.(statFields{i}).isSigned = false;
    info.posture.coils.(statFields{i}).name = ...
        [info.posture.coils.shortName ' ' statNames{i}];
    info.posture.coils.(statFields{i}).shortName = statNames{i};
    info.posture.coils.(statFields{i}).unit = statUnits{i};
end

% Organize the direction information.
info.posture.directions.name = 'Direction of Orientation';
info.posture.directions.shortName = 'Orientation';
fields = { ...
    'tail2head', ...
    'head', ...
    'tail'};
names = { ...
    'Tail-To-Head Orientation', ...
    'Head Orientation', ...
    'Tail Orientation'};
shortNames = { ...
    'Tail-To-Head', ...
    'Head', ...
    'Tail'};
for i = 1:length(fields)
    info.posture.directions.(fields{i}).resolution = 1;
    info.posture.directions.(fields{i}).isZeroBin = true;
    info.posture.directions.(fields{i}).isSigned = true;
    info.posture.directions.(fields{i}).name = names{i};
    info.posture.directions.(fields{i}).shortName = shortNames{i};
    info.posture.directions.(fields{i}).unit = 'Degrees';
end

% Organize the eigen projection information.
for i = 1:6
    info.posture.eigenProjection(i).resolution = 0.1;
    info.posture.eigenProjection(i).isZeroBin = true;
    info.posture.eigenProjection(i).isSigned = true;
    info.posture.eigenProjection(i).name = ['Eigen Projection ' num2str(i)];
    info.posture.eigenProjection(i).shortName = ['Projection ' num2str(i)];
    info.posture.eigenProjection(i).unit = 'No Units';
end

% Organize the skeleton information.
info.posture.skeleton.resolution = [];
info.posture.skeleton.isZeroBin = [];
info.posture.skeleton.isSigned = [];
info.posture.skeleton.name = 'Skeleton Location';
info.posture.skeleton.shortName = 'Skeleton';
info.posture.skeleton.unit = 'Microns';



%% Organize the worm locomotion display information.

% Organize the locomotion information.
info.locomotion.name = 'Locomotion Features';
info.locomotion.shortName = 'Locomotion';

% Organize the motion information.
info.locomotion.mode.resolution = [];
info.locomotion.mode.isZeroBin = [];
info.locomotion.mode.isSigned = [];
info.locomotion.mode.name = 'Motion';
info.locomotion.mode.shortName = 'Motion';
info.locomotion.mode.unit = 'No Units';

% Organize the forward/paused/backward information.
info.locomotion.motion.name = 'Motion';
info.locomotion.motion.shortName = 'Motion';
fields = { ...
    'Forward', ...
    'Backward', ...
    'Paused'};
subFields = { ...
    'time', ...
    'distance', ...
    'interTime', ...
    'interDistance'};
prefix = { ...
    '', ...
    '', ...
    'Inter ', ...
    'Inter '};
suffix = { ...
    'Time', ...
    'Distance', ...
    'Time', ...
    'Distance'};
units = { ...
    'Seconds', ...
    'Microns', ...
    'Seconds', ...
    'Microns'};
resolutions = { ...
    0.5, ...
    10, ...
    5, ...
    100};
for i = 1:length(fields)
    
    % Organize the motion information.
    field = lower(fields{i});
    info.locomotion.motion.(field).name = ...
        [fields{i} ' ' info.locomotion.motion.name];
    info.locomotion.motion.(field).shortName = fields{i};
    
    % Organize the motion event information.
    for j = 1:length(subFields)
        info.locomotion.motion.(field).(subFields{j}).resolution = ...
            resolutions{j};
        info.locomotion.motion.(field).(subFields{j}).isZeroBin = false;
        info.locomotion.motion.(field).(subFields{j}).isSigned = false;
        info.locomotion.motion.(field).(subFields{j}).name = ...
            [prefix{j} fields{i} ' ' suffix{j}];
        info.locomotion.motion.(field).(subFields{j}).shortName = ...
            [prefix{j} suffix{j}];
        info.locomotion.motion.(field).(subFields{j}).unit = units{j};
    end
end
statFields = { ...
    'frequency', ...
    'ratio.time', ...
    'ratio.distance'};
statNames = { ...
    'Frequency', ...
    'Time Ratio', ...
    'Distance Ratio'};
statUnits = { ...
    'Hz', ...
    'No Units', ...
    'No Units'};
for i = 1:length(fields)
    field = ['locomotion.motion.' lower(fields{i})];
    for j = 1:length(statFields)
        statField = [field '.' statFields{j}];
        info = setStructField(info, [statField '.resolution'], 0.001);
        info = setStructField(info, [statField '.isZeroBin'], false);
        info = setStructField(info, [statField '.isSigned'], false);
        info = setStructField(info, [statField '.name'], [fields{i} ' ' ...
            info.locomotion.motion.shortName ' ' statNames{j}]);
        info = setStructField(info, [statField '.shortName'], statNames{j});
        info = setStructField(info, [statField '.unit'], statUnits{j});
    end
end

% Organize the speed and direction information.
info.locomotion.velocity.name = 'Velocity';
info.locomotion.velocity.shortName = 'Velocity';
fields = { ...
    'headTip', ...
    'head', ...
    'midbody', ...
    'tail', ...
    'tailTip'};
shortNames = { ...
    'Head Tip', ...
    'Head', ...
    'Midbody', ...
    'Tail', ...
    'Tail Tip'};
for i = 1:length(fields)

    % Organize the velocity information.
    info.locomotion.velocity.(fields{i}).name = ...
        [shortNames{i} ' ' info.locomotion.velocity.name];
    info.locomotion.velocity.(fields{i}).shortName = shortNames{i};
    
    % Organize the speed information.
    info.locomotion.velocity.(fields{i}).speed.resolution = 1;
    info.locomotion.velocity.(fields{i}).speed.isZeroBin = true;
    info.locomotion.velocity.(fields{i}).speed.isSigned = true;
    info.locomotion.velocity.(fields{i}).speed.name = ...
        [shortNames{i} ' Speed (+/- = Forward/Backward)'];
    info.locomotion.velocity.(fields{i}).speed.shortName = shortNames{i};
    info.locomotion.velocity.(fields{i}).speed.unit = 'Microns/Seconds';

    % Organize the direction information.
    info.locomotion.velocity.(fields{i}).direction.resolution = 0.01;
    info.locomotion.velocity.(fields{i}).direction.isZeroBin = true;
    info.locomotion.velocity.(fields{i}).direction.isSigned = true;
    info.locomotion.velocity.(fields{i}).direction.name = ...
        [shortNames{i} ' Motion Direction (+/- = Toward D/V)'];
    info.locomotion.velocity.(fields{i}).direction.shortName = shortNames{i};
    info.locomotion.velocity.(fields{i}).direction.unit = 'Degrees/Seconds';
end

% Organize the bend information.
info.locomotion.bends.name = 'Crawling Motion';
info.locomotion.bends.shortName = 'Crawling';
fields = { ...
    'Head', ...
    'Midbody', ...
    'Tail'};
for i = 1:length(fields)
    
    % Organize the bend information.
    field = lower(fields{i});
    info.locomotion.bends.(field).name = ...
        [fields{i} ' ' info.locomotion.bends.name];
    info.locomotion.bends.(field).shortName = ...
        [fields{i} ' ' info.locomotion.bends.shortName];
    
    % Organize the bend amplitude information.
    info.locomotion.bends.(field).amplitude.resolution = 1;
    info.locomotion.bends.(field).amplitude.isZeroBin = true;
    info.locomotion.bends.(field).amplitude.isSigned = true;
    info.locomotion.bends.(field).amplitude.name = ...
        [fields{i} ' Crawling Amplitude (+/- = D/V Inside)'];
    info.locomotion.bends.(field).amplitude.shortName = fields{i};
    info.locomotion.bends.(field).amplitude.unit = 'Degrees';
    
    % Organize the bend frequency information.
    info.locomotion.bends.(field).frequency.resolution = 0.1;
    info.locomotion.bends.(field).frequency.isZeroBin = true;
    info.locomotion.bends.(field).frequency.isSigned = true;
    info.locomotion.bends.(field).frequency.name = ...
        [fields{i} ' Crawling Frequency (+/- = D/V Inside)'];
    info.locomotion.bends.(field).frequency.shortName = fields{i};
    info.locomotion.bends.(field).frequency.unit = 'Hz';
end

% Organize the foraging information.
info.locomotion.bends.foraging.name = 'Foraging (+/- = Toward D/V)';
info.locomotion.bends.foraging.shortName = 'Foraging';
info.locomotion.bends.foraging.amplitude.resolution = 1;
info.locomotion.bends.foraging.amplitude.isZeroBin = true;
info.locomotion.bends.foraging.amplitude.isSigned = true;
info.locomotion.bends.foraging.amplitude.name = ...
    'Foraging Amplitude (+/- = Toward D/V)';
info.locomotion.bends.foraging.amplitude.shortName = 'Amplitude';
info.locomotion.bends.foraging.amplitude.unit = 'Microns';
info.locomotion.bends.foraging.angleSpeed.resolution = 10;
info.locomotion.bends.foraging.angleSpeed.isZeroBin = true;
info.locomotion.bends.foraging.angleSpeed.isSigned = true;
info.locomotion.bends.foraging.angleSpeed.name = ...
    'Foraging Speed (+/- = Toward D/V)';
info.locomotion.bends.foraging.angleSpeed.shortName = 'Speed';
info.locomotion.bends.foraging.angleSpeed.unit = 'Degrees/Seconds';

% Organize the omega turn information.
info.locomotion.turns.omegas.name = 'Omega Turn Events';
info.locomotion.turns.omegas.shortName = 'Omega Turns';
fields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
names = { ...
    'Omega Turn Time (+/- = D/V Inside)', ...
    'Inter Omega Time (+/- = Previous D/V)', ...
    'Inter Omega Distance (+/- = Previous D/V)'};
shortNames = { ...
    'Time', ...
    'Inter Time', ...
    'Inter Distance'};
units = { ...
    'Seconds', ...
    'Seconds', ...
    'Microns'};
resolutions = { ...
    0.1, ...
    5, ...
    100};
isSigned = { ...
    true, ...
    true, ...
    true};
for i = 1:length(fields)
    info.locomotion.turns.omegas.(fields{i}).resolution = resolutions{i};
    info.locomotion.turns.omegas.(fields{i}).isZeroBin = false;
    info.locomotion.turns.omegas.(fields{i}).isSigned = isSigned{i};
    info.locomotion.turns.omegas.(fields{i}).name = names{i};
    info.locomotion.turns.omegas.(fields{i}).shortName = shortNames{i};
    info.locomotion.turns.omegas.(fields{i}).unit = units{i};
end
statFields = { ...
    'frequency', ...
    'timeRatio'};
statNames = { ...
    'Frequency', ...
    'Time Ratio'};
statUnits = { ...
    'Hz', ...
    'No Units'};
for i = 1:length(statFields)
    info.locomotion.turns.omegas.(statFields{i}).resolution = 0.001;
    info.locomotion.turns.omegas.(statFields{i}).isZeroBin = false;
    info.locomotion.turns.omegas.(statFields{i}).isSigned = false;
    info.locomotion.turns.omegas.(statFields{i}).name = ...
        [info.locomotion.turns.omegas.shortName ' ' statNames{i}];
    info.locomotion.turns.omegas.(statFields{i}).shortName = statNames{i};
    info.locomotion.turns.omegas.(statFields{i}).unit = statUnits{i};
end

% Organize the upsilon turn information.
info.locomotion.turns.upsilons.name = 'Upsilon Turn Events';
info.locomotion.turns.upsilons.shortName = 'Upsilon Turns';
fields = { ...
    'time', ...
    'interTime', ...
    'interDistance'};
names = { ...
    'Upsilon Turn Time (+/- = D/V Inside)', ...
    'Inter Upsilon Time (+/- = Previous D/V)', ...
    'Inter Upsilon Distance (+/- = Previous D/V)'};
shortNames = { ...
    'Time', ...
    'Inter Time', ...
    'Inter Distance'};
units = { ...
    'Seconds', ...
    'Seconds', ...
    'Microns'};
resolutions = { ...
    0.1, ...
    5, ...
    100};
isSigned = { ...
    true, ...
    true, ...
    true};
for i = 1:length(fields)
    info.locomotion.turns.upsilons.(fields{i}).resolution = resolutions{i};
    info.locomotion.turns.upsilons.(fields{i}).isZeroBin = false;
    info.locomotion.turns.upsilons.(fields{i}).isSigned = isSigned{i};
    info.locomotion.turns.upsilons.(fields{i}).name = names{i};
    info.locomotion.turns.upsilons.(fields{i}).shortName = shortNames{i};
    info.locomotion.turns.upsilons.(fields{i}).unit = units{i};
end
statFields = { ...
    'frequency', ...
    'timeRatio'};
statNames = { ...
    'Frequency', ...
    'Time Ratio'};
statUnits = { ...
    'Hz', ...
    'No Units'};
for i = 1:length(statFields)
    info.locomotion.turns.upsilons.(statFields{i}).resolution = 0.001;
    info.locomotion.turns.upsilons.(statFields{i}).isZeroBin = false;
    info.locomotion.turns.upsilons.(statFields{i}).isSigned = false;
    info.locomotion.turns.upsilons.(statFields{i}).name = ...
        [info.locomotion.turns.upsilons.shortName ' ' statNames{i}];
    info.locomotion.turns.upsilons.(statFields{i}).shortName = statNames{i};
    info.locomotion.turns.upsilons.(statFields{i}).unit = statUnits{i};
end



%% Organize the worm path display information.

% Organize the path information.
info.path.name = 'Path Features';
info.path.shortName = 'Path';

% Organize the curvature information.
info.path.curvature.resolution = 0.005;
info.path.curvature.isZeroBin = true;
info.path.curvature.isSigned = true;
info.path.curvature.name = 'Path Curvature (+/- = D/V Inside)';
info.path.curvature.shortName = 'Curvature';
info.path.curvature.unit = 'Radians/Microns';

% Organize the range information.
info.path.range.resolution = 10;
info.path.range.isZeroBin = false;
info.path.range.isSigned = false;
info.path.range.name = 'Path Range';
info.path.range.shortName = 'Range';
info.path.range.unit = 'Microns';

% Organize the duration information.
info.path.duration.name = 'Path Dwelling';
info.path.duration.shortName = 'Dwelling';
fields = { ...
    'Worm', ...
    'Head', ...
    'Midbody', ...
    'Tail'};
resolutions = { ...
    1, ...
    0.5, ...
    1, ...
    0.5};
for i = 1:length(fields)
    field = lower(fields{i});
    info.path.duration.(field).resolution = resolutions{i};
    info.path.duration.(field).isZeroBin = false;
    info.path.duration.(field).isSigned = false;
    info.path.duration.(field).name = [fields{i} ' Dwelling'];
    info.path.duration.(field).shortName = fields{i};
    info.path.duration.(field).unit = 'Seconds';
end

% Organize the centroid information.
info.path.coordinates.resolution = [];
info.path.coordinates.isZeroBin = [];
info.path.coordinates.isSigned = [];
info.path.coordinates.name = 'Centroid Location';
info.path.coordinates.shortName = 'Centroid';
info.path.coordinates.unit = 'Microns';
end
