package TestApp::PC::Controller::Root;
use Ze::Class;
extends 'Ze::WAF::Controller';

sub index {
    my ($self,$c) = @_;
    $c->res->body('hello Ze');
}


sub test {
    my ($self,$c) = @_;
    $c->res->content_type( 'text/html;charset=utf-8' );
    $c->stash->{name} = 'teranishi';
}


sub ja {
    my ($self,$c) = @_;
    $c->stash->{name} = '日本語';
}

EOC;
