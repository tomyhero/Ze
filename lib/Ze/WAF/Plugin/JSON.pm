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
    if($v_res){
        $args->{reason}{missing} = $v_res->missing if $v_res->missing;
        $args->{reason}{invalid} = [keys %{$v_res->invalid}] if
$v_res->invalid;
        $args->{reason}{custom_invalid} = [keys %{$v_res->custom_invalid}] if
$v_res->custom_invalid;
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
