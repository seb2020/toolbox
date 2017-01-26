'''
# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

################################################################################
#
# Script: List of running kernel of spacewalk client
#
################################################################################
'''


from __future__ import print_function
from xmlrpc import client
from datetime import date
from datetime import timedelta
import re


SATELLITE_URL = "http://SRVLNXMGNT-01.logival.local/rpc/api"

webservice = client.Server(SATELLITE_URL, verbose=0)

key = webservice.auth.login("admin", "ktnTp4oOgzTmdcfOoe5v")


today = date.today()
yesterday = today - timedelta(days=1)

list = webservice.system.list_systems(key)


for system in list:

                lastboot = webservice.system.get_details(key,system.get('id'))
                currKern = webservice.system.get_running_kernel(key,system.get('id'))
                matchObj = re.search(".*\'last_boot\'\: \<DateTime \'(.*?)\'\ at.*", str(lastboot))

                print(currKern,system.get('name'),matchObj.group(1))


webservice.auth.logout(key)

