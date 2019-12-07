function [macrepo_id] = DA_check_ingested(top_path,ingested_list)
%%% This function checks items in the Digital Archive to ensure that they
%%% contain all derivative files.
%%% Derivatives include:
%%% The output consists of two tables -- a list of all items reviewed, and
%%% a list of items failing the check stage.
%%% Any failing items are moved from /Ingested to
%%% Example Usage:
% DA_check_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\GermanyHollandPoland_25k\','ingested.csv')
%
%
%%% Notes to self: For every macrepo, we're looking for each item listed in
%%% the derivs array. This information is found in column 5 of the imported
%%% data. These sets need to exist for both types of ids (col 3):
%%% If this fails, we flag the item for review and DON'T copy it to /Ingested
%
derivs = {'DC';'MODS';'RELS-EXT';'OBJ';'TN';'JPG';'JP2'};
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
jjb_check_dirs([top_path 'ToFix\'],1);
fid_log = fopen([top_path 'ToFix\check_log_' datestr(now,30) '.csv'],'w+');
fid_errors = fopen([top_path 'ToFix\ToFix.csv'],'w+');



%Open the ingested_list file, which is output from a Fedora RIQS query
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
    try
    movefile([top_path 'ToIngest\Queued\' fname '.tif'],[top_path 'Ingested\' fname '.tif']);
    movefile([top_path 'ToIngest\Queued\' fname '.xml'],[top_path 'Ingested\' fname '.xml']);
    disp([fname ' pair moved to \Ingested']);
    catch
    disp(['Error moving pair ' fname ' from ToIngest\Queued\ to Ingested\. Skipping.']);
    end
else
    disp(['Could not find a pair for file: ' fname]);
    clear fname;
end
end