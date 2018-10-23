function [] = DA_prepare_ingest(top_path)

% Example: top_path = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\UofA WWII_Italy_Topos_50k\';
% Ensure that there is a slash at the end of top_path.
switch top_path(end)
    case {'\','/'}
    otherwise
        top_path = [top_path '\'];
end

%Check that all requisite folders exist:
mods_path = [top_path 'MODS\'];
if exist(mods_path,'dir')~=7
    disp('Can''t find the MODS\ directory. Check that it exists and that the top_path is set properly');
    return;
end

log_path = [top_path 'logs\'];
jjb_check_dirs(log_path,1) % processing log folder
jjb_check_dirs([top_path 'ToIngest\'],1) % output folder

% Open Log files:
fid = fopen([top_path 'unmatched_tiffs.csv'],'w+');
fid_log = fopen([log_path 'process_log_' datestr(now,30) '.csv'],'a');

%%% Directory listing
d = dir(top_path);

for i = 3:1:length(d)
    [~, fname, fext] = fileparts(d(i).name); %file directory | filename | file extension
    if strcmp(fext,'.tiff')==1 || strcmp(fext,'.tif')==1
        if exist([mods_path fname '.xml'],'file')==2
            % If there's a corresponding .xml file, move both over together
            % to /ToIngest:
            movefile([top_path d(i).name],[top_path 'ToIngest'])
            movefile([mods_path fname '.xml'],[top_path 'ToIngest'])
            disp(['Moved ' fname ' pair to \ToIngest.']);
            fprintf(fid_log,'%s\n',['Moved ' fname ' pair to \ToIngest.']);
        else
            disp(['No match for: ' d(i).name]);
            fprintf(fid_log,'%s\n',['No match for: ' d(i).name]);
            fprintf(fid,'%s\n',d(i).name);
        end
    end
end
            
fclose(fid);
fclose(fid_log);

