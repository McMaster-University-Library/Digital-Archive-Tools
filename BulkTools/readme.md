# Digital-Archive-Tools/BulkTools
This subdirectory contains Matlab functions used to perform bulk actions on items for (or from) the Digital Archive. Each function is described below

### DA_bulk_download_mods.m
Performs a bulk download of xml MODS files for a given list of items (list given as a csv of macrepo numbers)
Sample usage: DA_bulk_download_mods('H:\Map_Office\Projects\19thc_maps_surveys\','H:\Map_Office\Projects\19thc_maps_surveys\macrepo_list.csv')

### DA_mods_to_metadata.m
Loads all MODS xml file located in a the /MODS folder of a specified directory, reformats all metadata to a single table with one row per file, and one column per unique metadata element. Exports in tab-separated format. Operate this function using *run_DA_mods_to_metadata*.
**NOTE:** DA_mods_to_metadata should be run after DA_bulk_download_mods generates xml files.
### 