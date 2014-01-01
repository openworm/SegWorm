function [a b] = swap(a, b)
%SWAP Swap two values.
%
%   [A B] = SWAP(A, B)
%
%   Inputs:
%       Ttwo values to swap.
%
%   Outputs:
%       The swapped values.
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

tmp = a;
a = b;
b = tmp;
end

