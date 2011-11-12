use Test::More;
use lib 't/lib';
use Plack::Test;
use HTTP::Request;

use_ok('TestApp::PC');

my $app = TestApp::PC->new();

isa_ok($app,'TestApp::PC');


test_psgi 
    app => $app->to_app(),
    client => sub {
        my $cb  = shift;
        my $req = HTTP::Request->new(GET => "http://localhost/");
        my $res = $cb->($req);
        is $res->content, "hello Ze";
    };

test_psgi 
    app => $app->to_app(),
    client => sub {
        my $cb  = shift;
        my $req = HTTP::Request->new(GET => "http://localhost/test");
        my $res = $cb->($req);
        is $res->content, "TEST : teranishi\n";
    };

test_psgi 
    app => $app->to_app(),
    client => sub {
        my $cb  = shift;
        my $req = HTTP::Request->new(GET => "http://localhost/ja");
        my $res = $cb->($req);
        no utf8;
        is $res->content, "name : 日本語\n" , 'encode plugin';
    };


done_testing();
