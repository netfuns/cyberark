These Perl scripts are used for operate CyberArk Core PAS solution.
----------------------------------------------

export_all_accounts_in_non_internal_safes.pl
----------------------------------------------

#############################################

This perl script will export all accounts from non CyberArk internal safes.

You only need to change the below parameters to your own information.


my $CYBR_URL = "https://192.168.203.11";

my $CYBR_username = "administrator";

my $CYBR_password = "Cyberark1";

#############################################



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
