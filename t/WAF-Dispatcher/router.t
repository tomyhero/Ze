use Test::More;
use lib 't/lib';

use_ok('TestApp::WAF::Dispatcher::Router');

my $dispatcher = TestApp::WAF::Dispatcher::Router->new( waf_class => 'TestApp::PC' );

isa_ok($dispatcher,'TestApp::WAF::Dispatcher::Router');

subtest 'setup_router' => sub {
    like($dispatcher->config_file, qr/\/t\/etc\/router.pl$/);
    isa_ok($dispatcher->router, 'Router::Simple');
};

subtest 'setup_controller' => sub {
    # use ok
    my $root = TestApp::PC::Controller::Root->new();      
    isa_ok($root,'TestApp::PC::Controller::Root');
};

subtest 'match' => sub {
    use TestApp::WAF::Context;
    my $context = TestApp::WAF::Context->new( dispatcher => $dispatcher , env => { REQUEST_METHOD => 'GET', PATH_INFO => '/', HTTP_HOST => 'localhost'} );
    my ($controller,$action) = $dispatcher->match($context);

    is($controller,'Root');
    is($action,'index');

};


done_testing();
