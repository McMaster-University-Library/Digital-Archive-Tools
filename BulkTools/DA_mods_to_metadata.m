function [] = DA_mods_to_metadata()
start_path = 'H:\Map_Office\Projects\19thc_maps_surveys';
cd(start_path)
DA_path = 'http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A';
a = csvread([start_path '\macrepo_list.csv']);
% http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A5044/datastream/MODS/download
for i = 1:1:length(a)
   websave([start_path '\MODS\macrepo_' num2str(a(i)) '.xml'],[DA_path num2str(a(i)) '/datastream/MODS/download']);
end