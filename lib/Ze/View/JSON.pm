package Ze::View::JSON;
use Ze::Class;
extends 'Ze::View::Base';

use JSON::XS;
use Encode;
use Encode::JavaScript::UCS;


sub render {
    my $self = shift;
    my $args = shift;
    my $vars = $args->{vars} || {};
    my $out = '';
    my $json = encode( 'JavaScript-UCS', decode('utf8',encode_json( $vars ) ) );

    # IE6 XSS
    $json =~s/</\\u003c/g;
    $json =~s/>/\\u003e/g;

    my $callback = $args->{callback} ;
    if( $callback ) {
        $json = "$callback($json)";
    }
    return $json;
}


EOC;
