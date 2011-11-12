package Ze::Config;
use strict;
use warnings;
use Path::Class;
use Ze::Util;

sub instance {
    my $class = shift;
    die "this is class method." if ref $class;
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };
    defined $$instance ? $$instance : ($$instance = $class->_new);
}

sub appname {
    my $self = shift;
    my $class = ref $self;
    return uc Ze::Util::app_class( $class );
}
sub _new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->load_config;
    $self;
}

sub get {
    my( $self, $key, $default ) = @_;
    return defined $self->{$key} ? $self->{$key} : $default;
}


sub load_config {
    my $self = shift;
    my $files = $self->get_config_files;
    my %config;

    for my $file( @{$files} ) {
        my $conf =  do($file->cleanup) || {};
        die $@ if $@;
        %config = ( %config, %{$conf} );
    }

    $self->{__FILES} = $files;
    $self->{__TIME} = time;
    for my $key( keys %config ) {
        $self->{$key} = $config{$key};
    }
    \%config;
}

sub home { 
    my $self = shift;
    my $class = ref $self ? ref $self : $self;;
    Ze::Util::home($class);
}

sub get_config_files {
    my $self = shift;
    my @files;
    my $home = $self->home;
    my $base = $home->file('etc/config.pl');
    push @files, $base;


    if ( my $env = $ENV{ $self->appname . '_ENV'} ) {
        my $filename = sprintf 'etc/config_%s.pl', $env;
        die "could not found local config file:" . $home->file($filename)  unless  -f $home->file($filename);
        push @files, $home->file( $filename );
    }
    return \@files;
}


1;
