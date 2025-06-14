#!/usr/bin/python3.8
# Written by Anthony Moulen
# Last Modified: 24 Oct 2018
# Modifications: Initial Build

# Import required modules.  Should be python 3 safe.
try:
    # For Python 3.0 and later
    from urllib.request import urlopen
    from urllib.error import HTTPError, URLError
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import urlopen
    from urllib2 import HTTPError

import json
import os
import sys
from datetime import date

# Set the default variables for backups
bkup_type = "daily"
retention = 7
bkp_fold = "/efs/backups"
bkup_date = date.today().strftime("%Y%m%d")

# Check if we are asking for a weekly backup rather than a daily.
# Adjust appropraite variables.
if len(sys.argv) > 1:
    if sys.argv[1] == 'weekly':
        bkup_type = 'weekly'
        retention = 22

# Set the Base URL for Solr.
base_url = ("http://libsearch8-prod1.lib.harvard.edu:18280/solr/admin/collections")
storage = (bkp_fold + "/" + bkup_type)

# Setup URLs for various backup action.
coll_url = (base_url + "?action=LIST&wt=json")
bkup_base = (base_url + "?action=BACKUP&name={0}_{1}-{2}&collection={0}&location={3}&async={4}")
clrid_base = (base_url + "?action=DELETESTATUS&requestid={0}")

# Setup the base for the find command.
find_base = ("find {0} -maxdepth 1 -mindepth 1 -name {1}_{2}\* -type d -mtime +{3} -exec rm -rf {{}} \;")

# Retrieve our list of collections from the serverself.
response = urlopen(coll_url).read()

# Format the return for processing.
collections = json.loads(response)["collections"]

# Iterate over the collect array
iCol = 0
while iCol < len(collections):
    find_str = find_base.format(storage, collections[iCol], bkup_type, retention)
#    print(find_str)
    os.system(find_str)
    asyncID = 1500 + iCol
    clrid_url = clrid_base.format(asyncID)
#    print (clrid_url)
    try:
        resp = urlopen(clrid_url)
    except HTTPError:
        pass
        # print("Async ID not active")
    bkup_url =  bkup_base.format(collections[iCol],bkup_type,bkup_date,storage,asyncID)
#    print(bkup_url)
    urlopen(bkup_url)
    iCol += 1