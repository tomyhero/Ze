package TestApp::PC::Controller::Root;
use Ze::Class;
extends 'Ze::WAF::Controller';

sub index {
    my ($self,$c) = @_;
    $c->res->body('hello Ze');
}


EOC;
