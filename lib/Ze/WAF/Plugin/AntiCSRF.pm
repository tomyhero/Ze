package Ze::WAF::Plugin::AntiCSRF;
use Ze::Role;
use String::Random qw(random_regex);


before 'PREPARE' => sub {
        my( $c ) = @_;
        return unless delete $c->args->{use_anticsrf};
        $c->__AntiCSRF_set_token($c);

};

has '__AntiCSRF_cookie_expires' =>  ( is => 'rw', default => time + 60 * 60  );
has 'AntiCSRF_token_name' =>  ( is => 'rw', default => 'anticsrf_token' );
has 'AntiCSRF_token_value' =>  ( is => 'rw');

sub __AntiCSRF_set_token {
    my $c = shift;
    my $token_name = $c->__AntiCSRF_set_token;


    unless( $c->can('create_session') ) {
        die 'implement $c->create_session() please';
    }

    my $session = $c->create_session();

    my $token = random_regex("[a-zA-Z0-9_]{8}");

    $session->set( $token_name , $token );
    $session->finalize();

    $c->res->cookies->{$token_name} = { 
        value => $token,
        path  => "/",
        expires => $c->__AntiCSRF_cookie_expires,
    };

    $c->AntiCSRF_token_value( $token );
}

sub abort_CSRF {
    my $c = shift;
    my $token_name = $c->__AntiCSRF_set_token;

    unless( $c->can('create_session') ) {
        die 'implement $c->create_session() please';
    }

    my $session = $c->create_session();
    my $req_val = $c->req->param( $token_name );
    my $session_val = $session->get( $token_name );

    unless ( $req_val && $session_val && ($req_val eq $session_val) ) {
        $c->res->status( 403 );
        $c->res->body( 'Forbidden' );
        $c->finished( 1 );
        $c->abort;
    }
}

1;

=head1 NAME


Ze::WAF::Plugin::AntiCSRF -  AntiCSRF Plugin


=cut
