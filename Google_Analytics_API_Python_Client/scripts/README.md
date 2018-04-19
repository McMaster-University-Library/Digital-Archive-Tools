## Folder: Google Analytics API Python Client

**_Navigate to this folder [here](https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/Google_Analytics_API_Python_Client/scripts) or at Google_Analytics_API_Python_Client --> scripts_**

### Tool: GA_Filter.py

Using Python 2.7.8, this script performs a Google Analytics query to obtain the page title, number of users, and number of page views for each MacRepo ID within the Library's Maps Collections. This data is stored in a temporary output file in CSV, labelled GA_Data.csv.

### Tool: GA_CreateReport.py

Using Python 2.7.8, Google Analytics data in GA_Data.csv is parsed and formatted into a readable CSV format. Additional information for each web page is also appended, including a sub-collection or item flag, identifier, and parent directory for each MacRepo ID of the Library's Maps Collections. Two output Google Analytics Report files are created; one for  all sub-collections and items within the Library's Map Collections labelled GA_ReportYYYYMMDD and one for the top-level sub-collections within the Library's Map Collections labelled GA_CollectionsReportYYYYMMDD, with YYYYMMDD as the report creation date. With batch files then created for 7daysAgo, 30daysAgo, and 365daysAgo web data time spans, Windows Task Scheduler was set up to run a 30daysAgo and 365daysAgo report at the end of every month. Note that each of these scripts take a minimum of 24 hours or more to run. For this reason, each script is scheduled at least two days apart from the other.

### Resource: Google Analytics Reports

The reports are organized by the durations for which web data is captured. For our purposes, weekly, monthly, and yearly reports are created. Each report contains the MacRepo ID, number of users, number of page views, sub-collection or item flag, identifier, and parent directory for each MacRepo ID of the Library's Maps Collections. These reports may be found in the following folders.

**[7daysAgo](https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/Google_Analytics_API_Python_Client/scripts/7daysAgo)**
**[30daysAgo](https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/Google_Analytics_API_Python_Client/scripts/30daysAgo)**
**[365daysAgo](https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/Google_Analytics_API_Python_Client/scripts/365daysAgo)**

### Resource: Exploring Google Analytics

This text file contains key documentation in navigating the Google Analytics dashboard for McMaster University Library users.

### *A Guide to The Project's Initial Creation*

The following instructions are a guide on how to first set-up Python and the Google Analytics reporting API, then edit the Python scripts within this folder to create a CSV report on the reported data.

	1. The link below is a guide on setting up the Google Analytics API for the first time.
	
	Follow steps 1-4 within the link below to:
	- Download and install Python 2.7 on your computer.
	- Install the Google API Python Client to your computer.
		- If the pip module is not installed, download get-pip.py here: https://bootstrap.pypa.io/get-pip.py. 
		- Install the pip module by running the downloaded get-pip.py script.
	- Create a new Google Analytics API Project.
	
	http://www.ryanpraski.com/google-analytics-reporting-api-python-tutorial/
	
	2. Download the Google Analytics API Python Client folder.
	Follow the link to the full code repository on GitHub. Download the 'Google_Analytics_API_Python_Client' folder to your C:\ drive.
	
	https://github.com/maclibGIS/Digital-Archive-Tools/tree/master/Google_Analytics_API_Python_Client
	
	3. Add Your Google Analytics API Client Secret Credentials.
	In the Google_Analytics_API_Python_Client folder, open the scripts folder.
	
	\Google_Analytics_API_Python_Client\scripts
	
	Open the client_secrets.json file in a text editor such as NotePad++. Delete all the text in this client_secret.json file. Find the client_secret.json file that you created and downloaded from the Google Developer console. Open your client_secret.json file in NotePad++ and copy the text in your file (this has your API credentials) and paste the text into the sample client_secrets.json file that was in the scripts folder. Make sure to save the file.

	4. Obtain your View ID (also called Profile ID) from the Google Analytics Core Reporting API Query Explorer.
	
	Follow this link to the Google Analytics Core Reporting Query Explorer.
	https://ga-dev-tools.appspot.com/query-explorer/
	
	Choose the Account, Property and View you’d like to get data from. When you select a view the 'ids' field will be populated with the unique Google Analytics View (Profile) ID. You can also find your View (profile) ID in the ADMIN section of Google Analytics' web interface (https://www.google.com/analytics/web/) under View Settings in your specific view.
	
	5. Google Analytics API Python Query Data Output to Excel.
	
	Open GA_Filter.py and choose edit with IDLE. Edit the script at the 4 prompts to change file path names,file names, and the View or Profile ID you obtained from the previous step.
	Open GA_CreateReport.py and choose edit with IDLE. Edit the script at the 3 prompts to change file path names and file names.
	
	Note: Each report file name is of the form 'GA_ReportYYYYMMDD.csv' with the date on which the query was performed.
	

The steps below are a guide on how to set up GA_CreateReport to run within Windows Task Scheduler.
	
	6. The Google_Analytics_API_Python_Client folder should be located within your local C:\ drive. If it is not, copy it into any folder within the C:\ drive. Make sure that all file paths within GA_Filter and GA_CreateReport refer to the correct directory.
	
	7. Edit the batch file labelled "GA_CreateReport_30daysAgo" with Notepad ++. Change the directory in the second line to the directory in which the batch file is contained.
	
	8. Follow the link below to instructions on creating a scheduled task within Windows Task Scheduler. Choose the .bat file  "GA_CreateReport_30daysAgo" as the program/script to run. You may edit this file if you wish to change the start date of your Google Analytics Query, or you may use the existing 3 batch files already created within the "...\Google_Analytics_API_Python_Client\scripts" folder.
	
	http://www.thewindowsclub.com/how-to-schedule-batch-file-run-automatically-windows-7
	
	Note: When selecting security options, choose 'Run whether user is logged on or not.
	Note: Since each report creation script takes at least 24 hours to run, ensure that a minimum of two days is allocated between scheduled scripts.
	Note: In the case that the user account chosen to run the task does not have administrative privileges, follow this link to give that user 'Log on as Batch Job' Rights.
	https://www.smartftp.com/support/kb/how-to-give-a-user-log-on-as-a-batch-job-rights-f2691.html