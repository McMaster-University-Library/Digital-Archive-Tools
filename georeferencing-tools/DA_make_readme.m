function [output] = DA_make_readme(macrepo,id,template_path,save_dir,CRS_lookup_path)
% output = 1 if successful; 0 if not successful
fid_readme = fopen(template_path,'r');
fid_out = fopen([save_dir '\macrepo_' macrepo '_README.txt'],'w');

%%% Load the CRS Lookup file - structure: |identifier | CRS statement
fid_CRS = fopen(CRS_lookup_path,'r');
D_CRS_tmp = textscan(fid_CRS,'%q%q','Delimiter',',');
for pp = 1:1:size(D_CRS_tmp,2)
    D_CRS(:,pp) = D_CRS_tmp{1,pp}(1:end,1);
end
clear D_CRS_tmp;
fclose(fid_CRS);

%%% Find desired CRS
rightrow = find(strcmp(D_CRS(:,1),id)==1);
if ~isempty(rightrow)==1
    CRS_statement = D_CRS{rightrow,2};
else
    disp(['Can''t find identifier : ' id ' in CRS lookup list. Exiting']);
    output = 0;
    fclose(fid_readme); 
    fclose(fid_out);
    return;
end

eof = 0;
while eof==0
    tline = fgets(fid_readme);
    lineout = strrep(tline,'<macrepo>',macrepo);
    lineout = strrep(lineout,'<CRS>',CRS_statement);
    fprintf(fid_out,'%s',lineout);
    eof = feof(fid_readme);
end
fclose(fid_readme); 
fclose(fid_out);
output = 1;