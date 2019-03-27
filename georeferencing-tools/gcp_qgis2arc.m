function [] = gcp_qgis2arc(file_in, h, ppi)
% Converts a GCP file in QGIS format to ArcGIS format
% Inputs: 
% - file_in: The full path to the file (or the filename if in the desired output folder)
% - h:   The height of the image (in pixels)
%     - Can be pulled from an image using the imagemagick command: identify -quiet -format "%h" <filename>
% - ppi: The resolution of the image (in ppi)
%     - Can be pulled from an image using the imagemagick command: identify -quiet -format "%y" <filename>
%
%%% Information on converting between qgis and arcgis gcp formats: 

file_in = 'D:\Dropbox (MUL)\Public\Tiffs&GCPs\March2019\HTDP63360K030M05_1909.tif.points';
% Read the GCP file:
[filepath,name,ext] = fileparts(file_in);
if ~isempty(filepath)==1
    cd(filepath);
end

exten2 =  strfind(name,'.');
if ~isempty(exten2)==1
   [~,name,ext2] = fileparts(name);
end

gcp_fmt = '%f %f %f %f %f'; %input format for the QGIS GCP files

fid = fopen(file_in,'r');
hdr = fgetl(fid); % get header row
C_tmp = textscan(fid,gcp_fmt,'delimiter',',');
C = cell2mat(C_tmp); %convert from cell array into a matrix
fclose(fid)
        
%%% Create the ArcGIS gcp file:




%%% Perform the conversion        
        
fid_qgis = fopen([qgis_gcp_path filename_in '.points'],'w');
        fprintf(fid_qgis,'%s\n','mapX,mapY,pixelX,pixelY,enable');
        fclose(fid_qgis);
        
        
        
%%% Code to pull information from images using imageMagick
% cmd = ['identify -quiet -format "%h" ' pwd '/' name '.tif];
% cmd2 = ['identify -quiet -format "%y" ' file_in];
% %%% Note to self, need to add a query for resolution identify -quiet -format "%y"
% if ispc==1; [status,cmdout] = dos(cmd); else [status,cmdout] = unix(cmd);end
% h = str2double(cmdout); %height of the tif in pixels
% if ispc==1; [status2,cmdout2] = dos(cmd2); else [status2,cmdout2] = unix(cmd2);end
% ppi_in = str2double(cmdout2); %resolution of the tif (in points per inch)