fid = fopen('D:\Local\DigitalArchive-BulkDownload\to_download.csv');

eof = feof(fid);

while eof==0
    tline = fgets(fid);
    commas = strfind(tline,',');
    if numel(commas)==1
        commas(2)= length(tline)+1;
    end
    macrepo = tline(1:commas(1)-1);
    url = tline(commas(1)+1:commas(2)-1);
    %     download the JPEG2000
    try
        websave(['D:\Local\DigitalArchive-BulkDownload\macrepo' macrepo '.jp2'],url);
    catch
    end
    % Try to download the thumbnail JPEG:
    tn_url = ['http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' macrepo '/datastream/TN/view'];
    try
        websave(['D:\Local\DigitalArchive-BulkDownload\macrepo' macrepo '_TN.jpeg'],tn_url);
    catch
    end
end
fclose(fid)
