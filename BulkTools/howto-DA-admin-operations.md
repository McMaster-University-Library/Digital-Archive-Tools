# Important Notes
- To batch import, images must be zipped together with their corresponding xml metadata files.
- Zipped files must be less than 2 GB in size.

  
# Process
- Ensure you're logged in to the Digital Archive http://digitalarchive.mcmaster.ca/user
## Batch Import:
- Navigate to the target collection (folder)
- Click on **Manage**
- Click on **Collection** tab
- Click on **Batch Import Objects**
- Select the required zip file and upload it. 
-- Select **Islandora Large Image Content Model**
-- For namespace, select **macrepo**
--Click **Import**

## Deleting items
- Navigate to the item that you want to delete
- Click on **Manage**
- Click on **Properties** tab
- Change the state to **Deleted**
- Click on **Update Properties**

## Missing Image derivatives
- Click on **Manage**
- Click on **Datastreams** tab
- If object exists:
-- Click **Properties** tab
-- Click **Regenerate all Derivatives**
- Move TIF/XML from H: Digitization Projects/ON_LakeMaps to  H: Digitization Projects/ON_LakeMaps/ingested
- Delete TIF/XML from zipfile
-- use 7zip

## Replacing Metadata
Instructions on replacing metadata files for already-ingested items in the Digital Archive:

## Log in
- Ensure you're logged in to the Digital Archive http://digitalarchive.mcmaster.ca/user
- If you've logged in but don't see the "View | Manage" tabs for an item, try replacing "https:" in the URL with "http:"

## Upload new metadata file
(This assumes that a new metadata XML file has been created)
- Navigate to the item in the digital archive
- If logged in, you should see tabs: "View | Manage" -- select the **Manage** tab
- In the Manage window, select the **Datastreams** sub-tab
- For the MODS record, click **replace**
- Choose the new XML file and upload it. 
- Verify that the process applies correctly. 
