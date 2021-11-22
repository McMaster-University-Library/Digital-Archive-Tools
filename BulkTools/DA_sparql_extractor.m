function DA_sparql_extractor(file_in)
%%% Currently doesn't do much -- just takes stock csv input from DA SPARQL
%%% queries and turns into a unique list of macrepos.
[filepath,name,ext] = fileparts(file_in);

opts = detectImportOptions(file_in);

C = readcell(file_in);

headers = C(1,:);

right_col = find(strcmp(headers,'pid')==1);

%%% Assuming there is a column called 'pid', strip out the macrepo from
%%% each line.
if isempty(right_col)~=1
   tmp = C(2:end,right_col);
   macrepo_list = [];
    for i = 1:1:size(tmp,1)
       if strncmp(tmp{i},'info:fedora/macrepo:',numel('info:fedora/macrepo:'))==1
           tmp = strrep(tmp,'info:fedora/macrepo:','');
           macrepo_list = [macrepo_list; str2double(tmp)];
       end
    end
        
    
else
    disp(['Could not find pid column in file' file_in]);
end

%%% Get the unique macrepos
macrepo_list = unique(macrepo_list);
%%% Save the file
csvwrite([filepath '/macrepos_' name '.csv'],macrepo_list);


end