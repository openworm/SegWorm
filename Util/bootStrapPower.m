function betas = bootStrapPower(func, data, offsets, Ns, varargin)
%BOOTSTRAPPOWER Computer the power of a statistical test using a bootstrap.
%
%   BETAS = BOOTSTRAPPOWER(FUNC, DATA, OFFSETS, NS, VARARGIN)
%
%   Inputs:
%       func      - the function to compute significance
%                   p = func(group1, group2)
%       data      - the data (all drawn from the same distribution)
%       offsets   - the data offsets to discriminate (the mean shift)
%       Ns        - the first group sample sizes
%       N2s       - the second group sample sizes (if unequal group sizes)
%                   if empty, Ns is used
%       alphas    - the alphas to use
%       numTests  - the number of tests to perform (min(beta) = 1/numTests)
%       isVerbose - verbose mode displays the progress
%
%   Output:
%       betas    - the betas as offsets x Ns x alphas
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.


% Determine the second group sample sizes to use (if unequal group sizes).
N2s = Ns;
if ~isempty(varargin) && ~isempty(varargin{1})
    N2s = varargin{1};
end

% Determine the significance.
alphas = 0.05;
if length(varargin) > 1
    alphas = varargin{2};
end

% How many boostraps are we performing?
numTests = 10000;
if length(varargin) > 2
    numTests = varargin{3};
end

% Are we displaying the progress?
isVerbose = true;
if length(varargin) > 3
    isVerbose = varargin{4};
end

% Compute the betas.
minBeta = 1 / numTests;
betas = zeros(length(offsets), length(Ns), length(alphas));
for i = 1:length(offsets)
    
    % Display the progress.
    if isVerbose
        if i > 1
            toc;
        end
        disp(['Computing offset ' num2str(i) '/' ...
            num2str(length(offsets)) ' ...']);
        if i < length(offsets)
            tic;
        end
    end
    
    % Compute the betas.
    for j = 1:length(Ns)
        for k = 1:length(alphas)
            for l = 1:numTests
                
                % Compute the significance.
                group1 = data(randi(length(data), [Ns(j) 1]));
                group2 = data(randi(length(data), [N2s(j) 1])) + offsets(i);
                p = func(group1, group2);
                
                % Sum the false positives.
                %betas(i) = betas(i) + single(p <= alpha);
                if p > alphas(k)
                    betas(i,j,k) = betas(i,j,k) + 1;
                end
            end
            
            % Compute the beta.
            betas(i,j,k) = betas(i,j,k) / numTests;
            if betas(i,j,k) < minBeta
                betas(i,j,k) = minBeta;
            end
        end
    end
end
end
