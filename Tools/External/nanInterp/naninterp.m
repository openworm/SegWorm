function X = naninterp(X)
% Interpolate over NaNs
X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)), 'cubic');
return 