
function m = clockmod(n,k)
% clockmod - clock style mod arithmetic, mod(n,k) when that is non-zero, but k when it would be zero otherwise
% usage: m = clockmod(n,k)
%
% arguments: (input)
% n,k - standard arguments to mod(n,k)
%
% m - array of the same size and shape that
% mod(n,k) would generate, but when that
% result would have been zero, it contains k.
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
% just the mod, most of the time
m = mod(n,k);

% but when that result would be zero, return k instead.
ind = (m == 0);
if any(ind(:))
  if numel(k) == 1
    m(ind) = k;
  else
    m(ind) = k(ind);
  end
end 
