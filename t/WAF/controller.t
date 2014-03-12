use Test::More;
use lib 'lib';
use lib 't/lib';
use TestApp::WAF::Context;

use_ok('TestApp::PC::Controller::Root');

my $controller = TestApp::PC::Controller::Root->new();


my $c = TestApp::WAF::Context->new( env => { REQUEST_METHOD => 'GET', PATH_INFO => '/', HTTP_HOST => 'localhost'} );

$controller->EXECUTE( $c,'index');

is($c->res->body, 'hello Ze');
is($c->res->content_type,'text/json');
is($c->res->header('hoge'),'hoge');

done_testing();
