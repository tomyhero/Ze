package Ze::WAF::Controller;
use Ze::Class;
use Class::Trigger;


sub EXECUTE {
    my( $self, $c, $action ) = @_;
    $self->call_trigger('BEFORE_DISPATCH',$c,$action);
    $self->$action( $c );
    $self->call_trigger('AFTER_DISPATCH',$c,$action);
    return 1;
}



EOC;
