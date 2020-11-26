#include "WinHttp.au3"
#include 'ExtInputBox.au3'
;Opt("MustDeclareVars", 1)



Local $sData = _ExtInputBox("Login", "Address, eg. 1.1.1.1/pvwa.demo.com|Username|Password", "", "3")
Local $URL = $sData[1]
Local $PVWAuser = $sData[2]
Local $PVWApass = $sData[3]
;Local $URL = "192.168.10.10"
;Local $PVWAuser = "administrator"
;Local $PVWApass = "Cyberark1"

Local $Logon = "/PasswordVault/API/auth/Cyberark/Logon"
Local $Jason = '{"username":"' & $PVWAuser & '", "password":"' & $PVWApass & '"}'

Local $hOpen = _WinHttpOpen()
Local $hConnect = _WinHttpConnect($hOpen, $URL)

Local $hRequest = _WinHttpOpenRequest($hConnect, "post", $Logon, Default,  Default,  Default, $WINHTTP_FLAG_SECURE)
local $CurrentOption = _WinHttpQueryOption($hRequest, $WINHTTP_OPTION_SECURITY_FLAGS)
local $NewOption = BitOR($CurrentOption, _
        $SECURITY_FLAG_IGNORE_UNKNOWN_CA, _
        $SECURITY_FLAG_IGNORE_CERT_CN_INVALID, _
        $SECURITY_FLAG_IGNORE_CERT_DATE_INVALID)
; set options
_WinHttpSetOption($hRequest, $WINHTTP_OPTION_SECURITY_FLAGS, $NewOption)

; Send request
_WinHttpSendRequest($hRequest,"Content-type: application/json",$Jason)

; Wait for the response
_WinHttpReceiveResponse($hRequest)

; ...get full header
;Local $sHeader = _WinHttpQueryHeaders($hRequest)

; ...get full data
Local $AUTHtoken = _WinHttpReadData($hRequest)
$AUTHtoken = StringReplace($AUTHtoken, '"', '')

; Clean/Close handles
_WinHttpCloseHandle($hRequest)
_WinHttpCloseHandle($hConnect)
_WinHttpCloseHandle($hOpen)

; Display retrieved header
;MsgBox(0, "Header", $sHeader)

; Display retrieved data
;MsgBox(0, "Data", $AUTHtoken)
;ConsoleWrite($AUTHtoken)



Local $list_safes_url = "/PasswordVault/api/Safes"
Local $AUTHheader = '"Authorization: ' & $AUTHtoken  & ',Content-type: application/json"'
;ConsoleWrite($AUTHheader)

Local $hOpen = _WinHttpOpen()
Local $hConnect = _WinHttpConnect($hOpen, $URL)
Local $hRequest_safe = _WinHttpOpenRequest($hConnect, "get", $list_safes_url, Default,  Default,  Default, $WINHTTP_FLAG_SECURE)
_WinHttpAddRequestHeaders($hRequest_safe, "Authorization: " & $AUTHtoken)
_WinHttpSetOption($hRequest_safe, $WINHTTP_OPTION_SECURITY_FLAGS, $NewOption)
_WinHttpSendRequest($hRequest_safe)
_WinHttpReceiveResponse($hRequest_safe)
Local $safes_list = _WinHttpReadData($hRequest_safe)
;Local $sHeader = _WinHttpQueryHeaders($hRequest)
;ConsoleWrite($safes_list)
;ConsoleWrite($sHeader)
_WinHttpCloseHandle($hRequest)


    Local $output_file = @ScriptDir & "\Output.csv"
    DeleteFile($output_file)
    FileWrite($output_file, "id,UserName,address,platformId,safeName,Password" & @CRLF)


#include "oojson.au3"
Local $var = $safes_list
Local $oJSON = _OO_JSON_Init()

