# Digital-Archive-Tools/BulkTools
This subdirectory contains Matlab functions used to perform bulk actions on items for (or from) the Digital Archive. Each function and their associated processes are described below

## 1. Digital Archive to Spreadsheet or Directory
A number of functions have been created to pull metadata records or files (images, etc.) from the Digital Archive and place them in local files (or a collective spreadsheet of records). These functions are described below.

### DA_bulk_downloader.m
This function takes a list of macrepo numbers as input, and downloads the selected file type for each digital archive item. Downloadable types include '.tiff'; '.jp2'; '.jpeg'; '.xml'
When the argument file_ext is set to '.xml', it performs a bulk download of xml MODS files for a given list of items in the Digital Archive (list given as a csv of macrepo numbers)
Sample usage: DA_bulk_downloader('H:\Map_Office\Projects\19thc_maps_surveys\','H:\Map_Office\Projects\19thc_maps_surveys\macrepo_list.csv')
- Operate this function using *run_DA_bulk_downloader*.
- A sample input file can be found at \sample_files\macrepo_list.csv
- Sample output files are found in \sample_files\MODS_FromDA

### DA_mods_to_metadata.m
Loads all MODS xml file located in a /MODS folder of a specified directory, reformats all metadata to a single table with one row per file, and one column per unique metadata element. Exports in tab-separated format. 
- Operate this function using *run_DA_mods_to_metadata*.
- **NOTE:** DA_mods_to_metadata should be run after DA_bulk_downloader generates xml files.
- Sample output file is found at: \sample_files\metadata_out.txt

## 2. Spreadsheet to Digital Archive
Bulk uploading from a local filesystem to the Digital Archive can be done in a couple of ways. Regardless of approach, it is necessary to produce pairs of files for each object to be ingested. The pair consists of an image file and a corresponding xml metadata file.  
Our approach is as follows (a scripted overview of the process can be found in *run_DA_ingest.m*): 
1. **Creating metadata records**: Bulk metadata records are created via a [Google spreadsheet](https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk).  2. Records for each collection are created in separate tabs of the sheet. When a new collection is being described, a new tab is created by duplicating the "Template - DO NOT EDIT - Duplicate for new" tab, and renaming appropriately. 
2. **Generating individuals metadata files**: When MODS metadata files need to be produced, the following steps should be taken: 
    * The tab of interest in the metadata Google Sheet should be downloaded as a tab-separated file (.tsv) to the top-level local folder of the collection (i.e. the same place where scanned .tiff images are placed).
    * Run *DA_metadata_to_mods.m*, which generates Digital-Archive upload-ready xml MODS files from the downloaded metadata spreadsheet (.tsv). As an example:
        * ```cd('D:\Local\Digital-Archive-Tools\BulkTools')```  
	    * ```DA_metadata_to_mods('H:\Digitization_Projects\WWII_Topographic_Maps\Italy\UofA WWII_Italy_Topos_50k\','Bulk Metadata Templates - UofA_WW2_Italy_50k_topos.tsv');```  
	    * Running these lines results in the creation of a /MODS/ folder in the top-level directory, and the generation of separate .xml files for each row in the spreadsheet.  
3. **Preparing for bulk ingest**: 
    * [OLD method] In this method, .xml files from the /MODS/ directory are copied (manually) to the top-level folder, so that they appear alongside their corresponding .tiff files. 
	    * *DA_zip_for_ingest.m* is then executed, which creates ready-to-ingest zip files with .tiff/.xml pairs (see function description below for more information) Examples can be found in *run_DA_zip_for_ingest.m* or below:
            * ```cd('D:\Local\Digital-Archive-Tools\BulkTools')```  
			* ```DA_zip_for_ingest('H:\Digitization_Projects\WWII_Topographic_Maps\Italy\UofA WWII_Italy_Topos_50k\')```
		* Each zipped package is then manually imported into the Digital Archive using its bulk import tool.
    * [**NEW** method] In order to carry out the new method, a connection must be first made to a shared network folder on the Digital Archive server (dcs1.lib.mcmaster.ca). This can be prepared by Matt McCollow.
		* Run the function *DA_prepare_ingest.m*; this function moves corresponding pairs of .tiff and .xml files to the /ToIngest/ folder. Example:
			* ```cd('D:\Local\Digital-Archive-Tools\BulkTools')```
			* ```DA_prepare_ingest('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k');```
        * In the shared network folder, navigate to the /ToBeProcessed/ directory. If not already done, create a folder in this directory that is named after the macrepo number of its collection (e.g. a folder named "66660" is created for the Italy 1:25k topographic maps, since the collection's macrepo number is 66660 [http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A66660](http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A66660). 
			* All .tiff/.xml pairs should be copied from \ToIngest\ to the new directory (/ToBeProcessed/<macrepo>/) on the shared network folder. 
			* Once copying to the shared network folder has completed, move the copied items from \ToIngest\ to \ToIngest\Queued\ on the local drive.
	    * Notify Dorin to auto-process the items. Await confirmation that it is completed.
4. **Quality Control**: Ingested objects are inspected in the Digital Archive.
    * If an object passes inspection, its .tiff/.xml pair are moved out of \ToIngest\Queued\ to \Ingested\
	* If an object doesn't pass inspection (or doesn't exist in the digital archive). The inspector makes a note (e.g. in Trello), and the .tiff and .xml of the offending item are moved to the /ToFix/ folder

The following functions take metadata structured in a spreadsheet and prepares them for ingest into the Digital Archive. 

### DA_metadata_to_mods.m
Generates Digital-Archive upload-ready xml MODS files from a spreadsheet.
Spreadsheets are exported from https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk 
Run using *run_DA_metadata_to_mods.m*
- Sample output files can be found in \sample_files\MODS_FromSpreadsheet\

### zip_for_ingest.m
This function increments through all tif files in a directory. If a corresponding .xml file exists (i.e. same filename as the tif but extension = ".xml"), it will package these files with other groups in a manner that creates .zip archives that are ingestable into the Digital Archive via the bulk ingest tool (i.e. < 2 GB). 

### DA_prepare_ingest
This function identifies pairs of .tiff & .xml files and moves them to the /ToIngest/ folder. Corresponding pairs are moved to the /ToIngest/ folder, while any .tiff files without corresponding .xml files will remain in the top-level folder. A list of unmatched .tiffs is created in the top-level folder as **'unmatched_tiffs.csv**. This function also creates log files in /logs/

### run_DA_ingest
This run script brings together all bulk ingestion processes for each collection. It also contains a description of all processing steps, so can be used as a guide to the entire process.

## 3. Idealized directory structure for ingestion
Idealized directory structure: 
* \ (Top level): named after the collection, e.g. H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k
  * Contents include the all .tiff files to be ingested, as well as the downloaded .tsv metadata spreadsheet, metadata instructions, and any other directories containing .tiff files that are unique, different, or not to be ingested. 
  * \MODS\: Contains the .xml files generated by running *run_DA_metadata_to_mods.m*
  * \ToIngest\: .tiff files that have been packaged with .xml files and are ready to be ingested. Files are moved into this directory from the top-level directory by the function *DA_prepare_ingest.m*
    *\Queued\: Manual folder. Once .tiff/.xml pairs have been copied from ToIngest\ to DCS1 for bulk ingestion, they should be moved into /Queued so that they are not accidentally processed again.
  * \Ingested\: .tiff files that have been verified as ingested. Files are moved manually out of \Queued\ into this directory after having been inspected in the Digital Archive.
  * \ToFix\: Landing place for items that were processed by Dorin, but did not pass the QA process. Once items are fixed, the .tiff should be moved back to the top-level folder and the .xml returned to MODS or deleted and replaced.
  
## 4. Other Functions

### xml2struct.m
xml2struct takes either a java xml object, an xml file, or a string in xml format as input and returns a parsed xml tree in structure.
### aerialphoto_digarc_scraper.m
An old function used to crawl through URLs on the digital archive (by incrementing the macrepo numbers), parsing the HTML, and extracting the identifier and URL for only items in the air photo collection
### Bulk_Convert.m
Applies an imagemagick mogrify command to all items within a specified directory; typically used to resize and/or convert formats of images.
### rename_files.m
An old script used to bulk rename folders and files in a local/network directory

## 5. Other References
### SPARQL 
- The digital archive Fedora Resource Index Query Service can be accessed at http://dcs1.mcmaster.ca/fedora/risearch
- A Fedora SPARQL cookbook and other resources can be found [here](https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md)
