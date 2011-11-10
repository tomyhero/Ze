package Ze::WAF;
use Ze::Class;
use Mouse::Util;
extends 'Ze::Component';

__PACKAGE__->mk_classdata('context_class');


sub BUILD {
    my $self = shift;
    $self->setup_request();
}

sub setup_request {
    my $self = shift;
    Mouse::Util::load_class( $self->request_class );
}

sub setup_config {

}
sub create_config {

}
sub setup_context {

}
sub setup_view {

}
sub setup_dispatcher {

}

sub handler {
    my $self = shift;

    my $app = sub {
        my $env = shift;
        my $c = $self->prepare_context( $env );
        $c->dispatch();

    };

    return $app;
}

sub prepare_context {
    my $self = shift;
    my $env = shift;
    my $c = $self->context_class->new();
    my $req = $self->request_class->new( $env );
    $c->req($req);
    $c->res($req->new_response);
    return $c;
}


EOC;
