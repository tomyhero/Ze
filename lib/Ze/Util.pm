package Ze::Util;
use warnings;
use strict;
use Mouse::Util;


# SPEC. Application Class must be top level pacakge name
sub app_class {
    my $class = shift;
    my ($app_class ) = $class =~ m/^([a-zA-Z0-9_]+)::/;
    return $app_class;
}

sub home {
    my $class = shift;
    my $pkg = &app_class($class)  . '::Home';
    Mouse::Util::load_class( $pkg );
    return $pkg->instance;
}


1;
