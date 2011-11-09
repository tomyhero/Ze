use Test::More;
use utf8;
use lib 't/lib';
use TestApp::Home;

use_ok('Ze::View::Xslate');

my $path = TestApp::Home->get()->subdir('view-test');
my $engine = Ze::View::Xslate->new( config => { path => $path  } );

subtest 'config' => sub {

    is_deeply($engine->build_config, {
        syntax => 'TTerse',
        cache  => 1,
        path   => $path,
    });

};

subtest 'engine' => sub {
    isa_ok($engine->engine,'Text::Xslate');
};

subtest 'render' => sub {
    my $out = $engine->render( { file => 'test' , vars => { name => 'teranishi' }  } );
    is($out,"TEST : teranishi\n");
};

done_testing();
