package Ze::WAF::Plugin::JSON;
use Ze::Role;

has 'allow_jsonp' => (
    is => 'rw',
    default => 0,
);


sub set_json_stash {
    my( $c , $args ) = @_;
    $args->{error} ||= 0;
    $c->view_type('JSON');
    $c->stash->{VIEW_TEMPLATE_VARS} = $args;
    $c->_set_json_callback_if();
}

sub set_json_error {
    my( $c , $v_res , $addition ) = @_;
    $c->view_type('JSON');
    my $args = { error => 1};
    if($addition){
        $args = $addition;
        $args->{error} = 1;
    }
    if($v_res && ref $v_res){
        $args->{error_keys} = $v_res->error_keys;
    }
    elsif($v_res) {
        $args->{error_keys} = [ $v_res ];
    }

    $c->stash->{VIEW_TEMPLATE_VARS} = $args;
    $c->_set_json_callback_if();
}

sub _set_json_callback_if {
    my ($c) = shift;
    return unless $c->allow_jsonp;
    if( my $callback = $c->req->param('callback') ){
        return unless $callback =~ /^[a-zA-Z0-9_¥.]+$/;    
        $c->stash->{callback} = $callback;
    }

}


1;
