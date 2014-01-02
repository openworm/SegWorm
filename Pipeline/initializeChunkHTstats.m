function [statsHT] = initializeChunkHTstats()

% INITIALIZECHUNKHTSTATS this function will initialize all the variables
% that will be computed during the segmentation for head and tail detection
% which will be carried out later.
%
% Input: 
%
% Output:
%           statsHT - a struct with fields corresponding to different worm
%           statistics that will be used for head and tail detection
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

statsHT.hColourSum = 0;
statsHT.tColourSum = 0;
statsHT.vColourSum = 0;
statsHT.nvColourSum = 0;
statsHT.proximitySum = 0;
statsHT.flipProximitySum = 0;
statsHT.hOrthoSum = 0;
statsHT.tOrthoSum = 0;
statsHT.hParaAbsSum = 0;
statsHT.tParaAbsSum = 0;
statsHT.hParaNASum = 0;
statsHT.tParaNASum = 0;
statsHT.hOrthoParaRatio = 0;
statsHT.tOrthoParaRatio = 0;

statsHT.hOrthoVStOrthoRatio = 0;

% CDF
statsHT.hCDFsum  = zeros(1,5);
statsHT.tCDFsum  = zeros(1,5);
statsHT.cdfRatioSum = 0;

% STD
statsHT.hStdevSum = 0;
statsHT.tStdevSum = 0;
statsHT.stdevRatioSum = 0;

% Stage movement
statsHT.stageMovCount = 0;
statsHT.stageMovFrameNo = 0;

% OrientWormPostCoil
statsHT.orientWormPostCoil1 = 0;
statsHT.orientWormPostCoil2 = 0;
statsHT.orientWormPostCoil3 = 0;




