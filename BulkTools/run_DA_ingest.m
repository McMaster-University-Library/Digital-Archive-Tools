

%% Processing GermanyHollandPoland_25k
cd('D:\Local\Digital-Archive-Tools\BulkTools')
top_path = 'H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\';
%%% Step 1: Download a tab-separated spreadsheet (.tsv) of the appropriate tab in
%%% the metadata Google Sheet (https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk)
%%% to the top-level folder for this collection (as indicated by top_path).

%%% Step 2: Process the metadata Sheet with DA_metadata_to_mods, to create separate MODS xml files for each row in the sheet
%%% Second argument is the name of the downloaded .tsv metadata file (step 1)
%%% Function will create /MODS/ folder in the top-level directory (if necessary), 
%%% and generate separate .xml files for each row in the spreadsheet. Files are placed in the /MODS/ directory.
DA_metadata_to_mods(top_path,'Digital Archive - Bulk Metadata Templates - UofA_WW2_GermanyHollandPoland_25k_topos.tsv');

%%% Step 3: Run DA_prepare_ingest to identify pairs of .tiff & .xml files,
%%% and move to the /ToIngest/ folder. 
%%% Corresponding pairs are moved to the /ToIngest/ folder. 
%%% Any .tiff files without corresponding .xml files will remain in the
%%% top-level folder. A list of unmatched .tiffs is created in the
%%% top-level folder as 'unmatched_tiffs.csv'
%%% This function also creates log files in /logs/
cd('D:\Local\Digital-Archive-Tools\BulkTools')
DA_prepare_ingest('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k');

%%% Step 3b (Manual): Copy the contents of \ToIngest\ to the new directory (/ToBeProcessed/<macrepo>/) on the shared network folder
%%% Step 3c (Manual): Once copying to the shared network folder has completed, move the copied items from \ToIngest\ to \ToIngest\Queued\
%%% Step 3d (Manual): Notify Dorin to auto-process the items. Await confirmation that it is completed.

%%% Step 4: Move the ingested objects into the /Ingested folder. 
%%% The function DA_move_ingested.m moves verified ingested files from the \ToIngest\Queued\
%%% directory to the \Ingested\ directory. 
%%% The input file for this function is a single-column .csv file created
%%% from the fedora RIQS and formatted using this sheet: https://docs.google.com/spreadsheets/d/1GbFjUKtuc8bU2qK5CkAmdaKKlHDSoskw6uaInNMD6Hg/edit#gid=1862350458
%%% Notes on Fedora RIQS commands: https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md
%%% RIQS http://dcs1.mcmaster.ca/fedora/risearch
%%% NOTE that the input file is assumed to exist in \Ingested\
% DA_move_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested.csv')
DA_check_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested_all.csv')

%%% Step 5: Inspect the ingested objects in the Digital Archive

%%% > If an object doesn't pass inspection (or doesn't exist in the digital archive). The inspector makes a note (e.g. in Trello), and the .tiff and .xml of the offending item are moved to the /ToFix/ folder
%% Processing UofA Italy 1:25k
cd('D:\Local\Digital-Archive-Tools\BulkTools')
top_path = 'H:\Digitization_Projects\WWII_Topographic_Maps\Italy\UofA WWII_Italy_Topos_25k\';
%%% Step 1: Download a tab-separated spreadsheet (.tsv) of the appropriate tab in
%%% the metadata Google Sheet (https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk)
%%% to the top-level folder for this collection (as indicated by top_path).

%%% Step 2: Process the metadata Sheet with DA_metadata_to_mods, to create separate MODS xml files for each row in the sheet
%%% Second argument is the name of the downloaded .tsv metadata file (step 1)
%%% Function will create /MODS/ folder in the top-level directory (if necessary), 
%%% and generate separate .xml files for each row in the spreadsheet. Files are placed in the /MODS/ directory.
DA_metadata_to_mods(top_path,'Digital Archive - Bulk Metadata Templates - UofA_WW2_Italy_25k_topos.tsv');

