import os
import shutil
import re
import codecs
from urllib import request
import csv

#THIS SCRIPT CREATES A LOOKUP TABLE OF A RANGE OF ITEMS ON THE MCMASTER DIGITAL ARCHIVE. CURRENTLY THE SCRIPT ONLY WORKS ON PYTHON 3 DUE TO USING VERSION-UNIQUE LIBRARIES AND COMMANDS.
#THE LOOKUP TABLE WILL BE IN CSV FORMAT. IT WILL CONTAIN (for each unique object): MACREPO ID; URL; NAME; TYPE (Item or Collection); PARENT DIRECTORIES.

# NOTE: THIS SCRIPT USES UTF-8 ENCODING. EXCEL MAY NOT BE ABLE TO CORRECTLY IDENTIFY THE ENCODING OF CERTAIN CHARACTERS, PARTICULARLY INTERNATIONAL DIACRITICS, ON ITS OWN.
# THIS CAN EASILY BE SOLVED BY WORKING IN TEXT EDITORS SUCH AS NOTEPAD++.
# IF YOU WANT TO WORK IN EXCEL (2007 AT THE EARLIEST), GO TO THIS WEBPAGE AND FOLLOW THE SIMPLE INSTRUCTIONS TO OPEN THE TABLES IN EXCEL: https://www.itg.ias.edu/content/how-import-csv-file-uses-utf-8-character-encoding-0

nargin=0 #simple flag to determine which process to start: 0 is the whole range; 1 is based off the range of macrepo IDs generated previously (this acts essentially as an update)
type=0 #variable for the object: determines whether it is an item or a collection (or neither, but in theory this should never happen)
url_start = 'http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' #All objects on the Digital Archive have a unique URL, beginning with this and then adding the unique macrepo ID at the end.
output_table = [] #This will eventually contain all the data that we want to see in the lookup table.
URL_List=[] #This will eventually contain all the unique URLs that are part of parent directories and the name of the collection to which they belong.
tic=0 #Set a variable as a counter for the parent directories
dig=[] #List of macrepo IDs that are allowed in the range
interim=[] #List created for adding any new macrepo IDs to the current list
blank_URL=[] #List that will contain all URLs that are "empty" i.e. do not lead anywhere and yet still exist.
direct=[] #List that will contain each URL of the parent directory of each object.

