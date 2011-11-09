use Test::More;
use lib 't/lib';
use_ok('TestApp::Config');

subtest 'home ok' => sub {
    my $self = shift;
    my $home = TestApp::Config->home;
    ok( $home =~ /\/t$/);
};


subtest 'intsance' => sub {
    my $config = TestApp::Config->instance();
    my $config2 = TestApp::Config->instance();
    is( $config->{__TIME} , $config2->{__TIME});
};

subtest 'appname' => sub {
    my $config = TestApp::Config->instance();
    is( $config->appname(), 'TESTAPP');
};

subtest 'get_config_files' => sub {
    my $config = TestApp::Config->instance();
    my $files = $config->get_config_files();
    is( scalar @$files, 1);
    ok( $files->[0]->stringify =~  /\/t\/etc\/config\.pl$/);
};



subtest 'load_config' => sub {
    my $config = TestApp::Config->instance();
    $config->load_config();
    is($config->{name} , 'origin');
    is($config->{type} , 'xxx');
};


subtest 'get_config_files local' => sub {
    my $config = TestApp::Config->instance();
    $ENV{TESTAPP_ENV}  = 'test';
    my $files = $config->get_config_files();
    is( scalar @$files, 2);
    ok( $files->[0]->stringify =~  /\/t\/etc\/config\.pl$/);
    ok( $files->[1]->stringify =~  /\/t\/etc\/config_test\.pl$/);
};


subtest 'load_config local' => sub {
    my $config = TestApp::Config->instance();
    $config->load_config();
    is($config->{name} , 'test');
    is($config->{type} , 'xxx');
};


done_testing();
