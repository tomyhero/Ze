package Ze::Util;
use warnings;
use strict;
use Carp ();

sub appname {
    my $class = shift;
    if (my $appname = $ENV{ZE_APPNAME}) {
        return $appname;
    }
    if ( $class =~ m/^(.*?)::(Context|Config)$/ ) {
        my $appname = $1;
        return $appname;
    }
    Carp::croak("Could not determine APPNAME from either %ENV or classname ($class)");
}


1;
