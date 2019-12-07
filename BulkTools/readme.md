# Digital-Archive-Tools/BulkTools - Process and function documentation
This subdirectory contains Matlab functions used to perform bulk actions on items for (or from) the Digital Archive. Each function and their associated processes are described below. This guide and associated files can be found at [https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/BulkTools](https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/BulkTools).

## 1. Spreadsheet to Digital Archive - Methods and functions
Bulk uploading from a local filesystem to the Digital Archive can be done in a couple of ways. Regardless of approach, it is necessary to produce pairs of files for each object to be ingested. The pair consists of an image file and a corresponding xml metadata file.  
Our approach is as follows (a scripted overview of the process can be found in **run_DA_ingest.m**): 

1. In the top-level folder for the collection of interest (e.g. H:\Digitization_Projects\WWII_Topographic_Maps\Italy\UofA WWII_Italy_Topos_50k\), create the directory structure that is suggested in Section 2 (below). 

2. **Creating metadata records**: Bulk metadata records are created via a [Google spreadsheet](https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk).  2. Records for each collection are created in separate tabs of the sheet. When a new collection is being described, a new tab is created by duplicating the "Template - DO NOT EDIT - Duplicate for new" tab, and renaming appropriately. 

3. **Generating individuals metadata files**: When MODS metadata files need to be produced, the following steps should be taken: 
    * The tab of interest in the metadata Google Sheet should be downloaded as a tab-separated file (.tsv) to the top-level local folder of the collection (i.e. the same place where scanned .tiff images are placed).
    * Run **DA_metadata_to_mods.m**, which generates Digital-Archive upload-ready xml MODS files from the downloaded metadata spreadsheet (.tsv). As an example:
        * ```cd('D:\Local\Digital-Archive-Tools\BulkTools')```  
	    * ```DA_metadata_to_mods('H:\Digitization_Projects\WWII_Topographic_Maps\Italy\UofA WWII_Italy_Topos_50k\','Bulk Metadata Templates - UofA_WW2_Italy_50k_topos.tsv');```  
	    * Running these lines results in the creation of a /MODS/ folder in the top-level directory, and the generation of separate .xml files for each row in the spreadsheet.  

