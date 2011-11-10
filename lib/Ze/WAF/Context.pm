package Ze::WAF::Context;
use Ze::Class;
extends 'Ze::Component';
use Mouse::Util;

__PACKAGE__->mk_classdata('request_class' => 'Ze::WAF::Request');

has 'env' => ( is => 'rw' , required => 1 );
has 'dispatcher' => ( is => 'rw' , required => 1 );
has 'req' => ( is => 'rw' );
has 'res' => ( is => 'rw' );
has 'args' => ( is => 'rw' );


sub BUILD {
    my $c = shift;
    $c->setup_request;
    $c->setup_response;
}


sub setup_request {
    my $c =  shift;
    Mouse::Util::load_class( $c->request_class );
    $c->req( $c->request_class->new( $c->env ) );
    1;
}
sub setup_response {
    my $c =  shift;
    $c->res( $c->req()->new_response );
}

sub dispatch {
    my $c = shift;
    my ($controller,$action) = $c->dispatcher->match( $c );



}

EOC;
