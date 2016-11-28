# Digital-Archive-Tools
Tools to use with the McMaster Digital Archive.

# Tool: Google_Analytics_API_Python_Client

Using Python 2.7.8, the contents within Google_Analytics_API_Python_Client pulls Google Analytics query data
directly into Excel to write a CSV file containing the Google Analytics data. Particularly in GA_Filter, 
the script performs a query to report the page title, number of users, and pageviews for each webpage in the
Maps collection of McMaster's Digital Archives. In addition, the same information is gathered for the multiple 
timespans of the last 30 days, the last 7 days, and the last day. The following instructions are a guide on 
how to first setup Python and the Google Analytics reporting API, then edit the Python scripts within this 
folder to create a CSV report on the reported data.

	1. The link below is a guide on setting up the Google Analytics API for the first time.
	
	Follow steps 1-4 to:
	- Download and install Python on your computer.
	- Install the Google API Python Client to your computer.
	- Create a new Google Analytics API Project.
	
	http://www.ryanpraski.com/google-analytics-reporting-api-python-tutorial/
	
	2. Download the Google Analytics API Python Client folder.
	Follow the link to the full code repository on GitHub. Download the 'Google_Analytics_API_Python_Client'
	folder to your computer.
	
	*LINK*
	
	3. Add Your Google Analytics API Client Secret Credentials.
	In the Google_Analytics_API_Python_Client folder, open the scripts folder.
	
	\Google_Analytics_API_Python_Client\scripts
	
	Open the client_secrets.json file in a text editor such as NotePad++. Delete all the text in this
	client_secret.json file. Find the client_secret.json file that you created and downloaded from the Google 
	Developer console. Open your client_secret.json file in NotePad++ and copy the text in your file 
	(this has your API credentials) and paste the text into the sample client_secrets.json file that was in 
	the scripts folder. Make sure to save the file.

	4. Obtain your View ID, also called Profile ID from the Google Analytics Core Reporting API Query Explorer.
	
	Follow this link to the Google Analytics Core Reporting Query Explorer.
	https://ga-dev-tools.appspot.com/query-explorer/
	
	Choose the Account, Property and View you’d like to get data from. When you select a view the 'ids' field 
	will be populated with the unique Google Analytics View (Profile) ID. You can also find your View (profile) 
	ID in the ADMIN section of Google Analytics' web interface (https://www.google.com/analytics/web/) under 
	View Settings in your specific view.
	
	5. Google Analytics API Python Query Data Output to Excel