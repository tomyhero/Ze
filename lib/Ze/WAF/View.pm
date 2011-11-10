package Ze::WAF::View;
use Ze::Class;
use Mouse::Util;
use Encode;

has default_type => (
    is => 'rw',
    default => 'Xslate',
);

has mime_type => (
    is => 'rw',
    default => sub { { Xslate =>'text/html', JSON => 'application/json' }  }
);

has charset => (
    is => 'rw',
    default => sub { Encode::find_encoding('utf-8') } ,
);


has 'engine' => (
    is => 'rw',
    lazy_build => 1,
);


sub _build_engine { die 'implement me'; }

sub get_mime_type {
    my $self = shift;
    my $type = shift;

    if( ref $self->mime_type eq 'HASH') {
        return $self->mime_type->{$type} ? $self->mime_type->{$type} : 'text/html' ;
    }
    else {
        return $self->mime_type ? $self->mime_type : 'text/html' ;
    }
}

sub get_mime_charset {
    my $self = shift;
    my $type = shift;

    if( ref $self->charset eq 'HASH') {
        return $self->charset->{$type} ? $self->charset->{$type}->mime_name : 'UTF-8';
    }
    else {
        return $self->charset ? $self->charset->mime_name : 'UTF-8';
    }
}


sub BUILD {
    my $self  = shift;
    $self->engine; # LOAD
}


sub get_type {
    my $self = shift;
    my $c = shift;
    my $type = $c->stash->{template_type} || $self->default_type ;
    return $type;
}



sub render {
    my $self = shift;
    my $c    = shift;

    my $type  = $self->get_type($c);
    $self->build_template( $c ,$type );
    $self->build_stash( $c );

    my $output = $self->do_render( $c , $type );
    $self->build_response( $c , $output );

    return 1;
}


sub do_render {
    my $self  = shift;
    my $c     = shift;
    my $type  = shift;
    $self->engine->render( $type, { vars => $c->stash ,file => $c->stash->{VIEW_TEMPLATE} } );
}


sub build_stash {
    my ( $self, $c) = @_;
    $c->stash->{c} = $c;
}

sub build_template {
    my $self = shift;
    my $c    = shift;
    my $type = shift;

    unless( $c->stash->{VIEW_TEMPLATE} ) {
        my $path = $c->req->path_info;
        $path .= 'index' if $path =~ m{/$};
        $path =~ s{^/}{};
        $c->stash->{'VIEW_TEMPLATE'} = $path;
    }
}

sub build_response {
    my ( $self, $c, $output ) = @_;
    $c->res->code(200) unless $c->res->code;
    $c->res->body($output);
    unless ( $c->res->content_type ) {
        my $type = $self->get_type($c);
        my $mime_type = $self->get_mime_type($type);
        my $mime_charset = $self->get_mime_charset($type);
        $c->res->content_type( "$mime_type; charset=$mime_charset" );
    }

    1;
}


EOC;
