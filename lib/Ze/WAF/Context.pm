package Ze::WAF::Context;
use Ze::Class;
extends 'Ze::Component';
use Mouse::Util;
use Try::Tiny;

__PACKAGE__->mk_classdata('request_class' => 'Ze::WAF::Request');

has 'env' => ( is => 'rw' , required => 1 );
has 'dispatcher' => ( is => 'rw');
has 'req' => ( is => 'rw' );
has 'res' => ( is => 'rw' );
has 'args' => ( is => 'rw' , default => sub { { } } );
has 'finished' => ( is => 'rw' , default => 0 );


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

    if ( !$controller or !$action ) {
        $c->not_found;
        return $c->FINALIZE;
    }

    my $controller_obj = $c->dispatcher->controllers->{$controller};

    try {
        $controller_obj->EXCECUTE( $c ,$action ); 
    }
    catch {
        die $_ unless /^ZE_EXCEPTION_ABORT/;
    };

    unless ( $c->finished ) {
        $c->RENDER();
    }

    $c->FINALIZE();
}

sub abort { die 'ZE_EXCEPTION_ABORT'; }

sub RENDER {

}

sub FINALIZE {
    my $c = shift;
    return $c->res->finalize;
}


sub not_found {
    my $c = shift;
    $c->res->status( 404 );
    $c->body('NOT FOUND');
    $c->finished(1);
}

EOC;
