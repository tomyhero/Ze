use Test::More;

use_ok('Ze::Util');

is( Ze::Util::app_class('MyApp::Hoge::Foo'), 'MyApp' );




done_testing();
