# THIS SCRIPT RUNS GA_Filter.py. WHICH PULLS DATA FROM THE GOOGLE ANALYTICS REPORTING API.
# IT THEN TAKES THE RAW OUTPUT STORED IN A CSV FILE TO CREATE A READABLE CSV REPORT.
# IN ADDITION, THE RAW OUTPUT IS ALSO SORTED INTO EACH OBJECT'S COLLECTION, CREATING A SECOND READABLE CSV COLLECTIONS REPORT.
# CURRENTLY, THE SCRIPT ONLY WORKS ON PYTHON 2 DUE TO VERSION-UNIQUE LIBRARIES AND COMMANDS.

# THIS SCRIPT USES THE STORED GOOGLE ANALYTICS DATA WITHIN GA_Data.csv AS INPUTS.
# IN ADDITION, IT TAKES THE INPUT 'startdate', DENOTING THE BEGINNING DATE FROM WHICH GOOGLE TAKES
# ITS QUERY DATA. ITS END DATE IS THE DATE THE QUERY IS EXECUTED.
# THE OUTPUT DATA WILL BE IN A TABLE IN CSV FORMAT. IT WILL CONTAIN (for each unique webpage):
# MACREPO ID; WEBSITE URL; PAGETITLE; NUMBER OF UNIQUE USERS; NUMBER OF PAGEVIEWS; COLLECTION OR ITEM FLAG.

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

    # Creating empty lists. 
    IDList = [] # Create list of Macrepo IDs.
    flags = [] # Creating list to hold collection or item flags.
    identifiers = [] #Creating list to hold identifiers.
    parentdir = [] #Creating list of parent directories.
    pd_nodetails = [] #Creating list of parent directories with missing information from GA.
    topleveldir = []

    #----------------------------------------------------------------------------- USER EDIT ---------
    # Open Macrepo_Lookup.csv to obtain ID numbers.
    # DEAR USER: Enter the filepath and the corresponding filename for a csv file containing your
    #            MacRepo IDs. Double backslashes are used to avoid Python errors in scanning strings.
    filepath = 'C:\Home\\Digital-Archive-Tools'
    filename = 'Macrepo_Lookup.csv'

    with open(filepath.strip('\\') + '\\' + filename, 'r') as lookupfile:
        
        reader1 = csv.reader(lookupfile, delimiter=",")
        for row in reader1:
            IDList.append(row[0])
            flags.append(row[3])
            identifiers.append(row[4])
            parentdir.append(row[5])
            topleveldir.append(row[6])
    
    #print datetime.datetime.today().strftime('%Y%m%d')
    
    #----------------------------------------------------------------------------- USER EDIT ---------
    # Open the csv file to which the report will be written to.
    # DEAR USER: Enter the filepath and the corresponding filename for a csv file to which the report
    #            data will be written to.
    GARPath = 'C:\Home\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts\\' + startdate
    GARFile = 'GA_Report' + datetime.datetime.today().strftime('%Y%m%d') + '.csv'
    a = open(GARPath.strip('\\') + '\\' + GARFile, 'wt')
    
    #----------------------------------------------------------------------------- USER EDIT ---------
    # Open GA_Data.csv file for reading.
    # DEAR USER: Enter the filepath and the corresponding filename that contains the raw query data.
    GADPath = 'C:\Home\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts'
    GADFile = 'GA_Data.csv'
    c = open(GADPath.strip('\\') + '\\' + GADFile, 'r')
    reader2 = csv.reader(c, delimiter=',', quotechar='|')
    reader3 = csv.reader(c, delimiter = ',', quotechar=',')

    # WRITING GOOGLE ANALYTICS DATA TO GA_Report.csv.
    # Open GA_Report.csv file for appending.
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
    headerwriter = csv.DictWriter(b, fieldnames = ["MACREPO ID", "WEBSITE URL", DIMENSION, METRIC1, METRIC2, "ITEM=1, COLLECTION=2", "IDENTIFIER", "PARENT DIRECTORY", "TOP-LEVEL COLLECTION", TIMERANGE])
    headerwriter.writeheader()

    # Write data in GA_Report.csv.
    for ID, item, indicator, identifier, parent, toplevel in zip(IDList[0:len(IDList)],dataread[1:len(dataread)], flags[0:len(flags)], identifiers[0:len(identifiers)], parentdir[0:len(parentdir)], topleveldir[0:len(topleveldir)]): #dataread starts from "1" since "0" are the headings. 
        
        if ID == item[0]:
            line = []
            line.append(item[0]) #Appending MacRepo ID.
            line.append("http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A"+item[0]) #Appending corresponding URL.
            line.append(''.join('%5s' %piece for piece in item[1:len(item)-2])[3:]) #Appending corresponding dimension (page title).
            line.append(str(filter(str.isdigit, item[(len(item)-1)]))) #Appending corresponding Metric data (users).
            line.append(str(filter(str.isdigit, item[(len(item)-2)]))) #Appending corresponding Metric data (pageviews).
            line.append(int(indicator)) #Appending corresponding collection or item flag.
            line.append(str(identifier)) #Appending corresponding identifier.
            line.append(parent) #Appending corresponding parent directory.
            line.append(toplevel) #Appending corresponding top-level parent directory (collection).                                                                                                                                                                  
            writer.writerow(line)

        else:
            pass

    b.close()

    print "Success. Your Google Analytics report has been written to " + GARFile + " in " + GARPath


    # WRITING GOOGLE ANALYTICS DATA TO GA_CollectionsReport.csv.
    
    #----------------------------------------------------------------------------- USER EDIT ---------
    # Open the csv file to which the collections report will be written to.
    # DEAR USER: Enter the filepath and the corresponding filename for a csv file to which the collection
    #            report data will be written to.
    GARPathColl = 'C:\Home\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts\\' + startdate
    GARFileColl = 'GA_CollectionsReport' + datetime.datetime.today().strftime('%Y%m%d') + '.csv'
    d = open(GARPathColl.strip('\\') + '\\' + GARFileColl, 'wt')

    # Open GA_CollectionsReport.csv file for appending.
    e = open(GARPathColl.strip('\\') + '\\' + GARFileColl, 'a')
    writer = csv.writer(e, dialect='excel', lineterminator='\n')

    # Write headers for GA_CollectionsReport.csv.
    headerwriter = csv.DictWriter(e, fieldnames = ["COLLECTION MACREPO ID", "WEBSITE URL",DIMENSION, METRIC1 + " (TOTAL)",METRIC2 + " (TOTAL)", TIMERANGE])
    headerwriter.writeheader()

    # Creating list of unique parent directories.
    unique_pd = []
    [unique_pd.append(pd) for pd in parentdir if pd not in unique_pd]

    for pd in unique_pd:

        totalusers = 0
        totalpageviews = 0
        line = []
        line.append(pd) #Appending collection MacRepo ID.

        if pd not in IDList:
            pd_nodetails.append(pd) #Creating list of parent directories that are not listed as a MacRepo ID.
            
        else:
            pass

        for pdnoid in pd_nodetails: #Appending "N/A" for collection's URL and pagetitles if it is not listed as a MacRepo ID.

            if pd == pdnoid:

                line.append("N/A")
                line.append("N/A")

            else:
                pass
               
        # Open GA_Report.csv to obtain data.
        with open(GARPath.strip('\\') + '\\' + GARFile, 'r') as lookupfile2:
        
            reader4 = csv.reader(lookupfile2, delimiter=",")

            for row in reader4:

                if row[0] == pd: #Appending MacRepo ID details for the collection.
                    line.append(row[1]) #Appending corresponding URL.
                    line.append(row[2]) #Appending corresponding dimension (page title).
                        
                else:
                    pass
                    
                if row[7] == pd: #Tabulating the total numbers of users and pageviews for each parent directory.
                    usersnum = int(row[3])
                    pageviewsnum = int(row[4])
                    totalusers = totalusers + usersnum 
                    totalpageviews = totalpageviews + pageviewsnum

                else:
                    pass
                
        line.append(totalusers)
        line.append(totalpageviews)

        writer.writerow(line) #Writing the data line for each collection within the csv file. 
                    
    e.close()

    print "Success. Your Google Analytics Collections report has been written to " + GARFileColl + " in " + GARPathColl
    
if __name__ == "__main__":
    create_report(startdate)
