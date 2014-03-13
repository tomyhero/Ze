package Ze::WAF::Controller;
use Ze::Class;
use Class::Trigger;


sub EXECUTE {
    my( $self, $c, $action ) = @_;
    $self->call_trigger('BEFORE_EXECUTE',$c,$action);
    $self->$action( $c );
    $self->call_trigger('AFTER_EXECUTE',$c,$action);
    return 1;
}



EOC;
