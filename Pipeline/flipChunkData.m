function chunkData = flipChunkData(chunkData)

% FLIPCHUNKDATA this function will flip chunk data if it is detected that
% head in fact should be tail. 
%
% Input:
%        chunkData - original chunk data structure
%
% Output: 
%        chunkDataFlipped - chunk data where the statistics for head are
%        now the statistics for tail
%
% 
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% The confidences should switch places too

    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hColourSum', 'tColourSum');
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'vColourSum', 'nvColourSum');
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'proximitySum', 'flipProximitySum');
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hOrthoSum', 'tOrthoSum');
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hParaAbsSum', 'tParaAbsSum');
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hParaNASum', 'tParaNASum');
    
	chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hOrthoParaRatio', 'tOrthoParaRatio');
    
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hCDFsum', 'tCDFsum');
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hStdevSum', 'tStdevSum');
    chunkData.statsHT = flipDataStrucure(chunkData.statsHT, 'hOrthoParaRatio', 'tOrthoParaRatio');
    
    
    zeroFlag = false(1,length(chunkData.statsHT.cdfRatioSum));
    % lets check if we didnt divide anything by 0
    if sum(chunkData.statsHT.cdfRatioSum == 0) > 0
        zeroFlag = (chunkData.statsHT.cdfRatioSum == 0);
    end
    chunkData.statsHT.cdfRatioSum = 1./chunkData.statsHT.cdfRatioSum;
    chunkData.statsHT.cdfRatioSum(zeroFlag) = 0;
    
    zeroFlag = false(1,length(chunkData.statsHT.stdevRatioSum));
    % lets check if we didnt divide anything by 0
    if sum(chunkData.statsHT.stdevRatioSum == 0) > 0
        zeroFlag = (chunkData.statsHT.stdevRatioSum == 0);
    end
	chunkData.statsHT.stdevRatioSum = 1/chunkData.statsHT.stdevRatioSum;
    chunkData.statsHT.stdevRatioSum(zeroFlag) = 0;
    
    function dataStruct = flipDataStrucure(dataStruct, field1, field2)
        tmp = dataStruct.(field1);
        dataStruct.(field1) = dataStruct.(field2);
        dataStruct.(field2) = tmp;    
    end
end