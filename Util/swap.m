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

tmp = a;
a = b;
b = tmp;
end

