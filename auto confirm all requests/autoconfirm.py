#coding=utf-8
import requests
from tkinter import *
import stdiomask
import os
import sys

a = len(sys.argv)
if a < 4:
    print("Please input PVWA IP/FQDN, username and password with space\nSuch as 'autoconfirm.exe 1.1.1.1 user passwd'")
else:
    IP_ADDR = sys.argv[1]
    USERNAME = sys.argv[2]
    PASSWD = sys.argv[3]

    CYBR_URL = 'https://' + IP_ADDR
    LOGON_URL = CYBR_URL + '/PasswordVault/API/auth/Cyberark/Logon'
    INCOMING_REQUEST = CYBR_URL + '/PasswordVault/api/IncomingRequests'
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
    incoming = requests.get(INCOMING_REQUEST, headers=token_header)
    data1 = incoming.json()
    if data1['Total'] :
         a = data1['IncomingRequests']
         b = data1['Total']
         request_id = [0 for i in range(b)]
         t = 0
         while (t < b):
             request_id[t]=data1['IncomingRequests'][t]['RequestID']
             t = t + 1
         for ids in request_id:
              CONFIRM_URL = CYBR_URL + '/PasswordVault/api/incomingrequests/' + ids + '/confirm'
              payload = {"Reason": "auto confirm"}
              confirm_request = requests.post(CONFIRM_URL, headers=token_header, data=payload)
              confirm_status = confirm_request.status_code
              if (confirm_status == 200) :
                   print("Confirm success for request ID: " + ids)
              else:
                   print("Confirm failed!\n" + str(confirm_status) + " " + confirm_request.text)  # print session token
    else:
         print("No new request need to confirm")
