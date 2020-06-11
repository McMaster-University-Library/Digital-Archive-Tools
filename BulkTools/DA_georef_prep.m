% 
% Load the list of sheets ( List generated here:
% https://docs.google.com/spreadsheets/d/1G7VUOo7-7DDMI7Fj0FOrghMCAgbKQKDcXl8qWwv3TP4/edit#gid=0)
% Look for a match in /Ingested - if a match is found, move tif and mods
% file to /ToGeoref
% If not found, use the macrepo number to download the TIF and MODS file
% from the DA
% Convert each TIF into a JPEG (medium quality)
tif_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\GermanyHollandPoland_25k\Ingested\';
georef_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\GermanyHollandPoland_25k\ToGeoref\';
mods_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\GermanyHollandPoland_25k\MODS\';
fid = fopen([georef_dir 'UofA Georef Prep - List.csv']);
fmt = repmat('%s',1,2); %create the format string for reading:

%%% Load the file using textscan. Reform it until it's in a first-level
%%% cell structure
tmp = textscan(fid,fmt,'Delimiter',',','TreatAsEmpty',{'NA','NaN'});
C = {};
header = {};
%%% Fix a problem with Google Sheet export where the final column has one
%%% less element in it than the others.
if length(tmp{1,1}) - length(tmp{1,end}) == 1
    tmp{1,end}{length(tmp{1,end})+1,1} = '';
end

% Remove quotations (removed as of 08-Aug-2016); Collect header information
% replace '&' with '&amp;' (added 08-Aug-2016):
for i = 1:1:size(tmp,2)
    %     C(:,i) = strrep(tmp{1,i}(:,1),'"',''); % remove all quotation marks from tmp and assign it a column in C
    C(:,i) = tmp{1,i}(2:end,1);% strrep(tmp{1,i}(:,1),'&','&amp;'); % remove all quotation marks from tmp and assign it a column in C
    header{i,1} = tmp{1,i}(1,1);
end
fclose(fid);
C_remain = C;
rows_to_remove = [];
for j = 1:1:size(C,1)
   id = C{j,1}; % identifier
   if exist([tif_dir id '.tif'],'file')==2
      [s1] =  movefile([tif_dir id '.tif'],[georef_dir id '.tif']);
      [s2] =  movefile([mods_dir id '.xml'],[georef_dir id '.xml']);
      rows_to_remove = [rows_to_remove; j];
   else
      disp(['No TIF found in H:/ for ' id]); 
   end
end
C_remain(rows_to_remove,:)= [];


%% Now check against what is in georef_dir and make a list of what is not to be downloaded
macrepo_list = [];
no_mods_list = [];
for j = 1:1:size(C,1)
   id = C{j,1}; % identifier
   macrepo = C{j,2}; %macrepo
   if exist([georef_dir id '.tif'],'file')==2
   else
       macrepo_list = [macrepo_list; macrepo];
   end
   if exist([georef_dir id '.xml'],'file')==2
   else
       no_mods_list = [no_mods_list; id];
   end
   
end