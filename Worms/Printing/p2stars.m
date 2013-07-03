function stars = p2stars(p)
%P2STARS Convert a p-value to a string of stars representing significance.
%
%   STARS = P2STARS(P)
%
%   Input:
%       p - the p-value
%
%   Output:
%       stars - a string representing the p-value significance

% The p-value is not significant.
stars = 'n.s.';

% Determine the significance of the p-value.
if p <= 0.0001
    stars = '****';
elseif p <= 0.001
    stars = '***';
elseif p <= 0.01
    stars = '**';
elseif p <= 0.05
    stars = '*';
end
end
