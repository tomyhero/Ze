package Ze::WAF::Controller;
use Ze::Class;


sub EXECUTE {
    my( $self, $c, $action ) = @_;
    $self->$action( $c );
    return 1;
}





EOC;
