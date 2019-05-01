function [] = gcp_arc2qgis(file_in, h, r)
% Converts a GCP file in ArcGIS format to QGIS format
% Inputs: 
% - file_in: The full path to the file (or the filename if in the desired output folder)
% - h:   The height of the image (in pixels)
%     - Can be pulled from an image using the imagemagick command: identify -quiet -format "%h" <filename>
% - r: The resolution of the image (in ppi)
%     - Can be pulled from an image using the imagemagick command: identify -quiet -format "%y" <filename>
%
% NOTE that h and r are optional IF the following conditions are met: 
% - A file by the same name as the GCP file (and with a .tif, .tiff, or .jp2 extension) is in the same folder as the GCP file
% - ImageMagick is installed on the computer.
%
%%% More information on converting between qgis and arcgis gcp formats may be found at: https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/georeferencing-tools 
%
% Created by JJB in March, 2019.

%% Read the GCP file. Extract filename, path, and multiple extensions
[filepath,name,ext] = fileparts(file_in);
if ~isempty(filepath)==1
    cd(filepath);
else
    filepath = pwd;
end

exten2 =  strfind(name,'.');
if ~isempty(exten2)==1
   [~,name,ext2] = fileparts(name);
end

%% If h and r are not given, try to extract from image (assuming tif file is in the same directory and ImageMagick installed)
if nargin==1
    if exist([filepath '/' name '.tif'],'file')==2
        tifpath = [filepath '/' name '.tif'];
        tiffile = [name '.tif'];
    elseif exist([filepath '/' name '.tiff'],'file')==2
        tifpath = [filepath '/' name '.tiff'];
        tiffile = [name '.tiff'];
        
    elseif exist([filepath '/' name '.jp2'],'file')==2
        tifpath = [filepath '/' name '.jp2'];
        tiffile = [name '.jp2'];
    else
    end
        [status,h] = system(['identify -quiet -format "%h" "' tifpath '"']); % Image height in pixels
        [status2,r] = system(['identify -quiet -format "%y" "' tifpath '"']); % Image resolution in points per inch
        
    if status+status2 ==0    
        disp(['height and resolution values inferred from image ' tiffile ': h = ' h ', r = ' r]);
    else
        disp('height and resolution values not entered and unable to be inferred from image');
        return;
    end
    
end
%%% Convert h and r to numeric values
if ischar(h)==1
    h = str2double(h);
end
if ischar(r)==1
    r = str2double(r);
end

%% Read the Arc GCP file
gcp_fmt = '%f %f %f %f'; %input format for the QGIS GCP files

fid = fopen(file_in,'r');
% hdr = fgetl(fid); % get header row
C_tmp = textscan(fid,gcp_fmt,'delimiter','\t');
C = cell2mat(C_tmp); %convert from cell array into a matrix
fclose(fid);

%% Convert and write the file
 %Create the qgis .points file:
 fid_qgis = fopen([filepath '/' name ext '.points'],'w');
 fprintf(fid_qgis,'%s\n','mapX,mapY,pixelX,pixelY,enable');
 fclose(fid_qgis);
%%% Perform the conversion        
% C_ArcGIS = [C(:,3)./r (C(:,4)+h)/r C(:,1) C(:,2)];
C_QGIS = [C(:,3) C(:,4) C(:,1).*r (C(:,2).*r)-h ones(size(C,1),1)];
%%% Create the QGIS gcp file:
dlmwrite([filepath '/' name ext '.points'],C_QGIS,'delimiter',',','precision',14,'-append');
