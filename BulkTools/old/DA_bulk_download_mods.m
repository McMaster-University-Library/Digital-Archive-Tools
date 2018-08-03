function [] = DA_bulk_download_mods(start_path, macrepo_list_path)
%%% Performs a bulk download of xml MODS files for a given list of items
%%% (list given as a csv of macrepo numbers)
%%% inputs: 
% start_path: A file path where a \MODS directory will be created, in which
% xml files will be placed
% macrepo_list_path: Full file path to the csv list of macrepo numbers to be
% used.
%%% Sample usage: 
% DA_bulk_download_mods('H:\Map_Office\Projects\19thc_maps_surveys\','H:\Map_Office\Projects\19thc_maps_surveys\macrepo_list.csv')

if strcmp(start_path(end), '\')==1 || strcmp(start_path(end), '/')==1
else
    start_path = [start_path '\'];
end
% start_path = 'H:\Map_Office\Projects\19thc_maps_surveys';
% cd(start_path)
DA_path = 'http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A';

%%% read the csv list
a = csvread(macrepo_list_path);

%% Download each file in the list
% sample MODS location: http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A5044/datastream/MODS/download
for i = 1:1:length(a)
   websave([start_path 'MODS\macrepo_' num2str(a(i)) '.xml'],[DA_path num2str(a(i)) '/datastream/MODS/download']);
end