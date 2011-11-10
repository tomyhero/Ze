use Test::More;
use lib 't/lib';
use TestApp::PC::View;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use TestApp::WAF::Dispatcher::Router;
use TestApp::WAF::Context;

use_ok('TestApp::PC::View');

my $view = TestApp::PC::View->new();

my $engine = $view->engine();

isa_ok($engine,'Ze::View');


my $dispatcher = TestApp::WAF::Dispatcher::Router->new( waf_class => 'TestApp::PC' );

subtest 'body content' => sub {
    my $req = HTTP::Request->new( GET => 'http://localhost/test' );
    my $env = $req->to_psgi;
    my $c = TestApp::WAF::Context->new( dispatcher => $dispatcher , env => $env );
    $c->stash->{name} = 'teranishi';

    $view->render($c);

    is($c->res->body,"TEST : teranishi\n");
    is($c->res->content_type,'text/html');
    is($c->res->headers->content_type_charset,'UTF-8');

};


done_testing();
