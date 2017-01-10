import os
import shutil
import re
import codecs
from urllib import request
import csv
from collections import defaultdict
#THIS SCRIPT CREATES A LOOKUP TABLE OF A RANGE OF ITEMS ON THE MCMASTER DIGITAL ARCHIVE. CURRENTLY THE SCRIPT ONLY WORKS ON PYTHON 3 DUE TO USING VERSION-UNIQUE LIBRARIES AND COMMANDS.
#THE LOOKUP TABLE WILL BE IN CSV FORMAT. IT WILL CONTAIN (for each unique object): MACREPO ID; URL; NAME; TYPE (Item or Collection); PARENT DIRECTORIES.

# NOTE: THIS SCRIPT USES UTF-8 ENCODING. EXCEL MAY NOT BE ABLE TO CORRECTLY IDENTIFY THE ENCODING OF CERTAIN CHARACTERS, PARTICULARLY INTERNATIONAL DIACRITICS.
# THIS CAN EASILY BE SOLVED BY WORKING IN TEXT EDITORS SUCH AS NOTEPAD++ OR GOOGLE SHEETS.

nargin=1 #simple flag to start the process
type=0 #variable for the object: determines whether it is an item or a collection (or neither, but in theory this should never happen)
url_start = 'http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A' #All objects on the Digital Archive have a unique URL, beginning with this and then adding the unique macrepo ID at the end.
output_table = [] #This will eventually contain all the data that we want to see in the lookup table.
URL_List=[] #This will eventually contain all the unique URLs that are part of parent directories and the name of the collection to which they belong.
tic=0 #Set a variable as a counter for the parent directories
columns=defaultdict(list)
dig=[]
ital=[]
interim=[]

with open("Macrepo_Lookup.csv","w", encoding='utf-8',newline='') as f: #Prepares a csv file to write all the information - main lookup table
	with open("URL_Lookup.csv","w",encoding="utf-8",newline='') as u: #Prepares a csv file to write the information to - URL lookup
		poe=csv.writer(f,delimiter=",") #declares the variable that will write the first table to the csv file
		verne=csv.writer(u,delimiter=",") #declares the variable that will write the second table to the csv file
		if nargin==0:
			macrepo_start=1;
			macrepo_end=85000;
			dig=range(macrepo_start,macrepo_end,1)
			#Change the above integers to set the range.
			print('Running through entire potential range, please hold.');
		elif nargin ==1:
			macrepo_end=100000
			print('Alternate Route');
			with open("Macrepo_GOOD.csv","r",encoding='utf-8') as x:
				#with open("URL_GOOD.csv","r",encoding='utf-8') as y:
				book=csv.reader(x,delimiter=",")
					#mark=csv.reader(y,delimiter=",")
				for row in book:
					dig.append(row[0])
			interim.append(int(dig[-1]))
			for w in interim:
				w=w+1
				interim.append(w)
				if 100000 in interim:
					break;
			ital=dig.extend(interim)