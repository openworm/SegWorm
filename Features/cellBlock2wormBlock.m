function wormBlock = cellBlock2wormBlock(cellBlock)
%CELLBLOCK2WORMBLOCK Convert a array of cell arrays to an array of worm structs.
%
%   WORMBLOCK = CELLBLOCK2WORMBLOCK(WORMBLOCK)
%
%   Input:
%       cellBlock - an array of worm information organized in a cell array
%
%   Output:
%       wormBlock - an array of worm information organized in a structure
%                   read more in cell2block
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

blockSize = length(cellBlock);
wormBlock{blockSize}=[];

for i=1:blockSize
    if iscell(cellBlock{i})
        wormBlock{i} = cell2worm(cellBlock{i});
    end
end
