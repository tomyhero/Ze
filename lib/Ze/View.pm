package Ze::View;
use Ze::Class;
use Module::Pluggable::Object;
use Mouse::Util;

our $VERSION = '0.03';

has 'engines' => (
    is => 'rw',
    default => sub { [] }, 
);

has 'engine_holder' => (
        is => 'rw',
        lazy_build => 1,
        );


sub BUILD {
    my $self = shift;
    # LOADING ..
    $self->engine_holder;
}

sub _build_engine_holder {
    my $self = shift;
    my $holder = {};
    for(@{$self->engines}){
        my $pkg = $_->{engine};
        Mouse::Util::load_class($pkg);
        my $obj = $pkg->new( config => $_->{config} || {} );
        $holder->{$obj->name} = $obj;
    }
    return $holder;
}

sub engine {
    my $self = shift;
    my $name = shift;
    return $self->engine_holder->{$name};
}

sub render {
    my $self = shift;
    my $type = shift;
    my $args = shift || {};
    my $engine = $self->engine( $type );
    return $engine->render( $args );
}

sub get_extention {
    my $self = shift;
    my $type = shift;
    my $engine = $self->engine( $type )->extention;
}


EOC;
