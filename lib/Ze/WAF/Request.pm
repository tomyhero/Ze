package Ze::WAF::Request;
use strict;
use warnings;
use parent 'Plack::Request';
use Plack::Response;

sub new_response {
    Plack::Response->new(@_);    
}

1;
