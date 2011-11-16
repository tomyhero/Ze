package Ze::WAF::Controller::Role::JSON;
use Ze::Role;

before 'EXCECUTE' => sub {
    my ($self,$c) = @_;
    $c->view_type('JSON');
};


1;
