use Test::More;
use lib 't/lib';
use TestApp::WAF::Context;

use_ok('TestApp::PC::Controller::Root');

my $controller = TestApp::PC::Controller::Root->new();


my $c = TestApp::WAF::Context->new( env => { REQUEST_METHOD => 'GET', PATH_INFO => '/', HTTP_HOST => 'localhost'} );

$controller->EXCECUTE( $c,'index');

is($c->res->body, 'hello Ze');

done_testing();
