# THIS SCRIPT RUNS GA_Filter.py. WHICH PULLS DATA FROM THE GOOGLE ANALYTICS REPORTING API.
# IT THEN TAKES THE RAW OUTPUT STORED IN A CSV FILE TO CREATE A READABLE CSV REPORT.
# CURRENTLY, THE SCRIPT ONLY WORKS ON PYTHON 2 DUE TO VERSION-UNIQUE LIBRARIES AND COMMANDS.

# THIS SCRIPT USES THE STORED GOOGLE ANALYTICS DATA WITHIN GA_Data.csv AS INPUTS.
# IN ADDITION, IT TAKES THE INPUT 'startdate', DENOTING THE BEGINNING DATE FROM WHICH GOOGLE TAKES
# ITS QUERY DATA. ITS END DATE IS THE DATE THE QUERY IS EXECUTED.
# THE OUTPUT DATA WILL BE IN A TABLE IN CSV FORMAT. IT WILL CONTAIN (for each unique webpage):
# MACREPO ID; WEBSITE URL; PAGETITLE; NUMBER OF PAGEVIEWS; NUMBER OF USERS.

# Note: - Double backslashes are used to avoid Python errors in scanning strings.
#       - Each report file name is of the form 'GA_ReportYYYYMMDD.csv' with the date on which
#         the query was performed.
#       - Google places an API Limit 10 000 queries per profile ID per day. Exceedance of this limit
#       - will result in an API Error within this script.

import sys
import csv
import os
import datetime

def create_report(startdate):

    # Run the Google Analytics query built within GA_Filter and storing raw output data to GA_Data.csv.
    import GA_Filter
    GA_Filter.filtering(startdate)

    # Create list of Macrepo IDs.
    IDList = []

    #----------------------------------------------------------------------------- USER EDIT ---------
    # Open Macrepo_Lookup.csv to obtain ID numbers.
    # DEAR USER: Enter the filepath and the corresponding filename for a csv file containing your
    #            MacRepo IDs. Double backslashes are used to avoid Python errors in scanning strings.
    filepath = 'C:\Users\cochonnk\\Digital-Archive-Tools'
    filename = 'Macrepo_Lookup.csv'

    with open(filepath.strip('\\') + '\\' + filename, 'r') as lookupfile:
        
        reader1 = csv.reader(lookupfile, delimiter=",")
        for row in reader1:
            IDList.append(row[0])

    print datetime.datetime.today().strftime('%Y%m%d')
    
    #----------------------------------------------------------------------------- USER EDIT ---------
    # Open the csv file to which the report will be written to.
    # DEAR USER: Enter the filepath and the corresponding filename for a csv file to which the report
    #            data will be written to.
    GARPath = 'C:\Users\cochonnk\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts\\' + startdate
    GARFile = 'GA_Report' + datetime.datetime.today().strftime('%Y%m%d') + '.csv'
    a = open(GARPath.strip('\\') + '\\' + GARFile, 'wt')

    #----------------------------------------------------------------------------- USER EDIT ---------
    # Open GA_Data.csv file for reading.
    # DEAR USER: Enter the filepath and the corresponding filename that contains the raw query data.
    GADPath = 'C:\Users\cochonnk\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts'
    GADFile = 'GA_Data.csv'
    c = open(GADPath.strip('\\') + '\\' + GADFile, 'r')
    reader2 = csv.reader(c, delimiter=',', quotechar='|')
    reader3 = csv.reader(c, delimiter = ',', quotechar=',')

    # Open GA_DataDetails.csv file for appending.
    b = open(GARPath.strip('\\') + '\\' + GARFile, 'a')
    writer = csv.writer(b, dialect='excel', lineterminator='\n')

    # Place GA_Data.csv within the list 'dataread'.
    dataread = []
    for row in reader2:
        dataread.append(row)
    
    # Define headers.
    DIMENSION = (dataread[0])[0]
    DIMENSION = "DIMENSION: " + DIMENSION.upper()
    METRIC1 = (dataread[0])[2]
    METRIC1 = "METRIC: " + METRIC1.upper()
    METRIC2 = (dataread[0])[1]
    METRIC2 = "METRIC: " + METRIC2.upper()
    TIMERANGE = "TIMERANGE: From " + startdate + " to " + datetime.datetime.today().strftime('%Y%m%d')

    # Write headers for GA_Report.csv.
    headerwriter = csv.DictWriter(b, fieldnames = ["MACREPO ID", "WEBSITE URL", DIMENSION, METRIC1, METRIC2, TIMERANGE])
    headerwriter.writeheader()

    # Write data in GA_Report.csv.
    for ID, item in zip(IDList[0:len(IDList)],dataread[1:len(dataread)]):
        print item
        line = []
        line.append(item[0]) #Appending MacRepo ID.
        line.append("http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A"+item[0])#Appending corresponding URL.
        line.append(''.join('%5s' %piece for piece in item[1:len(item)-2])[3:]) #Appending corresponding dimension (page title).
        line.append(int(filter(str.isdigit, item[(len(item)-1)]))) #Appending corresponding Metric data (pageviews).
        line.append(int(filter(str.isdigit, item[(len(item)-2)]))) #Appending corresponding Metric data (users).
        writer.writerow(line)

    b.close()

    print "Success. Your Google Analytics report has been written to " + GARFile + " in " + GARPath

if __name__ == "__main__":
    create_report(startdate)
