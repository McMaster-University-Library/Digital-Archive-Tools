function [] = DA_mods_to_metadata(path_in)
%%% Loads all MODS xml file located in a the /MODS folder of a specified
%%% directory, reformats all metadata to a single table with one row per
%%% file, and one column per unique metadata element.
%%% Exports in tab-separated format

if strcmp(path_in(end), '\')==1 || strcmp(path_in(end), '/')==1
else
    path_in = [path_in '\'];
end

start_path = [path_in 'MODS'];

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
%% Save the output file
%output format
fid = fopen([path_in 'metadata_out.tsv'],'w');
% output header
fprintf(fid,'%s\n',sprintf('%s\t',fnames{1,:}));

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
    fprintf(fid,'%s\n',sprintf('%s\t',output{i,:}));
end
    fclose(fid);
    