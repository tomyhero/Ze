package Ze::WAF;
use Ze::Class;
use Mouse::Util;


has 'dispatcher' => ( is => 'rw');
has 'view' => ( is => 'rw');

has ['context_class','dispatcher_class','view_class'] => (
    is => 'rw',
    lazy_build => 1,
);

sub BUILD {
    my $self = shift;
    $self->setup_dispatcher();
    $self->setup_view();
    $self->setup_context();
}

sub _build_context_class {
    my $self = shift;
    my $class = ref $self;
    my $pkg = $class . '::Context';
    Mouse::Util::load_class( $pkg ) ;
    return $pkg;
}

sub _build_dispatcher_class {
    my $self = shift;
    my $class = ref $self;
    my $pkg = $class . '::Dispatcher';
    Mouse::Util::load_class( $pkg ) ;
    return $pkg;
}

sub _build_view_class {
    my $self = shift;
    my $class = ref $self;
    my $pkg = $class . '::View';
    Mouse::Util::load_class( $pkg ) ;
    return $pkg;
}

sub setup_context {
    my $self = shift;
    $self->context_class;
}

sub setup_view {
    my $self = shift;
    my $view_obj= $self->view_class->new();
    $self->view( $view_obj );
}

sub setup_dispatcher {
    my $self = shift;
    my $dispatcher_obj = $self->dispatcher_class->new( waf_class => ref $self );
    $self->dispatcher( $dispatcher_obj );
}

sub to_app {
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
    my $c = $self->context_class->new( env => $env , dispatcher => $self->dispatcher , view => $self->view );
    return $c;
}


EOC;
