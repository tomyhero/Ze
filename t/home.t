use Test::More;
use lib 't/lib';
use_ok('TestApp::Home');

ok( TestApp::Home->get() =~ /\/t$/ );

done_testing();
