package Ze::WAF::Plugin::Encode;
use Ze::Role;
use Encode ();

before 'INITIALIZE' => sub {
    my $c = shift;
    my $config = $c->context_config->{'Plugin::Encode'};
    my $ie = $config->{input_encoding} || 'utf-8';
    _decode( $c->req->query_parameters, $ie );
    _decode( $c->req->body_parameters, $ie );
    _decode_args($c->args, $ie);
    delete $c->req->env->{'plack.request.merged'}; # make sure

};

before 'FINALIZE' => sub {
    my $c = shift;
    if ( $c->res->content_type =~ m{^text/} ) {
        my $body = $c->res->body;
        my $config = $c->context_config->{'Plugin::Encode'};
        my $oe = $config->{output_encoding} || 'utf-8';
        #$c->res->content_type( $c->res->content_type. '; charset='. $oe );
        $c->res->body( Encode::encode( $oe, $body ) );
    }
};


sub _decode {
    my ($hmv, $ie) = @_;
    for my $key( keys %$hmv ) {
        my @values = map { Encode::decode($ie, $_) } $hmv->get_all( $key );

        $hmv->remove( $key );
        $hmv->add( $key => @values );
    }
}
sub _decode_args {
    my($h, $ie) = @_;
    for my $key( keys %{$h} ) {
        if ( ref $h->{$key} eq 'ARRAY' ) {
            my @values = map { Encode::decode($ie, $_) } @{$h->{$key}};
            $h->{$key} = \@values;
        }
        elsif(ref $h->{$key} ){
            # do nithing;
        }
        else {
            $h->{$key} = Encode::decode($ie, $h->{$key});
        }
    }
}

1;
