use Test::More;
use lib 't/lib';
use_ok('TestApp::Home');

ok( TestApp::Home->get() =~ /\/t$/ );

ok(0); # CI notification test

done_testing();
