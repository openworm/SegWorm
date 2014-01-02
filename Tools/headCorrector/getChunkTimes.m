function [ chunktimes ] = getChunkTimes( handle )
%chunktimes returns a function giving the time at which each chunk of
%an experiment begins
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

mydata=guidata(handle);

%clear existing data
if isfield(mydata, 'chunktimes')
    mydata=rmfield(mydata, 'chunktimes');
end

if isfield(mydata, 'reliabilities');
    mydata=rmfield(mydata, 'reliabilities');
end



if mydata.useDB == 0
    
    
    if mydata.chunkReady == 1 %check relevant paths were provided

    %load the chunk data from .mat files
    load(mydata.segNormInfoPath);
    
    %initialize for speed
    numChunks = length(hAndtData);
    mydata.chunktimes = zeros(numChunks, 1);
    mydata.reliabilities = zeros(numChunks, 1);
    
    
    %save start frame and reliabilities for each chunk
    for c=1:numChunks
        mydata.chunktimes(c) = hAndtData{c}.globalStartFrame;
        
        if ~isempty(hAndtData{c}.reliability)
            mydata.reliabilities(c) = hAndtData{c}.reliability;
        end
        
    end
    
    end
    
else
    
    %first, connect to the database    
    %try
    
    %find the start times
    query = ['SELECT start, reliability FROM main.wormmorphology WHERE experiment_id = ' num2str(mydata.experiment_id) ' ORDER BY start'];
    curs = exec(mydata.conn, query);
    setdbprefs('DataReturnFormat','numeric');
    curs = fetch(curs, 100);
    
    if ~strcmp(curs.data(1), 'No Data')
        mydata.chunktimes=curs.data(:, 1);
        mydata.reliabilities=curs.data(:, 2);
        %reliabilities = reliabilities ./ max(reliabilities); %normalise to 0-1 scale
    end
    %catch
    %   startTimes = '0';
    %end
end


%save the results
%mydata=guidata(handle);
%mydata.chunktimes = chunktimes;
%mydata.reliabilities = reliabilities;
guidata(handle,mydata);


end