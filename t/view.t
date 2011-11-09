use Test::More;
use lib 't/lib';
use TestApp::Home;
my $path = TestApp::Home->get()->subdir('view-test');


use_ok('Ze::View');

my $view = Ze::View->new( 
    engines => [
        { engine => 'Ze::View::Xslate' , config => { path => $path } }, 
        { engine => 'Ze::View::JSON', config  => {} } 
    ]
);

isa_ok($view,'Ze::View');

isa_ok( $view->engine('JSON'),'Ze::View::JSON');
isa_ok( $view->engine('Xslate'),'Ze::View::Xslate');

is($view->render('JSON',{ vars => { hoge => 'hoge' } } ),'{"hoge":"hoge"}');
is($view->render('Xslate',{ file => 'test', vars => { name => 'hoge' } } ),"TEST : hoge\n");

is($view->get_extention('Xslate'),'.tx');

done_testing;
