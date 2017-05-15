import os
import shutil
import re
import codecs
from urllib import request
import csv
import datetime

#THIS SCRIPT CREATES A LOOKUP TABLE OF A RANGE OF ITEMS ON THE MCMASTER DIGITAL ARCHIVE. CURRENTLY THE SCRIPT ONLY WORKS ON PYTHON 3 DUE TO USING VERSION-UNIQUE LIBRARIES AND COMMANDS.
#THE LOOKUP TABLE WILL BE IN CSV FORMAT. IT WILL CONTAIN (for each unique object): MACREPO ID; URL; NAME; TYPE (Item or Collection); PARENT DIRECTORY; TOP-LEVEL PARENT DIRECTORY; PARENT DIRECTORY URLS.
#NOTE: THIS SCRIPT USES UTF-8 ENCODING. EXCEL MAY NOT BE ABLE TO CORRECTLY IDENTIFY THE ENCODING OF CERTAIN CHARACTERS, PARTICULARLY INTERNATIONAL DIACRITICS, ON ITS OWN.
#THIS CAN EASILY BE SOLVED BY WORKING IN TEXT EDITORS SUCH AS NOTEPAD++.
#IF YOU WANT TO WORK IN EXCEL (2007 AT THE EARLIEST), GO TO THIS WEBPAGE AND FOLLOW THE SIMPLE INSTRUCTIONS TO OPEN THE TABLES IN EXCEL: https://www.itg.ias.edu/content/how-import-csv-file-uses-utf-8-character-encoding-0

scraperfunction = 0 #A flag to determine which process to start. (Set this to 0 to create an entirely new Macrepo_Lookup.csv file. Set this to 1 to update the existing Macrepo_Lookup.csv file.)
                
