function path=downloadVideo(experiment_id, videoDir)
%getNextVideo downloads the video with a specific id
%returns the path to downloaded video
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
%first, connect to the database

error('database details missing')
conn = database;

mydata.conn = conn;

try
    
    %find the path to the video on the NAS
    query = strcat('SELECT * FROM locationnas WHERE id=', num2str(experiment_id))
    curs = exec(conn, query);
    setdbprefs('DataReturnFormat','cellarray');
    curs = fetch(curs, 1);
    
    if strcmp(curs.data(1), 'No Data')
        msgbox(['Could not find path to video ' num2str(experiment_id) ' on NAS']);
        path = '';
    else
        avipath=curs.data{1,3}
        
        %try to download the video
        location = strrep(avipath, '//nas207-1/data', '/Volumes/data')
        system(['cp "' location '" ' videoDir]);
        
        %export the path it was saved to
        [pathstr, name, ext] = fileparts(location);
        path = [videoDir name ext]
    end
    
catch
    path = '';
end

end