%%% Step 3: Run DA_prepare_ingest to identify pairs of .tiff & .xml files,
%%% and move to the /ToIngest/ folder. 
%%% Corresponding pairs are moved to the /ToIngest/ folder. 
%%% Any .tiff files without corresponding .xml files will remain in the
%%% top-level folder. A list of unmatched .tiffs is created in the
%%% top-level folder as 'unmatched_tiffs.csv'
%%% This function also creates log files in /logs/
cd('D:\Local\Digital-Archive-Tools\BulkTools')
DA_prepare_ingest(top_path);

%%% Step 3b (Manual): Copy the contents of \ToIngest\ to the new directory (/ToBeProcessed/<macrepo>/) on the shared network folder
%%% Step 3c (Manual): Once copying to the shared network folder has completed, move the copied items from \ToIngest\ to \ToIngest\Queued\
%%% Step 3d (Manual): Notify Dorin to auto-process the items. Await confirmation that it is completed.

%%% Step 4: Move the ingested objects into the /Ingested folder. 
%%% The function DA_move_ingested.m moves verified ingested files from the \ToIngest\Queued\
%%% directory to the \Ingested\ directory. 
%%% The input file for this function is a single-column .csv file created
%%% from the fedora RIQS and formatted using this sheet: https://docs.google.com/spreadsheets/d/1GbFjUKtuc8bU2qK5CkAmdaKKlHDSoskw6uaInNMD6Hg/edit#gid=1862350458
%%% Notes on Fedora RIQS commands: https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md
%%% RIQS http://dcs1.mcmaster.ca/fedora/risearch
%%% NOTE that the input file is assumed to exist in \Ingested\
% DA_move_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested.csv')
DA_check_ingested(top_path,'ingested_all.csv')

%%% Step 5: Inspect the ingested objects in the Digital Archive

%%% > If an object doesn't pass inspection (or doesn't exist in the digital archive). The inspector makes a note (e.g. in Trello), and the .tiff and .xml of the offending item are moved to the /ToFix/ folder

%% Processing OCUL Topos 1:25k
cd('D:\Local\Digital-Archive-Tools\BulkTools')
top_path = 'H:\Digitization_Projects\OCUL_HTDP_25K\';
%%% Step 1: Download a tab-separated spreadsheet (.tsv) of the appropriate tab in
%%% the metadata Google Sheet (https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk)
%%% to the top-level folder for this collection (as indicated by top_path).

%%% Step 2: Process the metadata Sheet with DA_metadata_to_mods, to create separate MODS xml files for each row in the sheet
%%% Second argument is the name of the downloaded .tsv metadata file (step 1)
%%% Function will create /MODS/ folder in the top-level directory (if necessary), 
%%% and generate separate .xml files for each row in the spreadsheet. Files are placed in the /MODS/ directory.
DA_metadata_to_mods(top_path,'Digital Archive - Bulk Metadata Templates - OCUL_HTDP_25k.tsv');

%%% Step 3: Run DA_prepare_ingest to identify pairs of .tiff & .xml files,
%%% and move to the /ToIngest/ folder. 
%%% Corresponding pairs are moved to the /ToIngest/ folder. 
%%% Any .tiff files without corresponding .xml files will remain in the
%%% top-level folder. A list of unmatched .tiffs is created in the
%%% top-level folder as 'unmatched_tiffs.csv'
%%% This function also creates log files in /logs/
cd('D:\Local\Digital-Archive-Tools\BulkTools')
DA_prepare_ingest(top_path);

%%% Step 3b (Manual): Copy the contents of \ToIngest\ to the new directory (/ToBeProcessed/<macrepo>/) on the shared network folder
%%% Step 3c (Manual): Once copying to the shared network folder has completed, move the copied items from \ToIngest\ to \ToIngest\Queued\
%%% Step 3d (Manual): Notify Dorin to auto-process the items. Await confirmation that it is completed.

%%% Step 4: Move the ingested objects into the /Ingested folder. 
%%% The function DA_move_ingested.m moves verified ingested files from the \ToIngest\Queued\
%%% directory to the \Ingested\ directory. 
%%% The input file for this function is a single-column .csv file created
%%% from the fedora RIQS and formatted using this sheet: https://docs.google.com/spreadsheets/d/1GbFjUKtuc8bU2qK5CkAmdaKKlHDSoskw6uaInNMD6Hg/edit#gid=1862350458
%%% Notes on Fedora RIQS commands: https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md
%%% RIQS http://dcs1.mcmaster.ca/fedora/risearch
%%% NOTE that the input file is assumed to exist in \Ingested\
% DA_move_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested.csv')
DA_check_ingested(top_path,'ingested_all.csv')

