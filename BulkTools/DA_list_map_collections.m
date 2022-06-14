%%% This script builds a list of all collections belonging to the map
%%% collection tree. The second half of this script counts items within
%%% given collections
%%% 
%%% Step 1: Run the following Fedora RIQS query: https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md#example-5-list-all-collections-within-the-digital-archive-and-their-parents
%%% Step 2: Copy and paste the output in collections_current.csv (in this repo)
%%% Step 3: Save the file. Run this script.

clearvars
A = readcell('inventories\collections_current.csv','NumHeaderLines',1,'Delimiter',',');

A_cleaned = {};
for i = 1:1:length(A)
    
    %%% pull out macrepo numbers for collections (first and third columns):
    
    if strncmp(A{i,1},'info:fedora/macrepo:',length('info:fedora/macrepo:'))==1 && strncmp(A{i,3},'info:fedora/macrepo:',length('info:fedora/macrepo:'))==1
        A_cleaned(size(A_cleaned,1)+1,1:3) = A(i,:);
        A_cleaned{end,4} = str2num(A{i,1}(length('info:fedora/macrepo:')+1:end));
        A_cleaned{end,5} = str2num(A{i,3}(length('info:fedora/macrepo:')+1:end));
    else
        
    end
end


%%% Build a list of all collections belonging to the map collection tree
macrepos = cell2mat(A_cleaned(:,4:5));
macrepos_tmp = macrepos;

map_collections = [10];

ind = find(macrepos_tmp(:,2)==10);
length_old = length(map_collections);

map_collections = [map_collections; macrepos_tmp(ind,1)];
level = [1; 2*ones(length(ind),1)];

macrepos_tmp(ind,:) = [];
length_new = length(map_collections);
total_new = 0;
total_new = total_new + length(ind);
 
level_ctr = 2;
while total_new > 0
total_new = 0;
level_ctr = level_ctr + 1;
for i = length_old+1:1:length_new
    ind = find(macrepos_tmp(:,2)==map_collections(i,1));
    map_collections = [map_collections; macrepos_tmp(ind,1)];
    level = [level; level_ctr*ones(length(ind),1)];
    macrepos_tmp(ind,:) = [];
    total_new = total_new + length(ind);
end
length_old = i;
length_new = i+total_new;
end

map_collections_out = {};
[map_collections,ia] = unique(map_collections);
level = level(ia,1);

% [map_collections, ia2] = sort(map_collections(ia),'ascend');
[map_collections, ia2] = sort(map_collections,'ascend');
level = level(ia2);

for j = 1:1:length(map_collections)
    right_row = find(macrepos(:,1)==map_collections(j,1));
    map_collections_out{j,1} = macrepos(right_row(1),1);
    map_collections_out{j,2} = A_cleaned{right_row(1),2};
    map_collections_out{j,3} = macrepos(right_row(1),2);
    map_collections_out{j,4} = level(j,1);
    map_collections_out{j,5} = ['https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' num2str(macrepos(right_row(1),1))];
end

headers_collections = {'macrepo','name','parent_collection','level','url'};
T = cell2table(map_collections_out,'VariableNames',headers_collections);
writetable(T,'inventories\map_collections_out.csv')
map_collections_out2 = [{'macrepo','name','parent_collection','level','url'};map_collections_out];
writecell(map_collections_out2,'inventories\map_collections_out.xlsx');
clear map_collection_out2;

%% Step 2: check the items list against the collections list to include only those with proper parents:
B = readcell('inventories\items_current.csv','NumHeaderLines',1,'Delimiter',',');
B_tmp = B;
ind1 = find(strncmp(B(:,1),'info:fedora/macrepo:',length('info:fedora/macrepo:'))~=1 | strncmp(B(:,3),'info:fedora/macrepo:',length('info:fedora/macrepo:'))~=1);
B(ind1,:) = [];
map_items_out = {};
for i = 1:1:length(B)
tmp_item_macrepo = str2num(B{i,1}(length('info:fedora/macrepo:')+1:end)); 
tmp_parent_macrepo = str2num(B{i,3}(length('info:fedora/macrepo:')+1:end));
if ~isempty(tmp_item_macrepo) && ~isempty(tmp_parent_macrepo)
if ~isempty(find(tmp_parent_macrepo==map_collections))
   map_items_out{size(map_items_out,1)+1,1} = tmp_item_macrepo;
   map_items_out{size(map_items_out,1),2} = B{i,2};
   map_items_out{size(map_items_out,1),3} = tmp_parent_macrepo;   
end
end
end
% 84411 - Italy 1:50k Topographic Maps
% 66660 - Italy 1:25k Topographic Maps
% 85282 - Europe, Central 1:25k Topographic Maps (GermanyHollandPoland)
% 86603 - LCMSDS Defence Overprints
% 87642 - Ontario Historical Topographic Maps - 1:63360
% 88343 - Ontario Historical Topographic Maps - 1:25000
% 87641 - Japan City Plans 1:12,500 
% 88593 - WW2_Geologic_France_80k 
% 88988 - WW2_France_50k_GSGS4250 
% 88989 - WW2_France_50k_GSGS4040 
% 88992 - UofA_WW2_Crete_50k_topos
items_parents = cell2mat(map_items_out(:,[1,3]));
OCUL_63K = find(items_parents(:,2)==87642);
OCUL_25K = find(items_parents(:,2)==88343);
OCUL_nums = length(OCUL_25K) + length(OCUL_63K);

% Def Ovr = 66649;
% Crete = 
UofA_macrepos = [88992; 84411; 66660; 85282];
UofA_nums = [];
for i = 1:1:length(UofA_macrepos)
    UofA_nums(i,1) = length(find(items_parents(:,2)==UofA_macrepos(i,1)));
end
sum(UofA_nums)

DO_macrepos = [86722; 86716; 86718; 86725; 86724; 86719; 86721; 86715; 86717; 86723];
DO_nums = [];
for i = 1:1:length(DO_macrepos)
    DO_nums(i,1) = length(find(items_parents(:,2)==DO_macrepos(i,1)));
end
sum(DO_nums)

%%% Write map_items_out (but first, replace missing elements)
% mask = cellfun(@ismissing, map_items_out(1:18108,1:3));
% map_items_out(mask) = {[]};
% writecell(map_items_out(1:18103,1:3),'inventories\map_items_out.xlsx');

for i = 1:1:length(map_items_out)
    map_items_out{i,4} = ['https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' num2str(map_items_out{i,1})];
end
    headers_map_items = {'macrepo','name','parent_collection','url'};
T = cell2table(map_items_out,'VariableNames',headers_map_items);
writetable(T,'inventories\map_items_out.csv');

