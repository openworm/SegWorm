function info = experimentDisplayInfo()
%EXPERIMENTDISPLAYINFO Get information for displaying the experiment data.
%
%   INFO = EXPERIMENTDISPLAYINFO()
%
%   Output:
%       info - information for displaying the experiment data; a structure
%              mirroring the experiment data, where each data value has the
%              following subfield:
%
%              name = a descriptive name
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.



%% Organize the experiment information.

% Organize the worm information.
info.experiment.worm.strain.name = 'Worm (Strain)';
info.experiment.worm.genotype.name = 'Worm (Genotype)';
info.experiment.worm.gene.name = 'Worm Genotype (Genes)';
info.experiment.worm.allele.name = 'Worm Genotype (Alleles)';
info.experiment.worm.chromosome.name = 'Worm Genotype (Chromosomes)';
info.experiment.worm.sex.name = 'Worm (Sex Chromosomes)';
info.experiment.worm.age.name = 'Worm (Age)';
info.experiment.worm.habituation.name =  'Worm (Habituation Time)';
info.experiment.worm.ventralSide.name = ...
    'Worm (Ventral Side, Orientation From Head)';
info.experiment.worm.agarSide.name =  ...
    'Worm (Agar/Surface Touching Side)';
info.experiment.worm.annotations.name = 'Worm (Annotations)';

% Organize the environment information.
info.experiment.environment.timestamp.name = 'Environment (Start Time)';
info.experiment.environment.food.name = 'Environment (Food)';
info.experiment.environment.illumination.name = ...
    'Environment (Illumination)';
info.experiment.environment.temperature.name = ...
    'Environment (Temperatures)';
info.experiment.environment.chemicals.name = 'Environment (Chemicals)';
info.experiment.environment.arena.name = 'Environment (Arena)';
info.experiment.environment.tracker.name = 'Environment (Tracker)';
info.experiment.environment.annotations.name = 'Environment (Annotations)';



%% Organize the video information.

% Organize the video length information.
info.video.length.frames.name = 'Video Length (Frames)';
info.video.length.time.name = 'Video Length (Seconds)';

% Organize the video resolution information.
info.video.resolution.fps.name = ...
    'Video Temporal Resolution (Frames/Second)';
info.video.resolution.height.name = 'Video Height (Pixels)';
info.video.resolution.width.name = 'Video Width (Pixels)';
info.video.resolution.micronsPerPixels.x.name = ...
    'Video Spatial Resolution (X-Axis Microns/Pixels)';
info.video.resolution.micronsPerPixels.y.name = ...
    'Video Spatial Resolution (Y-Axis Microns/Pixels)';
info.video.resolution.fourcc.name = 'Video Codec (FourCC)';

% Organize the video annotation information.
info.video.annotations.frames.name = ...
    'Video Frame Annotations (IDs -- See The Reference)';
info.video.annotations.reference.id.name = ...
    'Video Frame Annotation Reference (ID)';
info.video.annotations.reference.function.name = ...
    'Video Frame Annotation Reference (Function Of Origin)';
info.video.annotations.reference.message.name = ...
    'Video Frame Annotation Reference (Description)';



%% Organize the file information.

% Organize the file information.
info.files.video.name = 'Video File (Path)';
info.files.vignette.name = 'Vignette File (Path)';
info.files.info.name = 'Information File (Path)';
info.files.stage.name = 'Stage Movement File (Path)';
info.files.directory.name = 'Experiment Directory (Path)';
info.files.computer.name = 'Experiment Computer (Name/IP)';



%% Organize the worm tracker information.

% Organize the Worm Tracker 2.0 information.
info.wt2.tracker.name = 'Tracker (Version)';
info.wt2.hardware.name = 'Hardware (Version)';
info.wt2.analysis.name = 'Analysis (Version)';
info.wt2.annotations.name = 'WT2 Hardware/Software (Annotations)';



%% Organize the lab information.

% Organize the lab information.
info.lab.experimenter.name = 'Lab (Experimenter)';
info.lab.name.name = 'Lab (Name)';
info.lab.address.name = 'Lab (Address)';
info.lab.annotations.name = 'Lab (Annotations)';
end
