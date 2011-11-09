package Ze::View::Xslate;
use Ze::Class;
use base qw(Ze::View::Base);
use Text::Xslate;

has '+extention' => ( default => '.tx' );

sub render {
    my $self = shift ;
    my $args = shift;
     my $vars = $args->{vars} || {};
    my $out = '';
    if ( my $file = $args->{file} ) {
        $file .= $self->extention;
        $out = $self->engine->render( $file , $vars ) ;
    }
    return $out;
}

sub _build_engine {
    my $self = shift;
    my $config = $self->build_config;
    return Text::Xslate->new( %$config );
}

sub build_config {
    my $self = shift;
    my %config = (%{$self->default_config},%{$self->config});
    return \%config;
}

sub _build_default_config { 
    {
        syntax => 'TTerse',
        cache  => 1,
    }
}

EOC;
