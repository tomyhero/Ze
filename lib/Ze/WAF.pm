package Ze::WAF;
use Ze::Class;
use Mouse::Util;
extends 'Ze::Component';

__PACKAGE__->mk_classdata('context_class');
__PACKAGE__->mk_classdata('dispatcher_class');
__PACKAGE__->mk_classdata('view_class');

has 'dispatcher' => ( is => 'rw');


sub BUILD {
    my $self = shift;
    $self->setup_dispatcher();
    $self->setup_view();
}


sub setup_config {

}

sub setup_view {
    my $self = shift;
    Mouse::Util::load_class( $self->view_class) ;
    my $view_obj= $self->view_class->new();
    $self->view( $view_obj );
}

sub setup_dispatcher {
    my $self = shift;
    Mouse::Util::load_class( $self->dispatcher_class) ;
    my $dispatcher_obj = $self->dispatcher_class->new( waf_class => ref $self );
    $self->dispatcher( $dispatcher_obj );
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
    my $c = $self->context_class->new( env => $env , dispatcher => $self->dispatcher );
    return $c;
}


EOC;