%%% Step 5: Inspect the ingested objects in the Digital Archive

%%% > If an object doesn't pass inspection (or doesn't exist in the digital archive). The inspector makes a note (e.g. in Trello), and the .tiff and .xml of the offending item are moved to the /ToFix/ folder

%%% Step 6: Prepare goereferencing items for ingest
cd('D:\Local\Digital-Archive-Tools\BulkTools')
DA_make_georef_matls(top_path,'ingested_all.csv')

%% Processing OCUL Topos 1:63k
cd('D:\Local\Digital-Archive-Tools\BulkTools')
top_path = 'H:\Digitization_Projects\OCUL_HTDP_63K\';
%%% Step 1: Download a tab-separated spreadsheet (.tsv) of the appropriate tab in
%%% the metadata Google Sheet (https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk)
%%% to the top-level folder for this collection (as indicated by top_path).

%%% Step 2: Process the metadata Sheet with DA_metadata_to_mods, to create separate MODS xml files for each row in the sheet
%%% Second argument is the name of the downloaded .tsv metadata file (step 1)
%%% Function will create /MODS/ folder in the top-level directory (if necessary), 
%%% and generate separate .xml files for each row in the spreadsheet. Files are placed in the /MODS/ directory.
DA_metadata_to_mods(top_path,'Digital Archive - Bulk Metadata Templates - OCUL_HTDP_63k.tsv');

%%% Step 3: Run DA_prepare_ingest to identify pairs of .tiff & .xml files,
%%% and move to the /ToIngest/ folder. 
%%% Corresponding pairs are moved to the /ToIngest/ folder. 
%%% Any .tiff files without corresponding .xml files will remain in the
%%% top-level folder. A list of unmatched .tiffs is created in the
%%% top-level folder as 'unmatched_tiffs.csv'
%%% This function also creates log files in /logs/
cd('D:\Local\Digital-Archive-Tools\BulkTools')
DA_prepare_ingest(top_path);

%%% Step 3b (Manual): Copy the contents of \ToIngest\ to the new directory (/ToBeProcessed/<macrepo>/) on the shared network folder
%%% Step 3c (Manual): Once copying to the shared network folder has completed, move the copied items from \ToIngest\ to \ToIngest\Queued\
%%% Step 3d (Manual): Notify Dorin to auto-process the items. Await confirmation that it is completed.

%%% Step 4: Move the ingested objects into the /Ingested folder. 
%%% The function DA_move_ingested.m moves verified ingested files from the \ToIngest\Queued\
%%% directory to the \Ingested\ directory. 
%%% The input file for this function is a single-column .csv file created
%%% from the fedora RIQS and formatted using this sheet: https://docs.google.com/spreadsheets/d/1GbFjUKtuc8bU2qK5CkAmdaKKlHDSoskw6uaInNMD6Hg/edit#gid=1862350458
%%% Notes on Fedora RIQS commands: https://github.com/jasonbrodeur/Fedora-SPARQL/blob/master/fedora-sparql-cookbook.md
%%% RIQS http://dcs1.mcmaster.ca/fedora/risearch
%%% NOTE that the input file is assumed to exist in \Ingested\
% DA_move_ingested('H:\Digitization_Projects\WWII_Topographic_Maps\GermanyHollandPoland_25k\','ingested.csv')
DA_check_ingested(top_path,'ingested_all.csv')

%%% Step 5: Inspect the ingested objects in the Digital Archive

%%% > If an object doesn't pass inspection (or doesn't exist in the digital archive). The inspector makes a note (e.g. in Trello), and the .tiff and .xml of the offending item are moved to the /ToFix/ folder

%%% Step 6: Prepare goereferencing items for ingest
cd('D:\Local\Digital-Archive-Tools\BulkTools')
DA_make_georef_matls(top_path,'ingested_all.csv')
%%% Copy contents of \ToIngest_Georef to dcs.lib.mcmaster.ca\GCP and move to Queued