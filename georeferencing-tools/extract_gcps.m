function [] = extract_gcps(file_in,gdal_path)
% extract_gcps.m
% This function uses the gdalinfo command to extract GCP and WKT information from a georeferenced tiff that has an accompanying .aux.xml file. 
% inputs: 
% - file_in: path to the geotiff. If no path is provided (filename only), script assumes Matlab is in the directory containing the file.
% - gdal_path (optional): Allows user to specify the path to the gdal library (often necessary in Windows systems).
%
% Example inputs and usage:
% file_in = 'H:\Digitization_Projects\WWII_Topographic_Maps\LCMSDS\GeoTiff-test\WWIIMMEmden_1945v1_TIFF\WWIIMMEmden_1945v1_TIFF.tif';
% gdal_path = 'C:\Program Files\QGIS 3.6\bin';
% extract_gcps(file_in, gdal_path)
%
% Created 20190409 by JJB

if nargin ==1
    gdal_path = '';
elseif nargin==0 || nargin>2
    disp('incorrect number of arguments (1 or 2). exiting'); return;
end
gdal_path = strrep(gdal_path,'\','/'); % replace to linux-style slashes

%%% Format the gdalinfo command to accommodate a gdal_path (if provided)
if isempty(gdal_path)
    gdal_cmd = 'gdalinfo';
else
    if strcmp(gdal_path(end),'/')==1
        gdal_cmd = ['"' gdal_path 'gdalinfo"'];
    else
        gdal_cmd = ['"' gdal_path '/gdalinfo"'];
    end
end

% Pull out filename and path
[FILEPATH,NAME,EXT] = fileparts(file_in);

if isempty(FILEPATH) == 1
    FILEPATH = pwd;
end

%%% Use gdalinfo to read geotiff info into json; read json file into data structure
[status, result] = system([gdal_cmd ' -json ' file_in]);
data = jsondecode(result);

%%% If data.gcps exists, we can pull out:
% - the wkt (data.gcps.coordinateSystem.wkt)
% - the GCPS (data.gcps.gcpList)

if status==0 && isfield(data,'gcps')==1
    try
        %Reformat GCPs into QGIS format
        gcp_out = [[data.gcps.gcpList.x]' [data.gcps.gcpList.y]' [data.gcps.gcpList.pixel]' -1*([data.gcps.gcpList.line]') ones(size(data.gcps.gcpList,1),1)];
        
        %%% Save GCPs to as a QGIS-format GCP file
        fid_qgis = fopen([FILEPATH '/' NAME EXT '.points'],'w');
        fprintf(fid_qgis,'%s\n','mapX,mapY,pixelX,pixelY,enable');
        fclose(fid_qgis);
              
        dlmwrite([FILEPATH '/' NAME EXT '.points'],gcp_out,'delimiter',',','precision',14,'-append');
        
        %%% Write the wkt info for the CRS to a new file:
        fid = fopen([FILEPATH '/' NAME '.wkt'],'w');
        fprintf(fid,'%s',data.gcps.coordinateSystem.wkt);
        fclose(fid);
    catch
        disp('Found GCP information but something went wrong.');
    end
else
    disp(['Could not find gcp information in file. Ensure you''ve entered the tif file and that the .aux.xml file is in the same folder (if it exists). No output created.']);
    disp(['Error text: ' result]);
end