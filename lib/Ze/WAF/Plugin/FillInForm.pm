package Ze::WAF::Plugin::FillInForm;
use Ze::Role;
use HTML::FillInForm::Lite;

has on_fillin => ( is => 'rw' , default => 0 );


after 'RENDER' => sub {
    my( $c ) = @_;

    return unless $c->on_fillin;

    if ( $c->stash->{fdat} ) {
        if ( $c->res->content_type =~ m{^text/x?html} || $c->res->content_type =~ m{^application/xhtml\+xml} ) {
            my $body = $c->res->body;
            my $q = $c->stash->{fdat} || $c->req;
            my $result = HTML::FillInForm::Lite->fill( \$body, $q );
            $c->res->body( $result );
        }
    }

};

1;
