function [] = DA_move_ingested(top_path,ingested_list)
%%% This function moves verified ingested files from the \ToIngest\Queued\
%%% directory to the \Ingested\ directory. 
%%% The input file for this function is a single-column .csv file created
%%% from the fedora RIS and formatted using this sheet: https://docs.google.com/spreadsheets/d/1GbFjUKtuc8bU2qK5CkAmdaKKlHDSoskw6uaInNMD6Hg/edit#gid=1862350458
%%% NOTE that the input file is assumed to exist in \Ingested\
%%% Example Usage:
% DA_move_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested.csv')

% Ensure that there is a slash at the end of top_path.
switch top_path(end)
    case {'\','/'}
    otherwise
        top_path = [top_path '\'];
end

%Open the ingested_list file, containing a list of all ingested files (by filename)
% ingested_list = 'H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\Ingested\ingested.csv';
fid = fopen([top_path 'Ingested\' ingested_list],'r');
D = textscan(fid,'%s','Delimiter',',');
% Remove quotation marks.
for pp = 1:1:size(D,2)
    isString = cellfun('isclass', D{1,pp}, 'char');
    D{1,pp}(isString) = strrep(D{1,pp}(isString), '"', '');
end
fclose(fid);
D = D{1,1};

for i = 1:1:size(D,1)
    fname = D{i,1};
    if exist([top_path 'ToIngest\Queued\' fname],'file')==2
        movefile([top_path 'ToIngest\Queued\' fname],[top_path 'Ingested\' fname]);
        movefile([top_path 'ToIngest\Queued\' fname(1:end-4) '.xml'],[top_path 'Ingested\' fname(1:end-4) '.xml']);
        disp([fname ' pair moved to \Ingested']);
    else
        disp(['Could not find a pair for file: ' fname]);
    clear fname;
    end
end