package Ze::View::Base;
use Ze::Class;

has 'name' => ( is => 'rw', lazy_build => 1);
has 'engine'         => ( is => 'rw', lazy_build => 1);
has 'default_config' => ( is => 'rw', lazy_build => 1);
has 'config'         => ( is => 'rw', default => sub { {} } );
has 'extension'      => ( is => 'rw', default => '.tmpl' );


sub _build_engine {
    die 'implement me';
}

sub _build_default_config { {} }

sub _build_name {
    my $self = shift;
    my @a = split('::', ref $self );
    return $a[-1];
}

EOC;
