#coding=utf-8
import requests
from tkinter import *
import stdiomask
import os


IP_ADDR = str(input("Please enter your PVWA IP or FQDN : "))
USERNAME = str(input("Please enter the username : "))
PASSWD = stdiomask.getpass(prompt='Please enter the password : ')

CYBR_URL = 'https://' + IP_ADDR
#print(CYBR_URL)
LOGON_URL = CYBR_URL + '/PasswordVault/API/auth/Cyberark/Logon'
LIST_SAFE_URL = CYBR_URL + '/PasswordVault/api/Safes'
LIST_ACCOUNT_IN_SAFE = CYBR_URL + '/PasswordVault/api/Accounts?limit=1000&filter=safeName eq '
logon = {'username': USERNAME, 'password': PASSWD}
logon_r = requests.post(LOGON_URL, json=logon)
session_token=logon_r.json()
logon_status=logon_r.status_code
if logon_status != 200 :
     print("Logon failed!")      # print session token
else :
     print("Logon success!")
#print(session_token)      # print session token
token_header = {'Authorization': session_token}
list_safe = requests.get(LIST_SAFE_URL, headers=token_header)
data1 = list_safe.json()
a = data1['Safes']
b = data1['Total']
all_safes=[0 for i in range(b)]
t = 0
while (t < b):
    all_safes[t]=data1['Safes'][t]['SafeName']
    t = t + 1
internal_safes=['VaultInternal', 'Notification Engine', 'PasswordManager', 'PasswordManager_Pending', 'AccountsFeedADAccounts', 'AccountsFeedDiscoveryLogs', 'PVWAReports', 'PVWATicketingSystem', 'PVWAPublicData', 'PSM', 'PSMUniversalConnectors', 'PSMRecordings', 'PSMPADBUserProfile', 'PSMPADBridgeCustom']
customer_safes = set(all_safes).difference(set(internal_safes))
customer_safes = list(customer_safes)
#print(customer_safes)  #list all safes
fo = open("output.csv", "w")
fo.write('id,name,address,username,platformID,safename,password\n')
fo.close()
fo = open("output.csv", "a")
print("Exporting, please wait ...")
for cybr_safe in customer_safes:
    LIST_URL = LIST_ACCOUNT_IN_SAFE + cybr_safe
    list_account = requests.get(LIST_URL, headers=token_header)
    data1 = list_account.json()
    b = data1['count']
    if b:
        accounts_id = [0 for i in range(b)]
        accounts_name = [0 for i in range(b)]
        accounts_address = [0 for i in range(b)]
        accounts_userName = [0 for i in range(b)]
        accounts_platformId = [0 for i in range(b)]
        accounts_safeName = [0 for i in range(b)]
        #accounts_password = [0 for i in range(b)]
        t = 0
        while (t < b):
            accounts_id[t] = data1['value'][t]['id']
            accounts_name[t] = data1['value'][t]['name']
            accounts_address[t] = data1['value'][t]['address']
            accounts_userName[t] = data1['value'][t]['userName']
            accounts_platformId[t] = data1['value'][t]['platformId']
            accounts_safeName[t] = data1['value'][t]['safeName']
            password_url = CYBR_URL + '/PasswordVault/api/Accounts/' + data1['value'][t]['id'] + '/Password/Retrieve'
            account_password = requests.post(password_url, headers=token_header)
            #fo.write('\n'+accounts_id[t]+','+accounts_name[t]+','+accounts_address[t]+','+accounts_userName[t]+','+accounts_platformId[t]+','+accounts_safeName[t]+','+account_password[t])
            fo.write(data1['value'][t]['id']+','+data1['value'][t]['name']+','+data1['value'][t]['address']+','+data1['value'][t]['userName']+','+data1['value'][t]['platformId']+','+data1['value'][t]['safeName']+','+account_password.json()+'\n')
            t = t + 1

fo.close()
print("All non-internal accounts are exported to output.csv under current folder.")
os.system('pause')
