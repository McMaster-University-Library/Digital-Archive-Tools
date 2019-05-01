function [] = DA_make_georef_matls(top_path,ingested_list)
% This function checks if items in the Digital Archive have GCP and README files.
% If it does not, it attempts to find a corresponding GCP file and create the readme file, and move both items to /ToIngest_Georef/

%%% Example Usage:
% DA_make_georef_matls('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested_all.csv')
% where ingested_all.csv is is output from a Fedora RIQS query(specifically, Example #2 here:
% https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md#example-2-display-list-of-all-active-non-deleted-items-in-a-collection-along-with-derivatives-good-for-checking)
%
%%% Notes to self:
% For every macrepo, we're looking for a GCP and README file ingested.
% If one of these is missing, try to create or find it and place it into /ToIngest_Georef/
% If these items exist, move them from /ToIngest_Georef/Queued/ to /Ingested
%
derivs = {'GCP';'README';'ISO19115'};
ids = {'macrepo:';'local:'};
%%%%%%%%%%%%%%%% Testing Purposes %%%%%%%%%%%%%%%%%%
% ingested_list = 'ingested_all.csv';
% top_path = 'H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ensure that there is a slash at the end of top_path.
switch top_path(end)
    case {'\','/'}
    otherwise
        top_path = [top_path '\'];
end

% Output files:
jjb_check_dirs([top_path 'ToIngest_Georef\'],1);
jjb_check_dirs([top_path 'ToIngest_Georef\Queued\'],1);
jjb_check_dirs([top_path 'README\'],1);

fid_log = fopen([top_path 'Ingested\georef_check_log_' datestr(now,30) '.csv'],'w+');
% fid_errors = fopen([top_path 'ToFix\ToFix.csv'],'w+');
if exist([top_path 'README\readme_template.txt'],'file')~=2
    copyfile(['..\georeferencing-tools\readme_template.txt'],[top_path 'README\readme_template.txt']);
end
addpath('..\georeferencing-tools');

% Open the ingested_list file, which is output from a Fedora RIQS query
%(specifically, Example #2 here:
%https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md#example-2-display-list-of-all-active-non-deleted-items-in-a-collection-along-with-derivatives-good-for-checking)
fid = fopen([top_path 'Ingested\' ingested_list],'r');
tline = fgetl(fid);
numcols = length(regexp(tline,','))+1;
formatspec = repmat('%q',1,numcols);
D = textscan(fid,formatspec,'Delimiter',',');

% Restructure into a flatter cell array; Remove quotation marks.
for pp = 1:1:size(D,2)
    %     isString = cellfun('isclass', D{1,pp}, 'char');
    %     D{1,pp}(isString) = strrep(D{1,pp}(isString), '"', '');
    D2(:,pp) = D{1,pp}(1:end,1);
end
% Turn the first column into a list of macrepos:
D2 = strrep(D2,'info:fedora/macrepo:','');
% remove "<macepo number>/" from the 5th column - leave just the derivative type
D2(:,5) = regexprep(D2(:,5),'^[^_]*\/','');
D2 = strrep(D2,'info:fedora/fedora-system:def/model#','');
fclose(fid);
clear D;

%%% Create a lookup table, with corresponding macrepos and identifiers (filenames):
ind = find(strncmp(D2(:,3),'local:',length('local:'))==1);
D3 = D2(ind,:);
D3 = strrep(D3,'local: ','');
[C,ia,ic] = unique(D3(:,1));
macrepo_id= D3(ia,[1,3]);
clear D3 ind C ia ic;

macrepos = unique(D2(:,1));

for i = 1:1:size(macrepos,1)
    ind = find( strcmp(D2(:,1),macrepos{i,1})==1 & strncmp(D2(:,4),'Active',6)==1 );
    tmp = D2(ind,:); % Extract the cell array section of interest
    
    %%% =========== GCP file ===================== %%%
    % If there is no GCP item ingested, try to find it in /gcp/, rename it and copy it into /ToIngest_Georef/
    if isempty(find(strcmp(tmp(:,5),'GCP')==1))==1
        if exist([top_path 'GCP\' macrepo_id{i,2} '.tif.points'],'file')==2
            [success] = copyfile([top_path 'GCP\' macrepo_id{i,2} '.tif.points'],[top_path 'ToIngest_Georef\macrepo_' macrepo_id{i,1} '_GCP.points']);
            switch success
                case 1
                    disp(['Copied file macrepo_' macrepo_id{i,1} '_GCP.points to \ToIngest_Georef\']);
                case 0
                    disp(['Error copying file ' macrepo_id{i,2} '.tif.points to \ToIngest_Georef\']);
            end
        else
            disp(['Can''t find file: ' macrepo_id{i,2} '.tif.points in \GCP']);
        end
        % else, see if it is in /ToIngest_Georef/Queued, move it to \Ingested
    else
        if exist([top_path 'ToIngest_Georef\Queued\macrepo_' macrepo_id{i,1} '_GCP.points'],'file')==2
            [success2] = movefile([top_path 'ToIngest_Georef\Queued\macrepo_' macrepo_id{i,1} '_GCP.points'],[top_path 'Ingested\macrepo_' macrepo_id{i,1} '_GCP.points']);
            switch success2
                case 1
                    disp(['Moved file macrepo_' macrepo_id{i,1} '_GCP.points to \Ingested\']);
                case 0
                    disp(['Error copying file ' macrepo_id{i,1} '_GCP.points to \Ingested\']);
            end
        end
    end
  %%% =========== ISO19115 file ===================== %%%
    % If there is no ISO19115 item ingested, try to find it in /ISO19115/, rename it and copy it into /ToIngest_Georef/
    if isempty(find(strcmp(tmp(:,5),'ISO19115')==1))==1
        if exist([top_path 'ISO19115\' macrepo_id{i,2} 'TIFF.xml'],'file')==2
            [success] = copyfile([top_path 'ISO19115\' macrepo_id{i,2} 'TIFF.xml'],[top_path 'ToIngest_Georef\macrepo_' macrepo_id{i,1} '_ISO19115.xml']);
            switch success
                case 1
                    disp(['Copied file macrepo_' macrepo_id{i,1} '_ISO19115.xml to \ToIngest_Georef\']);
                case 0
                    disp(['Error copying file ' macrepo_id{i,2} 'TIFF.xml to \ToIngest_Georef\']);
            end
        else
            disp(['Can''t find file: ' macrepo_id{i,2} '_ISO19115.xml in \ISO19115']);
        end
        
    else % else, see if it is in /ToIngest_Georef/Queued, move it to \Ingested
        if exist([top_path 'ToIngest_Georef\Queued\macrepo_' macrepo_id{i,1} '_ISO19115.xml'],'file')==2
            [success2] = movefile([top_path 'ToIngest_Georef\Queued\macrepo_' macrepo_id{i,1} '_ISO19115.xml'],[top_path 'Ingested\macrepo_' macrepo_id{i,1} '_ISO19115.xml']);
            switch success2
                case 1
                    disp(['Moved file macrepo_' macrepo_id{i,1} '_ISO19115.xml to \Ingested\']);
                case 0
                    disp(['Error copying file ' macrepo_id{i,1} '_ISO19115.xml to \Ingested\']);
            end
        end
    end
%%% =========== README file ===================== %%%
    % If there is no README item ingested, try to find it in /README/, rename it and copy it into /ToIngest_Georef/
    if isempty(find(strcmp(tmp(:,5),'README')==1))==1
        if exist([top_path 'README\macrepo_' macrepo_id{i,1} '_README.txt'],'file')~=2
            %%% Create the readme file: 
            result_readme = DA_make_readme(macrepo_id{i,1},macrepo_id{i,2},[top_path 'README\readme_template.txt'],[top_path 'README'],[top_path 'CRS_lookup.csv']);
            switch result_readme
                case 0 % Error
                    disp('Error creating README file -- deleted.');
                   delete([top_path 'README\macrepo_' macrepo_id{i,1} '_README.txt']);
                otherwise % success
                   disp(['Created README file: macrepo_' macrepo_id{i,1} '_README.txt in \README']);            
            end
        end
            [success] = copyfile([top_path 'README\macrepo_' macrepo_id{i,1} '_README.txt'],[top_path 'ToIngest_Georef\macrepo_' macrepo_id{i,1} '_README.txt']);
            switch success
                case 1
                    disp(['Copied file macrepo_' macrepo_id{i,1} '_README.txt to \ToIngest_Georef\']);
                case 0
                    disp(['Error copying file macrepo_' macrepo_id{i,1} '_README.txt to \ToIngest_Georef\']);
            end
        % else, see if it is in /ToIngest_Georef/Queued, move it to \Ingested
    else
        if exist([top_path 'ToIngest_Georef\Queued\macrepo_' macrepo_id{i,1} '_README.txt'],'file')==2
            [success2] = movefile([top_path 'ToIngest_Georef\Queued\macrepo_' macrepo_id{i,1} '_README.txt'],[top_path 'Ingested\macrepo_' macrepo_id{i,1} '_README.txt']);
            switch success2
                case 1
                    disp(['Moved file macrepo_' macrepo_id{i,1} '_README.txt to \Ingested\']);
                case 0
                    disp(['Error copying file ' macrepo_id{i,1} '_README.txt to \Ingested\']);
            end
        end
    end
    
end
fclose(fid_log);
%{    
    pass_flag = 1;
    for j_ids = 1:1:length(ids)
        for j_derivs = 1:1:length(derivs)
            test_ind = find( strncmp(tmp(:,3),ids{j_ids,1},length(ids{j_ids,1})) ==1 & strncmp(tmp(:,5),derivs{j_derivs,1},length(derivs{j_derivs,1})) );
            if isempty(test_ind)==1
                pass_flag = 0;
            end
        end
    end
    % get filename from lookup table
    try
        fname = macrepo_id{ strcmp(macrepo_id(:,1),macrepos{i,1})==1 ,2};
    catch
        disp(['no macrepo / identifier found for ' macrepos{i,1}]);
        pass_flag = 0;
        fname = '<unknown>';
    end
    
    tmp_out = sprintf('%s,',macrepos{i,1},fname, num2str(pass_flag));
    fprintf(fid_log,'%s\n',tmp_out(1:end-1));
    clear tmp_out;
    % If it has passed
    switch pass_flag
        case 0
            disp(['Possible issue with item : ' macrepos{i,1} ' : ' fname]);
            tmp_out = sprintf('%s,',macrepos{i,1},fname);
            fprintf(fid_errors,'%s\n',tmp_out(1:end-1));
            clear tmp_out;
        case 1 % If it passes, try to move the file to /Ingested/
            move_ingested_files(top_path, fname); % Try to move the file
    end
end
fclose(fid_errors);
fclose(fid_log);
end


function [] = move_ingested_files(top_path, fname)
if exist([top_path 'ToIngest\Queued\' fname '.tif'],'file')==2
    movefile([top_path 'ToIngest\Queued\' fname '.tif'],[top_path 'Ingested\' fname '.tif']);
    movefile([top_path 'ToIngest\Queued\' fname '.xml'],[top_path 'Ingested\' fname '.xml']);
    disp([fname ' pair moved to \Ingested']);
else
    disp(['Could not find a pair for file: ' fname]);
    clear fname;
end
end
%}