4. **Preparing for bulk ingest**: 
    * [**OLD** method] In this method, .xml files from the /MODS/ directory are copied (manually) to the top-level folder, so that they appear alongside their corresponding .tiff files. 
	    * **DA_zip_for_ingest.m** is then executed, which creates ready-to-ingest zip files with .tiff/.xml pairs (see function description below for more information) Examples can be found in *run_DA_zip_for_ingest.m* or below:
            * ```cd('D:\Local\Digital-Archive-Tools\BulkTools')```  
			* ```DA_zip_for_ingest('H:\Digitization_Projects\WWII_Topographic_Maps\Italy\UofA WWII_Italy_Topos_50k\')```
		* Each zipped package is then manually imported into the Digital Archive using its bulk import tool.
    * [**NEW** method] In order to carry out the new method, a connection must be first made to a shared network folder on the Digital Archive server (dcs1.lib.mcmaster.ca). This can be prepared by Matt McCollow.
		* Run the function **DA_prepare_ingest.m**; this function moves corresponding pairs of .tiff and .xml files to the /ToIngest/ folder. Example:
			* ```cd('D:\Local\Digital-Archive-Tools\BulkTools')```
			* ```DA_prepare_ingest('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k');```
        * In the shared network folder, navigate to the /ToBeProcessed/ directory. If not already done, create a folder in this directory that is named after the macrepo number of its collection (e.g. a folder named "66660" is created for the Italy 1:25k topographic maps, since the collection's macrepo number is 66660 [http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A66660](http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A66660). 
			* All .tiff/.xml pairs should be copied from \ToIngest\ to the new directory (/ToBeProcessed/<macrepo>/) on the shared network folder. 
			* Once copying to the shared network folder has completed, move the copied items from \ToIngest\ to \ToIngest\Queued\ on the local drive.
	    * Items in the /ToBeProcessed/ directory are processed automatically at 6 pm on weekday evenings. 
			* Processed items are moved to the /Processed/ directory in the shared network folder. Log files are found in the /Confirmation/ directory.

5. **Moving ingested items**
	* An output of all files ingested into a given collection is extracted using the Fedora RIQS (http://dcs1.mcmaster.ca/fedora/risearch), and the query given in Jay's [Fedora SPARQL Cookbook](https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md#example-2-display-list-of-all-active-non-deleted-items-in-a-collection-along-with-derivatives-good-for-checking)
	* Using the aforementioned csv as an input, the function **DA_check_ingested.m** performs quality control on the items and moves QA-passing ingested files from the \ToIngest\Queued\ directory to the \Ingested\ directory. E.g. 
		* ```DA_check_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested.csv')```
	* If an item doesn't pass QA, it will be listed in the output file **\ToFix\ToFix.csv**
		
6. **Human Quality Control**: QA-failing objects are inspected
	* If an item needs to be reingested, delete the item in the digital archive and move the .tif/.xml pair back to the /ToIngest/ folder.
	* If you're able to fix it in the Digital Archive (e.g. by re-uploading / regenerating), move the .tif/.xml pair to the /Ingested/ folder

7. **Preparing georeferencing materials for ingest
	* The following georeferencing products may be ingested into the Digital Archive alongside TIFF files, though is done after the TIFF file has already been ingested. 
		* **GCP file:** Ground Control Point (GCP) file, to be used to georeference a TIFF image in QGIS. GCP files should be collected in the /GCP/ folder of the top-level directory. GCP files should have the same filename as the corresponding TIFF file, with the extension of '.points' added. E.g. a TIFF file example.tiff would have a corresponding GCP file example.points. 
		* **README file:** Contains coordinate reference system information and instructions on how to georeference the original image. Readme files should be collected in the /README/ folder of the top-level directory. Readme files can be generated using the function *DA_make_readme.m*, which is called from *DA_make_georef_matls.m* as part of automated processing work.
		* **ISO19115 file(optional):** ISO19115 metadata file in XML format. 
	* Georeferencing products can be created automatically using the function *DA_make_georef_matls.m*, found in the /georeferencing-tools/ subdirectory of this github repo. The function has the following requirements: 
		* An extract of all items in the collection of interest must be created following the process described in item 4 above. 
		* GCP files must have been created and saved to the /GCP/ folder of the top-level directory. Note that for some collections, GCP files can be extracted from georeferenced tiffs using the function *extract_gcps.m* in the /georeferencing-tools/ subdirectory of this github repo. 
		* Readme files can be generated using the function *DA_make_readme.m*, which is called from *DA_make_georef_matls.m*. This process requires a csv file listing the item's identifier and a text string indicating the corresponding CRS for that item. See the example file in this github repo (CRS_lookup_example.csv).
	* What DA_make_georef_matls.m* does:  
		* In cases where the function finds ingested GCP/README/ISO19115 files in the Digital Archive, it attempts to move these items out of /ToIngest_Georef/Queued/ to /Ingested/
		* When GCP/README/ISO19115 files are not found in the Digital Archive (but TIFF and MODS files are present), the function attempts to copy GCPs files (from /GCP), ISO19115 files (from /ISO19115), and README files (from /README) to the /ToIngest_Georef/ folder.
			* If no README file is found, the function calls *DA_make_readme.m* to create the readme file. 
		* All files added to /ToIngest_Georef/ should be copied to the approapriate folder (/GCP, /ISO19115, /README) in the /GCP/subdirectory of the remote machine (dcs.lib.mcmaster.ca). These will be processed every weeknight at 6pm. Once files are copied, the files in /ToIngest_Georef/ should be manually moved to /ToIngest_Georef/Queued/.

The following functions take metadata structured in a spreadsheet and prepares them for ingest into the Digital Archive. 

### DA_metadata_to_mods.m
Generates Digital-Archive upload-ready xml MODS files from a spreadsheet.
Spreadsheets are exported from https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk 
Run using *run_DA_metadata_to_mods.m*
- Sample output files can be found in \sample_files\MODS_FromSpreadsheet\

### zip_for_ingest.m
This function increments through all tif files in a directory. If a corresponding .xml file exists (i.e. same filename as the tif but extension = ".xml"), it will package these files with other groups in a manner that creates .zip archives that are ingestable into the Digital Archive via the bulk ingest tool (i.e. < 2 GB). 

### DA_prepare_ingest
This function identifies pairs of .tiff & .xml files and moves them to the /ToIngest/ folder. Corresponding pairs are moved to the /ToIngest/ folder, while any .tiff files without corresponding .xml files will remain in the top-level folder. A list of unmatched .tiffs is created in the top-level folder as *unmatched_tiffs.csv*. This function also creates log files in /logs/

### run_DA_ingest
This run script brings together all bulk ingestion processes for each collection. It also contains a description of all processing steps, so can be used as a guide to the entire process.

## 2. Idealized directory structure for digitization and bulk ingestion
Idealized directory structure: 
* \ (Top level): named after the collection, e.g. H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\GermanyHollandPoland_25k
  * Contents include the all .tiff files to be ingested, as well as the downloaded .tsv metadata spreadsheet, metadata instructions, and any other directories containing .tiff files that are unique, different, or not to be ingested. 
  * \MODS\: Contains the .xml files generated by running *run_DA_metadata_to_mods.m*
  * \ToIngest\: .tiff files that have been packaged with .xml files and are ready to be ingested. Files are moved into this directory from the top-level directory by the function *DA_prepare_ingest.m*
    *\Queued\: Manual folder. Once .tiff/.xml pairs have been copied from ToIngest\ to DCS1 for bulk ingestion, they should be moved into /Queued so that they are not accidentally processed again.
  * \Ingested\: .tiff files that have been verified as ingested. Files are moved manually out of \Queued\ into this directory after having been inspected in the Digital Archive.
  * \ToFix\: Landing place for items that were processed by Dorin, but did not pass the QA process. Once items are fixed, the .tiff should be moved back to the top-level folder and the .xml returned to MODS or deleted and replaced.

| Collection        | Collection Macrepo Number       | H:\ Location  |
| ------------- |-------------:| -----|
|UofA Italy 1:50k Topographic Maps | 84411 |H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\UofA WWII_Italy_Topos_50k\|
|UofA Italy 1:25k Topographic Maps | 66660 | H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\UofA WWII_Italy_Topos_25k\ |
| Europe, Central 1:25k Topographic Maps (GermanyHollandPoland) | 85282 | H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\GermanyHollandPoland_25k\ |
|LCMSDS Defence Overprints|86603|H:\Digitization_Projects\WWII_Topographic_Maps\LCMSDS\|
|Ontario Historical Topographic Maps - 1:63360|87642|H:\Digitization_Projects\OCUL_HTDP_63K\|
|Ontario Historical Topographic Maps - 1:25000|88343|H:\Digitization_Projects\OCUL_HTDP_25K\|
|Japan City Plans 1:12,500 |87641|H:\Digitization_Projects\WWII_CityPlans\CityPlans_Japan\|
|WW2_Geologic_France_80k |88593|H:\Digitization_Projects\WWII_Geologic_Maps\Geologic_France_80k\|
|WW2_France_50k_GSGS4250|88988|H:\Digitization_Projects\WWII_Topographic_Maps\France_Belgium_Holland\France_50k_GSGS4250\|
|WW2_France_50k_GSGS4040|88989|H:\Digitization_Projects\WWII_Topographic_Maps\France_Belgium_Holland\France_50k_GSGS4040\|
|UofA_WW2_Crete_50k_topos|88992|H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\UofA_WW2_Crete_50k\|
|UofA_USSR_100k|91926|H:\Digitization_Projects\WWII_Topographic_Maps\U_of_Alberta\UofA_USSR_100k|


## 3. Functions for extracting items from the Digital Archive to a spreadsheet or directory
A number of functions have been created to pull metadata records or files (images, etc.) from the Digital Archive and place them in local files (or a collective spreadsheet of records). These functions are described below.

## 4. Checking ingested contents (QA processes)

1. Return a list of all ingested items in a collection
- Navigate to the Fedora Resource Index Query Service: http://dcs1.mcmaster.ca/fedora/risearch
- Run a SPARQL query to return all items that belong to a given collection
  - See the [first example](https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md#example-1-display-list-of-all-active-non-deleted-items-in-a-collection) in Jay's Fedora-SPARQL Cookbook for an example
  - Set **Language** to *sparql*
  - Set **Response** to *CSV*
  - Set **Limit** to *Unlimited*

2. Paste results into the first column of the [Formatter Tab](https://docs.google.com/spreadsheets/d/1GbFjUKtuc8bU2qK5CkAmdaKKlHDSoskw6uaInNMD6Hg/edit#gid=0) of the Ingestion Tracking Sheet
- 


### DA_bulk_downloader.m
This function takes a list of macrepo numbers as input, and downloads the selected file type for each digital archive item. Downloadable types include '.tiff'; '.jp2'; '.jpeg'; '.xml'
When the argument file_ext is set to '.xml', it performs a bulk download of xml MODS files for a given list of items in the Digital Archive (list given as a csv of macrepo numbers)
Sample usage: DA_bulk_downloader('H:\Map_Office\Projects\19thc_maps_surveys\','H:\Map_Office\Projects\19thc_maps_surveys\macrepo_list.csv')
- Operate this function using **run_DA_bulk_downloader**.
- A sample input file can be found at \sample_files\macrepo_list.csv
- Sample output files are found in \sample_files\MODS_FromDA

### DA_mods_to_metadata.m
Loads all MODS xml file located in a /MODS folder of a specified directory, reformats all metadata to a single table with one row per file, and one column per unique metadata element. Exports in tab-separated format. 
- Operate this function using **run_DA_mods_to_metadata**.
- **NOTE:** DA_mods_to_metadata should be run after DA_bulk_downloader generates xml files.
- Sample output file is found at: \sample_files\metadata_out.txt
  
## 5. Adding Georeferencing Products

1. Add tif and xml files to the appropriate subfolder (named after the macrepo number of the collection in the digital archive) of the ToBeProcessed folder in dcs1.lib.mcmaster.ca
2. Following ingest, run a SPARQL query to extract all items that belong to the digital archive collection of interest
  - pull out a table with | identifier | macrepo # |
  - for all items that need GCP/readme files to be processed, rename the files to preprend '<macrepo #>_' to the filename. 
3. Copy all renamed georeferencing files to the same subfolder as Step 1. 

  
## 6. Other functions

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
