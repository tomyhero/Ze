package Ze::Role::Pluggable;
use Carp ();
use Ze::Role;
use Mouse::Util;

sub load_plugin {
    my $self = shift;
    $self->load_plugins(@_);
}

sub load_plugins {
    my ( $self, @roles ) = @_;
    $self->_load_and_apply_role(reverse @roles) ;
    1;
}

sub _load_and_apply_role {
    my ( $self, @roles ) = @_;
    Mouse::Util::apply_all_roles(( $self, @roles )) ;
    return 1;
}

1;