with open("Macrepo_Lookup_AAB.csv","w", encoding='utf-8',newline='') as f: #Prepares a csv file to write all the information - main lookup table
    with open("URL_Lookup_AAB.csv","w",encoding="utf-8",newline='') as u: #Prepares a csv file to write the information to - URL lookup
        with open("Empty_AAB.csv","w",encoding="utf-8",newline='') as z: #Prepares a csv file to write the information to - Empty URL table
            poe=csv.writer(f,delimiter=",") #Declares the variable that will write the first table to the csv file
            verne=csv.writer(u,delimiter=",") #Declares the variable that will write the second table to the csv file
            speare=csv.writer(z,delimiter=",") #Declares the variable that will write the third table to the csv file

            if nargin==0: #Full run-through 
                macrepo_start=1;
                macrepo_end=100000;
                dig=range(macrepo_start,macrepo_end,1)
                #Change the above integers to set the range.
                print('Running through entire potential range, please hold.');
            elif nargin ==1: #Updating to the current lookup table
                macrepo_end=100000
                print('Alternate Route');
                with open("Macrepo_Lookup_AAB.csv","r",encoding='utf-8') as x: #Rename the previously completed lookup table to this before running the script
                    #with open("URL_Lookup.csv","r",encoding='utf-8') as y:
                    book=csv.reader(x,delimiter=",") #Read the original, complete lookup table
                        #mark=csv.reader(y,delimiter=",")
                    for row in book: 
                        dig.append(row[0]) #Add the column of macrepo IDs to the list
                interim.append(int(dig[-1])) #Add the last entry in dig to the updating list
                for w in interim:
                    w=w+1 #add one
                    interim.append(w) #add the new number (first number added is one more than the last element in dig)
                    if 100000 in interim:
                        break; #stop once it reaches the end of the desired range, in this case 100 000.
                dig.extend(interim) #Extend dig by the new list, creating an updated version.

            for i in dig: #Look in the defined range, going at intervals of 1

                the_url = url_start+str(i) #add the macrepo to the original URL

                try: #the try clause is to exclude all macrepo IDs whose pages do not exist
                    fetch=request.urlopen(the_url) #opens the above URL
                    #print (the_url);
                except:
                    pass #If the page does not exist, this skips it and moves to the next one in order to avoid breaking the code.
                try:
                    request.urlretrieve(the_url,filename="Object_Code_AAB.txt") #this try clause retrieves the url and saves its html temporarily as a text file, which will be used to obtain the other information.
                    print (i); #Prints the macrepo ID, easy to keep track of progress
                except:
                    continue #If the page does not exist, skip and move on.

                golden = codecs.open("Object_Code_AAB.txt","r","utf-8") #Opens the text file to read with utf-8 encoding, due to diacritics and other special characters
                text = golden.read() #the read function for the text file
                archivesandresearch = 'islandora/object/macrepo%3A6">'
                audio = 'islandora/object/macrepo%3A152">'
                books = 'islandora/object/macrepo%3A21847">'
                #Strings unique to an object in the Archives & Research, Audio, or Books Collections

                belong1 = text.find(archivesandresearch) #Find the string in the html text.
                belong2 = text.find(audio) #Find the string in the html text.
                belong3 = text.find(books) #Find the string in the html text.
                
                if belong1 > -1: #Skip the object if it is not found, keep it if it is.
                    collection = "Archives and Reasearch Collections"
                    pass
                elif belong2 > -1:
                    collection = "Audio"
                    pass
                elif belong3 > -1:
                    collection = "Books"
                    pass
                else:
                    continue
                #This ensures that only objects within the Archives & Research, Audio, or Books Collections are included.
                
                #PULL OUT THE NAME OF THE OBJECT
                name = 'id="page-title">' #Look in the html for this specific, unique string - the next character is the beginning of the identifier
                a = text.find(name) #Mark its position in the html
                snippet = text[a+16:a+314] #Take a large snippet of the html from point a+16, which is the beginning of the identifier
                b = snippet.find('</h1>') #Mark this string's position in the snippet above - this is the end of the identifier
                ident = snippet[0:b] #this variable only takes the name itself.
                    
                #PULL OUT THE DIRECTORY BRANCH OF THE OBJECT - USES BREADCRUMB
                bread='<nav class="breadcrumb" role="navigation"><h2 class="element-invisible">You are here</h2><ol><li>'
                crumb='<a name="main-menu"'
                #The above strings are unique to the breadcrumb and contain all the directory paths for each individual object.
                cut1=text.find(bread) #Marks the position of the bread string in the html
                cut2=text.find(crumb) #Marks the position of the crumb string in thte html
                cutBIG=text[cut1+97:cut2] #Takes the chunk of html from the end of the bread string to the beginning of the crumb string
                r=[h.end() for h in re.finditer('<a href="',cutBIG)] 
                e=[c.start() for c in re.finditer('">',cutBIG)]
                #The strings, h and c, above are not unique, they occur multiple times in each cutBIG segment as they contain the parent directories of the object.
                #In addition, the number of parent directories is variable among different objects.
                #As such, we want to find every occurrence and position of the strings h and c in the cutBIG segment, and create lists r and e from these indices. This will be important further down.
                
                if len(r)==0: #If there is only one entry in the breadcrumb, implying an empty URL
                    blank_URL.append(the_url)
                    speare.writerow(blank_URL)
                    speare=[] #Add the URL to the appropriate list, write it to the csv file and clear the list.
                
                output_table.append(i)
                output_table.append(the_url)
                output_table.append(ident)
                output_table.append(collection)
                #The above three lines add the macrepo ID, the URL, the name of the object, and its collection to the list.
                while tic < len(r):# and tic < len(e): #Since indices begin at 0, the last entry in a list with length n is L[n-1]. So this statement and the following only work while the tic variable has a value contained within the lists i.e. 0:n-1.
                    branch= cutBIG[r[tic]:e[tic]] #Take the segment using the entry whose index number matches the current tic value - starting at 0, or the first entry.
                    fullbranch='http://digitalarchive.mcmaster.ca'+str(branch) #Create the full branch path using the string and the branch segment obtained above.
                    #The html only uses the URL path after the above string, as a truncated version and since the above string is consistent in all objects.
                    tic=tic+1 #Add 1 to the counter and repeat with the next entry in the indices.
                    direct.append(fullbranch) #Add the branch to the directory list.
                tic=0 #Reset the tic counter.
                output_table.extend(direct) #Extend the output table list with every entry from the direct list i.e. the parent directories
                poe.writerow(output_table) #Write the current list to the csv file; the list now contains all the information for a single macrepo ID.
                direct=[] #Clear the parent directory list.
                output_table=[] #Finally, clear the list and repeat with the next macrepo ID.

            shutil.copyfile('Macrepo_Lookup_AAB.csv', 'Macrepo_Lookup_AAB' + datetime.datetime.today().strftime('%Y%m%d') + '.csv')
