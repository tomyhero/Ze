use Test::More;
use lib 't/lib';
use TestApp::Class;
use Encode;

my $obj= TestApp::Class->new();

ok( Encode::is_utf8($obj->string) , 'utf8 on');



done_testing();