#DEFINING THE SCRAPE FUNCTION. IT IS SET TO RUN NEAR THE END OF THIS SCRIPT. 
def scrape(scraperfunction):

        type = 0 #Variable for the object: Determines whether it is an item or a collection (or neither, but this should never happen).
        url_start = 'http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' #All objects on the Digital Archive have a unique URL, beginning with this and then adding the unique macrepo ID at the end.
        output_table = [] #This will eventually contain all the data that we want to see in the lookup table.
        URL_List = [] #This will eventually contain all the unique URLs that are part of parent directories and the name of the collection to which they belong.
        tic = 0 #Set a variable as a counter for the parent directories.
        dig = [] #List of macrepo IDs that are allowed in the range.
        interim = [] #List created for adding any new macrepo IDs to the current list.
        blank_URL = [] #List that will contain all URLs that are "empty" i.e. do not lead anywhere and yet still exist.
        direct = [] #List that will contain each URL of the parent directory of each object.
        identifer = [] #List that will contain each Identifier of the object, indicating 'N/A' for a collection.

        with open("URL_Lookup.csv","w",encoding="utf-8",newline='') as u: #Prepares a csv file to write the information to - URL lookup.
                with open("Empty.csv","w",encoding="utf-8",newline='') as z: #Prepares a csv file to write the information to - Empty URL table.
                        poe=csv.writer(f,delimiter=",") #Declares the variable that will write the first table to the csv file.
                        verne=csv.writer(u,delimiter=",") #Declares the variable that will write the second table to the csv file.
                        speare=csv.writer(z,delimiter=",") #Declares the variable that will write the third table to the csv file.
                        
                        if scraperfunction == 0: #Creating a list of Macrepo IDs from 1 to 100 000.

                                print('Running through entire potential range, please hold.')
                                macrepo_start = 1
                                macrepo_end = 100000
                                dig = range(macrepo_start,macrepo_end + 1, 1)

                        elif scraperfunction == 1: #Creating a list of Macrepo IDs from the last entry of the latest Macrepo_Lookup.csv file to 100 000.
                                
                                print('Alternate Route: Updating.')
                                with open("Macrepo_Lookup.csv", "r",encoding='utf-8') as x: #Reading the latest Macrepo_Lookup.csv file.
                                        book=csv.reader(x,delimiter=",")
                                        for row in book:
                                                dig.append(row[0])
                                interim.append(int(dig[-1])) #Add the last entry in dig to an empty "to be updated" list called interim.

                                for w in interim:
                                        w = w + 1
                                        interim.append(w)
                                        if 100000 in interim:
                                                break #Stop once it reaches the end of the desired range.
                                dig = interim[1:]

                        for i in dig:
                                
                                the_url = url_start + str(i) #Add the macrepo to the original URL

                                try: #A try clause to exclude all macrepo IDs whose pages do not exist.
                                        fetch=request.urlopen(the_url) #Opens the above URL.
                                except:
                                        pass #If the page does not exist, this skips it and moves to the next one in order to avoid breaking the code.

                                try:
                                        request.urlretrieve(the_url,filename="Object_Code.txt") #This try clause retrieves the url and saves its html temporarily as a text file, which will be used to obtain the other information.
                                        print (i); #Prints the macrepo ID, easy to keep track of progress.
                                except:
                                        continue #If the page does not exist, skip and move on.
                                
                                #ENSURING THAT ONLY ITEMS WITHIN THE MAP COLLECTIONS ARE INCLUDED.
                                golden = codecs.open("Object_Code.txt","r","utf-8") #Opens the text file to read with utf-8 encoding, due to diacritics and other special characters.
                                text = golden.read()
                                maps = 'islandora/object/macrepo%3A10">' #This is a string unique to an object in the Maps Collections.
                                belong = text.find(maps) #Find the string in the html text.
                                if belong == -1: #Skip the object if it is not found, keep it if it is.
                                        continue
                                else:
                                        pass
                                
                                #PULL OUT THE NAME OF THE OBJECT
                                name='id="page-title">' #Look in the html for this specific, unique string - the next character is the beginning of the identifier.
                                a=text.find(name) #Mark its position in the html.
                                snippet=text[a+16:a+314] #Take a large snippet of the html from point a+16, which is the beginning of the identifier.
                                b=snippet.find('</h1>') #Mark this string's position in the snippet above - this is the end of the identifier.
                                ident=snippet[0:b] #This variable only takes the name itself.
                                
                                #PULL THE TYPE OF THE OBJECT: ITEM OR COLLECTION
                                item = 'islandora-large-image' #Variable for string that is unique to items.
                                coll = 'islandora-basic-collection' #Variable for string that is unique to collections.
                                flag1 = text.find(item) 
                                flag2 = text.find(coll) 

                                #The above flags look for the item and coll strings in the html code. If they are found the flags return a number greater than 0. If they are not found, the flags return -1.
                                if flag1 == -1 and flag2 == -1:
                                        continue
                                
                                elif flag2 == -1  and flag1 != -1: #Has found the item string.
                                        type=1
                                        
                                elif flag1 == -1 and flag2 != -1: #Has found the coll string.
                                        type=2
                                        
                                        if the_url not in URL_List: #Only for collection URLs
                                                URL_List.append(ident) #Add the collection identifier to the list
                                                URL_List.append(the_url) #Add the collection URL to the list
                                                verne.writerow(URL_List) #Write the list to the csv file.
                                                URL_List=[] #Clear the list and repeat.

                                #PULL OUT THE IDENTIFIER OF THE OBJECT
                                if type == 1:
                                        iden = 'Identifier</td>'
                                        c = text.find(iden)
                                        snip = text[c+19:c+40]
                                        d = snip.find('<td>')
                                        e = snip.find('</td>')
                                        identifier = snip[d+4:e]
                                else:
                                        identifier = 'N/A'
                                
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
                                output_table.append(type)
                                output_table.append(identifier)
                                        
                                #The above five lines add the macrepo ID, the URL, the name of the object, the type of the object, and its identifier to the list.
                                while tic < len(r):#And tic < len(e): #Since indices begin at 0, the last entry in a list with length n is L[n-1]. So this statement and the following only work while the tic variable has a value contained within the lists i.e. 0:n-1.
                                        branch= cutBIG[r[tic]:e[tic]] #Take the segment using the entry whose index number matches the current tic value - starting at 0, or the first entry.
                                        fullbranch='http://digitalarchive.mcmaster.ca'+str(branch) #Create the full branch path using the string and the branch segment obtained above.
                                        #The html only uses the URL path after the above string, as a truncated version and since the above string is consistent in all objects.
                                        tic=tic+1 #Add 1 to the counter and repeat with the next entry in the indices.
                                        direct.append(fullbranch) #Add the branch to the directory list.
                                tic=0 #Reset the tic counter.

                                #OBTAIN THE PARENT DIRECTORY MACREPO ID OF THE OBJECT
                                pd_url = str (direct[len(direct)-1])
                                A = pd_url.find('A')
                                pd_id = pd_url[A+1:] #Takes the numbers after "...%3A" of pd_url and sets it as pd_id.

                                output_table.append(pd_id) #Append the parent directory MacRepo ID of the object to the list.

                                #OBTAIN THE TOP-LEVEL COLLECTION MACREPO ID OF THE OBJECT.
                                if len(direct) >= 5:
                                        top_level_url = str(direct[4])
                                        B = top_level_url.find('A')
                                        top_level_id = top_level_url[B+1:]
                                else:
                                        top_level_id = 0

                                output_table.append(top_level_id) #Append the top-level collection MacRepo ID of the object to the list.

                                output_table.extend(direct) #Extend the output table list with every entry from the direct list i.e. the parent directories.
                                poe.writerow(output_table) #Write the current list to the csv file; the list now contains all the information for a single macrepo ID.
                                direct=[] #Clear the parent directory list.
                                output_table=[] #Finally, clear the list and repeat with the next macrepo ID.


#RUNNING THE SCRAPE FUNCTION. 
if scraperfunction == 0: #Creating a new Macrepo_Lookup.csv file.
        with open("Macrepo_Lookup_Temp.csv", "w", encoding='utf-8',newline='') as f: #Prepares a csv file to write all the information - Main lookup table
                scrape(0)

elif scraperfunction == 1: #Appending or adding to the current new Macrepo_Lookup.csv file.
        with open("Macrepo_Lookup_Temp.csv", "a", encoding='utf-8',newline='') as f: #Prepares a csv file to append all the information - Main lookup table
                scrape(1)

shutil.copyfile('Macrepo_Lookup_Temp.csv', 'Macrepo_Lookup.csv')
shutil.copyfile('Macrepo_Lookup.csv', 'Macrepo_Lookup' + datetime.datetime.today().strftime('%Y%m%d') + '.csv')
