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
open USERLIST , $importfilename;


print "Enter the default password for the users: ";
my $CYBR_initialpassword = <STDIN>;
chomp $CYBR_initialpassword;

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
 #   print $auth_header_value;


## add EPVUsers from userlist.txt######
my $addepvuser_url = $CYBR_URL."/PasswordVault/api/Users";

foreach (<USERLIST>) {
  chomp($_);
  my $post = {
    "username"=>$_,
    "userType"=>"EPVUser",
    "initialPassword"=>$CYBR_initialpassword
};
    $json_string = encode_json($post);  
    my $req = HTTP::Request->new('POST' => $addepvuser_url);
        $req->content_type('application/json; charset=UTF-8');
        $req->header( 'Authorization' => $auth_header_value );
        $req->content("$json_string");
        my $res = $ua->request($req);
       
};

close(USERLIST);
