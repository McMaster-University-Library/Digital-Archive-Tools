function [] = DA_list_all_children(parent_macrepo)
%%% This function takes a parent macrepo number as input and returns all
%%% items in all subdirectories under it
%%% ensure that you run DA_list_map_collections.m before running this
%%% function

%%% Load necessary files: 
A = readcell('inventories\map_collections_out.csv','NumHeaderLines',1,'Delimiter',',');
B = readcell('inventories\map_items_out.csv','NumHeaderLines',1,'Delimiter',',');

collections_macrepos = cell2mat(A(:,1));
collections_parents = cell2mat(A(:,3));
items_macrepos = cell2mat(B(:,1));
items_parents = cell2mat(B(:,3));


% First level down
all_parents = parent_macrepo;
ind = find(collections_parents==parent_macrepo);
all_parents = [parent_macrepo; collections_macrepos(ind)];

%%% Next level
all_children = [];
for i = 2:1:length(all_parents)    
ind = find(collections_parents==all_parents(i));
all_children = [all_children; collections_macrepos(ind)];
end
all_parents = [all_parents; all_children];

%%% Next level
all_children = [];
for j = i+1:1:length(all_parents)
ind = find(collections_parents==all_parents(j));
all_children = [all_children; collections_macrepos(ind)];
end
all_parents = [all_parents; all_children];

%%% Next level
all_children = [];
for k = j+1:1:length(all_parents)
ind = find(collections_parents==all_parents(k));
all_children = [all_children; collections_macrepos(ind)];
end
all_parents = [all_parents; all_children];

%%% Next level
all_children = [];
for l = k+1:1:length(all_parents)
ind = find(collections_parents==all_parents(l));
all_children = [all_children; collections_macrepos(ind)];
end
all_parents = [all_parents; all_children];

%% Now, build a list of all items that are children of the parent collections
items_out = {};
for i = 1:1:length(all_parents)
    ind = find(items_parents==all_parents(i,1));
    items_out = [items_out; B(ind,:)];
end

%%% Replace parent macrepo ids with names
parent_macrepos = cell2mat(items_out(:,3));
aa = unique(parent_macrepos);

for j = 1:1:length(aa)
    ind = find(parent_macrepos==aa(j));
    coll_name = A(collections_macrepos==aa(j),2);
    items_out(ind,3) = coll_name;
end

%%% remove the first column (don't need it)
items_out(:,1) = [];
headers = {'Name','Parent Collection Name','URL'};
T = cell2table(items_out,'VariableNames',headers);
writetable(T,['inventories/item_list_macrepo_' num2str(parent_macrepo) '.csv']);
