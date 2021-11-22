cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'TIFF';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\';
download_list = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\macrepos.csv';
DA_bulk_downloader(download_type,download_dir,download_list)

%% Robert Clifford images
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'TIFF';
download_dir = 'H:\Digitization_Projects\Omeka\Robert Clifford Collection\';
download_list = 'H:\Digitization_Projects\Omeka\Robert Clifford Collection\download_list.csv';
DA_bulk_downloader(download_type,download_dir,download_list)

%% France 100K WW2 topos
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'TIFF';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\France_Belgium_Holland\France_100k\';
download_list = [download_dir 'macrepos.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)

%% Metadata for Italy 100k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'MODS';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\MODS\';
download_list = [download_dir 'macrepos.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)

%% Metadata for Italy 50k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'MODS';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\MODS\';
download_list = [download_dir 'macrepos.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)
%% Daily Twitter images
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'TIFF';
download_dir = 'D:\Local\DailyTwitter\12Oct1918\';
download_list = [download_dir 'download_list.csv'];
DA_bulk_downloader(download_type,download_dir,download_list,1); % run with book_flag = 1

%% Metadata for Italy 25k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'MODS';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\UofA WWII_Italy_Topos_25k\MODS-downloaded\';
download_list = [download_dir 'macrepo_list.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)

%% Metadata for Italy/Switzerland 250k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'MODS';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\ItalySwitzerland_250k\MODS-downloaded\';
download_list = [download_dir 'macrepo_list.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)

%% Some tiffs for DMDS workshop:
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'TIFF';
download_dir = 'D:\Local\GISDay - DMDS\';
download_list = 'D:\Local\GISDay - DMDS\macrepos.csv';
DA_bulk_downloader(download_type,download_dir,download_list)

%% Italy 1:50k tiffs
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'TIFF';
download_dir = 'E:\Italy_50k\';
download_list = 'E:\Italy_50k\macrepos.csv';
DA_bulk_downloader(download_type,download_dir,download_list)

%% HAM 1898 FIPs using new downloader program (to download DC files)
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_list = 'H:\Digitization_Projects\omeka-tests\HamFIP1898\macrepos.csv';
download_dir = 'H:\Digitization_Projects\omeka-tests\HamFIP1898\';
download_type = 'DC';
DA_bulk_downloader(download_type,download_dir,download_list);

%% WW2_France_100k_GSGS4249

%% WW2_Holland_100k_GSGS2541

%% WW2_Belgium_France_100k_GSGS4336

%% Bulgaria 1:250,000 (GSGS 4412) - https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A19790
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'DC';
download_dir = 'D:\Local\topo-extracts\19790\';
download_list = [download_dir '19790.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)
DA_dc_to_csv(download_dir);

%% Romania 1:250,000 (GSGS 4375) - https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A21809
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'DC';
download_dir = 'D:\Local\topo-extracts\20447\';
download_list = [download_dir '20447.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)
DA_dc_to_csv(download_dir);

%% Spain Gibraltar 1:100,000 (GSGS 4109) - https://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A20447
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'DC';
download_dir = 'D:\Local\topo-extracts\21809\';
download_list = [download_dir '21809.csv'];
DA_bulk_downloader(download_type,download_dir,download_list)
DA_dc_to_csv(download_dir);
%% Downloading a bunch of series at a time (collection macrepos inserted into a csv file
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
download_type = 'DC';
%%% Load the processing list:
list_path = 'D:\Local\topo-extracts\collections-to-process.csv';
colls_to_load = csvread(list_path);
top_dir = 'D:\Local\topo-extracts\';

% Run once -- check for all directories and csv files -- make empty ones if
% not
for i = 1:1:size(colls_to_load,1)
    coll_to_run = colls_to_load(i,1);
    
    download_dir = ['D:\Local\topo-extracts\' num2str(coll_to_run) '\'];
    jjb_check_dirs(download_dir,1);
    download_list = [download_dir num2str(coll_to_run) '.csv'];
    
    if exist(download_list,'file')~=2
        fid = fopen(download_list,'w+');
        fclose(fid);
    end
end

%%% Now, manually run sparql queries, save output to csv files

%%% Now, reformat the csv files to include just unique macrepo values of
%%% children. these lists will be in each directory with name
%%% 'macrepos_xxxxx'
for i = 1:1:size(colls_to_load,1)
    coll_to_run = colls_to_load(i,1);
    
    download_dir = ['D:\Local\topo-extracts\' num2str(coll_to_run) '\'];
    download_list = [download_dir num2str(coll_to_run) '.csv'];
DA_sparql_extractor(download_list);
end

%%% iterate through collections -- turn DC to spreadsheet
for i = 1:1:size(colls_to_load,1)
    coll_to_run = colls_to_load(i,1);
    download_dir = ['D:\Local\topo-extracts\' num2str(coll_to_run) '\'];
    download_list = [download_dir 'macrepos_' num2str(coll_to_run) '.csv'];
    DA_bulk_downloader(download_type,download_dir,download_list)
    DA_dc_to_csv(download_dir);
end

%%% Finally, pull the metadata files out into the top-level directory and
%%% add the macrepo number to the filename
for i = 1:1:size(colls_to_load,1)
    coll_to_run = colls_to_load(i,1);
    download_dir = ['D:\Local\topo-extracts\' num2str(coll_to_run) '\'];
copyfile([download_dir 'metadata_out.tsv'],[top_dir num2str(coll_to_run) '_metadata_out.tsv']);
end

% download_dir = 'D:\Local\topo-extracts\21809\';
% download_list = [download_dir '21809.csv'];
% DA_bulk_downloader(download_type,download_dir,download_list)
% DA_dc_to_csv(download_dir);
