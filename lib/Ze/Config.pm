package Ze::Config;
use strict;
use warnings;
use Path::Class;
use Plack::Util::Accessor qw(appname);
use Ze::Util;

sub instance {
    my $class = shift;
    die "this is class method." if ref $class;
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };
    defined $$instance ? $$instance : ($$instance = $class->_new);
}

sub _new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->load_config;
    $self->{appname} = Ze::Util::appname( $class );
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
        my $conf =  do $file->cleanup ;
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

sub home { die 'ABSTRACT METHOD' }

sub get_config_files {
    my $self = shift;
    my @files;
    my $home = $self->home;
    my $base = $home->file('etc/config.pl');
    push @files, $base;

    if ( my $env = $ENV{ uc $self->appname . '_ENV'} ) {
        my $filename = sprintf 'etc/config_%s.pl', $env;
        die "could not found local config file:" . $home->file($filename)  unless  -f $home->file($filename);
        push @files, $home->file( $filename );
    }
    return \@files;
}

sub path_to {
    my $class = shift;
    $class->home->file(@_)->stringify;
}

1;
