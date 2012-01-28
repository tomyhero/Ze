package Ze::WAF::Controller::Role::JSON;
use Ze::Role;

before 'EXECUTE' => sub {
    my ($self,$c) = @_;
    $c->view_type('JSON');
};


1;
