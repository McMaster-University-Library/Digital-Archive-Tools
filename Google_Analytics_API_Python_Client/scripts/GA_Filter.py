# THIS SCRIPT PULLS DATA FROM THE GOOGLE ANALYTICS REPORTING API DIRECTLY INTO EXCEL TO WRITE A CSV
# FILE CONTAINING THE GOOGLE ANALYTICS DATA. CURRENTLY, THE SCRIPT ONLY WORKS ON PYTHON 2 DUE TO
# VERSION-UNIQUE LIBRARIES AND COMMANDS.

# THIS SCRIPT TAKES WEBSITE URLS CONTAINED IN A CSV FILE AS INPUTS FOR THE GOOGLE ANALYTICS QUERY.
# THE OUTPUT DATA WILL BE IN A TABLE IN CSV FORMAT. IT WILL CONTAIN (for each unique webpage):
# MACREPO ID; PAGEVIEWS; USERS.

# Note: Double backslashes are used to avoid Python errors in scanning strings.

from __future__ import print_function
import argparse
import sys
import csv
import timeit
import time
import pause
import random
from googleapiclient.errors import HttpError
from googleapiclient import sample_tools
from oauth2client.client import AccessTokenRefreshError

def filtering(startdate):
	
	# Elimating logging error for oauth2client.
	import logging
	logging.basicConfig(filename='debug.log',level=logging.DEBUG)

	# Creating empty list to hold Macrepo IDs.
	content = []

	#----------------------------------------------------------------------------- USER EDIT ---------
	# Opening Macrepo_Lookup.csv to obtain ID numbers.
	# DEAR USER: Enter the filepath and the corresponding filename for a csv file which contains the
	#            MacRepo IDs you want to pass the Google Analytics query for.
	filepath = 'C:\Home\\Digital-Archive-Tools'
	filename = 'Macrepo_Lookup.csv' 

	with open(filepath.strip('\\') + '\\' + filename, 'r') as lookupfile:
		
		reader = csv.reader(lookupfile, delimiter=",")
		for row in reader:
			content.append(row[0])
			
	#----------------------------------------------------------------------------- USER EDIT ---------
	# Open GA_Data file for writing.
	# DEAR USER: Enter the filepath and the corresponding filename for a csv file to which the query
	#            data will be written to. 
	filepath = 'C:\Home\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts'
	filename = 'GA_Data.csv'
	g = open(filepath.strip('\\') + '\\' + filename, 'wt')

	print ("Processing... This script will run for two days.")

	for ID in content[0:len(content)]:

				if int(ID) == 81318:
					pause.days(1)
					print ("Paused: This script will resume in 24 hours. If the computer goes to sleep or standby mode, the script will remain running. Shutting down the computer, however, will kill the script immediately.")

					def main(argv):
						# Authenticate and construct service.
						service, flags = sample_tools.init(
								argv, 'analytics', 'v3', __doc__, __file__,
								scope='https://www.googleapis.com/auth/analytics.readonly')
						
						#------------------------------------------------------------------------ USER EDIT ---------
						# Try to make a request to the API. Print the results or handle errors.

						try:
							first_profile_id = '83866004' # DEAR USER: Enter your profile ID found from the Google Query Explorer.
							if not first_profile_id:
								print('Could not find a valid profile for this user.')
							else:
                                                                starttime = timeit.timeit()
								results = get_top_keywords(service, first_profile_id)
								print_results(results)
								endtime = timeit.timeit()
								print ("Query run time: " + str(endtime-starttime) + " seconds.")

						except TypeError as error:
							# Handle errors in constructing a query.
							print(('There was an error in constructing your query : %s' % error))

						except HttpError as error:
							# Handle API errors.
							print(('Arg, there was an API error : %s : %s' %
										 (error.resp.status, error._get_reason())))

						except AccessTokenRefreshError:
							# Handle Auth errors.
							print ('The credentials have been revoked or expired, please re-run '
										 'the application to re-authorize')
									
					def get_first_profile_id(service):
				
						"""Traverses Management API to return the first profile id.
						This first queries the Accounts collection to get the first account ID.
						This ID is used to query the Webproperties collection to retrieve the first
						webproperty ID. And both account and webproperty IDs are used to query the
						Profile collection to get the first profile id.
						Args:
							service: The service object built by the Google API Python client library.
						Returns:
							A string with the first profile ID. None if a user does not have any
							accounts, webproperties, or profiles.
						"""
						
						accounts = service.management().accounts().list().execute()

						if accounts.get('items'):
							firstAccountId = accounts.get('items')[0].get('id')
							webproperties = service.management().webproperties().list(
									accountId=firstAccountId).execute()

							if webproperties.get('items'):
								firstWebpropertyId = webproperties.get('items')[0].get('id')
								profiles = service.management().profiles().list(
										accountId=firstAccountId,
										webPropertyId=firstWebpropertyId).execute()

								if profiles.get('items'):
									return profiles.get('items')[0].get('id')

						return None

					def makeRequestWithExponentialBackoff(analytics):

                                                  """Wrapper to request Google Analytics data with exponential backoff.

                                                  The makeRequest method accepts the analytics service object, makes API
                                                  requests and returns the response. If any error occurs, the makeRequest
                                                  method is retried using exponential backoff.

                                                  Args:
                                                            analytics: The analytics service object

                                                  Returns:
                                                            The API response from the makeRequest method.
                                                  """
                                                  for n in range(0, 5):
                                                            try:
                                                                      return makeRequest(analytics)

                                                            except HttpError, error:
                                                                      if error.resp.reason in ['userRateLimitExceeded', 'quotaExceeded',
                                                                       'internalServerError', 'backendError']:
                                                                        time.sleep((2 ** n) + random.random())
                                                                      else:
                                                                                break

                                                  print ("There has been an error, the request never succeeded.")

			# EXECUTING AND RETURNING DATA FROM THE CORE REPORTING API.

					def get_top_keywords(service, profile_id):
				
						"""
							Args:
							service: The service object built by the Google API Python client library.
							profile_id: String The profile ID from which to retrieve analytics data.
						Returns:
							The response returned from the Core Reporting API.
						"""
					
			# ----------------------------------------------------------------------------------------------------------------------------
			# IF YOU WISH, YOU MAY DEFINE DETAILS ACCORDING TO GOOGLE'S QUERY EXPLORER IN THE SECTION BELOW.
			# The query builder can be found at https://ga-dev-tools.appspot.com/query-explorer/.
			# This script was orginally created with dimensions = 'ga:pagetitle', and metrics = 'ga:pageviews, ga:users'.
			# Though choosing different dimensions and metrics may work, unforeseen csv formatting issues may occur.
			# --------------------------------------------------------------------------------------------------------------------
                                                
						return service.data().ga().get(
							ids ='ga:' + profile_id,
							start_date = startdate,
							end_date = 'yesterday',
							#The following filter is placed to run the query for each MacRepo ID and the corresponding webpage.
							filters = 'ga:pagePath==/islandora/object/macrepo:' + ID,
							dimensions = 'ga:pagetitle',
							metrics = 'ga:pageviews, ga:users',
							#In the special case of multiple old web page titles, the webpage with which the most number of users is recorded.
							sort = "-ga:users",
							max_results = 1).execute()

			# ----------------------------------------------------------------------------------------------------------------------------

					def print_results(results):

						# WRITING RESULTS FROM GOOGLE ANALYTICS QUERY INTO 'FILENAME' BELOW.

						#----------------------------------------------------------------------------- USER EDIT ---------
						# Open GA_Data file for appending.
						# DEAR USER: Enter the filepath and the corresponding filename for a csv file to which the query
						#            data will be appended to.
						filepath = 'C:\Home\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts'
						filename = 'GA_Data.csv'
						f = open(filepath.strip('\\') + '\\' + filename, 'a')

						# Wrap file with csv.writer.
						writer = csv.writer(f, dialect='excel', lineterminator='\n')
						
						# Write header.
						header = [h['name'][3:] for h in results.get('columnHeaders')] #this takes the column headers and gets rid of ga: prefix
						if ID == content[0]:
								writer.writerow(header)

						# Write data table.
						if results.get('rows', []):
							for row in results.get('rows'):
								writer.writerow([ID, row])
							
						else:
							writer.writerow([ID,["No Results Found", 0,0]])
						
						f.close()
					
					print ("Collecting data for MacRepo ID " + ID + ".")
					
					main(sys.argv)

				else:

					def main(argv):
						# Authenticate and construct service.
						service, flags = sample_tools.init(
								argv, 'analytics', 'v3', __doc__, __file__,
								scope='https://www.googleapis.com/auth/analytics.readonly')
						
						#------------------------------------------------------------------------ USER EDIT ---------
						# Try to make a request to the API. Print the results or handle errors.

						try:
							first_profile_id = '83866004' # DEAR USER: Enter your profile ID found from the Google Query Explorer.
							if not first_profile_id:
								print('Could not find a valid profile for this user.')
							else:
                                                                starttime = timeit.timeit()
								results = get_top_keywords(service, first_profile_id)
								print_results(results)
								endtime = timeit.timeit()
								print ("Query run time: " + str(endtime-starttime) + " seconds.")

						except TypeError as error:
							# Handle errors in constructing a query.
							print(('There was an error in constructing your query : %s' % error))

						except HttpError as error:
							# Handle API errors.
							print(('Arg, there was an API error : %s : %s' %
										 (error.resp.status, error._get_reason())))

						except AccessTokenRefreshError:
							# Handle Auth errors.
							print ('The credentials have been revoked or expired, please re-run '
										 'the application to re-authorize')
									
					def get_first_profile_id(service):
				
						"""Traverses Management API to return the first profile id.
						This first queries the Accounts collection to get the first account ID.
						This ID is used to query the Webproperties collection to retrieve the first
						webproperty ID. And both account and webproperty IDs are used to query the
						Profile collection to get the first profile id.
						Args:
							service: The service object built by the Google API Python client library.
						Returns:
							A string with the first profile ID. None if a user does not have any
							accounts, webproperties, or profiles.
						"""
						
						accounts = service.management().accounts().list().execute()

						if accounts.get('items'):
							firstAccountId = accounts.get('items')[0].get('id')
							webproperties = service.management().webproperties().list(
									accountId=firstAccountId).execute()

							if webproperties.get('items'):
								firstWebpropertyId = webproperties.get('items')[0].get('id')
								profiles = service.management().profiles().list(
										accountId=firstAccountId,
										webPropertyId=firstWebpropertyId).execute()

								if profiles.get('items'):
									return profiles.get('items')[0].get('id')

						return None

			# EXECUTING AND RETURNING DATA FROM THE CORE REPORTING API.

					def get_top_keywords(service, profile_id):
				
						"""
							Args:
							service: The service object built by the Google API Python client library.
							profile_id: String The profile ID from which to retrieve analytics data.
						Returns:
							The response returned from the Core Reporting API.
						"""
					
			# ----------------------------------------------------------------------------------------------------------------------------
			# IF YOU WISH, YOU MAY DEFINE DETAILS ACCORDING TO GOOGLE'S QUERY EXPLORER IN THE SECTION BELOW.
			# The query builder can be found at https://ga-dev-tools.appspot.com/query-explorer/.
			# This script was orginally created with dimensions = 'ga:pagetitle', and metrics = 'ga:pageviews, ga:users'.
			# Though choosing different dimensions and metrics may work, unforeseen csv formatting issues may occur.
			# --------------------------------------------------------------------------------------------------------------------
                                                
						return service.data().ga().get(
							ids ='ga:' + profile_id,
							start_date = startdate,
							end_date = 'yesterday',
							#The following filter is placed to run the query for each MacRepo ID and the corresponding webpage.
							filters = 'ga:pagePath==/islandora/object/macrepo:' + ID,
							dimensions = 'ga:pagetitle',
							metrics = 'ga:pageviews, ga:users',
							#In the special case of multiple old web page titles, the webpage with which the most number of users is recorded.
							sort = "-ga:users",
							max_results = 1).execute()
                                                
			# ----------------------------------------------------------------------------------------------------------------------------

					def print_results(results):

						# WRITING RESULTS FROM GOOGLE ANALYTICS QUERY INTO 'FILENAME' BELOW.

						#----------------------------------------------------------------------------- USER EDIT ---------
						# Open GA_Data file for appending.
						# DEAR USER: Enter the filepath and the corresponding filename for a csv file to which the query
						#            data will be appended to.
						filepath = 'C:\Home\\Digital-Archive-Tools\\Google_Analytics_API_Python_Client\\scripts'
						filename = 'GA_Data.csv'
						f = open(filepath.strip('\\') + '\\' + filename, 'a')

						# Wrap file with csv.writer.
						writer = csv.writer(f, dialect='excel', lineterminator='\n')
						
						# Write header.
						header = [h['name'][3:] for h in results.get('columnHeaders')] #this takes the column headers and gets rid of ga: prefix
						if ID == content[0]:
								writer.writerow(header)

						# Write data table.
						if results.get('rows', []):
							for row in results.get('rows'):
								writer.writerow([ID, row])
							
						else:
							writer.writerow([ID,["No Results Found", 0,0]])
						
						f.close()
					
					print ("Collecting data for MacRepo ID " + ID + ".")
					
					main(sys.argv)

	print ("Your Google Analytics data has been successfully written to " + filename);
