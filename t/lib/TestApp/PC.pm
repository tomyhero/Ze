package TestApp::PC;
use Mouse;
extends 'Ze::WAF';

__PACKAGE__->mk_classdata('TestApp::WAF::Context');



__PACKAGE__->meta->make_immutable();

1;
