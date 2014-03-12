package TestApp::PC::Controller::Root;
use Ze::Class;
extends 'Ze::WAF::Controller';
use Class::Trigger;

__PACKAGE__->add_trigger(
  BEFORE_DISPATCH => sub {
    my ($self,$c,$action) = @_; 
    $c->res->content_type('text/json'); 
  }
);

__PACKAGE__->add_trigger(
  AFTER_DISPATCH => sub {
    my ($self,$c,$action) = @_; 
    $c->res->header('hoge' => 'hoge'); 
  }
);

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
