use Test::More;
use lib 'lib';
use lib 't/lib';
use TestApp::WAF::Dispatcher::Router;
use TestApp::PC::View;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

use_ok('TestApp::WAF::Context');


my $dispatcher = TestApp::WAF::Dispatcher::Router->new( waf_class => 'TestApp::PC' );
my $view = TestApp::PC::View->new();
subtest 'body content' => sub {

    my $req = HTTP::Request->new( GET => 'http://localhost/' );
    my $env = $req->to_psgi;

    my $c = TestApp::WAF::Context->new( dispatcher => $dispatcher , env => $env , view => $view );

    my $res = $c->dispatch();


    is_deeply($res, [
          200,
          [
          'Content-Type',
          'text/json',
          'Hoge',
          'hoge'
          ],
          [
            'hello Ze'
          ]
        ]
    );


};


subtest 'config' => sub {
    my $req = HTTP::Request->new( GET => 'http://localhost/' );
    my $env = $req->to_psgi;
    my $c = TestApp::WAF::Context->new( dispatcher => $dispatcher , env => $env , view => $view );

    is($c->config->get('name'),'origin');

};

subtest 'not found' => sub {

    my $req = HTTP::Request->new( GET => 'http://localhost/not-found/' );
    my $env = $req->to_psgi;

    my $c = TestApp::WAF::Context->new( dispatcher => $dispatcher , env => $env , view => $view );
    my $res = $c->dispatch();

    is_deeply($res,
        [
          404,
          [
            'Content-Type',
            'text/html;charset=utf-8'
          ],
          [
            'NOT FOUND'
          ]
        ]
    );
};


done_testing();
