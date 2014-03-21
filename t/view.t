use Test::More;
use lib 't/lib';
use TestApp::Home;
use Test::Exception;
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

my $value = 1;
$value = bless \$value;
throws_ok { $view->render('JSON', { vars => { key => $value } } ) } qr/t\/view\.t/, 'lay a trip on caller';

is($view->get_extension('Xslate'),'.tx');

done_testing;
