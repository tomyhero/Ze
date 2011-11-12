package Ze::WAF::Request;
use strict;
use warnings;
use parent 'Plack::Request';
use Plack::Response;

sub new_response {
    Plack::Response->new(@_);    
}

sub as_fdat {
    my $self = shift;
    $self->parameters->as_hashref_mixed;
}

1;
