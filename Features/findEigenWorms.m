function [eigenWorms, eigenVals] = findEigenWorms(angleArray, numEigWorms, verbose)

%FINDEIGENWORMS Find the eigenvectors of the angleArray covariance matrix
%
%   [EIGENWORMS, EIGENVALS] = FINDEIGENWORMS(ANGLEARRAY, NUMEIGWORMS, VERBOSE)
%
%   Input:
%       angleArray  - a numFrames by numSkelPoints - 1 array of skeleton
%                     tangent angles that have been rotated to have a mean
%                     angle of zero.  For best result, this angle array
%                     should probably be taken from a couple of hours of
%                     tracking data.  Several 15 minute angleArrays can be
%                     concatenated.
%       numEigWorms - the number of eigenworms to use in the projection.
%                     We simply take the first numEigWorms dimensions from
%                     eigenWorms and project onto those.
%       verbose     - flag indicating whether plots should be generated.
%
%   Output:
%       eigenWorms  - a matrix with the eigenvectors of the covariance
%                     matrix of angleArray ranked according to the amount
%                     variance they account for (most variance is first)
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% check for all-NaN input data
if isempty(~isnan(angleArray))
    error('angleArray contains only NaN values.')
end

% only use non-NaN frames for calculating the covariance matrix
covarianceMat = cov(angleArray(~isnan(angleArray(:,1)),:),1);

% get the eigenvectors and eigenvalues of the covariance matrix
[M, eVals] = eig(covarianceMat);

% sort the eigenvalues
eVals = sort(diag(eVals),'descend');

% keep the numEigWorms dimensions that capture most of the variance
eigenWorms = M(:, end:-1:end - numEigWorms)';
eigenVals = eVals(1:numEigWorms);

if verbose
    % plot eigenvalues to show fraction of variance captured
    figure
    plot(cumsum(eVals/sum(eVals)),'o','markeredgecolor',[1 0.5 0.1],...
        'markerfacecolor', [1 0.5 0.1],'markersize',8)
    %adjust font and font size
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);

    % plot the eigenworms
    figure
    for i = 1:numEigWorms
        subplot(ceil(numEigWorms/2),2,i)
        plot(eigenWorms(i,:), 'Color', [1 0.5 0.1], 'LineWidth', 2)
        xlim([0 size(eigenWorms, 2) + 1])
        %adjust font and font size
        set(gca, 'FontName', 'Helvetica', 'FontSize', 13);
    end
    
    % plot the covariance matrix
    figure
    imagesc(covarianceMat)
    set(gca,'YDir','normal')
    %adjust font and font size
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
end