use Test::More;
use lib 't/lib';
use TestApp::Class;
use Encode;
use Test::Mouse;

my $obj= TestApp::Class->new();



meta_ok($obj,'mouse obj');
has_attribute_ok($obj,'hoge');

ok( Encode::is_utf8($obj->string) , 'utf8 on');

is(TestApp::Class->meta->is_immutable,1,'immutable ok');



done_testing();
