package Ze::WAF::Context;
use Ze::Class;
extends 'Ze::Component';
use Ze::Util;
use Mouse::Util;
use Try::Tiny;

__PACKAGE__->mk_classdata('request_class' => 'Ze::WAF::Request');
__PACKAGE__->mk_classdata('context_config' => {} );

has 'env' => ( is => 'rw' , required => 1 );
has 'dispatcher' => ( is => 'rw');
has 'view' => ( is => 'rw');
has 'req' => ( is => 'rw' );
has 'res' => ( is => 'rw' );
has 'template' => ( is => 'rw');
has 'view_type' => ( is => 'rw');
has 'stash' => ( is => 'rw' , default => sub { {} } );
has 'args' => ( is => 'rw' , default => sub { { } } );
has 'finished' => ( is => 'rw' , default => 0 );
has 'config' => (is => 'rw', lazy_build => 1 );

with 'Ze::Role::Pluggable';


sub BUILD {
    my $c = shift;
    $c->setup_request;
    $c->setup_response;
}

sub _build_config{
    return Ze::Util::config(shift);
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
    $c->res->code(200);
}

sub dispatch {
    my $c = shift;
    $c->INITIALIZE;

    my ($controller,$action) = $c->dispatcher->match( $c );

    if ( !$controller or !$action ) {
        $c->not_found;
        return $c->FINALIZE;
    }

    my $controller_obj = $c->dispatcher->controllers->{$controller};

    try {
        $c->PREPARE;
        $controller_obj->EXECUTE( $c ,$action ); 
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

sub INITIALIZE{ }
sub PREPARE { } 

sub RENDER {
    my $c = shift;
    $c->view->render($c);
}

sub FINALIZE {
    my $c = shift;
    return $c->res->finalize;
}


sub not_found {
    my $c = shift;
    $c->res->status( 404 );
    $c->res->body('NOT FOUND');
    $c->res->content_type( 'text/html;charset=utf-8' );
    $c->finished(1);
}

sub redirect {
    my( $c, $url, $code ) = @_;
    $code ||= 302;
    $c->res->status( $code );
    $c->res->redirect( $url );
    #$url = ($url =~ m{^https?://}) ? $url : $c->uri_for( $url );
    #$c->res->headers->header(Location => $url);
    $c->finished(1);
}

EOC;
