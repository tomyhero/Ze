package Ze::Util;
use warnings;
use strict;
use Mouse::Util();
use Storable();
use Digest::MD5();


# SPEC. Application Class must be top level pacakge name
sub app_class {
    my $class = shift;
    $class = ref $class if ref $class;
    my ($app_class ) = $class =~ m/^([a-zA-Z0-9_]+)::/;
    return $app_class;
}

sub home {
    my $class = shift;
    my $pkg = &app_class($class)  . '::Home';
    Mouse::Util::load_class( $pkg );
    return $pkg->instance;
}

sub config {
    my $class = shift;
    my $pkg = &app_class($class)  . '::Config';
    Mouse::Util::load_class( $pkg );
    return $pkg->instance;
}


sub data2key {
    my $hash = shift || {};
    return Digest::MD5::md5_hex( Storable::nfreeze($hash) );

}

1;
