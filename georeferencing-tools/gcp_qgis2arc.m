function [] = gcp_qgis2arc(file_in, h, r)
% Converts a GCP file in QGIS format to ArcGIS format
% Inputs: 
% - file_in: The full path to the file (or the filename if in the desired output folder)
% - h:   The height of the image (in pixels)
%     - Can be pulled from an image using the imagemagick command: identify -quiet -format "%h" <filename>
% - r: The resolution of the image (in ppi)
%     - Can be pulled from an image using the imagemagick command: identify -quiet -format "%y" <filename>
%
%%% Information on converting between qgis and arcgis gcp formats: 

% file_in = 'D:\Dropbox (MUL)\Public\Tiffs&GCPs\March2019\HTDP63360K030M05_1909.tif.points';
% Read the GCP file:
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

% If h and r are not given, try to extract from image (assuming tif file is in the same directory and ImageMagick installed)
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
        [status,h] = system(['identify -quiet -format "%h" "' filepath '/' name ext2 '"']); % Image height in pixels
        [status2,r] = system(['identify -quiet -format "%y" "' filepath '/' name ext2 '"']); % Image resolution in points per inch
        
    if status+status2 ==0    
        disp(['height and resolution values inferred from image ' tiffile ': h = ' h ', r = ' r]);
    else
        disp('height and resolution values not entered and unable to be inferred from image');
        return;
    end
    
end

if ischar(h)==1
    h = str2double(h);
end
if ischar(r)==1
    r = str2double(r);
end

gcp_fmt = '%f %f %f %f %f'; %input format for the QGIS GCP files

fid = fopen(file_in,'r');
hdr = fgetl(fid); % get header row
C_tmp = textscan(fid,gcp_fmt,'delimiter',',');
C = cell2mat(C_tmp); %convert from cell array into a matrix
fclose(fid)
        
%%% Perform the conversion        
C_ArcGIS = [C(:,3)./r (C(:,4)+h)/r C(:,1) C(:,2)];

%%% Create the ArcGIS gcp file:
dlmwrite([filepath '/' name '.txt'],C_ArcGIS,'delimiter','\t','precision',14);

        
        
        
%%% Code to pull information from images using imageMagick
% [status,h] = system(['identify -quiet -format "%h" "' filepath '/' name ext2 '"']); % Image height in pixels
% [status2,r] = system(['identify -quiet -format "%y" "' filepath '/' name ext2 '"']); % Image resolution in points per inch
% cmd = ['identify -quiet -format "%h" ' pwd '/' name '.tif];
% cmd2 = ['identify -quiet -format "%y" ' file_in];
% %%% Note to self, need to add a query for resolution identify -quiet -format "%y"
% if ispc==1; [status,cmdout] = dos(cmd); else [status,cmdout] = unix(cmd);end
% h = str2double(cmdout); %height of the tif in pixels
% if ispc==1; [status2,cmdout2] = dos(cmd2); else [status2,cmdout2] = unix(cmd2);end
% ppi_in = str2double(cmdout2); %resolution of the tif (in points per inch)