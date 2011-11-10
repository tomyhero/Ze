package Ze::WAF::Dispatcher::Router;
use Ze::Class;
use Ze::Util;
use Plack::Util;
extends 'Ze::WAF::Dispatcher::Base';


has 'waf_class' => ( is => 'rw', required => 1 );
has 'router' => ( is => 'rw');
has 'home' => ( is => 'rw' , lazy_build => 1 );
has 'config_file' => ( is => 'rw' , lazy_build => 1 );
has 'controllers' => ( is => 'rw' , default => sub { {} } );

sub BUILD {
    my $self = shift;
    $self->setup_router();       
    $self->setup_controller();       
}

sub setup_controller {
    my $self = shift;
    my $routes = $self->router->{routes};
    my $controllers = {};
    if ($routes) {
        my %seen;
        foreach my $route (@$routes) {
            my $dest = $route->dest;
            my $controller = $dest->{controller};
            if (! $controller) {
                warn "No controller specified for path " . $route->pattern;
            }
            next if $seen{ $controller }++;
            my $pkg = Plack::Util::load_class( "Controller::" . $controller, $self->waf_class );
            $controllers->{$controller} = $pkg->new();
        }
        $self->controllers($controllers);
    }
}

sub setup_router {
    my $self = shift;
    my $router = $self->create_router;
    $self->router($router);
}


# steal code from Pickles::Dispatcher
sub create_router {
    my $self = shift;
    my $class = ref $self;

    my $config_file = $self->config_file;
    my $file = $config_file->cleanup;

    my $pkg = $file;
    $pkg =~ s/([^A-Za-z0-9_])/sprintf("_%2x", unpack("C", $1))/eg;


    my $fqname = sprintf '%s::%s', $class, $pkg;

    my $router_pkg = sprintf <<'SANDBOX', $fqname;
package %s;
use Router::Simple::Declare;
{
    delete $INC{$file};
    my $conf = require $file or die $!;
    $conf;
}
SANDBOX
    my $router = eval $router_pkg;

    return $router;
}



sub _build_home {
    my $self = shift;
    Ze::Util::home( ref $self );
}

sub _build_config_file {
    my $self = shift;
    $self->home->file('etc/router.pl');
}

sub match {
    my $self = shift;
    my $c = shift;

    my $match = $self->router->match( $c->env );
    my %args;
    for my $key( keys %{$match} ) {
        next if $key =~ m{^(controller|action)$};
        $args{$key} = $match->{$key};
    }

    # TODO utf8?
    $c->args( \%args );
    return ($match->{controller} , $match->{action} );

}


EOC;
