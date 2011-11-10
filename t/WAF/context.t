use Test::More;
use lib 't/lib';
use TestApp::WAF::Dispatcher::Router;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use_ok('TestApp::WAF::Context');


my $dispatcher = TestApp::WAF::Dispatcher::Router->new( waf_class => 'TestApp::PC' );

subtest 'body content' => sub {

    my $req = HTTP::Request->new( GET => 'http://localhost/' );
    my $env = $req->to_psgi;

    my $c = TestApp::WAF::Context->new( dispatcher => $dispatcher , env => $env );

    my $res = $c->dispatch();


    is_deeply($res, [
          200,
          [
            'Content-Type',
            'text/html;charset=utf-8'
          ],
          [
            'hello Ze'
          ]
        ]
    );


};


subtest 'not found' => sub {

    my $req = HTTP::Request->new( GET => 'http://localhost/not-found/' );
    my $env = $req->to_psgi;

    my $c = TestApp::WAF::Context->new( dispatcher => $dispatcher , env => $env );
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
