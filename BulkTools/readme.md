# Digital-Archive-Tools/BulkTools
This subdirectory contains Matlab functions used to perform bulk actions on items for (or from) the Digital Archive. Each function is described below

## 1. Digital Archive to Spreadsheet or Directory
The following functions pull metadata records or files from the Digital Archive and places them in local files (or a collective spreadsheet of records):

### DA_bulk_downloader.m
This function takes a list of macrepo numbers as input, and downloads the selected file type for each digital archive item.
Performs a bulk download of xml MODS files for a given list of items in the Digital Archive (list given as a csv of macrepo numbers)
Sample usage: DA_bulk_downloader('H:\Map_Office\Projects\19thc_maps_surveys\','H:\Map_Office\Projects\19thc_maps_surveys\macrepo_list.csv')
- Operate this function using *run_DA_bulk_downloader*.
- A sample input file can be found at \sample_files\macrepo_list.csv
- Sample output files are found in \sample_files\MODS_FromDA

### DA_mods_to_metadata.m
Loads all MODS xml file located in a /MODS folder of a specified directory, reformats all metadata to a single table with one row per file, and one column per unique metadata element. Exports in tab-separated format. 
- Operate this function using *run_DA_mods_to_metadata*.
**NOTE:** DA_mods_to_metadata should be run after DA_bulk_download_mods generates xml files.
- Sample output file is found at: \sample_files\metadata_out.txt

## 2. Spreadsheet to Digital Archive
The following functions take metadata structured in a spreadsheet and prepares them for ingest into the Digital Archive.

### DA_metadata_to_mods.m
Generates Digital-Archive upload-ready xml MODS files from a spreadsheet.
Spreadsheets are exported from https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk 
Run using *run_DA_metadata_to_mods.m*
- Sample output files can be found in \sample_files\MODS_FromSpreadsheet\

### zip_for_ingest.m
This function increments through all tif files in a directory. If a corresponding .xml file exists (i.e. same filename as the tif but extension = ".xml"), it will package these files with other groups in a manner that creates .zip archives that are ingestable into the Digital Archive via the bulk ingest tool (i.e. < 2 GB). 




## 3. Other Functions

### xml2struct.m
xml2struct takes either a java xml object, an xml file, or a string in xml format as input and returns a parsed xml tree in structure.
### aerialphoto_digarc_scraper.m
An old function used to crawl through URLs on the digital archive (by incrementing the macrepo numbers), parsing the HTML, and extracting the identifier and URL for only items in the air photo collection
### Bulk_Convert.m
Applies an imagemagick mogrify command to all items within a specified directory; typically used to resize and/or convert formats of images.
### rename_files.m
An old script used to bulk rename folders and files in a local/network directory
