function [] = DA_dc_to_csv(path_in)
%%% Loads all DC xml file located in a selected folder of a specified
%%% directory, reformats all metadata to a single table with one row per
%%% file, and one column per unique metadata element.
%%% Exports in tab-separated format
% See run_DA_dc_to_csv.m for usage examples

if strcmp(path_in(end), '\')==1 || strcmp(path_in(end), '/')==1
    start_path = path_in;
else
    start_path = [path_in '\'];
end

% start_path = [path_in 'MODS'];

d = dir(start_path);
output = {};
fnames = {};
macrepo = {};
for i = 3:1:length(d)
    
    if d(i).isdir==0 
        [~,filename,ext] = fileparts(d(i).name);
        switch ext
            case '.xml'
                macrepo_tmp = filename(strfind(filename,'_')+1:end);
                if isempty(macrepo_tmp)
                macrepo_tmp = filename;
                end

                macrepo{size(macrepo,1)+1,1} = macrepo_tmp;
                outStruct = xml2struct([start_path '\' d(i).name]); 
                
                %%%%%%%%%%% Flatten structure into cell array
                fname_top = fieldnames(outStruct);
                mods = getfield(outStruct,fname_top{1});
                [outcell_tmp, fnames_tmp] = flattenStruct2Cell(mods);
                if isempty(fnames)==1 % if first time through, take the field names to be the master list
                    fnames = fnames_tmp;
                    output(size(output,1)+1,:) = outcell_tmp;
                else % if not, we'll have to map the columns to the original
                    right_row = size(output,1)+1;
                    for j = 1:1:size(fnames_tmp,2)
                        right_col = find(strcmp(fnames,fnames_tmp{1,j})==1);
                        if isempty(right_col)==1 % if there's no matching column name between the new field names and the master list, add it
                            fnames{1,size(fnames,2)+1} = fnames_tmp{1,j};
                            output{right_row,size(output,2)+1} = outcell_tmp{1,j};
                        else % if there is a match, but the output in the correct cell.
                            output{right_row,right_col} = outcell_tmp{1,j};
                        end
                    end
                end
%                 fnames(size(fnames,1)+1,:) = fnames_tmp;
            otherwise
           disp(['Skipping file: ' d(i).name ' -- not an xml file.']);     
        end
    end
end
fnames(1,2:size(fnames,2)+1) = fnames(1,1:end);
fnames{1,1} = 'macrepo';

output(:,2:size(output,2)+1) = output(:,1:end);
output(:,1) = macrepo;

%%% TO DO HERE 
% replace 'u_colonu_' with ':'
% remove text after last underscore
% Remove all columns that start with 'Attribute'?
isString    = cellfun('isclass', fnames, 'char');
 fnames(isString) = strrep(fnames(isString),'u_colonu_',':');
 fnames(isString) = strrep(fnames(isString),'dc:','dcterms:');

% strrep(fnames,'u_colonu_',':');
to_remove = [];
for i = 1:1:size(fnames,2)
tmp = fnames{1,i};

ind_uscore = strfind(tmp,'_');

if ~isempty(ind_uscore)
    tmp = tmp(1:ind_uscore(end)-1);
    fnames{1,i} = tmp;
end

% Identify all fields starting with "Attributes"
try
if strcmp(tmp(1:10),'Attributes')==1
    to_remove = [to_remove; i];
end
catch    
end

end
% Remove all fields starting with "Attributes"
fnames(:,to_remove) = [];
output(:,to_remove) = [];

%%% Finally, create a final column that is the URL to the resource in the
%%% Digital Archive:
% TIFF URL: https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A33273/datastream/OBJ/download
% JP2 URL: https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A33273/datastream/JP2/download
fnames{1,size(fnames,2)+1} = 'TIFF_URL';
fnames{1,size(fnames,2)+1} = 'JP2000_URL';
numcols_output = size(output,2);

for i = 1:1:size(output,1)
    % TIFF URL on DA:
output{i,numcols_output+1} = ['https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' output{i,1} '/datastream/OBJ/macrepo%3A' output{i,1} '.tiff'];
    % JP2 URL on DA:
output{i,numcols_output+2} = ['https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' output{i,1} '/datastream/JP2/macrepo%3A' output{i,1} '.jp2'];  
end
%% Save the output file
%output format
fid = fopen([start_path 'metadata_out.tsv'],'w');
% output header
fprintf(fid,'%s',sprintf('%s\t',fnames{1,1:end-1}));
fprintf(fid,'%s\n',sprintf('%s',fnames{1,end}));

% write data
%%% Replace all newline characters and tabs in text with spaces.
%%% Replace some special unicode characters with more standard ones
isString    = cellfun('isclass', output, 'char');
 output(isString) = strrep(output(isString),'\t',' ');
 output(isString) = strrep(output(isString),'“','"');
 output(isString) = strrep(output(isString),'”','"');
 output(isString) = strrep(output(isString),'’','''');
 output(isString) = regexprep(output(isString),'[\n\r]+',' ');

for i = 1:1:size(output,1)
%     fprintf(fid,'%s\n',sprintf(formatout2_tab,output{i,:}));
    fprintf(fid,'%s',sprintf('%s\t',output{i,1:end-1}));
    fprintf(fid,'%s\n',sprintf('%s',output{i,end}));

end

    fclose(fid);
    