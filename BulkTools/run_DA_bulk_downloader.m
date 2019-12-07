cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.tiff';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\';
download_list = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\macrepos.csv';
DA_bulk_downloader(file_ext,download_dir,download_list)

%% Robert Clifford images
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.tiff';
download_dir = 'H:\Digitization_Projects\Omeka\Robert Clifford Collection\';
download_list = 'H:\Digitization_Projects\Omeka\Robert Clifford Collection\download_list.csv';
DA_bulk_downloader(file_ext,download_dir,download_list)

%% France 100K WW2 topos
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.tiff';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\France_Belgium_Holland\France_100k\';
download_list = [download_dir 'macrepos.csv'];
DA_bulk_downloader(file_ext,download_dir,download_list)

%% Metadata for Italy 100k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.xml';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\MODS\';
download_list = [download_dir 'macrepos.csv'];
DA_bulk_downloader(file_ext,download_dir,download_list)

%% Metadata for Italy 50k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.xml';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\Italy_100k_TIF_600dpi\MODS\';
download_list = [download_dir 'macrepos.csv'];
DA_bulk_downloader(file_ext,download_dir,download_list)
%% Daily Twitter images
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.tiff';
download_dir = 'D:\Local\DailyTwitter\12Oct1918\';
download_list = [download_dir 'download_list.csv'];
DA_bulk_downloader(file_ext,download_dir,download_list,1); % run with book_flag = 1

%% Metadata for Italy 25k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.xml';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\UofA WWII_Italy_Topos_25k\MODS-downloaded\';
download_list = [download_dir 'macrepo_list.csv'];
DA_bulk_downloader(file_ext,download_dir,download_list)

%% Metadata for Italy/Switzerland 250k
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.xml';
download_dir = 'H:\Digitization_Projects\WWII_Topographic_Maps\ItalySwitzerland_250k\MODS-downloaded\';
download_list = [download_dir 'macrepo_list.csv'];
DA_bulk_downloader(file_ext,download_dir,download_list)

%% Some tiffs for DMDS workshop:
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.tiff';
download_dir = 'D:\Local\GISDay - DMDS\';
download_list = 'D:\Local\GISDay - DMDS\macrepos.csv';
DA_bulk_downloader(file_ext,download_dir,download_list)

%% Italy 1:50k tiffs
cd('D:\Local\Digital-Archive-Tools\BulkTools\');
file_ext = '.tiff';
download_dir = 'E:\Italy_50k\';
download_list = 'E:\Italy_50k\macrepos.csv';
DA_bulk_downloader(file_ext,download_dir,download_list)
