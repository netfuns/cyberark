These Perl scripts are used for operate CyberArk Core PAS solution.
First of all, you should prepare the perl ENV before you run the scripts.
For windows OS, you should download and install ActivePerl.
Then run command 'perl -MCPAN -e shell' in CMD with administrator's role.
Install the CPAN with 'install' command like below samples:

install LWP
install Encode
install HTTP::Cookies
install URI::Escape
install URI::URL
install JSON
install Data::Dumper

----------------------------------------------

export_all_accounts_in_non_internal_safes.pl
----------------------------------------------

#############################################

This perl script will export all accounts from non CyberArk internal safes.

#############################################


----------------------------------------------

export_all_accounts_in_non_internal_safes.pl
----------------------------------------------

############################################
import all accounts in csv file.
The file format should be same as the export_all_accounts_in_non_internal_safes.pl exported file.
############################################

----------------------------------------------

perl_bulk_add_epv_users.pl
----------------------------------------------

#############################################

This perl script will load userlist.txt then bulk add epv users into Cyberark Vault.

You only need to change the below parameters to your own information.

open USERLIST , "userlist.txt";

my $CYBR_URL = "https://192.168.203.11";

my $CYBR_username = "administrator";

my $CYBR_password = "Cyberark1";

my $CYBR_initialpassword = "Cyberark1";

#############################################

Use AutoIT to export all non internal accounts

Use AutoIT to export all non internal accounts to CSV file.
Put export_accounts.exe Keys_polyfill.txt jsonpath-0.8.0.js json2.txt in the same folder, then run export_accounts.exe.
The source code is export_accounts.au3