Local $jsObj = $oJSON.parse($var)
For $i = 0 to $jsObj.Safes.length - 1
  
   if $jsObj.Safes.item($i).SafeName <> "VaultInternal" And $jsObj.Safes.item($i).SafeName <> "Notification Engine" and $jsObj.Safes.item($i).SafeName <> "PVWAReports"  and $jsObj.Safes.item($i).SafeName <> "PVWATicketingSystem" and $jsObj.Safes.item($i).SafeName <> "PVWAPublicData" and $jsObj.Safes.item($i).SafeName <> "PasswordManager" and $jsObj.Safes.item($i).SafeName <> "PasswordManager_Pending"  and $jsObj.Safes.item($i).SafeName <> "AccountsFeedADAccounts"  and $jsObj.Safes.item($i).SafeName <> "AccountsFeedADAccounts" and $jsObj.Safes.item($i).SafeName <> "AccountsFeedDiscoveryLogs" and $jsObj.Safes.item($i).SafeName <> "PSM" and $jsObj.Safes.item($i).SafeName <> "PSMUniversalConnectors" Then
   
   ;ConsoleWrite("id found ->" & $jsObj.Safes.item($i).SafeName & @CR)
	  
	  Local $list_accounts_in_safe_url = '/PasswordVault/api/Accounts?limit=1000&filter=safeName eq ' & $jsObj.Safes.item($i).SafeName
	  Local $hRequest_accounts = _WinHttpOpenRequest($hConnect, "get", $list_accounts_in_safe_url, Default,  Default,  Default, $WINHTTP_FLAG_SECURE)
	_WinHttpAddRequestHeaders($hRequest_accounts, "Authorization: " & $AUTHtoken)
	_WinHttpSetOption($hRequest_accounts, $WINHTTP_OPTION_SECURITY_FLAGS, $NewOption)
	_WinHttpSendRequest($hRequest_accounts)
	_WinHttpReceiveResponse($hRequest_accounts)
	Local $accounts_list = _WinHttpReadData($hRequest_accounts)
	;ConsoleWrite($accounts_list)
	
	_WinHttpCloseHandle($hRequest_accounts)
	
	Local $accounts_var = $accounts_list
	Local $oJSON_accounts = _OO_JSON_Init()
	Local $jsObj_accounts = $oJSON_accounts.parse($accounts_var)
	For $j = 0 to $jsObj_accounts.value.length - 1
		Local $acc_id = $jsObj_accounts.value.item($j).id
		Local $acc_username = $jsObj_accounts.value.item($j).userName
		Local $acc_address = $jsObj_accounts.value.item($j).address
		Local $acc_platformId = $jsObj_accounts.value.item($j).platformId
		Local $acc_safeName = $jsObj_accounts.value.item($j).safeName
	Local $account_passwd_url = "/PasswordVault/api/Accounts/" & $acc_id & "/Password/Retrieve";
	Local $hRequest_password = _WinHttpOpenRequest($hConnect, "post", $account_passwd_url, Default,  Default,  Default, $WINHTTP_FLAG_SECURE)
	_WinHttpAddRequestHeaders($hRequest_password, "Authorization: " & $AUTHtoken)
	_WinHttpSetOption($hRequest_password, $WINHTTP_OPTION_SECURITY_FLAGS, $NewOption)
	_WinHttpSendRequest($hRequest_password)
	_WinHttpReceiveResponse($hRequest_password)
	Local $accounts_password = _WinHttpReadData($hRequest_password)
	;ConsoleWrite($accounts_password)
	_WinHttpCloseHandle($hRequest_password)
	Local $CSV_input = $acc_id & "," & $acc_username & "," & $acc_address & "," & $acc_platformId & "," & $acc_safeName & "," & $accounts_password
	FileWrite($output_file, $CSV_input & @CRLF)

	Next
endif
next 
Exit

Func DeleteFile($file) ; è unito con  _Spediamo_it_CSV()

    $file_usage = FileOpen($file, 1)

    If $file_usage = -1 Then
        MsgBox(0, @ScriptName, $file & " is in use." & @CRLF & _
                'Please close it before continuing.')
        Exit
    EndIf

    FileClose($file_usage)

    If FileExists($file) Then
        FileDelete($file)
    EndIf

EndFunc   ;==>DeleteFile