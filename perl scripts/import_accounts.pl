use LWP;
use Encode;
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Headers;
use HTTP::Response;
use URI::Escape;
use URI::URL;
use JSON;
use Data::Dumper;

my $account_safe = "";

print "Enter your PVWA IP: ";
my $CYBR_URL = <STDIN>;
chomp $CYBR_URL;
$CYBR_URL = "https://".$CYBR_URL;

print "Enter your PVWA Username: ";
my $CYBR_username = <STDIN>;
chomp $CYBR_username;

print "Enter your PVWA Password: ";
use Term::ReadKey;
 ReadMode('noecho');
 my $CYBR_password = ReadLine(0);
 chomp($CYBR_password);
ReadMode(0);

print "\nEnter your file name, the file should be in same folder with the script: ";
my $importfilename = <STDIN>;
chomp $importfilename;

#my $CYBR_URL = "https://192.168.203.11";
#my $CYBR_username = "administrator";
#my $CYBR_password = "Cyberark1";
#my $importfilename = "output1.csv";

my $count = 0;
  my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0},);
     $ua->agent("Mozilla/8.0");
  
   my     $login_url =$CYBR_URL."/PasswordVault/API/auth/Cyberark/Logon";  
   my $post = {
        
          "username"=>$CYBR_username,
          "password"=>$CYBR_password,
      };  
    use JSON qw(encode_json);  
    $json_string = encode_json($post);  
  
    my $req = HTTP::Request->new('POST' => $login_url);
    $req->content_type('application/json; charset=UTF-8')  
      ;    #post请求,如果有发送参数，必须要有这句  
    $req->content("$json_string");    #发送post的参数  
    my $res = $ua->request($req);  
    my $auth_header_value = $res->content();            #获取的是响应正文
    $auth_header_value=~s/"//g;
	
open (READ, "<", $importfilename);
$count++ while <READ>;
my $num = $count - 1;
close READ;
print "Total $num accounts neet to be imported.\n";
open (READ, "<", $importfilename);
readline READ; # skip the first line
while(<READ>)
{
$count--;
print "import No.$count\n";
@temp=split(/,/,$_);
$account_address = $temp[2];
$account_username = $temp[3];
$account_platform = $temp[4];
$account_safe = $temp[5];
$account_password = $temp[6];
$account_name = $account_username."-".$account_address."-".$account_platform;

	
	   my $post_account = {
        
  "name"=> $account_name,
  "address"=> $account_address,
  "userName"=> $account_username,
  "platformId"=> $account_platform,
  "safeName"=> $account_safe,
  "secret" => $account_password,
  "secretType"=> "password"
      };  
    use JSON qw(encode_json);  
	my $add_account_url = $CYBR_URL."/PasswordVault/api/Accounts";
    $json_string = encode_json($post_account);
	    my $req = HTTP::Request->new('POST' => $add_account_url);
        $req->content_type('application/json; charset=UTF-8');
        $req->header( 'Authorization' => $auth_header_value );
        $req->content("$json_string");
        my $res = $ua->request($req);
		my $code = $res->code();
#my $output = $res->decoded_content;
#my $obj = decode_json($output);
#for my $item(@{$obj->{'Details'}})                                                                                                           
#{                                                                                                                                               
#  $cast .= $item->{'ErrorCode'};                                                                                                                 
#}   
                  
#if($cast eq "PASWS031E" && $count > 0)
if( $code > 399 && $count > 0 )
{

my $add_safe_url = $CYBR_URL."/PasswordVault/api/Safes";
my $post1 = {
"SafeName"=> $account_safe,
"NumberOfVersionsRetention"=> "7",
"ManagingCPM"=> "PasswordManager",
};


    my $json_string1 = encode_json($post1);
	    my $req1 = HTTP::Request->new('POST' => $add_safe_url);
        $req1->content_type('application/json; charset=UTF-8');
        $req1->header( 'Authorization' => $auth_header_value );
        $req1->content($json_string1);
		my $res1 = $ua->request($req1);
	
		 my $post_safemember = {
            "MemberType"=>"Group",
            "IsPredefinedUser"=>"true",
            "MemberName"=> "Vault Admins",
            "IsExpiredMembershipEnable"=> "false",
            "Permissions"=> {
                "UseAccounts"=> "true",
                "RetrieveAccounts"=> "true",
                "ListAccounts"=> "true",
                "AddAccounts"=> "true",
                "UpdateAccountContent"=> "true",
                "UpdateAccountProperties"=> "true",
                "InitiateCPMAccountManagementOperations"=> "true",
                "SpecifyNextAccountContent"=> "true",
                "RenameAccounts"=> "true",
                "DeleteAccounts"=> "true",
                "UnlockAccounts"=> "true",
                "ManageSafe"=> "true",
                "ManageSafeMembers"=> "true",
                "BackupSafe"=> "true",
                "ViewAuditLog"=> "true",
                "ViewSafeMembers"=> "true",
                "AccessWithoutConfirmation"=> "true",
                "CreateFolders"=> "true",
                "DeleteFolders"=> "true",
                "MoveAccountsAndFolders"=> "true",
                "RequestsAuthorizationLevel1"=> "true",
                "RequestsAuthorizationLevel2"=> "true",
            }
        };
		my $add_safemember_url = $CYBR_URL."/PasswordVault/api/Safes/".$account_safe."/Members";
    my $json_string2 = encode_json($post_safemember);
	    my $req2 = HTTP::Request->new('POST' => $add_safemember_url);
        $req2->content_type('application/json; charset=UTF-8');
        $req2->header( 'Authorization' => $auth_header_value );
        $req2->content($json_string2);
		my $res2 = $ua->request($req2);


    my $json_string = encode_json($post_account);
	    my $req = HTTP::Request->new('POST' => $add_account_url);
        $req->content_type('application/json; charset=UTF-8');
        $req->header( 'Authorization' => $auth_header_value );
        $req->content("$json_string");
        my $res = $ua->request($req);
#	print $res->content();

}                                     
else
{
continue;
}
}
close READ;
print "import complete."