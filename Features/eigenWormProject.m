function [projectedAmps, isInterpolated] = eigenWormProject(eigenWorms, angleArray, numEigWorms, interpNaN)

%EIGENWORMPROJECT Project a series of skeleton angles onto the given
%                 eigenworms
%
%   [PROJECTEDAMPS ISINTERPOLATED] = EIGENWORMPROJECT(EIGENWORMS, ANGLEARRAY, NUMEIGWORMS, INTERPNAN)
%
%   Input:
%       eigenWorms    - the basis eigenWorms that the skeleton angles will
%                       be projected onto. Must be produced from skeletons
%                       of the same length as those used for angleArray.
%       angleArray    - a numFrames by numSkelPoints - 1 array of skeleton
%                       tangent angles that have been rotated to have a mean
%                       angle of zero.
%       numEigWorms   - the number of eigenworms to use in the projection.
%                       We simply take the first numEigWorms dimensions from
%                       eigenWorms and project onto those.
%       interpNaN     - Logical. Should missing data (e.g. stage motions, coiled
%                       shapes, dropped frames) be interpolated over?
%
%   Output:
%       projectedAmps - a numEigWorms dimensional time series of length
%                       numFrames containing the projected amplitudes for
%                       each eigenworm in each frame of the video
%       isInterpolated - a vector with length equal to the number of frames
%                        indicating whether the given value was
%                        interpolated (1) or not (0).
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% check for empty or all-NaN input data and a request for interpolation.
% If interpNaN is 0 then result will be all NaNs and no error is necessary.
if isempty(~isnan(angleArray)) && interpNaN == 1
    error('angleArray contains only NaN values so there is nothing to interpolate.')
end

projectedAmps = NaN(size(angleArray, 1), numEigWorms);
isInterpolated = zeros(size(angleArray, 1), 1);

%Calculate time series of projections onto eigenworms
%for each frame
for i = 1:size(angleArray, 1)
    rawAngles = angleArray(i,:);
    
    %for each eigenworm
    for j = 1:numEigWorms
        projectedAmps(i,j) = sum(eigenWorms(j,:).*rawAngles);
    end
end

if interpNaN
    %interpolate over NaNs in projectedAmps
    projectedAmpsNoNaN = projectedAmps;
    %interpolate over NaN values.  'extrap' is necessary in case the
    %first values are NaN which happens occasionally
    for j = 1:numEigWorms
        pAmp = projectedAmps(:,j);
        pAmp(isnan(pAmp)) = interp1(find(~isnan(pAmp)),...
            pAmp(~isnan(pAmp)), find(isnan(pAmp)),'linear', 'extrap');
        projectedAmpsNoNaN(:,j) = pAmp;
    end
    %if any of the projected amplitudes is NaN at a given frame, they all
    %should be, so simply set interpolated flag based on first eigenworm.
    isInterpolated = isnan(projectedAmps(:,1));
    
    %now set projectedAmps to the interpolated values with no NaNs
    projectedAmps = projectedAmpsNoNaN;
end