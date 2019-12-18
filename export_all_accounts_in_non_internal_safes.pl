use LWP;
use Encode;
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Headers;
use HTTP::Response;
use Encode;
use URI::Escape;
use URI::URL;
use JSON;
use Data::Dumper;

my $CYBR_URL = "https://192.168.203.11";
my $CYBR_username = "administrator";
my $CYBR_password = "Cyberark1";


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

##list all safes #####
my $list_safes_url = $CYBR_URL."/PasswordVault/api/Safes";
my $header = ['Content-Type' => 'application/json; charset=UTF-8', 'Authorization' => $auth_header_value]; 
my $res = $ua->head( $list_safes_url , 'Authorization' => $auth_header_value);
$res = $ua->get( $list_safes_url,'Authorization' => $auth_header_value );
my $output = $res->decoded_content;
my $obj = decode_json($output);
for my $item(@{$obj->{'Safes'}})                                                                                                           
{                                                                                                                                               
  $cast .= $item->{'SafeName'}.",";                                                                                                                 
}
my $target_safes;
my @safename=split(/,/,$cast);
my @system_safes=('VaultInternal','Notification Engine','PasswordManager','PasswordManager_Pending','AccountsFeedADAccounts','AccountsFeedDiscoveryLogs','PVWAReports','PVWATicketingSystem','PVWAPublicData','PSM','PSMUniversalConnectors','PSMRecordings','PSMPADBUserProfile','PSMPADBridgeCustom','PIMSuRecordings');
$length=split(/,/,$cast);

for (my $temp=0;$temp<$length ;$temp++) {
  if ( grep {$safename[$temp] eq $_} @system_safes ){}
  else {$target_safes .= $safename[$temp].",";}
}
@safename=split(/,/,$target_safes);
#print @safename;

##list accounts in safe####

foreach(@safename)
{ 
  chomp($_);
my $list_accounts_in_safe_url = $CYBR_URL."/PasswordVault/api/Accounts?limit=1000&filter=safeName eq ".$_;
my $header = ['Content-Type' => 'application/json; charset=UTF-8', 'Authorization' => $auth_header_value]; 
my $res = $ua->head( $list_accounts_in_safe_url , 'Authorization' => $auth_header_value);
$res = $ua->get( $list_accounts_in_safe_url,'Authorization' => $auth_header_value );
my $output = $res->decoded_content;
my $obj = decode_json($output);

open ($csv, ">", "output.csv");
  print $csv "id,object name,address,username,platformId,safeName,password\n";
close($csv);
open ($output, ">>", "output.csv");

for my $item(@{$obj->{'value'}})                                                                                                           
{                                                                                                                                               
 my $accounts_id = $item->{'id'};
 my $accounts_name = $item->{'name'};                                                                                                               
 my $accounts_address = $item->{'address'};                                                                                                               
 my $accounts_userName = $item->{'userName'};                                                                                                               
 my $accounts_platformId = $item->{'platformId'};                                                                                                               
 my $accounts_safeName = $item->{'safeName'};                                                                                                               
my $account_passwd_url = $CYBR_URL."/PasswordVault/api/Accounts/".$item->{'id'}."/Password/Retrieve";                                                                                                            
my $post = {
 "reason"=>"export password"
 };
    $json_string = encode_json($post);  
    my $req = HTTP::Request->new('POST' => $account_passwd_url);
        $req->content_type('application/json; charset=UTF-8');
        $req->header( 'Authorization' => $auth_header_value );
        $req->content("$json_string");
        my $res = $ua->request($req);
        my $accounts_password = $res->content();
        $accounts_password=~s/^"//g;
        $accounts_password=~s/"$//g;
        #print $accounts_password."\n";
        print $output $accounts_id.",".$accounts_name.",".$accounts_address.",".$accounts_userName.",".$accounts_platformId.",".$accounts_safeName.",".$accounts_password."\n";

}
}
close($output);

