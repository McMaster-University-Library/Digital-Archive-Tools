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